#! /usr/bin/env nix-shell
# shellcheck shell=bash
#! nix-shell -i bash -p git

set -e

sourceRevision=$(git rev-parse --short HEAD)
nix-build ./default.nix

result="$(pwd)/result"
cd target

pendingChanges=$(git status -s | wc -l)

if [ "$pendingChanges" -gt 0 ]
then
  echo "Some changes weren't committed in the target repository. Aborting"
  exit 1

else
  git ls-files -z | xargs -0 rm -f
  cp --recursive --dereference --no-preserve=all "${result}"/. ./
  git add --all
  git commit -m "Automated deployment from ${sourceRevision}"
  git push clever master
fi
