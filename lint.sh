#! /usr/bin/env nix-shell
# shellcheck shell=bash
#! nix-shell -i bash -p nix-linter

set -e

find . -type f \
  -name "*.nix" \
  ! -path "./scripting/spago-packages.nix" \
  ! -path "./scripting/.spago/*" \
  ! -path "./nix/*" \
  -exec nix-linter {} \;
