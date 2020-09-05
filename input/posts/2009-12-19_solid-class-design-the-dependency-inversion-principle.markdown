{:title "SOLID Class Design: The Dependency Inversion Principle"
 :main-image {:uri "/images/posts/dip.jpg"
              :artist {:name "Derick Bailey"
                       :url "http://www.lostechies.com/blogs/derickbailey/archive/2009/02/11/solid-development-principles-in-motivational-pictures.aspx"}}
 :disqus-id "307 http://tomdalling.com/?p=307"
 :category :software-design}

This is part four of a five part series about [SOLID class design principles][]
by [Robert C. Martin][]. The SOLID principles focus on achieving code that is
maintainable, robust, and reusable. In this post, I will discuss the Dependency
Inversion Principle.

>**The Dependency Inversion Principle (DIP)**: *High level modules should not
>depend upon low level modules. Both should depend upon abstractions*.

<!--more-->

Imagine a world without plugs and sockets. The computer is directly soldered
into an electrical wire in the wall. Whenever you buy a motherboard you also
get a mouse, keyboard and monitor, but they're all directly soldered onto the
motherboard by the manufacturer. Everything works fine, but things get
complicated when you want to remove or replace anything. If you try to replace
the mouse:

 -  You risk damaging the motherboard
 -  It takes forever to solder
 -  Soldering is error prone because the new mouse has different wires

A world without plugs and sockets sounds ridiculous. Yet we programmers have a
tendency to pull out the metaphorical soldering iron and hard-wire our classes
together as we're making them. If the classes are hard-wired together, and you
want to replace one of them:

 -  You risk damaging code that uses the class
 -  It takes forever to find and change every place that the class is used
 -  Inserting the replacement class is error prone because it is slightly
    different to the old class

The Dependency Inversion Principle is basically a way of adding plugs and
sockets to your code. It allows you to create your high level modules (the
computer) independent of the low level modules (the mouse). The low level
modules can be created later, and are easily replaceable.

What Are The "Plugs"?
---------------------

Depending on what programming language you're using, a "plug" can be a few
different things. Here are plug mechanisms for a few common languages:

| Language    | Plug                                                                                             |
| ----------- | ------------------------------------------------------------------------------------------------ |
| C++         | base classes with [virtual methods][]; [templating][]; possibly [preprocessor][] function macros |
| Java        | [interfaces][]; base classes with virtual methods                                                |
| Python      | [duck typing][]                                                                                  |
| PHP         | interfaces; base classes with virtual methods; duck typing                                       |
| Objective-C | protocols; base classes                                                                          |

The plug is essentially an abstract interface. Any class can implement or
inherit the abstract interface. Here is an example in C++:

```cpp
//This is the "plug" (abstract base class)
class Exporter {
public:
    //pure virtual (not implemented)
    virtual String convertDocumentToString(Document* doc) = 0;
};

//This is a concrete class that implements the "plug"
class CSVExporter : public Exporter {
public:
    //concrete implementation
    String convertDocumentToString(Document* doc);
};


//Another concrete class that implements the "plug"
class XMLExporter : public Exporter {
public:
    //concrete implementation
    String convertDocumentToString(Document* doc);
};
```

It is critical that the all implementations/subclasses adhere to the [Liskov
Substitution Principle][]. This is because the implementations/subclasses will
be used via the abstract interface, *not* the concrete class interface.

What Are The "Sockets"?
-----------------------

The "sockets" are any functions or classes that use a "plug". Continuing from
the above code example, below is an example of a "socket" class. Error checking
has been ignored for brevity.

```cpp
//Class with an Exporter "socket"
class ExportController {
private:
    Exporter* m_exporter;
public:
    //this is the socket that accepts Exporter plugs
    void setExporter(Exporter* exporter);
    void runExport();
};

// ... (code omitted)

void ExportController::runExport()
{
    Document* currentDocument = GetCurrentDocument();
    String exportedString = m_exporter->convertDocumentToString(currentDocument);
    String exportFilePath = GetSaveFilePath();
    WriteStringToFile(exporterString, exportFilePath);
}
```

You may notice that the above example is practically the same as an example in
a previous [article about the Open Closed Principle (OCP)][]. Both make use of
[dependency injection (DI)][], but for different reasons. The OCP uses DI to
"close" a class to modification, whereas **the DIP uses DI to remove the
dependencies on lower level classes**.

Bringing It All Together
------------------------

In the above example, the `ExportController` is the "higher level" module and
all the `Exporter` subclasses are the "lower level" modules. This is because
`ExportController` uses the `Exporter` subclasses, and not the other way
around.  **The application of the DIP means that `ExportController` has no
knowledge of `CSVExporter`, `XMLExporter`, or any other `Exporter` subclass. It
only knows about the abstract `Exporter` interface**. 

The `ExportController` class says *"this is my socket. You lower level modules
are responsible for comforming to it."* The opposite of this is when the
`ExportController` directly creates and uses `XMLExporter` and `CSVExporter`.
In that situation, `XMLExporter` and `CSVExporter` say *"this is my interface.
Every other class is responsible for conforming to it."*  The higher level
classes control the flow of the application, and therefore the user experience.
You don't want some insignificant implementation detail dictating the flow of
the application.

[SOLID class design principles]: http://butunclebob.com/ArticleS.UncleBob.PrinciplesOfOod "Principles of OOD"
[Robert C. Martin]: http://www.objectmentor.com/omTeam/martin_r.html
[Liskov Substitution Principle]: /blog/software-design/solid-class-design-the-liskov-substitution-principle
[article about the Open Closed Principle (OCP)]: /blog/software-design/solid-class-design-the-open-closed-principle
[dependency injection (DI)]: http://en.wikipedia.org/wiki/Dependency_injection
[virtual methods]: http://en.wikipedia.org/wiki/Virtual_methods
[templating]: http://en.wikipedia.org/wiki/Template_%28programming%29
[preprocessor]: http://en.wikipedia.org/wiki/C_preprocessor
[interfaces]: http://en.wikipedia.org/wiki/Java_interface
[duck typing]: http://en.wikipedia.org/wiki/Duck_typing
