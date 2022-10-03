{ pkgs ? import <nixpkgs> {}
, name ? "frontend"
}:

let
  gitignoreSource = pkgs.callPackage ../gitignore.nix {};

  spagoPkgs = pkgs.callPackage ./spago-packages.nix {};

  dhallDeps = pkgs.dhallPackages.callPackage ./dhall-dependencies.nix {};

in
  pkgs.stdenv.mkDerivation {
    inherit name;

    buildInputs = [
      spagoPkgs.installSpagoStyle
      spagoPkgs.buildSpagoStyle
    ];
    nativeBuildInputs = with pkgs; [
      purescript
      esbuild
      spago
      git
    ];

    src = gitignoreSource ./.;

    unpackPhase = ''
      cp $src/spago.dhall .
      cp $src/packages.dhall .
      cp -r $src/src .

      install-spago-style

      mkdir -p .cache/dhall
      cp -r ${dhallDeps}/.cache/dhall/* .cache/dhall/
      chmod -R u+w .cache/dhall
    '';

    buildPhase = ''
      export XDG_CACHE_HOME=.cache
      build-spago-style "./src/**/*.purs"
      spago --global-cache=skip bundle-app --minify --no-build --no-install --source-maps --to index.js
    '';

    installPhase = ''
      mkdir $out
      mv index.js* $out/
    '';
  }
