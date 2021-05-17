{:title "Write Detailed RSpec Example Descriptions"
 :main-image {:uri "/images/posts/microscope.jpg"}
 :tags [:testing :mentoring]
 :category :mentoring}

## Rule Of Thumb

RSpec examples should have enough detail in the descriptions to
rewrite them from scratch.

<!--more-->

## Background

In the early days of automated testing there was some test code, which
would exercise the implementation code, and make assertions about the
results --- something like:

```ruby
def test_addition
  assert(UInt8.add(1, 2) == 3)
  assert(UInt8.add(255, 1) == 0)
  assert_raises(ArgumentError) { UInt8.add(1, 256) }
  assert_raises(ArgumentError) { UInt8.add(1, -1) }
end
```

Some time in the early 2000s a slightly different style of testing
evolved called behaviour-driven development (BDD), which produced
RSpec and Cucumber.

To oversimplify, what makes BDD different is the conceptual shift from
writing _tests_ to writing _specifications_ (_specs_ for short). A
test is anything that exercises the implementation and makes
assertions about the results, whereas a spec is a detailed description
of desired behaviour. The test above might be written in RSpec like:

```ruby
RSpec.describe UInt8 do
  it 'adds unsigned 8-bit integers' do
    expect(subject.add(1, 2)).to eq(3)
  end

  it 'wraps when addition results in an overflow' do
    expect(subject.add(255, 1)).to eq(0)
  end

  it 'raises an error when given an integer outside the unsigned 8-bit range' do
    expect { subject.add(1, 256) }.to raise_error(ArgumentError)
    expect { subject.add(1, -1) }.to raise_error(ArgumentError)
  end
end
```

It's relatively common to see RSpec used to write _tests_, not
_specs_. For example:

```ruby
RSpec.describe UInt8 do
  it 'works' do
    expect(UInt8.add(1, 2)).to eq(3)
    expect(UInt8.add(255, 1)).to eq(0)
    expect { UInt8.add(1, 256) }.to raise_error(ArgumentError)
    expect { UInt8.add(1, -1) }.to raise_error(ArgumentError)
  end
end
```

## Rationale

This rule of thumb --- that each RSpec example description should
contain enough detail to rewrite it from scratch --- is one way to
ensure that you're writing specs, not just tests.

Imagine that the subject under test and all the example bodies were
deleted. If the RSpec file was written in proper BDD style, we should
be able to rewrite them based on the example descriptions alone. The
implementation may not be exactly the same, but all of the desired
behaviours should be there.

```ruby
RSpec.describe UInt8 do
  it 'adds unsigned 8-bit integers'
  it 'wraps when addition results in an overflow'
  it 'raises an error when given an integer outside the unsigned 8-bit range'
end
```

But if the RSpec file is being used as a simple test, it would be
impossible to know what the desired behaviours were.

```ruby
RSpec.describe UInt8 do
  it 'works'
end
```

The purpose of BDD, and the intention behind RSpec, is to capture a
specification of desired behaviour. So one reason to write detailed
example descriptions in RSpec is that you're using the tool the way it
was intended to be used.

Without going too deep into the rationale behind BDD, there are a few
other benefits.

When an example fails, a good description will tell you which is
broken: the example or the implementation. Without an understanding of
the intended behaviour, it's easier to accidentally "fix" a failing
example by making it pass when the implementation produces incorrect
results. This is more likely to happen when the correct behaviour is
ambiguous.

RSpec example descriptions also function as a kind of documentation
between developers, communicating how parts of the codebase work.
RSpec's `documentation` formatter is evidence of this. If you're
writing specs in a BDD style, the output of this formatter should be
an understandable list of behaviours...

```
> rspec --format documentation

UInt8
  adds unsigned 8-bit integers
  wraps when addition results in an overflow
  raises an error when given an integer outside the unsigned 8-bit range

Finished in 0.00149 seconds (files took 0.10574 seconds to load)
3 examples, 0 failures
```

... not a list of method names and "works correctly".

```
UInt8
  #add
    adds correctly
  #subtract
    works
```
