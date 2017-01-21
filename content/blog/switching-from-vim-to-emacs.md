---
title: Switching from Vim to Emacs
kind: article
created_at: 2015-09-08 21:00
tags: [vim, emacs, programming]
---
Recently I decided to switch from Vim to Emacs as my primary text editor. It took a little time and effort to get used to a new tool used as frequently and intensively as an editor. Here’s how I made the switch.
{: .leader }

Advanced text editors can have a steep learning curve, so it pays to invest in learning to use it well. I find this to be both personally rewarding and a dangerous to learning and innovation: a form of editor Stockholm syndrome might make you blind to your current setup’s faults and overestimate its strengths. As with programming languages, human languages, keyboard layouts and many other subjects, stepping out of your comfort zone and **learning something new can be quite fun**, inspiring and challenging.

## My Text Editor Shopping list

I’ve tried switching from Vim to Emacs before, unsuccessfully. This time, rather than just dumping in, I got it to stick with a plan: I drew up a list of what my editor should do, I researched how to do it with Emacs, and I arranged my setup as such. 

This is roughly the shopping list I made before switching:

* **fuzzy file finder** for quickly jumping to files in a project using a exact or regular expression-like string matching;
* **contextual navigation** to navigate project files from source code (such as opening files from a Ruby `require` statement) or by role (such as opening a Rails controller by name);
* **test framework integration** to run one or more tests and provide feedback on the results;
* **language-aware editing** so you can navigate code by method or class, and edit with automatic indenting and syntax highlighting;
* **inline feedback** about code style, compilation, errors or test results;
* **multiple cursors** for applying the same edit operations on multiple locations;
* **unix integration** so the editor can connect to standard input and output of regular command-line utilities;
* **programmable** so it can be made to do non-standard things;
* **split windows** so you can work with multiple files side-by-side;
* **type once** to increase efficiency, for example by using macros, templates, snippets and auto-completion;
* **VCS integration** for quickly inspecting changes, crafting commits and dealing with merge conflicts.

Some of this stuff is standard in most decent code editors, but I knew I had to find solutions that worked for me in these areas to be able to make the switch really work.

## Notable settings and packages

I found some good packages to check off some of the items on my list. In no particular order, here’s what I use:

* [projectile][] for project navigation and automation;
* [projectile-rails][] for Rails-specific settings and automation;
* [Alchemist][] for Elixir automation, completion and inline documentation;
* [rspec-mode][] for Rspec-specific automation;
* [multiple-cursors][] for, well, multiple cursors;
* [magit][] for VCS integration
* [flycheck][] for inline feedback on code;
* [yasnippet][] for snippets
* [company][] for autocompletion

Emacs also comes with fine out-of-the-box support for:

* split windows
* shell integration
* language-aware editing
* programmability

I researched these options and packages mostly by trying out some of the complete configurations for Emacs that are available, such as [prelude][] and [spacemacs][]. Once you get a feel what’s possible, you can erase it all and start building your own, custom configuration. You can find mine in [my dotfiles at Github][dotfiles].

## Pros and cons

After a couple of weeks of working with Emacs, I think I can draw up a list of what I do and do not like about it. First, the  bad things:

* Emacs is slow to start. There’s a daemon version you can connect to with `emacsclient` but that’s exactly the kind of stockholm-syndrome solution I was referring to earlier.
* It comes with a lot of features, making it hard to learn and understand. Even its help system takes some time to learn.
* Emacs is harder to use in a terminal compared to the GUI version, since in the GUI it is easier make advanced keybindings work — which you _need_ without Vim’s modal editing.
* Most keybindings are plain horrible (`C-u 10 C-x {` anyone?) compared to the speed and elegance of Vim’s modal editing.
* It’s not exactly pretty compared to newer GUI editors, such as Atom.
* Emacs is not as good at _editing text_ as Vim is: there’s a lot more _work_ and repeated key presses involved.

But here’s the stuff I _do_ like:

### Extensibility

Emacs is extensible with a decent programming language (a special flavour of Lisp). That means that I can make it do what I want it to do, but also that its plugins can have a lot more power than in other editors. [Magit][] and [evil-mode][] are good examples of the level of customisation that Emacs allows.
Also, Emacs comes with a built-in package manager for plugins, which has worked fine for me so far.

### Implement all the features

Emacs feels more like an IDE than Vim. Vim is built to be used as little as possible, so it’s fast and delegates as much as possible to regular shell programs. Emacs is designed to be used as much as possible, and comes with a shell built in so you hardly ever need to switch away from it. This makes for a nicely integrated experience, such as with [Alchemist][] for Elixir. Also, with Emacs, I have no need for Tmux for asynchronous tasks like I do with Vim.

Emacs can do a lot of stuff; you don’t need all of it every day, but it’s great that it’s there when you do need it. One such example is `C-M-T` to switch two words or arguments. Another one that I find surprisingly useful is the ability to connect to a database and have a SQL prompt right there in your editor.

### Getting started

It’s easier to start with Emacs than with Vim, with its modal editing — although I bet Emacs is harder to master than Vim is. It seems to require much less initial configuration than Vim to get something workable, even though you do have to learn lisp first.

### Undecided about Evil-mode

I decided not to use evil mode (basically Vim in Emacs) so I could go all-in on Emacs. At the moment though, I’m still contemplating adding it to my setup because Vim’s modal editing is just so nice and speedy. But overall, I’m quite satisfied with my new workflow of running Emacs all day everyday, rather than juggling Vim instances and shells in Tmux panes.

## Conclusion

Switching editors has been fun and inspiring so far, and I expect to learn much more as I go forward. Emacs has surprised in some regards, and disappointed in others — as was to be expected. You should definitely switch to Emacs if you like tinkering with your setup and integration with your tools. If editing speed is your thing, stick with Vim. But definitely try them both — if only for a fun challenge!

[Alchemist]: http://www.alchemist-elixir.org
[projectile]: https://github.com/bbatsov/projectile
[projectile-rails]: https://github.com/asok/projectile-rails
[Magit]: http://magit.vc
[dotfiles]: https://github.com/avdgaag/dotfiles
[evil-mode]: https://bitbucket.org/lyro/evil/wiki/Home
[rspec-mode]: https://github.com/pezra/rspec-mode
[multiple-cursors]: https://github.com/magnars/multiple-cursors.el
[flycheck]: http://www.flycheck.org
[yasnippet]: https://github.com/capitaomorte/yasnippet
[company]: http://company-mode.github.io
[prelude]: https://github.com/bbatsov/prelude
[spacemacs]: https://github.com/syl20bnr/spacemacs