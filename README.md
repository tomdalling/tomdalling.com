# Statue

Static website generator

Testing:

```vim
let test#ruby#testbench#executable = 'bin/test'
```

Big diff:

```bash
find -E output -iname "*.html"| sort | xargs -n 1 bin/htmldiff | tee diff.txt
```

## TODO

 - [ ] replace all URL strings/pathnames with real URL objects
 - [ ] check that URLs are being rendered correctly into every page
 - [ ] check if canonical urls should have hostname, or just path
 - [ ] category index canonical urls are wrong
 - [ ] Upgrade mathml
 - [ ] Found mistake in old website: `B &times; A`
   (https://www.tomdalling.com/blog/modern-opengl/03-matrices-depth-buffering-animation/)
 - [ ] Found mistake in old website: `*require*` in an aside
   (https://www.tomdalling.com/blog/modern-opengl/03-matrices-depth-buffering-animation/_
