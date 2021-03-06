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

/// A module containing configuration settings.
module dsfml.config;

import dsfml.system.err;

//Check to confirm compiler is at least v2.092
static if (__VERSION__ < 2092L)
{
    static assert(0, "Please upgrade your compiler to v2.092 or later");
}

/// DSFML version enum
enum
{
    /// DSFML's major version number.
    DSFML_VERSION_MAJOR = 2,
    /// DSFML's minor version number.
    DSFML_VERSION_MINOR = 5
}

// Defines the maximum size for a string passed to a packet.
// No one will exceed this limit, right ?
package immutable short PACKET_STR_MAX_SIZE = 1024;
