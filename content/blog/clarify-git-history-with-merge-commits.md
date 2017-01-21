---
title:      Clarify your Git history with merge commits
kind:       article
created_at: 2011-12-06 20:00
tags:       [git]
tldr:
  Omit them needless merge commits. Add them to convey information.
---
The Git history is supposed to help you understand what has happened over time
in your project. In practice, _how_ stuff happened tends to obscure _what_
happened. Here are two tips for Git merges to help keep your history clean.
{: .leader }

## Do not create redundant merge commits

Suppose you are working on a branch with a colleague, be it `master` or some
feature branch. You make some commits in your local repository:

    O [master, HEAD] Added comments to post
    O Added comment model
    O [origin/master] Created post model
    O Initial commit

Your colleague has also made some in his local repository, and pushed them:

    O [origin/master, master] Added author to post
    O Created user model
    O Created post model
    O Initial commit

When you want to push your changes, Git will reject the non-fast forward merge.
So you pull the remote changes, which will merge `origin/master` into your
local `master` branch. Although you can now safely push your changes, you end
up with the following history:

    O [origin/master, master, HEAD] Merge branch 'master' of remote-repo.git
    |\
    O | Added comments to post
    O | Added comment model
    | O  Added author to post
    | O Created user model
    |/
    O Created post model
    O Initial commit

This makes it seem there are two different branches of development here, while
actually this would have worked fine as a single linear history. This would
have been the result had Git used `rebase` rather than `merge` to combine the
remote and local commits. Simply use:

    git pull --rebase

...and it shall be done. Here's what happens under the hood:

1. `reset` your `master` branch back to `origin/master`
2. `fetch` new commits from the remote `master` branch
3. fast-forward `master` to `origin/master`
2. replay all your original commits on the new `master` branch

This gives you:

    O [master, HEAD] Added comments to post
    O Added comment model
    O [origin/master] Added author to post
    O Created user model
    O Created post model
    O Initial commit

So now you can safely `push` your changes and be all in sync again. The history
now demonstrates all these commits were all part of a single feature.

This behaviour is usually what you want to do, so you might want to make it
default:

    git config branch.autosetuprebase always

This will 'always' set up remote tracking branches to pull using `--rebase`.
There are more options though, so make sure to read the docs (`man git-config`):

> When never, rebase is never automatically set to true. When local, rebase
> is set to true for tracked branches of other local branches. When remote,
> rebase is set to true for tracked branches of remote-tracking branches.
> When always, rebase will be set to true for all tracking branches.

## Do create redundant merge commits

Usually, Git prefers to create a linear history, as usually that's neat. But
when you develop your project with feature branches, and you want to look back
through your history to study what features are included, when and by whom, you
will have to start parsing a lot of commit dates, authors and log messages.

Suppose the following history, where you have added commenting to a post model
in a feature branch called `comments`:

    O [comments, HEAD] Added comments to post
    O Added comment model
    O [master] Added author to post
    O Created user model
    O Created post model
    O Initial commit

You're done and you want to merge the changes back into `master`

    git checkout master
    git merge comments

This will give you:

    O [comments, master, HEAD] Added comments to post
    O Added comment model
    O Added author to post
    O Created user model
    O Created post model
    O Initial commit

Git figured out it only had to move the "master" pointer to point at the same
commit as "comments" does -- a fast-forward merge. This is neat, but you lose
the information that the last two commits were a stand-alone feature. You want
to instruct Git to not perform a fast-forward merge, but create an explicit
merge commit:

    git checkout master
    git merge --no-ff comments

This gives you:

    O [master, HEAD] Merge branch 'comments'
    |\
    | O [comments] Added comments to post
    | O Added comment model
    |/
    O Added author to post
    O Created user model
    O Created post model
    O Initial commit

You could now remove the `comments` branch (`git branch -d comments`) and push
your commits.

If you like the `--no-ff` behaviour, you might want to configure Git (version
1.7.6 and later) to use it by default (although I personally don't do that):

    git config --add merge.ff false

Although the end result is more noisy, it does convey useful information: both
that there was a group of related commits that constitute a feature; and what
it was named. You might even consider not immediately creating a commit, and
adjusting the commit message:

    git checkout master
    git merge --no-ff --no-commit comments
    git commit -m "User story #2831: As\
    a visitor I can comment on posts"

## Conclusion

Git merge commits can both clutter your history or help structure it. Create
them to indicate groups of related commits; omit them to avoid the illusion of
unrelated commits.
