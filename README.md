# TomDalling.com

Static website generator for tomdalling.com, including output.

## TODO

 - [ ] check that URLs are being rendered correctly into every page
 - [ ] `img.listed-main-image` element is still present even when
   there is no main image for a post

## Testing Stuff

```vim
let test#ruby#testbench#executable = 'bin/test'
```

```bash
find -E output -iname "*.html"| sort | xargs -n 1 bin/htmldiff | tee diff.txt
```

