/*
 * DSFML - The Simple and Fast Multimedia Library for D
 *
 * Copyright (c) 2013 - 2018 Jeremy DeHaan (dehaan.jeremiah@gmail.com)
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * In no event will the authors be held liable for any damages arising from the
 * use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not claim
 * that you wrote the original software. If you use this software in a product,
 * an acknowledgment in the product documentation would be appreciated but is
 * not required.
 *
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 *
 * 3. This notice may not be removed or altered from any source distribution
 *
 *
 * DSFML is based on SFML (Copyright Laurent Gomila)
 */

/**
 * `RenderWindow` is the main class of the Graphics package. It defines an OS
 * window that can be painted using the other classes of the graphics module.
 *
 * `RenderWindow` is derived from $(WINDOW_LINK), thus it inherits all its
 * features : events, window management, OpenGL rendering, etc. See the
 * documentation of $(WINDOW_LINK) for a more complete description of all these
 * features, as well as code examples.
 *
 * On top of that, `RenderWindow` adds more features related to 2D drawing
 * with the graphics module (see its base class $(RENDERTARGET_LINK) for more
 * details).
 *
 * Here is a typical rendering and event loop with a `RenderWindow`:
 * ---
 * // Declare and create a new render-window
 * auto window = new RenderWindow(VideoMode(800, 600), "DSFML window");
 *
 * // Limit the framerate to 60 frames per second (this step is optional)
 * window.setFramerateLimit(60);
 *
 * // The main loop - ends as soon as the window is closed
 * while (window.isOpen())
 * {
 *    // Event processing
 *    Event event;
 *    while (window.pollEvent(event))
 *    {
 *        // Request for closing the window
 *        if (event.type == Event..Closed)
 *            window.close();
 *    }
 *
 *    // Clear the whole window before rendering a new frame
 *    window.clear();
 *
 *    // Draw some graphical entities
 *    window.draw(sprite);
 *    window.draw(circle);
 *    window.draw(text);
 *
 *    // End the current frame and display its contents on screen
 *    window.display();
 * }
 * ---
 *
 * Like $(WINDOW_LINK), `RenderWindow` is still able to render direct
 * OpenGL stuff. It is even possible to mix together OpenGL calls and regular
 * DSFML drawing commands.
 * ---
 * // Create the render window
 * auto window = new RenderWindow(VideoMode(800, 600), "DSFML OpenGL");
 *
 * // Create a sprite and a text to display
 * auto sprite = new Sprite();
 * auto text = new Text();
 * ...
 *
 * // Perform OpenGL initializations
 * glMatrixMode(GL_PROJECTION);
 * ...
 *
 * // Start the rendering loop
 * while (window.isOpen())
 * {
 *     // Process events
 *     ...
 *
 *     // Draw a background sprite
 *     window.pushGLStates();
 *     window.draw(sprite);
 *     window.popGLStates();
 *
 *     // Draw a 3D object using OpenGL
 *     glBegin(GL_QUADS);
 *         glVertex3f(...);
 *         ...
 *     glEnd();
 *
 *     // Draw text on top of the 3D object
 *     window.pushGLStates();
 *     window.draw(text);
 *     window.popGLStates();
 *
 *     // Finally, display the rendered frame on screen
 *     window.display();
 * }
 * ---
 *
 * See_Also:
 *      $(WINDOW_LINK), $(RENDERTARGET_LINK), $(RENDERTEXTURE_LINK), $(VIEW_LINK)
 */
module dsfml.graphics.renderwindow;

import dsfml.graphics.circleshape;
import dsfml.graphics.color;
import dsfml.graphics.convexshape;
import dsfml.graphics.drawable;
import dsfml.graphics.image;
import dsfml.graphics.rect;
import dsfml.graphics.primitivetype;
import dsfml.graphics.rectangleshape;
import dsfml.graphics.renderstates;
import dsfml.graphics.rendertarget;
import dsfml.graphics.shader;
import dsfml.graphics.shape;
import dsfml.graphics.sprite;
import dsfml.graphics.text;
import dsfml.graphics.texture;
import dsfml.graphics.vertex;
import dsfml.graphics.vertexarray;
import dsfml.graphics.vertexbuffer;
import dsfml.graphics.view;

import dsfml.window.contextsettings;
import dsfml.window.cursor;
import dsfml.window.event;
import dsfml.window.videomode;
import dsfml.window.window;
import dsfml.window.windowhandle;

import dsfml.system.err;
import dsfml.system.vector2;

import std.string;

/**
 * Window that can serve as a target for 2D drawing.
 */
class RenderWindow : Window, RenderTarget
{
    private sfRenderWindow* m_renderWindow;

    /**
     * Default constructor.
     *
     * This constructor doesn't actually create the window, use the other
     * constructors or call `create()` to do so.
     */
    this()
    {
        // Nothing to do.
    }

