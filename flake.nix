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
      website-full = baseUrl: (pkgs.ptitfred.website.nginx.override { inherit baseUrl; }).root;

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

      linter = pkgs.posix-toolbox.nix-linter.override {
        excludedPaths = [
          "scripting/spago-packages.nix"
          "scripting/.spago/*"
          "nix/*"
        ];
      };

      nixosModule = import ./nixos { inherit overlays; };

      zola = {
        check      = pkgs.writeShellScript "zola-check"      "${pkgs.zola}/bin/zola --root $1 check";
        dev-server = pkgs.writeShellScript "zola-dev-server" "${pkgs.zola}/bin/zola --root $1 serve --open";
      };

      inherit (pkgs.ptitfred.lib) mkApps mkChecks;

    in
      {
        nixosModules.default = nixosModule;

        # function used in the `deploy-from-flake`
        website.default = website-full;

        packages.${system} = {
          inherit (pkgs.ptitfred) take-screenshots check-screenshots;
          integration-tests = tests.in-nginx;
        };

        apps.${system} = mkApps {
          check-links = "${zola.check}";
          dev-server  = "${zola.dev-server}";
          lint        = "${linter}/bin/nix-linter";
          local       = "${tests.local}/bin/local";
          tests       = "${tests.screenshots}/bin/tests";
        };

        checks.${system} = mkChecks {
          lint-nix = "${linter}/bin/nix-linter ${./.}";
        };

        devShells.${system}.default = with pkgs; mkShell { buildInputs = [ zola ]; };
      };
}
