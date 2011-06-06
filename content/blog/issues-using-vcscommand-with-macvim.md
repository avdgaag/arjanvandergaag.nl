---
created_at: 2010-05-26 11:41
tags:
  - osx
  - macvim
  - subversion
  - vim
kind: article
title: Issues using VCSCommand with MacVim
---
I tried to use the [VCSCommand][1]-plugin for Vim the other day, but I ran into a strange issue: the plugin tried to use an _older_ version of subversion with my working copy, resulting in "this client is too old" error messages.

## The setup

I've got two copies of Subversion installed on my system: the default that comes with Mac OS X (1.4.4) and the one I manually installed (1.6.9). I have set my `$PATH` so that 1.6.9 (in `/opt/subversion/bin`) gets precedence over 1.4.4 (in `/usr/bin`). It all works fine from the command line.

## The problem

I am using [MacVim][2], which is very nice, but it apparently doesn't know about my 1.6.9 installation and complains. It appears (from running `:!which svn` in MacVim) that MacVim (or so it seems any OS X app) ignores my `$PATH` adjustments in `.bash_profile`. Hence it is unaware of the `/opt/subversion/bin/svn` executable.

## The fix

I tried adding a file with the extra location to the `/etc/paths.d` directory, [as per this suggestion][3]. That worked but did not help, as it _appended_ rather _prepended_ the new location to MacVim's `$PATH`. It gave `/usr/bin` precedence over `/opt/subversion/bin`.

I then gave up trying to solve this neatly. Instead I configured the plugin around the issue, which still works rather nicely. I included this line in my `.vimrc` file:

    let VCSCommandSVNExec="/opt/subversion/bin/svn"

This tells the plugin which executable to use. This solution is not very portable (the path to `svn` may very well be different on other machines), but I have not found another way to solve this. Of course I could mess with my Subversion installations, but down that path madness lies, or so I hear. For now, I'm glad I can get on with it.

[1]: http://vim.sourceforge.net/scripts/script.php?script_id=90
[2]: http://code.google.com/p/macvim/
[3]: http://superuser.com/questions/31353/path-in-vim-doesnt-match-terminal