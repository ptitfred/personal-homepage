let fetchPackage = self: definition: path:
      self.callPackage (self.fetchFromGitHub (builtins.fromJSON (builtins.readFile definition)) + path) {};
in
  self: { ... }:
    {
      posix-toolbox = fetchPackage self ./ptitfred-posix-toolbox.json "/nix/default.nix";
    }
