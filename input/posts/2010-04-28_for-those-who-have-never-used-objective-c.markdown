{:title "For Those Who Have Never Used Objective-C"
 :disqus-id "411 http://tomdalling.com/?p=411"
 :category :coding-styleconventions}

There is one feature of the Objective-C language that I really love: the method
naming. Let me explain with an example.

Here is a nasty call to a C function from the Win32 API that has 12 arguments:

```c
hwnd = CreateWindowEx(WS_EX_LAYERED,
                      TEXT("Hello"),
                      TEXT("World"),
                      WS_OVERLAPPEDWINDOW,
                      10, 
                      10,
                      400, 
                      400,
                      NULL, 
                      NULL,
                      hInstance, 
                      NULL);
```

Pick an argument, any argument. What does it do? You can probably guess a
couple of them, but basically you're forced to look up the documentation. Sure,
12 arguments is a bit excessive, but even three or for argument functions can
be ambiguous. What if you're trying to understand a function call that is being
passed three number literals as arguments? Even if you know the function,
you'll probably have to look up the documentation just to remember the order of
the arguments.

Now for the equivalent in Objective C:

<!--more-->

```objc
hwnd = [SomeClass createWindowExWithExtentedStyle:WS_EX_LAYERED
                                        className:TEXT("Hello")
                                       windowName:TEXT("World")
                                            style:WS_OVERLAPPEDWINDOW
                                                x:10
                                                y:10
                                            width:400
                                           height:400
                                           parent:NULL
                                             menu:NULL
                                         instance:hInstance
                                            param:NULL];
```

Aren't the named arguments great? 

At first it feels redundant when you're writing method declarations because the
method name segments are basically the same as the argument name. The method
declaration for the above method would look like this:

```objc
+(HWND) createWindowExWithExtentedStyle:(DWORD)extendedStyle
                              className:(LPCTSTR)className
                             windowName:(LPCTSTR)windowName
                                  style:(DWORD)style
                                      x:(int)x
                                      y:(int)y
                                  width:(int)width
                                 height:(int)height
                                 parent:(HWND)parent
                                   menu:(HMENU)menu
                               instance:(HINSTANCE)instance
                                  param:(LPVOID)param;
```

Yes, it is a bit redundant in the declaration, but reading code that *calls*
the method is so much easier. Whenever I write something in another language, I
miss my named arguments.

