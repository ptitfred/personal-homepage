{ writeShellApplication
, python39
, posix-toolbox
, ptitfred
}:

let static = ptitfred.website.static.override { baseUrl = testUrl; };
    testUrl = "http://localhost:${port}";
    port = "8000";
in

writeShellApplication {
  name = "test-screenshots";
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
