{:title "Monologue On End-To-End Testing"
 :main-image {:uri "/images/posts/server-rack.jpg"}
 :tags [:testing]
 :category :testing}

I wanted to write down some of my thoughts on end-to-end testing,
mainly to help clarify my own thinking.

<!--more-->

## What Is The Goal Of Testing?

Let's start from the beginning. Why do we test at all?

Software tends to become broken over time. Things are constantly
changing, and every change has the potential to break things.

Broken software has a variety of costly consequences that we would
rather avoid:

- Real-world effects that range from mild inconvenience to loss of
  human life, depending on domain
- Time and money spent to remedy the situation
- Reputational damage to the business, which can be difficult to fix
  even with time and money

Testing is one way to avoid or minimise these consequences.

Testing doesn't _prevent_ broken software, per se. More accurately:
testing _detects_ broken software earlier, reducing the cost. The same
defect might take a few seconds to fix if detected immediately as the
developer introduced it, or many person-hours of work if detected at
in later QA stage before deployment, or incredible amounts of time and
money if detected after being deployed to production for a few weeks.

## The High/Low Continuum

There are a variety of different ways that software can be tested,
and they can roughly be placed on a continuum from "low-level" to
"high-level".

Broadly speaking, moving a test higher up the continuum makes it more
"real", which gives higher confidence but is more expensive. To put it
another way, it reduces the likelihood of false positives (i.e.
passing when a defect exists) but also increases the cost of writing,
maintaining, and running the test. Conversely, moving a test lower
down the continuum makes it cheaper but less likely to detect defects.

So for the same investment, we can get:

- lots of less-reliable tests; or
- a small number of more-reliable tests; or
- something in between

### Lowest Level: Isolated Unit Tests

At the lowest level, we have isolated unit tests. These test a
single unit of code _without_ its dependencies. For example, this
might test a single function, with all of its dependencies replaced
with test doubles.

These are:

- quick to write
- easy to understand
- cheap to maintain (individually, but maybe not in aggregate)
- very fast to run

But you get what you pay for --- unit tests do not provide much
confidence that the entire system works appropriately in production
for real users.

### Mid Level: Integrated Tests

The next step up are tests of groups of units, with some or all of
their real dependencies in place. For example, this might be a test of
a command class like `PublishBlogPost`, which checks that the
database (a dependency) is modified as expected. 

Compared to isolated unit tests, these:

- take longer to write, due to setup code
- are harder to understand, because they cover a larger area of code
  and check distant side effects of dependencies
- are more likely to produce false negatives (i.e. failing when there is no
  defect), due to being coupled to more of the codebase
- give greater confidence that the functionality being tested works
  appropriately in production for real users

### Highest Level: Production

A test at the very highest level would exercise the software exactly
how real users would. There would be no difference between what the
test sees and what real users see. You probably already have a test
environment up and running for this this, called something like
"production". Humans exercising production is the ultimate test
of any software system --- either it really works, or it really
doesn't. 

The drawback of testing in production is the cost. Back near the start
I said that the aim of testing is to reduce costs by detecting defects
earlier, so it might sound a bit ridiculous to test at the final and
most expensive stage. And it can be, but there are approaches like A/B
testing and feature flags which are economical, and sometimes the best
choice. If you reframe "testing in production" as "monitoring and
alerting", suddenly it sounds a lot more sensible.

Testing in production is not what I'm trying to cover here, although
it is an interesting topic. Let me summarise by stealing a graphic
from some [scientific research by Erik Bernhardsson][erik].

[erik]: https://erikbern.com/2021/04/19/software-infrastructure-2.0-a-wishlist.html 

![testing in production](/images/posts/end-to-end/test-in-production.png)

## End-To-End Testing

Coming back to the intended topic: end-to-end testing, in my mind, is
supposed to be as high up the continuum as it can be without using
real human users or production. The idea is to boot up the entire
system, and exercise it in a way that is as realistic as possible
while being fully automated.

Why? To detect problems earlier than production, with a high level of
confidence, at a reasonable price. We could get a higher level of
confidence before production in other ways, but they tend to involve
humans, which makes them too expensive to run dozens of times per day.
We could get cheaper tests by moving down the continuum, but we would
also lose confidence. End-to-end tests will pick up defects that
lower-level tests can not.

### When To Use Them

Giving high confidence but also having a relatively high price,
end-to-end tests are best suited to situations where high confidence
is desirable enough to pay the high price.

Let's say we run an image sharing website. It's probably quite
important that users are able to sign up, upload an image, and share a
link to that image. It would be a major problem if any part of that
workflow was broken, considering that it's the primary use case of the
software. This is a good candidate for end-to-end testing. The test
set up might be nasty and complicated. It might take 30 seconds to
run. It might give false negatives and need to be fixed up on a
semi-regular basis. But I image that we're probably happy to pay that
price for confidence that our image sharing site can share images.

However, if _every_ test was that expensive, we would quickly run into
problems. The test suite would take so long to run, and be so hard to
work with, that developers would just abandon it in an attempt to get
any work done.

So, I think the best approach is to write end-to-end tests for a small
number of highly important workflows. When it comes to the numerous
edge cases and finer details, end-to-end tests are cost prohibitive,
so for those it's better to step down to one of the lower levels.

