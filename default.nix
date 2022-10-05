{ pkgs ? import <nixpkgs> {}
, baseUrl ? "https://frederic.menou.me"
}:

let
  website   = pkgs.callPackage ./website/package.nix { inherit baseUrl; };
  scripting = pkgs.callPackage ./scripting {};

in
  pkgs.symlinkJoin {
    name = "personal-homepage";

    paths = [
      # The order matters as they are potentially overriding files, so watch out!
      scripting
      website
    ];
  }
