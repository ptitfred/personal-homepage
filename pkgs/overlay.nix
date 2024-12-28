final: _:

{
  ptitfred = {
    lib               = final.callPackage ./lib               {};
    website           = final.callPackage ./website           {};
    check-screenshots = final.callPackage ./check-screenshots {};
    take-screenshots  = final.callPackage ./take-screenshots  {};
    deploy-from-flake = final.callPackage ./deploy-from-flake {};
    zola              = final.callPackage ./zola              {};
  };
  puppeteer-cli = final.callPackage ./puppeteer-cli {};
}
