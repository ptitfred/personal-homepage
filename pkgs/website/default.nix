{ callPackage, lib, ptitfred, symlinkJoin }:

let scripting = callPackage ../../scripting/package.nix {};
    static = { baseUrl }: callPackage ../../website/package.nix { inherit baseUrl; };

    nginx = extras:
      {
        extraConfig = builtins.readFile ./nginx.conf;
        root =
          ptitfred.lib.brotlify {
            src =
              symlinkJoin {
                name = "personal-homepage";
                paths = [ scripting (static extras) ];
              };
          };
      };

    defaults = { baseUrl = "http://localhost"; };
 in {
      nginx  = lib.makeOverridable nginx  defaults;
      static = lib.makeOverridable static defaults;
    }
