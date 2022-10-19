{ pkgs
, htmlq
, imagemagick
, lib
, makeWrapper
, puppeteer-cli
, stdenv
}:

let wrapper = pkgs.callPackage ./wrapper.nix {};
 in wrapper "take-screenshots.sh" [ imagemagick puppeteer-cli htmlq ]
