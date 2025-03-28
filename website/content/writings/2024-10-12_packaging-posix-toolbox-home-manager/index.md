+++
title = "home-manager module for my scripts collection"
description = ""
date = 2024-10-12
[taxonomies]
media-types = ["blog"]
programming-languages = ["nix"]
[extra]
tags = ["nix", "english"]
+++

A short tale of why and how I ended up with this mix of bash and nix [in this repository](https://github.com/ptitfred/posix-toolbox).

It's a 15 years journey with major phases as I made my workstation's setup evolve.

Today I'll talk how I package and install a collection of scripts I've written over the last 15 years, to use them in a laptop, a set of (remote) servers and a virtual machine. One might think it's overengineered and I won't argue. There's a logic in my madness (I'm sure).

{% figure(src="./cortex-madness.jpg", alt="Brain (called Cortex in France) from Pinky and the Brain (Minus et Cortex in France)") %}
Brain (called Cortex in France) from Pinky and the Brain (Minus et Cortex in France)
{% end %}

## A bit of history

On my first job back in 2007 we were only provided with Windows machines. It last until I joined [Capitaine Train](https://medium.com/@ptitfred/diaspora-cc1addb9182b) in 2012 where I was offered _a choice_. I chose a Linux of course. But until then I had to meddle with [cygwin](https://www.cygwin.com/), and it wasn't really pleasant.

At first it was a messy collection of scripts, utilities for git and android (yeah back in the days I was messing around with android apps).

I also had a PS1 forked from some git tutorials I've long forgotten, and some scripts were added to support it. This PS1 [still exists to this day](https://github.com/ptitfred/posix-toolbox/blob/main/src/git-ps1/git-ps1.sh). It looks like this:

{% figure(src="ps1.png", alt="Screenshot of git-ps1 in action") %}
git-ps1 when working on this article
{% end %}

I've been asked this PS1 on various occasions, mostly when showing my terminal at conferences or brown bag lunches. This solely explains why the repository has been starred more than once :grin:.

By the end of 2010 other scripts related to another job were added in an unordely fashion.

In June 2012 I've added the [wait-tcp script](https://github.com/ptitfred/posix-toolbox/blob/main/src/wait-tcp/wait-tcp.sh) to help usage of TCP servers in scripts, mostly for testing purposes. This script blocks until a process is listening to a given TCP port. Typically useful if you want to run some tests on a HTTP server and you first have to boot it.

In October 2013, I came up with [git-checkout-log](https://github.com/ptitfred/posix-toolbox/blob/main/src/git-checkout-log/git-checkout-log.sh) which helps navigates git-reflog for checkout actions and let you come back to a previously checked out branch. I use it intensively since then as I'm use to juggle between branches when dealing with pull requests for instance.

{% figure(src="git-checkout-log.png", alt="Screenshot of git-checkout-log in action") %}
git checkout-log when working on this article
{% end %}

On August 2014, my [SO](https://celine.louvet.me/) [contributed to the wait-tcp script](https://github.com/ptitfred/posix-toolbox/commit/fb2b2194a3df912c78f6a7e7e038d96f1439dfc4) to make it work on MacOS. I _guess_ it's still working fine on Mac but I never had (and never will probably) use a Macintosh so I can't assess it's still working fine.

Over the span of 2014 I also started working on [git-bubbles](https://github.com/ptitfred/posix-toolbox/blob/main/src/git-bubbles/git-bubbles.sh), a script designed to freely work on pull requests and make interactive rebases and the upcoming forced pushes safer. I've rely very heavily on this script to this day and couldn't work without it.

{% figure(src="git-bubbles.png", alt="Screenshot of git-bubbles in action") %}
Example usage of git-bubbles on this very article
{% end %}

Since then I've only done maintenance, applying [shellcheck](https://www.shellcheck.net/) advices and packaging it with Nix. Shellcheck is amazing and I strongly advice using it if you write any bash scripts, no matter you're level of expertise. Bash is a tricky language and it's very easy to write faulty code.

I use those scripts since then and I'm maintening those from time to time. They are now packaged with Nix [as the Readme now highlights](https://github.com/ptitfred/posix-toolbox?tab=readme-ov-file#how-to-install).

## My journey with Nix

My first experiments with Nix were around 2015/2016, when I was looking for a distribution to setup a laptop. For some reason I ended up on the nixos website, not realizing the full extend of it. And it was a very very poor first encounter :grin:.

But I later gave it a second try as an utility installer with [nix-env](https://nixos.org/guides/nix-pills/03-enter-environment). I was pissed with Debian being behind on so many things and having you adding third-party repository for any single cool stuff.

Later on I learned you can do more elaborate stuff, notably fixing dependencies for a given context, let's say a software project, without relying on the system at all. After 4 years of Ruby and OpenSSL madness, it was a fresh breeeze!

At the same time we were using Haskell at Fretlink, and there is a strong relationship between Nix and Haskell, both being functional programming languages, and a fare share of notable Nix contributors were also Haskell developers. I've learned a lot thanks to [Gabriella Gonzalez](https://www.haskellforall.com/) for instance.

I've then moved from Debian to NixOS, and right after started using [home-manager](https://nix-community.github.io/home-manager/).

## Whole system configuration as code

In January 2021, I started [git committing my home-manager configuration](https://github.com/ptitfred/home-manager), notably to share my setup between a laptop and a virtual machine. home-manager in a nutshell is there to generate your configuration files ($HOME/.config and alikes) and manage your path (like nix-env did).

And in October 2022 [personal-infrastructure repository](https://github.com/ptitfred/personal-infrastructure) followed, where I would commit my system configuration.

Thanks to nix you can:
- make it consistent across configuration, for instance by sharing a color scheme across various programs
- factorize out repetitive bits by writing functions
- make some things configurable, for instance my virtual machine doesn't display the battery in the toolbar
- group in a single nix file configuration and runtime dependencies that are related, for instance sourcing some bash configuration and provide the executables linked to this. This helps maintenance (easy to drop things later on), it's shareable with others, it's easy to debug or temporaraly disable.

## posix-toolbox in my home-manager configuration

At first I've added my posix-toolbox repository via an [overlay](https://github.com/ptitfred/home-manager/commit/451e786e0c349a6c63f4ba2221482e5646083eae#diff-e01d02fd85aae3c6374a3d9889ba6772caca0f64cc7cc8970d185ef30916e712) in my PATH, and the configuration bits were committed in [home-manager](https://github.com/ptitfred/home-manager/commit/451e786e0c349a6c63f4ba2221482e5646083eae#diff-31229fa992b403d35ed9d8652247285873be74fb3210d541767d0cf74a231371). The whole setup was concise and not so fancy, everything in a single nix expression.

After an large set of pull requests adding more and more to my home-manager configuration, I [moved to flakes](https://github.com/ptitfred/home-manager/pull/22) in July 2023. Flakes handle dependencies and provide some convention on the outputs a project can provide. home-manager itself support flakes and expects some profiles under the `homeConfigurations` attribute. You can have many profiles, notably if you share it across various setups.

`posix-toolbox` is then my longest lasting projects, and I've updating it inner workings many times. The usage of Nix as its building and packaging tooling was the last main stage.

When moving to flakes, the outputs consisted of an overlay with all the scripts, and the packages attributes so that one could use it with `nix run` or `nix shell` or `nix profile` to install it. I don't expect others to use it this way. I don't advertise this repository of scripts that much (expect in this article I suppose). So the whole setup is still pretty personal. But I like the idea of a project to be also packaged properly for others to use if they wanted to. Be my guest!

Over the last week I've done my fair share of maintenance and refactoring on both `personal-infrastructure` and `home-manager`, with the most notable being the [merge of both in personal-infrastructure](https://github.com/ptitfred/personal-infrastructure/pull/93). This big change was very smooth actually, with mainly only the flake.nix to handle merge conflicts with. It's not that common for configuration to be refactorable (is that a word?). Note also the nix provides some testing capabilities, and I was covered for the most tricky parts.

Following that momentum, yesterday [I extracted the configuration bits of posix-toolbox](https://github.com/ptitfred/posix-toolbox/pull/37) and moved them closer to the scripts, and added a home-manager module to the outputs of it. And made it consistent with the documentation, and easier to maintain. I no longer worry about it when patching the rest of my configuration. And if you wanted to use it yourself, feel free to [follow those instructions](https://github.com/ptitfred/posix-toolbox?tab=readme-ov-file#install-via-home-manager-as-a-module).
