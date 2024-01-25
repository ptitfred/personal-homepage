+++
title = "Static website hosting with NixOS"
description = "From Apache to Nginx, from PaaS to self-hosted via NixOS, from nix derivation to flake."
date = 2024-01-26
[taxonomies]
media-types = ["blog"]
programming-languages = ["nix"]
[extra]
tags = ["nix", "sys-admin", "english"]
+++

{{
  banner(
    src="./snow-flakes-prince-patel.jpg"
    alt="A photo of snow flakes on some vegetation, credits prince patel."
    title="Credits prince patel"
    variant="compact bright"
  )
}}

## _Previously, on frederic.menou.me_

In [this previous post](@/writings/2022-10-03_nix-derivation-website.md), I've tried explaining how this whole website is managed.

It's basically using [Zola] and packaged as a [nix] derivation, deployed on a [NixOS] VPS.

A few things have changed, notably:
- this is no more deployed to a PaaS, and instead is deployed on a VPS I'm managing and served by [Nginx].
- the nix derivation is now packaged in a [Flake].

Let me comment those changes :smile:.

[Flake]: https://nixos.wiki/wiki/Flakes
[Nginx]: https://nginx.org
[NixOS]: https://nixos.org
[Zola]: https://getzola.org
[nix]: https://nixos.org

## Self hosting to be free

For economic reasons, I moved away from [Clever-Cloud] and picked a small VPS at [Gandi]. At this time I had migrated my laptop and some VMs to NixOS. Having gained quite some experience with it and it's module system, I was confident enough to use it on a live server. Before doing it on a critical key of a larger infrastructure, it was therefore quite natural to do it for my personal static website.

Having a full fledge VPS is only handy to deploy custom small tools such as bots for automation, something I couldn't do with my previous hosting.

A static website is very easy to serve on the web. Apache or nginx are two easy and very well documented options. I prefer the later but that's not the point of this article and I won't try convincing you :grimacing:.

If you want to get started I suggest you read [Serving Static Content](https://docs.nginx.com/nginx/admin-guide/web-server/serving-static-content/).

If you want to "nixify" the example, you would have to generate the main configuration file to adjust the `root` attribute.

```nix
# File package.nix
{ stdenv, zola, src
}:

stdenv.mkDerivation {
  inherit src;
  name = "homepage-statically-generated";

  nativeBuildInputs = [ zola ];

  buildPhase = ''
    zola build -u ${baseUrl}
  '';

  installPhase = ''
    mkdir $out
    cp -r public/. $out/
  '';
}
```

```nix
{ pkgs ? import <nixpkgs> {}
, ...
}:

let gitignoreSource = pkgs.callPackage ./gitignore.nix {};
    nginx-configuration = root-directory: ''
      server {
        root ${root-directory};
        location / {
        }
      }
   '';
   my-website = pkgs.callPackage ./package.nix {
     baseUrl = "https://frederic.menou.me";
     src = gitignoreSource ./.;
   };
in nginx-configuration my-website
```

with such a derivation, you obtain a string that you could use as a `nginx.conf` file. But you still have to deploy nginx, manage it (make it a service, resist reboots, configure https). It is a bit of work actually.

Your favorite distribution has a nginx package capable of doing so. And assuming you're at ease with the `nginx.conf` file and its specifics you're good to go!

Personnally I'd rather a higher level of abstraction and declare what I want from my server. In this case I need:
- a static server which root is the output of my zola setup
- with https via let's encrypt and certificates renewal
- bound to the system so that it's up after a reboot
- with modern feature such as compression

You might be surprised by configuration nginx via NixOS is actually that concise.

## NixOS to the rescue

NixOS is a Linux distribution based on Nix (the language) and Nixpkgs (the package manager). It's declarative and the collection modules is as impressive as nixpkgs is large.

It can be hard to navigate.

It's also a distribution that doesn't follow the FHS, the [Filesystem Hierarchy Standard](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard). This makes it quite unpopular for many seasoned sysadmins, but there is a good reason.

By avoiding the FHS and using the `/nix/store` to store all binaries and configurations, a NixOS system has no issue maintaining different revision of a given binary or library. You don't suffer the system-wide OpenSSL version, and you can upgrade packages on a more granular basis. For configuration, you will still find the `/etc` directory but it's actually a symbolic link to an entry in the nix store: your system configuration is versioned for free, making rollbacks very easy.

The whole system is versioned by its boot sequence, and the boot loader lets you pick the revision you want. A system upgrade is almost risk free as you can rollback via the boot screens.

Obviously this doesn't cover the data of your system. You still are responsible for the well being of all services. Backups are still required and considered a good practice.

Another perks of NixOS if for auditability: you can review the changes of the nix configuration to audit the changes of your system. You should probably do this _before_ applying it of course, but that's no news for all of you already using terraform and/or ansible.

Note that usually people don't use DevOps tools to manage a workstation, and for those systems, NixOS offers you something you probably didn't have.

{% disclaimer() %}
In my 20 years of Linux usage, I only covered a subset of the myriad of distributions available. So you might have something similar elsewhere that I'm not aware of.
{% end %}

_Etiam venenatis vel augue sed hendrerit. Nulla varius ultricies congue. Pellentesque in mi eget arcu tempus laoreet. Proin mattis risus eget neque vehicula ullamcorper. In urna diam, tempus a sagittis ac, ultrices in neque. Aenean lacinia ante odio, ac tempus mauris egestas vel. Maecenas rutrum pretium metus sed cursus. Donec eu convallis arcu. Sed lectus felis, viverra id viverra vel, commodo in nibh. Fusce tempor condimentum augue ut finibus. Nullam viverra quis ex non consectetur. Fusce sit amet ligula sed quam maximus vestibulum quis eget velit._

## Flakes are the way to go

{{
  meme(
    src="./mandalorian.png"
    variant="bright compact"
    alt="Picture of the Mandalorian from the Disney+ series, saying:"
    bottom="This is the way!"
  )
}}

_Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Aenean sagittis facilisis massa sit amet congue. Aliquam tortor elit, dictum ac mollis a, gravida ut justo. Nullam risus magna, bibendum eu fringilla vel, dictum et risus. Mauris ut dignissim magna, eget vestibulum erat. Mauris facilisis ipsum ut nunc dapibus, a bibendum eros tristique. Proin finibus, leo vel lobortis dapibus, augue neque pulvinar orci, non maximus lacus dui vitae sem. Nunc sit amet massa ultricies, lobortis risus eu, faucibus ex._

* * *

Credits: [prince patel](https://unsplash.com/@princepatel).
