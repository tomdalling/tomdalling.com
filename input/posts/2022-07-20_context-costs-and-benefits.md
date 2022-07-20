{:title "Context, Costs, and Benefits",
 :main-image {:uri "/images/posts/woodworking.jpg"}
 :tags [:bleet]
 :category :random-stuff}

When is "measure twice, cut once" bad advice?

One of my hobbies is complaining about the tendency of software developers to view choices as binary, moralistic decisions.
Measuring twice is obviously correct, and anyone who doesn't do it is an unprofessional, evil wood waster.
Either that or double measurers are a bunch of know-nothing shysters selling snake oil for exorbitant consulting fees.
This black-and-white thinking is a mental shortcut that many animals take,
but sometimes it's nice to apply a little more intellectual rigour than a Pomeranian.

I'd like us to think less in terms of _right_ and _wrong_ when it comes to technical decisions,
and think more in terms of _context_, _costs_ and _benefits_.

<!--more-->

_Context_ is the entire situation around the decision.
Are we cutting wood, or writing code?
If we're cutting wood, are we making cabinets or furniture?
If we're making cabinets, are we fitting out one kitchen or every apartment in a 15 story building?
The answers to these questions could have a dramatic effect on which option is best.
It's rare that one option is better than the others _regardless of the situation_.
Context matters.

With the context in mind, we can try to predict the consequences of a decision.
The positive consequences are the _benefits_, and the negative consequences are the _costs_.
Measuring twice reduces the probability of wasting time and wood due to incorrect cuts, but it's not free ---
it takes more time than measuring once.
Why not measure three times, or four times, or 600 times?
Because, at some point, the cost of measuring outweighs the benefits.
Viewing choices as either "right" or "wrong" obscures the fact that we're making _tradeoffs_ between the desirable and undesirable consequences.
The best choice will still have negatives, and the worst choice has positives too.
Every choice is a tradeoff between costs and benefits.

So,
let's say I've decided to get into woodworking as a hobby,
I want to make a table for the first time,
and I'm using some expensive mahogany.
Should I measure twice?
The cost of measuring might add up to a minute or two of my time.
The probability that I make an incorrect cut is high, and the materials are expensive.
In this context, measuring twice looks like a good choice.
I might even be inclined to measure three or four times.

But what if I'm building a manufacturing line to produce 50,000 chairs for IKEA,
the measurement lasers are 99.99% accurate,
and making the lasers double-check everything would add two weeks to the production run?
Now the cost of measuring is higher, and the benefits are greatly reduced.
In this context, measuring twice looks like a bad choice.

To answer my original question,
"measure twice, cut once" is bad advice _in contexts where the cost of measuring outweighs benefits gained from making fewer incorrect cuts_.

That's my default view on all technologies, really.

- "Is _[tech]_ good?" Yes, in contexts where the benefits are greater than the costs.
- "Is _[tech]_ bad?" Yes, in contexts where the costs are greater than the benefits.
- "_[tech]_ is superior/inferior." In what contexts?
- "_[tech]_ is bad because of _[cost]_." What are the benefits?
- "_[tech]_ is good because of _[benefit]_."
  [But](https://knowyourmeme.com/memes/ive-won-but-at-what-cost)
  [at](https://youtu.be/DYvhC_RdIwQ)
  [what](https://twitter.com/thomasfuchs/status/1106282842068316162)
  [cost?](https://youtu.be/8Dld5kFWGCc?t=740)

Good judgement is not just having a big list of the "right" things and another of the "wrong" things ---
it involves assessing the choices against the situation, and then accurately predicting the most important consequences.

> "LISP programmers know the value of everything and the cost of
> nothing" -- Alan Perlis

-----

Now for something completely unrelated: is agile better than waterfall?
Should all code have tests?
Is JavaScript a bad programming language?
Are type-checked programming languages superior to dynamic languages?
Which is the best editor out of VSCode, Vim, and Emacs?
Tabs or spaces?
I'll leave these questions as homework for the reader.

