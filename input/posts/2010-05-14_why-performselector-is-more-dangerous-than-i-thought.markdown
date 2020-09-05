{:title "Why performSelector: Is More Dangerous Than I Thought"
 :disqus-id "425 http://tomdalling.com/?p=425"
 :category :cocoa}

I fixed a rather nasty bug today in [AspectObjectiveC][]. One particular unit
test would crash with `EXC_BAD_ACCESS` every time. After learning far more
about registers and ABIs than I ever wanted to know (thanks, [Greg Parker][]),
it dawned on me that `performSelector:` **was corrupting memory**. It was
particularly hard to track down because the crash would happen a couple of
lines *after* the call to `performSelector:`, when the corrupted memory was
actually accessed.

I've never had a problem with `performSelector:` before, but this time I was
using it a little differently. The return value of the selector was an
`NSRect`. 

Now for the gory explanation.

<!--more-->

Why Returning an NSRect Caused the Memory Corruption
----------------------------------------------------

Normally on Intel architectures, the return value for a function is stored in
the register `eax`. This is what `obj_msgSend` handles. 

There is an exception to this rule when the function returns a sufficiently
large struct, such as an `NSRect`. In such cases, the function is passed a
secret extra argument: a pointer to some memory that will hold the return
value. The Objective-C runtime has a different message dispatch function for
these exceptional cases: `objc_msgSend_stret` ("stret" is short for
"struct return"). Therein lies the problem.

The documentation for `performSelector:` states:

>For methods that return anything other than an object, use `NSInvocation`.

Apple aren't kidding when they mention this. This is because `performSelector:`
uses `objc_msgSend`. If you use `objc_msgSend` to call a method that requires
`objc_msgSend_stret`, the function will think the first parameter is the secret
struct pointer, when in fact it's the `self` pointer. When the function
returns, it corrupts the memory pointed to by `self` by overwriting it with the
return value. Next time you try to use the object, you get weird and wonderful
crashes.

The Moral of the Story
----------------------

Only use `performSelector:` when the selector returns an object. If the
selector returns a struct, then you risk corrupting memory, even if you don't
use the return value. If the method doesn't return an object, then use
NSInvocation instead, because it is capable of determining the correct message
dispatch function to use.

Wrap Yourself In Cotton Wool
----------------------------

For those of you who are overly cautious, here's a method that will check the
return type before calling `performSelector:`

```objc
@interface NSObject(SafePerformSelector)
-(id) performSelectorSafely:(SEL)aSelector;
@end

@implementation NSObject(SafePerformSelector)
-(id) performSelectorSafely:(SEL)aSelector;
{
    NSParameterAssert(aSelector != NULL);
    NSParameterAssert([self respondsToSelector:aSelector]);
    
    NSMethodSignature* methodSig = [self methodSignatureForSelector:aSelector];
    if(methodSig == nil)
        return nil;
    
    const char* retType = [methodSig methodReturnType];
    if(strcmp(retType, @encode(id)) == 0 || strcmp(retType, @encode(void)) == 0){
        return [self performSelector:aSelector];
    } else {
        NSLog(@"-[%@ performSelector:@selector(%@)] shouldn't be used. The selector doesn't return an object or void", [self className], NSStringFromSelector(aSelector));
        return nil;
    }
}
@end
```

[AspectObjectiveC]: http://github.com/tomdalling/AspectObjectiveC
[Greg Parker]: http://www.sealiesoftware.com/blog/archive/2008/10/30/objc_explain_objc_msgSend_stret.html "[objc explain]: objc_msgSend_stret"

