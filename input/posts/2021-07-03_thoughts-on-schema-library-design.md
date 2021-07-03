{:title "Thoughts On Schema Library Design"
 :main-image {:uri "/images/posts/floorplan.jpg"}
 :category :software-design}

It's that time of year again. It seems like about once a year I get
interested designing a schema library. This post is a collection of my
latest ideas and design goals, mostly based on what I've learnt from
the previous three or four implementations.

This topic is probably interesting to a tiny subset of developers, and
super boring to everyone else. I've tried to write this post in a way
that is accessible to a wider developer audience, but you have been
warned!

 <!--more-->

## WTF Is A Schema Library

The word "schema" comes from the ancient Greek for "form" or "shape".
In computery terms, a schema is a data structure that describes the
shape of data. Schemas are metadata: data about data. They are
typically used to filter/validate/coerce values in some way.

The fastest way for me to demonstrate the concept is probably to just
show a few different implementations.

[React `PropTypes`][proptypes] are schemas that do type checking on
React component properties.

```javascript
AuthorComponent.propTypes = {
  name: PropTypes.string,
  isVerified: PropTypes.bool,
}
```

Database table schemas describe the columns of a database table. In
PostgreSQL this can be [queried like a table][pg_ex], so it's kind of
a table of data that describes the shape of other tables.

```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'authors';
```

     column_name | data_type
    -------------+-----------
    id           | integer
    name         | text
    is_verified  | boolean
    (4 ROWS)

Making our way into Ruby land, [Rails Strong Parameters][] are (in my
opinion very poor) schemas that describe the structure of request
parameters.

```ruby
params.permit(:name, { emails: [] },
              friends: [ :name,
                         { family: [ :name ], hobbies: [] }])
```

The [stronger_parameters gem][] is a more-featureful alternative to
Strong Parameters, and looks a lot more like a typical schema library.

```ruby
params.permit(
  name: Parameters.string.required, # will not accept a nil or a non-String
  is_verified: Parameters.boolean   # optional, may be omitted
)
```

I think the best schema library in Ruby is currently [dry-schema][].

```ruby
AuthorSchema = Dry::Schema.Params do
  required(:name).filled(:string)
  required(:is_verified).value(:bool?)
end
```

To summarize, what all these implementations have in common is that
they describe the structure and/or types (i.e. the "shape") of complex
values.

On the off chance that this appears on Hacker News or any other
wretched hive of scum and vapidity, I should address the "lol dynlang
people reinventing compilers badly" reaction. There is a lot of
overlap between type systems and schemas libraries, but schemas are
primarily designed for checking user input, not function signatures.
Let me know when you're running your compiler in production to handle
web requests.

[proptypes]: https://www.npmjs.com/package/prop-types
[pg_ex]: https://www.postgresql.org/docs/current/information-schema.html
[dry-schema]: https://dry-rb.org/gems/dry-schema/
[stronger_parameters gem]: https://github.com/zendesk/stronger_parameters
[Rails Strong Parameters]: https://edgeguides.rubyonrails.org/action_controller_overview.html#strong-parameters


## Schemas In Web Apps

The typical use case for a web app is to sanitise inputs before
actually performing a request. My current view is that this can be
broken down into three distinct phases or steps:

1. Coercion
2. Constraint checking
3. Validation

These need to happen in order, and ideally should report failures in a
standardised way.

### Step 1. Coercion

Coercion is the process of converting a value to its "real" type. How
do we know what the "real" type is? The schema tells us.

For example, web forms submit everything as strings, so if you want an
integer you need to do string-to-integer coercion.

Similarly, we do string-to-time coercion quite often. If you've
ever parsed an input string into a date/time object, you've
implemented a kind of coercion.

Like the other steps, this can fail. Not all strings can be converted
into an integer in a sane way. There will be more on failures later.

### Step 2. Constraint checking

Just converting a value to the right _class_ doesn't necessarily mean
it's the right _type_. For example, the string `"-1"` can be coerced
to the integer `-1`, but that's still not a valid value if the type is
supposed to be an _unsigned_ integer (i.e. a non-negative integer).

This constraint checking step narrows down the set of valid values
from _everything_ (e.g. all integers) to a _subset_ (e.g. non-negative
integers).

As another example, a schema library might differentiate between
_any string_ and _strings with a specific format_. Let's say we're
writing a JSON web API that takes UUIDs as input. They will probably
come in as strings, but we don't want to accept any old string, we only
want to accept strings that have the correct UUID format. The format is
a constraint that reduces the infinite set of all strings down to a
finite subset of valid strings.

### Step 3. Validation

These are business rules. If an integer value represents money to
send, you might validate that there are sufficient funds to cover the
amount.

This is outside the scope of a schema library **but** failures are
usually rendered/handled in the same way across all steps. This brings
us to...

## Working With Failures

Schema failures and validation failures should be compatible, or at
least easy to map from one to the other, because all three steps
happen on the same pipeline. A piece of user input enters the
application, and needs to be cleaned up, converted, sanitised and
checked before it makes its way further into the system.

