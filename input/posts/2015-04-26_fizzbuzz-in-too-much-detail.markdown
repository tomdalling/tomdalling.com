{:title "FizzBuzz In Too Much Detail"
 :disqus-id "com.tomdalling.blog.fizzbuzz"
 :main-image {:uri "/images/posts/fizzbuzz/main-image.jpg"}
 :category :software-design}

I know. FizzBuzz has been done to death. But I want to use it as a familiar
base upon which we can explore some of the common tradeoffs involved in writing
and maintaining software. In this article, I'll show multiple implementations
of FizzBuzz, all designed to achieve different goals, and discuss the
implications of each.

<!--more-->

What is FizzBuzz?
-----------------

<figure>
  <img src="/images/posts/fizzbuzz/let-me-tell-you-about-fizzbuzz.jpg" />
  <figcaption>Hey guys, have you heard about this new FizzBuzz thing?</figcaption>
</figure>

FizzBuzz is a very simple programming task, used in software developer job
interviews, to determine whether the job candidate can actually write code. It
was [invented by Imran Ghory][], and [popularized by Jeff Atwood][]. Here is a
description of the task:

> Write a program that prints the numbers from 1 to 100. But for multiples of
> three print "Fizz" instead of the number and for the multiples of five print
> "Buzz". For numbers which are multiples of both three and five print
> "FizzBuzz".

It's very well known in software development circles. There are multiple
[implementations in every language][], [joke implementations][], and plenty
of articles discussing its usefulness during the hiring process.

A Naïve Implementation
----------------------

Let's kick things off with a super simple, straight-forward implementation.
I'll be using Ruby for this article, but the concepts apply to all languages.

```ruby
1.upto(100) do |i| 
  if i % 3 == 0 && i % 5 == 0
    puts 'FizzBuzz'
  elsif i % 3 == 0 
    puts 'Fizz'
  elsif i % 5 == 0 
    puts 'Buzz'
  else
    puts i
  end
end
```

This implementation gives the correct results, and there is nothing clever
about it. Now let's start applying some common software development practices
to it.

Don't Repeat Yourself (DRY)
---------------------------

I'm fairly certain that when Dijkstra descended from Mt Sinai, DRY was
inscribed on one of his stone tablets. Also known as "Single Source of Truth",
DRY is universally accepted as a pillar of good software design. It involves
removing redundancy and duplication from our code.

Let's apply DRY to the naïve implementation above. The sources of duplication
that immediately pop out to me are:

  - `i % 3 == 0` and `i % 5 == 0` both appear twice
  - `puts` appears four times

After removing those sources of duplication, our implementation looks like this:

```ruby
1.upto(100) do |i| 
  fizz = (i % 3 == 0)
  buzz = (i % 5 == 0)
  puts case
       when fizz && buzz then 'FizzBuzz'
       when fizz then 'Fizz'
       when buzz then 'Buzz'
       else i
       end
end
```

This implementation has a few advantages. If we wanted to replace `puts` with
something else, now we only have to change it in a single place instead of four.
In the naïve example, if we were to add an additional case to the `case` statement, we might
have forgotten to use `puts`, but that's not a problem here. Also, if the
definition of when to Fizz or Buzz changes &ndash; for example, if it should
Fizz on multiples of seven, instead of three &ndash; then we only need to change
one value instead of two. In summary, DRY is reducing the likelihood of
introducing bugs while updating the code.

But why stop there? I can still see duplication. The `i % _ == 0` pattern
appears twice, and the string literals `'Fizz'` and `'Buzz'` are duplicated
inside the `'FizzBuzz'` literal. Let's fix those up too.

```ruby
FIZZ = 'Fizz'
BUZZ = 'Buzz'

def divisible_by?(numerator, denominator)
  numerator % denominator == 0
end

1.upto(100) do |i| 
  fizz = divisible_by?(i, 3)
  buzz = divisible_by?(i, 5)
  puts case
       when fizz && buzz then FIZZ + BUZZ
       when fizz then FIZZ
       when buzz then BUZZ
       else i
       end
end
```

Now, if the "Fizz" or "Buzz" strings need to be changed, we've got that covered.
We're also covered if we want to change the way we test whether a number is 
divisible by another number. I don't know _why_ we would ever need to change that,
but hey, why stand in the rain of redundancy when everyone knows it's better
to stay DRY? By extracting the modulo operator (`%`) into its own function,
at least we've made the code more self-documenting. If someone else were to
read the code and they didn't understand how the modulo operator worked,
they could work it out based on the function name.

