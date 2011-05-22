---
title: The nanoc-cachebuster Gem
kind: article
created_at: 2011-05-22 12:00
tags: [ruby, nanoc, gem]
tldr: "I wrote an extension for Nanoc that helps you make the most of client-side caching by making it easy to add cache busters."
---
One of the benefits of using static site generators is not having to worry about back-end performance. It just doesn't get any faster than delivering static files. But that's not to say there are no optimizations to be made. I wrote an extension for Nanoc to make the most of client-side caching.
{: .leader }

Client-side caching reduces the amount of data the client has to download. All the server has to do is tell the client that a requested file has not changed since the last time he downloaded it, using far-future expiration dates.[^1]

The challenge with far-future expiration
----------------------------------------

But setting a far-future expires header has a downside. When the client 'permanently' caches a file, you as the developer cannot push changes anymore. Since there is no way to tell the client that this time the file _has_ changed, the only option is to use a different file altogether.

We could mimick using a different file by appending a query string to our URL. It sounds smart, but some proxies will actually not cache these supposedly dynamic files at all. So, we simply need to update the filename itself.

We could use version numbers, but that is too much of a hassle. I prefer including a hash of the file in its filename -- so that every time the _content_ changes, the _filename_ changes. And when the filename changes, the URL changes, effectively flushing the client's cache.

The nanoc-cachebuster gem
-------------------------

I wrote an extension to [Nanoc][nanoc], my static site generator of choice, to add a filter and some helpers to do basically two things:

* calculate a content-based fingerprint for the file, that you can use in your routing rules.
* rewrite all references to a fingerprinted file in your source code to the actual output URL.

In practice this means that you can simply refer to, say, `styles.css` in your HTML, and have it rewritten to `styles-cb18bb9ac1f.css` on compilation.

Usage is simple, as you only need to install the gem:

{: .sh }
    $ gem install nanoc-cachebuster

...and `require` the gem and include the helpers to get going:

{: .ruby }
    # in default.rb
    require 'nanoc3/cachebuster'
    include Nanoc3::Helpers::CacheBusting

You can now use the `#fingerprint` method in your routing rules:

{: .ruby }
    route '/assets/styles/' do
      item.identifier.chop + fingerprint(item) + '.' + item[:identifier]
    end

The gem will make sure that references to files you have fingerprinted will get updated when you compile your site.

The [nanoc-cachebuster gem][gem] is an extraction of my [nanoc-template][template] project, where I first developed a simple cache busting filter. But as it grew more complex over time, I decided to refactor it into its own, external component.

You can find [the code at Github][code] and install [the gem from rubygems.org][gem].

[^1]: This doesn't actually reduce the number of HTTP requests, only the amount of data transferred. Keep that in mind. See the [Yahoo! developer network][yahoo] for more information.

*[URL]: Uniform Resource Locator

[code]:     http://github.com/avdgaag/nanoc-cachebuster
[gem]:      http://rubygems.org/gems/nanoc-cachebuster
[template]: http://github.com/avdgaag/nanoc-template
[nanoc]:    http://nanoc.stoneship.org
[yahoo]:    http://developer.yahoo.com/performance/rules.html
