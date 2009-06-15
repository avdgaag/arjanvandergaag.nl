---
layout: post
title: Using Jekyll to create websites
published: true
category: code
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

> I can now use my favorite text editor and versioning
> system for my blog
{: .pull }

If it sounds easy, that's because it is. I can use [my favourite text editor][3]
and [version control system][4] to write my posts, and then I let Jekyll use
[Markdown][2] to turn my files into HTML. You can also use other filters, or
write plain HTML.

Let me stress my point: I can use my favorite text editor and versioning
system for my blog, rather than some wimpy `<textarea>`.

## Here comes trouble

Jekyll doesn't do a lot, by design. Some manual labour is involved; here are
some of my automations -- because we don't like manual labour, now do we?

### 1. **Publishing files to a server**

I use `rsync` to copy my generated site to my server:

{% highlight bash %}
$> rsync -avz "_site/" username@server:~/dir/to/public/
{% endhighlight %}

### 2. **Creating new posts**

Manually typing filenames in the form `yyyy-mm-dd-title.filter` is a
pain, so I use the following Rake task:

{% highlight ruby %}
desc 'create a new draft post'
task :post do
  title = ENV['TITLE']
  slug = "#{Date.today}-#{title.downcase.gsub(/[^\w]+/, '-')}"

  file = File.join(File.dirname(__FILE__), '_posts', slug + '.markdown')

  File.open(file, "w") do |f|
    f << <<-EOS.gsub(/^    /, '')
    ---
    layout: post
    title: #{title}
    published: false
    categories:
    ---

    EOS
  end

  system ("#{ENV['EDITOR']} #{file}")
end
{% endhighlight %}

Now I can type `rake post TITLE='hello, world'` to create a post, launch
TextMate and start typing.

### 3. **Draft posts**

I keep all my posts in one directory (`./_posts`) and use the `published` flag
in the YAML front matter to exclude certain posts from publication. I can find
all draft posts as follows:

{% highlight bash %}
$> find ./_posts -type f -exec grep -H 'published: false' {} \\;
{% endhighlight %}

### 4. **Sitemaps**

I have created a sitemap file for my site, and I want to ping Google every
time I republish my site. Here's how I do it:

{% highlight ruby %}
desc 'Notify Google of the new sitemap'
task :sitemap do
    require 'net/http'
    require 'uri'
    Net::HTTP.get(
        'www.google.com',
        '/webmasters/tools/ping?sitemap=' +
        URI.escape('http://domain.com/sitemap.xml')
    )
  end
end
{% endhighlight %}

## Publication process

I have included all these snippets, and some others, in one big Rakefile in my
project directory. Whenever I am ready to publish my site to my server I can
simply call `rake publish` and it will let Jekyll re-generate my site, upload
all the files to the server and ping Google about my new sitemap.

The actual [source code to my site is shared publicly at Github][5], so you
can check out [my collection of tasks][6].

## Downsides, Conclusion

First, since my entire website is now just static HTML it is **no longer
possible to have comments** on my site, unless I would use something like
[Disqus][7]. I'm fine without comments. Second, since Jekyll is Ruby gem,
writing more Ruby to add functionality to the website is easy -- but actually
getting it in there is a little harder. **Jekyll lacks a neat plug-in
solution**. Luckily it's easy to fork Jekyll on Github and hack away. Thirdly,
setting up archive pages, searching, RSS syndication, tagging and post
browsing **take some manual labour**, but for now I'm fine without them.
Jekyll is certainly not suited for everyone, but for simple sites it works fine.

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
[4]: http://git-scm.com "Git - Fast Version Control System"
[5]: http://github.com/avdgaag/arjanvandergaag.nl/tree/master "Browse the source code to this site at Github"
[7]: http://disqus.com/ "DISQUS is a Javascript-based commenting system"
[6]: http://github.com/avdgaag/arjanvandergaag.nl/blob/28539bc736a05b28f2aa4ef81e4f61f3f91375a0/Rakefile "See my project's Rakefile"