+++
title = "Retrospective 2023"
description = "A look back on 2023"
date = 2024-01-19
[taxonomies]
media-types = ["blog"]
[extra]
tags = ["english"]
+++

I pouet'ed twice while on end-of-year holidays about this past year, as it's the custom it seams:

{{ pouet(url="https://pouet.chapril.org/@ptitfred/111680964384649187") }}

{{ pouet(url="https://pouet.chapril.org/@ptitfred/111682108611942901") }}

It's quite short and it doesn't elaborate on up and downs, and reasons and contexts. I took some time to give you some details.

## A strange year

2023 has been strange. Mid 2022 my employer Fretlink turned off the lights and as others I was considering my options, trying to fill the battery back after 6 years of consistent effort and not much room to breathe.

After a few months I've started as CTO and first developer at a French consulting agency named Software Club. It didn't last long and for the first time of my career I decided to cut the trial period. It was a mismatch, the reasons don't matter.

Anyway it was a bit rough to swallow and we're now in February of 2023. Figure me standing in front of my (personal) computer with many questions and not so many convictions.

## Freelancing?

After a breakup you change your hair, right? I chose to start my freelancing company.

The idea was to start working for entrepreneurs trying to bootstrap a product. It wasn't very effective. I guess I have to improve my sales game.

It also gave me some free time to experiment and learn few things. I also planned on contribute to open source projects but this wasn't successful. Maybe in 2024?

Financially: not so great so far, but being independant and free to work of various topics is delightful. No regrets!

* * *

Enough of my rumbling, let's detail the 2 pouets:

## nix flakes for everything

I use nix extensively, for my laptop and my personal hosting (NixOS), for dev tools (home-manager and nix-shell), and for my CI (standard nix-build until then).

This past year I took the time to finally learn and exploit flakes. I did it for my systems (NixOS and home-manager support it natively), and for the software projects I maintain (which is not so many actually).

