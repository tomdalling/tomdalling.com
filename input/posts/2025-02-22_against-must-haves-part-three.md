{:title "Against Must-Haves (Part Three)"
 :main-image {:uri "/images/posts/bucket-chickens-3.jpg"}
 :tags [:bleet]
 :category :software-processes}

In this, the third and final part of this series, I'm going to present some
recommendations for avoiding the pitfalls covered in the previous two parts.

<!--more-->


## Recap

In [part one][] we:

- looked at what bucketed prioritisation is
- defined "must-haves" as the first, and highest-priority, bucket
- divided people's roles into the rough categories of "builders" and "specifiers"
- demonstrated how the must-have bucket creates perverse incentives for
  specifiers

In [part two][] we:

- told a harrowing but all-too-relatable tale about a software project gone
  wrong, largely due to bucketed prioritisation
- looked at why the fault mostly lies with engineering management
- explained how bucketed prioritisation leads to cherry-picking, which is an
  unnecessarily high-risk approach to software delivery and often makes projects
  go BOOM

[part two]: /blog/software-processes/against-must-haves-part-two/
[part one]: /blog/software-processes/against-must-haves-part-one/

## Tom's Top Ten Tips for Tip-Top Trioritisation

One of the reasons it's taken me so long to write this third part of the series
is that it's easy for this to turn into an article about how to run a software
engineering team properly, which is a topic too massive for me to cover well
in one article. So instead I'm going to structure this as a click-baity top ten
list of tips, which is much easier for me to actually write and publish.

## Tip 1: Stop using buckets

Take your MoSCoW prioritization framework and place it gently but firmly in the
bin. Buckets don't work. Maybe they are OK as a quick way to group things while
brainstorming, but get rid of them before any builders start building.

Instead, you should...

## Tip 2: Give the backlog a linear ordering

If the problems stem from things within each bucket being unprioritised, then
just prioritise all the things. Have one list from highest priority to lowest
priority. And when you have that, what use are buckets?

A linear ordering of upcoming work avoids _so many_ of the common problems
software engineering teams face, and not just problems with prioritisation.

## Tip 3: Prioritise by risk

"Risk" is another very broad concept. It's basically a probably of something bad
happening. There are several different kinds of risk relevant to software
engineering teams, and I think it's a fantastic exercise to learn about all of
them, but I'll narrow it down to just a couple of the most pertinent ones here.

Schedule risk is the risk that you'll run over schedule. You can mitigate this
risk by identifying the things the team is hasn't really put thought into, and
working on them _early_ to get a more accurate understanding of how long they
will take. You don't have to _finish_ them straight away, but you should work on
them until the schedule risk is sufficiently mitigated.

Feasibility risk is the risk that what you want to do is not possible. You can
mitigate this risk by identifying the things that could turn out to be major
blockers for the project, and working on them _early_ to confirm whether or not
the blockers will materialise. These are things that you really want to discover
as early as possible in the project.

Value risk is the risk that customers don't really care about what you're
building, and won't buy/use it when it's released. You can mitigate this risk by
running small experiments and releasing things _early_, to gather evidence that
you're on the right course and make adjustments if necessary.

Other types of risks you should consider during prioritisation, in no particular
order, are: business viability risk, usability risk, brand risk, compliance
risk, operational risk, and security risk.

I could go on forever on this topic, but my general advice is to think of it
this way: if your list of upcoming work is all low risk, then the success of the
project is more-or-less guaranteed. By definition, effectively mitigating risk
means that bad things are unlikely to happen.

By focusing on driving the project into a low-risk state as soon as possible,
one of two things will happen: you'll either mitigate all the major risks and
have a nice easy project to finish off, or you'll discover some kind of
major landmine quickly. Both of these are great outcomes.

## Tip 4: Put it into production immediately

The only way to fully de-risk something is to deploy it to production, release it
to real users, and see it work as intended. There is no environment like
production.

Incrementally delivering real, working software solves so many problems for a
software engineering team. Besides being the ultimate form of de-risking, it goes
a long way towards making stakeholders happy, and giving them confidence in the
team and the success of the project. It makes the relationship between the
builders and the specifiers much smoother.

It's not always possible to go fully into production with every little change,
but that doesn't mean you should give up on the concept. Things like deploying
behind feature flags and staff-only releases are almost as good, and certainly a
lot better than building in isolation.

Releasing is scary. It's when you find out whether you've messed it up. That's
why people's default inclination is usually to build and polish in isolation
for as long as possible, where there are no consequences. This is a mistake,
which takes conscious effort to overcome.

## Tip 5: Give the authority to change the backlog to a single person

Prioritisation is a highly collaborative process, and naturally involves quite a
bit of conflict. Different stakeholders have different needs, aren't really
aware of each others' needs, and typically default to believing that their needs
are more important than everyone else's. Without clear authority given to a
single person, it's like throwing a rotisserie chicken into a pack of hungry
wolves.

Having a linear ordering for the backlog helps a lot here. Nobody can just throw
their request into the "must have" bucket anymore. If someone wants to push in
line and get their work done sooner, they need to start at the top of the
backlog and directly compare their request to the things that have already been
identified as being the highest priorities, and make an argument to the person
with authority as to why this request is more important. This leads to much
better decision making, and also happier, better-informed stakeholders. It's
like... having a park ranger divide up the rotisserie chicken fairly for the
wolves, based on... how hungry each wolf is. I dunno. TODO: better metaphor.

