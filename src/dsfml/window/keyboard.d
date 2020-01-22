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
 * `Keyboard` provides an interface to the state of the keyboard. It only
 * contains static functions (a single keyboard is assumed), so it's not meant
 * to be instanciated.
 *
 * This class allows users to query the keyboard state at any time and directly,
 * without having to deal with a window and its events. Compared to the
 * `KeyPressed` and `KeyReleased` events, `Keyboard` can retrieve the state
 * of a key at any time (you don't need to store and update a boolean on your
 * side in order to know if a key is pressed or released), and you always get
 * the real state of the keyboard, even if keys are pressed or released when
 * your window is out of focus and no event is triggered.
 *
 * Example:
 * ---
 * if (Keyboard.isKeyPressed(Keyboard.Key.Left))
 * {
 *     // move left...
 * }
 * else if (Keyboard.isKeyPressed(Keyboard.Key.Right))
 * {
 *     // move right...
 * }
 * else if (Keyboard.isKeyPressed(Keyboard.Key.Escape))
 * {
 *     // quit...
 * }
 * ---
 *
 * See_Also:
 *      $(JOYSTICK_LINK), $(MOUSE_LINK), $(TOUCH_LINK)
 */
module dsfml.window.keyboard;

/**
 * Give access to the real-time state of the keyboard.
 */
final abstract class Keyboard
{
    // Allow to do (e.g.) Keyboard.A instead of Keyboard.Key.A, etc.
    alias Key this;

    /// Key codes.
    enum Key
    {
        /// Unhandled key
        Unknown = -1,
        /// The A key
        A = 0,
        /// The B key
        B,
        /// The C key
        C,
        /// The D key
        D,
        /// The E key
        E,
        /// The F key
        F,
        /// The G key
        G,
        /// The H key
        H,
        /// The I key
        I,
        /// The J key
        J,
        /// The K key
        K,
        /// The L key
        L,
        /// The M key
        M,
        /// The N key
        N,
        /// The O key
        O,
        /// The P key
        P,
        /// The Q key
        Q,
        /// The R key
        R,
        /// The S key
        S,
        /// The T key
        T,
        /// The U key
        U,
        /// The V key
        V,
        /// The W key
        W,
        /// The X key
        X,
        /// The Y key
        Y,
        /// The Z key
        Z,
        /// The 0 key
        Num0,
        /// The 1 key
        Num1,
        /// The 2 key
        Num2,
        /// The 3 key
        Num3,
        /// The 4 key
        Num4,
        /// The 5 key
        Num5,
        /// The 6 key
        Num6,
        /// The 7 key
        Num7,
        /// The 8 key
        Num8,
        /// The 9 key
        Num9,
        /// The Escape key
        Escape,
        /// The left Control key
        LControl,
        /// The left Shift key
        LShift,
        /// The left Alt key
        LAlt,
        /// The left OS specific key: window (Windows and Linux), apple (MacOS X), ...
        LSystem,
        /// The right Control key
        RControl,
        /// The right Shift key
        RShift,
        /// The right Alt key
        RAlt,
        /// The right OS specific key: window (Windows and Linux), apple (MacOS X), ...
        RSystem,
        /// The Menu key
        Menu,
        /// The [ key
        LBracket,
        /// The ] key
        RBracket,
        /// The ; key
        Semicolon,
        /// The , key
        Comma,
        /// The . key
        Period,
        /// The ' key
        Quote,
        /// The / key
        Slash,
        /// The \ key
        Backslash,
        /// The ~ key
        Tilde,
        /// The = key
        Equal,
        /// The - key
        Hyphen,
        /// The Space key
        Space,
        /// The Enter key
        Enter,
        /// The Backspace key
        Backspace,
        /// The Tabulation key
        Tab,
        /// The Page up key
        PageUp,
        /// The Page down key
        PageDown,
        /// The End key
        End,
        /// The Home key
        Home,
        /// The Insert key
        Insert,
        /// The Delete key
        Delete,
        /// The + key
        Add,
        /// The - key
        Subtract,
        /// The * key
        Multiply,
        /// The / key
        Divide,
        /// Left arrow
        Left,
        /// Right arrow
        Right,
        /// Up arrow
        Up,
        /// Down arrow
        Down,
        /// The numpad 0 key
        Numpad0,
        /// The numpad 1 key
        Numpad1,
        /// The numpad 2 key
        Numpad2,
        /// The numpad 3 key
        Numpad3,
        /// The numpad 4 key
        Numpad4,
        /// The numpad 5 key
        Numpad5,
        /// The numpad 6 key
        Numpad6,
        /// The numpad 7 key
        Numpad7,
        /// The numpad 8 key
        Numpad8,
        /// The numpad 9 key
        Numpad9,
        /// The F1 key
        F1,
        /// The F2 key
        F2,
        /// The F3 key
        F3,
        /// The F4 key
        F4,
        /// The F5 key
        F5,
        /// The F6 key
        F6,
        /// The F7 key
        F7,
        /// The F8 key
        F8,
        /// The F9 key
        F9,
        /// The F10 key
        F10,
        /// The F11 key
        F11,
        /// The F12 key
        F12,
        /// The F13 key
        F13,
        /// The F14 key
        F14,
        /// The F15 key
        F15,
        /// The Pause key
        Pause,

        /// Keep last -- the total number of keyboard keys
        Count,

        deprecated Dash = Hyphen,
        deprecated BackSpace = Backspace,
        deprecated BackSlash = Backslash,
        deprecated SemiColon = Semicolon,
        deprecated Return = Enter
    }

    /**
     * Check if a key is pressed.
     *
     * Params:
     *      key = Key to check
     *
     * Returns:
     *      true if the key is pressed, false otherwise.
     */
    @nogc
    static bool isKeyPressed(Key key)
    {
        return sfKeyboard_isKeyPressed(key);
    }

    /*
     * Show or hide the virtual keyboard.
     *
     * **Warning:**
     * the virtual keyboard is not supported on all systems. It will typically
     * be implemented on mobile OSes (Android, iOS) but not on desktop OSes
     * (Windows, Linux, ...).
     *
     * If the virtual keyboard is not available, this function does nothing.
     *
     * Params:
     *      visible = true to show, false to hide
     */
    @nogc
    static void setVirtualKeyboardVisible(bool visible)
    {
        sfKeyboard_setVirtualKeyboardVisible(visible);
    }
}

@nogc
private extern(C)
{
    bool sfKeyboard_isKeyPressed(int key);
    void sfKeyboard_setVirtualKeyboardVisible(byte visible);
}

//TODO known bugs:
//cannot press two keys at once for this unit test
unittest
{
    version (DSFML_Unittest_with_interaction)
    {
        import std.stdio;
        import std.conv;
        writeln("Running Keyboard unittest...");
        writeln("Press any key for real time input. Press ESC to exit.");

        bool running = true;

        while(running)
        {
            for(int i = -1; i < Keyboard.Key.Count; ++i)
            {
                Keyboard.Key k = cast(Keyboard.Key) i;
                if(Keyboard.isKeyPressed(k))
                {
                    writeln("Key " ~ k.to!string ~ " was pressed.");
                    if (k == Keyboard.Key.Escape)
                    {
                        running = false;
                    }
                }
            }
        }
    }
}
