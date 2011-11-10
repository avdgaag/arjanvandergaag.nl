---
title: "Tagger: Easier Google Analytics URL Tagging"
kind: article
created_at: 2010-12-16 12:00
tags: [tools, Google Analytics]
tldr: "I created a tool for tagging links with some templates and automatic URL shortening."
---
Tagging with campaign variables is a good practice when sharing links to your website. It allows you to track the traffic you receive from that link, so you can do all sorts of awesome analyses. But there's a problem.
{:.leader}

![Using custom source and medium in Google Analytics](/assets/images/sources.png){:.photo .right .pull .bordered}

Or rather, there are two problems with tagging URL's:

* **Tagging links is too much work**: you have to Google for [Google's URL builder tool][1], figure out what values you want to use for your campaign, and then copy the URL it spits out.
* **Tagged URLs are ugly**: It's not very nice to send someone a link like `http://mysite.com/mypage?utm_campaign=x&utm_source=y&utm_medium=z`.

So, I wanted an easier way to tag my links — and I created [a tiny Sinatra application][4] ([source code][3]) to do it. All the cool kids create tiny [Sinatra][5] applications to do stuff, right?

[![](/assets/images/tagger.png){:.photo .right .pull .bordered}][4]

## Templates

[My Tagger tool][4][^1] looks much the same as Google's original, but it can take some of the work of entering values by hand off your hands. It let's you pick a set of predefined values — a template, if you will — and specify only the values that matter.

So, you can use a pretty form to pick "social media" as your medium and "twitter" as your source. All you have to do is specify your campaign title. The point is, you no longer have to remember if you previously tagged your social media campaigns with "social_media", "social-media" or "socialmedia" as your medium.

Other templates include newsletters and offline campaigns. You can still enter all variables by hand if you want, though.

## URL Shortening

When you generate a tagged URL, a tiny Sinatra application will parse your input and merge the generated campaign variables into the URL. It will then return to you the tagged URL and a shorter version, generated using [bit.ly][2].

This helps with sharing, as a `http://bit.ly/foobar` URL is much nicer to receive. There are two notes to make here:

1. You really should **own your own URL's**. You don't want to lose all your incoming traffic when bit.ly suddenly goes out of business or whatever. You might want to set up your own custom URL shortener, resulting in something like `http://mysite.com/s/foobar`.
2. You should use **vanity URL's** — basically a server-side rewrite or redirect from a pretty URL like `http://mysite.com/xmas` to your actual landing page at `http://mysite.com/pages/christmas-sale.html?utm_campaign=christmas-sale&utm_medium=offline&utm_source=radio`.

## Make it even easier

In order to make sure you never share untagged links, tagging has to be as quick and easy as possible. So here's an idea to make that happen:

* Create a simple JSON or XML API for the service, which should be fairly simple.
* Integrate it in external tools, like a WordPress dashboard widget. This would make it dead easy for authors to tag links.

Oh, so many ideas, so little time… Maybe someone [will fork the project on Github][3] and do it?

*[URL]: Uniform Resource Locator
*[JSON]: JavaScript Object Notation
*[XML]: eXtensible Markup Language
*[API]: Application Programming Interface

[^1]: Tagger is not really a cool name, I know. Sorry.

[1]: http://www.google.com/support/analytics/bin/answer.py?hl=en&answer=55578
[2]: http://bit.ly/ "bit.ly | Basic | a simple url shortener"
[3]: https://github.com/avdgaag/tagger "Browse the source code at Github"
[4]: http://tagger.orangecubed.nl "Go to my link tagger tool"
[5]: http://www.sinatrarb.com "Sinatra is a really simple Ruby web framework"
