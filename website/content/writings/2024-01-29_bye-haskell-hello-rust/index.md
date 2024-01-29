+++
title = "Bye Haskell, hello Rust"
description = "After 8 years of being an Haskell advocate, it's time for me to reconsider my options."
date = 2024-01-29
[taxonomies]
media-types = ["blog"]
programming-languages = ["haskell", "rust"]
[extra]
tags = ["haskell", "rust", "english"]
+++

{{ banner(src="./haskellers-for-hire.jpg", alt="Photo of myself with a t-shirt saying: 'haskellers for hire!'", variant="compact") }}

## A bit of history

I've been curious of [Haskell] since 2014, looking for a type-safe and abstract language after a few years of [Ruby] at [Capitaine Train]. It was a bit of a challenge at first, the learning curve is very steap and that's something very well documented. But once it clicked, it was a breaze.

[Haskell]: https://www.haskell.org/
[Ruby]: https://www.ruby-lang.org/fr/
[Capitaine Train]: https://fr.wikipedia.org/wiki/Trainline_Europe

Then next challenge was: can I use it beyond the toy programs one can write when learning a new language, typically command-line tools. For instance: can I use it for my backend as a web developer?

The short answer is: yes, haskell is blessed with very strong libraries for the well, notably [servant] and [aeson], along with a fair share of lib for the web such as [amazonka] or [gogol] for IaaS integration, or database and message-queues drivers.

[servant]: https://hackage.haskell.org/package/servant
[aeson]: https://hackage.haskell.org/package/aeson
[amazonka]: https://hackage.haskell.org/package/amazonka
[gogol]: https://hackage.haskell.org/package/gogol

In 2016 I left Capitaine Train after the buyout by [Trainline] and I shortly thereafter joined [Fretlink]. The company was in its early stage with a MVP in [nodejs] and vanillajs and a huge roadmap before us. We started using Haskell for more services, notably a pricing service and a supplier directory. Both were present in the nodejs MVP but still very basic and lacking a large set of features.

[Trainline]: https://fr.wikipedia.org/wiki/Trainline
[Fretlink]: https://www.linkedin.com/company/fretlink/
[nodejs]: https://nodejs.org

This first "professional" use of Haskell was a bit of challenge but went very well, thanks notably to two recruits in 2017. We were 3 haskell developers, and willing to extend on this.

The rest is history as they say: the team grew up to 20 people all positions considered, and we had a large codebase. I don't have official statistics to share with you, but consider 10 repositories were active with 5 very active web services and quite a few libraries to support our systems. All of it was continuously deployed to [Clever Cloud] (for the haskell part) and some components elsewere ([AWS], [OVH], [Hetzner]).

[Clever Cloud]: https://www.clever-cloud.com/fr/home/
[AWS]: https://aws.amazon.com/
[OVH]: https://www.ovhcloud.com/
[Hetzner]: https://www.hetzner.com/

2021 and the first half of 2022 have been rough to us and the company [went down in june 2022](@/writings/2022-09-30_so-long-fretlink/index.md).

## And now what?

We are in the summer of 2022, I'm not feeling like getting busy right away, and I took that time to replenish the batteries. It was welcome.

But still, soon after I started looking for a new gig, willing to gather part of the team I left and enjoy the productivity and guarantees of a strongly typed and well equipped language. The experience of the last 6 years will for sure let me start on way saner basis than before.

If you look for haskell positions, you will most likely find a few things in financial institutions, some industries not hiring very actively, and the rest and majority: Blockchain projects.

{{
  meme(
    src="./buzz-woody-everywhere.jpg"
    alt="Buzz and Woody from Toys Story as a meme"
    top="Blockchain"
    bottom="Blockchain everywhere"
  )
}}

And that's a shame, especially when like me you don't want to work in this sector.

The market was dry. I was willing to start something with Haskell if it had to be on my terms and in a project where I got enough influence. This requires me to join early so that previous technical decisions couldn't refrain me from using it.