All these changes are aimed at insulating ourselves from bugs caused by
changing the code in the future. If you need to change something that exists in
multiple places, there is always the possibility that we will forget to change
one of those places.

We're not insulated from all changes, however. What if some pointy-haired suit
forces us to add a "Zazz" for multiples of seven? What if we have to handle an
arbitrary number of Fizzes and Buzzes and Zazzes? Maybe the users want to
define their own list of FizzBuzz values, with different output strings and
different multiples.

Parameterization
----------------

Let's level up the implementation by removing the hard-coded constants
and turning them into parameters. Here are the parameters that seem
reasonable to me:

 - The range of integers covered.
 - The text that is output.
 - The multiples that trigger text to be output

The new parameterized implementation looks like this:

```ruby
def fizzbuzz(range, triggers)
  range.each do |i|
    result = ''
    triggers.each do |(text, divisor)|
      result << text if i % divisor == 0
    end
    puts result == '' ? i : result
  end
end

fizzbuzz(1..100, [
  ['Fizz', 3],
  ['Buzz', 5],
])
```

FizzBuzz doesn't fit the needs of your users? No problem. Now you can
BlizzBlazz from -50 to -20, or WigWamWozzleWumpus from 10 to 10,000,000. You
name it.

We've introduced a new concept: triggers. A trigger is the pairing of a divisor
and an output string. There is no official name for this pairing, due to
FizzBuzz being a synthetic problem as opposed to a real-world problem, but it's
not that uncommon. We create abstract models of data and processes, and these
models contain things that need to be named. Often times there is a
pre-existing name we can use, but sometimes not. Note that this concept is
completely absent from previous implementations.

The `divisible_by?` function was removed, because the modulo operation only
happens in a single place now. It's already DRY, so we can inline it.

The `triggers` parameter is an array. This is important because it's called
"FizzBuzz", not "BuzzFizz". Ordering matters here.  We're using an array to
indicate that "Fizz" must come before "Buzz" in the situation were both are
triggered. If order was not important, we could have used a hash (a.k.a.
dictionary, map, associative array, etc.).

This implementation is actually more DRY than the last one. We can now see that
"fizz" and "buzz" are kind of duplicates of each other.  When they are combined
into a single array, we can get rid of the `FIZZ` and `BUZZ` constants, and
also the `fizz` and `buzz` variables, from the previous implementation.

<figure>
  <img src="/images/posts/fizzbuzz/but-wait-theres-more.png" />
</figure>

There are more potential parameters than just `range` and `triggers`. What if
we wanted to "Zazz" on all numbers less than 10? Our current implementation is
not flexible enough to handle that change. We can, however, accommodate this
change by parameterizing the "divisible by" condition.

```ruby
def fizzbuzz(range, triggers)
  range.each do |i|
    result = ''
    triggers.each do |(text, predicate)|
      result << text if predicate.call(i)
    end
    puts result == '' ? i : result
  end
end

fizzbuzz(1..100, [
  ['Fizz', ->(i){ i % 3 == 0 }],
  ['Buzz', ->(i){ i % 5 == 0 }],
  ['Zazz', ->(i){ i < 10 }],
])
```

This implementation gives the following (truncated) output:

```
Zazz
Zazz
FizzZazz
Zazz
BuzzZazz
FizzZazz
Zazz
Zazz
FizzZazz
Buzz
11
Fizz
13
14
FizzBuzz
16
... 
```

The definition of a "trigger" has changed. The divisor has been replaced
with a [predicate][]. For those unfamiliar with Ruby, `->(i){ i < 10 }` is
an anonymous function that takes a parameter, and returns a boolean
representing  whether the parameter is smaller than 10.

Once you start passing functions as parameters to other functions, there are
a _lot_ of things that can be parameterized. At the moment, the output
text from multiple triggers are combined by simple string concatenation,
but we could have a function parameter that controls how the strings
are combined. We could replace the `puts` with a function parameter
that controls what happens to the results. I'm going to stop parameterizing
at this point, just to keep this article shorter, but you get the idea.

Functional Programming (FP)
---------------------------

<blockquote class="pull-right">
  FP is so hot right now. All the cool kids are doing it.
</blockquote>

FP is so hot right now. All the cool kids are doing it. In all seriousness,
I do believe that programming in a functional style produces better software.
This isn't an article about the merits of FP, so let's just make the assumption
that it's something we aspire to, for the sake of brevity.

