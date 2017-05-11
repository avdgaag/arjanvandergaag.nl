---
title: "How to Lead a Team by Doing Nothing"
kind: article
created_at: 2017-05-11 12:00
tags:
    - leadership
    - teams
    - holacracy
    - kanban
---
This is transcript of the talk I did at Agile Manchester 2017, titled How to Lead a Team by Doing Nothing. It has been slightly edited for readability. Talks were not recorded, but [the slides are available on slidedeck][slides]. This was a 45-minute talk and therefore a long read, so I have included a summary opening paragraph.
{: .leader }

## Summary

Kanban calls for leadership on all levels. It provides many of the values to support that, but lacks a practical instruction on how to achieve it. Holacracy provides such a concrete framework. We used roles, consisting of purpose, domain and accountability, te re-organise our team around the work we were doing. That allowed us to iterate on our governance, focus more on strategy and priorities and embrace an experimentation mindset. In a team of independent, purpose-driven software developers, everybody is a leader who translates his particular abstract goals and values into concrete actions for others. As a team leader, you need to adopt a coaching mindset and shut up, letting the team figure it out for themselves.

## The Shrug

I distinctly remember one of my first days at McDonald's, one of my side jobs while I was at university in my early twenties. My manager, let's call him Steve, was training me. He was explaining all the steps involved in assembling an order for a customer. And make no mistake, McDonald's has got this down. They scienced the hell out of it. First get the sauces, then accept the customer's money, then put the cups in the drinks machine, then walk over there to get the fries, then walk over here to get the burgers &mdash; and so on, and so forth. Steve was clearly going to get this training over with as soon as possible.

So I was like any other bratty twenty-something in a side job: I thought I know how to do his job better. I said: "Surely, it's quicker for me to make a single round along the counter, picking up sauces, fries and burgers in one go? It's less walking, less bumping into colleagues and overall just a lot quicker."

Steve gave the slightest of sighs, and explained to me that there was a system to how we did things at McDonald's. It was a series of steps designed to deliver the food, fast. "Please, follow these steps and you'll be fine."

"But I'm pretty sure my way is quicker."

"Look, this is not that hard." Steve slowed down and lowered his voice. He improved his articulation. "This is how we assemble our orders. Please follow the procedure. Everybody else can do it."

I would like to think I would not stand for such a condescending tone. I was surrounded by idiots! Why could he not see that my solution was clearly superior to his? And who did he think he was, anyway? He was only a manager at McDonald's, while _I_ was already in my second year of _university_. The irony of me _also_ working at McDonald's was lost on me, at the time. But as much as I wanted to throw my McDonald's cap to the ground and storm off, I didn't. I said "Sure, Steve. Whatever your want." I shrugged it off.

That shrug was more important than it would seem. Right from the start, I decided I didn't care about my job. I wasn't going to put my creativity or energy into this job. I was just going to be there for the shortest amount of time I could do, putting in the absolute minimum effort I could get away with. And this is a mindset that may work for McDonald's, but is deadly for highly creative and complex environment such as software development.

## Introducing Kanban

Fast-forward to about a year and a half ago, I was asked to take the lead in a team that was struggling a bit. We were a team varying in size between 3 and 6 members, working for an external client. It dawned on me after a couple of weeks that the team was operating in survival mode, the least-mature mode of operation as defined by Roy Osherove in [Elastic Leadership][]. You could tell by constant production errors, frequent escalation of ticket to the highest priority, misunderstandings all around and a general sense of constant firefighting.

At the time I was visiting some conferences and reading some books about Kanban. I had come to the understanding that erasing the word "Scrum" from your Scrum board and replacing it with the word "Kanban" would magically resolve all software development problems, so I introduced the team to Kanban and both we and the client dove right in. We introduced some metrics, WIP-limits, focused on flow, explained our prioritising process and made some great imrovements overall.

But as I was going over some of the core values of Kanban as described by David J. Anderson and Andy Carmichael in [Essential Kanban Condensed][], something didn't feel right. I got how transparency worked, and I could see how understanding and balance were important. I knew how to focus on flow, and how to promote a focus on delivering customer value. But I was unsure about leadership, especially leadership on all levels. The advice is simple: just get yourself a self-organised, cross-functional team. But how do you do that? What is leadership anyway?

I can tell you something that leadership is _not_. My idea of leadership at the time was to delegate. So every day, I would sift through all the incoming e-mails and calls and tickets and questions, and I would tell my team members what to pick up first. Fix this ticket, work on that problem, call the client back on about that thing. I was setting myself up as a bottleneck, not a leader. As it turned out, delegation is not the same thing as micro management.

## Changing how we organised ourselves

