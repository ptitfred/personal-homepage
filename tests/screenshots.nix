{ writeShellApplication
, python39
, posix-toolbox
, ptitfred
, port
, testUrl
, static
}:

writeShellApplication {
  name = "tests";
  runtimeInputs = [ python39 posix-toolbox.wait-tcp ptitfred.take-screenshots ];
  text = ''
    set -e

    function setup {
      mkdir -p screenshots
      trap 'kill $COPROC_PID' err exit
    }

    function serveWebsite {
      coproc python3 -m http.server "${port}" --directory "${static}"
      wait-tcp ${port}
    }

    function takeScreenshots {
      take-screenshots "${testUrl}" screenshots
    }

    setup
    serveWebsite
    takeScreenshots
  '';
}
