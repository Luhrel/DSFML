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
 * Event holds all the informations about a system event that just happened.
 *
 * Events are retrieved using the sf::Window::pollEvent and Window.waitEvent
 * functions.
 *
 * An Event instance contains the type of the event (mouse moved, key pressed,
 * window closed, ...) as well as the details about this particular event. Please
 * note that the event parameters are defined in a union, which means that only the
 * member matching the type of the event will be properly filled; all other members
 * will have undefined values and must not be read if the type of the event doesn't
 * match. For example, if you received a KeyPressed event, then you must read the
 * event.key member, all other members such as event.mouseMove or event.text will
 * have undefined values.
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

import dsfml.window.keyboard;
import dsfml.window.mouse;
import dsfml.window.sensor;
import dsfml.window.joystick;

/**
 * Defines a system event and its parameters.
 */
struct Event
{
    enum EventType
    {
        Closed,                 ///< The window requested to be closed (no data)
        Resized,                ///< The window was resized (data in event.size)
        LostFocus,              ///< The window lost the focus (no data)
        GainedFocus,            ///< The window gained the focus (no data)
        TextEntered,            ///< A character was entered (data in event.text)
        KeyPressed,             ///< A key was pressed (data in event.key)
        KeyReleased,            ///< A key was released (data in event.key)
        deprecated("MouseWheelMoved is deprecated, please use MouseWheelScrolled instead.")
        MouseWheelMoved,        ///< The mouse wheel was scrolled (data in event.mouseWheel) (deprecated)
        MouseWheelScrolled,     ///< The mouse wheel was scrolled (data in event.mouseWheelScroll)
        MouseButtonPressed,     ///< A mouse button was pressed (data in event.mouseButton)
        MouseButtonReleased,    ///< A mouse button was released (data in event.mouseButton)
        MouseMoved,             ///< The mouse cursor moved (data in event.mouseMove)
        MouseEntered,           ///< The mouse cursor entered the area of the window (no data)
        MouseLeft,              ///< The mouse cursor left the area of the window (no data)
        JoystickButtonPressed,  ///< A joystick button was pressed (data in event.joystickButton)
        JoystickButtonReleased, ///< A joystick button was released (data in event.joystickButton)
        JoystickMoved,          ///< The joystick moved along an axis (data in event.joystickMove)
        JoystickConnected,      ///< A joystick was connected (data in event.joystickConnect)
        JoystickDisconnected,   ///< A joystick was disconnected (data in event.joystickConnect)
        TouchBegan,             ///< A touch event began (data in event.touch)
        TouchMoved,             ///< A touch moved (data in event.touch)
        TouchEnded,             ///< A touch event ended (data in event.touch)
        SensorChanged,          ///< A sensor value changed (data in event.sensor)

        Count,                  ///< Keep last -- the total number of event types
    }

    struct KeyEvent
    {
        EventType type;
        Keyboard.Key code;
        bool alt;
        bool control;
        bool shift;
        bool system;
    }

    struct TextEvent
    {
        EventType type;
        uint unicode;
    }

    struct MouseMoveEvent
    {
        EventType type;
        int x;
        int y;
    }

    struct MouseButtonEvent
    {
        EventType type;
        Mouse.Button button;
        int x;
        int y;
    }

    deprecated("MouseWheelEvent is deprecated, please use MouseWheelScrollEvent instead.")
    struct MouseWheelEvent
    {
        EventType type;
        int delta;
        int x;
        int y;
    }

    struct MouseWheelScrollEvent
    {
        EventType type;
        Mouse.Wheel wheel;
        float delta;
        int x;
        int y;
    }

    struct JoystickMoveEvent
    {
        EventType type;
        uint joystickId;
        Joystick.Axis axis;
        float position;
    }

    struct JoystickButtonEvent
    {
        EventType type;
        uint joystickId;
        uint button;
    }

    struct JoystickConnectEvent
    {
        EventType type;
        uint joystickId;
    }

    struct SizeEvent
    {
        EventType type;
        uint width;
        uint height;
    }

    struct TouchEvent
    {
        EventType type;
        uint finger;
        int x;
        int y;
    }

    struct SensorEvent
    {
        EventType type;
        Sensor.Type sensorType;
        float x;
        float y;
        float z;
    }

    // Allow to do (e.g.) Event.Closed instead of Event.EventType.Closed, etc.
    alias EventType this;

    union
    {
        EventType type;                         ///< Type of the event
        SizeEvent size;                         ///< Size event parameters
        KeyEvent key;                           ///< Key event parameters
        TextEvent text;                         ///< Text event parameters
        MouseMoveEvent mouseMove;               ///< Mouse move event parameters
        MouseButtonEvent mouseButton;           ///< Mouse button event parameters
        MouseWheelEvent mouseWheel;             ///< Mouse wheel event parameters (deprecated)
        MouseWheelScrollEvent mouseWheelScroll; ///< Mouse wheel event parameters
        JoystickMoveEvent joystickMove;         ///< Joystick move event parameters
        JoystickButtonEvent joystickButton;     ///< Joystick button event parameters
        JoystickConnectEvent joystickConnect;   ///< Joystick (dis)connect event parameters
        TouchEvent touch;                       ///< Touch events parameters
        SensorEvent sensor;                     ///< Sensor event parameters
    }
}
