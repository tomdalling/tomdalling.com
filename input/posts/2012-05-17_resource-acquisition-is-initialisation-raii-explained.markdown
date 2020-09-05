{:title "Resource Acquisition is Initialisation (RAII) Explained"
 :disqus-id "586 http://tomdalling.com/blog/?p=586"
 :category :software-design}

In the competition to make the worst acronym, [RAII][] probably comes second
after [HATEOS][]. Nevertheless, it is an important concept because it allows
you to write safer code in C++ &mdash; a harsh, unforgiving language that is
all too happy to help you shoot yourself in the foot.

This article will explain exception-safety and common pitfalls in C++. As we
work out how to avoid these problems, we will accidentally discover RAII. Then,
we will finish by defining exactly was RAII is, and where it is already being
used.

<!--more-->

Exception-safety and Common Pitfalls in C++
-------------------------------------------

The RAII paradigm is wide spread in modern C++, and for good reason. That
reason is the presence of exceptions. C++ basically forces you to use
exceptions, because there is no other way to signal the failure of a
constructor method. You either ensure that all constructors never fail, which
makes the design of your classes awkward, or you throw exceptions on failure.

Given that the use of exceptions is inevitable, your code needs to be
exception-safe. Here are some common, yet unsafe, scenarios:

```cpp
File f;
f.open("boo.txt");
//UNSAFE - an exception here means the file is never closed
loadFromFile(f);
f.close();

Dog* dog = new Daschund;
//UNSAFE - an exception here means the dog is never deleted
goToThePark(dog); 
delete dog;

Lock* lock = getLock();
lock.aquire();
//UNSAFE - an exception here means the lock is never released
doSomething();
lock.release();
```
    
Not only will exceptions break your code, it's also easy to just forget to
close a file. Maybe you close the file 99% of the time but there is one rare
edge case that you forgot about. It would be nice if there was a safeguard for
these situations &mdash; something that was guaranteed to close the file so we
can't forget to do it.


Finding A Solution
------------------

When we aquire a resource (such as opening a file) what we want is to guarantee
that we run code to relinquish that resource (such as closing the file).
Luckily, there is a way to guarantee that code will run in C++. **C++
guarantees that the destructors of objects on the stack will be called, even if
an exception is thrown**. 

So we just need to get the file closing code into the destructor of some class,
and then make an instance of that class on the stack. Let's try it out with the
file example:

```cpp
class FileCloser {
public:
    FileCloser(File* file) {
        _file = file;
    }
    ~FileClose() {
        _file->close();
    }
private:
    File* _file;
}

// then we can use it like this
File f;
f.open("boo.txt");
FileCloser closer(&f);
//SAFE - Even if this throws an exception the FileCloser destructor will
//       run and close the file.
loadFromFile(f);
//don't need to close the file here because the FileCloser
//destructor will run at this point
```

This is a very naive solution with a couple of problems, so don't copy it, but
it does give you an idea of what we are trying to achieve.

One problem with this is that we might forget to make a `FileCloser`, in the
same way that we might forget to close the file. It would be much better if the
`File` class could just close itself. Let's make a new class called `MyFile`
that closes itself:

```cpp
class MyFile {
public:
    MyFile() {}
    
    ~MyFile() {
        if(_file.isOpen()){
            _file.close();
        }
    }
    
    void open(const char* filename) {
        _file.open(filename);
    }
    
    bool isOpen() const {
        return _file.isOpen();
    }
    
    void close() {
        if(_file.isOpen()){
            _file.close();
        }
    }
    
    std::string readLine() {
        return _file.readLine();
    }
    
private:
    File _file;
};


// then we can use it like this
MyFile f;
f.open("boo.txt");
//SAFE - The MyFile destructor is guaranteed to run
loadFromFile(f);
```
    
That is looking a lot better. Using `MyFile` is simpler and cleaner than
`FileCloser`, and it's exception-safe as well. We can still do better, though.
What if someone calls the `open` method twice? Also, it's annoying to check
`isOpen` everywhere.

