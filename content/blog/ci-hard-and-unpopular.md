---
title: "Continuous Integration: surprisingly hard and unpopular"
kind: article
tags:
  - CI
  - Agile
  - Git
created_at: 2019-03-09 16:00
---
Continuous integration (CI) is a practice in software development where developers check in and merge their code frequently. For a long time I thought that meant: don’t make your commits too big, and have your test suite or build run automatically with something like [Jenkins](https://jenkins.io) or [Travis CI](https://travis-ci.com). It’s so simple, anyone can do it — or so I thought. I was wrong.
{: .leader }

## A common workflow

Here’s a common development workflow:

1. get the latest changes from the shared repository;
2. create a new topic branch;
3. commit to that branch until your work is done;
4. merge your changes back to the mainline.

There might be a code review of your changes, and maybe some conflicts when you merge, but nothing too bad. This is the typical [Github workflow](https://guides.github.com/introduction/flow/). So far, so good.

When you use Git, it’s accepted wisdom to use branches: they’re quick, they’re cheap, and there’s apparently just no reason _not_ to. There are even [elaborate branching models](https://nvie.com/posts/a-successful-git-branching-model/) out there. Again, nothing _inherently_ wrong with that.

## Running into trouble

If you’re on a small team, working in small steps, on a modular codebase, you might not encounter a lot of trouble with this approach. If you’re constantly collaborating with all the other developers anyway, there’s little risk of misalignment.

But in larger teams, with many developers and even many teams, all working in a monolithic codebase, productivity will soon slow to a crawl. You will recognise this by:

* days-long conflict resolution efforts;
* endless interdependencies between works-in-progress;
* weeks of unanticipated extra testing time and rework;
* abandonment of entire initiatives, for which re-integration is no longer economically feasible.

What’s more, these dysfunctions are so demotivating, that a common response from developers trying to salvage some level of productivity is exactly the behaviour that’s problematic in the first place: they isolate their changes, work in bigger chunks, and put off integrating with the rest of the team until the very last moment. It’s a downward spiral of dysfunction disguised as personal productivity, that no amount of small commits in isolated branches is going to break.

Under such conditions, predictability and trust erode quickly. Continuous integration can be your way out.

## What continuous integration means

Continuous integration means developers check in their code into the mainline frequently, making sure the code still builds and the tests still pass. Committing to a topic branch does not cut it and neither does running automated tests in Jenkins on your topic branch. In Git parlance, it means all developers merging their changes back into the `master` branch _at least_ daily, while keeping the build stable. You could still use branching — which is not bad in and of itself — but you’ll merge to master _at least_ daily. You might even consider automatically [deleting all branches nigthly](http://articles.coreyhaines.com/posts/short-lived-branches). The source control-specific practices associated with continuous integration are known as [trunk-based development](https://trunkbaseddevelopment.com).

What this means in practice, is developers working in small steps, committing to master daily, using feature toggles and abstractions to _deploy but not release_ their changes, collaborating with testers on quality control and prioritising code reviews and testing to ensure short lead times. Small steps and not breaking the build, yes—but that’s only the tip of the iceberg.

## Common objections

Implementing a continuous integration workflow leads to surprising amount of resistance. Common objections include:

1. **This feature is too big to integrate frequently**. No it isn’t, you can (almost) always make it smaller.
2. **We can build a small step, but we can’t ship that**. Sure, that’s why you build it using a feature toggle — deploy without releasing.
3. **I keep my branches up to date, so there will be no conflicts**. What you mean to say is: I make sure other people will have to resolve the conflicts I am causing by merging 6 weeks’ worth of commits into `master`.
3. **Using feature toggles takes too much time, we need to deliver this feature quickly**. A few weeks of the entire team testing, resolving conflicts and reworking the feature can save you an hour writing a feature toggle now.
4. **Working in master means I have to keep the software in a working state constantly**. Exactly.
5. **Working in master means I have to constantly take into account what other developers are doing**. Exactly.
6. **That would be disastrous for quality**. This will make it a lot harder to hide quality issues, yes. But, if anything, it will help you _improve_ quality by making it visible and unavoidable to address. 
7. **Merging daily leaves no time for a tester to test the work**. Small changes can be quickly tested, as long as team members collaborate throughout the day and avoid hand-offs between functional specialists.
8. **We have rules, procedures and quality gates that disallow working directly in master**. And that is probably why you have great difficulty to deliver working software.
9. **We can’t do code reviews anymore**. Sure you can, it just means you can’t take days to do it. Besides, code reviews are a poor substitute for pair programming anyway.

More implicitly, I found developers object to continuous integration because the increased opportunities for feedback can be scary, and they lose the ability to work “under the radar” for long stretches of time, where they get to feel secure and (individually) productive. These are serious challenges indeed, but nothing adequate coaching, mentoring and leadership can’t solve. Still, continuous integration does indeed mean putting the interests of the team and the product over that of the individual developer. That will take some getting used to.

Second, managers can be reluctant to abandon the rules and procedures that _protect_ the mainline from the whims of clumsy and incompetent development teams, thereby reversing cause and effect. Also, managers who are responsible for the development teams stand to lose face the most when problems are brought to the surface. It can be tempting to hide and claim “look, we’re already doing Continuous Integration: Jenkins runs our build every night. Individual developers just need to step up their game!” But, to paraphrase Jez Humble, when managers claim that “this will never work here” because of a people problem, they’re usually right — it’s just that they’re wrong about which people are the problem.

## If it hurts, do it more

Continuous integration is a powerful practice to front-load risk and bring quality and communication issues to the surface. It’s harder than it sounds, as it will most likely bring some painful issues to the surface in larger organisations that were not built from the ground up around a continuous integration workflow. But, as with other agile software development practices, that is exactly the reason why you should press on it with it. Bring pain points to the surface and deal with them.
