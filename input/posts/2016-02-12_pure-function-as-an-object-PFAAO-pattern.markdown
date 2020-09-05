{:title "The Pure Function As An Object (PFAAO) Ruby Pattern"
 :disqus-id "com.tomdalling.blog.pure-function-as-an-object"
 :main-image {:uri "/images/posts/ruby.jpg"
              :artist {:name "Rob Lavinsky, iRocks.com"
                       :url "http://www.irocks.com/"}}
 :category :ruby}

In this article, I want to demonstrate a nice way to write functional-style code in Ruby.
It is a way to write non-trivial pure functions, without a bunch of weird non-idiomatic code.
Also, the acronym is PFAAO, which I think sounds pretty cool.

<!--more-->

Pure Functions
--------------

Pure functions are functions that have no side-effects, and whose return values are only determined by their arguments.
Given the same arguments, a pure function will always return the same value.
It does nothing other than generate a return value &ndash; it doesn't affect anything, anywhere else in the program.

Pure functions are the core concept of functional programming (FP).
I'm going to gloss over the benefits of FP, because there are plenty of other articles about that.
Let's just say that pure functions are good, and you should be writing them wherever possible.


The Example: A JSON To XML Converter
------------------------------------

To demonstrate this pattern, I'm going to write a program that converts a JSON document to XML.
The whole example project is available on GitHub, here: <https://github.com/tomdalling/pure-function-as-an-object>

The input looks like this:

```json
{ "city" : "AGAWAM", "loc" : [ -72.622739, 42.070206 ], "pop" : 15338, "state" : "MA", "_id" : "01001" }
{ "city" : "CUSHMAN", "loc" : [ -72.51564999999999, 42.377017 ], "pop" : 36963, "state" : "MA", "_id" : "01002" }
{ "city" : "BARRE", "loc" : [ -72.10835400000001, 42.409698 ], "pop" : 4546, "state" : "MA", "_id" : "01005" }
{ "city" : "BELCHERTOWN", "loc" : [ -72.41095300000001, 42.275103 ], "pop" : 10579, "state" : "MA", "_id" : "01007" }
{ "city" : "BLANDFORD", "loc" : [ -72.936114, 42.182949 ], "pop" : 1240, "state" : "MA", "_id" : "01008" }
```

And the output looks like this:

```xml
<?xml version="1.0"?>
<cities count="5">
  <city id="01001" name="AGAWAM" state="MA" location="-72.622739,42.070206" population="15338"/>
  <city id="01002" name="CUSHMAN" state="MA" location="-72.51565,42.377017" population="36963"/>
  <city id="01005" name="BARRE" state="MA" location="-72.108354,42.409698" population="4546"/>
  <city id="01007" name="BELCHERTOWN" state="MA" location="-72.410953,42.275103" population="10579"/>
  <city id="01008" name="BLANDFORD" state="MA" location="-72.936114,42.182949" population="1240"/>
</cities>
```

