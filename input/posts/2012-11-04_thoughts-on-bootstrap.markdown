{:title "Thoughts On Bootstrap"
 :disqus-id "697 http://tomdalling.com/?p=697"
 :category :web}

You may have noticed that I redesigned the site recently. The new design uses
[Boostrap][], mainly to make the site work better on tablets and phones. This
post will be about the good and the bad parts of my recent encounter with
Bootstrap.

Bootstrap is basically a CSS and JavaScript framework that gives you
nice-looking components such as buttons, menus, grid-based layout, etc. One of
more interesting parts of Bootstrap is the responsive design functionality,
which automatically rearranges and resizes the page to fit nicely on smaller
screens, such as phones and tablets.

<!--more-->

Not Your Usual "Web Framework"
------------------------------

For me, the term "web framework" conjures up nightmarish visions of shoddy,
untested, tangled messes of PHP, CSS, and Javascript. However, while you could
call Bootstrap a "web framework" of sorts, it is a very high quality project
that doesn't deserve to be lumped into the same category. Bootstrap is
currently the most popular project on github.

Build System For Flexibility
----------------------------

The typographic CSS in Bootstrap looks nice, but I found the default 14px font
size too small. Thankfully, Bootstrap has a build system that takes parameters
such as base font size into account. I set a larger base font size on the
[customize page][], and downloaded a custom build without any hassles. As part
of the build, the custom font size cascades through all the CSS rules so that
everything gets proportionally bigger. The fact that it has a build system at
all is great evidence of the project's quality.

Easy To Integrate
-----------------

Getting started is as simple as including `bootstrap.js` and `bootstrap.css`,
and add specific classes to your html elements. Want to turn a link into a
nice-looking button? Just add `class="btn"`. That's all there is to it.

Lightweight
-----------

Everything claims to be "lightweight" these days, but bootstrap really is.
Apart from the use of common CSS names, it's very unobtrusive. I was able to
integrate it into a Wordpress theme without any problems. The hardest parts
involved wrestling with Wordpress to make it spit out the HTML that I wanted.

Think of Bootstrap as limited to the front end of a website. It will work with
anything that can generate HTML, whether it's Wordpress, Ruby on Rails, or
[Pyramid][].

No CSS Namespace
----------------

I worry about conflicts in the CSS classes Bootstrap has chosen, because the
names are too generic. For example, Bootstrap has CSS classes named
`container`, `navbar`, `nav`, and `btn`. Chances are good that other projects
use the exact same names, which will cause compatibility problems. Personally,
I would like to see Bootstrap CSS classes namespaced with a `bs-` prefix to
help avoid this, like `bs-container` or `bs-navbar`. A common prefix would also
help developers to distinguish between classes that come from Bootstrap, and
classes that don't.

The beauty of having a build system is that theoretically you could add a
"class prefix" parameter that can be prepended to all the classes. If you
prefer the short names, then you make a build where "class prefix" is empty. If
you want a namespace, then set "class prefix" to whatever you want.

Not-so-semantic HTML
--------------------

[Semantic HTML][] purists may not like Bootstrap. It's not that Bootstrap is
opposed to semantic HTML. It doesn't use tables for layout, or anything like
that. It's just that sometimes semantic correctness is sacrificed in the name
of appearance and functionality. If appearance is King, then semantic HTML is
probably 3<sup>rd</sup> or 4<sup>th</sup> in line to the throne.

In purely semantic HTML, you never change the HTML to make it look different.
If you want to change the appearance, that is done in CSS only. If you need to
add CSS classes to your HTML, then they should describe what the element *is*
not what it *looks like*. For example, if you want all your "read more" links
to look like cool buttons, then you set `class="read-more"` in your HTML, and
then you alter the appearance in CSS. In Bootstrap, if you want it to look like
a button, you change the HTML and tell it to look like a button with
`class="btn"`. In Bootstrap, instead of styling in CSS you end up adding a
bunch of classes to the HTML, or even restructuring the HTML to turn it into a
certain Bootstrap component.

Historically, semantic correctness has swung from being ignored (*"just use 34
tables to make it look right"*), to being taken too far (*"just write CSS to
make 34 divs look like a table"*). Nowadays, I think we've come to a pragmatic
middle ground where Bootstrap fits in nicely. It turns out that adding classes
to the HTML is just a simpler solution.

Update: Matt Polichette commented on using Bootstrap semantically:

> Instead of just including the Bootstrap CSS file, you can use the LESS files
> from github and then use LESS to apply Bootstrap styles onto your own class
> names. This is great for styling, though it doesn't always solve the problem
> for javascript.

Conclusion
----------

Overall, I'm very happy with Bootstrap. I think I'll be using it in every site
that I make from now on.

[Boostrap]: http://getbootstrap.com/
[customize page]: http://getbootstrap.com/customize/
[Pyramid]: http://www.pylonsproject.org/
[Semantic HTML]: http://en.wikipedia.org/wiki/Semantic_HTML