Ideally, failures at any point in the pipeline get returned to the
requester in a consistent, unified way. We don't want to be writing
three independent ways to render failures just because we're using
three different libraries. That means that all the different parts of
the pipeline need to play nice together, when it comes to returning
information about failures.

For example, Rails apps tend to be built around `ActiveModel::Errors`,
so when schema validation fails it probably makes sense that the
schema library returns `ActiveModel::Errors` objects (ew) or returns
something that can be mapped to an `ActiveModel::Errors` object
without losing fidelity.

Raising an exception with a single message string is not good enough.
At a minimum, I would expect:

- The ability to get _all_ the failures, not just the first one that
  was encountered.
- I18n compatibility, for human interfaces
- Symbolic, namespaced error names with machine-readable details, for
  computer interfaces
- Enough structural information that the failure can be associated
  with the exact input field that produced the failure, within a
  complex form

## Why Make A Distinction Between Validation And Constraint Checking?

Personally, I think general-purpose input validation is outside the
scope of a schema library. You have to draw the line somewhere.

In my mind, schemas are intuitively good for simple checks like:

- Is this an integer?
- Is it non-negative?
- Is this a `Hash`?
- Is this hash missing any required keys?
- Is this a string?
- Is the string empty?

These are all easy checks that can be applied to a single value. They
are the kind of thing one might expect from a type system, and schema
libraries are kind of type systems if you squint your eyes and tilt
your head slightly.

<blockquote class="pull-right">
  Don't hurt me, Haskell people. I'm just joking in the category of
  endofunctors of &#x1D44B;, with product &#x2715; replaced by
  composition of endofunctors and unit set by the identity
  endofunctor.
</blockquote>

What one would _not_ normally expect from a type system is that the
type of one variable depends on the _run-time value_ of a different
variable, or that type checking requires access to a database. Yes,
there are fancy type systems with dependent types that can do these
kind of things, but they are not widely used. I mean, they are so
obscure that even _Haskell_ doesn't have that capability, and nobody
actually uses Haskell, they just say that they do.

The story is different when it comes to general-purpose validation.
Checking a value against something in the database is absolutely
necessary, and checking two separate values against each other is
common (e.g. validating that `starts_at` is earlier than `ends_at`). I
would rather leave this higher-level business logic to some other
library that specialises in that functionality.

There is no reason that a lower-level schema library and a
higher-level validation library can't work together. Schema libraries
are a bad fit for business logic, and validation libraries are usually
too cumbersome for lots of pedantic type checking, so they actually
complement each other quite well. Rails has both Strong Parameters and
model validations, and together they work... passably.

## Coercion Is Context-Dependent

Constraint checking (Step 2) is universal. A non-negative integer is a
non-negative integer, regardless of whether it came from a JSON API, a
web form, CLI arguments, etc. The same is true for validation (Step 3)
--- it doesn't matter _how_ you requested a money transfer, there are
either sufficient funds or there are not.

But the same is not true for coercion (Step 1). Coercion is
context-dependent, and that has implications for designing a schema
library.

<blockquote class="pull-right">
  Apple's bug was caused by type inference <em>without</em> a schema.
  Schema-based coercion would have never converted <code>lastName</code> to a
  boolean, because the schema would have indicated that <code>lastName</code>
  should be a string. That's their whole purpose.
</blockquote>

As an example, let's say we have a schema for a boolean value. If the
input comes from a JSON request body then no coercion is necessary,
because JSON can represent `true` and `false` natively. Not only is it
unnecessary, it's probably also undesirable. If a client provides a
string where it should have provided a boolean, that's a mistake that
the client should be made aware of. Silently coercing strings to
booleans is how Rachel True got locked out of her iCloud account for
six months with the error message "cannot set value \`true\` to
property \`lastName\`".

<widget type="tweet" href="https://twitter.com/RachelTrue/status/1365461618977476610" />

But if that boolean input comes from a checkbox in a web form, then
coercion is a must, and it's also kind of complicated. Firstly, the
value comes in as a string. The default string is `"on"`, but it can
actually be set to _anything_. That's right, the strings `"off"` and
`"false"` could actually indicate that the checkbox was checked. So
what string gets sent when the checkbox is unchecked? That's a trick
question --- the browser doesn't send anything, as if the form had no
checkbox at all. But wait, is this a Rails app? Because Rails adds
hidden form inputs that only get submitted if the checkbox is
unchecked, so the string `"0"` should be interpreted as `false`.

Things went from _no_ coercion to _woah_ coercion, real fast. And the
schema shouldn't be concerned about any of this. There absolutely
should not be a `JSONBoolean` type and `WebFormBoolean` type. A
`Boolean` is a `Boolean` --- where the input comes from is irrelevant.

One of the mistakes I made in previous designs was treating schema
objects as if they were functions that could be applied to input ---
something like this:

```ruby
schema = RSchema.define { boolean }

