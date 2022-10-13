{ pkgs ? import <nixpkgs> {}
, baseUrl ? "https://frederic.menou.me"
}:

let gitignoreSource = pkgs.callPackage ../gitignore.nix { };
in pkgs.callPackage ./package.nix { inherit baseUrl gitignoreSource; }