    /**
     * Construct a new window.
     *
     * This constructor creates the window with the size and pixel depth defined
     * in mode. An optional style can be passed to customize the look and
     * behavior of the window (borders, title bar, resizable, closable, ...).
     *
     * The fourth parameter is an optional structure specifying advanced OpenGL
     * context settings such as antialiasing, depth-buffer bits, etc. You
     * shouldn't care about these parameters for a regular usage of the graphics
     * module.
     *
     * Params:
     *      mode     = Video mode to use (defines the width, height and depth of the
     *                 rendering area of the window)
     *      title    = Title of the window
     *      style    = Window style, a bitwise OR combination of Style enumerators
     *      settings = Additional settings for the underlying OpenGL context
     */
    // TODO: Should settings be a ref ?
    this(VideoMode mode, const(dstring) title, Style style = Style.DefaultStyle,
        ContextSettings settings = ContextSettings.init)
    {
        this();
        create(mode, title, style, settings);
    }

    /**
     * Construct the window from an existing control.
     *
     * Use this constructor if you want to create an DSFML rendering area into
     * an already existing control.
     *
     * The second parameter is an optional structure specifying advanced OpenGL
     * context settings such as antialiasing, depth-buffer bits, etc. You
     * shouldn't care about these parameters for a regular usage of the graphics
     * module.
     *
     * Params:
     *      handle   = Platform-specific handle of the control
     *      settings = Additional settings for the underlying OpenGL context
     */
    // TODO: Should settings be a ref ?
    this(WindowHandle handle, ContextSettings settings = ContextSettings.init)
    {
        this();
        create(handle, settings);
    }

    /**
     * Destructor.
     *
     * Closes the window and frees all the resources attached to it.
     */
    ~this()
    {
        sfRenderWindow_destroy(m_renderWindow);
    }

    @property
    {
        /**
         * Change the position of the window on screen.
         *
         * This property only works for top-level windows (i.e. it will be
         * ignored for windows created from the handle of a child
         * window/control).
         *
         * Params:
         *      _position = New position, in pixels
         */
        override void position(Vector2i _position)
        {
            if (m_renderWindow !is null)
                sfRenderWindow_setPosition(m_renderWindow, _position);
        }

        /**
         * Get the position of the window.
         *
         * Returns:
         *      Position of the window, in pixels
         */
        override Vector2i position() const
        {
            if (m_renderWindow is null)
                return Vector2i(0, 0);
            return sfRenderWindow_getPosition(m_renderWindow);
        }
    }

    @property
    {
        /**
         * Change the size of the rendering region of the window.
         *
         * Params:
         *      _size = New size, in pixels
         */
        override void size(Vector2u _size)
        {
            if (m_renderWindow !is null)
            {
                sfRenderWindow_setSize(m_renderWindow, _size);
                onResize();
            }
        }

        /**
         * Get the size of the rendering region of the window.
         *
         * The size doesn't include the titlebar and borders of the window.
         *
         * Returns:
         *      Size in pixels
         */
        override Vector2u size() const
        {
            if (m_renderWindow is null)
                return Vector2u(0, 0);
            return sfRenderWindow_getSize(m_renderWindow);
        }
    }

    @property
    {
        /**
         * Change the current active view.
         *
         * The view is like a 2D camera, it controls which part of the 2D scene
         * is visible, and how it is viewed in the render-target. The new view
         * will affect everything that is drawn, until another view is set.
         *
         * The render target keeps its own copy of the view object, so it is not
         * necessary to keep the original one alive after calling this function.
         * To restore the original view of the target, you can pass the result
         * of `defaultView()` to this function.
         *
         * Params:
         *      _view = New view to use
         *
         * See_Also:
         *      defaultView
         */
        void view(View _view)
        {
            if (m_renderWindow !is null)
                sfRenderWindow_setView(m_renderWindow, _view.ptr);
        }

        /**
         * Get the view currently in use in the render target.
         *
         * Returns:
         *      The view object that is currently used
         *
         * See_Also:
         *      defaultView
         */
        View view() const
        {
            if (m_renderWindow is null)
                return null;
            return new View(sfRenderWindow_getView(m_renderWindow));
        }
    }

    /**
     * Get the default view of the render target.
     *
     * The default view has the initial size of the render target, and never
     * changes after the target has been created.
     *
     * Returns:
     *      The default view of the render target.
     *
     * See_Also:
     *      view
     */
    @property
    View defaultView() const
    {
        if (m_renderWindow is null)
            return null;
        return new View(sfRenderWindow_getDefaultView(m_renderWindow));
    }

    /**
     * Get the settings of the OpenGL context of the window.
     *
     * Note that these settings may be different from what was passed to the
     * constructor or the `create()` function, if one or more settings were not
     * supported. In this case, DSFML chose the closest match.
     *
     * Returns:
     *      Structure containing the OpenGL context settings
     */
    @property
    override ContextSettings settings() const
    {
        if (m_renderWindow is null)
            return ContextSettings.init;
        return sfRenderWindow_getSettings(m_renderWindow);
    }

