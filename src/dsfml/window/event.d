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
 * `Event` holds all the informations about a system event that just happened.
 *
 * Events are retrieved using the `Window.pollEvent` and `Window.waitEvent`
 * functions.
 *
 * An `Event` instance contains the type of the event (mouse moved, key pressed,
 * window closed, ...) as well as the details about this particular event.
 * Please note that the event parameters are defined in a union, which means
 * that only the member matching the type of the event will be properly filled;
 * all other members will have undefined values and must not be read if the type
 * of the event doesn't match. For example, if you received a `KeyPressed`
 * event, then you must read the `event.key` member, all other members such as
 * `event.mouseMove` or `event.text` will have undefined values.
 *
 * Usage example:
 * ---
 * Event event;
 * while (window.pollEvent(event))
 * {
 *     // Request for closing the window
 *     if (event.type == Event.Closed)
 *         window.close();
 *     // The escape key was pressed
 *     if ((event.type == Event.KeyPressed) && (event.key.code == Keyboard.Escape))
 *         window.close();
 *     // The window was resized
 *     if (event.type == Event.Resized)
 *         doSomethingWithTheNewSize(event.size.width, event.size.height);
 *     // etc ...
 * }
 * ---
 */
module dsfml.window.event;

import dsfml.window.joystick;
import dsfml.window.keyboard;
import dsfml.window.mouse;
import dsfml.window.sensor;

/**
 * Defines a system event and its parameters.
 */
struct Event
{
    /// Definition of all the event types
    enum EventType
    {
        /// The window requested to be closed (no data)
        Closed,
        /// The window was resized (data in event.size)
        Resized,
        /// The window lost the focus (no data)
        LostFocus,
        /// The window gained the focus (no data)
        GainedFocus,
        /// A character was entered (data in event.text)
        TextEntered,
        /// A key was pressed (data in event.key)
        KeyPressed,
        /// A key was released (data in event.key)
        KeyReleased,
        /// The mouse wheel was scrolled (data in event.mouseWheel) (deprecated)
        deprecated("Use MouseWheelScrolled instead.") MouseWheelMoved,
        /// The mouse wheel was scrolled (data in event.mouseWheelScroll)
        MouseWheelScrolled,
        /// A mouse button was pressed (data in event.mouseButton)
        MouseButtonPressed,
        /// A mouse button was released (data in event.mouseButton)
        MouseButtonReleased,
        /// The mouse cursor moved (data in event.mouseMove)
        MouseMoved,
        /// The mouse cursor entered the area of the window (no data)
        MouseEntered,
        /// The mouse cursor left the area of the window (no data)
        MouseLeft,
        /// A joystick button was pressed (data in event.joystickButton)
        JoystickButtonPressed,
        /// A joystick button was released (data in event.joystickButton)
        JoystickButtonReleased,
        /// The joystick moved along an axis (data in event.joystickMove)
        JoystickMoved,
        /// A joystick was connected (data in event.joystickConnect)
        JoystickConnected,
        /// A joystick was disconnected (data in event.joystickConnect)
        JoystickDisconnected,
        /// A touch event began (data in event.touch)
        TouchBegan,
        /// A touch moved (data in event.touch)
        TouchMoved,
        /// A touch event ended (data in event.touch)
        TouchEnded,
        /// A sensor value changed (data in event.sensor)
        SensorChanged,

        /// Keep last -- the total number of event types
        Count,
    }

    /// Keyboard event parameters
    struct KeyEvent
    {
        /// Type of the event
        EventType type;
        /// Code of the key that has been pressed
        Keyboard.Key code;
        /// Is the Alt key pressed?
        bool alt;
        /// Is the Control key pressed?
        bool control;
        /// Is the Shift key pressed?
        bool shift;
        /// Is the System key pressed?
        bool system;
    }

    /// Text event parameters
    struct TextEvent
    {
        /// Type of the event
        EventType type;
        /// UTF-32 Unicode value of the character
        uint unicode;
    }

    /// Mouse move event parameters
    struct MouseMoveEvent
    {
        /// Type of the event
        EventType type;
        /// X position of the mouse pointer, relative to the left of the owner window
        int x;
        /// Y position of the mouse pointer, relative to the top of the owner window
        int y;
    }

