{:title "Modern OpenGL 05 – Model Assets & Instances"
 :disqus-id "1104 http://tomdalling.com/?p=1104"
 :main-image {:uri "/images/posts/modern-opengl-05.png"}
 :category :modern-opengl}

In this article, we will be refactoring the code to be more like a 3D
engine/framework. Specifically, we will be replacing some of the globals with
structs that represent "assets" and "instances." At the end, we will have a
single wooden crate asset, and five instances of that asset arranged to spell
out "Hi" in 3D.

<!--more-->
<p></p>
<widget type="modern-opengl-preamble">05_asset_instance</widget>

Assets, In General
------------------

<blockquote class="pull-right">
  For the purpose of this article, we will define an asset as a 3D object that
  can be drawn – often just referred to as a "model."
</blockquote>

The term "asset" is very broad and can mean a variety of things. Other 3D
engines and frameworks might use the term "resources" instead of "assets."
Often, the term "asset" includes things like music, sound effects, particle
emitters, shaders, meshes, game levels, etc. For the purpose of this article,
we will define an asset as a 3D object that can be drawn – often just referred
to as a "model."

In more complicated 3D engines, a model is typically made up of *meshes* and
*materials*. A mesh typically contains the per-vertex data: the vertices,
texture coordinates, etc. A material typically contains the shaders, and some
values for uniform variables of the shader, for example: textures, colors,
shininess, etc. In the code for this article, we will not have separate classes
for meshes and materials. For simplicity, we will just have a single struct
called `ModelAsset` that is a combination of a material and a mesh.

The ModelAsset Struct
---------------------

We will represent assets with this struct:

```cpp
struct ModelAsset {
    tdogl::Program* shaders;
    tdogl::Texture* texture;
    GLuint vbo;
    GLuint vao;
    GLenum drawType;
    GLint drawStart;
    GLint drawCount;
};
```

Each asset contains shaders, a single texture, a VBO, VAO, and all the
parameters to `glDrawArrays`. Basically, it contains everything necessary to
draw a whole 3D object. We have seen all of these variables in previous
articles, but they were either globals or hard-coded constants. Grouping these
elements into a struct allows us to have multiple assets later on, for example:
a wooden crate, a teapot, and a tree.

You will notice that each asset has its own shader. This allows us to use
different shaders for different assets. A single shader can also be shared by
multiple assets, because it is stored as a pointer.

Each asset also has a single texture. Most 3D engines have multitexture
support, but we will just stick to a single texture per model for simplicity.

The VBO contains all the vertices and texture coordinates, the same as in the
previous articles.

The VAO is also the same as in previous articles.

The `drawType`, `drawStart` and `drawCount` variables will hold the parameters
to `glDrawArrays`. In the previous articles these three parameters were just
hard-coded constants, but they have become variables in order to make the code
more reusable.

Instances, In General
---------------------

<blockquote class="pull-right">
  An instance is an asset with an individual position, size, and other
  properties. The main reason why you separate assets from instances is that
  you can have multiple instances of a single asset.
</blockquote>

An instance is an asset with an individual position, size, and other
properties. The main reason why you separate assets from instances is that you
can have multiple instances of a single asset. The fewer assets, the less video
memory you need.

For example, you can make a forest scene by creating 100 instances of a single
tree asset. Each instance would be in a different position, with a slightly
different size, and rotated a little bit. From the viewer's perspective, it
looks like 100 different trees. From the programmer's perspective, it is
actually just one tree that is drawn 100 times.


<a name="instances-vs-entities"></a>

Instances vs Entities
---------------------

You may find that "instances" sound very similar to "entities" that you have
seen in other frameworks and engines. Indeed, they both have a position, a
size, a rotation, and you can draw them. You could design your code so that
instances and entities are the same thing, or maybe the `Entity` class inherits
from the `Instance` class, or vice versa. However, we can come up with a better
design than that.

In some situations it is nice to have entities that are not instances. For
example, maybe your camera is an entity – or maybe you have a "trigger" entity
that is invisible, but something happens when the player collides with it.

