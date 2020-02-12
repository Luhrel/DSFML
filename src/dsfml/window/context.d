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
 * If you need to make OpenGL calls without having an active window (like in a
 * thread), you can use an instance of this class to get a valid context.
 *
 * Having a valid context is necessary for *every* OpenGL call.
 *
 * Note that a context is only active in its current thread, if you create a new
 * thread it will have no valid context by default.
 *
 * To use a `Context` instance, just construct it and let it live as long as you
 * need a valid context. No explicit activation is needed, all it has to do is
 * to exist. Its destructor will take care of deactivating and freeing all the
 * attached resources.
 *
 * Example:
 * ---
 * void threadFunction()
 * {
 *    Context context = new Context();
 *    // from now on, you have a valid context
 *
 *    // you can make OpenGL calls
 *    glClear(GL_DEPTH_BUFFER_BIT);
 * }
 * // the context is automatically deactivated and destroyed by the
 * // Context destructor when the class is collected by the GC
 * ---
 */
module dsfml.window.context;

import dsfml.window.contextsettings;

alias GlFunctionPointer = void*;

/**
 * Class holding a valid drawing context.
 */
class Context
{
    private sfContext* m_context;

    /**
     * Default constructor.
     *
     * The constructor creates and activates the context.
     */
    @nogc @safe this()
    {
        m_context = sfContext_create();
    }

    /// Destructor.
    @nogc @safe ~this()
    {
        sfContext_destroy(m_context);
    }

    /**
     * Activate or deactivate explicitely the context.
     *
     * Params:
     *      _active = true to activate, false to deactivate
     *
     * Returns:
     *      true on success, false on failure.
     */
    @property @nogc @safe void active(bool _active)
    {
        sfContext_setActive(m_context, _active);
    }

    /**
     * Get the settings of the context.
     *
     * Note that these settings may be different than the ones passed to the
     * constructor; they are indeed adjusted if the original settings are not
     * directly supported by the system.
     *
     * Returns:
     *      Structure containing the settings
     */
    @property @nogc @safe ContextSettings settings()
    {
        return sfContext_getSettings(m_context);
    }

    /**
     *
     * Get the currently active context's ID.
     *
     * The context ID is used to identify contexts when managing unshareable
     * OpenGL resources.
     *
     * Returns:
     *      The active context's ID or 0 if no context is currently active
     */
    @nogc @safe static ulong activeContextId()
    {
        return sfContext_getActiveContextId();
    }

    /**
     * Get the address of an OpenGL function.
     *
     * Params:
     *      name = Name of the function to get the address of
     *
     * Returns:
     *      Address of the OpenGL function, 0 on failure
     */
    // TODO: Not yet implemented in CSFML
    @disable @nogc @safe static GlFunctionPointer getFunction(const string name)
    {
        //return sfContext_getFunction(name.ptr);
        return null;
    }

    /**
     * Check whether a given OpenGL extension is available.
     *
     * Params:
     *      name = Name of the extension to check for
     *
     * Returns:
     *      true if available, false if unavailable
     */
    // TODO: Not yet implemented in CSFML
    @disable @nogc @safe static bool isExtensionAvailable(const string name)
    {
        //return sfContext_isExtensionAvailable(name.ptr);
        return false;
    }
}

@nogc @safe private extern (C)
{
    struct sfContext;

    sfContext* sfContext_create();
    void sfContext_destroy(sfContext* context);
    bool sfContext_setActive(sfContext* context, bool active);
    ContextSettings sfContext_getSettings(const sfContext* context);
    ulong sfContext_getActiveContextId();
}

unittest
{
    import std.stdio : writeln;

    writeln("Running Context unittest...");

    //TODO: find a way to test this
}
