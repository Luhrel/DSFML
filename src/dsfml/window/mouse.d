/*
 * DSFML - The Simple and Fast Multimedia Library for D
 *
 * Copyright (c) 2013 - 2020 Jeremy DeHaan (dehaan.jeremiah@gmail.com)
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
 * `Mouse` provides an interface to the state of the mouse. It only contains
 * static functions (a single mouse is assumed), so it's not meant to be
 * instanciated.
 *
 * This class allows users to query the mouse state at any time and directly,
 * without having to deal with a window and its events. Compared to the
 * `MouseMoved`, `MouseButtonPressed` and `MouseButtonReleased` events, `Mouse`
 * can retrieve the state of the cursor and the buttons at any time (you don't
 * need to store and update a boolean on your side in order to know if a button
 * is pressed or released), and you always get the real state of the mouse, even
 * if it is moved, pressed or released when your window is out of focus and no
 * event is triggered.
 *
 * The `setPosition` and `getPosition` functions can be used to change or
 * retrieve the current position of the mouse pointer. There are two versions:
 * one that operates in global coordinates (relative to the desktop) and one
 * that operates in window coordinates (relative to a specific window).
 *
 * Example:
 * ---
 * if (Mouse.isButtonPressed(Mouse.Button.Left))
 * {
 *     // left click...
 * }
 *
 * // get global mouse position
 * auto position = Mouse.getPosition();
 *
 * // set mouse position relative to a window
 * Mouse.setPosition(Vector2i(100, 200), window);
 * ---
 *
 * See_Also:
 *      $(JOYSTICK_LINK), $(KEYBOARD_LINK), $(TOUCH_LINK)
 */
module dsfml.window.mouse;

import dsfml.graphics.renderwindow;
import dsfml.system.vector2;
import dsfml.window.window;

/**
 * Give access to the real-time state of the mouse.
 */
final abstract class Mouse
{
    /// Mouse buttons.
    enum Button
    {
        /// The left mouse button
        Left,
        /// The right mouse button
        Right,
        /// The middle (wheel) mouse button
        Middle,
        /// The first extra mouse button
        XButton1,
        /// The second extra mouse button
        XButton2,

        ///Keep last -- the total number of mouse buttons
        Count

    }

    alias Button this;
    // TODO: Multiple alias this not supported
    //alias Wheel this;

    /// Mouse wheels.
    enum Wheel
    {
        /// Vertically oriented mouse wheel
        Vertical,
        /// Horizontally oriented mouse wheel
        Horizontal
    }

    /**
     * Set the current position of the mouse in desktop coordinates.
     *
     * This function sets the global position of the mouse cursor on the
     * desktop.
     *
     * Params:
     *      position = New position of the mouse
     */
    @nogc @safe static void setPosition(Vector2i position)
    {
        sfMouse_setPosition(position, null);
    }

    /**
     * Set the current position of the mouse in window coordinates.
     *
     * This function sets the current position of the mouse cursor, relative to
     * the given window.
     *
     * Params:
     *      position   = New position of the mouse
     *      relativeTo = Reference window
     */
    @nogc @safe static void setPosition(Vector2i position, Window relativeTo)
    {
        sfMouse_setPosition(position, relativeTo.ptr);
    }

    /**
     * Set the current position of the mouse in window coordinates.
     *
     * This function sets the current position of the mouse cursor, relative to
     * the given window.
     *
     * Params:
     *      position   = New position of the mouse
     *      relativeTo = Reference window
     */
    @nogc @safe static void setPosition(Vector2i position, RenderWindow relativeTo)
    {
        sfMouse_setPositionRenderWindow(position, relativeTo.ptr);
    }

    /**
     * Get the current position of the mouse in desktop coordinates.
     *
     * This function returns the global position of the mouse cursor on the
     * desktop.
     *
     * Returns:
     *      Current position of the mouse.
     */
    @nogc @safe static Vector2i getPosition()
    {
        return sfMouse_getPosition(null);
    }

    /**
     * Get the current position of the mouse in window coordinates.
     *
     * This function returns the current position of the mouse cursor, relative
     * to the given window.
     *
     * Params:
     *      relativeTo = Reference window
     *
     * Returns:
     *      Current position of the mouse.
     */
    @nogc @safe static Vector2i getPosition(Window relativeTo)
    {
        return sfMouse_getPosition(relativeTo.ptr);
    }

    /**
     * Get the current position of the mouse in window coordinates.
     *
     * This function returns the current position of the mouse cursor, relative
     * to the given window.
     *
     * Params:
     *      relativeTo = Reference window
     *
     * Returns:
     *      Current position of the mouse.
     */
    @nogc @safe static Vector2i getPosition(RenderWindow relativeTo)
    {
        return sfMouse_getPositionRenderWindow(relativeTo.ptr);
    }

    /**
     * Check if a mouse button is pressed.
     *
     * Params:
     *      button = Button to check
     *
     * Returns:
     *      true if the button is pressed, false otherwise.
     */
    @nogc @safe static bool isButtonPressed(Button button)
    {
        return sfMouse_isButtonPressed(button);
    }
}

@nogc @safe private extern (C)
{
    bool sfMouse_isButtonPressed(Mouse.Button button);
    Vector2i sfMouse_getPosition(const sfWindow* relativeTo);
    void sfMouse_setPosition(Vector2i position, const sfWindow* relativeTo);
    Vector2i sfMouse_getPositionRenderWindow(const sfRenderWindow* relativeTo);
    void sfMouse_setPositionRenderWindow(Vector2i position, const sfRenderWindow* relativeTo);
}

unittest
{
    version (DSFML_Unittest_with_interaction)
    {
        import std.stdio : writeln;
        import std.conv : to;
        import dsfml.window.keyboard : Keyboard;

        writeln("Running Mouse unittest...");
        writeln("Press any mouse button for real time input. Press ESC to exit.");

        bool running = true;

        //must check for each possible key
        while (running)
        {
            for (int i = -1; i < Mouse.Button.Count; ++i)
            {
                Mouse.Button b = cast(Mouse.Button) i;
                if (Mouse.isButtonPressed(b))
                {
                    writeln("Button " ~ b.to!string ~ " was pressed.");
                }
            }
            if (Keyboard.isKeyPressed(Keyboard.Key.Escape))
            {
                running = false;
            }
        }
    }
}
