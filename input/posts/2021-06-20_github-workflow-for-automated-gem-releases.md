{:title "GitHub Workflow For Automated Gem Releases",
 :main-image {:uri "/images/posts/automated-gem-releases.jpg" :visible? false}
 :category :software-processes}

This is a quick look at the recent CI/release automation I wrote for
the [byebug-skipper][] gem.

<widget type="youtube" video="fmWgh2qsLlc" />

## Links

- [Commits from the video](https://github.com/tomdalling/byebug-skipper/commits/youtube-video)

- [The "Release Gem" GitHub workflow](https://github.com/tomdalling/byebug-skipper/blob/7d784e6d4ec71f21405082ccf09626b21f5597e7/.github/workflows/release.yml)

- [Config](https://github.com/tomdalling/byebug-skipper/blob/7d784e6d4ec71f21405082ccf09626b21f5597e7/.versionrc.js)
  for [standard-version](https://github.com/conventional-changelog/standard-version),
  which is what bumps the version and updates the changelog using the
  commit history.

- [CI step](https://github.com/tomdalling/byebug-skipper/blob/7d784e6d4ec71f21405082ccf09626b21f5597e7/.github/workflows/ci.yml#L23-L26)
  that ensures commit messages have the correct format 

[byebug-skipper]: https://github.com/tomdalling/byebug-skipper
