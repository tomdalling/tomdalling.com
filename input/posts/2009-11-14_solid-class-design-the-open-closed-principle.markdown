{:title "SOLID Class Design: The Open Closed Principle"
 :main-image {:uri "/images/posts/ocp.jpg"
              :artist {:name "Derick Bailey"
                       :url "http://www.lostechies.com/blogs/derickbailey/archive/2009/02/11/solid-development-principles-in-motivational-pictures.aspx"}}
 :disqus-id "245 http://tomdalling.com/?p=245"
 :category :software-design}

This is part two of a five part series about [SOLID class design principles][]
by [Robert C. Martin][]. The SOLID principles focus on achieving code that is
maintainable, robust, and reusable. In this post, I will discuss the Open
Closed Principle.

>**The Open Closed Principle (OCP)**: *You should be able to extend a classes behavior, without modifying it*.

<!--more-->

The OCP is sometimes alternatively defined as:

>*A class should be open to extension, but closed to modification.*

Robert Martin sums up the rationale for the OCP like this:

>"When a single change to a program results in a cascade of changes to dependent
modules, that program exhibits the undesirable attributes that we have come to
associate with 'bad' design. The program becomes fragile, rigid, unpredictable
and unreusable. The open-closed principle attacks this in a very
straightforward way. It says that you should design modules that never change.
When requirements change, you extend the behavior of such modules by adding new
code, not by changing old code that already works." &mdash; Robert Martin

At first, the OCP can sound contradictory. How can you change the behavior of a
class without modifying it? In a nutshell, the answer is the cornerstone of
object oriented design: [polymorphism][].  The example later in the article
will show how polymorphism is used to achieve classes that are "closed" to
changes.

The Benefits
------------

As stated by Robert Martin, classes that must be modified to accommodate new
changes are fragile, rigid, unpredictable and unreusable. By insulating the
class from changes, the class becomes robust, flexible, and reusable. Also as
no modifications are made to the code no bugs can be introduced, leading to
code that only becomes more stable over time through testing. The ability to
reuse a class that has been working for years without modification is clearly
preferable to modifying the class every time requirements change.

An Example
----------

Continuing on from the example in the previous post about [the Single
Responsibility Principle][], I'm going to modify the code to allow for multiple
export file formats.

```cpp
/********* XMLConverter ************/
class XMLConverter {
public:
    String convertDocumentToXML(Document doc);
}
 
// ... (code ommitted)

/********* BinaryConverter *********/
class BinaryConverter {
public:
    Data convertDocumentToBinary(Document doc);
}

// ... (code ommitted)
 
/********* DocumentExporter ************/

enum ConverterType {
    XMLConverterType,
    BinaryConverterType
};

class DocumentExporter {
private:
    URL _runSaveDialog();
    void _showSuccessDialog;
    ConverterType _converterType;
public:
    void setConverterType(ConverterType converterType);
    void exportDocument(Document doc);
};
 
void DocumentExporter::exportDocument(Document doc)
{
    URL fileURL = _runSaveDialog();
    
    switch(_converterType){
        case XMLConverterType:{
            XMLConverter xmlConverter;
            String xmlFileContent = xmlConverter.convertDocumentToXML(doc);
            xmlFileContent.writeToURL(fileURL);
            break;
        }
            
        case BinaryConverterType:{
            BinaryConverter binaryConverter;
            Data binaryFileContent = binaryConverter.convertDocumentToBinary(doc);
            binaryFileContent.writeToURL(fileURL);
            break;
        }
        
        default:
            LogError("Unrecognised converter type");
            return;
    }
    
    _showSuccessDialog();
}

// ... (code ommitted)

```

The `DocumentExporter` class is **not** closed to change. Every time a new
export format must be supported, the `DocumentExporter` class must be modified.
**Enums and switch statements are strong indicators that a class is not closed
to changes**. If the enum changes, then every related switch statement must
also be changed.

The way to close `DocumentExporter` to changes, in this case, is to make an
abstract base class for all the converters. Then, the converter can be supplied
to `DocumentExporter` via a technique called [dependency injection][]. The
solution is as follows:

```cpp
/********* Converter ************/

class Converter {
public:
    virtual Data convertDocumentToData(Document doc) = 0;
};

/********* XMLConverter ************/

class XMLConverter : public Converter {
public:
    Data convertDocumentToData(Document doc);
};

Data XMLConverter::convertDocumentToData(Document doc)
{
    //convert to xml here
}

/********* BinaryConverter ************/

class BinaryConverter : public Converter {
public:
    Data convertDocumentToData(Document doc);
};

Data BinaryConverter::convertDocumentToData(Document doc)
{
    //convert to binary here
}
 
/********* DocumentExporter ************/

class DocumentExporter {
private:
    URL _runSaveDialog();
    void _showSuccessDialog;
    Converter* _converter;
public:
    void setConverter(Converter* converter); //Here is the dependency injection function
    void exportDocument(Document doc);
};
 
void DocumentExporter::exportDocument(Document doc)
{
    URL fileURL = _runSaveDialog();
    Data fileContent = _converter.convertDocumentToData(doc);
    fileContent.writeToURL(fileURL);
    _showSuccessDialog();
}

// ... (code ommitted)

```

In the above example, `DocumentExporter` is closed to change in respect to new
export formats. To support a new export format, a new class is created that
inherits from `Converter`. The new converter is injected into `DocumentExporter`
via the `setConverter` method, and **`DocumentExporter` is not modified in any
way**.

Note that a class can never be *completely* closed. There will always be
unforeseen changes that require a class to be modified. However, if changes can
be foreseen, such as different export formats, then you have a perfect
opportunity to apply the OCP to make your life easier when those change
requests come rolling in.

[SOLID class design principles]: http://butunclebob.com/ArticleS.UncleBob.PrinciplesOfOod "Principles of OOD"
[Robert C. Martin]: http://www.objectmentor.com/omTeam/martin_r.html
[Derick Bailey]: http://www.lostechies.com/blogs/derickbailey/archive/2009/02/11/solid-development-principles-in-motivational-pictures.aspx
[polymorphism]: http://en.wikipedia.org/wiki/Polymorphism_in_object-oriented_programming
[the Single Responsibility Principle]: http://tomdalling.com/software-design/solid-class-design-the-single-responsibility-principle
[dependency injection]: http://en.wikipedia.org/wiki/Dependency_injection

