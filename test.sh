#! /usr/bin/env nix-shell
# shellcheck shell=bash
#! nix-shell -i bash -p python38

set -e

port=8000

nix build -f default.nix --argstr baseUrl "http://localhost:${port}"

echo "Serving $(readlink result)"

nix-shell -p python38 --command "python3 -m http.server $port --directory result/"
