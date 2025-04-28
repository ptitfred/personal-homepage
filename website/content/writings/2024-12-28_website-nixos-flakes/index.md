+++
title = "Static website hosting with NixOS"
description = "From Apache to Nginx, from PaaS to self-hosted via NixOS, from nix derivation to flake."
date = 2024-12-28
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
- the server-side configuration is now a proper [NixOS module] maintained by the repository itself.

Let me comment those changes :smile:.

[Flake]: https://nixos.wiki/wiki/Flakes
[Nginx]: https://nginx.org
[NixOS]: https://nixos.org
[Zola]: https://getzola.org
[nix]: https://nixos.org
[NixOS module]: https://nixos.wiki/wiki/NixOS_modules

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

NixOS options are legion, and it's highly recommended you have a look at the search engine. For instance for nginx options, look for `services.nginx.*` [here](https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=alpha_asc&type=packages&query=services.nginx.*).

The bare minimum:
- `services.nginx.enable` to ensure nginx is configured and started (via systemd)
- `services.nginx.virtualHosts` to configure your ... virtual host, and there serve a website.

```nix
{ ... }:

{
  services.nginx.enable = true;
  services.nginx.virtualHosts = {
    "frederic.menou.me" = {
      locations."/" = {
        root = /path/to/web-pages; # can be a nix derivation!
        extraConfig = ''
          # NGinx configuration that is not natively supported by the options.
          # Typically rewrite directives for URL rewriting (alias, old URLs support).
        '';
      };
    };
  };
}
```

This let you configure and manage a NGinx server without struggling (too much) with systemd and nginx configuration.

Another benefit of nixos modules is the discoverability of configuration. Thanks to the hard work of many NixOS maintainers I've discovered features I didn't even expect and were never to look for in the NGinx manual. The same apply to postgresql and other gems of the open-source world.

Having your nginx configuration expressed in nix let you factorize out code, avoid repeating yourself, highlight important configuration bits, our delay the configuration choice by declaring your own NixOS options.

For instance the domain the webserver listens too is configured by a custom option:

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  # Use the options exposed by this module:
  cfg = config.services.ptitfred.personal-homepage;

  # pass the domain to the derivation building the web pages to hydrate the domain in links
  root = pkgs.callPackage ./website.nix { domain = cfg.domain; };

