{:title "Coding Tip: Have A Single Exit Point"
 :disqus-id "75 http://tomdalling.com/?p=75"
 :category :coding-tips}

Having one exit point (return) from a function is a good thing. Here is an
example of a single exit point:

```cpp
int MyArray::indexOfElement(int elementToFind){
  int foundIndex = ELEMENT_NOT_FOUND;

  for(int i = 0; i < m_numberOfElements; ++i){
    if(this->elementAtIndex(i) == elementToFind){
      foundIndex = i;
      break;
    }
  }

  return foundIndex;
}
```

Having multiple exit points can be bad. Here is an example of multiple exit
points:

```cpp
int MyArray::indexOfElement(int elementToFind){
  for(int i = 0; i < m_numberOfElements; ++i){
    if(this->elementAtIndex(i) == elementToFind){
      return i;
    }
  }

  return ELEMENT_NOT_FOUND;
}
```

The main reason multiple exit points are bad is that they complicate control
flow. The more complicated the control flow is, the harder the code is to
understand. The harder the code is to understand, the greater the change of
introduction bugs whenever the code is modified.

<!--more-->

Before I make my argument against multiple exit points, I will admit that the
examples provided are rather trivial. A six line function with two exit points
isn't particularly dangerous or unreadable &mdash; especially considering that
it's very common to see an early return in functions that search a collection
of objects. However, the problems increase exponentially with the number of
exit points and the size of the function. When you're making changes to a 70
line function with a generous sprinkling of return statements, the problems are
quite obvious.

There is some controversy surrounding returning early versus having a single
exit point, and both sides have decent arguments. However, it is my belief that
**robustness is more important than insignificant performance gains**, and
**having a single exit point improves maintainability for any non-trivial
function**.

Fragility
---------

Here is an example of a modification to the above function where having two
exit points causes a bunch of problems, demonstrating the fragility of the
function:

```cpp
int MyArray::indexOfElement(int elementToFind){
  FooBar* fb = new FooBar;
  fb->openSomeFile();
  fb->startSomeWorkerThread();

  for(int i = 0; i < m_numberOfElements; ++i){
    if(this->elementAtIndex(i) == elementToFind){
      //this return causes:
      //  1. a memory leak
      //  2. a permanently open file
      //  3. a rogue worker thread that could disrupt the application later
      return i;
    }
  }

  fb->closeSomeFile();
  fb->waitForWorkerThreadToFinish();
  delete fb;
  return ELEMENT_NOT_FOUND;
}
```

You could duplicate the clean up code, but duplication will make the function
even more fragile. Any change to the clean up code must be done in multiple
places, and if you forget one, you get problems all over again. As a rule of
thumb, you should never duplicate code. Here is an example with the duplicated
clean up code:

```cpp
int MyArray::indexOfElement(int elementToFind){
  FooBar* fb = new FooBar;
  fb->openSomeFile();
  fb->startSomeWorkerThread();

  for(int i = 0; i < m_numberOfElements; ++i){
    if(this->elementAtIndex(i) == elementToFind){
      fb->closeSomeFile(); //yuck
      fb->waitForWorkerThreadToFinish(); //yuck
      delete fb; //and yuck
      return i;
    }
  }

  fb->closeSomeFile();
  fb->waitForWorkerThreadToFinish();
  delete fb;
  return ELEMENT_NOT_FOUND;
}
```

Maintainability
---------------

Have you ever:

 -  modified a function only to find that it behaves exactly the same as before
    because of an early return statement?

 -  introduced a bug like in the code example above and spent forever finding
    it because the early return statement only happens under certain
    conditions?

If so, then you've experienced how extra return statements can make it
difficult to read and understand a section of code. If you accidentally miss
the extra return statements, then you're likely to introduce bugs. If you
*do* catch the return statements, then you have to constantly ask
yourself *"will this line be executed, or has it already
returned?"* The larger the function and number of return statements,
the greater the potential for error.

The Exceptions
--------------

Having said how great single exit points are, I will mention that there are
certain situations where multiple exit points are safe and improve readability.
I think it is good to return early in function guards like so:

```cpp
void MyArray::insertElementAtIndex(int element, int index){
	if(index < 0 || index > m_numberOfElements)
		return;

	//code for inserting element goes here
}
```

This is only because the return effectively stops the whole function from
executing. Adding a FooBar object is perfectly safe, as you can see here:

```cpp
void MyArray::insertElementAtIndex(int element, int index){
	if(index < 0 || index > m_numberOfElements)
		return;

	FooBar* fb = new FooBar;

	//code for inserting element goes here

	delete fb;
}
```

Returning early can also be used instead of deeply nested 'if' statements. In
such a situation, returning early can be the lesser of two evils.

This post was inspired by [Wil Shipley's post about why he likes returning
early][shipley_post]. I love your work, Wil, but I have to disagree with you on
this one. Those goto statements give me a bad feeling.

[shipley_post]: http://blog.wilshipley.com/2005/08/pimp-my-code-part-4-returning-late-to.html "Pimp My Code, Part 4: Returning late to return early"

