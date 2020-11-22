# TomDalling.com

Static website generator for tomdalling.com, including output.

## TODO

 - [ ] check that URLs are being rendered correctly into every page
 - [ ] Upgrade mathjax
 - [ ] Found mistake in old website: `B &times; A`
   (https://www.tomdalling.com/blog/modern-opengl/03-matrices-depth-buffering-animation/)
 - [ ] Found mistake in old website: `*require*` in an aside
   (https://www.tomdalling.com/blog/modern-opengl/03-matrices-depth-buffering-animation/_
 - [ ] `img.listed-main-image` element is still present even when
   there is no main image for a post

## Testing Stuff

```vim
let test#ruby#testbench#executable = 'bin/test'
```

```bash
find -E output -iname "*.html"| sort | xargs -n 1 bin/htmldiff | tee diff.txt
```

