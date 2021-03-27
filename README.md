# TomDalling.com

Static website generator for tomdalling.com, including output.

## Getting Started

Install whatever the dependencies are (Ruby, `bundle install`, Yarn,
`cd input/frontend && yarn install`, etc.).

Run the `Procfile` to get a development environment.

```sh
gem install foreman
foreman start
```

## TODO

 - [ ] Check that URLs are being rendered correctly into every page
 - [ ] Remove Disqus. It's injecting a bunch of spammy ads.
 - [ ] Add unique id to assets for cache busting
 - [ ] Replace categories with tags

## Testing Stuff

```vim
let test#ruby#testbench#executable = 'bin/test'
```

```bash
find -E output -iname "*.html"| sort | xargs -n 1 bin/htmldiff | tee diff.txt
```