The last implementation is sort of written in a functional style already.
We've got a higher-order function (a function that takes a function parameter)
and we're using lambdas (anonymous functions).

We are mutating a string using the `<<` operator, though. In FP, we try to
avoid mutation in favour of using immutable values. However this is the least
troublesome type of mutation. We're only mutating local state, and then we
return the string and forget about it. Local scope is like Las Vegas: what
happens in local scope, stays in local scope. Nobody saw us mutating the
string, so nobody has to know. I think that everyone accepts that this sort of
temporary local mutation is totally fine, except maybe Haskell zealots.

The glaring FP faux pas in the current implementation is that the `fizzbuzz`
function has side effects. Specifically, it prints out text every time it is
called. If we get rid of the side effects, we will have a [pure function][],
which is something that we always strive for when writing in a functional
style. Here is an implementation that returns the output instead of printing
it:

```ruby
def fizzbuzz(range, triggers)
  range.map do |i|
    result = ''
    triggers.each do |(text, predicate)|
      result << text if predicate.call(i)
    end
    result == '' ? i : result
  end
end

puts fizzbuzz(1..100, [
  ['Fizz', ->(i){ i % 3 == 0 }],
  ['Buzz', ->(i){ i % 5 == 0 }],
  ['Zazz', ->(i){ i < 10 }],
])
```

The key difference is that `range.each` has been changed into `range.map`,
which converts the range into an array of outputs that is then returned.
Instead of printing each value with `puts`, we just `puts` the whole
array returned from the `fizzbuzz` function.

The output is the same as the previous implementation, but now we have
a pure function, with all the benefits that pure functions bring.

We can take the functional style even further:

```ruby
def fizzbuzz(range, triggers)
  range.map do |i|
    parts = triggers.select{ |(_, predicate)| predicate.call(i) }
    parts.size > 0 ? parts.map(&:first).join : i
  end
end

puts fizzbuzz(1..100, [
  ['Fizz', ->(i){ i % 3 == 0 }],
  ['Buzz', ->(i){ i % 5 == 0 }],
  ['Zazz', ->(i){ i < 10 }],
])
```

Again, this implementation produces the same output. However, the string
mutation has been removed, along with the procedural-style `triggers.each`
loop. The new implementation uses filter (called `select` in Ruby),
another `map`, and `join` (a kind of reduction). Map, filter and reduce
are the bread and butter of functional programming. This is probably
overkill, considering that `fizzbuzz` was already a pure function beforehand.

Lazy Generation
---------------

We've come a long way from the naïve implementation, but we can go further.
What if we needed to generate terabytes of output? Like, instead of calculating
pi to the billionth digit, we want to calculate FizzBuzz to the billionth
output.  Currently, the `fizzbuzz` function returns an array containing all
output, but we will run out of memory if we try to make a multi-terabyte array.
Plus, we can't start printing output until the _whole array_ is made. We
obviously have to stop generating and returning the whole array. In this
implementation, we generate a single output value, print it, throw it away,
then repeat.

```ruby
def fizzbuzz(start, triggers)
  Enumerator.new do |yielder|
    i = start
    loop do
      parts = triggers.select{ |(_, predicate)| predicate.call(i) }
      i_result = parts.size > 0 ? parts.map(&:first).join : i
      yielder.yield(i_result)
      i += 1
    end
  end
end

enumerator = fizzbuzz(1, [
  ['Fizz', ->(i){ i % 3 == 0 }],
  ['Buzz', ->(i){ i % 5 == 0 }],
  ['Zazz', ->(i){ i < 10 }],
])

loop { puts enumerator.next }
```

How you implement this really depends on the language you're in, so let me
explain this implementation for people who are unfamiliar with Ruby. Firstly,
instead of returning an array, the `fizzbuzz` function now returns an instance
of `Enumerator`. This particular `Enumerator` is an _infinite_ enumerator
&ndash; that is, it starts at a given integer and keeps generating the next
output value _forever_. `loop` starts an infinite loop. The
`yielder.yield` call contains magic that stops the infinite loop from hanging
the application. Every time that `enumerator.next` is called, the enumerator
will generate and return the next output value in the sequence. Finally, the
`loop` on the last line is another infinite loop that keeps printing the next
output value forever. Ruby can handle arbitrarily large integers, so this will
literally run until the `i` variable is a single number so big that it won't
fit in memory. That's a number so big that we can consider it infinite for all
practical purposes.

