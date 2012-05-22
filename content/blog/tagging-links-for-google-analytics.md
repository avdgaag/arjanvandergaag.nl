---
title:      Tagging links for Google Analytics
kind:       article
created_at: 2010-12-28 12:00
tags:       [Google Analytics, SEO, marketing]
tldr:       "You should tag links to your website so you can better analyse incoming traffic."
---
Analysing incoming traffic is an important part of optimising your online marketing efforts. In the strictest sense, all traffic either comes from another website (a **referral**) or from loading a specific URL (**direct traffic**). Therein lies a problem; here's a solution.
{:.leader}

## The problem of direct traffic

That distinction, however, doesn't help us understand the effectiveness of our newsletter campaign, print ad or social media strategy. So we use tools to sprinkle some fairy dust on our traffic analysis.

Let's assume we're using [Google Analytics][5] to monitor our website traffic. It has got us covered on the referrals part: it can parse and group them into ad campaigns, search engines and such. That helps a great deal, but we can do better.

When we e-mail someone a link, or when we display a URL in a magazine advertisement, we have no way to recognise the traffic they generate — as they all count as 'direct traffic' _without any source information_. We're completely in the dark regarding their origin.

## Tagging a URL

But we can add that missing source information ourselves. We can _tag_ a URL with extra information so we can recognise and segregate incoming traffic in our data analysis.

With Google Analytics, tags come in the form of query variables. They don't look pretty, but they get the job done:

    http://mysite.com/?utm_source=breakfast_club&utm_campaign=xmas&utm_medium=tv

Using these tags, we can specify the following information:

Medium
: the kind of referrer. This could be TV, radio, print, or whatever channel of promotion you want to identify.

Source
: a specific referrer in the medium, such as a TV show, magazine title or newsletter name.

Title
: the name of a campaign, or your ad effort. This could be a christmas sale, coupon code or a newsletter title.

There are two more variables, useful for PPC ads, which I usually ignore:

Terms
: the keywords a specific ad targets

Content
: identifier for alternate versions of an ad, to enable split testing

Now you can actually track the amount of traffic your €300 magazine ad generated — and consequently how well it converted and much revenue it generated.[^1] This, in turn, will help you focus your marketing strategy.

## The problem of the ugly URL

There is one problem, though: these links are rather ugly. Luckily, it is easy to prettify it using HTTP redirects. Just point a pretty but unique URL to your ugly, tagged URL:

    # i.e. in .htaccess or other server configuration file
    Redirect /xmas-sale http://mysite.com/?utm_campaign=xmas-sale...

Or, you could use a URL shortening service like [bit.ly][2] or one of the many, many others to generate a less ugly URL for you.[^2]

## The next level: segregating referral traffic

You can go one step further and use link tagging to segregate even your referral traffic. There are two use cases here:

1. You want to know how much traffic [Twitter][3] is sending you, but many people never use the [twitter.com][3] website. Instead, they prefer desktop and native mobile applications. Therefore, only part of you incoming traffic from Twitter is showing up as such. You could use link tagging to also recognise third-party Twitter traffic.
2. You want to know how well your social media campaign is performing. You could group Twitter, Facebook, LinkedIn and Digg together under a "social media" medium, with each sites as a source.

So, you could use link tagging to segregate incoming traffic on custom sources, roll-up various parts of the same source and do all kinds of nifty things. Of course, it all depends on what problem you are trying to solve by analysing your website traffic.

## The actual tagging process

The one big problem with link tagging is the actual tagging of links. It is not _that_ hard, but it is one extra step to perform. Luckily, Google has made [an online tool for tagging links][1], so you don't have to fiddle with URLs yourself.

But it is still easy to forget to do, or to forget what exact values you used last time. Did you call your custom medium "socialmedia", "social-media" or "social_media"? If you don't get that right, you end up with confusing data later on.

That is why I developed [a tiny copy of Google's link builder][2], but with built-in templates to make this a little bit easier. It also features automatic URL shortening for easy sharing, so [check it out][2].

## Conclusion

If you do want to analyse incoming traffic to your website in greater detail than basic visitor numbers, do make sure you tag your links — especially when sharing them offline or via e-mail, as there will be no way to identify that traffic if you don't.

Only use tagging for URLs you share on the web if you have a clear and specific goal; you don't want to make that boat-load of data you are getting anyway through Google Analytics to get any more confusing than it already is.

Whatever you do, make it a habit and be consistent. The only thing worse than no data is incomplete or invalid data. Happy analysing!

[1]: http://www.google.com/support/analytics/bin/answer.py?hl=en&answer=55578 "google's own, rather spartan, url tagger"
[2]: http://tagger.orangecubed.nl "my own tiny url tagger web app"
[3]: http://twitter.com
[2]: http://bit.ly "bit.ly is one of many url shortening services"
[5]: http://google.com/analytics

*[URL]: Uniform Resource Locator
*[PPC]: Pay-Per-Click
*[HTTP]: HyperText Transfer Protocol

[^1]: Remember, if someone visits your site once using this special URL and then later returns (for example via a bookmark), it still counts as the same source/medium!
[^2]: Do realise the risk of letting someone else host your URLs for you. If, for some reason, they go offline, your URLs stop working. I recommend hosting your own URL shortener, so you can keep matters in your own hands.
