---
title: Fuzzy-find all the things with Selecta
tags:
  - unix
  - shell scripting
created_at: 2013-10-29 12:00
kind: article
---
[Selecta][1] is a nice new Ruby script by Gary Bernhardt that does one thing and does it well: provide fuzzy finder functionality in your terminal. It is surprisingly useful.
{: .leader }

So we're all familiar with `⌘T` in TextMate and its many clones: hit a shortcut to get a prompt, where you can start typing to find files in your current project. Hit enter on the selected item, and you open that file.

Selecta extracts the fuzzy matching part into its own utility, leaving whatever you are selecting from and whatever you do with what gets selected, up to you. Here's a couple of use cases for fuzzy matching I found useful.

## 1. Git branches

When you have a bunch of branches in your Git repository, make switching between them easier using a shell alias:

    git branch --all --remotes | cut -c 3- | rev | cut -d "/" -f 1 | rev | selecta | xargs git checkout

## 2. Terminal-based fuzzy file finder

Rather than launching Vim and using a fuzzy file finder plugin to open files, jump straight to the file you are interested in:

    vim `find . -type f -name '*.rb' | selecta`

## 3. Attach to Tmux session

When you start a Tmux session per project you are working on, doing the `tmux ls` and `tmux attach` routine is tiring. Do it in one go:

    tmux attach -t `tmux ls | selecta | cut -f1 -d:`

## 4. Kill a process

Look up a process PID and kill it straight away:

    kill `ps aux | selecta | awk '{print $2 }'`

## 5. Pick a Rake task to run

A trivial Rails app has a lot of Rake tasks you can run. If you find yourself forgetting their names, pick one from a list:

    rake `rake -T | selecta | cut -f2 -d' '`

[1]: https://github.com/garybernhardt/selecta