In other situations, you want to have instances that are not entities. For
example, maybe there is a static area of your game that the player can not get
to, so you just want to draw a bunch of instances without any of the other
features of entities, such as collision detection, animation, movement, etc.

From the examples above, we can conclude that entities and instances are
separate things, so one should not inherit from the other. A good rule of
thumb, no matter what you're programming, is to [prefer composition to
inheritance][], so let's do that.

A decent design would be for each entity to have an instance pointer. If the
instance pointer is null, then the entity can't be drawn, and is invisible. If
you want instances that are *not* entities, you can do that too, because the
instances do not depend on entities in any way. Basically, the instance class
is *only used for drawing*, and the entity class contains the rest of the
functionality.

If you keep following this avenue of design, you eventually end up with an
[entity system][] architecture. Entity system architectures are quite elegant,
in my opinion, and I might do an article about them in the future.

The ModelInstance Struct
------------------------

We will represent instances with this struct:

```cpp
struct ModelInstance {
    ModelAsset* asset;
    glm::mat4 transform;
};
```

This struct is very simple. It only contains an asset and a transformation
matrix. A single matrix is all that is necessary to control the size, position,
and rotation of the instance. This per-instance matrix is often call the "model
matrix."

In the code for this article, we have one asset and five instances. This means
the one asset will get drawn five times. Every time the asset gets drawn, it
will have a different transformation matrix applied, which will change the
position, size and rotation of the asset.

Integrating ModelAsset and ModelInstance
----------------------------------------

First lets look at how the globals have changed.

```cpp
// new globals this article
ModelAsset gWoodenCrate; 
std::list<ModelInstance> gInstances;

// deleted globals from last article
/*
tdogl::Texture* gTexture = NULL;
tdogl::Program* gProgram = NULL;
GLuint gVAO = 0;
GLuint gVBO = 0;
*/

// unchanged globals
GLFWwindow* gWindow = NULL;
double gScrollY = 0.0;
tdogl::Camera gCamera;
GLfloat gDegreesRotated = 0.0f;
```

The deleted globals are all part of the `ModelAsset` struct now. We only have a
single asset, so we'll keep it in the global `gWoodenCrate` for now. Lastly, we
have a list of instances in the variable `gInstances`.

Now lets look in the start of the `LoadWoodenCrateAsset` function to see how
the asset is loaded:

```cpp
static void LoadWoodenCrateAsset() {
    gWoodenCrate.shaders = LoadShaders("vertex-shader.txt", "fragment-shader.txt");
    gWoodenCrate.drawType = GL_TRIANGLES;
    gWoodenCrate.drawStart = 0;
    gWoodenCrate.drawCount = 6*2*3;
    gWoodenCrate.texture = LoadTexture("wooden-crate.jpg");
    glGenBuffers(1, &gWoodenCrate.vbo);
    glGenVertexArrays(1, &gWoodenCrate.vao);

    //...
```

The code is almost identical to the `LoadCube` function from the previous
article, except instead of setting global variables, it sets the variables
inside of `gWoodenCrate`. Also, the `LoadShaders` and `LoadTexture` functions
now return a value instead of setting a global. The fact that we are removing
the use of globals is an indication that the structure of the code is getting
better.

Now that we have seen how the asset is loaded, let's look at how the instances
are made inside of the `CreateInstances` function:

```cpp
static void CreateInstances() {
    ModelInstance dot;
    dot.asset = &gWoodenCrate;
    dot.transform = glm::mat4();
    gInstances.push_back(dot);

    ModelInstance i;
    i.asset = &gWoodenCrate;
    i.transform = translate(0,-4,0) * scale(1,2,1);
    gInstances.push_back(i);

    ModelInstance hLeft;
    hLeft.asset = &gWoodenCrate;
    hLeft.transform = translate(-8,0,0) * scale(1,6,1);
    gInstances.push_back(hLeft);

    ModelInstance hRight;
    hRight.asset = &gWoodenCrate;
    hRight.transform = translate(-4,0,0) * scale(1,6,1);
    gInstances.push_back(hRight);

    ModelInstance hMid;
    hMid.asset = &gWoodenCrate;
    hMid.transform = translate(-6,0,0) * scale(2,1,0.8);
    gInstances.push_back(hMid);
}
```

