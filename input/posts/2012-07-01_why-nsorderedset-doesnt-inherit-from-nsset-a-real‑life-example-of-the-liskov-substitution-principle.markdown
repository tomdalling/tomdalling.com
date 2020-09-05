{:title "Why NSOrderedSet Doesn't Inherit From NSSet - A Real‑life Example of the Liskov Substitution Principle"
 :disqus-id "627 http://tomdalling.com/blog/?p=627"
 :category :software-design}

There was an interesting question on StackOverflow this morning: [Why doesn't
NSOrderedSet inherit from NSSet?][] It's interesting because the reason is so
easy to miss. I thought it would make a good blog post because it turned out to
be a nice, real-life example of the [Liskov substitution principle][] (herein
abbreviated to LSP).

<!--more-->

The (Winding) Answer
--------------------

When I saw the question, the first thing I thought of was [old mate Liskov][].
I opened up [the documentation for `NSSet`][] and went through every method,
trying to find one that would have its contract violated by `NSOrderedSet`.
Every single method looked fine to me. They could all be implemented in
`NSOrderedSet` without any problems.

Upon closer inspection, there is one little method that violates the LSP in a
very subtle way. That method is `mutableCopy`. The return value of
`mutableCopy` would have to be an `NSMutableSet`, but `NSMutableOrderedSet`
should inherit from `NSOrderedSet`. It turns out that you can't have both.

Let me explain with some code. First, let's look at the correct behaviour of
`NSSet` and `NSMutableSet`:

```objc
NSSet* immutable = [NSSet set];
NSMutableSet* mutable = [immutable mutableCopy];

[mutable isKindOfClass:[NSSet class]]; // YES
[mutable isKindOfClass:[NSMutableSet class]]; // YES
```

Now, let's pretend `NSOrderedSet` does inherit from `NSSet`, and
`NSMutableOrderedSet` inherits from `NSOrderedSet` as expected:

```objc
NSSet* immutable = [NSOrderedSet orderedSet];
NSMutableSet* mutable = [immutable mutableCopy];

[mutable isKindOfClass:[NSSet class]]; // YES
[mutable isKindOfClass:[NSMutableSet class]]; // NO (problem)
```

The last line of the example above shows the problem. You wouldn't be able to
pass an `NSOrderedSet` into a function expecting an `NSSet` because the
behaviour is different. It's a violation of the LSP, which also makes it a
backwards compatibility problem.

What if `NSMutableOrderedSet` inherited from `NSMutableSet` instead? Then we
get a different problem:

```objc
NSSet* immutable = [NSOrderedSet orderedSet];
NSMutableSet* mutable = [immutable mutableCopy];

[mutable isKindOfClass:[NSSet class]]; // YES
[mutable isKindOfClass:[NSMutableSet class]]; // YES
[mutable isKindOfClass:[NSOrderedSet class]]; // NO (problem)
```

Now, `NSMutableOrderedSet` doesn't inherit from `NSOrderedSet`. In Foundation,
every mutable class inherits from the immutable class. To break this rule would
be a bad design decision. Imagine if you had to allocate a new `NSArray` every
time you wanted to pass an `NSMutableArray` into a function that takes
immutable arrays as parameters. That would suck.

**Update**: Michael Tsai [correctly points out another LSP violation][]. If
`NSOrderedSet` inherits from `NSSet`, then `isEqual:` can not correctly compare
an ordered set to an unordered set, for example:

```objc
NSSet* unordered = [NSSet setWithObjects:@"a", @"b", @"c", nil];
NSSet* ordered1 = [NSOrderedSet orderedSetWithObjects:@"a", @"b", @"c", nil];
NSSet* ordered2 = [NSOrderedSet orderedSetWithObjects:@"c", @"b", @"a", nil];

[ordered1 isEqual:ordered2]; //NO, because the order is different

// Should this be NO because the order may be different, 
// or should it be YES for backwards compatibility, because
// NSSet never used to care about order?
[unordered isEqual:ordered1]; //problem
```

Conclusion
----------

This all boils down to the fact that `NSMutableOrderedSet` can't inherit from
both `NSMutableSet` and `NSOrderedSet` because Objective-C doesn't have
multiple inheritance. The usual way to get around this is to make protocols for
`NSMutableSet` and `NSOrderedSet`, because then `NSMutableOrderedSet` can
implement both protocols. 

I guess the Apple developers just thought it was simpler without the extra
protocols, and I agree with them. The addition of the new protocols would
cascade into the API of other areas. You would have to change method signatures
to take `id<NSMutableSet>` instead of `NSMutableSet*`.  It's just cleaner
to use `[myOrderedSet set]` when you really need to use the object as an
`NSSet`.

Funnily enough, choosing *not* to inherit from `NSSet` has already caused at
least one [bug in Core Data][]. The error message is a dead giveaway: `-[NSSet
intersectsSet:]: set argument is not an NSSet.` Designing an API always
involves trade-offs.

[Why doesn't NSOrderedSet inherit from NSSet?]: http://stackoverflow.com/questions/11278995/why-doesnt-nsorderedset-inherit-from-nsset
[Liskov substitution principle]: http://tomdalling.com/blog/software-design/solid-class-design-the-liskov-substitution-principle
[old mate Liskov]: http://en.wikipedia.org/wiki/Liskov_substitution_principle "Liskov substitution principle"
[the documentation for `NSSet`]: https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSSet_Class/Reference/Reference.html
[correctly points out another LSP violation]: http://mjtsai.com/blog/2012/08/08/why-nsorderedset-doesnt-inherit-from-nsset/
[bug in Core Data]: http://stackoverflow.com/questions/7385439/problems-with-nsorderedset

