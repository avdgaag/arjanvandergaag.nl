---
layout: post
title: Publishing a Jekyll website to a server
published: true
keywords: blog, blogging, code, ruby, rake, automation, script
description: In which I describe how I publish static HTML files to a server using ruby scripts.
categories:
  - code
  - jekyll
---

One of the problems with using Jekyll, a static website generator, is that you
have to copy your files to a server _manually_ if you want the world to see
them. Luckily, **it is easy to automate**.
{: .leader }

## Using `rsync`

I use `rsync` to copy my generated site to my server. This works like a charm:

{% highlight bash %}
$> rsync -avz "_site/" username@server:~/dir/to/public/
{% endhighlight %}

The `avz` flags tell it to be verbose, and both archive and compress the data.

## Rake task

Remembering and typing that `rsync` line every time I want to publish my site
is not a good idea, so I dropped the whole thing in a Rake task:

{% highlight ruby %}
desc 'rsync the contents of ./_site to the server'
task :sync do
  puts '* Publishing files to live server'
  puts `rsync -avz "_site/" username@server:~/dir/to/public/`
end
{% endhighlight %}

Publishing my site is now as easy as `rake sync`. The good thing about putting
this in a Rake task is that I can now **chain the syncing with other tasks**:
calling `rake publish` will re-generate my site, push code to Github, sync my
site with the server and notify various web services about the changes to my
site. Awesome.

You can check out [my `Rakefile` at Github][1].

[1]: http://github.com/avdgaag/arjanvandergaag.nl/blob/cbc47e03d4cf766278f2982bfe79862cb251fd34/Rakefile "View my Rakefile on Github"