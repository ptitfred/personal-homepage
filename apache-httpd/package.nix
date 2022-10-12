{ stdenv
, callPackage
}:

let
  gitignoreSource = callPackage ../gitignore.nix { };

in
  stdenv.mkDerivation {
    name = "personal-homepage-apache-htaccess";

    src = gitignoreSource ./.;

    installPhase = ''
      mkdir $out
      cp -r $src/.htaccess $out/
    '';
  }
