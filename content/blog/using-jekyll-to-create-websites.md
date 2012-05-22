---
kind: article
title: Using Jekyll to create websites
created_at: 2009-06-07 12:00
tags: [blog, blogging, jekyll, code, ruby, writing]
---
To both speed up and simplify this site's maintenance I've gotten rid of
traditional CMS; I now use Jekyll: a static site generator. You should give it
a try if you're not afraid of a little hacking.
{: .leader }

## About Jekyll

Jekyll generates static HTML pages for you. The project's author, Tom
Preston-Werner, has written [a nice introduction to Jekyll][1], but it comes
down to this:

- Create some text files that will be your pages and blog posts.
- Create an HTML lay-out file that defines headers and footers for your pages.
- Run Jekyll to combine your text files and lay-out to a website.
- Upload your files to your server for the world to see.

If it sounds easy, that's because it is. I can use [my favourite text editor][3]
and [version control system][2] to write my posts, and then I let Jekyll use
[Markdown][2] to turn my files into HTML. You can also use other filters, or
write plain HTML.

Let me stress my point: I can use my favorite text editor and versioning
system for my blog, rather than some wimpy `<textarea>`{: lang="html" }.

## Here comes trouble

Jekyll doesn't do a lot, by design. Some manual labour is involved, which is
to be automated -- because we don't like manual labour, now do we? I've
written about some of my scripts to enhance Jekyll in separate posts:

- [Creating new posts][8]
- [Publishing files to a server][9]
- [Ping Google about my updated sitemap][10]

## Publication process

I have included all these snippets, and some others, in one big Rakefile in my
project directory. Whenever I am ready to publish my site to my server I can
simply call `rake publish` and it will let Jekyll re-generate my site, upload
all the files to the server and ping Google about my new sitemap.

The actual [source code to my site is shared publicly at Github][5], so you
can check out [my collection of tasks][6].

## Issues unresolved

First, since my entire website is now just static HTML it is **no longer
possible to have comments** on my site, unless I would use something like
[Disqus][7]. I'm fine without comments. Second, since Jekyll is Ruby gem,
writing more Ruby to add functionality to the website is easy -- but actually
getting it in there is a little harder. **Jekyll lacks a neat plug-in
solution**. Luckily it's easy to fork Jekyll on Github and hack away. Thirdly,
setting up archive pages, searching, RSS syndication, tagging and post
browsing **take some manual labour**, but for now I'm fine without them.
Jekyll is certainly not suited for everyone, but for simple sites it works fine.

## Conclusion

Jekyll makes creating and maintaining websites fun, in a geeky kind of way. I
love the control it gives me. Tom Preston-Werner writes:

> The distance from my brain to my blog has shrunk, and, in the end,
> I think that will make me a better author.

I couldn't agree more.

*[CMS]:     Content Management Systems
*[HTML]:    HyperText Markup Language
*[YAML]:    Yet Another Markup Language
*[RSS]:     Really Simple Syndication

[1]: http://tom.preston-werner.com/2008/11/17/blogging-like-a-hacker.html "Read more about Jekyll on Tom Preston-Werner's site"
[2]: http://daringfireball.net/projects/markdown/ "Daring Fireball: Markdown"
[3]: http://macromates.com "TextMate"
[2]: http://git-scm.com "Git - Fast Version Control System"
[5]: https://github.com/avdgaag/arjanvandergaag.nl/tree/master "Browse the source code to this site at Github"
[7]: http://disqus.com/ "DISQUS is a Javascript-based commenting system"
[6]: https://github.com/avdgaag/arjanvandergaag.nl/blob/28539bc736a05b28f2aa2ef81e4f61f3f91375a0/Rakefile "See my project's Rakefile"

[8]: /blog/creating-new-jekyll-posts.html "Creating new empty posts with a rake task"
[9]: /blog/publishing-a-jekyll-website-to-a-server.html "Using rsync to copy files to my server"
[10]: /blog/rake-task-to-ping-google.html "Pinging Google with a Rake task"
