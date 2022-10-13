{ pkgs
, stdenv
, gitignoreSource
, content
}:

let
  configuration =
    stdenv.mkDerivation {
      name = "personal-homepage-apache-htaccess";

      src = gitignoreSource ./.;

      installPhase = ''
        mkdir $out
        cp -r $src/.htaccess $out/
      '';
    };
in

  pkgs.symlinkJoin {
    name = "personal-homepage-apache-httpd";

    paths = [
      configuration
      content
    ];
  }
