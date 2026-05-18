{:title "Goblin Dot Business"
 :draft true
 :main-image {:uri "/images/posts/business-goblin.jpg"}
 :tags [:random-stuff :ai]}

Business Goblin (left) is a character created by friend and colleague Matthew
Grey (right). Originally drawn for an internal presentation, he represents
greedy unscrupulous businesses selling fake AI hype without the ability to
follow through on their promises. After the presentation, Business Goblin took
on a bit of a life of his own, appearing around the office as a life-sized
coreflute cutout.

Recently, after a couple of Friday evening beers, a small group of collegues and
I asked the question: what if you could email Business Goblin and he actually
emailed you back? I happened to be looking for an LLM-related side project, and
so 24 hours later [https://goblin.business/](https://goblin.business/) was up and
running.

Send him an email and see what he has to say.

<!--more-->

## LLM Learnings

I did this project to learn more about integrating LLMs into software. Here are
some of the things I learned in the process:

- Dumber models can be better at certain tasks than smarter models. Opus 4.7
  kinda sucked at pretending to be a goblin, but Hauku 4.5 pretty much nailed
  it.

- You can use an expensive LLM to tune the usage of a cheaper LLM. I
  had kind of accidentally arrived at the Temu version of Andrej Karpathy's
  [Autoresearch](https://github.com/karpathy/autoresearch), where I asked Claude
  Code (Opus 4.7) to tune the email generation (Haiku 4.5).

- Related to the above point, getting good results out of a clanker agent really
  requires solid feedback loops. TDD, type checking, linting tools, et cetera
  are more important than ever.

- There is this thing called "few shotting", which is where you include a few
  example inputs and outputs in the prompt for the LLM to learn from before
  giving it the _real_ input and getting it to generate something. This results
  in better output for certain kinds of tasks, e.g. generating emails from a
  goblin CEO.

- Anthropic has a pre-paid pricing model for LLM API requests, in contrast to
  most cloud providers. I like that.

- Cheap models are pretty cheap. $5 USD per million output tokens isn't too bad,
  considering I'm only outputting about 400 tokens per email. That's a lot of
  emails per dollar.

- But when you're paying per token, you probably want to think real hard about
  your rate limits. I've architected the project so that it can't cost more
  than ~$2 USD per day.

- There is no _reliable_ defense against prompt injection! This is pretty wild
  and concerning!

## Other Kinds Of Learnings

Some other things I learned are:

- [Purelymail](https://purelymail.com/) is a product that exists, and I can use
  it for whatever silly projects I want for a flat fee of $10 USD per year.
  Unlimited custom domains for no extra fee is pretty cool.

- [Dokploy](https://dokploy.com/) is ok but kinda janky. It's described as a
  "self-hosted Heroku" type of product, which _it is_, but the UX/DX isn't
  polished and I ran into bugs and gaps in documentation a few times. 

- [Tailscale](https://tailscale.com/) exists, and lets you set up a little VPN
  for free, with nice and polished UX. I hadn't heard of it before, and I was
  impressed.

- Python has types now. I haven't written any Python in hot minute. Looks
  decent.

- Avoiding spam filters is tricky, especially for a new domain. If you do the
  proper SMTP headers, the DNS records, and chant the forbidden phrase while
  lighting a red candle at midnight, eventually Gmail will let your emails
  through.

- It's fun watching people you know interacting with your software.

## What It Done Cost

I was also interested to learn the cheapest possible way to deploy a lil joke
project into production. The breakdown is:

- Domain (NearlyFreeSpeech): $14 USD/year.
- VPS (Linode): ~$10 USD/month. Could be slightly cheaper if I wasn't using
  Dokploy.
- Email hosting (Purelymail): $10 USD/year. Bargain.
- LLM API (Claude):
    - Minimum credit purchase: it says $5 USD now, but I swear it was about $20
      USD when I did it.
    - Credits per month: depends on how many emails the goblin gets, but should
      be less than $1 per month. 

So all up it costs about $220 AUD (~$156 USD) per year, or ~$18 AUD (~$13 USD)
per month. Slightly more than I'd like to pay for a dumb joke, but not terrible
considering I can use the VPS and email hosting for other projects at no
additional cost.
