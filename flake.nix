{
  description = "Personal homepage (frederic.menou.me)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    gitignore.url = "github:hercules-ci/gitignore.nix";
    gitignore.inputs.nixpkgs.follows = "nixpkgs";
    posix-toolbox.url = "github:ptitfred/posix-toolbox";
    easy-ps.url = "github:justinwoo/easy-purescript-nix";
  };

  outputs = { nixpkgs, gitignore, posix-toolbox, easy-ps, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system overlays; };

      overlay = import pkgs/overlay.nix;

      overlays = [
        gitignore.overlay
        posix-toolbox.overlays.default
        (_: _: { easy-ps = easy-ps.packages.${system}; })
        overlay
      ];

      website = baseUrl: pkgs.ptitfred.website.static.override { inherit baseUrl; };

      tests =
        {
          screenshots =
            pkgs.callPackage tests/screenshots.nix rec {
              port = "8000";
              testUrl = "http://localhost:${port}";
              static = website testUrl;
            };

          local =
            pkgs.callPackage tests/local.nix rec {
              port = "8000";
              static = website "http://localhost:${port}";
            };

          in-nginx =
            pkgs.callPackage tests/in-nginx.nix {
              cores = 2;
              memorySize = 4096;
              inherit nixosModule;
            };
        };

      mkCheck = name: checkPhase:
        pkgs.stdenvNoCC.mkDerivation {
          inherit name checkPhase;
          dontBuild = true;
          src = ./.;
          doCheck = true;
          installPhase = ''
            mkdir "$out"
          '';
        };

      linter = pkgs.posix-toolbox.nix-linter.override {
        excludedPaths = [
          "scripting/spago-packages.nix"
          "scripting/.spago/*"
          "nix/*"
        ];
      };

      nixosModule = import ./nixos { inherit overlays; };

    in
      {
        nixosModules.default = nixosModule;

        packages.${system} = {
          inherit (pkgs.ptitfred) take-screenshots check-screenshots;
          integration-tests = tests.in-nginx;
        };

        apps.${system} = {
          tests = {
            type = "app";
            program = "${tests.screenshots}/bin/tests";
          };

          local = {
            type = "app";
            program = "${tests.local}/bin/local";
          };

          dev-server = {
            type = "app";
            program =
              let script = pkgs.writeShellScriptBin "zola-dev-server" "${pkgs.zola}/bin/zola -r $1 serve";
               in "${script}/bin/zola-dev-server";
          };

          lint = {
            type = "app";
            program = "${linter}/bin/nix-linter";
          };
        };

        checks.${system} = {
          lint =
            mkCheck "lint-nix" ''
              ${linter}/bin/nix-linter ${./.}
            '';
        };

        devShells.${system}.default = with pkgs; mkShell { buildInputs = [ zola ]; };
      };
}
