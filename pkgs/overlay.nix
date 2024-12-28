final: prev:

{
  ptitfred = {
    lib               = final.callPackage ./lib               {};
    website           = final.callPackage ./website           {};
    check-screenshots = final.callPackage ./check-screenshots {};
    take-screenshots  = final.callPackage ./take-screenshots  {};
    deploy-from-flake = final.callPackage ./deploy-from-flake {};
    zola              = final.callPackage ./zola              {};
  };

  posix-toolbox = prev.posix-toolbox // {
    nix-linter = prev.posix-toolbox.nix-linter.override {
      excludedPaths = import ../.linter.nix;
    };
  };

  puppeteer-cli = final.callPackage ./puppeteer-cli {};
}
