{:title "Start With High-Level Tests"
 :main-image {:uri "/images/posts/floorplan.jpg"}
 :tags [:testing :mentoring]
 :category :mentoring}

## Rule Of Thumb

Start with high-level tests, and step down to lower levels when the
implementation is stable.

<!--more-->

## Background

There are different kinds of tests, and each kind can be placed on a
continuum from high-level to low-level. High-level tests cover a
larger portion of the codebase, and tend to exercise application
features in a way that is closer to how a real user would.
Low level tests cover small units of the codebase, often
in isolation, and tend to exercise programmatic interfaces of internal
implementation details.

In the context of a Rails application, the kinds of tests can be
roughly ordered:

 1. _Highest_: System/feature/end-to-end tests
 1. Request/controller tests
 1. Tests for commands, interactors, background jobs, or other business logic
 1. Tests for individual models, views, or other small components
 1. _Lowest_: Isolated unit tests for individual classes, often POROs,
    where all dependencies have been mocked out

## Rationale

As with everything, choosing between high- and low-level tests
involves trade-offs.

The benefits of higher-level tests are:

- We get higher confidence that the functionality actually works for
  real users.
- Refactoring and experimentation are easier because we can change all
  the implementation details without having to change the test.
- Fewer tests are required because each test covers a larger area of
  the code.

The costs of higher-level tests are:

- The tests take longer to run, and can make the test suite slow.
- Edge cases and error scenarios are harder to test, and are often
  neglected as a result.
- The tests are more complicated, and harder to debug when they
  fail.

Higher-level tests are better at the beginning, when the exact details
of the implementation are still being explored. Our understanding of
requirements increases as we work, which means that we understand the
_least_ at the start, and the _most_ at the end. This is why the
ability to refactor is important. The first implementation will not be
optimal, so we want the ability to make big changes easily while still
having confidence that everything connects together in a way that
works.

Lower-level tests are better for covering all the different edge cases
precisely. They are simpler and faster, which makes it easier to write
a lot of them, but there are a couple of drawbacks. They make
refactoring harder by coupling to implementation details, meaning that
changing the implementation often requires rewriting all those little
tests. And while they give high confidence that the individual parts
work correctly, they do not give much confidence that all the parts
are integrated together in a way that works properly for the user.

## Example Scenario

Let's say we are implementing a small new feature in a Rails
application.

Writing a single "happy path" system test does not take very long, and
it will drive out the majority of the implementation details. It will
exercise views, controllers, models, database migrations,
interactors/command objects --- maybe even background jobs, external
third-party services, and new libraries.

In typical TDD fashion, we can repeatedly rerun the test while
exploring different approaches to the implementation. Once it passes,
we are free to change all of the implementation details. And after
deciding on an approach, we can run the test while refactoring ---
cleaning up and refining the new code.

By this point we're happy with the general design of the
implementation, and we're confident that it works for the most
straight-forward use case, but we're _not_ confident that it is robust
against all the other use cases and error scenarios. This is where we
might step down to model validation tests, to cover some error cases
--- or maybe tests at the interactor level, to cover all the different
ways a dependency could affect the outcome. These tests will hamper
refactoring to some extent, but hopefully the largest refactorings
have already been done before this point.
