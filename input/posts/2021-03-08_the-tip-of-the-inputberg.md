{:title "The Tip Of The Inputberg"
 :main-image {:uri "/images/posts/inputberg.jpg"}
 :tags [:bleet]
 :category :testing}

Why did Apple not test what happens when a user supplies "True" as
their last name? Is it incompetence?

<widget type="tweet" href="https://twitter.com/JPaulGibson/status/1368182852668583948" />

I don't think so. I think the explanation is simpler: it's not
feasible. It's highly impractical, if not computationally impossible,
to test every input. 

<!--more-->

_Out of the Tar Pit_ (Moseley & Marks, 2006) explains the issue:

> The key problem with testing is that a test (of any kind) that uses
> one particular set of inputs tells you nothing at all about the
> behaviour of the system or component when it is given a different
> set of inputs. The huge number of different possible inputs usually
> rules out the possibility of testing them all.

And goes on to quote Dijkstra:

> testing is hopelessly inadequate... (it) can be used very
> effectively to show the presence of bugs but never to show their
> absence.

Consider a simple function that adds together two 8-bit integers.
There are 65,536 possible inputs to this function. When was the last
time you tested 65,536 different inputs for a single, simple function?

It _is_ possible for a computer to generate and test 65,536 inputs.
But what if those 8-bit integers were instead 32-bit integers? The
number of possible inputs would then be 18,446,744,073,709,551,616.
Even if we could test one million inputs per second, it would take 585
_millennia_ for the test suite to finish. I don't know about you, but
I'm expected to produce more than one function every half a million
years. And this function only adds two integers. The string `"True"`,
by the way, is is typically represented with at least 40 bits.

This means that, invariably, _the vast majority of inputs will never
be tested_. You can rely on this fact in the same way that you can
rely on the sun rising in the morning.

I'm not saying that it's impossible to have caught this bug with a
test. There are dozens of practical ways this could have been
prevented. I'm saying that it's wholly unsurprising that this bug was
not detected, and it is not a sign of incompetence that there is no
test for the input value `"True"` in the last name field.

As Dijkstra said, it is _not possible_ for tests to prove that there
are no bugs. Every test suite only checks the tip of the inputberg.
Keep this in mind the next time you hear someone glibly claim that
"there should have been a test for that". 

