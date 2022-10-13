{ pkgs
, baseUrl
}:

let
  website   = pkgs.callPackage ./website/package.nix { inherit baseUrl; };
  scripting = pkgs.callPackage ./scripting/package.nix {};

  root = pkgs.symlinkJoin {
    name = "personal-homepage";
    paths = [ scripting website ];
  };

  extraConfig = builtins.readFile ./nginx.conf;

in
  { inherit root extraConfig; }
