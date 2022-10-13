{ pkgs ? import <nixpkgs> {}
, baseUrl ? "https://frederic.menou.me"
}:

pkgs.callPackage ./package.nix {
  inherit baseUrl;
}
