{ callPackage, lib, stdenvNoCC }:

let mkApps   = lib.attrsets.mapAttrs (_: program: { "type" = "app"; inherit program; });
    mkChecks = lib.attrsets.mapAttrs mkCheck;
    mkCheck = name: checkPhase:
      stdenvNoCC.mkDerivation {
        inherit name checkPhase;
        dontBuild = true;
        src = ./.;
        doCheck = true;
        installPhase = ''
          mkdir "$out"
        '';
      };
    brotlify = callPackage ./brotlify.nix {};
in
{
  inherit mkApps mkChecks brotlify;
}
