{:title "Why camelCaps Are Superior To_Underscores"
 :disqus-id "660 http://tomdalling.com/blog/?p=660"
 :main-image {:uri "/images/posts/camel-caps.jpg"}
 :category :coding-styleconventions}

I've always preferred camel caps to underscores when it comes to naming
conventions, but I've never really known why. Recently I've been writing a lot
of Python, where the standard is to use underscores for most names, and now I
realise why I don't like underscores. I hope to make my argument for camel caps
objective &mdash; or, failing that, at least better than the mouth-frothing,
religious reactions you normally get in these &ldquo;X is better than Y&rdquo;
type of discussions.

<!--more-->

Line Width
----------

If you are adhering to a line length limit, then underscores will encourage
less descriptive names, and more temporary variables.

[The Style Guide for Python (PEP 8)][] says each line should be no longer than
79 characters. Style guides for other languages often have similar limits on
line width. 

When your function names and variables are descriptive, you end up hitting the
maximum line width pretty often. Underscores make the situation worse. I find
myself shortening names just to fit the line width, and that is not a good
thing. You can break long statements into multiple smaller statements, but then
you have to introduce temporary, single-use variables. Adding unnecessary
variables isn't ideal, either.

Python is especially bad in this respect because whitespace is meaningful,
unlike most other languages. If you want to wrap a long statement onto multiple
lines, it looks very similar to a loop or conditional structure. On top of
this, sometimes you need to use backslashes to break up a line and other times
you don't. 

You can see all of these problems in in a typical SQLAlchemy query:

```python
dirty_col = db.species.c.num_dirty_occurrences
db.species.update()\
    .values(
        num_dirty_occurrences=(dirty_col + newly_dirty),
        needs_vetting_since=func.now()
    ).where(db.species.c.id == row['id'])\
    .execute()
```


Underscores Make Spaces And Other Symbols Harder To See
-------------------------------------------------------

Compare this code written with underscores:

```python
i_am_the = very_model_of(a_modern_major)
general_ive.information_vegetable = animal_and_mineral
i_know_the(kings_of, england_and, i_quote, the_fights, historical)
```

To this identical code, translated into camel caps:

```python
iAmThe = veryModelOf(aModernMajor)
generalIve.informationVegetable = animalAndMineral
iKnowThe(kingsOf, englandAnd, iQuote, theFights, historical)
```

I would argue that the camel caps code is more readable. The underscores look
too similar to spaces, which makes the spaces harder to see. Camel caps make
the other symbols stand out, which makes the code easier to scan with your
eyes.

I know a programmer who insists that underscores are easier to read than camel
caps because humans are used to reading words separated by spaces. My problem
with this argument is that code isn't written like a novel. When you scan code
with your eyes, you are primarily looking for syntactic structure, not names.
You want to instantly see where a loop starts and ends, or where a functions
arguments start and end, et cetera. Only *after* you've mentally digested the
structure do you actually care about the names of variables and function.

For example, let's say you are scanning a file to find a certain method. First
you scan for the class you want. You ignore every name in the code except for
class names. Once you've found the class, you start scanning for method
declarations. You ignore every name in the code except for method names. If the
class names and method names blend in with all the other code, that makes for a
frustrating experience.


What Advantages Do Underscores Give You?
----------------------------------------

Names with underscores are probably easier to read than names in camel caps. As
I mentioned above, I don't think you should be optimising for the readability
of names, at the expense of the readability of the syntactic structure of the
code.

If you are using a language where underscores are a widely accepted standard,
then you probably want to stick with that standard. Having a single naming
convention is better than having multiple naming conventions, even if the
single convention is suboptimal. However, this doesn't mean that underscores
are inherently good, it just means that you should pick the lesser of two
evils.

So, what advantages do you get from using underscores instead of camel caps. I
can't think of any others.


Conclusion
----------

In the end, the camel caps versus underscores issue is fairly minor. After
working in a code base with multiple different conventions, I've realised that
doesn't matter a whole lot. Sure, the underscores are slightly more annoying to
dig through, but it's not like it brings development to a grinding halt.

If you are starting with a clean slate and have the opportunity to choose, then
choose camel caps. If not,  there is no need to make a big deal out of it.

[The Style Guide for Python (PEP 8)]: http://www.python.org/dev/peps/pep-0008/

