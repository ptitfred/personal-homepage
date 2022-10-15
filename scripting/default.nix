{ pkgs ? import <nixpkgs> {}
}:

pkgs.callPackage ./package.nix { minify = false; }
