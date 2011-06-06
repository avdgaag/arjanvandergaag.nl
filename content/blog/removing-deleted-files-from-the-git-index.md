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


I've got that aliased to `grd` (Git Remove Deleted).