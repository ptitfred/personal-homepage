#!/usr/bin/env bash

set -e

node2nix -16 -c node.nix -l package-lock.json
spago2nix generate
dhall-to-nixpkgs directory --fixed-output-derivations . --file ./base.dhall > dhall-dependencies.nix