    /// Mouse buttons events parameters
    struct MouseButtonEvent
    {
        /// Type of the event
        EventType type;
        /// Code of the button that has been pressed
        Mouse.Button button;
        /// X position of the mouse pointer, relative to the left of the owner window
        int x;
        /// Y position of the mouse pointer, relative to the top of the owner window
        int y;
    }

    /// Mouse wheel events parameters
    deprecated("Use MouseWheelScrollEvent instead.") struct MouseWheelEvent
    {
        /// Type of the event
        EventType type;
        /// Number of ticks the wheel has moved (positive is up, negative is down)
        int delta;
        /// X position of the mouse pointer, relative to the left of the owner window
        int x;
        /// Y position of the mouse pointer, relative to the top of the owner window
        int y;
    }

    /// Mouse wheel events parameters
    struct MouseWheelScrollEvent
    {
        /// Type of the event
        EventType type;
        /// Which wheel (for mice with multiple ones)
        Mouse.Wheel wheel;
        /// Wheel offset (positive is up/left, negative is down/right). High-precision mice may use non-integral offsets.
        float delta;
        /// X position of the mouse pointer, relative to the left of the owner window
        int x;
        /// Y position of the mouse pointer, relative to the top of the owner window
        int y;
    }

    /// Joystick axis move event parameters
    struct JoystickMoveEvent
    {
        /// Type of the event
        EventType type;
        /// Index of the joystick (in range `[0 .. Joystick.Count - 1]`)
        uint joystickId;
        /// Axis on which the joystick moved
        Joystick.Axis axis;
        /// New position on the axis (in range `[-100 .. 100]`)
        float position;
    }

    /// Joystick buttons events parameters
    struct JoystickButtonEvent
    {
        /// Type of the event
        EventType type;
        /// Index of the joystick (in range `[0 .. Joystick.Count - 1]`)
        uint joystickId;
        /// Index of the button that has been pressed (in range `[0 .. Joystick.ButtonCount - 1]`)
        uint button;
    }

    /// Joystick connection/disconnection event parameters
    struct JoystickConnectEvent
    {
        /// Type of the event
        EventType type;
        /// Index of the joystick (in range `[0 .. Joystick.Count - 1]`)
        uint joystickId;
    }

    /// Size events parameters
    struct SizeEvent
    {
        /// Type of the event
        EventType type;
        /// New width, in pixels
        uint width;
        /// New height, in pixels
        uint height;
    }

    /// Touch events parameters
    struct TouchEvent
    {
        /// Type of the event
        EventType type;
        /// Index of the finger in case of multi-touch events
        uint finger;
        /// X position of the touch, relative to the left of the owner window
        int x;
        /// Y position of the touch, relative to the top of the owner window
        int y;
    }

    /// Sensor event parameters
    struct SensorEvent
    {
        /// Type of the event
        EventType type;
        /// Type of the sensor
        Sensor.Type sensorType;
        /// Current value of the sensor on X axis
        float x;
        /// Current value of the sensor on Y axis
        float y;
        /// Current value of the sensor on Z axis
        float z;
    }

    // Allow to do (e.g.) Event.Closed instead of Event.EventType.Closed, etc.
    alias EventType this;

    /// sfEvent defines a system event and its parameters
    union
    {
        /// Type of the event
        EventType type;
        /// Size event parameters
        SizeEvent size;
        /// Key event parameters
        KeyEvent key;
        /// Text event parameters
        TextEvent text;
        /// Mouse move event parameters
        MouseMoveEvent mouseMove;
        /// Mouse button event parameters
        MouseButtonEvent mouseButton;
        /// Mouse wheel event parameters (deprecated)
        MouseWheelEvent mouseWheel;
        /// Mouse wheel event parameters
        MouseWheelScrollEvent mouseWheelScroll;
        /// Joystick move event parameters
        JoystickMoveEvent joystickMove;
        /// Joystick button event parameters
        JoystickButtonEvent joystickButton;
        /// Joystick (dis)connect event parameters
        JoystickConnectEvent joystickConnect;
        /// Touch events parameters
        TouchEvent touch;
        /// Sensor event parameters
        SensorEvent sensor;
    }
}
