{:title "What Is The Purpose Of Private?"
 :main-image {:uri "/images/posts/private.jpg"}
 :category :software-design}

Why use `private` at all? What is the benefit of trying to stop other
people from using code that works perfectly well? It's to reduce
future maintenance costs by discouraging coupling to unstable
dependencies.

<!--more-->

## Change Has Costs

Codebases are constantly evolving. New code gets added to implement
new requirements. If we're lucky, existing code gets renamed,
redesigned, refactored and broken apart to improve clarity,
simplicity, and performance. And if we're _really_ lucky, code
eventually becomes obsolete and gets deleted.

But it's difficult to build upon code that is constantly changing. It's
like trying to build a house on shifting sand. If we write some code
that calls a method, can we rely upon that method working correctly
six months from now? What if someone changes the behaviour of the
method in a way that we aren't expecting? Will they realise that we
depend upon that behaviour, and be careful not to break our code?
Maybe. After six months, I wouldn't even trust myself to remember. 

These problems incur real costs, mostly in terms of wasted developer
time --- for example, time spent fixing bugs in previously-working
code due to changes in dependencies. But there are also nasty
second-order costs like developers adopting a very defensive style of
coding, due to perceiving the codebase to be fragile and
unreliable in general.

## Private Communicates Stability

Categorising code as either `public` or `private` is an attempt to
reduce the costs of change by _communicating stability_. Designating
something as `private` communicates to other developers that _this
thing might change so don't rely upon it_. Conversely, designating
something as `public` says that _this thing is fairly stable so you
can rely upon it_, or at least that _this thing is more stable than
the private things_.

Compilers, linters, and runtime environments assist us, but ultimately
it is still developers communicating information about stability to
other developers.

## The Benefits

Communicating stability with `public` and `private` has multiple
benefits.

1. We are more careful about making changes to public behaviour,
   leading to fewer bugs.

1. People can make changes to private behaviour more quickly and
   confidently, knowing that it is unlikely to affect the rest of the
   codebase.

1. When writing new code, we can make it more reliable by avoiding
   coupling to unstable dependencies.

1. When designing classes and modules, it prompts us to invest thought
   into which parts should be stable, and which parts we want to be
   free to change in the future. This results in code that
   accommodates future changes more easily.

In summary, judicious use of `private` reduces maintenance costs.

## An Example

Let's say we're writing an integration with the VisageNovel web API
to fetch some user info. We might start with something like this:

```ruby
class VisageNovelIntegration
  def fetch_user_info(user)
    response = Net::HTTP.get("https://visagenovel.com/user/#{user.id}")
    JSON.parse(response.body)
  end 
end
```

This works, but the thought occurs that VisageNovel is well known for
"moving fast and breaking things", and is particularly good at the
latter. Let's invest a little bit of brainpower and consider how that
might affect us in the future.

By returning the JSON response body from `fetch_user_info`, it becomes
part of the public interface of `VisageNovelIntegration`. That is,
other parts of the application will call `fetch_user_info` and dig
through the return value to get the data that they need. Put another
way, the callers of `fetch_user_info` are _directly coupling to the
structure of VisageNovel's API response, which we expect to be
unstable_. Whenever VisageNovel changes the response body --- which
sounds likely and is outside of our control --- there is the potential
to break every part of our codebase that uses `fetch_user_info`. This
is not good.

To mitigate this risk, we need to stop returning the raw API response
from `fetch_user_info`. This will reduce the coupling between the API
response and rest of the application. We want the code that parses the
API response to be private, so that it can be changed easily in the
future. One way to achieve this is to return a value object instead.
It might look something like this:

```ruby
class VisageNovelIntegration
  class UserInfo
    value_semantics do
      id Integer
      email String
      picture_url String
    end
  end

  def fetch_info(user)
    response = Net::HTTP.get("https://api.visagenovel.com/user/#{user.id}")
    user_info_from(response)
  end

  private

    def user_info_from(response)
      json = JSON.parse(response.body)
      UserInfo.new(
        id: json['id'],
        email: json['email'],
        picture_url: json['picture'],
      )
    end
end
```

Also, perhaps we're not 100% happy with `user_info_from`, and can see
it being refactored later. It is new, after all, and new things tend
to change and grow for a while before they become stable. These are
all good reasons to keep the method private. We want to communicate to
other developers that it should not be relied upon.

Let's say that two months later we get an email from VisageNovel like
this:

> Dear developer,
>
> We've made some exciting additions to the API. There are new
> endpoints available for getting info about pictures. As a result,
> the `/user/[id]` endpoint no longer includes this information in its
> response.
>
> Regards,
>
> The VisageNovel API Team

This is now a relatively easy change to handle. The affected code is
private, so we can change it without worrying about how it might
impact the rest of the application. We might end up with something
like this:

```ruby
class VisageNovelIntegration
  class UserInfo
    value_semantics do
      id Integer
      email String
      picture_url String
    end
  end

  def fetch_info(user)
    attrs = fetch_user_info(user)
    attrs[:picture_url] = fetch_picture_url(user)
    UserInfo.new(**attrs)
  end

  private

    def fetch_user_info(user)
      json = fetch("user/#{user.id}")
      {
        id: json['id'],
        email: json['email'],
      }
    end

    def fetch_picture_url(user)
      json = fetch("picture/profile/#{user.id}")
      json['url']
    end

    def fetch(path)
      response = Net::HTTP.get("https://api.visagenovel.com/#{path}")
      JSON.parse(response.body)
    end
end
```

The private methods are completely different, while the public
interface remains the same. We are able to make changes and refactor
with confidence, knowing that we aren't breaking other parts of the
codebase.

## Addendum: Safety

Some commenters have correctly pointed out that `private` is also used
to discourage people from using behaviour that is potentially unsafe.
This is more apparent in languages like Rust, which has explicit
syntax for "safe" and "unsafe" code, where the unsafe code is
typically private.

The assumption is that external callers probably don't understand how
to use the dangerous functionality safely, and therefore should be
prevented or discouraged from using it.

The corollary assumption is that internal callers _do_ understand how
to use the dangerous functionality correctly. This is more likely than
for external callers but not guaranteed, so I would strive to make the
private code as safe as the public code wherever possible. Private
shouldn't be seen as a license to ignore safety.

