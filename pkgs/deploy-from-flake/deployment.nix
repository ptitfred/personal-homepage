{ lib, lix, writeShellApplication
, baseUrl, flakeInput, linkPath
, ptitfred, screenshotsDirectory
}:

let expectingNotNull = name: value:
      lib.asserts.assertMsg (! (builtins.isNull value)) "${name} must be set";
 in
writeShellApplication {
  name = "deploy-from-flake";
  runtimeInputs = [ lix ];
  text =
    assert expectingNotNull "baseUrl"              baseUrl;
    assert expectingNotNull "screenshotsDirectory" screenshotsDirectory;
    ''
      previous_drv=""
      if [ -h "${linkPath}" ]; then
        previous_drv="$(readlink "${linkPath}")"
      fi

      nix build --out-link "${linkPath}" --impure -E "(builtins.getFlake \"${flakeInput}\").website.default \"${baseUrl}\""

      latest_drv="$(readlink "${linkPath}")"

      if [ "$latest_drv" != "$previous_drv" ]; then
        echo "New version deployed!"
        ${ptitfred.take-screenshots}/bin/take-screenshots ${baseUrl} "${screenshotsDirectory}"
      fi
    '';
}