For each of the five instances, we set the asset to `&gWoodenCrate`, then
set the transformation matrix to something unique, then append the instance to
the `gInstances` list. 

The functions `translate` and `scale` are just convenience functions that
return matrices. The translation controls the position of the instance, and the
scale controls the size. 

<blockquote class="pull-right">
  The identity matrix is a special matrix that does <em>not</em> do any
  transformation.
</blockquote>

Notice that the first instance does not have a transformation. The matrix for
this instance is the *identity matrix*. The identity matrix is a special matrix
that does *not* do any transformation. We are going to make this first instance
spin like in the previous article, so let's look at the `Update` function to
see how that is done.

```cpp
void Update(float secondsElapsed) {
    //rotate the first instance in `gInstances`
    const GLfloat degreesPerSecond = 180.0f;
    gDegreesRotated += secondsElapsed * degreesPerSecond;
    while(gDegreesRotated > 360.0f) gDegreesRotated -= 360.0f;
    gInstances.front().transform = glm::rotate(glm::mat4(), gDegreesRotated, glm::vec3(0,1,0));

    //...

```

The only difference is the addition of that last statement:

```cpp
gInstances.front().transform = glm::rotate(glm::mat4(), gDegreesRotated, glm::vec3(0,1,0));
```

This takes the first instance in `gInstances`, and sets the transformation
matrix based on the recently updated `gDegreesRotated` global.

Now that we have a list of instances to draw, let's look at the `Render`
function:

```cpp
static void Render() {
    // clear everything
    glClearColor(0, 0, 0, 1); // black
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // render all the instances
    std::list<ModelInstance>::const_iterator it;
    for(it = gInstances.begin(); it != gInstances.end(); ++it){
        RenderInstance(*it);
    }
    
    // swap the display buffers (displays what was just drawn)
    glfwSwapBuffers();
}
```

This function is simpler than in the last article. Now, it just loops over the
`gInstances` list, and calls `RenderInstance` for every instance. Let's look in
`RenderInstance`:

```cpp
static void RenderInstance(const ModelInstance& inst) {
    ModelAsset* asset = inst.asset;
    tdogl::Program* shaders = asset->shaders;

    //bind the shaders
    shaders->use();

    //set the shader uniforms
    shaders->setUniform("camera", gCamera.matrix());
    shaders->setUniform("model", inst.transform);
    shaders->setUniform("tex", 0); //set to 0 because the texture will be bound to GL_TEXTURE0

    //bind the texture
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, asset->texture->object());

    //bind VAO and draw
    glBindVertexArray(asset->vao);
    glDrawArrays(asset->drawType, asset->drawStart, asset->drawCount);

    //unbind everything
    glBindVertexArray(0);
    glBindTexture(GL_TEXTURE_2D, 0);
    shaders->stopUsing();
}
```

The code comments explain the steps of the function fairly well. The code in
this function is almost identical to the code inside `Render` in the previous
article, except it uses a `ModelInstance` object instead of globals.

That's pretty much it. We have restructured the code into assets and instances,
which is much more flexible than using globals. To test out the flexibility,
try adding some more instances. Or, if you're brave, try adding a new asset
with a different texture, or different shaders.

Optimisation
------------

The code in this article is naïve, and unoptimised. It still runs fast enough,
so it's not a problem at this stage. However, there are a few fairly simple
optimisations that would make the rendering faster.

The current implementation binds and unbinds the same shader five times. If the
shader is the same for all five instances, then it only needs to be bound once.
In pseudocode, a more-optimised render loop would look something like this:

