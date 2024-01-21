---
title: Nix flakes and Git submodules
date: 2024-01-21
description: Embedding a Hugo theme as a Git submodle within a Nix flake. Had better ideas in the past
image: images/headless-dog.jpg
imageAltAttribute: No-dogs-allowed-sign with the head of the pictogram dog being removed. High tides in the background with water splashing into a pool. Portuguese coast side
tags:
   - GitHubActions
   - Nix
   - flakes
   - Git
   - submodules
---

## Publishing a blog with Hugo would be easy they said

Okay, I'll do it with Nix then and learn something along the way in the worst case.

And oh boy, I was right.
I did learn things.
If they are the things one should learn or know about is a topic for another day, I guess.

Most of the Hugo howtos start with getting hugo and picking a theme.
A lot of them are offering to be cloned into your freshly started Hugo repo as a Git submodule.
This way one does not need to copy all the files in its own codebase and later on manually sync the worst-fork-you-can-do when the theme author decided to add something you'd also like and you notice a few thousands commits later. 

Great, did that and tried `nix build`.
And I was disappointed.
My carefully picked theme was not picked up in the sandbox.

A few issues later and a nice comment from Mister `edolstra` himself we got the impression that this situation can be handled by passing a parameter to the url we're trying to build:

```
nix build .?submodules=1
```

Great! Somehow cumbersome, but if you want, you can read it [some often referenced issue on GitHub](https://github.com/NixOS/nix/issues/4423) about the reasons why its handled that way.
To keep it short: Nix only fetched the main repository by default.
Imagine some growing submodule nuking your build process.

Okay, great with that knowledge, let's push a GitHub Action to the repo and see if GitHub can build it.
At least it works on my machine, I'm using Nix, what can possibly go wrong, right?
Turns out: Some.

The default behaviour for the `checkout` action is a shallow checkout without submodules.
Okay, we can tweak that with some options like `fetch-depth: 0` and `subdmodules: true`.

But the Nix build still does not pick up the submodule.
Why is that?

Turns out that the checkout action does some Git config dance for each submodule individually.
I guess there are some good reasons, but it differs a lot from my local dev environment where there is basically one Git config for the repo including the submodule.

Okay, we now know and learned a lot about GitHubs checkout action and it's inner workings, but what can we do?
Built our own Checkout?
`nix run nixpkgs#git` to the rescue?

Let's assume we're in the GitHub runner and have happily checked out the repo and its submodules.
There is some state on disk that reassembles our wish of the file system at build time.
We can now tweak the nix build command in the following way:

```
nix build "git+file://$(pwd)?submodules=1"
```

Yep, we hacked our way through this.
The `"git+file://$(pwd)"` is our main achievement here, we're not fetching anything from the outside but are consuming the local git repository in its state being the current working directory without fetching and dealing with auth, configs or other shenanigans.

The GitHub Action now produces fully rendered version of the Hugo site.
Like I expected.
You can follow the turn of events if you look at the [pages.yml in the repo](https://github.com/robsliwi/robsliwi.github.io/blob/995a706bdf1b84a42b558dc7672dcea50a86acdb/.github/workflows/pages.yml).