    /**
     * Get the OS-specific handle of the window.
     *
     * The type of the returned handle is `WindowHandle`, which is a typedef to
     * the handle type defined by the OS. You shouldn't need to use this
     * function, unless you have very specific stuff to implement that SFML
     * doesn't support, or implement a temporary workaround until a bug is
     * fixed.
     *
     * Returns:
     *      System handle of the window
     */
    @property
    override WindowHandle systemHandle() const
    {
        if (m_renderWindow is null)
            return WindowHandle.init;
        return sfRenderWindow_getSystemHandle(m_renderWindow);
    }

    /**
     * Get the viewport of a view, applied to this render target.
     *
     * The viewport is defined in the view as a ratio, this function simply applies
     * this ratio to the current dimensions of the render target to calculate the
     * pixels rectangle that the viewport actually covers in the target.
     *
     * Params:
     *      view = The view for which we want to compute the viewport
     */
    @property
    IntRect viewport(View view) const
    {
        if (m_renderWindow is null)
            return IntRect(0, 0, 0, 0);
        return sfRenderWindow_getViewport(m_renderWindow, view.ptr);
    }

    /**
     * Activate or deactivate the window as the current target for OpenGL rendering.
     *
     * A window is active only on the current thread, if you want to make it
     * active on another thread you have to deactivate it on the previous thread
     * first if it was active. Only one window can be active on a thread at a
     * time, thus the window previously active (if any) automatically gets
     * deactivated.
     *
     * Params:
     *      _active = true to activate, false to deactivate
     *
     * Returns:
     *      true if operation was successful, false otherwise
     */
    @property
    override bool active(bool _active = true)
    {
        if (m_renderWindow is null)
            return false;
        return sfRenderWindow_setActive(m_renderWindow, _active);
    }

    /**
     * Limit the framerate to a maximum fixed frequency.
     *
     * If a limit is set, the window will use a small delay after each call to
     * `display()` to ensure that the current frame lasted long enough to match
     * the framerate limit.
     *
     * DSFML will try to match the given limit as much as it can, but since it
     * internally uses sleep, whose precision depends on the underlying OS, the
     * results may be a little unprecise as well (for example, you can get 65
     * FPS when requesting 60).
     *
     * Params:
     *      limit = Framerate limit, in frames per seconds (use 0 to disable limit)
     */
    @property
    override void framerateLimit(uint limit)
    {
        if (m_renderWindow !is null)
            sfRenderWindow_setFramerateLimit(m_renderWindow, limit);
    }

    /**
     * Change the window's icon.
     *
     * pixels must be an array of width x height pixels in 32-bits RGBA format.
     *
     * The OS default icon is used by default.
     *
     * Params:
     *      width  = Icon's width, in pixels
     *      height = Icon's height, in pixels
     *      pixels = Icon pixel array to load from
     *
     * See_Also:
     *      title
     */
    override void setIcon(uint width, uint height, const(ubyte[]) pixels)
    {
        if (m_renderWindow !is null)
            sfRenderWindow_setIcon(m_renderWindow, width, height, pixels.ptr);
    }

    /**
     * Change the joystick threshold.
     *
     * The joystick threshold is the value below which no JoystickMoved event
     * will be generated.
     *
     * The threshold value is 0.1 by default.
     *
     * Params:
     *      threshold = New threshold, in the range [0, 100]
     */
    @property
    override void joystickThreshold(float threshold)
    {
        if (m_renderWindow !is null)
            sfRenderWindow_setJoystickThreshold(m_renderWindow, threshold);
    }

    /**
     * Enable or disable automatic key-repeat.
     *
     * If key repeat is enabled, you will receive repeated `KeyPressed` events
     * while keeping a key pressed. If it is disabled, you will only get a
     * single event when the key is pressed.
     *
     * Key repeat is enabled by default.
     *
     * Params:
     *      enabled = true to enable, false to disable
     */
    @property
    override void keyRepeatEnabled(bool enabled)
    {
        if (m_renderWindow !is null)
            sfRenderWindow_setKeyRepeatEnabled(m_renderWindow, enabled);
    }

    /**
     * Show or hide the mouse cursor.
     *
     * The mouse cursor is visible by default.
     *
     * Params:
     *      visible = true show the mouse cursor, false to hide it
     */
    @property
    override void mouseCursorVisible(bool visible)
    {
        if (m_renderWindow !is null)
            sfRenderWindow_setMouseCursorVisible(m_renderWindow, visible);
    }

    //TODO: Cannot use templates here as template member functions cannot be virtual.
    /**
     * Change the title of the window
     *
     * Params:
     *      _title = New title
     */
    @property
    override void title(const dstring _title)
    {
        if (m_renderWindow !is null)
            sfRenderWindow_setUnicodeTitle(m_renderWindow, representation(_title).ptr);
    }

