final: _:

{
  ptitfred = {
    lib.brotlify      = final.callPackage ./brotlify          {};
    website           = final.callPackage ./website           {};
    check-screenshots = final.callPackage ./check-screenshots {};
    take-screenshots  = final.callPackage ./take-screenshots  {};
    deploy-from-flake = final.callPackage ./deploy-from-flake {};
  };
  puppeteer-cli = final.callPackage ./puppeteer-cli {};
}
