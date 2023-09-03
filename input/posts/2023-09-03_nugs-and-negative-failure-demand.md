{:title "Nugs And Negative Failure Demand"
 :main-image {:uri "/images/posts/pcb.jpg"}
 :category :software-processes}

In this article I'm going to take a look at software quality as a way to
differentiate between junior, mid-level, and senior software engineers, through
the lens of _failure demand_, purely so that I can introduce a new concept that
I thought up on a walk today, which I'm calling _negative failure demand_.

<!--more-->

Caveats
-------

To pre-empt people getting angry at me, I want to be clear on a few points:

- Failure demand is not the _only_ thing that distinguishes
  juniors/mids/seniors. There are lots of things, and this is just one of them.
  The model presented here is one tool, not the entire toolkit.

- Like all models, this one has flaws and limitations, and as such should be
  considered critically. All models are wrong, but some are useful. The map is
  not the territory.

- Not all juniors/mids/seniors behave exactly as described here. People are
  individuals, not categories, and should be considered on an objective,
  case-by-case basis. Sometimes juniors act like seniors, and vice versa. I have
  personally witnessed a junior handedly outperforming a senior before. There is
  plenty of variability.

Also, this is a bit long. I would have written a shorter article, but I didn't
have the time.

What Is Failure Demand?
-----------------------

Let's first look at _demand_. Loosely speaking, demand is a measure of customers
knocking on your door and saying "I have money that I would like to exchange for
something of yours". Demand is (usually) proportional to the amount of goods and
services a business provides. For a bakery, that translates to bread sold, but
for a service business like a cleaner it (largely) translates to _employee time_
sold.

_Failure demand_ is a kind of demand that comes _not_ from customers wanting to
purchase something, but from customers seeking a remedy to a _failing_ of the
business. Some examples include:

- a customer asking for a new loaf of bread because they one they just purchased
  was mouldy

- a customer asking for a cleaner to return because something was not cleaned
  properly

- a customer interacting with support (i.e. consuming employee time) because the
  software they purchased is not user-friendly enough for them to be able to
  work it out by themselves

How Does It Apply To Software Engineering?
------------------------------------------

Failure demand could apply to software engineering in a few different ways, but
what I want to focus on specifically here is: when engineers produce software
that results in future costs for the business _due to poor quality_. Those costs
could be:

- increased burden on customer support due to poor UX

- a litany of bugs that consume the time of various different people across the
  business, including engineers

- maintenance costs of supporting poorly-designed features, which often can't be
  removed or fixed after customers come to rely on them

This is similar to, but not quite the same concept as, technical debt.

Juniors
-------

Without a good environment, it's not uncommon for a junior software engineer to
spend one month producing software that results in several months of failure
demand for the business. And let's face it, creating a good environment is
particularly difficult --- most businesses don't do it well.

Typically you would expect that the value produced by an engineer would be
greater than the salary they're paid. Otherwise the business is running at a
loss, which is not sustainable. Well, in some situations, the value produced by
an engineer might not only be below their salary --- it can be below
_zero_. That is, even if they worked for free you'd still be losing money.

Juniors are a longer-term investment. If you're expecting the same result at
half the price, then you're setting yourself up for a rude awakening. It might
sound smart to get a month of engineering work at a cheaper, junior rate, but it
sounds less smart when you account for a month of a senior engineer to fix it ---
not to mention all the other costs of shipping low-quality software.

Now is a good time to read the caveats section above, if you haven't already.

Seniors
-------

One of the hallmarks of a senior engineer is their ability to see into the
future and make decently accurate guesses as to the maintenance costs of their
decisions. To put it another way: seniors should be able to anticipate and avert
failure demand.

Top-quality software is software that employees don't hear about. It doesn't
need to be debugged because there are no bugs. Customers never ask for support
because it's intuitive to use. Engineers don't need to change it or even read
the code when they add new functionality because it's designed to be extensible
without modification. It just keeps working, and nobody has to think about it.
This is what senior engineers should be able to produce.

Mids
----

Mids are half-way between juniors and seniors.

Fresh mids still produce a sizable amount of failure demand, but less so than
juniors. Usually the reduction is accomplished by copying patterns from
more-senior engineers, without necessarily understanding the reasoning behind
them.

Mids approaching senior should have started honing their farsight, and
have significantly reduced the failure demand that they produce. 

Nugs
----

So juniors tend to produce a relatively large amount of failure demand, which
decreases as they gain experience. This might lead you to believe that the ideal
--- i.e. what the seniorest of the senior produce --- is zero failure demand.
But I would argue that S-tier engineers can actually go beyond zero, and into
the negatives. This brings us to the new concept I wanted to introduce: negative
failure demand.

It's one thing to be able to foresee and avoid failure demand in your own code.
Done perfectly, that would get you to zero. To go beyond zero, into the
negatives, you also need the ability to foresee and prevent failure demand in
_other team members' code that hasn't been written yet_.

To demonstrate, let's take bugs as an example of engineering failure demand. We
can write code that contains some bugs, or no bugs. But how can we write code
with a negative number of bugs? Well, imagine if it was possible to write a
negative bug --- a _nug_, if you will. You write your nug, and commit it into
the codebase. Initially, it does nothing. But the next time any engineer
introduces a new bug, the nug cancels it out, resulting in no new bug being
introduced. Wouldn't that be amazing? The good news is that this is already how
software engineering works, in a manner of speaking.

Good software is not only good at the point it's released --- it should be
robust, and _remain_ good after being extended and modified by other
engineers. If the wheels fall off as soon as someone else touches the code, then
you need to keep working on that senior farsight. _Really_ good code is strong
enough to survive multiple juniors extending it, and actually guides them to
produce higher-quality work than they otherwise would have, purely by virtue
of the design and structure. This is what I mean by negative failure demand.
It's quality work that's _infectious_, and propagates that quality into the
future.

Nugs In Practice
----------------

The way that you write a nug is by:

1. Anticipating what changes might be made in the future
2. Analysing the likely mistakes an engineer would make while implementing those
   changes
3. Designing/structuring the current implementation such that those mistakes are
   impossible, or at least difficult, to make

This is what senior engineers should be doing already, especially the seniory
seniors.

In practice, negative failure demand work takes the shape of things like:

- libraries and frameworks
- library-like and framework-like parts of the codebase, which are only ever
  used internally and never extracted
- linters
- continuous integration pipelines
- mentorship and education

All of the above are leveraged ways to improve quality --- that is, they make
other people more effective at their work _without_ the author having to be
involved in that work. For example, adding a linter rule can prevent a whole
class of bugs for _all_ engineers working in the codebase, even future engineers
that haven't been hired yet. Don't get me started on linters, though.