    /**
     * Enable or disable vertical synchronization.
     *
     * Activating vertical synchronization will limit the number of frames
     * displayed to the refresh rate of the monitor. This can avoid some visual
     * artifacts, and limit the framerate to a good value (but not constant
     * across different computers).
     *
     * Vertical synchronization is disabled by default.
     *
     * Params:
     *      enabled = true to enable v-sync, false to deactivate it
     */
    @property
    override void verticalSyncEnabled(bool enabled)
    {
        if (m_renderWindow !is null)
            sfRenderWindow_setVerticalSyncEnabled(m_renderWindow, enabled);
    }

    /**
     * Show or hide the window.
     *
     * The window is shown by default.
     *
     * Params:
     *      _visible = true to show the window, false to hide it
     */
    @property
    override void visible(bool _visible)
    {
        if (m_renderWindow !is null)
            sfRenderWindow_setVisible(m_renderWindow, _visible);
    }

    /**
     * Clear the entire target with a single color.
     *
     * This function is usually called once every frame, to clear the previous
     * contents of the target.
     *
     * Params:
     *      color = Fill color to use to clear the render target
     */
    void clear(Color color = Color.Black)
    {
        if (m_renderWindow !is null)
            sfRenderWindow_clear(m_renderWindow, color);
    }

    /**
     * Close the window and destroy all the attached resources.
     *
     * After calling this function, the Window instance remains valid and you
     * can call `create()` to recreate the window. All other functions such as
     * `pollEvent()` or `display()` will still work (i.e. you don't have to test
     * `isOpen()` every time), and will have no effect on closed windows.
     */
    override void close()
    {
        if (m_renderWindow !is null)
            sfRenderWindow_close(m_renderWindow);
    }

    /**
     * Create (or recreate) the window.
     *
     * If the window was already created, it closes it first. If style contains
     * `Window.Style.Fullscreen`, then mode must be a valid video mode.
     *
     * The fourth parameter is an optional structure specifying advanced OpenGL
     * context settings such as antialiasing, depth-buffer bits, etc.
     *
     * Params:
     *      mode     = Video mode to use (defines the width, height and depth of the
     *                 rendering area of the window)
     *      title    = Title of the window
     *      style    = Window style, a bitwise OR combination of Style enumerators
     *      settings = Additional settings for the underlying OpenGL context
     */
    override void create(VideoMode mode, const dstring title, Style style = Style.DefaultStyle,
        ContextSettings settings = ContextSettings.init)
    {
        m_renderWindow = sfRenderWindow_createUnicode(mode, representation(title).ptr, style, &settings);
        onCreate();
    }

    /**
     * Create (or recreate) the window from an existing control.
     *
     * Use this function if you want to create an OpenGL rendering area into an
     * already existing control. If the window was already created, it closes it
     * first.
     *
     * The second parameter is an optional structure specifying advanced OpenGL
     * context settings such as antialiasing, depth-buffer bits, etc.
     *
     * Params:
     *      handle   = Platform-specific handle of the control
     *      settings = Additional settings for the underlying OpenGL context
     */
    // TODO: Should settings be a ref ?
    override void create(WindowHandle handle, ContextSettings settings = ContextSettings.init)
    {
        m_renderWindow = sfRenderWindow_createFromHandle(handle, &settings);
        onCreate();
    }

    /**
     * Copy the current contents of the window to an image
     *
     * Deprecated:
     * Use a $(TEXTURE_LINK) and its `Texture.update()` function and
     * copy its contents into an $(IMAGE_LINK) instead.
     *
     * This is a slow operation, whose main purpose is to make screenshots of
     * the application. If you want to update an image with the contents of the
     * window and then use it for drawing, you should rather use a
     * $(TEXTURE_LINK) and its `update()` function. You can also draw
     * things directly to a texture with the $(RENDERTEXTURE_LINK)
     * class.
     *
     * Returns:
     *      An Image containing the captured contents.
     */
    deprecated("Use a Texture, its update function, and copy its contents into an Image instead.")
    Image capture()
    {
        if (m_renderWindow is null)
            return null;
        return new Image(sfRenderWindow_capture(m_renderWindow));
    }

    /**
     * Display on screen what has been rendered to the window so far.
     *
     * This function is typically called after all OpenGL rendering has been
     * done for the current frame, in order to show it on screen.
     */
    override void display()
    {
        if (m_renderWindow !is null)
            sfRenderWindow_display(m_renderWindow);
    }

