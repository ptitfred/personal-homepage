{
  description = "Personal homepage (frederic.menou.me)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    previous.url = "github:nixos/nixpkgs/nixos-22.11";
    gitignore.url = "github:hercules-ci/gitignore.nix";
    gitignore.inputs.nixpkgs.follows = "nixpkgs";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    posix-toolbox.url = "github:ptitfred/posix-toolbox";
    easy-ps.url = "github:justinwoo/easy-purescript-nix";
  };

  outputs = { nixpkgs, previous, gitignore, posix-toolbox, easy-ps, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system overlays; };

      previous-pkgs = import previous { inherit system; };

      inherit (gitignore.lib) gitignoreSource;

      scripting = pkgs.callPackage scripting/package.nix { inherit gitignoreSource; };
      website = baseUrl: pkgs.callPackage website/package.nix { inherit baseUrl gitignoreSource; };
      root = baseUrl:
        pkgs.symlinkJoin {
          name = "personal-homepage";
          paths = [ scripting (website baseUrl) ];
        };

      overlay = _: prev: {
        nix-linter = previous-pkgs.nix-linter;
        easy-ps = easy-ps.packages.${system};
        ptitfred = {
          nginx = prev.lib.makeOverridable ({ baseUrl ? "http://localhost" }: prev.callPackage webservers/nginx/package.nix { root = root baseUrl; }) {};
          take-screenshots = prev.callPackage scripts/take-screenshots.nix {};
        };
      };

      overlays = [
        overlay
        posix-toolbox.overlay
      ];

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
              testing-python = pkgs.callPackage "${nixpkgs}/nixos/lib/testing-python.nix" {};
            };
        };

      lint = pkgs.callPackage ./lint.nix {};

    in
      {
        overlays.default = overlay;

        packages.${system} = {
          inherit (pkgs.ptitfred) take-screenshots;
          inherit scripting;
          nginx-root = pkgs.ptitfred.nginx.root;
          integration-tests-github = tests.in-nginx;
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

          lint = {
            type = "app";
            program = "${lint}/bin/lint";
          };
        };

        devShells.${system}.default = with pkgs; mkShell { buildInputs = [ zola ]; };
      };
}