This is the concept of "laziness" in software design. Think of it like a
demotivated employee. They sit there doing nothing until you ask them for
something, then they do the minimum amount of work necessary to give you what
you asked for.

Although there is still some functional-style code at the core, this isn't very
functional anymore. Enumerators are stateful, and every call to `next` is
mutating the enumerator. This implementation is still DRY and parameterized,
though.

Polishing For Distribution
--------------------------

This FizzBuzz implementation is super flexible now &ndash; some might say _too_
flexible. We've got to open source it. This powerful, reusable functionality
needs to be made available to everyone.

But we can't just dump it on github. What about documentation, namespacing, and
unit tests? I mean, it's currently just a script that prints out results in an
infinite loop.

The last step &ndash; the last step I'm going to demonstrate in this article,
at least &ndash; is to polish the code for consumption by other developers. 
This should include writing tests, and usage documentation, but I'm not going
to show those here. Here is the ultimate FizzBuzz implementation:

```ruby
module FizzBuzz
  DEFAULT_RANGE = 1..100
  DEFAULT_TRIGGERS = [
    ['Fizz', ->(i){ i % 3 == 0 }],
    ['Buzz', ->(i){ i % 5 == 0 }],
  ]

  ##
  # Makes an array of FizzBuzz values for the given range and triggers.
  #
  # @param range [Range<Integer>] FizzBuzz integer range
  # @param triggers [Array<Array(String, Integer)>] An array of [text, predicate]
  # @return [Array<String>] FizzBuzz results
  #
  def self.range(range=DEFAULT_RANGE, triggers=DEFAULT_TRIGGERS)
    enumerator(range.first, triggers).take(range.size)
  end

  ##
  # Makes a FizzBuzz value enumerator, starting at the given integer, for the
  # given triggers.
  #
  # @param start [Integer] The first integer to FizzBuzz
  # @param triggers [Array<Array(String, Integer)>] An array of [text, predicate]
  # @return [Enumerable] Infinite sequence of FizzBuzz results, starting with `start`
  #
  def self.enumerator(start=DEFAULT_RANGE.first, triggers=DEFAULT_TRIGGERS)
    Enumerator.new do |yielder|
      i = start
      loop do
        parts = triggers.select{ |(_, predicate)| predicate.call(i) }
        i_result = parts.size > 0 ? parts.map(&:first).join : i.to_s
        yielder.yield(i_result)
        i += 1
      end
    end
  end

end
```

And here is some example usage code, with example output:

```ruby
FizzBuzz.range(1..5)
#=> ["1", "2", "Fizz", "4", "Buzz"]

FizzBuzz.range(1..5, [['Odd', ->(i){ i.odd? }]])
#=> ["Odd", "2", "Odd", "4", "Odd"]

e = FizzBuzz.enumerator
e.next #=> "1"
e.next #=> "2"
e.next #=> "Fizz"
e.next #=> "4"
e.next #=> "Buzz"
```

Everything is inside a module called `FizzBuzz`.  It's an anti-pattern for
third party code to pollute the global namespace, so we want to tuck everything
underneath a single namespace to be a good citizen.

All the code that prints the output is gone now. That's not really code worth
sharing. The reusable part is the output generation.

The `fizzbuzz` function has been renamed to `enumerator`, which better describes
its purpose.

All parameters are now optional. Maybe users want plain-old vanilla FizzBuzz
without all the fancy bells and whistles, so we provide sensible defaults.
Users of this implementation don't even have to learn what a "trigger" is if
they just want standard FizzBuzz output.

There is a new function called `range` that returns an array, like older
implementations used to.  You can't know what other peoples use case will be,
so it's not nice to force everyone to use the enumerator API if they don't need
it. The `range` function is a "convenience" function that provides a simpler
interface to a more complicated API. If you want to get all gang-of-four, you
could call it a "facade". It uses an enumerator under the hood, to keep things
DRY. 

One subtle difference is the `to_s` call. In previous implementations, the
output would either be a string _or an integer_. This is somewhat of a no-no.
We've just been printing the output values, and in Ruby you can print integers
or strings and everything works fine. But what if a user of the library writes
some code that only works for strings? It will crash on the integers. To avoid
confusion, this implementation converts integers to strings before returning
them. Now output values are always strings, so nobody has to account for two
different types.

All functions have documentation for parameters and return values. There should
also be a separate document that contains examples of how to use the library,
such as a README.md file.

