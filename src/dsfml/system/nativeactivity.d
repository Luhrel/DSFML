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
module dsfml.system.nativeactivity;

version (Android)
{
    struct ANativeActivity;

    @nogc
    extern(C++, sf)
    {
        /**
         *
         * Return a pointer to the Android native activity.
         *
         * You shouldn't have to use this function, unless you want to implement
         * very specific details, that SFML doesn't support, or to use a
         * workaround for a known issue.
         *
         * Returns:
         *      Pointer to Android native activity structure
         *
         * Platform Limitation:
         * This is only available on Android and to use it, you'll have to
         * specifically import `dsfml.system.nativeactivity` in your code.
         */
        ANativeActivity* getNativeActivity();
    }
}
