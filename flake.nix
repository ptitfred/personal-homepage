{
  description = "Personal homepage (frederic.menou.me)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    gitignore.url = "github:hercules-ci/gitignore.nix";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    posix-toolbox = {
      url = "github:ptitfred/posix-toolbox";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, gitignore, posix-toolbox, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system overlays; };

      inherit (gitignore.lib) gitignoreSource;

      scripting = pkgs.callPackage scripting/package.nix { inherit gitignoreSource; };
      website = baseUrl: pkgs.callPackage website/package.nix { inherit baseUrl gitignoreSource; };
      root = baseUrl:
        pkgs.symlinkJoin {
          name = "personal-homepage";
          paths = [ scripting (website baseUrl) ];
        };
      scripts = pkgs.callPackage ./scripts/package.nix {};

      overlay = final: prev: {
        ptitfred = {
          nginx = prev.lib.makeOverridable ({ baseUrl ? "http://localhost" }: prev.callPackage webservers/nginx/package.nix { root = root baseUrl; }) {};
          inherit (scripts) take-screenshots;
        };
        posix-toolbox = prev.callPackage "${posix-toolbox}/nix/default.nix" {};
      };

      overlays = [
        overlay
      ];

      tests =
        {
          screenshots =
            pkgs.callPackage tests/screenshots.nix rec {
              port = "8000";
              testUrl = "http://localhost:${port}";
              static = website testUrl;
              inherit scripts;
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

    in
      rec {
        overlays.default = overlay;

        packages.${system} = {
          inherit (scripts) take-screenshots;
          inherit scripting ;
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
        };

        devShells.${system}.default = with pkgs; mkShell { buildInputs = [ zola ]; };
      };
}
