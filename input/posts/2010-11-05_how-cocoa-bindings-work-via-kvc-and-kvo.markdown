{:title "How Cocoa Bindings Work (via KVC and KVO)"
 :disqus-id "490 http://tomdalling.com/blog/?p=490"
 :category :cocoa}

Cocoa bindings can be a little confusing, especially to newcomers. Once you
have an understanding of the underlying concepts, bindings aren't too hard. In
this article, I'm going to explain the concepts behind bindings from the ground
up; first explaining Key-Value Coding (KVC), then Key-Value Observing (KVO),
and finally explaining how Cocoa bindings are built on top of KVC and KVO.

<!--more-->

Key-Value Coding (KVC)
----------------------

The first concept you need to understand is [Key-Value Coding (KVC)][], as KVO
and bindings are built on top of it.

Objects have certain "properties". For example, a `Person` object may have an
`name` property and an `address` property. In KVC parlance, the `Person` object
has a *value* for the `name` *key*, and for the `address` *key*. "Keys" are
just strings, and "values" can be any type of object<a class="footnote-ref"
name="footnote_1_ref" href="#footnote_1">[1]</a>. At it's most fundamental
level, KVC is just two methods: a method to change the value for a given key
(mutator), and a method to retrieve the value for a given key (accessor). Here
is an example:

```objc
void ChangeName(Person* p, NSString* newName)
{
    //using the KVC accessor (getter) method
    NSString* originalName = [p valueForKey:@"name"];

    //using the KVC mutator (setter) method.
    [p setValue:newName forKey:@"name"];

    NSLog(@"Changed %@'s name to: %@", originalName, newName);
}
```

Now let's say the `Person` object has a third key: a `spouse` key. The value
for the `spouse` key is another `Person` object. KVC allows you to do things
like this:

```objc
void LogMarriage(Person* p)
{
    //just using the accessor again, same as example above
    NSString* personsName = [p valueForKey:@"name"];

    //this line is different, because it is using
    //a "key path" instead of a normal "key"
    NSString* spousesName = [p valueForKeyPath:@"spouse.name"];

    NSLog(@"%@ is happily married to %@", personsName, spousesName);
}
```

Cocoa makes a distinction between "keys" and "key paths". A "key" allows you to
get a value on an object. A "key path" allows you to chain multiple keys
together, separated by dots. For example, this...

```objc
[p valueForKeyPath:@"spouse.name"];
```

... is exactly the same as this...

```objc
[[p valueForKey:@"spouse"] valueForKey:@"name"];
```

That's all you need to know about KVC for now.

Let's move on to KVO.

Key-Value Observing (KVO)
-------------------------

[Key-Value Observing (KVO)][] is built on top of KVC. It allows you to observe
(i.e. watch) a KVC key path on an object to see when the value changes. For
example, let's write some code that watches to see if a person's address
changes. There are three methods of interest in the following code:

 -  `watchPersonForChangeOfAddress:` begins the observing
 -  `observeValueForKeyPath:ofObject:change:context:` is called every time there is a change in the value of the observed key path
 -  `dealloc` stops the observing

```objc
static NSString* const KVO_CONTEXT_ADDRESS_CHANGED = @"KVO_CONTEXT_ADDRESS_CHANGED"

@implementation PersonWatcher 

-(void) watchPersonForChangeOfAddress:(Person*)p;
{
    //this begins the observing
    [p addObserver:self 
        forKeyPath:@"address" 
           options:0 
           context:KVO_CONTEXT_ADDRESS_CHANGED];

    //keep a record of all the people being observed,
    //because we need to stop observing them in dealloc
    [m_observedPeople addObject:p];
}

//whenever an observed key path changes, this method will be called
- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context;
{
    //use the context to make sure this is a change in the address,
    //because we may also be observing other things 
    if(context == KVO_CONTEXT_ADDRESS_CHANGED){
        NSString* name = [object valueForKey:@"name"];
        NSString* address = [object valueForKey:@"address"];
        NSLog(@"%@ has a new address: %@", name, address);
    }    
}

-(void) dealloc;
{
    //must stop observing everything before this object is
    //deallocated, otherwise it will cause crashes
    for(Person* p in m_observedPeople){
        [p removeObserver:self forKeyPath:@"address"];
    }
    [m_observedPeople release]; m_observedPeople = nil;
    [super dealloc];
}

-(id) init;
{
    if(self = [super init]){
        m_observedPeople = [NSMutableArray new];
    }
    return self;
}

@end
```