result = schema.validate("1")
result.value #=> true
```

This is a mistake because it assumes that there could be a single
implementation of coercion that is correct for all situations, when in
reality there are many different ways to coerce a boolean, and the
correct choice depends on the context.

To avoid this mistake next time, I plan to...

## Consider Schemas As Data Structures

<blockquote class="pull-right">
  Don't hurt me, object-oriented people. I'm just making a joke using
  the polymorphic joke builder interface encapsulating the concrete
  joke builder implementation that I got from the abstract joke
  builder factory which got setter-injected by the DI framework. I
  specifically used setter instead of constructor injection so nobody
  can accuse me of using immutability.
</blockquote>

OOP teaches us that good code combines encapsulated state (instance
variables) with behaviour that is privy to that state (methods). Not
to go on a rant, but that's a bunch of poppycock and flapdoodle. As
Freud once said, "sometimes a data structure is just a data structure".

Probably the primary application of schemas is validating input, but
there are several useful applications.

- Various different flavours of coercion
- User input validation
- Code generation
- Automated API documentation
- Generating random valid inputs for property-based testing
- Versioning structured data (e.g. event payloads)
- Run-time assertions
- Conversion to other schema formats (e.g. JSON Schema)

That is way too many responsibilities to cram into a single class, if
we were to use one class per type.

The solution to this design problem is pretty simple, in hindsight.
Just stop thinking of schemas as objects. Think of them as data
structures, and think of every application as a function that takes
the schema as an argument.

```ruby
# no
coerced_input = schema.coerce_json(json_input)
coerced_input = schema.coerce_web(form_input)
coerced_input = schema.coerce_cli(cli_args)
result = schema.validate(coerced_input)
docs = schema.to_documentation
value = schema.random_value
json = schema.to_json_schema

# yes (pseudocode)
coerced_input = coerce_json(input, schema)
coerced_input = coerce_web(input, schema)
coerced_input = coerce_cli(input, schema)
result = validate(coerced_input, schema)
docs = generate_documentation_for(schema)
value = generate_random_value_for(schema)
json = json_schema_for(schema)
```

This solves a lot of design problems I have previously created for
myself. I'm kind of kicking myself for not realising this earlier.
There are plenty of examples of people doing this already (e.g. JSON
Schema). I was blinded by focusing too much on the validation use
case.

Next time, I'm not going to implement any kind of validation behaviour
on schema classes (or any other kind of feature). The single
responsibility of a schema will be to _represent_ a type, as a simple
tree structure. There will probably be some behaviour for traversing
the tree using a common interface, but that's about all it needs.

Coercion, validation, and all the other features can then be
implemented separately, as independent functions. Some of those
functions will be complicated --- coercion, for example, requires
walking two tree structures in synchrony (the schema and the
input), triple dispatch (applying behaviour based on the kind of
coercion, the kind of schema, and the kind of input), and building a
complex return value (see _Working With Failures_ above) --- but I
think decomposing the functionality this way will be a huge
simplification overall.

I'm toying with a proof-of-concept implementation, and it's looking
good so far. I want to keep an eye on performance --- not too many
allocations, and doing coercion and validation with a single
traversal of the input/schema tree (instead of two traversals). The
other tricky part is making everything extensible, so that
user-defined types can opt-in to functionality in a piecemeal way.
Defining a new type from scratch should be easy, and shouldn't require
implementing functionality that you don't intend to use --- that is,
if you don't intend to use your new type for validation, you shouldn't
be forced to write any code related to validation.

## Summary

What I'm looking for from a schema library is:

- a suite of built-in types that represent the most common stuff like
  strings, numbers, arrays and hashes

- the ability to add custom types to the suite _easily_, and have the
  custom types be 100% as powerful as the built-in ones

- when implementing custom types, to be able to only implement the
  functionality I intend to use, ignoring the features I don't
  care about

- a suite of built-in coercion behaviours, and the ability to add
  custom implementations that are just as powerful

- the ability to reuse a single schema across multiple different
  contexts, with different kinds of coercion behaviour

- context-independent constraint checking, that goes beyond just
  looking at a value's class

- rich failure details, that can be integrated into various different
  validation failure workflows (e.g. `ActiveModel::Errors` in Rails)
  without losing fidelity

- an extensible way to implement new _applications_ for schemas, such
  that one gem could provide this new feature, a completely separate
  gem could provide some custom types, and a third gem could provide
  the integration between the new feature and the custom types

- the ability to treat schemas as simple data structures, that can be
  converted to, and imported from, other formats (e.g. JSON Schema)

- good performance, in terms of memory allocations and efficient
  traversal of the input/schema tree

I'm not aware of any schema library that meets all these criteria, in
any programming language. Even Clojure's [schema][clj_schema] and
[spec][clj_spec] libraries, considered by some to be best in class, do
not tick all the boxes. I know, because I've tried to steal parts of
their design to improve my own, and discovered that they have the
exact same limitations I was running into.

[clj_schema]: https://github.com/plumatic/schema
[clj_spec]: https://clojure.org/about/spec

I'm in the very early stages of progress towards this ideal schema
library. I've been tinkering with a proof of concept design in
Ruby recently. There are still some unknowns to iron out, but it's
looking promising at the moment. This is no announcement or guarantee
that I will finish and release a library, but it's a topic that I keep
coming back to year after year, so maybz it will happen some day.