    /**
     * Draw a drawable object to the render target.
     *
     * Params:
     *      drawable = Object to draw
     *      states   = Render states to use for drawing
     */
    void draw(Drawable drawable, ref RenderStates states)
    {
        if (m_renderWindow is null)
            return;

        sfRenderStates sfStates = convertRenderStates(states);

        if (is(drawable == Sprite))
        {
            sfRenderWindow_drawSprite(m_renderWindow, (cast(Sprite) drawable).ptr, &sfStates);
        }
        else if (is(drawable == Text))
        {
            sfRenderWindow_drawText(m_renderWindow, (cast(Text) drawable).ptr, &sfStates);
        }
        else if (is(drawable == CircleShape))
        {
            sfRenderWindow_drawCircleShape(m_renderWindow, (cast(CircleShape) drawable).ptr, &sfStates);
        }
        else if (is(drawable == ConvexShape))
        {
            sfRenderWindow_drawConvexShape(m_renderWindow, (cast(ConvexShape) drawable).ptr, &sfStates);
        }
        else if (is(drawable == RectangleShape))
        {
            sfRenderWindow_drawRectangleShape(m_renderWindow, (cast(RectangleShape) drawable).ptr, &sfStates);
        }
        else if (is(drawable == Shape))
        {
            sfRenderWindow_drawShape(m_renderWindow, (cast(Shape) drawable).ptr, &sfStates);
        }
        else if (is(drawable == VertexArray))
        {
            sfRenderWindow_drawVertexArray(m_renderWindow, (cast(VertexArray) drawable).ptr, &sfStates);
        }
        else
        {
            drawable.draw(this, states);
        }
    }

    /**
     * Draw primitives defined by an array of vertices.
     *
     * Params:
     *      vertices = Array of vertices to draw
     *      type     = Type of primitives to draw
     *      states   = Render states to use for drawing
     */
    void draw(const(Vertex)[] vertices, PrimitiveType type, ref RenderStates states)
    {
        if (m_renderWindow !is null)
        {
            sfRenderStates sfStates = convertRenderStates(states);
            sfRenderWindow_drawPrimitives(m_renderWindow, vertices.ptr, vertices.length, type, &sfStates);
        }
    }

    /**
     * Draw primitives defined by a vertex buffer.
     *
     * Params:
     *      vertexBuffer = Vertex buffer
     *      states       = Render states to use for drawing
     */
    void draw(VertexBuffer vertexBuffer, ref RenderStates states)
    {
        if (m_renderWindow !is null)
        {
            sfRenderStates sfStates = convertRenderStates(states);
            sfRenderWindow_drawVertexBuffer(m_renderWindow, vertexBuffer.ptr, &sfStates);
        }
    }

    /**
     * Draw primitives defined by a vertex buffer.
     *
     * Params:
     *      vertexBuffer = Vertex buffer
     *      firstVertex  = Index of the first vertex to render
     *      vertexCount  = Number of vertices to render
     *      states       = Render states to use for drawing
     */
    // TODO: Not yet implemented in CSFML
    @disable
    void draw(VertexBuffer vertexBuffer, size_t firstVertex,
              size_t vertexCount, ref RenderStates states)
    {
        if (m_renderWindow !is null)
        {
            sfRenderStates sfStates = convertRenderStates(states);
            sfRenderWindow_drawVertexBuffer(m_renderWindow, vertexBuffer.ptr, &sfStates);
        }
    }

    /**
     * Tell whether or not the window is open.
     *
     * This function returns whether or not the window exists. Note that a
     * hidden window (`visible(false)`) is open (therefore this function would
     * return true).
     *
     * Returns:
     *      true if the window is open, false if it has been closed
     */
    override bool isOpen() const
    {
        if (m_renderWindow is null)
            return false;
        return sfRenderWindow_isOpen(m_renderWindow);
    }

    /**
     * Restore the previously saved OpenGL render states and matrices.
     *
     * See the description of pushGLStates to get a detailed description of
     * these functions.
     *
     * See_Also:
     *      pushGLStates
     */
    void popGLStates()
    {
        if (m_renderWindow !is null)
            sfRenderWindow_popGLStates(m_renderWindow);
    }

    /**
     * Save the current OpenGL render states and matrices.
     *
     * This function can be used when you mix SFML drawing and direct OpenGL
     * rendering. Combined with PopGLStates, it ensures that:
     * - DSFML's internal states are not messed up by your OpenGL code
     * - your OpenGL states are not modified by a call to an SFML function
     *
     * More specifically, it must be used around code that calls Draw functions.
     * Example:
     * ---
     * // OpenGL code here...
     * window.pushGLStates();
     * window.draw(...);
     * window.draw(...);
     * window.popGLStates();
     * // OpenGL code here...
     * ---
     *
     * Note that this function is quite expensive: it saves all the possible
     * OpenGL states and matrices, even the ones you don't care about.Therefore
     * it should be used wisely. It is provided for convenience, but the best
     * results will be achieved if you handle OpenGL states yourself (because
     * you know which states have really changed, and need to be saved and
     * restored). Take a look at the `resetGLStates` function if you do so.
     *
     * See_Also:
     *      popGLStates
     */
    void pushGLStates()
    {
        if (m_renderWindow !is null)
            sfRenderWindow_pushGLStates(m_renderWindow);
    }

