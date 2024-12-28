{ callPackage, nixosModule }:

{
  screenshots = callPackage ./screenshots.nix {};

  in-nginx =
    callPackage ./in-nginx.nix {
      cores = 2;
      memorySize = 4096;
      inherit nixosModule;
    };
}
