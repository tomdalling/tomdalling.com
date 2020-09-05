{:title "SOLID Class Design: The Liskov Substitution Principle"
 :main-image {:uri "/images/posts/lsp.jpg"
              :artist {:name "Derick Bailey"
                       :url "http://www.lostechies.com/blogs/derickbailey/archive/2009/02/11/solid-development-principles-in-motivational-pictures.aspx"}}
 :disqus-id "267 http://tomdalling.com/?p=267"
 :category :software-design}

This is part three of a five part series about [SOLID class design
principles][] by [Robert C. Martin][]. The SOLID principles focus on achieving
code that is maintainable, robust, and reusable. In this post, I will discuss
the Liskov Substitution Principle.

>**The Liskov Substitution Principle (LSP)**: *functions that use pointers to
>base classes must be able to use objects of derived classes without knowing
>it*.

<!--more-->

When first learning about object oriented programming, inheritance is usually
described as an "is a" relationship. If a penguin "is a" bird, then the
`Penguin` class should inherit from the `Bird` class. The "is a" technique of
determining inheritance relationships is simple and useful, but occasionally
results in bad use of inheritance.

The [Liskov Substitution Principle][] is a way of ensuring that inheritance is
used correctly.

Tom's Penguin Problem
---------------------

The classic example of the "is a" technique causing problems is the
[circle-elipse problem][] (a.k.a the rectangle-square problem). However, I'm
going use penguins.

First, consider an application that shows birds flying around in patterns in
the sky. There will be multiple types of birds, so the developer decides to use
the [Open Closed Principle][] to "close" the code to the addition of new types
of birds. To do this, the following abstract `Bird` base class is created:

```cpp
class Bird {
public:
    virtual void setLocation(double longitude, double latitude) = 0;
    virtual void setAltitude(double altitude) = 0;
    virtual void draw() = 0;
};
```

Version one of BirdsFlyingAroundApp is a huge success. Version two adds another
12 different types of birds with ease, and is also a success. Hooray for the
Open Closed Principle. However, version three of the app is required to support
penguins. The developer makes a new `Penguin` class that inherits from the
`Bird` class, but there is a problem:

```cpp
void Penguin::setAltitude(double altitude)
{
    //altitude can't be set because penguins can't fly
    //this function does nothing
}
```

**If an override method does nothing or just throws an exception, then you're
probably violating the LSP.**

When the app is run, all the flying patterns look wrong because the `Penguin`
objects ignore the `setAltitude` method. The penguins are just flopping around
on the ground. Even though the developer tried to follow the OCP, they failed.
Existing code must be modified to accommodate the `Penguin` class.

While a penguin *technically* "is a" bird, the `Bird` class makes
the assumption that all birds can fly. Because the `Penguin` subclass violates
the flying assumption, it does not satisfy the Liskov Substitution Principle
for the `Bird` superclass.

Why Violating The LSP is Bad
----------------------------

The whole point of using an abstract base class is so that, in the future, you
can write a new subclass and insert it into existing, working, tested code.
This is the essence of the [Open Closed Principle][]. However, when the
subclasses don't adhere properly to the interface of the abstract base class,
you have to go through the existing code and account for the special cases
involving the delinquent subclasses. This is a blatant violation of the [Open
Closed Principle][]. 

For example, take a look at this fragment of code:

```cpp
//Solution 1: The wrong way to do it
void ArrangeBirdInPattern(Bird* aBird)
{
    Pengiun* aPenguin = dynamic_cast<Pengiun*>(aBird);
    if(aPenguin)
        ArrangeBirdOnGround(aPenguin);
    else
        ArrangeBirdInSky(aBird);
}
```

The LSP says that *the code should work without knowing the actual class of the
`Bird` object*. What if you want to add another type of flightless bird, like
an emu? Then you have to go through all your existing code and check if the
`Bird` pointers are actually `Emu` pointers. You should be wrinkling your nose
at the moment, because there is definitely a code smell in the air.

Two Possible Solutions
----------------------

We want to be able to add the `Penguin` class without modifying existing code.
This can be achieved by fixing the bad inheritance hierarchy so that it
satisfies the LSP.

One not-so-great way of fixing the problem is to add a method to the `Bird`
class named `isFlightless`. This way, at least additional flightless bird
classes can be added without violating the OCP. This would result in code like
so:

```cpp
//Solution 2: An OK way to do it
void ArrangeBirdInPattern(Bird* aBird)
{
    if(aBird->isFlightless())
        ArrangeBirdOnGround(aBird);
    else
        ArrangeBirdInSky(aBird);
}
```

This is really a band-aid solution. It hasn't fixed the underlying problem. It
just provides a way to check whether the problem exists for a particular
object.

A better solution would be to make sure flightless bird classes don't inherit
flying functionality from their superclasses. This could be done like so:

```cpp
//Solution 3: Proper inheritance
class Bird {
public:
    virtual void draw() = 0;
    virtual void setLocation(double longitude, double latitude) = 0;
};

class FlightfulBird : public Bird {
public:
    virtual void setAltitude(double altitude) = 0;
};
```

I don't think the English language has a word that means the opposite of
"flightless", but let's be Shakespearian and invent the word "flightful" to
fill the position. In the above solution the `Bird` base class does not contain
any flying functionality, and the `FlightfulBird` subclass adds that
functionality. This allows some functions to be applied to both `Bird` and
`FlightfulBird` objects; drawing for example. However, the `Bird` objects,
which may be flightless, can not be shoved into functions that take
`FlightfulBird` objects.

[SOLID class design principles]: http://butunclebob.com/ArticleS.UncleBob.PrinciplesOfOod "Principles of OOD"
[Robert C. Martin]: http://www.objectmentor.com/omTeam/martin_r.html
[Liskov Substitution Principle]: http://en.wikipedia.org/wiki/Liskov_substitution_principle
[circle-elipse problem]: http://en.wikipedia.org/wiki/Circle-ellipse_problem
[Open Closed Principle]: /blog/software-design/solid-class-design-the-open-closed-principle "SOLID Class Design: the Open Closed Principle"