    /**
     * Reset the internal OpenGL states so that the target is ready for drawing.
     *
     * This function can be used when you mix SFML drawing and direct OpenGL
     * rendering, if you choose not to use `pushGLStates`/`popGLStates`. It
     * makes sure that all OpenGL states needed by DSFML are set, so that
     * subsequent `draw()` calls will work as expected.
     *
     * Example:
     * ---
     * // OpenGL code here...
     * glPushAttrib(...);
     * window.resetGLStates();
     * window.draw(...);
     * window.draw(...);
     * glPopAttrib(...);
     * // OpenGL code here...
     * ---
     */
    void resetGLStates()
    {
        if (m_renderWindow !is null)
            sfRenderWindow_resetGLStates(m_renderWindow);
    }

    /**
     * Pop the event on top of the event queue, if any, and return it.
     *
     * This function is not blocking: if there's no pending event then it will
     * return false and leave event unmodified. Note that more than one event
     * may be present in the event queue, thus you should always call this
     * function in a loop to make sure that you process every pending event.
     * ---
     * Event event;
     * while (window.pollEvent(event))
     * {
     *     // process event...
     * }
     * ---
     * Params:
     *      event = Event to be returned
     *
     * Returns:
     *      true if an event was returned, or false if the event queue was empty.
     *
     * See_Also:
     *      waitEvent
     */
    override bool pollEvent(ref Event event)
    {
        if (m_renderWindow is null)
            return false;
        return sfRenderWindow_pollEvent(m_renderWindow, &event);
    }

    /**
     * Wait for an event and return it.
     *
     * This function is blocking: if there's no pending event then it will wait
     * until an event is received. After this function returns (and no error
     * occured), the event object is always valid and filled properly. This
     * function is typically used when you have a thread that is dedicated to
     * events handling: you want to make this thread sleep as long as no new
     * event is received.
     * ---
     * Event event;
     * if (window.waitEvent(event))
     * {
     *   // process event...
     * }
     * ---
     *
     * Params:
     *      event = Event to be returned
     *
     * Returns:
     *      false if any error occurred.
     *
     * See_Also:
     *      pollEvent
     */
    override bool waitEvent(ref Event event)
    {
        if (m_renderWindow is null)
            return false;
        return sfRenderWindow_waitEvent(m_renderWindow, &event);
    }

    /**
     * Check whether the window has the input focus.
     *
     * At any given time, only one window may have the input focus to receive input
     * events such as keystrokes or most mouse events.
     *
     * Returns:
     *      true if window has focus, false otherwise
     *
     * See_Also:
     *      requestFocus
     */
    override bool hasFocus() const
    {
        if (m_renderWindow is null)
            return false;
        return sfRenderWindow_hasFocus(m_renderWindow);
    }

    /**
     * Request the current window to be made the active foreground window.
     *
     * At any given time, only one window may have the input focus to receive input
     * events such as keystrokes or mouse events. If a window requests focus, it
     * only hints to the operating system, that it would like to be focused. The
     * operating system is free to deny the request. This is not to be confused with
     * `active()`.
     *
     * See_Also:
     *      hasFocus
     */
    override void requestFocus()
    {
        if (m_renderWindow !is null)
            sfRenderWindow_requestFocus(m_renderWindow);
    }

    /**
     * Convert a point from world coordinates to target coordinates, using the
     * current view.
     *
     * This function is an overload of the `mapCoordsToPixel` function that implicitly
     * uses the current view. It is equivalent to:
     * ---
     * target.mapCoordsToPixel(point, target.view);
     * ---
     *
     * Params:
     *      point = Point to convert
     *
     * Returns:
     *      The converted point, in target coordinates (pixels)
     *
     * See_Also:
     *      mapPixelToCoords
     */
    Vector2i mapCoordsToPixel(Vector2f point) inout
    {
        if (m_renderWindow is null)
            return Vector2i(0, 0);
        return sfRenderWindow_mapCoordsToPixel(m_renderWindow, point, null);
    }

    /**
     * Convert a point from world coordinates to target coordinates.
     *
     * This function finds the pixel of the render target that matches the given 2D
     * point. In other words, it goes through the same process as the graphics card,
     * to compute the final position of a rendered point.
     *
     * Initially, both coordinate systems (world units and target pixels) match
     * perfectly. But if you define a custom view or resize your render target, this
     * assertion is not true anymore, i.e. a point located at (150, 75) in your 2D
     * world may map to the pixel (10, 50) of your render target – if the view is
     * translated by (140, 25).
     *
     * This version uses a custom view for calculations, see the other overload of the
     * function if you want to use the current view of the render target.
     *
     * Params:
     *      point = Point to convert
     *      view  = The view to use for converting the point
     *
     * Returns:
     *      The converted point, in target coordinates (pixels)
     *
     * See_Also:
     *      mapPixelToCoords
     */
    Vector2i mapCoordsToPixel(Vector2f point, View view) inout
    {
        if (m_renderWindow is null)
            return Vector2i(0, 0);
        return sfRenderWindow_mapCoordsToPixel(m_renderWindow, point, view.ptr);
    }

