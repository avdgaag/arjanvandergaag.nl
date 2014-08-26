---
title: Combining Vim and Ctags
kind: article
created_at: 2014-08-25 12:00
tags:
  - development
  - vim
tldr: Use ctags, Vim and Rbenv to navigate your codebase quicker using tags.
---

Working with large Rails projects means dealing with a lot of files. Being able
to navigate these files quickly is a huge productivity boost. Combining Vim and
ctags can help by offering tag-based navigation.
{: .leader }

## About Ctags

[Ctags][] is a tool for indexing source code. It scans a bunch of files and
creates a single list of the locations of classes, methods, constants or
whatever else you tell it to index. Having an index like that gives you a nice
way to search for important identifiers in your code base.

The de facto standard these days however is not ctags itself but a project
called [exuberant ctags][], which supports more programming languages and
features and integrates nicely with Vim.

You can install exuberant ctags through your regular package manager of choice;
in the Mac OS X world you would use Homebrew:

    % brew install ctags

To make sure you have the right version installed, check the version
information for _Exuberant Ctags_:

    % ctags --version
    Exuberant Ctags 5.8, Copyright (C) 1996-2009 Darren Hiebert
    Compiled: Jul 25 2014, 20:54:25
    Addresses: <dhiebert@users.sourceforge.net>, http://ctags.sourceforge.net
    Optional compiled features: +wildcards, +regex

## Generating a tags file

If you have a project with a bunch of source files -- say, a Rails project --
you can run `ctags` from your project root to index it:

    % ctags --recurse .

This will give you a nice `tags` file. Now you may want to include more than
just your project's tags in your tags file. In a Ruby project, it might be
helpful to include tags for all your gems, too. You can give `ctags` multiple
locations to index, so you could feed it a bunch of paths from Bundler:

    % ctags --recurse . `bundle show --paths`

This will significantly increase the size of your index (and the time it takes
to generate it) but makes it a lot easier to quickly inspect library code.

Now `ctags` can take quite a few options, but the most important I use are
these:

* `--recurse` to index everything in this directory and all directories below
  it;
* `--exclude=` to skip certain directories from indexing, specifying it once for
  at least `.git`, `tmp`, `doc` and `log`;
* `--append` to have new definitions added to, rather than replacing the old,
  collection tags;
* `--languages=-javascript,sql` to exclude certain file types from indexing --
  which naturally differs per project.

Specifying all these options at the command line is cumbersome so Ctags supports
a configuration file in your home directory where you can list your default
options:

    % cat ~/.ctags
    --recurse=yes
    --exclude=.git
    --exclude=log
    --languages=-javascript,sql
    --append

[My ctags file][] is available online in my dotfiles repository.

## Navigating tags in Vim

Once we do have a Ctags index generated, we can use it for navigation in Vim.
Vim by default looks for a `tags` file in your current directory and in the
directory of the current file:

    :set tags?
    ./tags,tags

...which is usually fine. You can use the `tags` option to store it somewhere
else, such as in your `.git` directory.

There are several different ways you can navigate your
code base using tags:

1. Use the `:tag` command to jump to a tag by name. This comes with tab
   completion and positions your cursor straight on the line of the tag
   definition (such as where a constant is defined).
2. Using the `CTRL-]` command you can jump to a tag under your cursor. This is
   nice when you come across a class name in your code and want to jump to it.
   Position your cursor on the name, press `CTRL-]` and there you go.
3. Some plugins integrate with tags, such as [CtrlP][]. Apart from fuzzy finding
   files, it can also fuzzy-find tags. This is particularly nice if you are
   not quite sure on the exact spelling of the tag you are looking for.
4. Using the **tag stack**, which is a list of tag-based locations you have
   visited. After following some tags, you can trace back through your history
   with `:pop` or `CTRL-T` and forward with `:tag` (each take an optional
   count). To see your history, you can use `:tags`. This works much like Vim's
   regular `CTRL-I` and `CTRL-O` commands for the jump list, but the tag stack
   only contains, well, tags.

There are some more options are details you may be interested in, which are
documented nicely in Vim's documentation. See `:help tags` for more information.

## Keeping your tags file up to date

The trick to using Ctags is keeping your index up to date. When you install new
dependencies or pull in new commits, your index is out of date. You _could_ run
`ctags` every time, but we all know how that'll work out. So there are some
tricks to automatically keep your index updated.

### Project tags

First, you can use a Git hook to re-generate your index whenever your working
tree is changed. The `.git/hooks/post-checkout` file is a good place to stick
such a hook. Tim Pope has written an excellent explanation of [how to install a
Git hook to generate tags][tpope-ctags].

### Gem tags

Second, when dealing with Ruby projects, you can hook into Rubygems and
automatically generate ctags for your gems on installation. Tim Pope (again) has
written a neat plugin [gem-ctags][] to do just that. Having Tim's
[vim-bundler][] plugin installed handles picking up the generated indices for
you.

### Standard Library tags

Finally, there's tags for the Ruby standard library. If you use [Rbenv][] -- and
why wouldn't you? -- you can use Tim Pope's (gasp!) [rbenv-ctags][] plugin to
automatically generate indices when you install a new Ruby. Having [vim-ruby][]
and [vim-rbenv][] installed will make sure Vim will pick these up, too. And
while you're at it, use [rbenv-default-gems][] to automatically install
gem-ctags when you install new Rubies.

## Round-up

You can navigate your projects using meaningful names rather than files using
tags. You can browse back and forth through your code using Vim's tag stack and
there are various plugins available to make sure your tags file always stays up
to date. Go forth and navigate!

[Ctags]:              http://en.wikipedia.org/wiki/Ctags
[exuberant ctags]:    http://ctags.sourceforge.net
[My ctags]:           https://github.com/avdgaag/dotfiles/tree/master/home/.ctags
[CtrlP]:              https://github.com/kien/ctrlp.vim
[tpope-ctags]:        http://tbaggery.com/2011/08/08/effortless-ctags-with-git.html
[gem-ctags]:          https://github.com/tpope/gem-ctags
[vim-bundler]:        https://github.com/tpope/vim-bundler
[vim-rbenv]:          https://github.com/tpope/vim-rbenv
[vim-ruby]:           https://github.com/vim-ruby/vim-ruby
[rbenv-default-gems]: https://github.com/sstephenson/rbenv-default-gems
[Rbenv]:              https://github.com/sstephenson/rbenv
[rbenv-ctags]:        https://github.com/tpope/rbenv-ctags
