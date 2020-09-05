{:title "An In-depth Look At Manual Memory Management In Objective-C"
 :disqus-id "608 http://tomdalling.com/blog/?p=608"
 :category :cocoa}

It feels like fleets of new developers dash themselves upon the rocky shores of
Objective-C memory management every day on StackOverflow. I can't bear to write
the same answers over and over again, so this article will be my final,
unabridged explanation of: `retain`, `release`, `autorelease`, `alloc`,
`dealloc`, `copy`, and `NSAutoreleasePool`. There will be some rules to
memorize, but we will also take a journey under the hood for a deeper
understanding.

This article is intended for people who are new to Objective-C, or who never
fully learnt how manual reference counting works. It does assume that you have
some programming experience, possibly in another language. If you are a
beginner programmer and Objective-C is your first language, I will try to keep
the explanations clear, but it may become confusing the more in-depth we get.

We will be covering:

 -  A Quick Mention Of ARC And Garbage Collection
 -  Coming From C/C++
 -  Coming From a Garbage Collected Language (Java, Python, C#, etc.)
 -  What Is Reference Counting?
 -  How Does Reference Counting Work In Objective-C?
 -  `NSAutoreleasePool` And `autorelease`
 -  Common Mistakes

If something is not explained, or not explained very well, post a question in
the comments and I'll expand the article to cover it.

<!--more-->

A Quick Mention Of ARC And Garbage Collection
---------------------------------------------

These days, you can mostly avoid manual reference counting by turning on
Automatic Reference Counting (ARC) or garbage collection. I haven't used either
of those yet, so this article will focus exclusively on manual reference
counting using `retain` and `release`. 

I think Apple is pushing ARC as the new standard (please correct me on this if
I'm wrong). I'm guessing this is why the "Memory Management Programming Guide"
has been renamed to the "[*Advanced* Memory Management Programming
Guide][mem_manage_guide]". If you're starting a new project then turn on ARC
and you can largely forget about manual reference counting.  However, I get the
impression that you still need a decent understanding of reference counting to
use ARC 100% correctly.


Coming From C/C++
-----------------

*You can skip this section if you don't have experience with manual memory
management, such as in C or C++.*

In C/C++, you can create objects as local (a.k.a stack-allocated) variables,
where allocation and deallocation is handled for you automatically. You don't
have this luxury in Objective-C. In Objective-C all objects are allocated on
the heap. It is the equivalent of always using `new` to create objects in C++.
As a result, all object variables are pointers.

In C++, an allocated bit of memory usually has a single owner. The owner
deallocates the memory when appropriate. This is also slightly different in
Objective-C. Objects can have multiple owners *by default*, as we will see
later. You can't say "deallocate this now." Instead, you say "I'm not using
this anymore" and the deallocation of an object happens automatically once all
owners have said they are no longer using the object.


Coming From a Garbage Collected Language (Java, Python, C#, etc.)
-----------------------------------------------------------------

*You can skip this section if you don't have experience in a garbage collected
language like Java, Python or C#.*

In a garbage collected langauge, you create new objects whenever you want.
Then, when you're finished with the objects you just stop using them and forget
about them. The garbage collector will magically come along and free up the
memory that the objects were occupying. This is not so, in Objective-C.

In Objective-C, when you create a new object you are responsible for freeing up
(a.k.a. deallocating) the memory once you're done with it. **If you forget
this, then the object stays in memory until the program exits**.  This is
called a [memory leak][]. If you keep leaking memory, eventually you will use
so much that the program will crash.

Conversely, you also have to be careful that you don't use an object that has
been deallocated. If an object gets deallocated, but you still have a variable
pointing to that object, then the next time you try to use that variable you
will crash &mdash; or worse. Unlike other languages, just because you have a
variable doesn't mean that the object in the variable still exists. This is
called a [dangling pointer][].


What Is Reference Counting?
---------------------------

Every object in Objective-C uses [reference counting][] to manage its
lifecycle. The canonical documentation for this is the [Advanced Memory
Management Programming Guide][mem_manage_guide]. Reference counting allows a
single object to have multiple "owners", and ensures that the object will stay
alive as long as there is at least one owner. Once the last owner is gone, the
object deallocates itself.

Reference counting is very simple, and works like this:

 -  Every object has a "reference count", which is just an integer.
 -  The reference count starts at one when the object is created, and whoever
    created the object automatically has ownership of it.
 -  If you want to take ownership of an object, you **increase** the reference
    count of the object by one.
 -  When you release ownership of an object because you don't need it any more,
    you **decrease** the reference count by one.
 -  When the reference count of an object reaches zero that means nobody is
    using it, so it is safe to be deallocated.

Let's look at an example of correct usage, using a reference counted television
object.

| Action                                                                                                                   | Change | Reference Count |
|--------------------------------------------------------------------------------------------------------------------------|--------|-----------------|
| Jerry wants to watch Seinfeld, so he creates a TV object. Creating the object makes him the only owner.                  |        | 1               |
| Elaine wants to watch the same TV object as Jerry, so she also takes ownership of the object.                            | +1     | 2               |
| Jerry gets bored of the Seinfeld episode he is watching and decides to leave, so he releases ownership of the TV object. | -1     | 1               |
| The episode of Seinfeld finishes, so Elaine releases ownership of the TV object and leaves.                              | -1     | 0               |

Now let's look at an incorrect usage, which causes a [memory leak][]:

| Action                                                                                                       | Change | Reference Count |
|--------------------------------------------------------------------------------------------------------------|--------|-----------------|
| Ned wants to watch Game of Thrones, so he creates a TV object. Creating the object makes him the only owner. |        | 1               |
| Joffrey wants to watch the TV with Ned, so he also takes ownership.                                          | +1     | 2               |
| Joffrey beheads Ned.                                                                                         |        | 2               |
| Joffrey leaves, and releases ownership of the object.                                                        | -1     | 1               |
| The TV object is never deallocated because the reference count will stay at one forever.                     |        | 1               |

This memory leak occurs because Ned forgot to release ownership of the object before he was beheaded.

Now let's look at another incorrect usage that causes a [dangling pointer][]:

| Action                                                                                                         | Change | Reference Count |
|----------------------------------------------------------------------------------------------------------------|--------|-----------------|
| Simon wants to watch Grandma's House, so he creates a TV object. Creating the object makes him the only owner. |        | 1               |
| Adam starts watching too, but doesn't bother taking ownership.                                                 |        | 1               |
| Simon releases ownership and leaves.                                                                           | -1     | 0               |
| The reference count has hit zero, so the TV object deallocates itself.                                         |        |                 |
| Adam tries to keep watching, but the TV object is gone so the universe explodes.                               |        |                 |


How Does Reference Counting Work In Objective-C?
------------------------------------------------

Memory management in Objective-C involves four basic rules. If you follow these
rules, then you will not leak memory or cause dangling pointers.

### Rule 1. If you create an object using a method that starts with "alloc", "copy" or "new", then you own it.

This is where you have created a new object with a retain count of one, which
automatically makes you the owner.

Examples:

```objc
NSString* iOwnThis1 = [[NSString alloc] initWithString:@"hello"];
NSString* iOwnThis2 = [someOtherString copy];
NSMutableString* iOwnThis3 = [someOtherString mutableCopy];
NSString* iOwnThis4 = [NSString new];

[iOwnThis1 release];
[iOwnThis2 release];
[iOwnThis3 release];
[iOwnThis4 release];
```

### Rule 2. If you `retain` an object, then you own it.

This is where you call `retain` on an object, which increases the retain count
by one.

Examples:

```objc
[donkey retain];
[eagle retain];
[eagle retain];
[eagle retain];

[donkey release];
[eagle release];
[eagle release];
[eagle release];
```

Note that you can take ownership of an object more than once. If you own the
object three times, then you have to release it three times.


### Rule 3. If you own it, you must release it.

This is where you call the `release` method on an object, which decreases the
retain count by one. When you call `release` and the retain count reaches zero,
the object will deallocate itself by calling `dealloc`. **This means you should
never call `dealloc` directly.** Just release the object correctly, and it will
handle everything itself.

Examples:

```objc
NSString* iMadeThis = [[NSString alloc] init]; // Rule 1
[iMadeThis release];

[imSharingThis retain]; // Rule 2
[imSharingThis release];

//can own the same object many times
Pidgeon* pidgeon = [[Pidgeon alloc] init]; // Rule 1
[pidgeon retain]; // Rule 2
[pidgeon release];
[pidgeon release];
```

### Rule 4. If you keep a pointer to an object, then you must own the object (with some rare exceptions).

Basically, if you own an object, then you know it is definitely safe to use. If
you *don't* own it, then it is sometimes safe to use temporarily (discussed in
the autorelease section). If you want to *keep* an object to use later, such as
storing it in an ivar or a global, you must retain it. Otherwise, it might be
deallocated and you will be left with a dangling pointer.

One exception is the use of strings you type directly into the code (string
literals). String literals are never deallocated, and `retain` and `release`
don't do anything to them. Another exception is when you are trying to avoid
retain cycles, which we will look at later.

Here are some examples showing the right and wrong way to keep a variable:

```objc
//good - no retain necessary on string literal
NSString* g_globalDefaultName = @"Balram";

@interface Tiger {
    NSString* name;
    NSImage* picture;
}
//BAD! This property should be `copy` or `retain`
@property(assign) NSImage* picture;

-(id) initWithName:(NSString*)nameArg;
+(void) setDefaultName:(NSString*)defaultName;
@end

@implementation

@synthesize picture;

-(id) initWithName:(NSString*)nameArg;
{
    if((self = [super init])){
        //BAD!
        name = nameArg;
        
        //Should be:
        //name = [nameArg copy]; //good
        
        //Could also be:
        //name = [nameArg retain]; //good
    }
    return self;
}

-(void) dealloc;
{
    //good - always release the ivars you own in `dealloc`
    [name release];
    [image release];
    [super dealloc];
}

+(void) setDefaultName:(NSString*)defaultName;
{
    //BAD!
    g_globalDefaultName = defaultName;
    
    //Should be:
    //if(g_globalDefaultName != defaultName){
    //    [g_globalDefaultName release];
    //    g_globalDefaultName = [defaultName copy];
    //}
}
@end
```


NSAutoreleasePool And Autorelease
---------------------------------

The final peice of the puzzle is autoreleasing. Let's say we create an object
like this:

```objc
NSString* greeting = [NSString stringWithFormat:@"%@, %@!", @"Hello", @"sailor"];
```

According to Rule 1, we do **not** own the `greeting` string because the method
`stringWithFormat` does not begin with "alloc", "copy" or "new". How can we not
own an object we just created? If we don't release it then what will?

At (almost) any time, there is a global `NSAutoreleasePool` in use. When you
call `autorelease` on an object, all it does is add that object to the global
pool. Later on, the pool will be "drained" which causes `release` to be called
on every object in the pool. **So, `autorelease` just calls `release` some time
in the future**.

This is the reason why we don't own the `greeting` string. It has already been
autoreleased, which means it has been added to the current pool, and will be
released later when the pool is drained. If we don't retain the string now,
then when the pool is drained the retain count will hit zero, and the string
will be deallocated. The object is safe to use until the pool is drained, but
it will not be safe after that.

So now the question becomes "how long can I safely use the object before the
autorelease pool is drained?" In Cocoa, the pool is drained after every
`NSEvent` is sent. For example, if the user clicks the mouse twice then the
pool will be drained in between the first and the second click. This is why it
is safe to use an object temporarily, but it is not safe to *keep* an
object unless you own it. If you don't retain your ivar and the user moves her
mouse, suddenly your ivar is gone and you're probably going to crash very
shortly. 

You can actually create your own autorelease pools if you need to drain them
frequently:

```objc
//put `outside` in the current global pool (the "old pool")
Tiger* outside = [[[Tiger alloc] init] autorelease];

//make a new current global pool (the "new pool")
NSAutoreleasePool* newPool = [[NSAutoreleasePool alloc] init];

//put `inside` into the new pool
Tiger* inside = [[[Tiger alloc] init] autorelease];

//drain the new pool, which makes the old pool become current again
[newPool drain];

//BAD! `inside` is gone, because it was in the new pool, and
//the new pool has been drained. This will probably crash.
[inside speak];

//good - `outside` was in the old pool, so it was not affected by the
//new pool being drained
[outside speak];
```

The basic rule of thumb is this: It's safe to use an object you don't own until
the current function/method returns. After you return from the function/method
someone might drain the pool, or they might release one of the arguments they
gave you. If you want to be sure the object will live after the function/method
returns, then retain it. It's always safe to use an object you own.


Common Mistakes
---------------

### Releasing An Object You Don't Own

One common mistake is to think "I have to release this string because I created
it with `[NSString stringWithString:@"hello"]`." Look at Rule 1 again.
`stringWithString:` does not start with "alloc", "copy" or "new", which means
you don't own the object, so don't release it. The only exception I can think
of is the `mutableCopy` method, which really should have been called
`copyMutable` instead.

### Keeping And Using An Object You Don't Own

A similar mistake to the previous one is doing something like this:

```objc
@interface Tiger {
    NSString* voice;
}
-(void) speak;
@end;

@implementation Tiger
-(id) init;
{
    if((self = [super init])){
        //DANGER! You don't own the string, so it will be deallocated
        voice = [NSString stringWithFormat:@"%@, I'm a %@", "ROAR", "tiger"];
    }
}

-(void) speak;
{
    //This will crash when `voice` becomes a dangling pointer
    NSLog(@"%@", voice);
}

-(void) dealloc;
{
    //This will also crash when `voice` becomes a dangling pointer
    [voice release];
    [super dealloc]
}

@end
```

Again, look at Rule 1. `stringWithFormat:` does not begin with "alloc", "copy"
or "new", so you don't own the string it creates. Objects should retain their
ivars unless they have a very good reason not to.

Scarily, this may work without crashing, depending on how the `Tiger` class is
used. It is, however, still a ticking time bomb. 


### Calling `dealloc` Directly

Some people jump into Objective-C assuming that memory management works the
same way as C++. However, they quickly learn that this is a very bad idea:

```objc
//WRONG
Tiger* pet = [Tiger alloc];
[pet speak];
[pet dealloc];

//CORRECT
Tiger* pet = [[Tiger alloc] init];
[pet speak];
[pet release];
```

Firstly, never call `dealloc` directly. Secondly, you *must* call one of the
`init` methods directly after calling `alloc`.

Once again, the scary thing is that the above code can actually work without
crashing sometimes, depending on the class being used.


### Looking At `retainCount`

The `retainCount` method returns &mdash; you guessed it &mdash; the current
retain count. Occassionally someone will look at this number and say "OMG,
something is wrong! I know the retain count should be 1 but it's 3!"

Looking at the retain count is not reliable because it doesn't show
autoreleases. Take this peice of code, for example:

```objc
NSMutableString* str = [NSMutableString string];
[str appendString:"Testy Cakes"];
for(int i = 0; i < 3; ++i){
    NSLog(@"%@", str);
    NSLog(@"Retain count is %d", [str retainCount]);
}
```

The output is this:

```
Testy Cakes
Retain count is 2
Testy Cakes
Retain count is 3
Testy Cakes
Retain count is 4
```

`NSLog` is retaining `str` every time it is called. That doesn't mean that
`NSLog` is leaking memory. If you could look into the current autorelease pool
&mdash; which you can't, as far as I know &mdash; you would find that `str` has
been autoreleased four times.

Anything can retain your objects. I could write a function that retains every
argument 1000 times and then autoreleases it 1000 times just to make you freak
out when you look at the retain count, but it wouldn't leak a drop.


### Over-releasing

Despite your best efforts, you will occassionally accidentally release
something twice instead of once, or maybe release something that you don't own.
This will cause a crash. Fortunately, these bugs are pretty easy to find if you
turn on zombies in Instruments. And I'm not talking about sexually arousing the
walking dead inside of a clarinet, or anything like that.

Xcode 4 makes this pretty easy:

 -  Click and hold the "Run" button in the toolbar.
 -  Select "Profile" from the drop down menu.
 -  When Instruments pops up, select the "Zombies" instrument.
 -  Go to your running app and trigger the crash.
 -  Instruments will pop up a little box that says something like: "You
    messaged a zombie at 0xDEADBEEF." Click the little arrow in there.
 -  In the bottom pane, Instruments will show you every single `retain`,
    `release` and `autorelease` that ever happened to the object, so you can
    figure out the problem from that.


### Retain Cycles

Normally you retain an ivar in a setter or an initialiser method, then you
release it in `dealloc`. That way, when an object is deallocated there is a
cascading effect. The root object releases its children, then it's children
release their children, until the whole data structure is fully released.

If you have a situation where object X owns object Y, and object Y also owns
object X then you have a problem. X and Y will never be deallocated while they
own each other, because they are keeping each others retain counts at one. So
you just end up leaking both of the objects.

The reason why objects don't retain their delegates is because the delegate is
usually the owner of the object. Image if delegates were retained. The
`NSWindowController` owns the `NSWindow`, and the `NSWindow` owns it's
delegate, which just happens to be the `NSWindowController`. Now you've leaked
an entire window and its controller, which could take up a huge chunk of
memory.

The way you get around this, is you basically say "Ok, the controller is going
to live longer than the window which means we shouldn't get any dangling
pointers, so just don't retain the controller." If you want to be super safe,
you can set the delegate to nil inside of the `dealloc` of the window
controller. That way, even if the window outlives the controller, you can be
sure that there won't be a dangling pointer.

[mem_manage_guide]: https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/MemoryMgmt/Articles/MemoryMgmt.html "TODO: link title"
[memory leak]: http://en.wikipedia.org/wiki/Memory_leak
[dangling pointer]: http://en.wikipedia.org/wiki/Dangling_pointer
[reference counting]: http://en.wikipedia.org/wiki/Reference_counting
[memory leak]: http://en.wikipedia.org/wiki/Memory_leaks
[dangling pointer]: http://en.wikipedia.org/wiki/Dangling_pointers

