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
        let port = "8000";
            testUrl = "http://localhost:${port}";
            static = website testUrl;
         in pkgs.writeShellApplication rec {
              name = "tests";
              runtimeInputs = with pkgs; [ python38 imagemagick puppeteer-cli htmlq jq pkgs.posix-toolbox.wait-tcp ];
              text = ''
                set -e

                function setup {
                  mkdir -p screenshots
                  trap 'kill $COPROC_PID' err exit
                }

                function serveWebsite {
                  coproc python3 -m http.server "${port}" --directory "${static}"
                  wait-tcp ${port}
                }

                function takeScreenshots {
                  ${scripts.take-screenshots}/bin/take-screenshots.sh "${testUrl}" screenshots
                }

                setup
                serveWebsite
                takeScreenshots
              '';
            };

    in
      rec {
        overlays.default = overlay;

        packages.${system} = {
          inherit (scripts) take-screenshots;
          inherit scripting;
          nginx-root = pkgs.ptitfred.nginx.root;
        };

        apps.${system} = {
          tests = {
            type = "app";
            program = "${tests}/bin/tests";
          };
        };

        devShells.${system}.default = with pkgs; mkShell { buildInputs = [ zola ]; };
      };
}
