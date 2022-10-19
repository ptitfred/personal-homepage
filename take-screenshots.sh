#! /usr/bin/env nix-shell
# shellcheck shell=bash
#! nix-shell -i bash -p python38 imagemagick puppeteer-cli htmlq jq posix-toolbox.wait-tcp

set -e

port=8000
baseUrl="http://localhost:${port}"

function buildStatic {
  nix build --json --no-link -f website/default.nix --argstr baseUrl "$baseUrl"
}

function readStorePath {
  jq -r '.[0].outputs.out'
}

function setup {
  rm -rf screenshots
  mkdir screenshots
  trap 'kill $COPROC_PID' err exit
}

function serveWebsite {
  local path="$1"
  coproc python3 -m http.server "$port" --directory "$path"
}

function build {
  static=$(buildStatic | readStorePath)
  serveWebsite "$static"
}

setup
build
wait-tcp $port
scripts/take-screenshots.sh "$baseUrl" screenshots
