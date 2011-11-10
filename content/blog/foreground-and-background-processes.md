---
title: Taking advantage of foreground and background processes
kind: article
created_at: 2011-11-10 12:00
tags: [unix]
tldr: You can simplify your development environment using background processes in a unix-like environment.
---
As a developer I spend a lot of time in the terminal, mostly using tabs to multitask. But it turns out you can speed up your work flow using the native multitasking capabilities of unix-like systems. I may be late to the party here, but it's awesome nonetheless.
{: .leader }

Here's an example: when I am working on a Rails project, I often have various processes running: a simple web server[^1] to quickly inspect my work, [Spork][] for autoloading my Rails environment and speeding up my tests, [Guard][] for watching for file changes and running related tests, a console for running Git and Rake commands and -- of course -- an instance of Vim.[^2]

## Switching between two processes

I often use multiple tabs using multiple sessions at the same time to run all this stuff, and switch tabs to switch between them, but this can be quite annoying. The first step is _suspend_ active processes in a console session using `^Z`. For example, when in Vim, hitting `^Z` will bring you back to the console. You can mess around and then jump back to Vim using `fg`.

This works great when switching between two processes, but you can do better. You can start en suspend multiple processes, and using `jobs` you can list what's running. You can jump back to processes by number using `%1`, `%2` etc.

    $ rails server
    ^Z
    zsh: suspended  rails server
    $ vim Gemfile
    ^Z
    zsh: suspended vim Gemfile
    $ jobs
    [1]: - suspended vim Gemfile
    [2]: - suspended rails server
    $ %2
    [2]  - continued rails server

## Background processes

You will notice that when the `rails server` process is running, you can no longer use the console. In order to get back the command prompt, you would need to suspend or quit the process. But it turns out, you can move it to the background using `bg`:

    [2]  - continued rails server
    ^Z
    $ bg %2
    $

Now the process is still running and when it generates output, you will still see it -- but in the meantime you can continue working. We can even launch a process straight into the background by suffixing it with a `&`:

    $ rails server &
    $

## Example uses

I especially find it useful to launch Spork in the background and Vim in the foreground. I then map a special keyboard shortcut to test the current file, like so: `:map <leader>r :!bundle exec rspec %<cr>`. Or, when I develop static sites with [Nanoc][], it is great to launch a server to the background with `nanoc view &` and then bind a key in Vim to recompile the site, like `:map <leader>r :!bundle exec nanoc co<cr>`. This kind of friction reduction is great when doing TDD, and you should give it a try

## Caveats

Of course, you don't really want the output of all your processes clutter up your single terminal window, but for simple tasks this is an ideal way to keep things neat and tidy. 

[Nanoc]: http://nanoc.stoneship.org
[Spork]: http://spork.rubyforge.org
[Guard]: https://github.com/guard/guard

[^1]: I do often use Pow as my local server, eliminating the need to launch my own using `rails server`.
[^2]: sometimes I use MacVim, sometimes plain old Vim in the terminal.