Another good candidate is anything that charges money. Customers get
pissed off when they pay for something and it doesn't work. They also
don't like being overcharged. And the business really doesn't like
when their ability to generate revenue is broken. These defects are
fairly high on the list of things the business wants to avoid, so it
might make sense to write tests for the amounts charged in various
realistic scenarios.

### Dos

- Run background jobs as part of the tests. This is what happens in
  production, so it should happen in end-to-end tests too.

- Travel forward in time, where appropriate. For example: exercise a
  feature, wind the clock forward to the end of the billing period,
  and check that the invoice is as expected. Users also time travel as
  part of their real workflows, albeit at the slower rate of
  one second per second.

- Test communication with external dependencies. You might be
  confident that the user can see an invoice for the correct amount,
  but are you confident that the system actually charged that amount?
  That part is kind of important too, even though it's invisible
  to the user. Wherever the software communicates with an external
  system, such as a payment processor, you should be testing that
  communication too.

### Don'ts

- Avoid mocking/stubbing as much as possible. Remember, the purpose is
  to simulate a production environment as closely as possible, and
  every mock/stub introduces behaviour that doesn't exist in
  production, lowering confidence. If you really want to mock/stub
  something, consider writing a lower-level test instead, since they
  are cheaper. See "External Dependencies" below for a counterpoint to
  this.

- Don't test internal state. It's easy to peek at database records in
  a test, but the goal is to test from the user's perspective for
  increased confidence, and users don't have direct access to the
  database. Try to access that information via the UI, like a user
  would. An exception to this is possibly the initial state of the
  system before the test starts, which may be difficult to set up
  exclusively via the UI.

- Don't write too many. It's tempting to write end-to-end tests for
  everything, to get that high confidence, but they are comparatively
  expensive. Be wary of the test suite run time, and how much time
  developers are spending maintaining the end-to-end tests.

- Don't tolerate flaky tests. Things like headless browsers used in
  end-to-end tests do tend to be more flaky in general, but you should
  still be aiming to have zero false negatives. Flapping or
  super-brittle tests cause developers to stop paying attention to
  test failures.

- Be wary of complexity creep. End-to-end tests will contain more code
  than other kinds of tests, but they shouldn't be difficult to read.
  You can't be confident in a test that you don't understand.

### External Dependencies

The most realistic way to test external dependencies is to
actually hit them from the tests. This is usually not feasible,
though.

The next best thing is to use some kind of sandbox system provided by
the creators of the dependency. Most dependencies will not have
sandboxes, unfortunately.

The next most realistic option is to configure the system with a
replacement dependency. For example, if we're talking about sending
emails via SMTP, it's possible to point the system at a different SMTP
server for testing purposes. Most dependencies are not that easy to
replace, however.

It's a common situation to integrate with an external system that:

- has side effects that make it unsuitable for automated tests
- doesn't provide any kind of sandbox environment
- has a custom REST API

This severely limits options for realistic testing.

We could write a separate web app that implements their custom API.
This is not unheard of (e.g. [stripe-mock][]) but is a lot of effort
and not necessarily a realistic simulation of production.

[stripe-mock]: https://github.com/stripe/stripe-mock

In this situation I think it makes sense to design an adapter
interface for the dependency within the codebase, and swap out the
real adapter for a test adapter. Test adapters run faster, are less
flaky, don't require an internet connection, and can make testing
different kinds of scenarios a whole lot easier. I'm a big fan of this
approach, despite recommending to avoid mocking in general. It's less
realistic, but has so many other advantages that I'm generally happy
to make that trade-off. Similar to the common saying "don't mock what
you own", my view is that mocking is acceptable _at the boundaries_
but undesirable for internals.

Test adapter behaviour can easily fall out of sync with the real
adapter, and some amount of effort should be spent guarding against
this. This is the point where contract testing (e.g.
[Pact](https://pact.io/)) becomes useful. This is also a good
candidate for testing in production, if the adapter can't
realistically be tested in any other environment.

I should also mention that the primary database for a web application is
typically _not_ an external dependency, even if it runs on separate
servers. If a database is controlled by some third party, or is
perhaps write-only, then I can see how it could be viewed as an
external dependency. But if the developers of the web app are writing
migrations, then the database is an internal implementation detail and
therefore should not be queried by end-to-end tests.

## Conclusion

Of all the different kinds of automated tests, end-to-end tests give
the highest level of confidence, short of testing in production. They
will detect integration defects that lower-level tests can not.
Their main drawback is that they are relatively expensive, and as such
should only be used sparingly, for workflows important enough to
justify the cost.

The test environment should mimic production as closely as possible,
so mocking should be avoided. The exception to this is at the
boundaries of the system, where mocking out external dependencies is
advantageous enough to justify the reduction in confidence.

Tests should exercise the system from the boundaries, in a way that is
as similar as possible to how the live production system is used. This
typically means driving a headless browser. Tests should not be
peaking into the database, or checking that specific functions were
run, because this does not simulate realistic usage.

The UI is not the only interface at the boundary. Communication with
external systems should also be tested, to ensure that the software
produces the expected side effects (e.g. sending emails) and handles
programmatic users (e.g. API clients, webhooks) appropriately too.