At some point, we started to change the way we organised ourselves at our company. It would have a profound effect. Our team got on the bandwagon quickly. But in order to explain what we did, I first have to tell you about another side job I used to have.

### Another job

When I was around 15 or 16, my mom told me to get a job and so I did. I knew a guy who knew a guy who could get me a job at a local snackbar &mdash; the Dutch equivalent of your English fish and chips shop. I showed up on my first day, all green and wide-eyed, not knowing what to expect. My boss, the owner of the place, was rather brief with his introduction: "You're too young to work up front at the counter and the deep fryer. You'll be in the kitchen. It's your job to make sure that the guys in the shop can get their work done. Do whatever it takes to make that happen. Also, I'm relying on you to keep the place clean. Oh, and be on the look out for colleagues who want to take a break or have a drink or anything. They'll be coming into your kitchen. But this place is small, so by all means, if you need to, kick them out. The kitchen is yours." And with that, I could get started. "Go find yourself some onions and a knife and get dicing."

"Where are the onions? And the knives?"

"Dude, this place is smaller than my home kitchen. Just open cupboards until you find it. You'll figure it out."

I'm pretty sure that this entirely different take on getting started at a company and understanding of what was to be expected from me, played a major part in how I experienced these two jobs. Working at McDonald's was a means to make some ends meet as a student; working at the local snackbar was fun, rewarding and something I took pride in &mdash; even though I was "just" dicing onions must of the time. But I knew I was good at my job, because I knew my place. I had purpose, I had accountability and I had a domain.

### Roles: purpose, accountability and domain

We got the team together and tracked what we were doing all day. After a week, we clustered those activities intro groups of related work and summarised these into roles. In a team of about 5 at the time, we had some 15 roles, such as facilitator, customer relationship manager, release manager, security officer, developer, project manager and so forth. Most people had multiple roles; some roles were filled by multiple persons. And all roles consist of the same three components.

Purpose is what tells us what a role is supposed to achieve. It's a dot on the horizon, a direction or a desired high-level outcome. Like in the kitchen, my purpose was to make sure the other guys could get their jobs done. Not "perform this sequence of tasks", but "do whatever it takes to achieve this". For example, our release manager had a purpose along the lines of "regular, worry-free software delivery".

Accountability is "I'm relying on you to keep the place clean". An accountability is an ongoing outcome you need to track, and is a good indication of whether you are doing a good job &mdash; or rather, it would be a good indication of you _not_ doing a good job. For example, we had an accountability in our team for the security officer along the lines of "ensure we comply with our contractual obligations toward the customer regarding information security and privacy."

Domain gives someone exclusive ownership of a particular area or subject, like I had in the kitchen. This is very powerful. For example, we had a role called "Architect" with the domain of "the entire codebase". That meant that the architect was the one to determine what did and did not go into our codebase. This had two effects for us: in the first place, someone got to decide our coding standards and general workflow. The architect could say: under these conditions, team members can commit code to our repository. But it also had a second-order effect of mediation. The Architect clearly had the final say in any discussions that would erupt. The fact that we all knew about, and accepted, this domain, absolved us from many bike-shedding discussions.

## The evolving governance

By implementing the roles based on purpose, domain and accountability, we organised ourselves around the work we were doing. We were no longer just software developers writing code, but we were much more. As it turned out, a lot of work that normally left to the team leader, was now delegated into the team. As it turns out, delegation is not about telling people what to do, it's about giving them the authority to act as they see fit.

And, in line with Kanban's insistence on visualising in order to improve, having our roles written out explicitly allowed us to change them. And we did! Every week we would discuss proposals for improving the way we organised ourselves. We would split up roles, combine roles, add to them or remove from them, or drop roles entirely if they were becoming obsolete. With agile, we like to talk about how we let the architecture of our code evolve feature by feature; what we did is let our governance structure evolve, proposal by proposal.

It wasn't all good, though. One important lesson we learned was that describing how we want to organise ourselves is _not_ the same thing as how we actually organise ourselves. Every now and then, discrepencies would come up between how we should work, and how we actually worked. There was a certain shadow governance underlying our roles, as all team members were under the influence of old habits, formal job titles and an outside world of customers, managers and colleagues who were unaware of or uninterested in how we chose to organise ourselves. It took a lot of explanation, vigilance and a little courage to guard our own governance and get others on board.

## The learning team

With roles based on purpose, domain and accountability, we were starting to get the hang of things. As team leader, I could (and had to) spend more time on strategy, priorities and role fit (ensuring the right people fulfil te right roles).

