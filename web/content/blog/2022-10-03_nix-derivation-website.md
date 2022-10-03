+++
title = "This website is statically generated via Nix"
date = 2022-10-03
[taxonomies]
media-types = ["blog"]
programming-languages = ["nix"]
+++

# Hosted on Clever-Cloud

This blog is (currently) hosted on [Clever-Cloud](https://www.clever-cloud.com), a PaaS.

This website is static so I went to the easier option: a static website which is
actually served by good ol' Apache httpd.

The first versions of this website were a sole index.html file, pushed via git+ssh
to the Clever-Cloud's application, as it's meant to be.

As the urge to blog was building, I looked into a solution to handle its content
in a saner way. I'm used to writing html by hand but we all know that it's not
the proper way to produce content. When writing your ideas down you don't want
to mess with the syntax.

As a long time user of pandoc for the vast majority of my personal or
professional documentation over the last 5 years, I went to a markdown-based
solution. And I discovered Zola when reading about [biscuits](https://www.biscuitsec.org).
By the way you should learn about biscuits, but that's a story for another time.

Also I love [Nix](https://nixos.org/).

# Zola

[Zola](https://www.getzola.org) is a static site generator. I won't plagiarize
their own documentation so if you want to know more, go read it. I'll wait.

...

Done reading it? Good.

So the whole tool is built around a CLI, and the main task provided by it is the
`build` task.

```bash
nix-shell -p zola --command "zola build"
```

Its job is to produce a comprehensive files tree in the `public/` directory,
with an index.html at root. Deploying this directory to a web server or reverse
proxy should do the trick.

You could for instance test it via python3's own little webserver:

```bash
nix-shell -p python38 --command \
  "python3 -m http.server --directory public/"
```

# The derivation wrapping it

```nix
{ pkgs ? import <nixpkgs> {}
, name ? "homepage-statically-generated"
, baseUrl ? "https://frederic.menou.me"
}:

let
  gitignoreSource = pkgs.callPackage ./gitignore.nix {};

in
  pkgs.stdenv.mkDerivation {
    inherit name;

    nativeBuildInputs = with pkgs; [
      zola
    ];

    src = gitignoreSource ./.;

    buildPhase = ''
      zola build -u ${baseUrl}
    '';

    installPhase = ''
      mkdir $out
      cp -r public/. $out/
    '';
  }
```

It's a pretty naive derivation:
- `buildPhase` calls zola
- `installPhase` copy the result in the derivation's result. The `public/.` is intended to copy hidden files too. (In my case the `.htaccess` file.)
- The mindful reader will have noticed the source tree used for this derivation is
  built via [`gitignoreSource`](https://github.com/hercules-ci/gitignore.nix). This
  helper strips files and directories ignored in git. This is handy when using the
  derivation from a working directory and make sure we don't rebuild every single
  time if a non relevant file is modified.

The `gitignoreSource` helper is provided the following fixed derivation:

```nix
{ fetchFromGitHub, lib }:

let
  gitignoreSrc = fetchFromGitHub {
    owner = "hercules-ci";
    repo = "gitignore.nix";
    rev = "a20de23b925fd8264fd7fad6454652e142fd7f73";
    sha256 =
      "sha256-8DFJjXG8zqoONA1vXtgeKXy68KdJL5UaXR8NtVMUbx8=";
  };
  inherit (import gitignoreSrc { inherit lib; })
    gitignoreSource;
in gitignoreSource
```

This produces a `result/` directory containing the result of `zola build`. Relaunching it will do nothing as sources havent changed.

The last step is to deploy it on your hosting provider.

# Deploying to Clever-Cloud

As I mentioned in the beginning, I use Clever-Cloud. It's probably not the cheaper option for this usecase, but in exchange of a fee I don't worry about system maintenance, uptime, and other boring stuff in that vein.

This is the step where you need to do some side effect via a git push. And this is where I fall back to a good ol' bash script.

_Reader is getting nervous._

First let's summarize the plan:

1. build it via nix
2. sync the result to the git clone
3. commit the changes
4. if something has been committed, push to the remote pointing at Clever-Cloud's deployment machine

The whole script looks like this:

```bash
#! /usr/bin/env nix-shell
# shellcheck shell=bash
#! nix-shell -i bash -p git

set -e

sourceRevision=$(git rev-parse --short HEAD)
nix-build

result="$(pwd)/result"
cd /path/to/git-clone

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
```

Some comments in no specific order:

- The script is launched in a nix-shell to make sure the dependencies are there (including git that you should have anyway).
- The sync process could probably be implemented via rsync, but I'm a simple man who has spent over a decade writing bash scripts.
- The script is pleasing shellcheck. The only pragma used here (line 2) is required because of the nix-shell shebang. The rest is clean.
- If no change detected, `git commit` will fail, so no useless deployment.

# Flakes

I know, I know, this is the future. I'm not used to it (yet).
