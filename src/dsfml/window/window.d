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
 * `Window` is the main class of the window module. It defines an OS window
 * that is able to receive an OpenGL rendering.
 *
 * A `Window` can create its own new window, or be embedded into an already
 * existing control using the create(handle) function. This can be useful for
 * embedding an OpenGL rendering area into a view which is part of a bigger GUI
 * with existing windows, controls, etc. It can also serve as embedding an
 * OpenGL rendering area into a window created by another (probably richer) GUI
 * library like Qt or wxWidgets.
 *
 * The `Window` class provides a simple interface for manipulating the
 * window: move, resize, show/hide, control mouse cursor, etc. It also provides
 * event handling through its `pollEvent()` and `waitEvent()` functions.
 *
 * Note that OpenGL experts can pass their own parameters (antialiasing level
 * bits for the depth and stencil buffers, etc.) to the OpenGL context attached
 * to the window, with the $(CONTEXTSETTINGS_LINK) structure which is passed as
 * an optional argument when creating the window.
 *
 * On dual-graphics systems consisting of a low-power integrated GPU and a powerful
 * discrete GPU, the driver picks which GPU will run an SFML application. In order
 * to inform the driver that an SFML application can benefit from being run on the
 * more powerful discrete GPU, SFML_DEFINE_DISCRETE_GPU_PREFERENCE can be placed in
 * a source file that is compiled and linked into the final application. The macro
 * should be placed outside of any scopes in the global namespace.
 *
 * Example:
 * ---
 * // Declare and create a new window
 * auto window = new Window(VideoMode(800, 600), "DSFML window");
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
 *        if (event.type == Event.EventType.Closed)
 *            window.close();
 *    }
 *
 *    // Activate the window for OpenGL rendering
 *    window.setActive();
 *
 *    // OpenGL drawing commands go here...
 *
 *    // End the current frame and display its contents on screen
 *    window.display();
 * }
 * ---
 */
module dsfml.window.window;

import dsfml.system.vector2;
import dsfml.window.contextsettings;
import dsfml.window.cursor;
import dsfml.window.event;
import dsfml.window.videomode;
import dsfml.window.windowhandle;

import std.string;

/**
 * Window that serves as a target for OpenGL rendering.
 */
class Window
{
    private sfWindow* m_window;

    /// Choices for window style
    enum Style
    {
        None = 0,
        Titlebar = 1 << 0,
        Resize = 1 << 1,
        Close = 1 << 2,
        Fullscreen = 1 << 3,
        DefaultStyle = Titlebar | Resize | Close
    }

    /**
     * Default constructor.
     *
     * This constructor doesn't actually create the window, use the other
     * constructors or call `create()` to do so.
     */
    @nogc @safe this()
    {
        // Nothing to do
    }

    /**
     * Construct a new window.
     *
     * This constructor creates the window with the size and pixel depth defined
     * in mode. An optional style can be passed to customize the look and
     * behaviour of the window (borders, title bar, resizable, closable, ...).
     * If style contains `Style.Fullscreen`, then mode must be a valid video
     * mode.
     *
     * The fourth parameter is an optional structure specifying advanced OpenGL
     * context settings such as antialiasing, depth-buffer bits, etc.
     *
     * Params:
     *      mode     = Video mode to use (defines the width, height and depth of
     *                 the rendering area of the window)
     *      title    = Title of the window
     *      style    = Window style
     *      settings = Additional settings for the underlying OpenGL context
     */
    this(VideoMode mode, const(dstring) title, Style style = Style.DefaultStyle,
            ContextSettings settings = ContextSettings.init)
    {
        create(mode, title, style, settings);
    }

    /**
     * Construct the window from an existing control.
     *
     * Use this constructor if you want to create an OpenGL rendering area into
     * an already existing control.
     *
     * The second parameter is an optional structure specifying advanced OpenGL
     * context settings such as antialiasing, depth-buffer bits, etc.
     *
     * Params:
     *      handle   = Platform-specific handle of the control
     *      settings = Additional settings for the underlying OpenGL context
     */
    this(WindowHandle handle, ContextSettings settings = ContextSettings.init)
    {
        create(handle, settings);
    }

    /**
     * Destructor.
     *
     * Closes the window and frees all the resources attached to it.
     */
    @nogc @safe ~this()
    {
        sfWindow_destroy(m_window);
    }

