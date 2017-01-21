---
created_at: 2010-6-30 11:20
tags:
  - subversion
kind: article
title: Modifying Subversion commit messages
---
Sometimes when I try to quickly repeat my last command in the terminal, I end up firing off a `svn commit`. Unlike with Git, you cannot modify commits in Subversion, but you _can_ modify a revision’s properties — like the log message.

Here’s how:

{: .sh }
    svn propedit --revprop -r 1232 svn:log

This will open your `$EDITOR` and it lets you edit the log message for the specified commit (`1232`).

**Note**: in order to make this work, you repository needs to be configured correctly. This means you should rename `/path/to/your/repo/hooks/pre-revprop-change.tmpl` to `/path/to/your/repo/hooks/pre-revprop-change` and `chmod +x` it.
