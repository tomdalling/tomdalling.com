# TomDalling.com

Static website generator for tomdalling.com, including output.

## TODO

 - [ ] check that URLs are being rendered correctly into every page

## Testing Stuff

```vim
let test#ruby#testbench#executable = 'bin/test'
```

```bash
find -E output -iname "*.html"| sort | xargs -n 1 bin/htmldiff | tee diff.txt
```

