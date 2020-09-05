{:title "Implementing Your Own Cocoa Bindings"
 :disqus-id "119 http://tomdalling.com/?p=119"
 :category :cocoa}

This post is the result of investigation into a [stackoverflow.com question of
mine][].

So, you've created a spiffy `NSView` of your own, and have decided to make it
compatible with bindings. Great! So you go and read the [documentation][], and
you look at mmalc's GraphicsBindings examples. You override
`bind:toObject:withKeyPath:options:` and everything works. But wait! Why isn't
the `NSWindowController` ever being deallocated anymore?

Now you've got a nasty retain cycle on your hands. You do a little research and
discover that not only do [other people have the same problem][], but even
[Apple's bindings used to have it][] a few years ago. How did Apple fix the
problem? With the magic, undocumented class `NSAutounbinder`, which [nobody
seems to know much about][].

Other people will tell you that you don't need to override
`bind:toObject:withKeyPath:options:` and that bindings work automatically. This
is only a half truth. `NSObject` does provide an implementation of
`bind:toObject:withKeyPath:options:`, but it only half works. Using the default
`NSObject` implementation, changes in the model will update the view, but the
reverse is not true. When the bound property of the view changes, nothing
happens to the model.

So, what is a Cocoa developer to do? I'll explain how to implement your own
bindings that work exactly like Apple's, with no retain cycles. ~~I haven't
found this solution anywhere else, so as far as I know, I'm the discoverer. I
feel so special.~~ It has been [mentioned before][] at least once. The solution
is hard to find, though.

<!--more-->

The Solution
------------

The first thing you need to know is that `-[NSObject
bind:toObject:withKeyPath:options:]` will actually use the undocumented
`NSAutounbinder` mechanism to avoid the retain cycle problem. That is half the
problem solved right there. So the first step is:

<p style="text-align: center;"><strong>DO NOT override <code>bind:toObject:withKeyPath:options:</code> or <code>unbind:</code></strong></p>

Because we're using the default `NSObject` implementation, when a bound
property changes in the view, we have to manually set the new value on the
bound object. This is made possible by the fact that all information about the
binding can be obtained from `-[NSObject infoForBinding:]`. So the second step
is:

<p style="text-align: center;"><strong>Use <code>infoForBinding:</code> to propagate view-driven changes</strong></p>

Below is what I use to handle propagation of view-driven changes. It's a
category on `NSObject`, and is used like so:

```objc
-(void)mouseDown:(NSEvent*)theEvent;
{
    NSColor* newColor = //mouse down changes the color somehow (view-driven change)
    self.color = newColor;
    [self propagateValue:newColor forBinding:@"color"];
}
```

Here is the implementation of `propagateValue:forBinding:`. It handles value
transformers in the binding options.

```objc
@implementation NSObject(TDBindings)

-(void) propagateValue:(id)value forBinding:(NSString*)binding;
{
    NSParameterAssert(binding != nil);

    //WARNING: bindingInfo contains NSNull, so it must be accounted for
    NSDictionary* bindingInfo = [self infoForBinding:binding];
    if(!bindingInfo)
        return; //there is no binding

    //apply the value transformer, if one has been set
    NSDictionary* bindingOptions = [bindingInfo objectForKey:NSOptionsKey];
    if(bindingOptions){
        NSValueTransformer* transformer = [bindingOptions valueForKey:NSValueTransformerBindingOption];
        if(!transformer || (id)transformer == [NSNull null]){
            NSString* transformerName = [bindingOptions valueForKey:NSValueTransformerNameBindingOption];
            if(transformerName && (id)transformerName != [NSNull null]){
                transformer = [NSValueTransformer valueTransformerForName:transformerName];
            }
        }

        if(transformer && (id)transformer != [NSNull null]){
            if([[transformer class] allowsReverseTransformation]){
                value = [transformer reverseTransformedValue:value];
            } else {
                NSLog(@"WARNING: binding \"%@\" has value transformer, but it doesn't allow reverse transformations in %s", binding, __PRETTY_FUNCTION__);
            }
        }
    }

    id boundObject = [bindingInfo objectForKey:NSObservedObjectKey];
    if(!boundObject || boundObject == [NSNull null]){
        NSLog(@"ERROR: NSObservedObjectKey was nil for binding \"%@\" in %s", binding, __PRETTY_FUNCTION__);
        return;
    }

    NSString* boundKeyPath = [bindingInfo objectForKey:NSObservedKeyPathKey];
    if(!boundKeyPath || (id)boundKeyPath == [NSNull null]){
        NSLog(@"ERROR: NSObservedKeyPathKey was nil for binding \"%@\" in %s", binding, __PRETTY_FUNCTION__);
        return;
    }

    [boundObject setValue:value forKeyPath:boundKeyPath];
}

@end
```

I hope this helps! I'd like to thank [Ryan Ballantyne][] and Louis Gerbarg
for their input, and [Peter Hosey][] for further investigation into the
problem.

[stackoverflow.com question of mine]: http://stackoverflow.com/questions/1169097/can-you-manually-implement-cocoa-bindings "Can you manually implement Cocoa bindings?"
[documentation]: http://developer.apple.com/documentation/Cocoa/Conceptual/CocoaBindings/Concepts/HowDoBindingsWork.html "How Do Bindings Work?"
[other people have the same problem]: http://www.cocoabuilder.com/archive/message/cocoa/2004/6/12/109600 "Retain cycle problem with bindings & NSWindowController"
[Apple's bindings used to have it]: http://theocacao.com/document.page/18 "Bindings and File's Owner"
[nobody seems to know much about]: http://www.google.com/search?q=nsautounbinder
[mentioned before]: http://www.cocoabuilder.com/archive/message/cocoa/2008/6/30/211682 "Why aren't my bindings firing?"
[Ryan Ballantyne]: http://stackoverflow.com/users/143388/ryan-ballantyne
[Peter Hosey]: http://boredzo.org/

