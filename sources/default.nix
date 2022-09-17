{ pkgs ? import <nixpkgs> {}
, name ? "frontend"
}:

let
  gitignoreSource = import ../gitignore.nix { inherit pkgs; };

  spagoPkgs = import ./spago-packages.nix { inherit pkgs; };

  dhallDeps = pkgs.dhallPackages.callPackage ./dhall-dependencies.nix {};
  nodeDeps = (import ./node.nix {}).nodeDependencies;

in
  pkgs.stdenv.mkDerivation {
    inherit name;

    buildInputs = [
      spagoPkgs.installSpagoStyle
      spagoPkgs.buildSpagoStyle
      nodeDeps
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

      rm -rf node_modules
      ln -s ${nodeDeps}/lib/node_modules ./node_modules
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
