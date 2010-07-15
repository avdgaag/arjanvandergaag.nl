---
layout: post
title: Introducing μtil
published: true
keywords: javascript, library, μtil, jquery, dom
description: In which I describe my new tiny javascript library called μtil.
categories:
  - code
  - javascript
---
Lately in my web development work I find myself needing some simple JavaScript tools. Usually I bring out jQuery, but sometimes it just doesn't feel right to load an entire library in order to show and hide some elements.

That is why I recently started developing a tiny JavaScript toolkit of my own, called μtil (mu-til). It's purpose is to make basic DOM operations a little easier without taking on too much bloat. You can find the [μtil at Github][].

## Why a new library?

There's more than enough JavaScript libraries out there, but here's why I wrote one:

* it's a great way to learn JavaScript.
* it's nice to have a pet project
* I wanted something specific that other libraries did not provide
* It's good to really know the tools you use

I'll still be using bigger frameworks of course, but on some cases μtil will suffice and I will enjoy creating a as-lean-as-possible website.

## Concepts

μtil only does a couple of things, all of which I have stolen from the big guys:

* Simple element selection
* Adding event observers
* Working with class names
* Adding various core extensions to String and Array
* Extensions to quickly add features on a per project basis.
* a really simple build script to concatenate and minify the μtil core and required plugins.
* a packager, to quickly generate a minified library file to include in a project.

μtil doesn't do Ajax or effects. If I need that I'm much better off with jQuery. Most of the features are extensions on the core library, and it's nice and easy to add more.

## Usage

Here's a quick code sample from the project README to show off:

{% highlight javascript %}
// on page load
$(function() {

  // Select all links in the content leader
  $('#content p.leader a')

    // observe the click event
    .addEvent('click', function(e) {

      // stop event propagation and prevent default link behaviour
      e.stop();

      // Set a nice background color on its parent
      $(this.parentNode).setCss({ background: '#ffffe1' });
  });
});
{% endhighlight %}

And here's using the packager from the command line to generate a minified library file of the μtil core and some plugins:

    $./bin/mutil hover classes

This will generate a `mutil.min.js` file that includes the core library and the `hover` and `classes` plugins. Easy!

## Experience

Writing a little library is great fun, as you get to explore practical needs, writing documentation, code optimization and crazy JavaScript quirks. I've learned a lot from writing μtil, and even if I will never use it in a production environment it was time well spent.

## Dive in

You can find the code for [μtil at github][], along with documentation and an issue tracker. Please do fork and hack away!


[μtil at Github]: http://github.com/avdgaag/mutil