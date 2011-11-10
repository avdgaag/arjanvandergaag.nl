---
created_at: 2010-03-18
tags:
  - development
  - subversion
  - zsh
kind: article
title: ZSH arguments-fu
---
When using Subversion from the command-line I commonly do:

{: .sh }
    svn copy ^/myproject/branches/FB-branch1 \
             ^/myproject/branches/FB-branch2
    svn switch ^/myproject/branches/FB-branch2

This is a lot of typing. One way of working around this [a wrapper around `svn` to automate these patterns](https://github.com/avdgaag/subcheat "Look at my project at Github"), but another is using shell power. I use zsh, but bash and others can do the same with slightly different syntax:

{: .sh }
    svn copy ^/myproject/branches/FB-branch1 \
             ^/myproject/branches/FB-branch2
    svn switch !!:3

Here `!!:3` is the third argument of the last command. Neat!
