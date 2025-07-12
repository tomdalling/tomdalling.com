{:title "Work In Thin Vertical Slices"
 :main-image {:uri "/images/posts/thin-slices.jpg"}
 :category :mentoring}

Work should be completed in a series of small changes, where each change is a
polished, fully-working improvement.

<!--more-->

## What is a “horizontal slice”?

*Horizontal* slices are the individual layers of the system, e.g. the front end
is a horizontal slice, and so is the back end. These are the opposite of
vertical slices. Working in horizontal slices looks like:

1. First I’ll deploy the database migration
1. Then I’ll write the model with some unit tests
1. Then I’ll make the front end, even though it’s not hooked up to anything
1. Then I’ll write the controller that connects the front end to the model
1. Then I’m done

## What is a “vertical slice”?

In contrast, *vertical* slices are pieces of functionality that are fully
complete, and provide some kind of value. Working in vertical slices looks like:

1. First I’ll add the new page with basic information about a Foo
2. Then I’ll add a new section to the page with extra information about the Foo’s status
3. Then I’ll add a button to the page that marks the Foo as “completed”
4. Then I’ll add a new page that lists all the Foos
5. Then I’m done

Each vertical slice cuts across *all* of the horizontal slices. For example,
each vertical slice includes *both* the front end *and* the back end.

## Why?

Horizontal slices are notorious for the problems they cause, compared to
vertical slices.

| Horizontal Slices | Vertical Slices |
| --- | --- |
| All value is delivered at the very end of the project. Changes are useless until the final step is completed. | Value is delivered immediately and consistently over the duration of the project. Users get a little bit of useful functionality at every step. |
| There is no good indication of whether the project is on the right track or not. | It’s easy to evaluate whether the project is making progress towards the desired outcome or not. |
| Developers don’t receive feedback, and so have no reason to change course if they are heading in a bad direction. | Developers received feedback early and often, which makes it easier to tell if the project is achieving the intended outcome. Feedback can be used to quickly change course if needed. |
| When problems are inevitably discovered, they are discovered late and often lead to large amounts of wasted time and rework. The final step is often the one with the most risk, and can have the ability to tank the entire project. | When problems are inevitably discovered, they are found early and rework is minimal. Vertical slices can be prioritised based on risk, allowing the project to be validated and de-risked before too much work has been wasted. |
| The horizontal layers have a tendency to not integrate together well. The layers are “completed” independently without knowing exactly how they will interface with other layers, and often need considerable rework once it becomes clear how they will actually be used. | The horizontal layers are always fully integrated. They are extended whenever new functionality is clearly needed, which makes it easier to design a good interface. Horizontal layers are only completed at the very end of the project, when all of the use cases have been implemented. |
| Horizontal slices are difficult to review. How can you determine whether code is good or correct if you can’t see how it will be used? | Vertical slices are easier to review well, because all the related changes are together in one PR and you can see how all the new code is used. |
| Horizontally-sliced projects can’t be easily stopped. The only options are to keep going until the end, or to abandon all the unusable work and potentially leave a bunch of technical debt in the codebase. | Vertically-sliced projects can be stopped at any time. If the results are achieved faster than expected or priorities change, all the work to date is “finished” and providing value. |

## How To Do It

The short version is to just look for a little bit of value you could deliver to
the user, and make that change in a single, well-polished, fully-complete PR.

The long version is that you can identify whether a change or PR is a thin
vertical slice if it passes three tests:

1. **The value test:** Does this change, by itself, deliver some kind of value?
   The answer must be yes. Refactoring is exempt from this test because,
   by definition, users should not see any observable differences after
   refactoring.

2. **The completeness test:**  If this was the final change that was ever deployed
   for the project, and nobody was allowed to work on the project ever again,
   would deploying this change leave the software in a broken or incomplete
   state? The answer must be no. If the change requires other future
   changes in order to work properly, that means it’s not fully integrated and
   is therefore some kind of horizontal slice.

3. **The thin test:** Are there any smaller vertical slices that could be extracted
   from this change? The answer *should usually* be no, because smaller steps
   are generally better than larger steps.

## Examples Of Horizontal Slices

Horizontal slices are, for example, PRs that:

- Add a bunch of UI that doesn’t do anything yet, with the intention to make it
  actually work later (frontend without the backend)
- Add a bunch of classes/models that can’t be accessed by users yet, with the
  intention to add UI for it later (backend without the frontend)
- Don’t have tests, because those will be written latter
- Add database columns that will be used in future PRs

## Further Resources

- [The Teeth](https://kellysutton.com/2018/07/20/the-teeth.html)
- [Shape Up - Get One Piece Done](https://basecamp.com/shapeup/3.2-chapter-11)
