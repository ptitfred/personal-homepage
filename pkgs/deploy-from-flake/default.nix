{ callPackage, lib }:

let deployment =
      { baseUrl, flakeInput, linkPath }:

      callPackage ./deployment.nix {
        inherit baseUrl flakeInput linkPath;
      };

    defaults = {
      linkPath = "/var/lib/web-profiles/personal-homepage";
    };

    deploymentDefaults = defaults // {
      # To be changed in production absolutely
      baseUrl = null;

      # Overridable if you want to test a branch
      flakeInput = "github:ptitfred/personal-homepage";
    };

    activationScriptDefaults = defaults // {
      # To be changed in production absolutely
      root = null;
    };

    activationScript =
      { linkPath, root }:

      callPackage ./activationScript.nix {
        inherit linkPath root;
      };

 in {
      activation-script = lib.makeOverridable activationScript activationScriptDefaults;
      deployment        = lib.makeOverridable deployment       deploymentDefaults;
    }
