# CLAUDE.md — tomdalling.com

## Project Overview

Custom-built Ruby static site generator for Tom Dalling's personal blog at https://www.tomdalling.com/. Not Jekyll or Hugo — it's a handcrafted generator in `lib/` under the `Statue::` namespace. Posts are markdown with EDN frontmatter; output is plain HTML deployed to GitHub Pages.

## Tech Stack

- **Ruby 3** — core generator (`lib/statue/`)
- **Kramdown + GFM** — markdown parsing; **Rouge** — syntax highlighting
- **Nokogiri** — HTML parsing/transformation
- **Zeitwerk** — class autoloading
- **value_semantics** — immutable value objects for models (Post, Frontmatter, etc.)
- **dry-cli** — CLI framework (`bin/site build`)
- **Hanami::Action** — lightweight dev server actions
- **Webpack 5 + Tailwind CSS 3 + PostCSS** — frontend CSS pipeline
- **TestBench** — testing framework
- **Foreman** — runs webpack watcher + dev server together

## Setup

```bash
gem install foreman
bundle install
cd input/frontend && yarn install
cd ../..
foreman start   # webpack watcher + dev server on port 5023
```

## Key Commands

| Task | Command |
|------|---------|
| Start dev server | `foreman start` |
| Build site | `bin/site build [--output=/path]` |
| Run tests | `bin/test test/automated` |
| New post | `bin/new-post` |
| REPL | `bin/repl` |

## Directory Structure

```
input/
  posts/         # Blog posts: YYYY-MM-DD_slug.md
  pages/         # Static pages (index.html, 404.html)
  templates/     # ERB/HTML templates
  static/        # Images, assets
  frontend/      # Webpack/Tailwind source
lib/
  boot.rb        # Bundler + Zeitwerk setup
  statue.rb      # Constants (BASE_URL, paths)
  statue/        # All generator code
    cli.rb              # CLI commands
    build.rb            # Build orchestration
    post.rb             # Post model
    page.rb             # Page model
    edn.rb              # Frontmatter parser
    markdown.rb         # Markdown → HTML
    outputs.rb          # Output generation
    *_output.rb         # PostOutput, FeedOutput, PageOutput, etc.
    *_transform.rb      # Content transformation pipeline
    dev_server.rb       # Dev server action
test/automated/    # TestBench tests
output/            # Generated HTML (git-ignored)
```

## Blog Post Format

Posts live in `input/posts/` as `YYYY-MM-DD_slug-name.md`.

Frontmatter is **EDN** (Clojure-like syntax), not YAML:

```edn
{:title "Post Title"
 :deprecated-category :software-design
 :tags [:ruby :oop]
 :draft false
 :main-image {:uri "/images/posts/image.jpg"
              :artist {:name "Photographer Name"
                       :url "https://unsplash.com/..."}}}
```

- `:draft true` — excluded from build output
- `:tags [:bleet ...]` — posts tagged `:bleet` are short-form "bleets"
- `<!--more-->` — splits post into preview and full content
- `:disqus-id` — optional legacy Disqus ID (Disqus is being removed)
- Output URL: `/blog/{slug}/`

## Deployment

GitHub Actions (`.github/workflows/main.yml`) runs on push to `main`:
1. RuboCop lint
2. `bin/test test/automated`
3. `bin/site build` → outputs into checked-out `gh-pages` branch
4. Commits and pushes to `gh-pages` → served by GitHub Pages

## Code Conventions

- All generator code in `Statue::` namespace, autoloaded by Zeitwerk
- Models use `value_semantics` gem — immutable, coerce-on-construction
- `Forwardable` / `def_delegators` used heavily for delegation
- `memery` gem for method memoization (`memoize :method_name`)
- Pathname types are wrapped (relative vs absolute) for safety
- Content passes through a transform pipeline (PostTransform, DOMTransform, etc.)
- RuboCop config is minimal — only debugger checks enforced

## Misc

- `bin/htmldiff` / `bin/xmldiff` / `bin/dirdiff` — regression diffing tools
- `CACHING.md` — documents the incremental build/caching strategy
- `.projections.json` — Vim alternate-file config (source ↔ test)
- TestBench executable config for Vim: `let test#ruby#testbench#executable = 'bin/test'`
- Tailwind tree-shaking runs *after* HTML generation (needs HTML to know which classes are used)
