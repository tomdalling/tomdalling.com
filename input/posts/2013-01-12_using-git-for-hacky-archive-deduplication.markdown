{:title "Using Git For Hacky Archive Deduplication"
 :disqus-id "980 http://tomdalling.com/?p=980"
 :main-image {:uri "/images/posts/git-logo.png"}
 :category :random-stuff}

Have you ever wished that `tar` or `zip` would deduplicate files when creating
an archive? Well here's a hacky solution using [git][].

<!--more-->

How It Works
------------

Git already has deduplication functionality, due to the way it stores files.
Internally, files are named using their own checksums, so if two files have the
same checksum then only one copy of the file is stored.

So, to make use of this, if you add all the files to a new git repo then it
will perform the deduplication. Then, you archive the `.git` directory of the
repo with `zip` or `tar`.

When unarchiving, you just do the opposite. Unzip the `.git` directory inside
the destination directory. Run `git reset --hard` to bring back all the
duplicate files. Then, just delete the `.git` folder.

Git will also do zlib compression if you run `git gc --aggressive`. Bzip2
compression is better, but why not have both?!

The Results
-----------

I took some [recent work][], which I know contains duplicate files, to test if
this would actually work. Here are the results:

    39M   original
    3.5M  original.gitar
    10M   original.tar.bz2
    2.7M  original.tar.lrz *see update below

The original directory contained 39mb of files. Running `tar cjf
original.tar.bz2 original`, which uses bzip2 compression, compressed the folder
to about **25%** of it's original size. The git method compressed the folder to
about **10%** of it's original size. So it does actually work.

Update: lrzip is better
-----------------------

After publishing this article, someone suggested trying [lrzip][], which I
hadn't heard of before. It doesn't do file deduplication *per se*, but it does
a good job of compressing files with large chunks of redundant data &ndash;
such as a tarball of duplicate files. By default it uses LZMA compression,
which seems to be better than bzip2.

Running `tar cf original.tar original && lrzip original.tar` produces a file
named `original.tar.lrz` with a size of `2.7M`, which is a bit better than the
git method.

The Script
----------

<div class="alert alert-info">
  <strong>Update:</strong> Sam Gleske has written a more robust script here:
  <a href="https://github.com/sag47/drexel-university/tree/master/bin#gitarsh---a-simple-deduplication-and-compression-script">
    http://github.com/sag47/drexel-university/tree/master/bin
  </a>.
</div>

Here is a quick and nasty script called `gitar.sh` that makes these
deduplicated archives. Use `gitar.sh myfolder` to create the `myfolder.gitar`
archive. Then use `gitar.sh myfolder.gitar` to recreate the original folder.

Do whatever you want with the script. I've released it under the MIT license
just because I don't want to get sued if someone copy/pastes it onto a
production server and everything explodes.

<script src="https://gist.github.com/4535447.js"></script>

[git]: http://git-scm.com/
[recent work]: https://github.com/tomdalling/opengl-series
[lrzip]: https://github.com/ckolivas/lrzip

