{ lib, lix, writeShellApplication
, baseUrl, flakeInput, linkPath
}:

writeShellApplication {
  name = "deploy-from-flake";
  runtimeInputs = [ lix ];
  text =
    assert lib.asserts.assertMsg (! (builtins.isNull baseUrl)) "baseUrl must be set";
    ''
      nix build --out-link "${linkPath}" --impure -E "(builtins.getFlake \"${flakeInput}\").website.default \"${baseUrl}\""
    '';
}
