{:title "Leprechauns, Root Causes, And Other Fairy Tales"
 :category :software-processes}

This is a short talk I gave a while ago about how complex systems fail, and root
cause analysis. Transcript is below.

<widget type="youtube" video="N0NQUt07FvI" />

<!--more-->

## Transcript

We're going to talk about root causes today, but since I only have about 10
minutes, I wanted to start with some stories from a book I'm writing called
_Bedtime Stories To Put Your Children To Sleep Instantly And Also Yourself_.

![Rainbow with leprechaun slide from
presentation](/images/posts/root-cause-talk/first-story.jpg)

This first story is about leprechauns. Once upon a time, there was a company
with a new employee, and one day the employee asked their manager "why does
everyone suddenly get in their cars as soon as it stops raining?".

The manager said "it's not about when the rain stops. It's about when the
rainbow appears. Common sense tells us that rainbows are produced by a pot of
gold left on the ground by a Leprechaun. Everyone knows this --- just go ask
your Irish ancestor from the 11th century. It's in books and stuff. But anyway,
so, whenever we see a rainbow our proceedure is to trace it back to its source
and get the gold. And when we get enough gold, we can all quit our jobs and we
won't have to work anymore."

The employee walked away from that conversation thinking: how come everyone's
still at work if they've been finding all these pots of gold? The end.

![Rainbow incident with leprechaun root cause slide from
presentation](/images/posts/root-cause-talk/second-story.jpg)

Now for a completed different story. Once upon a time, there was a software
company with a new employee. And one day the employee asked their manager "why
does everyone do root cause analysis after an incident?"

And the manager said "well, common sense tells us that every incident has a root
cause. And everyone knows this --- just ask people in the industry. It's in
books and stuff. But anyway, whenever we have an incident, our proceedure is to
ask the five whys. Why?! Why?! Why?! Why?! Why?! Why did this happen to us?! And
that allows us to trace the incident back to its root cause, so that we can
eliminate it. And once we've eliminated all the root causes, we won't have any
incidents anymore."

The employee walked away from this conversation thinking: how come we have so
many incidents if we've been eliminating root causes this whole time? The end.

So thanks for listening to my stories. Book coming soon. Now I'll get on with my
talk: Leprechauns, Root Causes, And Other Fairy Tales.

This talk is largely based on a well-known paper called _How Complex Systems
Fail_ by Richard Cook. It's only three pages long, so I'd encourage everyone
here to give it a read. And while making this talk, I found out that someone has
turned it into a website:
[https://how.complexsystems.fail](https://how.complexsystems.fail), which is
nice. Whenever you hear me say "complex system" in this talk, think of something
like a bank or a large system of software. Let's look at a few points the paper
makes.

> Complex systems are intrinsically hazardous systems

What this is basically saying is that incidents arise from complexity. It
doesn't matter how many root causes you fix --- if you have a sufficiently
complex system there will always be problems.

> Complex systems run in degraded mode

So if complexity is the cause of problems, then you would expect complex systems
to be constantly experiencing problems, and that is exactly what you find when
you look at any complicated system. Major incidents might be rare, but minor
failures are happening all the time.

> Complex systems are heavily and successfully defended against failure

So if they're constantly having all these problems, you would expect them to
grind to a halt and die, but they don't. And that's because every complex system
has a multitude of defenses that protect it from small localised failures
cascading into major system-wide failures. So every complex system has these,
and they wouldn't be able to exist if they didn't have them.

> Catastrophe requires multiple failures --- single point failures are not
> enough

So if they have all these defenses against problems, how come major incidents
are still possible? That's because each individual layer of defense is not
perfect. When one layer fails, usually it gets caught by a different layer, but
sometimes it will slip through several layers of defense before getting caught.
So to get a really nasty major incident, you have to have several failures all
line up perfectly to allow that to slip through.

And that kind of brings us to the heart of this talk, so I'm going to read
verbatim from the paper at this point (emphasis mine).

> Post-accident attribution to a 'root cause' is fundamentally wrong.
>
> Because overt failure requires multiple faults, **there is no isolated
> 'cause'** of an accident. There are multiple contributors to accidents. Each
> of these is necessarily insufficient in itself to create an accident. Only
> jointly are these causes sufficient to create an accident. Indeed, it is the
> linking of these causes together that creates the circumstances required for
> the accident. This, no isolation of 'root cause' of an accident is possible.
> The evaluations based on such reasoning as **'root cause' do not reflect a
> technical understanding of the nature of failure** but rather the **social,
> cultural** need to **blame** specific, localized forces or events for
> outcomes.

The paper goes on to say that:

> Views of 'cause' limit the effectiveness of defenses against future events

So when you go hunting for a root cause, you always find one, but the problem is
that you always find _one_. And this fulfils the social need to place blame on
something, but it doesn't necessarily help to reduce the risk of future
incidents.

An earlier quote from the paper said that hazard arises from complexity. And
what do we do when we fix a root cause? We fix it by adding new rules, new
processes, new checks and guards --- in other words, new _complexity_ --- to the
system. So, ironically, every time we try to fix a root cause and reduce our
risk, we may accidentally be increasing our risk by adding complexity.

I want to leave a couple of things with you, from this talk.

The paper says "the social need to blame" but I think "scapegoating" is a
punchier term. So whenever you hear someone say "root cause" you can take that
part of the sentence, replace it with the word "scapegoat", and it _will_ still
make sense. I guarantee that the sentence will still make sense. And it should
give you a new perspective on the conversation you're having, as well.

I didn't have time to talk about good alternatives, but I would recommend Swiss
cheese. You can google "the Swiss cheese model of accident causation" or just
come talk to me later.

And if you take anything from this talk, I hope it's this: root causes are like
leprechauns --- fun to think about, but completely fictional.

Thank you.
