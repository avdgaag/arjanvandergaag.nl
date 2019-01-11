---
tags:
  - code
  - git
created_at: 2009-07-2 15:39
kind: article
title: Using git stash branch
---
When using Git I sometimes end up with a bunch of changes that would really be better off in a feature branch. Here's a quick way to take those changes in your working copy and start a feature branch quickly:

{: .sh }
    git stash
    git stash branch my_branch_title

From [the docs on `git stash branch`](http://www.kernel.org/pub/software/scm/git/docs/git-stash.html):

> Creates and checks out a new branch named &lt;branchname&gt; starting from the commit at which the &lt;stash&gt; was originally created, applies the changes recorded in &lt;stash&gt; to the new working tree and index, then drops the &lt;stash&gt; if that completes successfully. When no &lt;stash&gt; is given, applies the latest one.

Awesome.
