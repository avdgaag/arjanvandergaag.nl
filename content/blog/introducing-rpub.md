---
title: Introducing Rpub, a simple ePub generation library
kind: article
tags: [ruby, epub, ebooks, programming, markdown]
created_at: 2012-05-01 12:00
tldr: I wrote a gem to convert Markdown files to an ebook in epub format.
---
I am writing a book. A little book, but a book nonetheless. And when I started writing it, I knew I wanted to publish it as an ebook and write in Markdown. I found no easy solution to facilitate that, so I wrote my own.
{: .leader }

[Rpub][] is a very simple Ruby gem for converting a set of [markdown][] input files into an ebook in `.epub` format. It is simple because it doesn't do much:

* it converts the markdown files to HTML using [Kramdown][];
* it combines the HTML files together with any referenced images and fonts into a `.zip` archive, together with some XML boilerplate files.

Additionally, it provides some helper functions to make life a little easier:

* a package task to combine the `.epub` file with an arbitrary number of other files (e.g. a license or README) into a single archive for online distribution;
* a preview task for generating a single HTML page for easy previewing-as-you-write.
* a statistics task for counting words and stuff.
* it can generate a table of contents for you based on headers in your text.

## Configuration

As valid `.epub` files require some metadata, a `config.yml` file is needed to generate your book. It is needed to specify book title, author, publisher, subject and all that malarkey. You can also use it to specify the cover image you want to use for the book or what files to include in the package.

The gem comes with default HTML and CSS files for layout, but you can easily override them. Using the `generate` task you can copy these files into your current project and tweak them to your taste.

## Secret features

Because markdown files are converted using [Kramdown][], we get a few nice extra features:

* footnotes
* syntax highlighting of code samples
* automatic header ids
* abbreviations

Find out more about those in the [Kramdown documentation][quickref].

## Getting started

Rpub is distributed as a Ruby gem, so getting started is easy. Once you've got a working installation of Ruby and Ruby Gems set up, you can install Rpub:

    $ gem install rpub

Then create a new directory for your project, write your next great novel in a `.md` file per chapter and set the title and author in a `config.yml` file:

    ---
    creator: Arjan van der Gaag
    language: en
    version: 1.0.0
    title: Absolutism in 18th century Cleves
    publisher: Me!
    subject: History
    rights: copyright 2012. All rights reserved.
    description: My awesome history thesis.
{: .yaml }

That should do it. Compile your ebook:

    $ rpub compile

…and a new `absolutism-in-the-18th-centruy-1.0.0.epub` file will appear in your current directory. Open it in iBooks on your iPad or use an ebook reader on your computer and bask in your self-publishing glory.

### Contribute

Take [the gem][gem] for a spin and report any issues you find on the [Github issues tracker][issues]. Or better yet, [fork it][Rpub] and send it some pull request love.

[gem]:      https://rubygems.org/gems/rpub
[Rpub]:     https://avdgaag.github.com/rpub
[markdown]: http://daringfireball.net/projects/markdown
[kramdown]: http://kramdown.rubyforge.org
[quickref]: http://kramdown.rubyforge.org/quickref.html
[issues]:   https://github.com/avdgaag/rpub/issues