This is all that KVO does. It allows you to observe a key path on an object to
get notified whenever the value changes.

Cocoa Bindings
--------------

Now that you understand the concepts behind KVC and KVO, Cocoa bindings won't
be too mysterious.

Cocoa bindings allow you to synchronise two key paths<a name="footnote_2_ref"
class="footnote-ref" href="#footnote_2">[2]</a> so they have the same value.
When one key path is updated, so is the other one.

For example, let's say you have a `Person` object and an `NSTextField` to edit
the person's address. We know that every `Person` object has an `address` key,
and thanks to the [Cocoa Bindings Reference][], we also know that every
`NSTextField` object has a `value` key that works with bindings. What we want
is for those two key paths to be synchronised (i.e. bound). This means that if
the user types in the `NSTextField`, it automatically updates the address on
the `Person` object.  Also, if we programmatically change the the address of
the `Person` object, we want it to automatically appear in the `NSTextField`.
This can be achieved like so:

```objc
void BindTextFieldToPersonsAddress(NSTextField* tf, Person* p)
{
    //This synchronises/binds these two together:
    //The `value` key on the object `tf`
    //The `address` key on the object `p`
    [tf bind:@"value" toObject:p withKeyPath:@"address" options:nil];
}
```

What happens under the hood is that the `NSTextField` starts observing the
`address` key on the `Person` object via KVO. If the address changes on the
`Person` object, the `NSTextField` gets notified of this change, and it will
update itself with the new value. In this situation, the `NSTextField` does
something similar to this:

```objc
- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context;
{
    if(context == KVO_CONTEXT_VALUE_BINDING_CHANGED){
        [self setStringValue:[object valueForKeyPath:keyPath]];
    }    
}
```

When the user starts typing into the `NSTextField`, the `NSTextField` uses KVC
to update the `Person` object. In this situation, the `NSTextField` does
something similar to this:

```objc
- (void)insertText:(id)aString;
{
    NSString* newValue = [[self stringValue] stringByAppendingString:aString];
    [self setStringValue:newValue];
    
    //if "value" is bound, then propagate the change to the bound object
    if([self infoForBinding:@"value"]){
        id boundObj = ...; //omitted for brevity
        NSString* boundKeyPath = ...; //omitted for brevity
        [boundObj setValue:newValue forKeyPath:boundKeyPath];
    }
}
```

For a more complete look at how views propagate changes back to the bound
object, see my article: [Implementing Your Own Cocoa Bindings][].

Conclusion
----------

That's the basics of how KVC, KVO and bindings work. The views use KVC to
update the model, and they use KVO to watch for changes in the model. I have
left out quite a bit of detail in order to keep the article short and simple,
but hopefully it has given you a firm grasp of the concepts and principles. 

<hr />
**Footnotes**

<a name="footnote_1" href="#footnote_1_ref">[1]</a>
KVC values can also be primitives such as `BOOL` or `int`, because the KVC
accessor and mutator methods will perform auto-boxing. For example, a `BOOL`
value will be auto-boxed into an `NSNumber*`. 

<a name="footnote_2" href="#footnote_2_ref">[2]</a>
When I say that bindings synchronise two key paths, that's not technically
correct. It actually synchronises a "binding" and a key path. A "binding" is a
string just like a key path but it's not guaranteed to be KVC compatible,
although it can be. Notice that the example code uses `@"address"` as a key
path but never uses `@"value"` as a key path. This is because `@"value"` is a
binding, and it might not be a valid key path.


[Key-Value Coding (KVC)]: http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/KeyValueCoding/KeyValueCoding.html
[Key-Value Observing (KVO)]: http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html
[Cocoa Bindings Reference]: http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/CocoaBindingsRef/CocoaBindingsRef.html
[Implementing Your Own Cocoa Bindings]: /blog/cocoa/implementing-your-own-cocoa-bindings/

