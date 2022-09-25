{ pkgs ? import <nixpkgs> {}
, name ? "homepage-statically-generated"
, baseUrl ? "https://frederic.menou.me"
}:

let
  gitignoreSource = import ../gitignore.nix { inherit pkgs; };

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