    @property
    {
        /**
         * Change the position of the window on screen.
         *
         * This function only works for top-level windows (i.e. it will be ignored
         * for windows created from the handle of a child window/control).
         *
         * Params:
         *      _position = New position, in pixels
         */
        @nogc @safe void position(Vector2i _position)
        {
            if (m_window !is null)
                sfWindow_setPosition(m_window, _position);
        }

        /**
         * Get the position of the window.
         *
         * Returns:
         *      Position of the window, in pixels
         */
        @nogc @safe Vector2i position() const
        {
            if (m_window is null)
                return Vector2i(0, 0);
            return sfWindow_getPosition(m_window);
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
        void size(Vector2u _size)
        {
            if (m_window !is null)
            {
                sfWindow_setSize(m_window, _size);
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
        @nogc @safe Vector2u size() const
        {
            if (m_window is null)
                return Vector2u(0, 0);
            return sfWindow_getSize(m_window);
        }
    }

    /**
     * Activate or deactivate the window as the current target for OpenGL
     * rendering.
     *
     * A window is active only on the current thread, if you want to make it
     * active on another thread you have to deactivate it on the previous thread
     * first if it was active. Only one window can be active on a thread at a
     * time, thus the window previously active (if any) automatically gets
     * deactivated. This is not to be confused with `requestFocus()`.
     *
     * Params:
     *      _active = true to activate, false to deactivate
     *
     * Returns:
     *      true if operation was successful, false otherwise.
     */
    @nogc @safe bool active(bool _active = true)
    {
        if (m_window is null)
            return false;
        return sfWindow_setActive(m_window, _active);
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
    @nogc @safe void requestFocus()
    {
        if (m_window !is null)
            sfWindow_requestFocus(m_window);
    }

    /**
     * Check whether the window has the input focus.
     *
     * At any given time, only one window may have the input focus to receive input
     * events such as keystrokes or most mouse events.
     *
     * Returns:
     *      true if the window has focus, false otherwise
     */
    @nogc @safe bool hasFocus() const
    {
        if (m_window is null)
            return false;
        return sfWindow_hasFocus(m_window);
    }

    /**
     * Limit the framerate to a maximum fixed frequency.
     *
     * If a limit is set, the window will use a small delay after each call to
     * `display()` to ensure that the current frame lasted long enough to match
     * the framerate limit. SFML will try to match the given limit as much as it
     * can, but since it internally uses dsfml.system.sleep, whose precision
     * depends on the underlying OS, the results may be a little unprecise as
     * well (for example, you can get 65 FPS when requesting 60).
     *
     * Params:
     *      limit = Framerate limit, in frames per seconds (use 0 to disable limit).
     */
    @property @nogc @safe void framerateLimit(uint limit)
    {
        if (m_window !is null)
            sfWindow_setFramerateLimit(m_window, limit);
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
     *      pixels = Array of pixels in memory. The pixels are copied, so you
     *               need not keep the source alive after calling this function.
     */
    @nogc void setIcon(uint width, uint height, const(ubyte[]) pixels)
    {
        if (m_window !is null)
            sfWindow_setIcon(m_window, width, height, pixels.ptr);
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
     *      threshold = New threshold, in the range [0, 100].
     */
    @property @nogc @safe void joystickThreshold(float threshold)
    {
        if (m_window !is null)
            sfWindow_setJoystickThreshold(m_window, threshold);
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
     *      enabled = true to enable, false to disable.
     */
    @property @nogc @safe void keyRepeatEnabled(bool enabled)
    {
        if (m_window !is null)
            sfWindow_setKeyRepeatEnabled(m_window, enabled);
    }

    /**
     * Show or hide the mouse cursor.
     *
     * The mouse cursor is visible by default.
     *
     * Params:
     *      visible = true to show the mouse cursor, false to hide it.
     */
    @property @nogc @safe void mouseCursorVisible(bool visible)
    {
        if (m_window !is null)
            sfWindow_setMouseCursorVisible(m_window, visible);
    }

    /**
     * Change the title of the window.
     *
     * Params:
     *      _title = New title
     */
    @property @nogc void title(const dstring _title)
    {
        if (m_window !is null)
            sfWindow_setUnicodeTitle(m_window, representation(_title).ptr);
    }

    /**
     * Show or hide the window.
     *
     * The window is shown by default.
     *
     * Params:
     *      _visible = true to show the window, false to hide it
     */
    @property @nogc @safe void visible(bool _visible)
    {
        if (m_window !is null)
            sfWindow_setVisible(m_window, _visible);
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
    @property @nogc @safe void verticalSyncEnabled(bool enabled)
    {
        if (m_window !is null)
            sfWindow_setVerticalSyncEnabled(m_window, enabled);
    }

    /**
     * Get the settings of the OpenGL context of the window.
     *
     * Note that these settings may be different from what was passed to the
     * constructor or the `create()` function, if one or more settings were not
     * supported. In this case, SFML chose the closest match.
     *
     * Returns:
     *      Structure containing the OpenGL context settings.
     */
    @property @nogc @safe ContextSettings settings() const
    {
        if (m_window is null)
            return ContextSettings.init;
        return sfWindow_getSettings(m_window);
    }

    /**
     * Get the OS-specific handle of the window.
     *
     * The type of the returned handle is `WindowHandle`, which is a typedef
     * to the handle type defined by the OS. You shouldn't need to use this
     * function, unless you have very specific stuff to implement that SFML
     * doesn't support, or implement a temporary workaround until a bug is
     * fixed.
     *
     * Returns:
     *      System handle of the window.
     */
    @property @nogc @safe WindowHandle systemHandle() const
    {
        if (m_window is null)
            return WindowHandle.init;
        return sfWindow_getSystemHandle(m_window);
    }

    /**
     * Close the window and destroy all the attached resources.
     *
     * After calling this function, the Window instance remains valid and you
     * can call `create()` to recreate the window. All other functions such as
     * `pollEvent()` or `display()` will still work (i.e. you don't have to test
     * `isOpen()` every time), and will have no effect on closed windows.
     */
    @nogc @safe void close()
    {
        if (m_window !is null)
            sfWindow_close(m_window);
    }

    /**
     * Create (or recreate) the window.
     *
     * If the window was already created, it closes it first. If style contains
     * `Style.Fullscreen`, then mode must be a valid video mode.
     *
     * The fourth parameter is an optional structure specifying advanced OpenGL
     * context settings such as antialiasing, depth-buffer bits, etc.
     *
     * Params:
     *      mode     = Video mode to use (defines the width, height and depth of
     *                 the rendering area of the window)
     *      title    = Title of the window
     *      style    = Window style, a bitwise OR combination of `Style`
     *                 enumerators
     *      settings = Additional settings for the underlying OpenGL context
     */
    void create(VideoMode mode, const dstring title, Style style = Style.DefaultStyle,
            ContextSettings settings = ContextSettings.init)
    {
        m_window = sfWindow_createUnicode(mode, representation(title).ptr, style, &settings);
        onCreate();
    }

    /**
     * Create (or recreate) the window from an existing control.
     *
     * Use this function if you want to create an OpenGL rendering area into an
     * already existing control. If the window was already created, it closes it first.
     *
     * The second parameter is an optional structure specifying advanced OpenGL
     * context settings such as antialiasing, depth-buffer bits, etc.
     *
     * Params:
     *      handle   = Platform-specific handle of the control
     *      settings = Additional settings for the underlying OpenGL context
     */
    void create(WindowHandle handle, ContextSettings settings = ContextSettings.init)
    {
        m_window = sfWindow_createFromHandle(handle, &settings);
        onCreate();
    }

    /**
     * Display on screen what has been rendered to the window so far.
     *
     * This function is typically called after all OpenGL rendering has been
     * done for the current frame, in order to show it on screen.
     */
    @nogc @safe void display()
    {
        if (m_window !is null)
            sfWindow_display(m_window);
    }

    /**
     * Tell whether or not the window is open.
     *
     * This function returns whether or not the window exists. Note that a
     * hidden window (`visible(false)`) is open (therefore this function would
     * return true).
     *
     * Returns:
     *      true if the window is open, false if it has been closed.
     */
    @nogc @safe bool isOpen() const
    {
        if (m_window is null)
            return false;
        return sfWindow_isOpen(m_window);
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
     *      event = Event to be returned.
     *
     * Returns:
     *      true if an event was returned, or false if the event queue was empty.
     *
     * See_Also:
     *      waitEvent
     */
    @nogc bool pollEvent(ref Event event)
    {
        if (m_window is null)
            return false;
        return sfWindow_pollEvent(m_window, &event);
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
     *      // process event...
     * }
     * ---
     * Params:
     *      event = Event to be returned
     *
     * Returns:
     *      false if any error occured.
     *
     * See_Also:
     *      pollEvent
     */
    @nogc bool waitEvent(ref Event event)
    {
        if (m_window is null)
            return false;
        return sfWindow_waitEvent(m_window, &event);
    }

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
     */
    @property @nogc @safe void mouseCursor(Cursor cursor)
    {
        if (m_window !is null)
            sfWindow_setMouseCursor(m_window, cursor.ptr);
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
    @nogc @safe void mouseCursorGrabbeb(bool grabbed)
    {
        if (m_window !is null)
            sfWindow_setMouseCursorGrabbed(m_window, grabbed);
    }

    /**
     * Function called after the window has been created.
     *
     * This function is called so that derived classes can perform their own
     * specific initialization as soon as the window is created.
     */
    protected void onCreate()
    {
    }

    /**
     * Function called after the window has been resized.
     *
     * This function is called so that derived classes can perform custom
     * actions when the size of the window changes.
     */
    protected void onResize()
    {
    }

    // Returns the C pointer
    @property @nogc @safe package(dsfml) sfWindow* ptr()
    {
        return m_window;
    }
}

package(dsfml) extern (C)
{
    struct sfWindow; // @suppress(dscanner.style.phobos_naming_convention)
}

@nogc @safe private extern (C)
{
    sfWindow* sfWindow_create(VideoMode mode, const char* title, uint style,
            const ContextSettings* settings);
    sfWindow* sfWindow_createUnicode(VideoMode mode, const uint* title,
            uint style, const ContextSettings* settings);
    sfWindow* sfWindow_createFromHandle(WindowHandle handle, const ContextSettings* settings);
    void sfWindow_destroy(sfWindow* window);
    void sfWindow_close(sfWindow* window);
    bool sfWindow_isOpen(const sfWindow* window);
    ContextSettings sfWindow_getSettings(const sfWindow* window);
    bool sfWindow_pollEvent(sfWindow* window, Event* event);
    bool sfWindow_waitEvent(sfWindow* window, Event* event);
    Vector2i sfWindow_getPosition(const sfWindow* window);
    void sfWindow_setPosition(sfWindow* window, Vector2i position);
    Vector2u sfWindow_getSize(const sfWindow* window);
    void sfWindow_setSize(sfWindow* window, Vector2u size);
    void sfWindow_setTitle(sfWindow* window, const char* title);
    void sfWindow_setUnicodeTitle(sfWindow* window, const uint* title);
    void sfWindow_setIcon(sfWindow* window, uint width, uint height, const ubyte* pixels);
    void sfWindow_setVisible(sfWindow* window, bool visible);
    void sfWindow_setVerticalSyncEnabled(sfWindow* window, bool enabled);
    void sfWindow_setMouseCursorVisible(sfWindow* window, bool visible);
    void sfWindow_setMouseCursorGrabbed(sfWindow* window, bool grabbed);
    void sfWindow_setMouseCursor(sfWindow* window, const sfCursor* cursor);
    void sfWindow_setKeyRepeatEnabled(sfWindow* window, bool enabled);
    void sfWindow_setFramerateLimit(sfWindow* window, uint limit);
    void sfWindow_setJoystickThreshold(sfWindow* window, float threshold);
    bool sfWindow_setActive(sfWindow* window, bool active);
    void sfWindow_requestFocus(sfWindow* window);
    bool sfWindow_hasFocus(const sfWindow* window);
    void sfWindow_display(sfWindow* window);
    WindowHandle sfWindow_getSystemHandle(const sfWindow* window);
}

unittest
{
    version (DSFML_Unittest_with_interaction)
    {
        import dsfml.window.keyboard : Keyboard;
        import std.stdio : writeln;

        writeln("Running Window unittest...");

        class MyWindow : Window
        {
            this(VideoMode mode, dstring title)
            {
                super(mode, title);
            }

            override void onCreate()
            {
                writeln("Window created !");
            }

            override void onResize()
            {
                // TODO: doesn't work
                writeln("Window resized !");
            }
        }

        auto window = new MyWindow(VideoMode(300, 300), "DSFML Window unit test");

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