in
{
  options = {
    services.ptitfred.personal-homepage = {
      domain = mkOption  {
        type = types.str;
        description = ''
          CNAME to respond to to host the website.
        '';
      };
    };
  };

  config = {
    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      locations."/" = {
        inherit root;
      };
    };
  };
}
```

## Flakes are the way to go

{{
  meme(
    src="./mandalorian.png"
    variant="bright compact"
    alt="Picture of the Mandalorian from the Disney+ series, saying:"
    bottom="This is the way!"
  )
}}

What are [Flakes]? Except from the wiki:

> Nix flakes provide a standard way to write Nix expressions (and therefore packages) whose dependencies are version-pinned in a lock file, improving reproducibility of Nix installations. The experimental nix CLI lets you evaluate or build an expression contained within a flake, install a derivation from a flake into an User Environment, and operate on flake outputs much like the original nix-{build,eval,...} commands would.

Another definition closer to the [actual schema]:

> A function from inputs to outputs, with inputs being other flakes or raw nix derivations, to be used as dependencies, and outputs being either derivations (for applications or checks), nix expressions (for nixos modules, overlays, home-manager configuration) and _anything_ your project might build from the sources and the inputs.

Is it clear? I'm not sure. I'm sorry.

If you're new to Nix, I think you should know that Flakes are controversial in the ecosystem.

**Inexhaustive list of complaints:**
- Not fully designed in the open and RFCs, one might argue it's a corporate attempt to open-source an internal project without bringing on the community.
- Still marked as experimental (as 2024).
- Expects you to `git add` everything to make it work if you're working in a git repository.
- Almost impossible to use arguments from the command line.

**Some benefits though:**
- built in dependencies pinning and updates (no need to third party like [niv])
- cross-compilation is supported by default (even though one can totally ignore other architectures)
- composition of Flakes
- multiple outputs if you want to package applications, provide those applications in an overlay, package some system bits as NixOS modules, package the applications as home-manager modules. This let you provide a consistent experience without forcing people to use your own way. I will detail in an upcoming blog post how I package my set of utiliies in [posix-toolbox].

{% disclaimer() %}
In summary: I would argue flakes are better than raw nix expressions, especially for complex setups. But you might not approve of the constraints and find this too much of an hassle. Both ways are actually fine.<br/><br/>
Packaging your software with flakes make it convenient for people used to it. You know what to look for.<br/><br/>
_Your choice._
{% end %}

[Flakes]: https://nixos.wiki/wiki/Flakes
[actual schema]: https://nixos.wiki/wiki/Flakes#Flake_schema
[niv]: https://github.com/nmattia/niv
[posix-toolbox]: https://github.com/ptitfred/posix-toolbox

## NixOS module as a Flake output

A flake is a function of inputs (dependencies) to outputs (artifacts, such as an executable, some tests, or a nix-shell). The output is a big attributes set (like a hash, a dict, a Map depending on your favorite programming language). There is some convention, but it can be extended as you wish if you are reusing the flake as another flake input.

I have a dedicated flake responsible for my system and user-land configurations (both NixOS and home-manager). This is notably responsible for managing the server hosting the website you're currently reading. By the end of 2024, the nginx configuration bits specific to this website were mature enough for me to extract it as a module and upstream it to the website git repository itself. This minimizes the maintaince effort (less coupling implies less pull requests and synchronization) and also make it more self-contained: the flake output can be limited to the NixOS module itself and no longer expose the web pages or other utilities. Later refactorings are easier.

To give you a hint of the general outlook, the flake output looks like this as now December 2024:

```
$ nix flake show github:ptitfred/personal-homepage
github:ptitfred/personal-homepage/b517a6cea8c9cfe6cca993b0df3b33cdc744de29
├───apps
│   └───x86_64-linux
│       ├───check-links: app
│       ├───dev-server: app
│       ├───lint: app
│       └───tests: app
├───checks
│   └───x86_64-linux
│       └───lint-nix: derivation 'lint-nix'
├───devShells
│   └───x86_64-linux
│       └───default: development environment 'nix-shell'
├───nixosModules
│   └───default: NixOS module
├───packages
│   └───x86_64-linux
│       ├───check-screenshots: package 'check-screenshots'
│       ├───integration-tests: package 'vm-test-run-personal-homepage-hosting'
│       └───take-screenshots: package 'take-screenshots'
└───website: unknown
```

The `apps` are executable I use when working on the website, notably used in the Justfile:

```Justfile
lint:
  nix run .#lint

dev-server:
  nix run .#dev-server -- website

tests:
  nix run .#tests

integration-tests:
  nix build --print-build-logs .#integration-tests

check-links:
  nix run .#check-links -- website

check-metas:
  nix run .#check-screenshots https://frederic.menou.me
```

The `checks` are also executables (and can be executed like packages or apps) but are recognized by [Garnix] for my CI. The `integration-tests` package could be exposed as a check.

The `take-screenshots` package is a remainder of the previous setup where this binary was deployed on the server. It is now hidden in the NixOS module and could be stripped from the flake output.

The `nixosModules` is an attrset of NixOS modules. In my case I only package one single module. This is a common pattern in flake outputs, you can find something similar for [overlays]. This is the main output of this flake and this is what is used by the whole `personal-infrastructure` repository to actually deploy my website on a given server. This has been done in [personal-infrastructure#155](https://github.com/ptitfred/personal-infrastructure/pull/155). The main nix bits for that is to use the module as an import from the inputs:

The inputs are pointing to the website flake:

```nix
{
  inputs = {
    ptitfred-personal-homepage.url = "github:ptitfred/personal-homepage";
  };
  outputs = { self, ...}: ...;
}
```

The module is imported from the inputs and configured accordingly:

```nix
{ inputs, ... }:

