# authored

A modular framework for building authoring tools.

Originally developed for [Adivix](https://github.com/Adivix), but usable for any kind of (2D) authoring tool project.

## Demo

[Here.](http://cryto.net/~joepie91/authored-test/test/test.html) No performance optimizations carried out yet, and very rough around the edges still, so Chrome is probably a better choice.

## Current state

__Not__ production-ready. Still under development. The plugins will eventually be put into their own repository.

## Plugins

* Core (stage, scenes, objects - not actually a plugin)
* Layers
* Object type - text
* Object type - image

## UI plugins

* Scene panel
* Layer panel
* Object panel
* Properties panel
* HTML renderer

## Utilities

* `dom-wait`; queues a function call for when the DOM has loaded, where necessary.
* `apply-property-map`; utility for mapping values to DOM element properties.
* `split-filter`; like `.filter`, but returns both a matching and non-matching array.
* `distance-from`; calculates direct distance between two points, used for the drag threshold in the HTML renderer.

