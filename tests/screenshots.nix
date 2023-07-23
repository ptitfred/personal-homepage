{ writeShellApplication
, python38
, imagemagick
, puppeteer-cli
, htmlq
, jq
, posix-toolbox
, scripts
, port
, testUrl
, static
}:

writeShellApplication {
  name = "tests";
  runtimeInputs = [ python38 imagemagick puppeteer-cli htmlq jq posix-toolbox.wait-tcp ];
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
      ${scripts.take-screenshots}/bin/take-screenshots.sh "${testUrl}" screenshots
    }

    setup
    serveWebsite
    takeScreenshots
  '';
}
