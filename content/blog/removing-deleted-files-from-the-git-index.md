---
tags:
  - code
  - git
created_at: 2009-08-17 2:03
kind: article
title: Removing deleted files from the Git index
---
When working with Git it can be cumbersome to have to remove files from the index (marking them deleted rahter missing) if you did not delete them using `git-rm`. Here's bash one-liner for that:

{: .sh }
    git rm $(git ls-files -d)

What that does is use `ls-files -d` to list all files in the project that are deleted from the file system, and apply the `rm` command to those paths to delete them from the git index.

I've got that aliased to `grd` (Git Remove Deleted).