We will only be using the Ruby 2.3.0 standard library, and the [Ox gem](https://github.com/ohler55/ox) for writing the XML.

Let's get started!


Designing The API
-----------------

After gathering the requirements, the next step is to ask: how much of this can be implemented with pure functions?

As it turns out, pretty much the entire thing could be a pure function.
Reading the input is non-pure, and writing the output is also non-pure, but the entire conversion from JSON to XML _is_ pure.
The same input JSON always produces the same output XML.

The API for this converter could be used like this:

```ruby
input = File.read('input.json')
output = JSON2XML.convert(input)
File.write('output.xml', output)
```

This example code could easily be written as a test.
Just use some dummy input, and assert that `output` is correct.

Because the `File.read` and `File.write` calls are non-pure, I have purposely kept them separate from the conversion code.
That allows the conversion step to be implemented as a pure function -- it just takes a string and returns a string.

This API looks pretty good to me, assuming that the input data isn't too big.
If the input data set was huge, we wouldn't be able to load the whole thing into memory, so we would need so write some sort of streaming API.
But, for the sake of demonstration, let's assume that we've investigated this possibility and decided that it's very unlikely that the input will ever be more than a few megabytes.

<div class="alert alert-info">
  This is an example of the
  <a href="http://mollyrocket.com/casey/stream_0029.html">&quot;write the usage code first&quot; school of API design</a>,
  as advocated by Casey Muratori.
  For more API design advice from Casey, I recommend watching his talk:
  <a href="http://mollyrocket.com/casey/stream_0028.html">Designing and Evaluating Reusable Components</a>.
</div>


The Motivation
--------------

The public API consists of a single method, which will be the pure function.
Let's start with that:

```ruby
require 'json'
require 'ox'

module JSON2XML
  def self.convert(input_json)
    # TODO: implementation goes here
  end
end
```

We could easily implement all the functionality by writing a bunch of pure methods on the `JSON2XML` module, without defining any new classes.
It would work, but I personally don't think that this is how Ruby is designed to be used.
It's not what most people would consider to be idiomatic Ruby.
We would be fighting the language &ndash; going against the grain.
That's not fun.

To use Ruby the way it is designed to be used, we will need to define a class here.
However, the class is unnecessary.
It's an implementation detail.
The public API is just a single pure function, so nobody should ever need to instantiate an object of the class we're about to create.

This is the motivation behind the pattern: we want the public API to be a simple pure function, but we want to implement that function with a private class.


The Pattern
-----------

Without further ado, here is the pattern:

```ruby
require 'json'
require 'ox'

class JSON2XML
  def self.convert(input_json)
    new(input_json).send(:xml)
  end

  private
    def initialize(input_json)
      @input_json = input_json
    end

    def xml
      # TODO: implementation goes here
    end
end
```

Instead of a module, `JSON2XML` is now a class.
Everything below the `convert` method is marked as private, signalling to other developers that `convert` is the only thing they should be calling, and everything else is an implementation detail.
The `xml` method can't be called directly because it is private, so we use `send(:xml)` to get around that.

The `convert` class method:

 1. creates an object of its own class,
 2. passing its argument into the initializer,
 3. and calls a single method on the object, to generate the return value.

That's the overview of how the pattern works.


Implementation Advantages
-------------------------

Now let's finish off the implementation of the JSON to XML converter, to demonstrate some advantages of using this pattern.

The `xml` method is empty at the moment.
It's supposed to return the output XML as a string, as required by the `convert` class method.
How do you generate XML?
One approach is to take some sort of XML "document" object, and serialize it.
Let's do that:

```ruby
def xml
  Ox.dump(document, with_xml: true)
end
```

"But wait!"
I hear you say.
"There is no `document` object. It doesn't exist."
Let's create it, then.

How do you make a document object?
Since we're using the Ox gem, we need to instantiate an `Ox::Document` and fill it with all the output.
XML documents are only supposed to have a single root node in them, so all the content will have to be inside that.

```ruby
def document
  Ox::Document.new(version: '1.0').tap do |doc|
    doc << root_node
  end
end
```

"But wait!"
I hear you say, again.
"Where did this `root_node` come from? That's not defined anywhere."
Let's create it, then.

How do you make the root node?
In Ox, you instantiate a `Ox::Element` object.
We have to fill the root node with all the output data, so each city will have its own node inside the root node.
Also, the root node has a "count" attribute on it, for reasons that I will explain later.

```ruby
def root_node
  Ox::Element.new('cities').tap do |root|
    root[:count] = city_nodes.size
    city_nodes.each { |city| root << city }
  end
end
```

"But wait!"
I hear you say, for a third time.
"`city_nodes` doesn't exist either!"
Let's create it.
I'm sure you're getting the gist of what's happening here.

Each city node is also an `Ox::Element` object.
We can create a city node from each line of the JSON input.

```ruby
def city_nodes
  input_json.each_line.map { |line| parse_city_node(line) }
end
```

The `input_json` method is missing.
That is the string value that was passed into the initializer.
We can implement that with a simple `attr_reader :input_json`.

The `parse_city_node` method needs to be implemented, too.
Here it is:

```ruby
def parse_city_node(line)
  Ox::Element.new('city').tap do |city|
    attrs = JSON.parse(line)

    city[:id] = attrs.fetch('_id')
    city[:name] = attrs.fetch('city')
    city[:state] = attrs.fetch('state')
    city[:location] = attrs.fetch('loc').join(',')
    city[:population] = attrs.fetch('pop').to_s
  end
end
```

"But wait!"
I don't hear you say, because the implementation is now complete.
Here is the whole class:

```ruby
class JSON2XML
  def self.convert(input_json)
    new(input_json).send(:xml)
  end

  private
    attr_reader :input_json

    def initialize(input_json)
      @input_json = input_json
    end

    def xml
      Ox.dump(document, with_xml: true)
    end

    def document
      Ox::Document.new(version: '1.0').tap do |doc|
        doc << root_node
      end
    end

    def root_node
      Ox::Element.new('cities').tap do |root|
        root[:count] = city_nodes.size
        city_nodes.each { |city| root << city }
      end
    end

    def city_nodes
      input_json.each_line.map { |line| parse_city_node(line) }
    end

    def parse_city_node(line)
      Ox::Element.new('city').tap do |city|
        attrs = JSON.parse(line)

        city[:id] = attrs.fetch('_id')
        city[:name] = attrs.fetch('city')
        city[:state] = attrs.fetch('state')
        city[:location] = attrs.fetch('loc').join(',')
        city[:population] = attrs.fetch('pop').to_s
      end
    end
end
```

What I've just demonstrated is a top-down decomposition of the entire implementation.
You start with the desired output &ndash; in this case, an XML string &ndash; and work backwards.
You write the code that you wish existed, and implement it later.
This is a nice way to break down complicated algorithms into smaller, and smaller pieces.

This is all made possible by Ruby's syntax.
Ruby blurs the line between local variables and a method calls.
This allows us to write identifiers representing values that we wish we had, as if they already exist as local variables, and then implement them later as methods.
We're working with grain of the language, and this is one of the benefits.

Notice how none of the methods have side effects.
Each method in the class is itself a pure function.
The `@input_json` instance variable is never changed &ndash; it's essentially a constant.
Because of that, we would expect that every method would always have the same return value.
For example, if I call the `xml` method three times, I would get three identical strings.
To use FP terminology, all of the methods have _referential transparency_.


Performance Optimisation
------------------------

Astute readers may have noticed a performance hiccup in the `root_node` method.

```ruby
def root_node
  Ox::Element.new('cities').tap do |root|
    root[:count] = city_nodes.size
    city_nodes.each { |city| root << city }
  end
end
```

I put the "count" attribute on the root node to demonstrate a common performance problem with this pattern.

The problem is that `city_nodes` is called two times.
That means we're parsing the entire data set twice.
That is unnecessary, and roughly doubles the run time of the conversion.

Thankfully, due to all the methods being pure, we have a simple solution to this problem: memoization.
Memoization is the caching of return values from pure functions.

We've already seen that the `city_nodes` method always returns the same value.
That means we can cache the return value the first time the function is called.
On all subsequent calls, we can just return the cached value without running the rest of the function.

Cache invalidation can be a tricky problem, but not in this case.
When do we need to invalidate the cache?
Never!
It's a pure function.
The return value literally never changes.
We can just forget about cache invalidation completely.

Here is the solution:

```ruby
def city_nodes
  @city_nodes ||=
    input_json.each_line.map { |line| parse_city_node(line) }
end
```

The function implementation is exactly the same, except for the `@city_nodes ||=` line that has been added.
This trick isn't specific to the PFAAO pattern, it's just normal, idiomatic Ruby.

Now we can call `city_nodes` as many times as we like, from any other method, without having to worry about performance.
This is a cleaner solution than storing the return value in a local variable before using it.


When To Use PFAAO
-----------------

This pattern is good for implementing complicated pure functions.
I've written a DOCX to HTML converter this way, quite happily.

If the implementation is simple, it's not really worth defining a new class &ndash; just write a slightly larger function.
If you're writing a pure function and it's growing out of control, that is the time to consider using this pattern.

Where the implementation is mostly pure, but not completely, you can still use this pattern.
The implementation will be more complicated, but still have a small and simple public API.
Ruby isn't Haskell.
We can use side effects, in a controlled fashion, wherever it makes sense.

If your implementation requires a lot of mutable state, PFAAO is probably a bad fit.


Optional Extras
---------------

 -  **Disallow instantiation of the class.**  
    Unfortunately, making `initialize` private does not prevent instantiation of the class.
    The fact that everything is private except the class method should indicate that the class isn't meant to be instantiated.
    If that's not strict enough for you, you can make Ruby raise an error by adding this line of code to the class definition:

    ```ruby
    private_class_method :new
    ```

 -  **Make it quack like a Proc.**  
    Objects that act like functions, such as `Proc` objects, are invoked using the `call` method in idiomatic Ruby.
    I named the class method `convert` in the example above, but if you changed that to `call` you could use the class as if it were a `Proc`.
    In that case, I would change the class name to `XML2JSONConverter` to keep the word "convert" in there.

 -  **Make it convertable to a Proc.**  
    Let's say you're using this PFAAO as a block fiarly often, like this:

    ```ruby
    documents.map{ |d| XML2JSON.convert(d) }
    ```

    It would be nicer to just pass the block argument using ampersand syntax like this:

    ```ruby
    documents.map(&XML2JSON)
    ```

    To make this a reality, implement the `to_proc` method on the class, like this:

    ```ruby
    def self.to_proc
      method(:convert).to_proc
    end
    ```


Conclusion
----------

It is possible, and even preferable, to write Ruby in a functional style.
No monads or category theory required.
Complicated pure functions can be written in idiomatic Ruby.

Again, you can get the code for the article from GitHub:
<https://github.com/tomdalling/pure-function-as-an-object>

We've also learnt that PFAAO is a cool acronym.
Say it out loud.
PFAAO. PFAAO.

PFAAO...
