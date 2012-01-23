---
title: Shell scripting to the rescue
kind: article
created_at: 2012-01-19 20:00
tags: [unix, programming, shell scripting, zsh]
tldr:
  Some scripting tasks can be solved right in the shell, without resorting to
  languages like Ruby.
---
I love [Ruby][ruby] and tend to use it for everything I _can_ use it for. But
I've [reading up on Unix][unix] recently, and I decided to test my newfound
knowledge by using standard unix programs to solve a problem. Those who do not
know Unix are doomed to re-implement it badly (or so I have been told).
{: .leader }

I needed to copy a lot of images from a remote server to my local machine.
Since images were constantly being added to the remote server, I wanted to have
a repeatable script to download only those images that were listed in a YAML
file from another application. So I needed to read the YAML file, find the
files listed inside it, and collect those in an archive for easy downloading.

## 01. Reading input

My input file was in YAML, so the first step is reading that. But since the
file is several thousand lines long, we pipe it into head to just print the
first few lines:

    $ cat images.yml | head
    ---
    - http://host.tld/images/image1.jpg
    - http://host.tld/images/image2.jpg
    ...

The first problem was the first line of three dashes, which I needed to get rid
of. Using `sed` you can actually issue `ex` commands like in Vim, so this was
easy:

    $ cat images.yml | sed '1d' | head
    - http://host.tld/images/image1.jpg
    - http://host.tld/images/image2.jpg
    - http://flickr.com/images/image3.jpg
    ...

This deletes line one, but there's a saying along the lines of: "if you `cat` a
file and immediately pipe it into something else, something's wrong". So, I
rewrote it like so:

    $ sed 'd' images.yml | head

## 02. "Parsing" YAML

Then, I needed to get rid of the YAML array element indicators -- the dashes
starting each line. I could have used `sed` for that, but I chose `cut`, which
extracts fields from a line, splitting the line on a given delimited into
columns. I wanted the second column with a space as delimiter:

    $ sed 'd' images.yml | cut -d' ' -f 2 | head
    http://host.tld/images/image1.jpg
    http://host.tld/images/image2.jpg
    http://flickr.com/images/image3.jpg
    …

This was starting to look useful. 

## 03. Getting just the image path

There was a problem with the images: all images contained the full URL, and I
wanted to get just the path. `sed` to the rescue, again:

    $ sed 'd' images.yml | \
      cut -d' ' -f 2 | \
      sed 's|http://host.tld/||' |\
      head
    images/image1.jpg
    images/image2.jpg
    http://flickr.com/images/image3.jpg

This time, I used a replacement pattern as we would in Vim, only replacing the
standard `/` separator with a `|` to not have to escape every `/` in the search
string.

## 04. Getting rid of externally hosted images

This left the problem of externally hosted images. I just gave up on those.
Getting rid of those sounded like a task for `grep`, which can be used to
_exclude_ lines matching a pattern:

    $ sed 'd' images.yml | \
      cut -d' ' -f 2 | \
      sed 's|http://host.tld/||' |\
      grep -v "flickr" |\
      head
    images/image1.jpg
    images/image2.jpg
    http://amazon.com/images/image4.jpg

This gives a new problem: there are several different external hosts in the
file. I only wanted our own. I decided to rewrite the command and use `grep` to
filter out all lines that _do_ contain our own host, and _then_ remove the
domain:

    $ sed 'd' images.yml | \
      cut -d' ' -f 2 | \
      grep "http://host.tld" |\
      sed 's|http://host.tld/||' |\
      head
    images/image1.jpg
    images/image2.jpg
    images/image5.jpg

## 05. Combining files into an archive

The next task was to zip up all those files into one big archive for easy
downloading from the server to my local machine.

The first idea was to just dump the whole lot into `zip`, like so:

    $ sed 'd' images.yml | \
      cut -d' ' -f 2 | \
      grep "http://host.tld" |\
      sed 's|http://host.tld/||' |\
      zip dump.zip

Alas, that doesn't work. I started investigating possible solutions, such as
using `xargs` -- which mashes a bunch of lines into a single line and feed them
as arguments to another program, with some intelligence about the number of
arguments a program accepts. After some fiddling, I got frustrated that `zip`
just didn't read filenames from standard input, so I _finally_ decided to open
the `zip` manual with `man zip`. Searching the manual for `stdin`, I found out
`zip` indeed does not read input filenames from standard input by default, but
On Mac OS X, there's the `--names-stdin` option, while on most other systems
there's `-@`. There you go, it pays to RTFM.

So, the entire command now looks like this:

    $ sed 'd' images.yml | \
      cut -d' ' -f 2 | \
      grep "http://host.tld" |\
      sed 's|http://host.tld/||' |\
      zip dump.zip -@

This does what I wanted it to do quite nicely, but I figured I could do
slightly better.

## 06. Duplicates and thumbnails

One problem was a lot of duplicate images; another was lots of different sizes
of the same image -- with the original one the only I care about.

Solving duplicates is easy enough using the `uniq` program:

    $ sed 'd' images.yml | \
      cut -d' ' -f 2 | \
      grep "http://host.tld" |\
      sed 's|http://host.tld/||' |\
      uniq |\
      zip dump.zip -@

Then, I want to only use the original image, not the generated thumbnails. I
happened to know that generated thumbnails have filenames like
`original-filename-150x75.jpg`. Removing the dimensions at the end of the
filename would give me the regular file. My list could very well contain that
original file already, but `uniq` would sort that out. So, there's one more
`sed` to add:

    $ sed 'd' images.yml | \
      cut -d' ' -f 2 | \
      grep "http://host.tld" |\
      sed 's|http://host.tld/||' |\
      sed 's/-\d+x\d+\.jpg/.jpg/' |\
      uniq |\
      zip -9 dump.zip -@

That gave me a dump archive file containing all my images. As I was happy with
the result, I tacked on a `-9` to enable maximum compression for the archive,
shaving a couple of percentage points of the end result file size.

## Conclusion

This post might seem long, but the process of developing this command chain was
actually rather quick. Feedback is almost instant and there's a rich collection
of tools to get the job done. I'm pretty sure developing a Ruby script doing
the same thing would have involved more manual tweaking and looking up
documentation.

[ruby]: http://ruby-lang.org
[unix]: http://www.amazon.co.uk/gp/product/0596003307/ref=as_li_ss_tl?ie=UTF8&tag=arjanvandergaag-21&linkCode=as2&camp=1634&creative=19450&creativeASIN=0596003307

*[RTFM]: Read The Fucking Manual
