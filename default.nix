{ pkgs ? import <nixpkgs> {}
, name ? "personal-homepage"
, baseUrl ? "https://frederic.menou.me"
}:

let
  web     = import ./web     { inherit pkgs baseUrl; };
  sources = import ./sources { inherit pkgs; };

in
  pkgs.symlinkJoin {
    inherit name;

    paths = [
      # The order matters as they are potentially overriding files, so watch out!
      sources
      web
    ];
  }