The main take away for me is the following:
- dependency management is way easier, at least when you manually pulled deps via [`fetchFromGithub`](https://ryantm.github.io/nixpkgs/builders/fetchers/) or equivalent. I used [niv] for the larger ones and yet it's more convenient.
- composition and reuse is easier. For instance my oldest open-source project [posix-toolbox] is a collection of scripts I used on my workstation for the last 15 years and now this project is [a flake exposing an overlay](https://github.com/ptitfred/posix-toolbox/commit/63fedf493b190f7eb90350292bceb79c1daffcea#diff-206b9ce276ab5971a2489d75eb1b12999d4bf3843b7988cbe8d687cfde61dea0). When deployment locally via home-manager I have [posix-toolbox as an input](https://github.com/ptitfred/home-manager/commit/fb2a7481fb7e9aec74f1d6c7822114c8053790ed#diff-206b9ce276ab5971a2489d75eb1b12999d4bf3843b7988cbe8d687cfde61dea0), and its overlay is simply passed to the nixpkgs I use for my user space. It's a trivial example but it's still an improvement as I don't have to remember all the details when pulling it. If I need to override it downstream I can override the input of an input [as explained in the Nix manual](https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake.html#flake-inputs).
- the overall structure of a flake is a bit clumsy and there's an overhead. The nix expression can be more complex and intimidating for the newcomer, especially having to deal with target systems. Also documentation can be very light some times. Nothing new for a Nix related project though...

I've learned a lot via Xe Iaso's blog. It clicked where the official documentation failed to enlight me.

Must read notably include:
- [Nix Flakes: an Introduction] by Xe Iaso
- [Nix Flakes: Packages and How to Use Them] by Xe
- [Nix Flakes: Exposing and using NixOS Modules] by Xe
- [Incrementally package a Haskell program using Nix] by Gabriella Gonzalez ; this one is about packaging an haskell program but it ends with the use of flakes and notably the overlay for custom dependencies. It was very insightful to me.

[posix-toolbox]: https://github.com/ptitfred/posix-toolbox
[niv]: https://github.com/nmattia/niv
[Nix Flakes: an Introduction]: https://xeiaso.net/blog/nix-flakes-1-2022-02-21/
[Nix Flakes: Packages and How to Use Them]: https://xeiaso.net/blog/nix-flakes-2-2022-02-27/
[Nix Flakes: Exposing and using NixOS Modules]: https://xeiaso.net/blog/nix-flakes-3-2022-04-07/
[Incrementally package a Haskell program using Nix]: https://www.haskellforall.com/2022/08/incrementally-package-haskell-program.html

## Haskell: bye bye stack, hello cabal and nixpkgs

Speaking of Gabriella's blogpost, I totally ditched [stack] for haskell development and move to cabal via nix.

[Incrementally package a Haskell program using Nix] is 98% what I do today, so I won't paraphrase her work. Go read it instead!

Pros:
+ my haskell builds are properly supported by nixpkgs (and my CI)
+ I don't fear patching a dependency, especially when indirect dependencies are moving

Cons:
- I'm not sure it's sustainable if you don't move along with the nixpkgs branch you're following.
- Same question regarding GHC's version.

I didn't take the time to assess the situation. And to be honest I don't think I ever will as I'm slowly moving to Rust as my goto language. (More on this later I promise.)

## NixOS deployment with colmena

After switching my laptop to NixOS in 2022, I tried using NixOS on a VPS. I did it with 2 VPS at 2 French hosting providers: Gandi and OVH. Gandi support NixOS directly, while for OVH you have to infect it. It's quite straightforward.

I then looked how to manager those machine and centralized the deployment my services and the system updates. I first used [morph]. As I was migrating to flakes (espically system wide for my workstations), I was willing to do so with my servers. Unfortunately [morph doesn't support it yet](https://github.com/DBCDK/morph/issues/124) and it looks like it's not going to change. So I move to [colmena](https://colmena.cli.rs/unstable/). Its features and CLI is pretty close to morph's so the migration was pretty straightforward. I had very things to change to make it work. If you're curious, here is [the PR with most changes](https://github.com/ptitfred/personal-infrastructure/pull/45).

Secrets management was where I had most of the work. I switched to [sops] and [age]. The repository is private for obvious reasons.

[morph]: https://github.com/DBCDK/morph
[sops]: https://github.com/getsops/sops/
[age]: https://github.com/FiloSottile/age

## Garnix for my CI

Having migrated my projects to flakes also let me used a CI tool called [Garnix].

Garnix has this (unique?) feature: it reuses the same nix store for your various builds, making CI **REALLY** fast when few things change. I routinely have pull requests ready to merge under 20 seconds, with the setup phase being the longer (garnix has to assess the work first by evaluating the flake/derivation first).

![An example of a Haskell project with a NixOS module and a NixOS virtual machine for integration testing](./garnix-example-checks-haskell.png)

One might argue you have such a feature with caches but if you ever had to maintain a CI configuration, you _know_ how tricky it can be, how painful cache invalidation can be, and that it's usually very specific to every framework or buid toolchain. **Here the caching is by design** (thanks nix) and generalized to the whole tree of dependencies, including the system ones.

Another neat feature: the nix store is available as a nix cache (like the standard cache.nixos.org) and therefore you can locally reuse derivations outputs without having to build them, for instance if a colleague of yours already did some work or bumped some dependencies. [More details here](https://garnix.io/docs/caching).

This is something I dreamed of for quite some time and I was eager to have at feu Fretlink. Some of my former colleagues could testify :-)

Garnix is a private non open-source initiative, so it can be a no-go for you. I don't care much, I've been a user of Travis long time ago, and more recently Github Actions. But they are close to the nix ecosystem and did [explain how it works in this article](https://garnix.io/docs/steps). I guess one could clone it.

[Garnix]: https://garnix.io/

## Bye bye Make, hello just

I've been using make for the past 10 years to easily start task in a given development project. The main benefit of make (for me) was the completion support out-of-box so quite easy to have standard development tasks as shortcuts. For instance I typically had: `make build`, `make clean`, `make lint` or `make test`.

I'm a hardcore git-rebase user, especially interactive rebase. It's mostly for history rewriting but it's also interesting to launch some task on some git commit of your history with the `exec` action. Having a short command to pass to those actions is quite helpful.

![Example use of the exec action in git-rebase --interactive](git-rebase-interactive-exec.png)

But Makefiles are a bit rough on the edges, and using it this way is clearly a hack. This past year I've started migrating to [Just].

I typically have the same tasks, in a file with an another but with a syntax so close (for trivial cases) that usually I just have to `git mv Makefile justfile`.

Two quick nuggets: [passing arguments](https://just.systems/man/en/chapter_38.html) and [self documentation](https://just.systems/man/en/chapter_24.html). But there's more and should give it a try!

For example, [here](https://github.com/ptitfred/personal-homepage/blob/main/justfile) is the justfile for the source of this website:

```Just
lint:
  nix run .#lint

dev-server:
  nix run .#dev-server -- website

local:
  nix run .#local

tests:
  nix run .#tests
```

[Just]: https://just.systems/man/en/

## Hurl for API testing

[Hurl] is a "command line tool that runs HTTP requests defined in a simple plain text format". This sounds like [httpie] but it's more than that. It can chain requests, interpret the body of responses, and support the classic HTTP feature you might encounter as a developer.

I uses it for automatic testing in my CI.

Example of a intricate scenario, testing the login feature of a web service, chaining requests and reusing results to query the next endpoint:

```hurl
GET http://{{web_root}}/login.html
HTTP 200

POST http://{{api_root}}/login
[FormParams]
email:    some_user@localhost
password: some_password
HTTP 403
[Asserts]
jsonpath "$.message" == "Login failed."

POST http://{{api_root}}/login
[FormParams]
email:    frederic.menou@gmail.com
password: invalid_password
HTTP 403
[Asserts]
jsonpath "$.message" == "Login failed."

POST http://{{api_root}}/login
[FormParams]
email:    frederic.menou@gmail.com
password: valid_password
HTTP 200
[Captures]
token: jsonpath "$.token"

GET http://{{api_root}}/user/me
HTTP 401
[Asserts]
jsonpath "$.message" == "Missing Authorization header"

GET http://{{api_root}}/user/me
Authorization: Bearer EmwKAhgDEiQIABIgLdtqyHvCfwe21K-jwm0VR-rDnNL0aoit0ljjXhikywUaQP_y5Hzsklr8go6fdy5IxaS6TIvmLfEl7P7ca3deYCmzRQs71fcLxm0lq0sbS90tgKJbK4paES6nU-G5WkEi2gIiIgogARBiwlwArFQfNdeWRAqUZdwskNP15oVWPDBhmWWrSvo=
HTTP 401
[Asserts]
jsonpath "$.message" == "Error parsing the token."

GET http://{{api_root}}/user/me
Authorization: Bearer {{token}}
HTTP 200
[Asserts]
jsonpath "$.email"    == "frederic.menou@gmail.com"
jsonpath "$.fullname" == "Frédéric Menou"
```

_(Unfortunately [Zola] doesn't highlight hurl files yet. Zola uses sublime text syntax files and I couldn't find any at the time of writing this post.)_

I'm not sure Hurl changed my life, but it's been a big "WOW" of 2023.

[Hurl]: https://hurl.dev/
[Zola]: https://www.getzola.org/

## The pipes library is amazing

I won't explain [pipes] here, others I've done it better. For instance:
- The official tutorial: [`Pipes.Tutorial`](https://hackage.haskell.org/package/pipes-4.3.16/docs/Pipes-Tutorial.html)
- [Intro to pipes by Oliver Charles](https://www.youtube.com/watch?v=2jdJGdA7AYs), London Haskell user group, 18th September 2013

I had to use it to stream some scrapping and database queries in a webscraper. It was a mess and performance was disastrous until I use pipes. I know it sounds too good to be true, but still. Unfortunately this code is closed source.

[pipes]: https://hackage.haskell.org/package/pipes

## A Purescript binding of a popular React components library

At Fretlink we used [Purescript] for our frontend codebase. It's a cousin to Haskell, sharing most of the syntax and features. It's compiling to javascript, not machine code. It's then very easy to interop with javascript libraries.

I also used [mantine] for some personal or professional projects, and I felt the urge to use mantine from Purescript code. It lead to [purescript-mantine]. I'm not sure this project got any future as it's quite a lot of work to maintain those bindings (it's all manual work unfortunately).

But I learned a lot regarding Purescript internals. For instance I had to routinely "convert" from typical Purescript datatypes (closed sum types to make it very hard for the user to misuse the library) to javascript datatypes (strings, numbers, "object"s, arrays, badly typed effects) and this lead to the [`Mantine.FFI` module](https://github.com/funky-thunks/purescript-mantine/blob/main/src/Mantine/FFI.purs).

In this module I had to write conversion functions for an extensive set of pairs of types. For most of them it's trivial (identity function, or fmap to the generic type). For others it's a bit trickier (effects are curried and therefore need a bit of plumbing). And the really hairy part is about Records for which you need to dive into [`RowToList`](https://pursuit.purescript.org/builtins/docs/Prim.RowList). The official documentation is pretty unhelpful and I had to piggyback on old [blogpost](https://liamgoodacre.github.io/purescript/rows/records/2017/07/10/purescript-row-to-list.html)s or [gist](https://gist.github.com/i-am-tom/355987ba2b972d4da16635626b27f42e)s and fight with the compiler until [success](https://github.com/funky-thunks/purescript-mantine/commit/9ba12f79aff53ff36bf10be7e98e9350ba5aa3bc#diff-945c6508eb5695eb9ce50c47df90e2479cf0c9c20c8ae4d6962ea098d8e0a97aR65-R98)!

Let's say that all of this was mostly to hide the dirty details of Javascript (null and undefined, erk) and JSX (everything is automagic and properties are optionals, erk). Maybe I should stop worrying and just right dumb and buggy javascript for my SPAs :/

[Purescript]: https://www.purescript.org/
[mantine]: https://mantine.dev
[purescript-mantine]: https://github.com/funky-thunks/purescript-mantine

* * *

This post is still a bit rough. I might get into more details for some of it later.

_Maybe_

Bye, Frédéric
