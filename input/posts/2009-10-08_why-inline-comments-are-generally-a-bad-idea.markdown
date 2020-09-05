{:title "Why Inline Comments Are Generally a Bad Idea"
 :disqus-id "208 http://tomdalling.com/?p=208"
 :category :coding-styleconventions}

Bellow is a single function commented in two different ways. Which one is
better?

```objc
NSString* MD5StringOfString(NSString* inputStr)
{
    //UTF8 encoding is used so the hash can be compared with hashes of ASCII strings
    NSData* inputData = [inputStr dataUsingEncoding:NSUTF8StringEncoding];

    unsigned char outputData[CC_MD5_DIGEST_LENGTH];
    CC_MD5([inputData bytes], [inputData length], outputData);

    NSMutableString* hashStr = [NSMutableString string];
    int i = 0;
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; ++i)
        [hashStr appendFormat:@"%02x", outputData[i]];
 
    return hashStr;
}

```

```objc
NSString* MD5StringOfString(NSString* inputStr)
{
    //convert the string to UTF8 encoded byte data
    NSData* inputData = [inputStr dataUsingEncoding:NSUTF8StringEncoding];

    //calculate the hash
    unsigned char outputData[CC_MD5_DIGEST_LENGTH];
    CC_MD5([inputData bytes], [inputData length], outputData);

    //convert hash to a hexadecimal string
    NSMutableString* hashStr = [NSMutableString string];
    int i = 0;
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; ++i)
        [hashStr appendFormat:@"%02x", outputData[i]];
 
    //return the hexadecimal string
    return hashStr;
}

```

<!--more-->

The Good
--------

The single comment in the first block of code doesn't explain *what* the code
does, but explains *why*. The difference is that the "why" can't be discerned
from the code alone. Someone editing the code would see this comment, and know
not to change the encoding unless they wanted to break compatibility with ASCII
string hashes.

The Bad
-------

The comments in the second block of code are redundant. They explain *what* the
code does, which is information that the code already contains. If the code is
too difficult to understand, then it should be decomposed into functions with
meaningful names like so:

```objc
NSString* MD5StringOfString(NSString* inputStr)
{
    NSData* inputData = [inputStr dataUsingEncoding:NSUTF8StringEncoding];
    NSData* hashData = MD5HashOfData(inputData);
    return HexadecimalStringFromData(hashData);
}
```

I would argue that the above code with no comments is much easier to read than
the original code with four comments. Hard-to-read code should be rewritten
properly, instead of being explained with comments. 

The Heart of the Matter
-----------------------

Some people think comments are extra information that you get for free. If
they appear to have no cost associated with them, and there is no downside to
extra information, then comments sound awesome. The problem lies in the fact
that **there *are* costs associated with comments**.

Each comment, good or bad, comes with a future maintenance cost because they
must be synchronized with the code whenever changes are made. The more
comments, the higher the maintenance cost. On top of this, if a comment were to
get out of sync, it could confuse the reader which is also expensive in terms
of time and the possible introduction of bugs. You can't run comments, and a
comment that lies is worse than no comment at all.

My advice is to:

 -  Avoid comments that explain "what" the code does.

 -  Only include "why" comments if they are of decent value to developers
    maintaining the code.

 -  Always delete code that has been commented out. If you really need the old
    code, it should be available from your version control software anyway.

If you disagree with me, feel free to share your thoughts in the comments. Pun
intended!

P.S. Auto-documentation comments (Javadoc, Doxygen, etc.) may be a necessary
evil.

P.P.S. See [this post by Peter Hosey][] where he almost accidentally committed an incorrect
comment, then refactors the code to avoid the comment entirely.

[this post by Peter Hosey]: http://boredzo.org/blog/archives/2009-08-14/variables-for-clarification "Variables for clarification"

