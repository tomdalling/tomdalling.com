{:title "Const Correctness For NSString (And Pointers In General)"
 :disqus-id "552 http://tomdalling.com/blog/?p=552"
 :category :coding-tips}

So you're implementing a new notification and you want the name to be a
constant. Easy, right?

```objc
const NSString* VTMyNewNotification;
```

If that's how you do constants, you're not doing it quite right. Try assign a
new value to the alleged constant and watch in horror as the compiler doesn't
stop you.

This is because when you type `const NSString*`, the compiler interprets that
as **a pointer to a constant `NSString`**. `NSString` is already an immutable
object, so making a constant `NSString` doesn't do anything except maybe cause
some compiler errors/warnings later when you try to use it. What you're really
after is **a constant pointer to an `NSString`**. It's ever so subtly
different, and written like so:

```objc
NSString* const VTMyNewNotification;
```

Don't feel bad. It's a common mistake. I used to do it until Rob Napier
[schooled me][], and now I'm passin' on the learnin' to you.

[schooled me]: http://stackoverflow.com/questions/1937685/static-nsstring-usage-vs-inline-nsstring-constants/1937727#1937727 "Static NSString usage vs inline NSString constants"

<!--more-->
