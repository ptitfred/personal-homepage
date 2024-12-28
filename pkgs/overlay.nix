final: _:

let mkApps   = final.lib.attrsets.mapAttrs (_: program: { "type" = "app"; inherit program; });
    mkChecks = final.lib.attrsets.mapAttrs mkCheck;
    mkCheck = name: checkPhase:
      final.stdenvNoCC.mkDerivation {
        inherit name checkPhase;
        dontBuild = true;
        src = ./.;
        doCheck = true;
        installPhase = ''
          mkdir "$out"
        '';
      };
in
{
  ptitfred = {
    lib = {
      inherit mkApps mkChecks;
      brotlify = final.callPackage ./brotlify {};
    };
    website           = final.callPackage ./website           {};
    check-screenshots = final.callPackage ./check-screenshots {};
    take-screenshots  = final.callPackage ./take-screenshots  {};
    deploy-from-flake = final.callPackage ./deploy-from-flake {};
    zola              = final.callPackage ./zola              {};
  };
  puppeteer-cli = final.callPackage ./puppeteer-cli {};
}
