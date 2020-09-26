{:title "What's Stopping You From Coding Like This?"
 :category :random-stuff}

I made a [quick-and-dirty Ruby script][gist] that animates the [GitHub
contributions calendar][], for the express purpose of making this
satirical video:

<widget type="youtube" video="5wbtCyZTbTU" />

<!--more-->

## Background

Twitter user Hays Stanford asked "what's stopping you from coding like
this?", with a screenshot of a mostly-full GitHub contributions
calendar.

<widget type="tweet" href="https://twitter.com/haysstanford/status/1306209477226569729" />

I'm still not sure whether this tweet was deliberate trolling or
accidental trolling, but it sure made a lot of people [feel some kind
of way][feel]. A couple of [big][hanselman] [names][booch] stepped in
to denounce its message. Some people were leaving excessively spiteful
and nasty replies. There was no need for that.

<widget type="tweet" href="https://twitter.com/cassidoo/status/1306263579897688065" />

I knew of [scripts that manipulate the GitHub contributions
calendar][commit_script], and it occurred to me that I could take that
one step further by animating it.

<widget type="tweet" href="https://twitter.com/tom_dalling/status/1306855833519534080" />

I made a slapdash Ruby script that converts ASCII art strings into
frames -- grids of colours -- and uses those to generate a video -- an
array of frames. The video is serialised and interpolated into some
vanilla JavaScript that applies the next frame's colours to the DOM
every few milliseconds. I pasted the JavaScript into the Chrome
console to kick it off.


## Some Takeaways

Measuring developer productivity is a sensitive topic. Plenty of
people reacted to the original tweet as if it were a personal attack.
The GitHub contributions calendar has some strong negative emotions
associated with it.

Outrage is viral. If not for the haters, nobody would have seen the
original tweet. It was spread to a massive audience by those who
disliked it. 

Optimal code quality is a return on investment calculation. Low
quality code can be optimal, depending on the context.

Memes.

[commit_script]: https://bd808.com/blog/2013/04/17/hacking-github-contributions-calendar/
[GitHub contributions calendar]: https://docs.github.com/en/github/setting-up-and-managing-your-github-profile/viewing-contributions-on-your-profile#contributions-calendar
[gist]: https://gist.github.com/tomdalling/2540a1c785d51da2bf0d57164bd26d96
[feel]: http://onlineslangdictionary.com/meaning-definition-of/feel-some-kind-of-way
[hanselman]: https://twitter.com/shanselman/status/1306719133615050752
[booch]: https://twitter.com/Grady_Booch/status/1306252038834016258
