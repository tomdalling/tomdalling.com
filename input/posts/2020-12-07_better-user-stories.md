{:title "Better User Stories"
 :main-image {:uri "/images/posts/booktube.jpg"}
 :category :software-processes}

As a member of the software industry, I want user stories to focus
more on the problem definition, so that we can make better choices
around how to implement a solution.

Or should I say:

As a member of the software industry, it's easy to decide on a
solution or implementation details too quickly, without a good
understanding of the problem we are trying to solve. This leads to
suboptimal software for the end user, technical debt, and rework that
could have been avoided. I propose that we change the user story
format to focus more on the problem definition, and less on a single
solution.

<!--more-->

## Problem Definition

A common user story format goes like this:

> As a \$ROLE, I want \$SOLUTION, so that \$BENEFIT.

- It focuses on one particular solution, ignoring alternatives.
- It focuses on implementation details, not the reasoning behind the
  change.
- It persuades the reader with benefits, but neglects to mention any
  costs or trade-offs.

It's a recipe for jumping the gun.

This template for user stories _can_ be used in a way that avoids
these problems. So blah blah disclaimer, something something not doing
it properly, it comes with experience, et cetera. But I think it's
fair to say that it causes real-world costs, and could be improved.

## Proposed Solution

I would prefer to see a format something like this:

> As a \$ROLE, I have \$PROBLEM_OR_OPPORTUNITY. This leads to
> \$CONSEQUENCES. I propose that we \$SOLUTION.

This focuses more on the reasoning behind the change, which helps the
team make better decisions around design and implementation details.

It still proposes a single solution. I think it's usually better to
propose a solution than to just describe the problem and lob it over
the wall to developers. But clearly describing the problem facilitates
the discovery of better alternatives. You can't know if something is
better or worse unless you have enough context. There could also be
multiple proposed solutions, allowing the implementer to choose
whichever is most appropriate.

It still doesn't mention costs, but it also doesn't mention benefits.
Hopefully that results in a more balanced consideration of trade-offs.
