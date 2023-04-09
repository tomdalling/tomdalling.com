{:title "Against Must-Haves (Part One)"
 :main-image {:uri "/images/posts/bucket-chickens-1.jpg"}
 :tags [:bleet]
 :category :software-processes}

Categorising requirements into buckets like "must-haves" and "nice-to-haves" is
a common approach to prioritisation in software projects. In my opinion, this is
a bad way to priortise work, for reasons which become clear when you look at the
incentives it produces.

<!--more-->

## Prioritisation By Bucket

There are various different, common approaches to priortisation that involve
placing requirements into ordered buckets.

For example, the MoSCoW prioritisation framework has four buckets, in order of
decreasing importance:

- Must-have
- Should-have
- Could-have
- Won't-have

The well known minimum viable product (MVP) strategy is also basically a
two-bucket prioritisation framework. There is a bucket for the things that are
absolutely necessary to make the project viable --- essentially "must-haves" ---
followed by a bucket for everything else.

Regardless of how the buckets are structured, generally the first one contains
the things that are non-negotiable: the must-haves. This is the bucket that
ruins the whole idea of prioritising with buckets.

## The Players

Before looking at incentives, the first question is always: for who? Within the
same team or orgnisation, different people are presented with different
incentives. For the purpose of this series of articles, I'm going to roughly
split people into two roles:

- Builders: the people who literally build the software. This obviously includes
  software engineers, but often also includes _some_ engineering managers. It
  can also include people like designers and testers.

- Specifiers: the people who have influence over requirements. These are your
  project managers, product owners, business analysts, product people,
  management, executives, etc. In a healthy organisation this role also
  includes the builders, but that's not always the case.

Individuals play both roles to some extent, but usually they skew towards one or
the other overall.

## A Tale Of Specifiers And Buckets

Specifiers almost always want the _maximum amount of stuff_. Managers want the
maximum output from their reports. Product people want the maximum number of
features possible. This is nothing new, and isn't necessarily good or bad per
se.

Imagine you're a specifier working in a bucketed prioritisation system. You have
a whole bunch of things that you want built, and each thing needs to be put into
a bucket. How are you going to decide which thing goes into which bucket?
You want to do the right thing, so you carefully consider how the buckets are
defined and put your things into the correct buckets accordingly.

But your colleague Jimithan is not so considerate. He keeps putting his things
into the must-have bucket even if they don't meet the criteria. You try to talk
to him about it nicely, but he says that his things are very high priority, and
that if they get downgraded to should-haves then they're not going to get done
in time. You think it's probably true that should-haves are not going to get
done now, largely thanks to Jimithan's behaviour. He insists that all his things
are important, which is actually true, but your things are important too. He's
not trying to deprioritising your things, he's just trying to do his job.

Tactfulness has failed. Now you're only left with courses of action that aren't
very desirable. Are you going to be more assertive and probably start a
conflict? Are you going to try go over Jimithan's head and get him reprimanded
by his manager? Are you just going to let Jimithan steamroll you and perform
your job badly from now on? The fact that he's doing it and it's working for him
probably points to systemic/cultural issues that are well outside of your sphere
of control, so you might not receive much support.

In this situation, it's entirely reasonable and rational to take the path of
least resistance: shoving all your things into the must-have bucket, just like
Jimithan is doing. It avoids conflict (for now) and you'll be able to do your
job again (for now). And it's not just you --- all of the specifiers are doing
it now, because they get disadvantaged if they don't.

## Why It Do

If a specifier wants to get their thing built, they are incentivized to
put it in the must-have bucket. But every time a new thing gets added to the
must-have bucket, it reduces the bucket's effectiveness for actually getting
the right things built. This is the [perverse
incentive](https://en.wikipedia.org/wiki/Perverse_incentive) that bucketing
creates. It's intended to improve delivery, but actually makes it worse.

In my experience, this is the fate of all bucketed prioritisation systems. They
only work if:

- everyone involved is both experienced enough to know how this plays out, and
  considerate enough not to abuse it

- or there is a "prioritisation nazi" that has the desire and the ability to
  stop people from abusing the system, and also not abuse it themselves. 

Neither of the above situations are common. Usually it just takes one Jimithan ---
who meant no harm but couldn't foresee the consequences of their actions --- to
burn the whole system down.

Regardless of how the buckets are _supposed_ to be structured, they inevitably
devolve into a system of two buckets:

- The "things someone wanted" bucket. You have to put your thing here to get it
  built, but nobody really knows when or if it will actually happen.

- The graveyard. Everybody knows these will never get built, but pretends like
  we'll get to them eventually.

This _is_ a way of working. Software still gets built. It's just shitty, and
there are better alternatives.

## Up Next

If you're upset about yet another engineer complaining about non-engineering
roles then stay tuned for the next installment of this series, where I complain
about how engineers abuse bucketed priority systems too.

Read: [Against Must Haves (Part
Two)](/blog/software-processes/against-must-haves-part-two/)
