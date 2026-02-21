{
  description = "Personal homepage (frederic.menou.me)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
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

      website-full = baseUrl: (pkgs.ptitfred.website.nginx.override { inherit baseUrl; }).root;

      tests = pkgs.callPackage ./tests { inherit nixosModule; };

      nixosModule = import ./nixos { inherit overlays; };

      inherit (pkgs.ptitfred) zola;
      inherit (pkgs.ptitfred.lib) mkApps mkChecks;
      inherit (pkgs.posix-toolbox) nix-linter;

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
          lint        = "${nix-linter}/bin/nix-linter";
          tests       = "${tests.screenshots}/bin/test-screenshots";
        };

        checks.${system} = mkChecks {
          lint-nix = "${nix-linter}/bin/nix-linter ${./.}";
        };

        devShells.${system}.default = pkgs.callPackage ./shell.nix {};
      };
}
