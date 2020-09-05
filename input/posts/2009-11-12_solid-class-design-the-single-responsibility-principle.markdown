{:title "SOLID Class Design: The Single Responsibility Principle"
 :main-image {:uri "/images/posts/srp.jpg"
              :artist {:name "Derick Bailey"
                       :url "http://www.lostechies.com/blogs/derickbailey/archive/2009/02/11/solid-development-principles-in-motivational-pictures.aspx"}}
 :disqus-id "232 http://tomdalling.com/?p=232"
 :category :software-design}

This is part one of a five part series about [SOLID class design principles][]
by [Robert C. Martin][]. The SOLID principles focus on achieving code that is
maintainable, robust, and reusable. In this post, I will discuss the Single
Responsibility Principle.

>**The Single Responsibility Principle (SRP)**: *A class should have one, and only one, reason to change*.

<!--more-->

The SRP is roughly the same as having "high [cohesion][]". A class is said to
have high cohesion if it's behaviours are highly related, and strongly focused.
The SRP states that a class should be cohesive to the point that it has a
single responsibility, where a responsibility is defined as "a reason for
change."

The Benefits
------------

 -  **The class is easier to understand**<br />
    When the class only does "one thing", its interface usually has a small
    number of methods that are fairly self explanatory. It should also have a
    small number of member variables (less than seven-ish).
    
 -  **The class is easier to maintain**<br />
    Changes are isolated, reducing the chance of breaking other unrelated areas
    of the software. As programming errors are inversely proportional to
    complexity, being easier to understand makes the code less prone to bugs.
    
 -  **The class is more reusable**<br />
    If a class has multiple responsibilities, and only one of those is needed
    in another area of the software, then the other unnecessary
    responsibilities hinder reusability. Having a single responsibility means
    the class should be reusable without modification.

An Example
----------

Consider a class called `XMLExporter`. `XMLExporter` takes a `Document` object,
and exports it into a different file format for another application. Ignoring
error handling, the class may look something like this:

```cpp
class XMLExporter {
private:
    URL _runSaveDialog();
    String _exportDocumentToXML(Document doc);
    void _showSuccessDialog();
public:
    void exportDocument(Document doc);
};

void XMLExporter::exportDocument(Document doc)
{
    String xmlFileContent = _exportDocumentToXML(doc);
    URL fileURL = _runSaveDialog();
    xmlFileContent.writeToURL(fileURL);
    _showSuccessDialog();
}

// ... (code ommitted)

```

There are at least two reasons for change (a.k.a. responsibilities) in the
`XMLExporter` class. The class needs to be modified if the GUI changes &mdash;
for example, if an options dialog is added. Also, the class needs to be
modified if the XML format changes, or the `Document` needs to be exported
differently.

To apply the SRP to the `XMLExporter` class, it must be split into two classes.
One class will handle the GUI, and the other will only handle the conversion to
XML. Here is a possible application of the SRP:

```cpp
/********* XMLConverter ************/
class XMLConverter {
public:
    String convertDocumentToXML(Document doc);
}

// ... (code ommitted)

/********* XMLExporter ************/
class XMLExporter {
private:
    URL _runSaveDialog();
    void _showSuccessDialog();
public:
    void exportDocument(Document doc);
};

void XMLExporter::exportDocument(Document doc)
{
    XMLConverter converter;
    String xmlFileContent = converter.convertDocumentToXML(doc);
    URL fileURL = _runSaveDialog();
    xmlFileContent.writeToURL(fileURL);
    _showSuccessDialog();
}

// ... (code ommitted)

```

N.B. The above code demonstrates the SRP *only*, and actually violates some of
the other four SOLID class design principles.

By extracting the `XMLConverter` class from `XMLExporter`, the two reasons for
change are separated from each other. Note that separating the GUI from the
converter has resulted in a model-view-controller type of structure.

[SOLID class design principles]: http://butunclebob.com/ArticleS.UncleBob.PrinciplesOfOod "The Principles of OOD"
[Robert C. Martin]: http://www.objectmentor.com/omTeam/martin_r.html
[cohesion]: http://en.wikipedia.org/wiki/Cohesion_%28computer_science%29 "Cohesion (computer science)"

