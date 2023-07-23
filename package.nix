{ pkgs
, baseUrl
}:

let
  gitignoreSource = pkgs.callPackage ./gitignore.nix { };

  website   = pkgs.callPackage website/package.nix { inherit baseUrl gitignoreSource; };
  scripting = pkgs.callPackage scripting/package.nix {};
  content =
    pkgs.symlinkJoin {
      name = "personal-homepage";
      paths = [ scripting website ];
    };

in
  {
    nginx = pkgs.callPackage webservers/nginx/package.nix {
      root = content;
    };
    tools = pkgs.callPackage scripts/package.nix {};
  }