First up, we embraced science. With science, we defined experiments, gave it a shot and evaluated the results. We reviewed metrics weekly to spot important trends. We set quarterly goals using objectives and key results to focus the team on particular topics, using key results as metrics in our weekly team meetings. But embracing the experiment also came in another form: in our weekly governance meetings, we basically gave everyone a veto for new proposals &mdash; but that came with clear and strict rules on what makes a valid objection. If you can demonstrate a proposal hurts your ability to fulfill one of your roles, you've got a valid objection. If you just think the solution is incomplete, too complex, too simple, not necessary... then it still flies. You can always revert it or improve upon it next week. Everybody knew this, so no one was afraid to suggest changes.

Second, as a learning team, it became more important for us to exchange feedback. We started having regular one on one meetings to discuss how things were going. Along the way I picked up three tips for sharing gret feedback:

1. Be specific: you need examples of behaviour if you want to tell someone they did well or poorly on something.
2. Be positive (at first): don't rush in with the critical comments. Build up a relationship with some trust first, and only _then_ offer critical feedback. Remember that critical feedback usually has a far bigger personal impact than positive feedback has, so keep an appropriate balance.
3. Base it on shared values: especially when giving critical feedback, make sure you link it to shared values that you all defined and agreed upon up front. This is what changes your feedback from just a personal opinion into something with a little more weight, coming from a team leader.

Operating the team for a while like this, exchanging feedback for a while, showed me something that really surprised me: getting things done is hard and does not come naturally to people. I'm one of those GTD junkies that can lose the entire afternoon to reading about productivity hacks, but some people simply dislike to do lists and prefer to keep it all in their heads. That's okay, up to a point, but if you are operating in a self-organised team without anyone telling you what to do, you had better be aware that the team trusts that you prioritise, say "no", give insight in that state of your projects and follow up on your commitments. I have yet to come across someone who can do that without some kind of external system like David Allen's Getting Things Done. GTD is a skill, and you need to develop it.

## The self organised team

With our evolving governance model and processes in place for strategy, priorities and feedback, the team truly became self-organising. This opened up yet another new challenge for the team leader. Rather than teahcing people how a process worked, it now became essential to coach the team in how to use it. This required a coaching mindset.

Coaching is funny subject and it's the closest I have ever come to "one weird trick and you won't believe what happens next". As a coach, you can magic happen just by shutting up. Really, in a meeting or a personal conversation, just don't speak. Let the others speak. Let ideas flow. When you are in a one on one conversation, see what happens if you stay silent. People hate it. Most people can only stand silence for a couple of seconds. There will be an uncontrollable urge to continue talking &mdash; and that's where the magic happens. Shut up and notice how people will talk themselves through their issues, what they find hard about it and how they could resolve it. If you must, you can ask some questions every now and then. The most powerful I have found is "what do you need? What do _you_ need right now in order to solve your own problem?". Using that question helps people come up with their own solutions (that you would never think of) to problems (that you never knew were there) without you telling them what to do (since you have no idea what they're talking about).

And with that, I discovered what leadership was all about. Taking a coaching mindset myself and observering the team follow their individual purposes and values, we noticed that leadership is not about delegation or micro-management, it's about translating something abstract (goals, values, purpose) into concrete actions. And in a self-organising team, we are all leaders to some extent. And I guess that is what was meant by leadership on all levels in the Kanban book.

Of course, the coaching mindset resulted from the conclusion that self-organisation is not just a switch you flip; it's something that requires constant maintenance and vigilance. It's hard, there are old habits, there's an outside world to defend your process against. You do need to keep working on it.

## Conclusion

What we did to introduce roles and how to evolve them, is something we did not come up with ourselves &mdash; and certainly not something _I_ came up with. We used an "operating system for self-organisation" called Holacracy. In this post, I have only scratched the surface of Holacracy, but I do think it is the _essence_: organising yourself around the work you are doing using purpose, domain and accountability. Holacracy has a lot more rules and principles that are very interesting, but do check those out yourselves. It's worth your while, because I think a system like Holacracy is the antidote to the shrug, the not caring, the apathy that is so deadly to creative professions like our own.

But Holacracy is not special. It is just one of many ways of organising yourself. There are some core principles and values that make Holacracy work. Among these are the focus on purpose (to deliver customer value), collaboration of different roles, transparency of how we work, balance of different opinions, the need for respect, the need for leadership... basically, these are all the values we started out with in the first place: the basic Kanban values. I did not understand how to put them to work in the beginning, bu with hindsight, I can see how Kanban and Holacracy (and, I can imagine, any other system for self-organised, continuous improvement) revolve around some of the same core values.

So I believe you too can transform your role in a team from micro-manager to basically doing nothing anymore, as long as you adopt the experiment, translate the abstract into the concrete, visualise how your work and shut up.

[Elastic Leadership]: http://www.elasticleadership.com
[Essential Kanban Condensed]: http://leankanban.com/guide/
[slides]: https://speakerdeck.com/avdgaag/how-to-lead-a-team-by-doing-nothing
