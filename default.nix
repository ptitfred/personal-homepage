{ pkgs ? import <nixpkgs> {}
, name ? "personal-homepage"
, baseUrl ? "https://frederic.menou.me"
}:

let
  website   = pkgs.callPackage ./website   {};
  scripting = pkgs.callPackage ./scripting {};

in
  pkgs.symlinkJoin {
    inherit name;

    paths = [
      # The order matters as they are potentially overriding files, so watch out!
      scripting
      website
    ];
  }
