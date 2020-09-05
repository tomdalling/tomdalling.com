{:title "When A Café Is Not A Café – A Short Lesson In Unicode Featuring NSString"
 :disqus-id "576 http://tomdalling.com/blog/?p=576"
 :category :coding-tips}

Let's start with two exotic strings (console output is in the code comments):

```objc
NSString* apples = NSGetFrenchWord();
NSString* oranges = NSGetFrenchWord();

NSLog(@"apples == '%@'", apples); 
//apples == 'café'
NSLog(@"oranges == '%@'", oranges); 
//oranges == 'café'
```

They look identical, but looks can be deceiving.

```objc
NSLog(@"isEqual? %@", [apples isEqual:oranges] ? @"YES" : @"NO");
//isEqual? NO
NSLog(@"[apples length] == %lu", [apples length]);
//[apples length] == 4
NSLog(@"[oranges length] == %lu", [oranges length]);
//[oranges length] == 5
```

<!--more-->

But if you were to sort them they should be the same, right?

```objc
NSLog(@"NSOrderedSame? %@", [apples compare:oranges] == NSOrderedSame ? @"YES" : @"NO");
//NSOrderedSame? YES
```

Well at least sorting works. Let's inspect the strings one character at a time.

```objc
NSString* CodePoints(NSString* str)
{
    NSMutableString* codePoints = [NSMutableString string];
    for(NSUInteger i = 0; i < [str length]; ++i){
        long ch = (long)[str characterAtIndex:i];
        [codePoints appendFormat:@"%0.4lX ", ch];
    }
    return codePoints;
}

NSLog(@"apples == %@", CodePoints(apples));
//apples == 0063 0061 0066 00E9
NSLog(@"oranges == %@", CodePoints(oranges));
//oranges == 0063 0061 0066 0065 0301
```

So they are, in fact, different strings. 

If you were to look up the above Unicode characters (a.k.a code points) you
would find that:

 -  `0063` is 'c'
 -  `0061` is 'a'
 -  `0066` is 'f'
 -  `0065` is 'e'
 -  `00E9` is '&#xe9;' (LATIN SMALL LETTER E WITH ACUTE)
 -  `0301` is '&#xb4;' (COMBINING ACUTE ACCENT)

There are at least two ways to represent the glyph '&#xe9;' in Unicode. One way
is with the single code point `00E9`. The other is with two code points: an 'e'
code point (`0065`) followed by a combining acute accent code point (`0301`).
Unicode sort of works like ASCII, but not quite.

This is where [Unicode normalization/equivalence][] comes into play.
"Normalizing" a Unicode string simply involves taking all the glyphs that look
the same and giving them the same code point sequence. You can "compose" all
the glyphs, which will translate the two code points <code>0065</code> `0301`
into a single code point `00E9`. You can also "decompose" all the glyphs, which
will do the opposite. There are [four types of Unicode normalization][], and
`NSString` provides methods for all of them:

 -  [decomposedStringWithCanonicalMapping][] 
 -  [decomposedStringWithCompatibilityMapping][] 
 -  [precomposedStringWithCanonicalMapping][] 
 -  [precomposedStringWithCompatibilityMapping][] 

Mad props to Simon for the tip.

[Unicode normalization/equivalence]: http://en.wikipedia.org/wiki/Unicode_normalization
[four types of Unicode normalization]: http://unicode.org/reports/tr15/
[decomposedStringWithCanonicalMapping]: https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSString_Class/Reference/NSString.html#//apple_ref/occ/instm/NSString/decomposedStringWithCanonicalMapping
[decomposedStringWithCompatibilityMapping]: https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSString_Class/Reference/NSString.html#//apple_ref/occ/instm/NSString/decomposedStringWithCompatibilityMapping
[precomposedStringWithCanonicalMapping]: https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSString_Class/Reference/NSString.html#//apple_ref/occ/instm/NSString/precomposedStringWithCanonicalMapping
[precomposedStringWithCompatibilityMapping]: https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSString_Class/Reference/NSString.html#//apple_ref/occ/instm/NSString/precomposedStringWithCompatibilityMapping

