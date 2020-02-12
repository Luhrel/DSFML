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
 * `Joystick` provides an interface to the state of the joysticks. It only
 * contains static functions, so it's not meant to be instanciated. Instead,
 * each joystick is identified by an index that is passed to the functions of
 * this class.
 *
 * This class allows users to query the state of joysticks at any time and
 * directly, without having to deal with a window and its events. Compared to
 * the `JoystickMoved`, `JoystickButtonPressed`, and `JoystickButtonReleased`
 * events, `Joystick` can retrieve the state of axes and buttons of joysticks
 * at any time (you don't need to store and update a boolean on your side in
 * order to know if a button is pressed or released), and you always get the
 * real state of joysticks, even if they are moved, pressed or released when
 * your window is out of focus and no event is triggered.
 *
 * DSFML supports:
 * - 8 joysticks (Joystick.Count)
 * - 32 buttons per joystick (Joystick.ButtonCount)
 * - 8 axes per joystick (Joystick.AxisCount)
 *
 * Unlike the keyboard or mouse, the state of joysticks is sometimes not
 * directly available (depending on the OS), therefore an `update()` function
 * must be called in order to update the current state of joysticks. When you
 * have a window with event handling, this is done automatically, you don't need
 * to call anything. But if you have no window, or if you want to check
 * joysticks state before creating one, you must call `Joystick.update`
 * explicitly.
 *
 * Example:
 * ---
 * // Is joystick #0 connected?
 * bool connected = Joystick.isConnected(0);
 *
 * // How many buttons does joystick #0 support?
 * uint buttons = Joystick.getButtonCount(0);
 *
 * // Does joystick #0 define a X axis?
 * bool hasX = Joystick.hasAxis(0, Joystick.Axis.X);
 *
 * // Is button #2 pressed on joystick #0?
 * bool pressed = Joystick.isButtonPressed(0, 2);
 *
 * // What's the current position of the Y axis on joystick #0?
 * float position = Joystick.getAxisPosition(0, Joystick.Axis.Y);
 * ---
 *
 * See_Also:
 *      $(KEYBOAD_LINK), $(MOUSE_LINK)
 */
module dsfml.window.joystick;

/**
 * Give access to the real-time state of the joysticks.
 */
final abstract class Joystick
{
    struct Identification
    {
        /// Name of the joystick.
        const string name;
        /// Manufacturer identifier.
        uint vendorId;
        /// Product identifier.
        uint productId;
    }

    //Constants related to joysticks capabilities.
    enum
    {
        /// Maximum number of supported joysticks.
        JoystickCount = 8,
        /// Maximum number of supported buttons.
        JoystickButtonCount = 32,
        /// Maximum number of supported axes.
        JoystickAxisCount = 8
    }

    /// Axes supported by SFML joysticks.
    enum Axis
    {
        /// The X axis.
        X,
        /// The Y axis.
        Y,
        /// The Z axis.
        Z,
        /// The R axis.
        R,
        /// The U axis.
        U,
        /// The V axis.
        V,
        /// The X axis of the point-of-view hat.
        PovX,
        /// The Y axis of the point-of-view hat.
        PovY
    }

    alias Axis this;

    /**
     * Return the number of buttons supported by a joystick.
     *
     * If the joystick is not connected, this function returns 0.
     *
     * Params:
     *      joystick = Index of the joystick
     *
     * Returns:
     *      Number of buttons supported by the joystick.
     */
    @nogc @safe static uint getButtonCount(uint joystick)
    {
        return sfJoystick_getButtonCount(joystick);
    }

    /**
     * Get the current position of a joystick axis.
     *
     * If the joystick is not connected, this function returns 0.
     *
     * Params:
     *      joystick = Index of the joystick
     *      axis     = Axis to check
     *
     * Returns:
     *      Current position of the axis, in range [-100 .. 100].
     */
    @nogc @safe static float getAxisPosition(uint joystick, Axis axis)
    {
        return sfJoystick_getAxisPosition(joystick, axis);
    }

    /**
     * Get the joystick information
     *
     * Params:
     *      joystick = Index of the joystick
     *
     * Returns:
     *      Structure containing the joystick information.
     */
    @nogc @safe static Identification getIdentification(uint joystick)
    {
        if (isConnected(joystick))
            return sfJoystick_getIdentification(joystick);
        return Identification("No Joystick", 0, 0);
    }

    /**
     * Check if a joystick supports a given axis.
     *
     * If the joystick is not connected, this function returns false.
     *
     * Params:
     *      joystick = Index of the joystick
     *      axis     = Axis to check
     *
     * Returns:
     *      true if the joystick supports the axis, false otherwise.
     */
    @nogc @safe static bool hasAxis(uint joystick, Axis axis)
    {
        return sfJoystick_hasAxis(joystick, axis);
    }

    /**
     * Check if a joystick button is pressed.
     *
     * If the joystick is not connected, this function returns false.
     *
     * Params:
     *      joystick = Index of the joystick
     *      button   = Button to check
     *
     * Returns:
     *      true if the button is pressed, false otherwise.
     */
    @nogc @safe static bool isButtonPressed(uint joystick, uint button)
    {
        return sfJoystick_isButtonPressed(joystick, button);
    }

    /**
     * Check if a joystick is connected.
     *
     * Params:
     *      joystick = Index of the joystick
     *
     * Returns:
     *      true if the joystick is connected, false otherwise.
     */
    @nogc @safe static bool isConnected(uint joystick)
    {
        return sfJoystick_isConnected(joystick);
    }

    /**
     * Update the states of all joysticks.
     *
     * This function is used internally by SFML, so you normally don't have to
     * call it explicitely.
     *
     * However, you may need to call it if you have no window yet (or no window
     * at all): in this case the joysticks states are not updated automatically.
     */
    @nogc @safe static void update()
    {
        sfJoystick_update();
    }
}

@nogc @safe private extern (C)
{
    bool sfJoystick_isConnected(uint joystick);
    uint sfJoystick_getButtonCount(uint joystick);
    bool sfJoystick_hasAxis(uint joystick, Joystick.Axis axis);
    bool sfJoystick_isButtonPressed(uint joystick, uint button);
    float sfJoystick_getAxisPosition(uint joystick, Joystick.Axis axis);
    Joystick.Identification sfJoystick_getIdentification(uint joystick);
    void sfJoystick_update();
}
/*
unittest
{
    import std.stdio;

    writeln("joystick.d");
    writeln(Joystick.getIdentification(1).name);
}
*/
