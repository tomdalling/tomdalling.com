Caching
=======

I want this static website generator to cache as much as possible.
This includes inputs, intermediates, and outputs. The idea is that
rebuilding outputs should only do the absolute minimum of work,
leading to very fast build times (minus the first build). This is much
like an incremental build when compiling source code.

## Aims

- Deleting a post's markdown file removes the post from all applicable
  indexes and sidebars

- Adding a new post markdown file adds the post to all applicable
  indexes and sidebars

- Modifying a post's markdown file updates the post, all applicable
  indexes, and sidebars. This includes things like changing the
  publish date, which affects the order of indexes.

- Modifying a template updates all usages of the template

- Exceptions should be captured and reported gracefully, allowing a
  build to be retried

- Stretch goal: the cache should survive the process exiting and
  starting again.

- Non aim: modifying the generator's source code rebuilds all
  affected outputs. It's too hard to know which outputs are affected
  by which files/classes. Possibly some Ruby files could be reloaded
  when changed, but these would need to be loaded from the input dir
  like all the other inputs.

## Notes

This will need to be a dependency graph. The more intermediate nodes
between the inputs and outputs, the more effective the caching will
be.

Can the dependency graph contain cycles? My heart says "no", but my
brain says "your heart is not qualified to answer that question".
Let's go with a tentative "no".

Detecting modified files is easy, but detecting when inputs have been
added or deleted from a specific list (such as the list of most recent
posts) is harder. In the case of most recent posts, whether a
new/deleted/modified file affects the list depends on the date
specified within the file.

Hashing file/intermediate contents would give good cache keys, but I'm
trying to avoid hitting the disk, so I think using file modification
times will suffice. Modification times will have race conditions, but
it doesn't need to be 100% infallible, it just needs to work correctly
most of the time while writing content or tweaking templates.

Repeatedly checking the modification time of a file could be slow too.
Each output will depend on multiple inputs and templates, so I could
end up with an n*m situation. I might want to do fetch all mtimes up
front, once per build, or at least memoize the value when requested.
It would probably be fastest to shell out once and get a complete list
of all files with their mtimes.

TODO: One tough problem is that markdown files can include templates
in them, meaning that I can't know the dependencies of a post without
rendering it. I don't want to have to render every post to build the
dependency graph, because that kind of defeats the purpose. Also, I
need to handle those dependencies being added or removed every time
the markdown file is modified.

Annoyingly, I can't determine what the outputs are until I read the
inputs, and I can't determine all the inputs until I render the
outputs. It's looking like a two phase algorithm --- first phase
builds the outputs from some of the input files, second phase renders
outputs and records the dependencies that couldn't be determined
beforehand. And possibly a third phase, where outputs are duplicated
to keep old URLs working after I've changed them.

It's probably easiest to do this with immutable nodes. The new
dependency graph is a function of the old dependency graph and the
current state of the file system. Unchanged nodes can be reused, while
changed nodes will be rebuilt.

Mtime isn't going to cut it for directories of files, such as all
posts. To detect modification of a directory, I'll need to compare the
list of files currently in the directory against the list of files
previously seen in the directory. Basically, I can't do
`all_posts.modified_since?(mtime)`, I will need to do something like
`new_all_posts = all_posts.updated_using(current_file_system)`.

TODO: Config changes can trigger rebuilds too, so I need to know which
nodes are affected by which config values. Tricky. I guess that the
config is kind of like a global input, and the file should probably
live in the input dir.

TODO: Need to handle switching between development config,
and production config.
