---
layout: post
title: Creating new Jekyll posts
published: true
categories:
  - code
  - jekyll
---

Jekyll, a static site generator, is *blog-aware*. That means it tracks posts
and publication dates. Working with such files can be tricky, but here is one
way of using Rake to ease the pain.
{: .leader }

## What we need

Jekyll requires blog posts to be saved in files with a specific filename. It
should include the title of the post **and the publication date**. Example:
2009-06-15-hello-world.markdown. The extension tells Jekyll what text filter
to use (Markdown in this case).

## What we want

Manually typing filenames in the form `yyyy-mm-dd-title.filter` is a
pain. I want to be able to create a post, given a title, and let it figure out
the date itself.

## What we get

I use the following Rake task to create post files:

{% highlight ruby linenos %}
desc 'create a new draft post'
task :post do
  title = ENV['TITLE']
  slug = "#{Date.today}-#{title.downcase.gsub(/[^\w]+/, '-')}"

  file = File.join(
    File.dirname(__FILE__),
    '_posts',
    slug + '.markdown'
  )

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

Now I can type `rake post TITLE='hello, world'` to create a post. Here's what
it does:

1. At lines 3 and 4 it finds the `TITLE` argument and converts it to a
   suitable filename with the current date prepended.
2. At line 6 the filename is expanded to a full path to the file to create.
3. The following block (8–18) writes a post template to that file. This is
   some YAML front matter, with the `published` flag down by default.
4. Finally, at line 20, it launches the file in my default text editor,
   which in my case in [TextMate][1].

## Draft posts

With the `published` flag set to `false` **I can keep my drafts in my Git
repository without actually publishing them**. I can find all draft posts
using `rake drafts`:

{% highlight ruby %}
desc 'List all draft posts'
task :drafts do
  puts `find ./_posts -type f -exec grep -H 'published: false' {} \\;`
end
{% endhighlight %}

## Renaming files

One slight problem occurs when I want to rename the file to publish it on a
different date. I don't have a task yet that can easily rename a file. It
would also be useful to be able to override the default extension.

There's still some work to do, but I guess I've got 80% of the scenarios
covered.

*[YAML]: Yet Another Markup Language

[1]: http://macromates.com "TextMate is my favourite text editor"