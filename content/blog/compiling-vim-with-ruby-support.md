---
title: Compiling Vim with Ruby support
kind: article
created_at: 2011-11-30 12:00
tags:
  - vim
  - mac os x
  - ruby
tldr: Compiling Vim with Ruby support is pretty easy, as long as mind what Ruby version you link it to.
---
Vim can easily be extended, not only with Vimscript but also with Ruby, Python, or whatever else. However, Vim needs to be compiled with support for those external languages. On Mac OS X by default it is not. Luckily, it is easy to do it yourself.
{: .leader }

The other day I wanted to give the [command-t][] plugin another go. It is a nice fuzzy-search plugin writing in Ruby (with a C extension), and it requires Vim with Ruby support. Of course, [MacVim][] comes with Ruby support built-in, but I prefer running Vim in the terminal, so I was out of luck. "No biggie", I thought to myself, "how hard can compiling Vim be?" As it turned out, I ran into some issues with Vim **immediately crashing** after installation, or as soon as I tried to use the command-t.

## Mind the Ruby version you link to

By installing Vim with Ruby support, you link it to a particular installation of Ruby. Mac OS X comes with Ruby by default, by I use [rbenv][] to switch between different versions. This becomes problematic if you try to compile Vim against one version, and then try to install a plugin like command-t with a C-extension compiled against _another_ version.

I decided to compile both against my system Ruby (1.8.7) as that is the least likely to be messed around with. In a new shell session, I first switched to the stock Ruby version:

    $ rbenv shell system
    $ ruby -v
    ruby 1.8.7 (2010-01-10 patchlevel 229) [universal-darwin11.0]

## Compiling Vim

The first actual step is to get the Vim source code. There's more than one way to skin this cat, but I chose to clone the repository with Mercurial:

    $ hg clone https://vim.googlecode.com/hg/ vim

This gives you a `vim` directory in your current working directory. Change into it to start the whole _configure, make, make install_ routine:

    ./configure --prefix=/usr/local \
        --enable-gui=no \
        --without-x \
        --disable-nls \
        --enable-multibyte \
        --with-tlib=ncurses \
        --enable-pythoninterp \
        --enable-rubyinterp \
        --with-ruby-command=/usr/bin/ruby \
        --with-features=huge

Note the `--enable-rubyinterp` -- and toss in `--enable-pythoninterp` while you're at it. Note you may want to adjust your `prefix`. Then compile and install:

    make
    sudo make install

Finally, make sure `[prefix]/bin` is in your `$PATH`. Check it with `echo $PATH` to see your current `$PATH`, and edit `.bashrc` or `.zshrc` to prepend it if necessary:

    export PATH=/usr/local/bin:$PATH

If you `source` your shell configuration, or just start a new terminal session, you will notice the new version of Vim:

    $ which vim
    /usr/local/bin/vim
    $ vim --version
    ...

The output of `vim --version` will tell you _a lot_, but somewhere in there is `+ruby` to indicate you can now run Ruby straight from Vim. Try it by starting Vim and perform the command:

    :ruby puts 'Hello, world'

## Installing command-t

Installing command-t is pretty easy. The documentation describes how you can install it as a vimball, or straight from the source -- for example using [Tim Pope][tp]'s excellent [Pathogen][] plugin. I opted to install it as a Git submodule and load it with Pathogen. Change into the plugin directory:

    cd ~/.vim/bundle/command-t

There's a nice `Rakefile` for us there that will handle installing the C-extension. Still in a shell where system Ruby is the currently active Ruby installation, we just need to follow the installation instructions:

    ruby extconf.rb
    rake make

That should do it; you should now be able to launch Vim and start using command-t. You can find [my Vim setup at Github][dotfiles].

[dotfiles]: https://github.com/avdgaag/dotfiles
[Pathogen]: http://www.vim.org/scripts/script.php?script_id=2332
[tp]: http://tbaggery.com/
[rbenv]: https://github.com/sstephenson/rbenv
[command-t]: https://wincent.com/products/command-t
[MacVim]: http://code.google.com/p/macvim/
