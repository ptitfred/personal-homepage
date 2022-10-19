{ pkgs
, curl
, htmlq
, imagemagick
, puppeteer-cli
}:

let wrapper = pkgs.callPackage ./wrapper.nix {};
    take-screenshots = wrapper "take-screenshots.sh" [ curl htmlq imagemagick puppeteer-cli ];
in { inherit take-screenshots; }
