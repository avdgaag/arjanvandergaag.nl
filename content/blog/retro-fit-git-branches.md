---
title: Retro-fitting Git branches
kind: article
created_at: 2011-10-18 12:00
tags: [git]
tldr: Git allows you to apply branches in your unshared commit history.
---
Every now and then I am making a series of commits in a Git project, when I realise that my current work would be better suited for a feature branch. As long as I have not yet shared my commits with co-workers, I can safely retro-fit a feature branch.
{:.leader}

Say I am developing a simple application. I have made a few commits. Assume the following Git history:

    O [master, origin/master, HEAD] added license
    O added readme
    O initial commit

Then, I go on a hacking spree:

    O [master, HEAD] customized to_param method
    O created stub spec
    O added migration
    O generated model
    O [origin/master] added license
    O added readme
    O initial commit

It strikes me that all my work on a new model could have benefitted from being on a feature branch called `new-model`. If only I hadn’t comitted to `master`...

As it turns out, we can retro-actively create a feature branch for this range of commits!

### The easy way

Because Git branches are just *pointers to commits*, it is easy enough to make our current commit the tip of a new branch:

    git branch new-model

Our history now looks like this:

    O [master, new-model, HEAD] customized to_param method
    O created stub spec
    O added migration
    O generated model
    O [origin/master] added license
    O added readme
    O initial commit

Note the new branch name on our latest commit. Our current repository state is now the tip of both the `master` and `new-model` branches. We're halfway there. Now, we want our `master` branch to no longer include our last few commits.

The way to do this is less obvious, but simple nonetheless:

    git reset --hard origin/master

The `reset` subcommand resets the working copy to an earlier state, defaulting to `HEAD` but optionally to any ref (i.e. commit). Here, it was simply `origin/master`, but it might as well have been `2ab83ec3` or `HEAD~3`.

Now, our repository looks as follows:

    O [new-model] customized to_param method
    O created stub spec
    O added migration
    O generated model
    O [origin/master, master, HEAD] added license
    O added readme
    O initial commit

Our `master` branch is now back at the same commit as `origin/master` and no longer includes my latest commits. Now, we can simply `git checkout new-model` to continue our work on the new feature branch, or stay on `master` and work on something else.

## A slightly harder way

The key step in the first example is that you reset the `master` branch to an older commit. The newer commits did not get 'lost' because they belonged to another branch. But what would happen if you had not created that new branch?

You might think your new commits were gone, as your history would have looked like this:

    O [origin/master, master, HEAD] added license
    O added readme
    O initial commit

Your commits are no longer listed. That is because they are no longer included in the history of any branch — _but they are still there_[^1], and you would still be able to create a new branch _if only you knew the exact commit hash_ you would like it to point to:

    git branch new-model [sha]

How would you find that commit hash, now it no longer appears in the logs? You can use the `reflog` to inspect your recent changes:

    67a09d8... HEAD@{0}: reset --hard HEAD^: updating HEAD
    a3100ce... HEAD@{1}: commit: customized to_param method
    8bf0929... HEAD@{2}: commit: created stub spec
    09d7a98... HEAD@{3}: commit: added migration
    ...

The `reflog` subcommand gives you a list of actions that were performed on the repo. It tells you the hash of the commit you were looking for (the second line), so you can do:

    git branch new-model a3100ce

…and you're in the same situation as in the first example. 

## The hard way

So far, the situation has been straight forward. But let's look at a situation where not all your recent commits belong in the new feature branch. Assume I had created one more commit:

    O [master] added Gemfile
    O customized to_param method
    O created stub spec
    O added migration
    O generated model
    O [origin/master, HEAD] added license
    O added readme
    O initial commit

In is case, I don't want the most recent commit on my new feature branch. What I want is this:

    O [master, HEAD] added Gemfile
    | O [new-model] customized to_param method
    | O created stub spec
    | O added migration
    | O generated model
    |/
    O [origin/master] added license
    O added readme
    O initial commit

I would plan it as follows:

* create the `new-model` branch as before
* create a temporary branch at the same spot as `master`
* reset `master` to `origin/master`
* merge the temporary branch into `master`

Here's how I'd do it:

    git branch temp
    git branch new-model HEAD^
    git reset --hard origin/master
    git merge temp
    git branch -d temp

The basic concepts at work here are the same, only this time, merging is added to the mix. 

With Git, there is always more than one way to skin a cat, and with a basic understanding of the Git object model and a couple of basic commands, you'll probably find a way to get things done soon enough.

[^1]: do note that lost commits will not stay around forever — Git will occassionally clean up the reflog and remove unused commits.
