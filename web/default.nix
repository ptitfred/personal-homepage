{ pkgs ? import <nixpkgs> {}
, name ? "homepage-statically-generated"
, baseUrl ? "https://frederic.menou.me"
}:

let
  gitignoreSource = pkgs.callPackage ../gitignore.nix { };

in
  pkgs.stdenv.mkDerivation {
    inherit name;

    nativeBuildInputs = with pkgs; [
      zola
    ];

    src = gitignoreSource ./.;

    buildPhase = ''
      zola build -u ${baseUrl}
    '';

    installPhase = ''
      mkdir $out
      cp -r public/. $out/
    '';
  }
