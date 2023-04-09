{:title "Against Must-Haves (Part Two)"
 :main-image {:uri "/images/posts/bucket-chickens-2.jpg"}
 :tags [:bleet]
 :category :software-processes}

In part two of this series, we're going to look at how the must-have priority
bucket leads engineering to make bad decisions.

<!--more-->

## Recap

In [part one][] we:

- looked at what bucketed prioritisation is
- defined "must-haves" as the first, and highest-priority, bucket
- divided people's roles into the rough categories of "builders" and "specifiers"
- demonstrated how the must-have bucket creates perverse incentives for
  specifiers

[part one]: /blog/software-processes/against-must-haves-part-one/

## A Tale Of Builders And Buckets

Imagine you're an engineer working in a bucketed priority system. Let's say that
the specifiers have gone and done specified, and produced a set of requirements
divided into three buckets: must-haves, nice-to-haves, and things to consider
doing in the future. Now it's time to start building.

Where are you going to start? You're going to start by looking at the
must-haves, and ignoring everything else. This is prioritisation working as
intended. So far, so good.

There are a bunch of different things in the must-have bucket, so how do you
decided which one to start with? In a system of bucketed prioritisation, the
priority of a requirement is determined by the bucket that it sits in. Since all
the requirements you're looking at are in the same bucket, they are all equal in
terms of priority, and so therefore _the order in which they are built is
irrelevant_. These are the non-negotiables, right? They all _must_ get done
within the given time frame, so what difference does ordering make? Through the
office window you see a raven cawing as if it's laughing at you. In its nest
there are several expensive-looking keycaps, and you could have sworn that it
was sporting some kind of neck beard.

One of the cards says we should consider using AI for part of it. That sounds
like it might be an interesting learning experience. In another card, the
designer has included a Figma mock-up with some cool animations. That might be
fun to implement. Some cards look boring, or difficult, or both. Your colleague
just picked up the animation card. Dang. Better grab the AI card before someone
else does.

So you start investigating how you're going to do the AI, make a proof of
concept implementation using a new AWS service, and then start building it into
the project properly. After a few cycles it's done, but it's not really useable
yet because it depends on parts of the project that haven't been built. You head
back to the list of must-haves, and find another interesting card to get started
on.

It's been a few months now, and the specifiers have started becoming antsy in
meetings. They are getting worried that the project might not be delivered on
time, and say that they're not seeing much progress. That's annoying. You've
been working hard, and you know all the other builders have been working hard
too. You point out all the hard work that went into the AI. The specifiers ask
where they can see that feature. You tell them that you gave a demo about it two
weeks ago. They say they liked the demo, but ask how they can actually use it in
the app. You show them the screen, but say that they're not going to be able to
use it properly until a couple of other cards are finished. They ask when those
other cards are going to be finished. You say that someone will pick it up soon,
and that everyone is working as fast as possible, focusing only on the
must-haves.

The specifiers say that they want more confidence around delivery, and suggest
that builders take some time to put accurate estimates on each of the remaining
cards. You ask why more must-have cards are being added every week if we're
worried about delivery. You're told that those cards are important, and that
they can't be nice-to-haves because it doesn't look like there will be any time
left for nice-to-haves. You say that if there's no time to do a card, labelling
it a must-have isn't going to magically create more time for it. They say the
must-haves must get done, and that's why they're called "must-haves". The raven
is back cawing outside the window --- it's neck beard more prominent than ever.

As the deadline draws near, it has become crystal clear that the must-haves are
not going to be done on time. After many hours of estimation meetings, the
numbers just don't add up, and even if they did, a significant proportion of the
cards are taking longer than estimated. The builders get criticised for giving
inaccurate estimates, so now they add lots of padding to each estimate, which
makes the roadmap (a.k.a. the fancy Gantt chart) so incredibly long that the
specifiers start updating their resumes. Even with the padding, a couple of
cards have unearthed major technical obstacles that only became apparent after
they were started recently, and these threaten to blow up the already-disastrous
schedule.

The specifiers enter the third stage of grief: bargaining. They are asking you
whether you think you could work really hard and meet the deadline if they
removed a bunch of the must-have cards. It turns out that the non-negotiables
are, in fact, negotiable after all. The specifiers make a new bucket --- the
must-have must-haves --- which contains only the must-haves that are really
really important.

