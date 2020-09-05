{:title "SOLID Class Design: The Interface Segregation Principle"
 :main-image {:uri "/images/posts/isp.jpg"
              :artist {:name "Derick Bailey"
                       :url "http://www.lostechies.com/blogs/derickbailey/archive/2009/02/11/solid-development-principles-in-motivational-pictures.aspx"}}
 :disqus-id "352 http://tomdalling.com/?p=352"
 :category :software-design}

This is that last part of a five part series about [SOLID class design
principles][] by [Robert C. Martin][]. The SOLID principles focus on achieving
code that is maintainable, robust, and reusable. In this post, I will discuss
the Interface Segregation Principle.

>**The Interface Segregation Principle (ISP)**: *Clients should not be forced
>to depend upon interfaces that they do not use*.

<!--more-->

The Interface Segration Principle (ISP) is best demonstrated with an example,
so let's dive right in.

```cpp
//EXAMPLE 1
class SomeButton {
private:
    SomeController* _controller;
public:
    void setController(SomeController* controller);
};

class SomeWindow {
private:
    SomeController* _controller;
public:
    void setController(SomeController* controller);
};

class SomeController {
private:
    SomeWindow* _window;
    SomeButton* _okButton;
    SomeButton* _cancelButton;
public:
    void onButtonDown(SomeButton* button);
    void onButtonUp(SomeButton* button);
    void onWindowOpen(SomeWindow* window);
    void onWindowClose(SomeWindow* window);
    void onWindowMoved(SomeWindow* window);
};
```

In the above example, there is `SomeController` which handles clicks from two
`SomeButton` objects and window events from a `SomeWindow` object. The problem
with this design is that `SomeButton` and `SomeWindow` both have a
`SomeController` pointer. `SomeButton` *does* need to call the `onButton[X]`
methods of the controller object, but it also has access to the `onWindow[X]`
methods which are useless to the button. The presence of useless `onWindow[X]`
methods is a violation of the ISP. There is also a cyclic dependency, which is
another hint that something is amiss.

**To conform to the ISP, `SomeButton` must not have access to the `onWindow[X]`
methods, and `SomeWindow` must not have access to the `onButton[X]` methods.**
This can easily be done by applying the [Dependency Inversion Principle][], and
the [Open Closed Principle][]. Here is one way to improve the design:

```cpp
//EXAMPLE 2
// The Button ///////////////////////////////////////////////////////

class SomeButtonController {
public:
    virtual void onButtonDown(SomeButton* button) = 0;
    virtual void onButtonUp(SomeButton* button) = 0;
};

class SomeButton {
private:
    SomeButtonController* _controller;
public:
    void setController(SomeButtonController* controller);
};

// The Window ///////////////////////////////////////////////////////

class SomeWindowController {
public:
    virtual void onWindowOpen(SomeWindow* window) = 0;
    virtual void onWindowClose(SomeWindow* window) = 0;
    virtual void onWindowMoved(SomeWindow* window) = 0;
};

class SomeWindow {
private:
    SomeWindowController* _controller;
public:
    void setController(SomeWindowController* controller);
};

// The Controller ///////////////////////////////////////////////////////

class SomeController : public SomeButtonController, public SomeWindowController {
private:
    SomeWindow* _window;
    SomeButton* _okButton;
    SomeButton* _cancelButton;
public:
    void onButtonDown(SomeButton* button);
    void onButtonUp(SomeButton* button);
    void onWindowOpen(SomeWindow* window);
    void onWindowClose(SomeWindow* window);
    void onWindowMoved(SomeWindow* window);
};
```

The improved design above uses abstract base classes and (the good kind of)
multiple inheritance. `SomeButton` now only has access to button related
controller methods, and `SomeWindow` only has access to window related
controller methods, yet `SomeController` objects can be plugged into both.

Why bother adhering to the ISP?
-------------------------------

Martin Fowler mentions the cost of recompiling as a reason to adhere to the
ISP. In Example 1, if `SomeController` were to change, then both `SomeButton` and
`SomeWindow` would need to be recompiled. In Example 2, this is not a problem. I
don't think that's a huge deal, because ~~a fast compile time is the least of
your worries when you're writing software~~. *(2014 update: after compiling
Boost a few times, one grows to appreciate fast build times. If you're the victim
of a monstrous, Boost-like codebase, then this could be important to you.)* 

Martin also mentions that **"fat interfaces" &mdash; interfaces with
additional useless methods &mdash; lead to inadvertent coupling between
classes**. This is the real reason why the SIP should be adhered to. 

Coupling is the bane of reusability. In Example 1, `SomeButton` and
`SomeWindow` are not reusable, and can only be used in one window of the
application. It's absurd to require different window and button classes for
every window in the application. 

Fat interfaces also introduce unnecessary complexity, which isn't good for
maintainability or robustness. It's very clear in Example 2 that `SomeButton`
will only call the two methods on `SomeButtonController`. It's nice and simple.
However, the distinction is not so clear in Example 1.  In reality
`SomeController` would have many more than five methods, and `SomeButton` could
be using any number of them in weird and wonderful ways. I imagine that
[dependency hell][] is full of developers running around saying *"this
`SomeButton` closes the window, so I'll just call onWindowClose instead of
onButtonDown."* I know that *I* would be wailing and gnashing my teeth.

ISP, OCP, and DIP... OMG WTF BBQ?
---------------------------------

The design flaw in Example 1 doesn't just violate the ISP, it also violates the
DIP and OCP. This is quite common, so if you're adhering to the DIP and OCP
properly then you won't come across many ISP violations. Having said that, the
ISP does gives you another handy way to evaluate your class design. **It
teaches you to ask yourself _"do I need all the methods on this interface
I'm using?"_** If the answer is no, then you might want to use a
different interface and apply some of the other SOLID principles.

[SOLID class design principles]: http://butunclebob.com/ArticleS.UncleBob.PrinciplesOfOod "Principles of OOD"
[Robert C. Martin]: http://www.objectmentor.com/omTeam/martin_r.html
[Dependency Inversion Principle]: /blog/software-design/solid-class-design-the-dependency-inversion-principle/
[Open Closed Principle]: /blog/software-design/solid-class-design-the-open-closed-principle/
[dependency hell]: http://en.wikipedia.org/wiki/Dependency_hell

