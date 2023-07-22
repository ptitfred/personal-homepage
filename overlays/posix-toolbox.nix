let fetchPackage = pkgs: definition: path:
      pkgs.callPackage (pkgs.fetchFromGitHub (builtins.fromJSON (builtins.readFile definition)) + path) {};
in
  final: prev:
    {
      posix-toolbox = fetchPackage final ./ptitfred-posix-toolbox.json "/nix/default.nix";
      ptitfred = prev.ptitfred // { nginx = prev.ptitfred.nginx.override { baseUrl = "http://localhost:8000"; }; };
    }
