{ buildDhallDirectoryPackage, buildDhallUrl }:
  buildDhallDirectoryPackage {
    name = ".";
    src = ./.;
    file = "./packages.dhall";
    source = false;
    document = false;
    dependencies = [
      (buildDhallUrl {
        url = "https://raw.githubusercontent.com/purescript/package-sets/psc-0.15.2-20220706/src/packages.dhall";
        hash = "sha256-eiTr26yyv6J7L8bOPalvBICT1k5UNplloqe12YkrYDE=";
        dhallHash = "sha256:7a24ebdbacb2bfa27b2fc6ce3da96f048093d64e54369965a2a7b5d9892b6031";
        })
      ];
    }
