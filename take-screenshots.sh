#! /usr/bin/env nix-shell
# shellcheck shell=bash
#! nix-shell -i bash -p python38 imagemagick puppeteer-cli htmlq jq

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

function listPages {
  local path="$1"
  htmlq -t urlset url loc < "${path}/sitemap.xml"
}

function readContentHash {
  local url="$1"
  curl -s "$url" | htmlq "meta[property=source_hash]" --attribute content
}

function takeScreenshot {
  local url="$1"

  hash=$(readContentHash "$url")
  if [ -n "$hash" ]
  then
    puppeteer screenshot --viewport 1200x630 "$url" "screenshots/$hash-uncropped.png"
    echo "Cropping to screenshots/$hash.png"
    convert "screenshots/$hash-uncropped.png" -crop 1200x630+0+0 "screenshots/$hash.png"
    rm "screenshots/$hash-uncropped.png"
  fi
}

function takeScreenshots {
  while read -r line ; do takeScreenshot "$line" ; done
}

function serveWebsite {
  local path="$1"
  coproc python3 -m http.server "$port" --directory "$path"
}

function proceed {
  static=$(buildStatic | readStorePath)
  serveWebsite "$static"
  listPages "$static" | takeScreenshots
}

function sumUp {
  echo "--"
  echo "$(find screenshots -name '*.png' | wc -l) screenshots taken, good bye."
}

setup
proceed
sumUp