But now you're indignant. You don't want to cooperate with the specifiers. They
told you that the cards were must-haves, and you trusted them, but when you
worked on those cards they turned around and said you've been wasting time on
low-priority work. Someone even said that the AI feature you implemented doesn't
work well, and used it as an example of builders wasting time. They've been
dragging you away from doing actual work and into pointless estimation meetings,
pressuring you to give over-optimistic estimates, and then criticising you for
being slow and not estimating accurately. The entire team is demoralised
because, even though nobody will say it out loud, they all know that the
deadline is impossible, and yet they're still expected to put in overtime
indefinitely. This project is a death march.

The project runs over schedule by a factor of two. The end product is a steaming
pile of shit, and it's questionable whether it's even fit for purpose. The
builders and the specifiers both place the blame on the other's incompetence.
The people with the highest employability --- usually the ones with the
strongest skill sets --- quit the company. Maybe one or two of the specifiers
get fired, too.

You morph into a raven, peck the keycaps off your mechanical keyboard, and fly
off into the sunset to be one with nature.

## Whose Fault Is It Anyway?

Plenty of things went wrong in the story above. The specifiers made some bad
decisions, but I think that the responsibility for this situation mostly lands
on the builders --- specifically engineering management.

The typical specifier does not understand the technical details and technical
risks involved in building software. That's not their job. And if they did
understand, engineers would become easily replaceable and their salaries would
fall through the floor. For example, part of the job of marketing and sales
people is to understand what the customers want, so they are able to provide
great input when deciding what to build. It is not, however, part of their job
to know _how_ to build those things, which is why it's not uncommon for them to
come up with ideas that are wildly expensive or literally impossible. And that's
fine. Not every idea is feasible.

It's also often not specifiers' job to understand _delivery_ risk, although it
is highly desirable. Product people often don't have a good sense for whether
building any given feature will be easy peasy lemon squeezy, or stressed
depressed lemon zest. That's because there are knowns and unknowns that are
deeply technical in nature, and only the people actually building the software
have a hope of identifying where the landmines are. Product people with deep
technical knowledge are incredible assets, but also exceedingly hard to find and
probably outside of your price range.

So then who is actually responsible for the delivery of quality, working
software? Whose job is it to deal with these deeply technical unknowns and the
risks they pose? The most practical choice is engineering. Engineering is in the
best position to understand and mitigate delivery risk --- less so the individual
engineers writing the code, and more so engineering management/leadership.
Engineering management is the interface between the specifiers and the builders,
and it is their job to ensure that delivery happens smoothly.

This is why I believe that non-technical engineering managers are generally a
bad idea --- but that's a topic for another time.

## How Buckets Are Involved

The main issue with prioritisation by bucket is that each individual bucket is
unprioritised. Buckets are prioritised against each other --- e.g. must-haves
are higher priority than nice-to-haves --- but the things within a bucket are
not. To the naive observer, all the must-haves appear to be equal in terms of
importance, and therefore the order in which they get done should not matter.
This is a natural and logical conclusion to arrive at, but it couldn't be
further from the truth, and it's the source of the problems in the story above.

If you tell a bunch of engineers to complete a collection of tasks, they are
going to cherry-pick the things that are _easy_ or _interesting_.

Easy things, by definition, are low-risk in terms of delivery. If they involved
unknowns then they wouldn't be easy. Cherry-picking the easy things causes all
the high-risk tasks to be deferred until near the end of the project. So the
point at which everyone discovers the devastating, unforeseen problems that
threaten to tank the whole project is just before the deadline. It should be
obvious why this is a terrible approach to delivering software. Bucketed
prioritisation systems naturally lead people to make this mistake.

Cherry-picking the _interesting_ things causes a different problem. I mentioned
earlier that it's a mistake to assume that the must-haves are all equal in terms
of priority. Despite the name, the "must-haves" are going vary in importance,
from absolutely critical down to things that should be nice-to-haves. Working in
order of decreasing interest means that interesting less-important things are
done before boring more-important things. This wouldn't be an issue if all the
things get done in time, but that rarely happens. Usually what happens is that
new ideas are added to the bucket faster than the things in the bucket are
getting completed, meaning that the bucket is effectively infinite. The
consequence of ignoring the boring high-priority stuff is that, as you approach
the deadline, the software has a lot of cool features but it doesn't actually do
what it was intended to do. The first 90% of the engineering budget gets
squandered on random shit that the engineers think is cool, then the second 90%
of the engineering budget is a mad rush to try and make it fit for purpose,
resulting in late, poor-quality, ineffective software. This problem is a natural
consequence of bucketed prioritisation too.

## Up Next

Hopefully by this point I've demonstrated why and how bucketed prioritisation
drives poor outcomes. I've served up a heapin' helpin' o' problems without even
a side of solutions, so in the next article I'm going to suggest some tactics
designed to avoid the pitfalls covered so far. Hint: it won't involve buckets.
