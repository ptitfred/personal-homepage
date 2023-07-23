{
  description = "Personal homepage (frederic.menou.me)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    gitignore.url = "github:hercules-ci/gitignore.nix";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, gitignore, ... }:
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
      tools = pkgs.callPackage ./scripts/package.nix {};

      overlay = final: prev: {
        ptitfred = {
          nginx = prev.lib.makeOverridable ({ baseUrl ? "http://localhost" }: prev.callPackage webservers/nginx/package.nix { root = root baseUrl; }) {};
          inherit (tools) take-screenshots;
        };
      };

      overlays = [
        overlay
      ];

    in
      {
        overlays.default = overlay;

        packages.${system} = pkgs.ptitfred // { inherit scripting; };

        devShells.${system}.default = with pkgs; mkShell { buildInputs = [ zola ]; };
      };
}
