{ pkgs ? import <nixpkgs> {}
, name ? "personal-homepage"
, baseUrl ? "https://frederic.menou.me"
}:

let
  web     = pkgs.callPackage ./web     {};
  sources = pkgs.callPackage ./sources {};

in
  pkgs.symlinkJoin {
    inherit name;

    paths = [
      # The order matters as they are potentially overriding files, so watch out!
      sources
      web
    ];
  }
