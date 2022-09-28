#!/usr/bin/env bash

set -e

port=8000

nix build -f default.nix --argstr baseUrl "http://localhost:${port}"

echo "Serving $(readlink result)"

nix-shell -p python38 --command "python3 -m http.server $port --directory result/"
