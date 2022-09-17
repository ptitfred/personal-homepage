#!/usr/bin/env bash

set -e

sourceRevision=$(git rev-parse --short HEAD)
nix-build sources/default.nix

cd target

pendingChanges=$(git status -s | wc -l)

cp --recursive --no-preserve=all ../result/* ./

if [ "$pendingChanges" -gt 0 ]
then
  echo "Some changes weren't committed in the target repository. Aborting"
  exit 1
else
  git add --all
  git commit -m "Automated deployment from ${sourceRevision}"
  git push clever master
fi
