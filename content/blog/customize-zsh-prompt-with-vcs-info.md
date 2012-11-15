---
title: Customize your ZSH prompt with vcs_info
kind: article
created_at: 2011-12-23 08:00
tags: [Git, ZSH, vcs_info]
tldr: Use the ZSH built-in library vcs_info to display version control information in your prompt.
---
You're not cool if you're don't display some Git status information in your prompt. If you use [ZSH][] -- and you _should_ -- it's quite easy to customize your prompt. ZSH comes with a nice package [`vcs_info`][vcs_info] that provides almost all the information you need.
{: .leader }

`vcs_info` is a function that populates a variable for you. This variable can then be used inside your prompt to print information. What information is printed can be controlled by some configurations -- which are essentially format strings.

## Set up

Assuming you are using ZSH, setting things up is easy enough:

1. Enable `vcs_info`.
2. Call it in a pre-command.
3. Include the variable in your prompt.

To do so, modify your `~/.zshrc`:

    autoload -Uz vcs_info
    zstyle ':vcs_info:*' enable git svn
    precmd() {
        vcs_info
    }

Then, include the output variable in your prompt:

    setopt prompt_subst
    PROMPT='${vcs_info_msg_0_}%# '

This example is a rather minimalist prompt, so make sure you customize it with additional information.

## Configuring `vcs_info`

There's not too much documentation on `vcs_info` available, but [the official docs][vcs_info] got enough to get you going. The defaults should be fine, but we wouldn't be using ZSH and reading articles about `vcs_info` if we were satisfied with defaults, would we?


### Format string

First, set the general format string of your `vcs_info_msg_0` variable:

    zstyle ':vcs_info:git*' formats "%{$fg[grey]%}%s %{$reset_color%}%r/%S%{$fg[grey]%} %{$fg[blue]%}%b%{$reset_color%}%m%u%c%{$reset_color%} "

This is, admittedly, a little hairy. Let's remove the color codes:

    zstyle ':vcs_info:git*' formats "%s  %r/%S %b %m%u%c "

That's a lot clearer. This would look like this:

    git my_project/. master %

This prompt includes:

`%s`
: The current version control system, like `git` or `svn`.

`%r`
: The name of the root directory of the repository

`%S`
: The current path relative to the repository root directory

`%b`
: Branch information, like `master`

`%m`
: In case of Git, show information about stashes

`%u`
: Show unstaged changes in the repository

`%c`
: Show staged changes in the repository

There's a special format string for 'actions' -- which in practice means a special format for when Git is currently performing a merge or rebase. Mine is identical to the normal format, but with the action string added:

    zstyle ':vcs_info:git*' formats "%s  %r/%S %b (%a) %m%u%c "

Which would result in something like:

    git my_project/. master (rebase) %

This is all I need, although some people do write their own functions to display how many commits the current branch is ahead or behind its remote. Knock yourself out if you're so inclined.

### Flags

There are also a couple of flags you can set to influence the `vcs_info`'s behaviour:

`check-for-changes`
: Disabled by default because it might slow things down, it tell the back-end to check for working-copy changes and staged changes. Enable it with `zstyle ':vcs_info:*' check-for-changes true` if you want to use the `%c` and `%u` sequences.

`enable`
: List the versioning systems to enable. In the example above, I have enable Git and Subversion, but there's many more -- notably Mercurial.

The `vcs_info` format string, especially with lots of color codes, is not all that readable, but I nonetheless prefer using a ZSH library over hacking together my own functions that parse the output of various Git commands.

[vcs_info]: http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#Version-Control-Information
[ZSH]: http://www.zsh.org