The harsh reality was:
- I had some projects willing to hire me _but_ the MVP was already there and rewriting it wasn't a sound decisions,
- I wasn't on the radar of projects creators (I'm working on it),
- such projects usually can't pay you decently.

As of 2024 this is still the case I'm afraid.

{% key_point() %}
**Obvious conclusion**

I can't expect to find a company willing to pay me a decent wage to use Haskell or Purescript on something I deem acceptable (ie not Blockchain mostly).
{% end %}

It took me all of 2023 to accept that.

## A Christmas Carol

Around Christmas 2023, I was a bit bored and took some time to read [the Rust Programming Language book](https://doc.rust-lang.org/book/).

I was aware of Rust since 2014 as [Tristram], a colleague of mine at [Capitaine Train], ~~used it for a routing engine~~ who was a strong advocate but had to use C++ at the time, and as [Clément], a as-of-then future colleague of mine, talked about it at ScalaIO 2015. And we had a optimization tool at [Fretlink] developed by [Axelle]. But I never did take the time to study it.

[Tristram]: https://mamot.fr/@tristramg
[Clément]: https://framapiaf.org/@clementd
[Axelle]: https://www.linkedin.com/in/axelle-piot-a987a0b8/

**Edit**: _Tristram [notified me](https://mamot.fr/@tristramg/111838910731745483) he did not use Rust for the routing engine and had to suffer using C++, Rust not being mature enough at the time._

I took [some notes](https://pouet.chapril.org/@ptitfred/111691245597831310) of my first steps. Some takeaways:
- the documentation is outstanding, notably the [getting started](https://doc.rust-lang.org/stable/book/),
- rust-analyzer (Language Server Protocol) is really capable, which is sweet,
- rustc is by itself a very strong tool and helping beginners (like I was),
- cargo is fast and capable (coming from the Haskell ecosystem, but even so comparing to npm).

### Do I miss Haskell?

**Yes**:
- the syntax is verbose _but_ the tooling is really helpful and appealing.
- effectful code everywhere and lack of purity is scary, but I have to confess it's convenient from time to time (hello mutability! I felt dirty when using it)

I find it amusing that Haskell is so strict regarding mutability and effects, and in the meantime rust is so strict for memory management. Both are willing to help the developers avoiding doing the same old mistakes. They just don't focus on the same thing.

### Is it still acceptable as a future language?

**Yes**:
- we have ADTs, we have Options, we have a strong and safe async framework. I'm ok onboarding juniors on such a language.
- tooling and libraries make it a general purpose language, so quite a safe choice when launching a project. wasm and embedded are 2 minor use cases of the language, so learning it can be fruitful for other usages
- rust is way more accepted as a general purpose language than Haskell (perceived as niche, hard to learn, hard to recruit for), making it a more consensuable choice and easy to push for future projects

{{
  banner(
    src="./Christmas_Island_Nat_Park_banner.jpg"
    alt="Red crabs crossing a road when migrating on the Christmas Island"
  )
}}

Time for me to migrate to rust?

## A matter of being employable

All of this looks good to me ; I can totally work on a complex project with a large team willing to work properly. So let's go right?

To be honest it was a pragmatic move at first.

{% key_point() %}
I love my job, and battling with nodejs and other ecosystems is not something I'm ok with on a daily basis.

Rust is not like this. I enjoyed the onboarding, working with it on a pet project, and I'm eager to start something bigger. [Wanna work with me?](https://www.funkythunks.dev/work-with-me)
{% end %}

As a bonus Rust is very well equipped to hack embedded systems (Raspberry, Arduino, and alike) with [embassy] and that's very appealing. I don't see myself being involved with it professionnaly, but it will be a nice pet project later this year for sure!

[embassy]: https://embassy.dev/

## Bye Haskell?

Well, not really I guess. I will miss servant for instance, and Purescript for the web.

If I was given the opportunity to use it again I will for sure.

{{ banner(src="./haskellers-for-hire.jpg", alt="Photo of myself with a t-shirt saying: 'haskellers for hire!'") }}

I'm still an Haskeller for hire :heart:,

Frédéric
