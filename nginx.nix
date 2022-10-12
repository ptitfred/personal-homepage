{ pkgs
, baseUrl
}:

let
  root = pkgs.callPackage ./website/package.nix { inherit baseUrl; };

  extraConfig = builtins.readFile ./nginx.conf;

in
  { inherit root extraConfig; }
