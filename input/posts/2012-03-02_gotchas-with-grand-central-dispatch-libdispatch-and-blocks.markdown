{:title "Gotchas With Grand Central Dispatch (libdispatch) And Blocks"
 :disqus-id "563 http://tomdalling.com/blog/?p=563"
 :category :cocoa}

[GCD][] is a nice replacement for the old
<code><a href="https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/nsobject_Class/Reference/Reference.html#//apple_ref/occ/instm/NSObject/performSelectorInBackground:withObject:">performSelectorInBackground:withObject:</a></code> and
<code><a href="https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/nsobject_Class/Reference/Reference.html#//apple_ref/occ/instm/NSObject/performSelectorOnMainThread:withObject:waitUntilDone:">performSelectorOnMainThread:withObject:waitUntilDone:</a></code> methods
and [NSOperation][]. It's also a nice supplement to [NSThread][]. 

However, I think it was over-hyped a little bit by Apple when it was first
released. You probably have all these random deadlocks and race conditions and
stuff whenever you use multiple threads, but GCD is *soooooo good* that you
don't have to worry about that anymore. Just use these magic blocks.

The problem is that concurrent programming is notoriously hard to get right.
Maybe GCD helps to make it easier, but It doesn't solve all of your problems.
In fact, GCD and blocks introduce some problems of their own. This article will
focus on some of those problems.

<!--more-->

Blocks Are Stack Allocated
--------------------------

Invariably, when you start using blocks you will find out the hard way that
blocks are allocated on the stack. It is natural to think along the lines of:
*"Blocks are objects in Objective-C, right? I'll just retain it and use it
later."* But when you go to use the block, you get weird crashes that are hard
to debug.

Stack allocated memory is deallocated when it goes out of scope. If you make a
block inside of a method then it is deallocated when the method finishes,
regardless of how many times it is retained. You need to copy the block if you
want it to survive going out of scope, because copied blocks are heap
allocated.

Dispatch Barriers
-----------------

GCD has the ability to dispatch "barriers". When a block is dispatched as a
barrier, it will not run until all blocks before it in the queue have finished.
Then, once it is guaranteed to be the only thing running in the dispatch queue,
the block is run until completion. Once the barrier block has finished, the
queue resumes executing blocks as it normally would.

Barriers have their uses, but they also introduce a problem. Let's say you have
a block running on the default priority global queue and it needs to pop back
onto the main thread, so it does a `dispatch_sync` onto the main queue.
Meanwhile, over on the main thread, someone decides to do a
`dispatch_barrier_sync` onto the default priority global queue. Now you have a
deadlock. The main thread is waiting on the barrier, the barrier won't execute
because it's waiting on the block in front, and the block in front won't
execute because it's waiting on the main thread.

**Any time you `dispatch_sync` to the main thread from one of the global queues
&ndash; which is extremely common &ndash; you risk deadlock.**

You're probably thinking that dispatching a barrier from the main thread to a
shared global queue is a horrible idea, and that nobody should be doing it in
the first place. I totally agree with you. Unfortunately, this is exactly what
Apple does. I have come across this exact bug when clicking a toolbar item.
Deep inside Apple frameworks, code which I assume is responsible for darkening
the image of the toolbar item calls `dispatch_barrier_sync`. I wish I could
find a screenshot I took of the stack trace, but alas I can not. I assume this
is a bug, and I expect it will be fixed eventually, but you can't rely on third
party code playing nicely with the global queues.

Remember how everyone told you globals were bad? This is exactly why.

The solution is to make your own dispatch queue instead of using the global
ones. Third party code can't dispatch a barrier onto your queue if they don't
have a pointer to it.

512 Thread Limit
----------------

GCD tries to hide the use of threads with abstraction, but the [abstraction is
leaky][]. The threads are still there, lurking just below the surface. If
you're not careful, you may find that you hit the 512 thread limit
accidentally, and then GCD will start going weird on you.

Every time a queue wants to run a block, GCD tries to reuse a thread that has
finished running a block and is now doing nothing. However, if all the threads
are busy running their blocks then GCD will create a new thread for you.

Let's say you are about to add more than 512 blocks to queues. If the blocks
finish fairly quickly then there is no problem, because the threads will be
reused. But what if, instead of finishing quickly, they all start waiting on a
lock? Now you have a problem. Every time you add a new block it looks for
threads to reuse, but all the threads are busy waiting on a lock, so GCD makes
a new thread for you. Every block ends up with its own thread, and now you've
accidentally hit the thread limit.

There isn't a whole lot of documentation about this, but if you click "Sample
Process" from Activity Monitor, it will tell you when you have hit the 512
thread limit. If your app locks up and you can't work out why, it might be
worth checking.

To solve this one, you might want to add your blocks to serial queues. The
serial queues basically have a single thread, and execute the blocks one at a
time. You'll be fine as long as you don't have 512 serial queues all running at
once.

[GCD]: http://en.wikipedia.org/wiki/Grand_Central_Dispatch "Grand Central Dispatch"
[NSOperation]: https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/NSOperation_class/Reference/Reference.html
[NSThread]: https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/nsthread_Class/Reference/Reference.html
[abstraction is leaky]: http://en.wikipedia.org/wiki/Leaky_abstraction "Leaky abstraction"