    /**
     * Convert a point from target coordinates to world coordinates, using the
     * current view.
     *
     * This function is an overload of the `mapPixelToCoords` function that
     * implicitly uses the current view. It is equivalent to:
     * ---
     * target.mapPixelToCoords(point, target.view);
     * ---
     *
     * Params:
     *      point = Pixel to convert
     *
     * Returns:
     *      The converted point, in "world" coordinates
     *
     * See_Also:
     *      mapCoordsToPixel
     */
    Vector2f mapPixelToCoords(Vector2i point) inout
    {
        if (m_renderWindow is null)
            return Vector2f(0, 0);
        return sfRenderWindow_mapPixelToCoords(m_renderWindow, point, null);
    }

    /**
     * Convert a point from target coordinates to world coordinates.
     *
     * This function finds the 2D position that matches the given pixel of the
     * render target. In other words, it does the inverse of what the graphics card
     * does, to find the initial position of a rendered pixel.
     *
     * Initially, both coordinate systems (world units and target pixels) match
     * perfectly. But if you define a custom view or resize your render target, this
     * assertion is not true anymore, i.e. a point located at (10, 50) in your
     * render target may map to the point (150, 75) in your 2D world – if the view
     * is translated by (140, 25).
     *
     * For render-windows, this function is typically used to find which point (or
     * object) is located below the mouse cursor.
     *
     * This version uses a custom view for calculations, see the other overload of
     * the function if you want to use the current view of the render target.
     *
     * Params:
     *      point = Pixel to convert
     *      view  = The view to use for converting the point
     *
     * Returns:
     *      The converted point, in "world" units
     *
     * See_Also:
     *      mapCoordsToPixel
     */
    Vector2f mapPixelToCoords(Vector2i point, View view) inout
    {
        if (m_renderWindow is null)
            return Vector2f(0, 0);
        return sfRenderWindow_mapPixelToCoords(m_renderWindow, point, view.ptr);
    }

    /**
     * Function called after the window has been created.
     *
     * This function is called so that derived classes can perform their own
     * specific initialization as soon as the window is created.
     */
    alias onCreate = Window.onCreate;
    //override protected void onCreate() {}

    /**
     * Function called after the window has been resized.
     *
     * This function is called so that derived classes can perform custom actions
     * when the size of the window changes.
     */
    alias onResize = Window.onResize;
    //override protected void onResize() {}

    /**
     * Set the displayed cursor to a native system cursor.
     *
     * Upon window creation, the arrow cursor is used by default.
     *
     * **Warning:**
     * The cursor must not be destroyed while in use by the window.
     * Features related to `Cursor` are not supported on iOS and Android.
     *
     * Params:
     *      cursor = Native system cursor type to display
     *
     * See_Also:
     *      Cursor.loadFromSystem, Cursor.loadFromPixels
     */
    @property
    override void mouseCursor(Cursor cursor)
    {
        if (m_renderWindow !is null)
            sfRenderWindow_setMouseCursor(m_renderWindow, cursor.ptr);
    }

    /**
     * Grab or release the mouse cursor.
     *
     * If set, grabs the mouse cursor inside this window's client area so it may no
     * longer be moved outside its bounds. Note that grabbing is only active while
     * the window has focus.
     *
     * Params:
     *      grabbed = true to enable, false to disable
     */
    @property
    override void mouseCursorGrabbeb(bool grabbed)
    {
        if (m_renderWindow !is null)
            sfRenderWindow_setMouseCursorGrabbed(m_renderWindow, grabbed);
    }

    // Returns the C pointer
    package(dsfml) sfRenderWindow* ptr()
    {
        return m_renderWindow;
    }
}

package(dsfml) extern(C)
{
    struct sfRenderWindow;
}

