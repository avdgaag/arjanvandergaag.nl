---
title: Navigating project files with Vim
kind: article
created_at: 2014-03-05 11:00
tags: [vim, development, ruby]
tldr: With find and gf, Vim has some powerful tools built-in to navigate across project files.
---
When I was learning to use Vim, finding my way around all the files in my
project was one of the major obstacles. But however tempting it may be to use a
plugin such as [NERDTree][] to get a GUI-like file browser in your editor, The
Vim Way&trade; prescribes other, more powerful tools to get around.
{: .leader }

This post describes navigating through a set of files using the `:find` and `gf`
commands. Vim also supports tag-based navigation and project-wide search
operations out of the box; and with plugins you can add fuzzy file finding and
more. But these basics go a long way in helping you navigate your project all
from Vim.

## Finding project files by name

The simplest way to open a file in Vim is by using the `:edit` command, which
takes a path to a file. But even with tab-completion, typing out full paths is
cumbersome. Vim’s answer is the `:find` command, which allows us to recursively
search our project directory for a file by its filename. You can usually
autocomplete the filename you are looking for after entering a few characters.

The `:find` command uses the `path` option to determine where to look for
results. The `path` option is a list of directories or glob patterns Vim should
consider; it defaults to `.,/usr/include,,`. The  `.` makes Vim consider all
files in the current directory, while the empty option (`,,`) tells vim to
consider paths relative to the current directory. You can inspect the current
value of `path` like so:

    :set path?

In a Ruby project you would typically alter the `path` option to recursively
include the `lib` and `spec` (or `test`) directories:

    :set path+=lib/**,spec/**

For Rails projects, you would want to include the `app` directory, but if you
are using [Rails.vim][], that is already taken care of for you. Rails.vim’s
`:Emodel` and `:Scontroller` commands are also implemented as wrappers around
`:find`: they basically map to `:find app/models/` and `:sfind
app/controllers/`, respectively.

The `:find` command does not work like a fuzzy finder like [CommandT][] or
[CtrlP][], but it handles most of the reasons why you would want to use such
plugins. See `:help find` for more information.

## Jumping to file under cursor

When editing source code, you can use the `gf` command to jump to the file under
the cursor. That means that when you position your cursor on a path to a file in
your source code, pressing `gf` will open that path. That is moderately useful,
but it becomes better with the use of a couple of options that you can tweak:

* when the current word is not an exact path to an existing file, Vim will look
  for a file by that name in all locations in your `path` option (see `:help
  path`);
* when the file still can’t be found, Vim will try to suffix the word under
  cursor with any of the suffixes listed in the `suffixesadd` option. For Ruby
  files, you could add `.rb` to this list: `:set suffixesadd+=.rb` (see `:help
  suffixesadd`);
* finally, Vim will try to apply the expression in the `includeexpr` option to
  the word under cursor to transform it into something more appropriate, such
  as replacing `.` with `/` in Java source code (see
  `:help includeexpr`).

There are a few tricks you can pull with `gf`-related commands:

* Use `gF` to jump to a specific line number in the file. The line number should
  come after the current word. For example, pressing `gf` on
  `lib/my_gem/foo.rb:30` would open up `lib/my_gem/foo.rb`, while `gF` would
  open that same file and jump straight to line 30.
* Use `CTRL-W_f` or `CTRL-W_CTRL-F` to open the file under cursor like `gf`, but
  do so in a new split window.
* When the file under your cursor does not yet exist, you can create a new file
  with that name using `:edit <cfile>`.

## Customising default settings

Most of these settings have sensible defaults in stock Vim distributions. For
example, the core Ruby plugin provides the following settings:

    :set suffixesadd?
    # => .rb
    :set includeexpr?
    # => substitute(substitute(v:fname,'::','/','g'),'$','.rb','')

There is value in tweaking these. For example, we could adapt the `includeexpr`
option to allow Vim to directly open up the appropriate file when we press `gf`
on a class name by converting CamelCase words to snake_case:

    :set includeexpr=substitute(substitute(substitute(v:fname,'::','/','g'),'$','.rb',''),'\(\<\u\l\+\|\l\+\)\(\u\)','\l\1_\l\2','g')

Granted, this is a horrible one-liner with three substitution operations and a
terribly escaped regular expression — but it does let us position our cursor on
the word `ApiClient` and jump straight to `lib/my_gem/api_client.rb` with `gf`
which is pretty neat. Of course, jumping to class and method definitions is
typically a use case for tags (see `:help tags`) — but there is a slight
conceptual difference between jumping to a file with a certain name, and to the
definition of a class. Use it!

Rails.vim also uses this method to open `app/views/posts/_post.html.erb` by
pressing `gf` on a `<%= render @post %>` line in a view -- demonstrating how
you can do some advanced stuff by [using a Vimscript function for the
`includeexpr`
option](https://github.com/tpope/vim-rails/blob/master/autoload/rails.vim#L2235).

## Moving back and forth

Of course, with all the jumping around between files it can be nice to navigate
back and forth through different locations much like we use the back and forward
buttons in a web browser. Vim has got us covered with the jumplist movement
commands. We move backwards and forwards through our history of locations in
individual and across multiple files using the `CTRL-O` and `CTLR-I` commands.
See `:help jumplist` for more information.

## Refer to the documentation

Remember, Vim’s documentation is very good, descriptive and exhaustive. It
contains everything you need to know about these commands, options — and the
some. It’s easiest to read it straight from Vim through `:help`, but the
contents are also available online:

* [:find][]
* [:sfind][]
* [:tags][]
* [path][]
* [includeexpr][]
* [suffixesadd][]
* [isfname][]
* [jumplist][]

[:find]: http://vimdoc.sourceforge.net/htmldoc/editing.html#:find
[:sfind]: http://vimdoc.sourceforge.net/htmldoc/windows.html#:sfind
[path]: http://vimdoc.sourceforge.net/htmldoc/options.html#'path'
[includeexpr]: http://vimdoc.sourceforge.net/htmldoc/options.html#'includeexpr'
[suffixesadd]: http://vimdoc.sourceforge.net/htmldoc/options.html#'suffixesadd'
[isfname]: http://vimdoc.sourceforge.net/htmldoc/options.html#'isfname'
[jumplist]: http://vimdoc.sourceforge.net/htmldoc/motion.html#jumplist
[:tags]: http://vimdoc.sourceforge.net/htmldoc/tagsrch.html#:tags
[NERDTree]: http://www.vim.org/scripts/script.php?script_id=1658
[CommandT]: http://www.vim.org/scripts/script.php?script_id=3025
[CtrlP]: http://www.vim.org/scripts/script.php?script_id=3736
[Rails.vim]: http://www.vim.org/scripts/script.php?script_id=1567
