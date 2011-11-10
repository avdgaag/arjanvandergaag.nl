---
title: On Using Vim
created_at: 2010-09-14 10:50
kind: article
tags: [vim, tips]
---
Like all the cool kids in town, my text editor of choice used to be [Textmate][]. Then I jumped on the wave of interest in Vim, which seems to be the new black these days.
{:.leader}

I have been using Vim for a couple of months now, and I realised I haven’t
shared much of my experience yet. Here are a few of my thoughts on day-to-day
use of Vim, and how I have customised Vim to my liking.

## Getting used to Vim

When I first came in contact with Vim a couple of years ago, I was confused by
the concept of modal editing. When I decided to start using Vim regularly to
see if I liked it, I spent some time reading up on the philosophy behind Vim
and its modes. Only when I ‘got it’ did I dive in.[^1]

Working with command, selection and insert modes takes some getting used to.
But, as many other Vim users will tell you, once you do get used to it, you
start missing it in other editors. The speed and precision of text operations
and navigation in Vim command mode makes any other editor feel slow and clunky.

![Espcially with the right color scheme, Vim is an awesome editor](/assets/images/vim.png){:.photo .right .pull}

### Force yourself to adapt

I did not really use any leaning programs, I decided to just start using it and
find out stuff as I went along. In the end, this is how I learned to type using
the Dvorak keyboard lay-out: use it exclusively and let your frustration power
your learning.[^2] After a couple of days, you will have gotten it.

Forcing yourself to get used to the new pattern might require some assistance,
if you will. For example, I disabled the arrow keys in command mode to force
myself to use the home row keys.

But if you are learning how to use Vim now, I can strongly recommend watching
the [Peepcode screencasts on Vim][peepcode]. They’re well worth the money in
content and production quality.

### Compared to Textmate

I was desperately slow using Vim at first, but as I found out more commands and
shortcuts, I got to the same level of productivity of using [Textmate][].
Still, although Vim _can_ do just about anything, I found that Textmate’s
concept of bundles (i.e. collections of scripts) defeat anything Vim can do
hands down in development time and ease of use.

## Customizations

Vim seems to be infinitely customizable, and many people share their
configurations online. For example, Vincent Driessen has published [a nice
collection of tips and tricks][nvie]. I have collected [my fair share of
settings][github] over time.

### Editing and reloading of `.vimrc`

One of the most important is a shortcut to editing and reloading my `.vimrc`
file:

    map <Leader>e :e! ~/.vimrc<cr>
    autocmd! bufwritepost vimrc source ~/.vimrc
{:.vim}

The adding and updating of shortcuts is just a few keystrokes away. I use a
similar setup to quickly edit and reload my `.zshrc` in the terminal.

### File type customizations

I like to use 4 spaces instead of tabs, but in Ruby-related files the custom is
to use 2 spaces. I instruct Vim to use 2 spaces in Ruby files like so:

    autocmd Filetype ruby,yaml,rake,rb setlocal ts=2 sw=2 expandtab

Similarly, I like to ‘run’ files right from Vim. For Ruby files this would mean
running the file through `ruby`, while for HTML files this would opening the
file in a browser. This is simple:

    autocmd Filetype ruby,rb nmap <Leader>r :!ruby %<CR>
    autocmd Filetype html nmap <Leader>r :!open -a Safari %<CR>

Of course, the second example will only work on Mac OS X, as it provides the
`open` command.

### Plug-ins

I use a couple of plug-ins to enhance Vim, but these are simply the usual
suspects you find elsewhere. These include NERDTree, snipmate, surround and
tComment. One notable plug-in is [sparkup][], which allows you to write HTML
quite quickly:

    div>ul.menu>li*3>a[href="#"]{Item}
{:.css}

...turns into:

    <div>
        <ul class="menu">
            <li><a href="#">Item</a></li>
            <li><a href="#">Item</a></li>
            <li><a href="#">Item</a></li>
        </ul>
    </div>
{:.html}

Check out [sparkup at Github][sparkup].

[sparkup]: https://github.com/rstacruz/sparkup

### Find more

There’s lots more you can tell Vim to do. I share my configuration files on
Github, updating them every now and then. Searching for ‘config files’ or
‘dotfiles’ on Github or Google will lead you to many more example
configurations from which you can cherry-pick.

## The verdict

I have gotten used to Vim and I like. I like it a lot. But it is not perfect.
Vim is a great _editor_: it‘s very good at changing and moving text around, but
I find Textmate much quicker and easier to use when _writing_ lots of text.
That is to say, its snippets and commands are easier to use than Vim’s and
emphasize _creation_.

I cannot conclude but that Textmate and Vim are both tools, each suited for its
own kind of job. I currently spend equal amounts of time in both. Were Textmate
to gain more advanced editing controls, or Vim Textmate’s bundles, I would
happily stick to one or the other.

[Textmate]: http://macromates.com
[peepcode]: http://peepcode.com/products/smash-into-vim-i
[github]: https://github.com/avdgaag/dotfiles
[MacVim]: http://code.google.com/p/macvim/
[dvorak]: http://old.arjanvandergaag.nl/2008/01/14/learning-dvorak/
[nvie]: http://nvie.com/posts/how-i-boosted-my-vim/

[^1]: I currently use [MacVim][] for most of my work, and Vim in the standard Mac OS X terminal for quick hacks.
[^2]: There’s still [an old post of mine][dvorak] online [about using Dvorak][dvorak], from back when I was using Windows. Imagine that.