```cpp
currentShader = NULL;

foreach(instance in gInstances) {
    if(instance.asset.shader != currentShader){
        if(currentShader) currentShader.stopUsing();
        currentShader = instance.asset.shader;
        currentShader.use();
    }

    RenderInstance(instance);
}

currentShader.stopUsing();
```

This way, if the shader doesn't change, then it doesn't get unbound. Binding
and unbinding shaders is a relatively expensive operation, so eliminating
unnecessary shader bindings will speed up the loop.

To make this work with multiple different shaders, you would need to sort the
`gInstances` list by shader. That way, all the instances with the same shader
will be grouped together, so each shader will only get bound once.

The next most expensive operation is binding the texture for each instance. We
can optimise texture binding in the exact same way as shader binding. Sort the
instances by shader, then by texture. Inside the loop, check if the correct
texture is already bound, and, if so, don't unbind and rebind it.

Scene Graphs
------------

In other engines/frameworks, you may find that instances are stored
*hierarchically* – that is, they are stored in a *tree* structure instead of
the `std::list` that we are using. Instances might be referred to as "nodes."
Each instance would have a parent and multiple children. This is basically the
definition of a [scene graph][].

It's possible to have both a list of instances *and* a scene graph. If you use
the same design rationale explained in the [Instances vs Entities][] section of
this article, the solution would be for each scene graph node to have a pointer
to an instance. Keeping a list of instances separate to the scene graph could
be helpful when it comes to optimisation.

We don't require a scene graph yet, so let's ignore them for now.

OpenGL Instanced Rendering Functionality
----------------------------------------

There is an OpenGL extension called [ARB_draw_instanced][] that provides
functions for doing what was described in this article. It involves putting the
model matrices into a VBO, and calling `glDrawArraysInstanced` instead of
`glDrawArrays`. It can be used to get better performance when rendering many
thousands of instances of the same asset. It would be overkill to use it to
draw five instances of a cube, but if you ever need to draw a fudge-tonne of
instances then you should consider using it.

This functionality became available in OpenGL ES 3, which means it's *not*
available on most mobile devices that exist right now. On the desktop, it is
available in OpenGL 2.1 as an extension, and became part of the core profile in
OpenGL 3.1.


Future Article Sneak Peek
-------------------------

In the next article, we will begin to implement lighting, starting with diffuse
reflection of a single point light.

Additional Resources
--------------------

 -  It may be interesting to look at the structure of various 3D engines, such
    as [Unity][], [Irrlicht][], [Ogre3D][] and [libgdx][].
 -  A [nice article, including a video, about composition vs inheritance in
    game programming][] 
 -  [An explanation of ARB_draw_instanced][] on the OpenGL wiki
 -  [Links to articles about entity systems][] on the entity systems wiki

[ARB_draw_instanced]: http://www.opengl.org/registry/specs/ARB/draw_instanced.txt
[An explanation of ARB_draw_instanced]: http://www.opengl.org/wiki/Vertex_Rendering#Instancing
[Instances vs Entities]: #instances-vs-entities
[Irrlicht]: http://irrlicht.sourceforge.net/docu/index.html
[Links to articles about entity systems]: http://entity-systems.wikidot.com/es-approaches
[Ogre3D]: http://www.ogre3d.org/docs/manual/manual_9.html
[Unity]: http://docs.unity3d.com/Documentation/Components/comp-AssetsGroup.html
[entity system]: http://t-machine.org/index.php/2007/11/11/entity-systems-are-the-future-of-mmog-development-part-2/
[libgdx]: http://libgdx.badlogicgames.com/nightlies/docs/api/com/badlogic/gdx/graphics/g3d/model/Model.html
[nice article, including a video, about composition vs inheritance in game programming]: http://www.learn-cocos2d.com/2010/06/prefer-composition-inheritance/
[prefer composition to inheritance]: http://www.learn-cocos2d.com/2010/06/prefer-composition-inheritance/
[scene graph]: http://en.wikipedia.org/wiki/Scene_graph