## Tip 6: Don't let the builders cherry-pick

Ordering work in a smart, deliberate way is completely pointless if nobody
follows the ordering. 

If you've prioritised by risk, all of the difficult, ambiguous, yucky work is
going to be at the top of the backlog. The engineers _will_ try to wriggle out
of this and write some fun code instead. This is going to happen no matter what
process you say you have, so be prepared for it. It's the responsibility of the
whole team, but particularly engineering management, to prevent this from
happening.

I do want to quickly mention that engineers do more than just work a product
backlog. Just because they're not doing product work doesn't necessarily mean
that they're cherry-picking. The engineering manager or technical lead should be
able to tell the difference. This is another reason why I think non-technical
engineering managers are a bad idea --- they can't tell when the engineers are
taking them for a ride.

## Tip 7: Treat work in progress as the absolute highest priority

Another common problem, somewhat related to cherry-picking, is when the builders
get frustrated by work that is difficult, ambiguous, and yucky, decide that they
are blocked, and pick up new work hoping that it will be less frustrating. Then
the next thing turns out to be harder than it looked too, so they pick up a
third thing. And on and on it goes, constantly starting things but never
finishing them, until everything grinds to a halt.

I'm going to gloss over the reasons, but it's important to keep work in progress
to a minimum. There should be an upper limit to the number of things the team is
actively working on at the same time.

There is a common saying that I'm fond of that applies here: stop starting,
start finishing. I also have a personal saying: if you feel blocked, you're
probably not. Usually there is some action that could be taken to move the work
forward, that for whatever reason the builder has chosen not to do, but which
would be a better choice than picking up new work.

## Tip 8: Try to break everything down into cards that take roughly 1-3 days

For cards shorter than one day, the administrative overhead of prioritisation
can be a bit much. Cards longer than three days have a bunch of potential
problems. Sometimes they get blocked and work stops but it's not obvious that
that's what has happened. Sometimes specifiers use never-ending cards as a way
to bypass prioritisation, constantly adding new requirements after the card has
been picked up. Sometimes builders use long cards as a way to cherry-pick,
taking a huge chunk of work and then doing all the easy and fun parts first.
Large cards also tend to bundle together low-priority and high-priority work,
which would be better split up and prioritised separately. And they get in the
way of changing direction when needed, because builders are tied up with work
in progress instead of picking up new priorities.

Having a standard card size in combination with an upper limit on work in
progress _forces_ the team to deliver a steady stream of output. It should be
easy to demonstrate what the team has produced every week, and obvious when work
gets stuck.

This is also my preferred way to do estimation. It's both easier and more
accurate to break things down, count the cards, and multiply by 3 days, than it
is to estimate large chunks of work that all vary in size --- not that I'm a
huge fan of estimation to begin with.

## Tip 9: Break work down into vertical slices

If the team is working in priority order, staying under the work in progress
limits, and all the cards are roughly the same smallish size, then the only
thing left that can mess up delivery is working in horizontal slices. Horizontal
slices bad. Vertical slices good.

To simplify, the difference between a vertical and horizontal slice is whether
you can actually use the software after the card is done. If the card is
something like "do the database migrations" then no, that's not usable software,
which indicates it's a horizontal slice. If the card is something like "add
button for deleting widget" and the button actually works, then that's a
vertical slice because it's real working software for users.

Vertical slicing is a topic that I strongly believe in and have written about
previously, so I've already got a two-part test for evaluating whether work is a
vertical slice or not, and here it is:

1. The value test: Does this change, by itself, deliver some kind of value to
   the user? The answer must be yes. Refactoring is exempt from this test
   because, by definition, users should not see any observable differences after
   refactoring.

2. The completeness test: If this was the final change that was ever deployed
   for the project, and nobody was allowed to work on the project ever again,
   would deploying this change leave the software in a broken or incomplete
   state for users? The answer must be no. If the change requires other future
   changes in order to work properly, that means it’s not fully integrated and
   is therefore some kind of horizontal slice.

## Tip 10: Don't put too much effort into the bottom of the backlog

The backlog is going to grow and change a lot over the course of the project.
If you put a bunch of effort into planning, specifying, and prioritising
everything up front, a lot of that effort is going to be wasted when things
change.

At any given time, you only need to know the next few highest-priority things
--- maybe just the things that are expected to be started in the next two weeks
or so. Beyond that, it's good to have a rough ordering for the purposes of
communicating with stakeholders, but these are likely to change a fair bit and
so they're not worth putting a lot of effort into.

The thing at the top of the backlog should be adequately specified and ready to
go right now. The next couple of things should be fleshed out pretty well,
because they could get picked up soon. The next few things after that can just
be some rough notes, because they're not going to get picked up any time soon.
And the rest... meh. Empty cards with just a title is fine. They can get
specified when they're closer to being picked up, which might never happen.

## That's A Wrap

Phew. Trilogy over, finally. I hope you've had an interesting read, and maybe
found something useful to try on your next project.
