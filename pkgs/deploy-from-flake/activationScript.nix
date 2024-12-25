{ coreutils, lib, writeShellApplication
, linkPath, root
}:

let directory = builtins.dirOf linkPath;
 in writeShellApplication {
      name = "deploy-from-flake-activation-script";
      runtimeInputs = [ coreutils ];
      text =
        assert lib.asserts.assertMsg (! (builtins.isNull root)) "root must be set";
        ''
          if [ ! -e "${directory}" ]; then
            mkdir -p "${directory}"
            chown nginx:nginx "${directory}"
          fi
          if [ ! -e "${linkPath}" ]; then
            ln -s ${root} "${linkPath}"
            chown nginx:nginx "${linkPath}"
          fi
        '';
    }
