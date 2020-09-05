{:title "Coding Tip: Replace Complicated Conditions With Boolean Variables"
 :disqus-id "196 http://tomdalling.com/?p=196"
 :category :coding-tips}

Consider the following if statement:

```objc
if(dragOperation != NSDragOperationCopy && NSPointInRect(currentMouseLocation, self.bounds)){
    //do something
}
```

Even though you may have worked out what the condition represents, it probably
took you a little longer than it should. It's complicated, making it time
consuming to read, and prone to bugs upon modification. Thankfully, there is an
easy remedy:

<!--more-->

```objc
BOOL isMovingWithinSelf = dragOperation != NSDragOperationCopy && NSPointInRect(currentMouseLocation, self.bounds);
if(isMovingWithinSelf){
    //do something
}
```

By using the variable name to explain the *intent* of the condition, the code
is made more readable. This technique is also useful when the condition is
simple, but the intent is unclear. Consider this example:

```objc
if([commandLineArgs containsObject:@"-scm"])
    //...
```

`"-scm"` could mean anything. It would be much clearer if it was written like so:

```objc
BOOL isInSuperCoolMode = [commandLineArgs containsObject:@"-scm"];
if(isInSuperCoolMode)
    //...
```

When written this way, it is obvious that the `"-scm"` command line argument
activates "super cool mode."
