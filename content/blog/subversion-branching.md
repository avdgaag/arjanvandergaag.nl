---
created_at: 2009-09-8 11:28
tags:
  - code
  - subversion
kind: article
title: Subversion branching
---
The main reason why developers should use Git for versioning is cheap, cheap branching. But in Subversion it isn't _so_ hard that you shouldn't use it. Here's a basic bugfix branch workflow. First, create your branch:

{: .sh }
    svn copy /path/trunk\
             /path/branches/my-new-branch\
             -m "Create my new branch"
    svn switch /path/branches/my-new-branch

Of course, `/path/` is easy enough to find:

{: .sh }
    svn info | grep URL

Hack away, make some commits, and when you are ready to merge to branch back into trunk:

{: .sh }
    # Note the revision that started this branch
    # assume this tells you '2362'
    svn log --stop-on-copy

    # Get back to trunk and merge in your changes
    svn switch /path/trunk
    svn merge -r 2362:HEAD /path/branches/my-new-branch

Inspect your changes, resolve conflicts and make sure everything is alright. Commit your changes…

{: .sh }
    svn commit -m "Merge in branch 'my new branch'"

…and then clean up after yourself:

{: .sh }
    svn delete /path/branches/my-new-branch\
               -m "Remove obsolete branch"

The trick is knowing where your branch started. You can note the revision number when you create the branch, or use `svn log` to find out.

**Beware of changes to `trunk` before merging in your branch**. If `trunk` has changed since you created your branch (and chances are it has) you should first merge those changes back into your branch, so it stays in sync.

Newer versions of Subversion should make this process a little easier, but this works. Be sure to check out [the Subversion manual on branching patterns](http://svnbook.red-bean.com/en/1.5/svn.branchmerge.commonpatterns.html#svn.branchmerge.commonpatterns.feature "Common Branching Patterns").
