{ stdenv
, callPackage
, zola
, baseUrl
}:

let
  gitignoreSource = callPackage ../gitignore.nix { };

in
  stdenv.mkDerivation {
    name = "personal-homepage-website";

    nativeBuildInputs = [
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
