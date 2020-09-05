{:title "Model View Controller Explained"
 :disqus-id "3 http://tomdalling.com/?p=3"
 :category :software-design}

Model view controller (MVC) is a very useful and popular design pattern. If
you're writing software, you should know it. Unfortunately it's also one of the
hardest to truly understand. In this article I will provide what I think is the
simplest explanation of MVC, and why you should use it.

<!--more-->

What is Model View Controller (MVC)?
------------------------------------

In a typical application you will find these three fundamental parts:

- Data (Model)
- An interface to view and modify the data (View)
- Operations that can be performed on the data (Controller)

The MVC pattern, in a nutshell, is this:

1.  The **model** represents the data, and does nothing else.
    The model does NOT depend on the controller or the view.

2.  The **view** displays the model data, and sends user
    actions (e.g. button clicks) to the controller. The view can:

    - <p>be independent of both the model and the controller; or</p>

    - <p>actually <strong>be</strong> the controller, and therefore depend on the model.</p>

3.  The **controller** provides model data to the view, and
    interprets user actions such as button clicks. The controller depends on
    the view and the model. In some cases, the controller and the view are the
    same object.

Rule 1 is the golden rule of MVC so I'll repeat it:

> **The model represents the data, and does nothing else. The
> model does NOT depend on the controller or the view.**

Let's take an address book application as an example. The model is a list of
`Person` objects, the view is a GUI window that displays the list of people, and
the controller handles actions such as "Delete person", "Add person", "Email
person", etc. The following example does not use MVC because the model depends
on the view.

```cpp
//Example 1:
void Person::setPicture(Picture pict){
    m_picture = pict; //set the member variable
    m_listView->reloadData(); //update the view
}
```

The following example uses MVC:

```cpp
//Example 2:
void Person::setPicture(Picture pict){
    m_picture = pict; //set the member variable
}

void PersonListController::changePictureAtIndex(Picture newPict, int personIndex){
    m_personList[personIndex].setPicture(newPict); //modify the model
    m_listView->reloadData(); //update the view
}
```

In the above example, the `Person` class knows nothing about the view. The
`PersonListController` handles both changing the model, and updating the view.
The view window tells the controller about user actions (in this case, it tells
the controller that the user changed the picture of a person).

What is the advantage of MVC?
-----------------------------

Unnecessary complexity is the devil of software development. Complexity leads
to software that is buggy, and expensive to maintain. The easiest way to make
code overly complex is to put dependencies everywhere. Conversely, removing
unnecessary dependencies makes delightful code that is less buggy and easier to
maintain because it is **reusable without modification**. You can
happily reuse old, stable code without introducing new bugs into it.

The primary advantage of the MVC design pattern is this:

> **MVC makes model classes reusable without modification.**

The purpose of the controller is to remove the view dependency from the model.
By removing the view dependency from the model, the model code becomes
delightful.

Why is the model code so delightful? Let's continue with the address book
application example. The project manager approaches the developer and says *"We
love the contact list window, but we need a second window that displays all the
contacts by their photos only. The photos should be in a table layout, with
five photos per row."*

If the application uses MVC, this task is pretty straight forward. Currently
there are three classes: `Person`, `PersonListController`, and
`PersonListView`. Two classes need to be created: `PersonPhotoGridView` and 
`PersonPhotoGridController`.  The `Person` class remains the same, and is easily
plugged into the two different views. How delightful.

If the application is structured badly like in Example 1, then things get more
complicated. Currently there are two classes `Person`, and `PersonListView`. The
`Person` class can not be plugged into another view, because it contains code
specific to `PersonListView`. The developer must modify the `Person` class to
accommodate the new `PersonPhotoGridView`, and ends up complicating the model
like so:

```cpp
//Example 3:
void Person::setPicture(Picture pict){
    m_picture = pict; //set the member variable
    if(m_listView){ //check if it's in a list view
        m_listView->reloadData(); //update the list view
    }
    if(m_gridView){ //check if it's in a grid view
        m_gridView->reloadData(); //update the grid view
    }
}
```

As you can see, the model code is starting to turn nasty. If the project
manager then says *"we're porting the app to a platform with a different GUI
toolkit"* the delightfulness is even more prominent. With MVC, the `Person`
class can be displayed by different GUI toolkits without any modification. Just
make a controller and a view with the new toolkit, just as you would with the
old toolkit. Without MVC, it is a nightmare to support multiple GUI toolkits.
The code may end up looking like this:

```cpp
//Example 4:
void Person::setPicture(Picture pict){
    m_picture = pict;
#ifdef ORIGINAL_GUI_TOOLKIT
    if(m_listView){ //check if it's in a list view
        m_listView->reloadData(); //update the list view
    }
    if(m_gridView){ //check if it's in a grid view
        m_gridView->reloadData(); //update the grid view
    }
#endif
#ifdef NEW_GUI_TOOLKIT
    if(m_listView){ //check if it's in a list view
        m_listView->redisplayData(); //update the list view
    }
    if(m_gridView){ //check if it's in a grid view
        m_gridView->redisplayData(); //update the grid view
    }
#endif
}
```

The `setPicture` method is basically spaghetti code at this point.

Why not put the controller code in the view?
--------------------------------------------

One solution to the spaghetti code problem in Example 4 is to move the
controller code from the model to the view like so:

```cpp
//Example 5:
PersonListView::newPictureClicked(Picture clickedPicture){
    m_selectedPerson.setPicture(clickedPicture);
    this->reloadData();
}
```

The above example also makes the model reusable, which is the main advantage of
MVC. When the view will only ever display one type of model object, then
combining the view and the controller is fine. For example, a `SinglePersonView`
will only ever display a `Person` object, so the `SinglePersonView` can double as
the controller.

However, if the controller is separate from the view then MVC has a second
advantage:

> **MVC can also make the *view* reusable without modification.**

Not only does MVC make the model delightful, it can also make the view
delightful. Ideally, a list view should be able to display lists of anything,
not just `Person` objects. The code in Example 5 can *not* be a generic
list view, because it is tied to the model (the `Person` class). In the situation
where the view should be reusable (e.g. a list view, or a table view) and the
model should be reusable, MVC is the only thing that will work. The controller
removes the dependencies from both the model and the view, which allows them to
be reused elsewhere.

Conclusion
----------

The MVC design pattern inserts a controller class between the view and the
model to remove the model-view dependencies. With the dependencies removed, the
model, and possibly the view, can be made reusable without modification.  This
makes implementing new features and maintenance a breeze. The users get stable
software quickly, the company saves money, and the developers don't go insane.
How good is that?