private extern(C)
{
    sfRenderWindow* sfRenderWindow_create(VideoMode mode, const char* title, uint style, const ContextSettings* settings);
    sfRenderWindow* sfRenderWindow_createUnicode(VideoMode mode, const uint* title, uint style, const ContextSettings* settings);
    sfRenderWindow* sfRenderWindow_createFromHandle(WindowHandle handle, const ContextSettings* settings);
    void sfRenderWindow_destroy(sfRenderWindow* renderWindow);
    void sfRenderWindow_close(sfRenderWindow* renderWindow);
    bool sfRenderWindow_isOpen(const sfRenderWindow* renderWindow);
    ContextSettings sfRenderWindow_getSettings(const sfRenderWindow* renderWindow);
    bool sfRenderWindow_pollEvent(sfRenderWindow* renderWindow, Event* event);
    bool sfRenderWindow_waitEvent(sfRenderWindow* renderWindow, Event* event);
    Vector2i sfRenderWindow_getPosition(const sfRenderWindow* renderWindow);
    void sfRenderWindow_setPosition(sfRenderWindow* renderWindow, Vector2i position);
    Vector2u sfRenderWindow_getSize(const sfRenderWindow* renderWindow);
    void sfRenderWindow_setSize(sfRenderWindow* renderWindow, Vector2u size);
    void sfRenderWindow_setTitle(sfRenderWindow* renderWindow, const char* title);
    void sfRenderWindow_setUnicodeTitle(sfRenderWindow* renderWindow, const uint* title);
    void sfRenderWindow_setIcon(sfRenderWindow* renderWindow, uint width, uint height, const ubyte* pixels);
    void sfRenderWindow_setVisible(sfRenderWindow* renderWindow, bool visible);
    void sfRenderWindow_setVerticalSyncEnabled(sfRenderWindow* renderWindow, bool enabled);
    void sfRenderWindow_setMouseCursorVisible(sfRenderWindow* renderWindow, bool show);
    void sfRenderWindow_setMouseCursorGrabbed(sfRenderWindow* renderWindow, bool grabbed);
    void sfRenderWindow_setMouseCursor(sfRenderWindow* window, const(sfCursor)* cursor);
    void sfRenderWindow_setKeyRepeatEnabled(sfRenderWindow* renderWindow, bool enabled);
    void sfRenderWindow_setFramerateLimit(sfRenderWindow* renderWindow, uint limit);
    void sfRenderWindow_setJoystickThreshold(sfRenderWindow* renderWindow, float threshold);
    bool sfRenderWindow_setActive(sfRenderWindow* renderWindow, bool active);
    void sfRenderWindow_requestFocus(sfRenderWindow* renderWindow);
    bool sfRenderWindow_hasFocus(const sfRenderWindow* renderWindow);
    void sfRenderWindow_display(sfRenderWindow* renderWindow);
    WindowHandle sfRenderWindow_getSystemHandle(const sfRenderWindow* renderWindow);
    void sfRenderWindow_clear(sfRenderWindow* renderWindow, Color color);
    void sfRenderWindow_setView(sfRenderWindow* renderWindow, const sfView* view);
    const(sfView)* sfRenderWindow_getView(const sfRenderWindow* renderWindow);
    const(sfView)* sfRenderWindow_getDefaultView(const sfRenderWindow* renderWindow);
    IntRect sfRenderWindow_getViewport(const sfRenderWindow* renderWindow, const sfView* view);
    Vector2f sfRenderWindow_mapPixelToCoords(const sfRenderWindow* renderWindow, Vector2i point, const sfView* view);
    Vector2i sfRenderWindow_mapCoordsToPixel(const sfRenderWindow* renderWindow, Vector2f point, const sfView* view);

    void sfRenderWindow_drawSprite(sfRenderWindow* renderWindow, const sfSprite* object, const sfRenderStates* states);
    void sfRenderWindow_drawText(sfRenderWindow* renderWindow, const sfText* object, const sfRenderStates* states);
    void sfRenderWindow_drawShape(sfRenderWindow* renderWindow, const sfShape* object, const sfRenderStates* states);
    void sfRenderWindow_drawCircleShape(sfRenderWindow* renderWindow, const sfCircleShape* object,
        const sfRenderStates* states);
    void sfRenderWindow_drawConvexShape(sfRenderWindow* renderWindow, const sfConvexShape* object,
        const sfRenderStates* states);
    void sfRenderWindow_drawRectangleShape(sfRenderWindow* renderWindow, const sfRectangleShape* object,
        const sfRenderStates* states);
    void sfRenderWindow_drawVertexArray(sfRenderWindow* renderWindow, const sfVertexArray* object,
        const sfRenderStates* states);
    void sfRenderWindow_drawVertexBuffer(sfRenderWindow* renderWindow, const sfVertexBuffer* object,
        const sfRenderStates* states);
    void sfRenderWindow_drawPrimitives(sfRenderWindow* renderWindow, const Vertex* vertices,
        size_t vertexCount, PrimitiveType type, const sfRenderStates* states);

    void sfRenderWindow_pushGLStates(sfRenderWindow* renderWindow);
    void sfRenderWindow_popGLStates(sfRenderWindow* renderWindow);
    void sfRenderWindow_resetGLStates(sfRenderWindow* renderWindow);

    // Deprecated :

    sfImage* sfRenderWindow_capture(const sfRenderWindow* renderWindow);
}

unittest
{
    version (DSFML_Unittest_with_interaction)
    {
        import std.stdio;
        import dsfml.window.keyboard;
        writeln("Running RenderWindow unittest...");

        auto window = new RenderWindow(VideoMode(200, 300), "DSFML test");

        while (window.isOpen())
        {
            Event event;
            while (window.pollEvent(event))
            {

                if (event.type == Event.Closed)
                {
                    window.close();
                }
                else if (event.type == Event.KeyPressed)
                {
                    if (event.key.code == Keyboard.Escape)
                    {
                        writeln("\tWindow closed !");
                        window.close();
                    }
                    writeln("\t", event.key.code);
                }
                else
                {
                    writeln("\t", event.type);
                }
            }
        }
    }
}
