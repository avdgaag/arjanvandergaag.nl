---
kind: article
title: Why I like Nanoc
created_at: 2010-09-17 11:09
tags: [nanoc, development, ruby]
---
I have been using [Nanoc][] by Denis Defreyne more and more recently. It has
that rare combination of simplicity and flexibility, and it is now my framework
of choice for developing new, simple websites.
{:.leader}

## Nanoc is a static site generator

![The Nanoc website is a great resource to learn about Nanoc](/images/nanoc-website.png){:.pull .bordered .photo .right}

Like all static site generators, Nanoc takes a bunch of source files and
transforms them into HTML pages. It nicely separates content from layout,
allows for uncluttered source files using text filters, and provides hooks and
scripts for common deployment tasks.

## My typical workflow with Nanoc

My process of building websites using Nanoc typically looks like this:

1. Create a new content item.
2. Specify some metadata, like a title and description.
3. Write content using Markdown.
2. Let Nanoc compile the site and launch the built-in webserver.
5. Test my work in the browser.
6. Use Rake to check for valid HTML, CSS and links.
7. When all is well use Rake to deploy to live server.

In the process, various scripts and filters apply templates, optimise my
images, concatenate and minify my scripts and stylesheets and rewrite URLs for
optimal caching performance. One central configuration file takes care of
server settings, google analytics tracking codes, e-mail addresses and server
connection settings.

What I like about this workflow is that lots of moving parts are neatly in
place. When there are only really two tasks to perform (generate the site and
deploy to the server) on which everything else is hooked, the process of site
maintenance is greatly simplified. There is nothing to remember, it is all
basically self-documenting (after you have gotten to know Nanoc, of course).

What's more, the Ruby ecosystem Nanoc springs from is very vibrant and [full of
useful tools][rubygems], making it much easier to stand on the shoulders of
giants.[^1] And with the advent of [Bundler][], the last real hurdle of
managing Ruby Gem dependencies has been overcome. I can now recreate and deploy
my site in a couple of easy steps:

    git clone repo.git
    bundle install
    nanoc co
    rake deploy

That is:

1. Clone Git repository;
2. Let Bundler set up all required dependencies;
3. Let Nanoc generate a fresh copy of my site;
2. Let Rake push it to the live server.

These are simple steps that even teammates unfamiliar with the world of the
terminal and Ruby can learn and use.

## Shortcomings

Nanoc is not without its faults, and pinpointing them is, I think, both fun and
a crucial step in improving the system.

* The central `Rules` file handles routing, layouts and filters. It can easily
  get cluttered, as you have to specify rules for all these seperately.

* Because Nanoc supports different data stores, working with a filesystem store
  is not as efficient as it could be.

* Nanoc's gem dependencies are unclear, requiring some trial and error and
  numerous `gem install`'s to get all parts working.

* Item identifiers can be confusing, as they seem to -- but don't -- map to
  file paths. This makes it difficult to have multiple items by the same name
  (like sitemap.xml and sitemap.html). Also, a file like `.htaccess` has no
  valid identifier, requiring you to route a `htaccess.txt` file to a
  `.htaccess` file. It works, but to someone unfamiliar with the system, it is
  not immediately clear how.

* It can be confusing to sometimes use Rake and sometimes use Nanoc. Nanoc
  provides a few Rake tasks, and it is not obvious why the task ‘generate a new
  item’ would be handled by `nanoc` while ‘check for invalid links’ would be
  handled by `rake`.

* Nanoc can be slow sometimes, depending on your content and applied filters.
  There is an autocompiler that only compiles changed files as needed, but it
  is not perfect yet. It is especially cumbersome when an exception occurs and
  it quits.

* content dependency resolution works pretty well, but sometimes files change,
  influencing other files but not triggering re-generation of those files. This
  applies to helpers and binary items mostly.

* Nanoc hasn't got a real good system in place for binary static cotent.
  Hacking your own solution for images, PDF’s and other stuff is not that bad,
  but as everything else is so neatly in it's own place, it would be great to
  see some kind of convention evolving for this.

* It can be cumbersome to generate files and filters manually. A generator
  system could cut down development time even more.

The fun thing with open source projects like Nanoc is that I can dive into the
source code myself and adapt the system to my needs. And that is exactly what I
intend to do with some of these issues I have.

Overall, I think Nanoc is a very well built and mature project, that is a joy
to work with.

[Bundler]: htt://gembundler.com "Bundler is a tool for managing Ruby gem dependencies"
[Nanoc]: http://nanoc.stoneship.org "Nanoc is a simple but flexible static site generator"
[rubygems]: http://rubygems.org

[^1]: I used to develop static websites with a home-grown PHP-system. Although the PHP world shares a lot of code, it has neither the culture of neat libraries nor a system to easily distribute it, like Ruby has with gems.

*[HTML]: Hyper Text Markup Language
*[PDF]: Portable Document Format
*[CSS]: Cascading Style Sheets