Let's take a different approach. What if we make a class that represents an
open file? That way, we don't have to worry about opening twice, or closing
twice, and we don't even have to check if the file is open.

```cpp
class OpenFile {
public:
    OpenFile(const char* filename){
        //throws an exception on failure
        _file.open(filename);
    }
    
    ~OpenFile(){
        _file.close();
    }
    
    std::string readLine() {
        return _file.readLine();
    }
    
private:
    File _file;
};


// then we can use it like this
OpenFile f("boo.txt");
//exception safe, and no closing necessary
loadFromFile(f);
```

`OpenFile` is exception safe, and nice and simple. We have accidentally
stumbled across RAII. Well it wasn't really accidental, but let's just pretend.

What is RAII?
-------------

There are three parts to an RAII class:

 -  The resource is relinquished in the destructor (e.g. closing a file)
 -  Instances of the class are stack allocated
 -  The resource is aquired in the constructor (e.g. opening a file). This part is optional, but common.

RAII stands for "Resource Acquisition is Initialisation." The "resource
acquisition" part of RAII is where you begin something that must be ended
later, such as:

 -  Opening a file (and closing it later)
 -  Allocating some memory (and deallocating it later)
 -  Acquiring a lock (and releasing it later)

The "is initialisation" part means that the acquisition happens inside the
constructor of a class. Want to open a file? Then the opening should happen in
the constructor like we saw in the `OpenFile` example above. This isn't totally
necessary, but I think it simplifies the classes. You could also argue that
"initialisation" can happen outside of the constructor, shortly after the
constructor is run.
    
Ironically, the acronym RAII doesn't explain the most important part of the
design, which is that the relinquishing of the resource (closing, deallocating,
etc.) must be put into the destructor.

The final part is to ensure that the instance is allocated on the *stack* and
not on the *heap*. It is easy to see why if you compare the two:

```cpp
std::string firstLineOf(const char* filename){
    OpenFile f("boo.txt"); //stack allocated
    return f.readLine();
    //File closed here. `f` goes out of scope and destructor is run.
}

std::string firstLineOf(const char* filename){
    OpenFile* f = new OpenFile("boo.txt"); //heap allocated
    return f->readLine();
    //DANGER WILL ROBINSON! Destructor is never run, because `f` is never
    //deleted
}
```
    
A better name for RAII would be something like "Scope-bound Resources," because
you're tieing the life of a resource to the life of a local variable, and the
life of the local variable ends when it goes out of scope. Actually, let's
change that to "Resources are bound irreversibly to scope," because then the
acronym is RABITS. Everybody likes rabbits.


Common Uses of RAII
-------------------

When it comes to opening and closing files, `std::fstream` already has an RAII
type of design because it closes itself in its destructor.

The Boost library uses RAII for locking and unlocking with classes like
[boost::lock_guard][] and [boost::interprocess::scoped_lock][].

If you're writing modern C++ then no doubt you've heard of smart pointers.
Smart pointers are RAII classes. They help avoid a whole bunch of problems,
like forgetting to deallocate the memory, or deallocating it while it's still
being used somewhere else.

`std::shared_ptr` is interesting, in that the "resource" is not the pointer
itself &mdash; that's what `std::unique_ptr` does. Rather, the resource is a
*guarantee* that the pointer is valid. Once the `shared_ptr` goes out of scope
the pointer might still be valid, but you can't be sure because you've
relinquished your guarantee. This just goes to show that a "resource" isn't
always a physical thing like a file, or a peice of memory.

[RAII]: http://en.wikipedia.org/wiki/RAII
[HATEOS]: http://en.wikipedia.org/wiki/HATEOAS
[boost::lock_guard]: http://www.boost.org/doc/libs/1_49_0/doc/html/thread/synchronization.html#thread.synchronization.locks.lock_guard
[boost::interprocess::scoped_lock]: http://www.boost.org/doc/libs/1_49_0/doc/html/boost/interprocess/scoped_lock.html