{
  imports = [
    inputs.ptitfred-personal-homepage.nixosModules.default
  ];

  services.ptitfred.personal-homepage = {
    enable = true;
    domain = "frederic.menou.me";
    secure = true;
  };

  # Nginx
  services.nginx.enable = true;

  # Firefox HTTP/HTTPs
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Let's Encrypt
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "somebody+acme@somewhere.org";
}
```

[overlays]: https://nixos.wiki/wiki/Overlays

## Details under the hood

If you are brave enough to have a look at [nixos/website.nix](https://github.com/ptitfred/personal-homepage/blob/main/nixos/website.nix) you'll realise there's much more to it than what I described above. The main additions include:
- a background utility to take screenshots of the web pages to provide as thumbnail as metadata
- a background utility updating the content from the source to avoid updating everything when I publish an article
- extra configuration to support Brotli as compression algorithm
- support of alias domains (menou.me -> frederic.menou.me) for both http and https protocols
- nixos options for various bits, either for testing purposes or customization (some bits are hidden and not committed in public)

## Integration tests

Another part I haven't covered are tests: it's actually quite easy with NixOS to test in a VM (thanks to Qemu) your whole configuration, and making sure your server behaves properly.

In [tests/in-nginx.nix](https://github.com/ptitfred/personal-homepage/blob/main/tests/in-nginx.nix) is declared a NixOS test and a single VM. This let you demo the configuration in a simple setup:

```nix
{ httpie
, cores
, memorySize
, nixosTest
, nixosModule
, ptitfred
}:

nixosTest {
  name = "personal-homepage-hosting";
  nodes.machine = { ... }: {
    imports = [ nixosModule ];

    virtualisation = {
      inherit cores memorySize;
    };

    services.ptitfred.personal-homepage = {
      enable = true;
      domain = "long.test.localhost";
      aliases = [ "test.localhost" ];
      redirections = [
        { path = "/example";  target = "http://long.test.localhost/open-source"; }
        { path = "/example/"; target = "http://long.test.localhost/open-source"; }
      ];

      # Explicitly disable HTTPs as we can't have the ACME dance in the VM
      secure = false;
    };

    users.users.test_user = {
      isNormalUser = true;
      description = "Test User";
      password = "foobar";
      uid = 1000;
    };

    services.nginx.enable = true;

    environment.systemPackages = [ httpie ptitfred.check-screenshots ];

    # disable the timers in the VM
    systemd.timers.homepage-deployment.enable = false;
  };

  testScript = builtins.readFile ./integration-test.py;
}
```

The test case call a python script to assert various things. In [tests/integration-test.py](https://github.com/ptitfred/personal-homepage/blob/main/tests/integration-test.py) you'll find out how I check notable URLs are properly served, how redirections work as expected, and that the screenshoting utility works properly and thumbnail are indeed valid:

```python
machine.start()
machine.wait_for_unit("nginx.service")

with subtest("Check root setup before deployment"):
  machine.succeed("ls -l /var/lib/www/personal-homepage")

with subtest("Base files present"):
  machine.succeed("http --check-status http://long.test.localhost/index.html")
  machine.succeed("http --check-status http://long.test.localhost/sitemap.xml")
  machine.succeed("http --check-status http://long.test.localhost/robots.txt")
  machine.succeed("http --check-status http://long.test.localhost/rss.xml")

with subtest("Aliases"):
  machine.succeed("http --check-status --follow http://test.localhost")
  machine.succeed("http --check-status --follow http://test.localhost/index.html")

with subtest("Legacy URLs still there (by redirections)"):
  machine.succeed("http --check-status --follow http://long.test.localhost/about.html")
  machine.succeed("http --check-status --follow http://long.test.localhost/resume.html")
  machine.succeed("http --check-status --follow http://long.test.localhost/blog")
  machine.succeed("http --check-status --follow http://long.test.localhost/tutorials")

with subtest("Custom redirections"):
  machine.succeed("http --check-status --follow http://long.test.localhost/example")
  machine.succeed("http --check-status --follow http://long.test.localhost/example/")

with subtest("Screenshots"):
  machine.succeed("systemctl cat homepage-screenshots.service")
  machine.succeed("systemctl start homepage-screenshots.service")
  machine.succeed("check-screenshots http://long.test.localhost")
```

This is literally a wet-dream for testers.

This was a simple setup. You can provision multiple VMs and configure a VLan between them to test networking. Black magic.

* * *

Credits: [prince patel](https://unsplash.com/@princepatel).