The last step is to package up the code for whatever package management system
the language provides. In the case of Ruby, we'd be writing a gemspec
and a rakefile to build and tag versions of the gem, and publish builds to
[rubygems.org][].

What Have We Done?
------------------

<blockquote class="pull-right">
  The final implementation represents a <em>veritable explosion</em> of complexity.
</blockquote>

Let's reflect on the journey we have just taken. You may have thought that I
was demonstrating how to improve the code in every iteration. Or maybe you
thought that _I thought_ I was improving the code.  Not so. Every iteration
increased the complexity, and cost time. That's not what we want. We want
functionality without bugs, and we want it as cheaply as possible.

The first implementation uses these methods: `upto`, `%`, `==`, `puts`. It has
about 10 expressions/statements.

The final implementation uses these methods: `range`, `enumerator`, `first`,
`take`, `size`, `select`, `call`, `map`, `first`, `join`, `to_s`, `yield`, `+`,
`==`. It has about 20 expressions/statements. It has higher-order functions and
lambdas. It introduces the concept of triggers, and infinite enumerators. It
also comes with a bunch of documentation, tests, and other supporting files. On
top of that, it doesn't even print out the results &ndash; that part is left up
to the user of the library.

The final implementation represents a _veritable explosion_ of complexity.
Complexity bad. More code means more bugs, slower maintenance, and a steeper
learning curve for other developers.  We could have taken it further, too. We
could have done performance optimisation, added concurrency, etc. There are
plenty more ways to parameterize the code. Soon enough, you're
implementing a [DefaultFizzBuzzUpperLimitParameter][], several
levels deep into an inheritance hierarchy.

You Ain't Gonna Need It
-----------------------

<blockquote class="pull-right">
  We must be honest with ourselves about our requirements.
  When we choose the quick but inflexible implementation, we're usually saving time.
</blockquote>

I guess what I'm trying to get at here is the essence of YAGNI: You Ain't Gonna
Need It. YAGNI is up there with DRY, in terms of importance. If you're not
_certain_ that you need it, then YAGNI. But isn't it better to add the
flexibility now, so we save time later when the change request comes in? YAGNI.
Adding flexibility isn't free. It costs time, and it adds _unnecessary
complexity_ to the codebase. Complexity is like a mortgage &ndash; you're going
to be paying interest on it. You may have heard of the term "technical debt"
before.

When we choose the quick but inflexible implementation, we're usually saving time. 
If a change request comes in later, we can spend that saved time implementing
the more complex solution. If the change request _doesn't_ come in, then
we win! We're laughing all the way to the chronological bank.

Does that mean that the final and most complex implementation is a waste of
time? Usually, but not always. Maybe you truly need to generate a few terabytes
of FizzBuzz output. A simple implementation is not going to cut it, in that case.
Maybe you have strange requirements which make all that parameterization
necessary. Maybe it's going to be used by lots of other developers in lots of
other projects. The implementation that you choose really depends on your exact
requirements.

But we must be honest with ourselves about our requirements. Do we _really_
need terabytes of boutique FizzBuzz output? Really? Is it written in stone
somewhere? Can we start with a simpler implementation, and extend it if it
becomes necessary? In the absence of a definitive answer, lean towards YAGNI.

[invented by Imran Ghory]: http://imranontech.com/2007/01/24/using-fizzbuzz-to-find-developers-who-grok-coding/
[popularized by Jeff Atwood]: http://blog.codinghorror.com/why-cant-programmers-program/
[implementations in every language]: http://rosettacode.org/wiki/FizzBuzz
[joke implementations]: https://github.com/EnterpriseQualityCoding/FizzBuzzEnterpriseEdition/blob/00097ff1aae1045448811ebbe9a51429e6831d25/src/main/java/com/seriouscompany/business/java/fizzbuzz/packagenamingpackage/impl/Main.java
[predicate]: http://en.wikipedia.org/wiki/Predicate_%28mathematical_logic%29
[pure function]: http://www.sitepoint.com/functional-programming-pure-functions/
[rubygems.org]: http://rubygems.org/
[DefaultFizzBuzzUpperLimitParameter]: https://github.com/EnterpriseQualityCoding/FizzBuzzEnterpriseEdition/blob/00097ff1aae1045448811ebbe9a51429e6831d25/src/main/java/com/seriouscompany/business/java/fizzbuzz/packagenamingpackage/impl/parameters/DefaultFizzBuzzUpperLimitParameter.java
