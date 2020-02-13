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
 * The audio listener defines the global properties of the audio environment, it
 * defines where and how sounds and musics are heard.
 *
 * If $(VIEW_LINK) is the eyes of the user, then `Listener` is his ears (by the
 * way, they are often linked together – same
 * position, orientation, etc.).
 *
 * `Listener` is a simple interface, which allows to setup the listener in
 * the 3D audio environment (position and direction), and to adjust the global
 * volume.
 *
 * Because the listener is unique in the scene, `Listener` only contains
 * static functions and doesn't have to be instanciated.
 *
 * Example:
 * ---
 * // Move the listener to the position (1, 0, -5)
 * Listener.position = Vector3f(1, 0, -5);
 *
 * // Make it face the right axis (1, 0, 0)
 * Listener.direction = Vector3f(1, 0, 0);
 *
 * // Reduce the global volume
 * Listener.globalVolume = 50;
 * ---
 */
module dsfml.audio.listener;

import dsfml.system.vector3;

/**
 * The audio listener is the point in the scene from where all the sounds are heard.
 */
final abstract class Listener
{
    @property
    {
        /**
         * The orientation of the listener in the scene.
         *
         * The direction (also called "at vector") is the vector pointing forward
         * from the listener's perspective.
         * Together with the up vector, it defines the 3D orientation of the
         * listener in the scene.
         * The direction vector doesn't have to be normalized.
         * The default listener's orientation is (0, 0, -1).
         *
         * Params:
         *      _direction = New listener's direction
         *
         * See_Also:
         *      upVector, position
         */
        @nogc @safe static void direction(Vector3f _direction)
        {
            sfListener_setDirection(_direction);
        }

        /**
         * Get the current forward vector of the listener in the scene.
         *
         * Returns:
         *      Listener's forward vector (not normalized)
         */
        @nogc @safe static Vector3f direction()
        {
            return sfListener_getDirection();
        }
    }

    @property
    {
        /**
         * Set the upward vector of the listener in the scene.
         *
         * The up vector is the vector that points upward from the listener's
         * perspective. Together with the direction, it defines the 3D orientation
         *  of the listener in the scene. The up vector doesn't have to be
         * normalized. The default listener's up vector is (0, 1, 0). It is usually
         * not necessary to change it, especially in 2D scenarios.
         *
         * Params:
         *      _upVector = New listener's up vector
         *
         * See_Also:
         *      direction, position
         */
        @nogc @safe static void upVector(Vector3f _upVector)
        {
            sfListener_setUpVector(_upVector);
        }

        /**
         * Get the current upward vector of the listener in the scene.
         *
         * Returns:
         *      Listener's upward vector (not normalized)
         */
        @nogc @safe static Vector3f upVector()
        {
            return sfListener_getUpVector();
        }
    }

    @property
    {
        /**
         * The global volume of all the sounds and musics.
         *
         * The volume is a number between 0 and 100 ; it is combined with the
         * individual volume of each sound / music.
         *
         * The default value for the volume is 100 (maximum).
         *
         * Params:
         *      volume = New global volume, in the range [0, 100]
         */
        @nogc @safe static void globalVolume(float volume)
        {
            sfListener_setGlobalVolume(volume);
        }

        /**
         * Get the current value of the global volume.
         *
         * Returns:
         *      Current global volume, in the range [0, 100]
         */
        @nogc @safe static float globalVolume()
        {
            return sfListener_getGlobalVolume();
        }
    }

    @property
    {
        /**
         * The position of the listener in the scene.
         *
         * The default listener's position is (0, 0, 0).
         *
         * Params:
         *      _position = New listener's position
         *
         * See_Also:
         *      direction
         */
        @nogc @safe static void position(Vector3f _position)
        {
            sfListener_setPosition(_position);
        }

        /**
         * Get the current position of the listener in the scene.
         *
         * Returns:
         *      Listener's position
         */
        @nogc @safe static Vector3f position()
        {
            return sfListener_getPosition();
        }
    }
}

// CSFML's functions.
@nogc @safe private extern (C)
{
    void sfListener_setGlobalVolume(float volume);
    float sfListener_getGlobalVolume();
    void sfListener_setPosition(Vector3f position);
    Vector3f sfListener_getPosition();
    void sfListener_setDirection(Vector3f direction);
    Vector3f sfListener_getDirection();
    void sfListener_setUpVector(Vector3f upVector);
    Vector3f sfListener_getUpVector();
}

unittest
{
    import std.stdio : writeln;

    writeln("Running Listener unittest...");

    const float volume = 50;
    const Vector3f pos = Vector3f(10, 20, 30);
    const Vector3f dir = Vector3f(10, 10, 10);
    const Vector3f upvec = Vector3f(20, 20, 20);

    Listener.globalVolume = volume;
    assert(Listener.globalVolume == volume);

    Listener.direction = dir;
    // waiting for pull https://github.com/dlang/dmd/pull/10200
    //assert(Listener.direction == dir);

    Listener.position = pos;
    // waiting for pull https://github.com/dlang/dmd/pull/10200
    //assert(Listener.position == pos);

    Listener.upVector = upvec;
    // waiting for pull https://github.com/dlang/dmd/pull/10200
    //assert(Listener.upVector == upvec);
}
