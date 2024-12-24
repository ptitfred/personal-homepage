final: _:

{
  ptitfred = {
    website           = final.callPackage ./website           {};
    check-screenshots = final.callPackage ./check-screenshots {};
    take-screenshots  = final.callPackage ./take-screenshots  {};
  };
  puppeteer-cli = final.callPackage ./puppeteer-cli {};
}
