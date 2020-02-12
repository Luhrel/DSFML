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
 * `Clock` is a lightweight class for measuring time.
 *
 * Its provides the most precise time that the underlying OS can achieve
 * (generally microseconds or nanoseconds). It also ensures monotonicity, which
 * means that the returned time can never go backward, even if the system time
 * is changed.
 *
 * Example:
 * ---
 * auto clock = Clock();
 * ...
 * Time duration1 = clock.getElapsedTime();
 * ...
 * Time duration2 = clock.restart();
 * ---
 *
 * The Time value returned by the clock can then be converted to a number
 * of seconds, milliseconds or even microseconds.
 *
 * See_Also:
 *      $(TIME_LINK)
 */
module dsfml.system.clock;

import core.time : MonoTime, Duration;
import dsfml.system.time;

/**
 * Utility class that measures the elapsed time.
 */
class Clock
{
    private MonoTime m_startTime;
    private alias currTime = MonoTime.currTime;

    /// Default constructor.
    @nogc @safe this()
    {
        m_startTime = currTime;
    }

    /**
     * Get the elapsed time.
     *
     * This function returns the time elapsed since the last call to `restart()`
     * (or the construction of the instance if `restart()` has not been called).
     *
     * Returns:
     *      Time elapsed.
     */
    @nogc @safe Time getElapsedTime() const
    {
        return microseconds((currTime - m_startTime).total!"usecs");
    }

    /**
     * Restart the clock.
     *
     * This function puts the time counter back to zero. It also returns the
     * time elapsed since the clock was started.
     *
     * Returns:
     *      Time elapsed.
     */
    @safe Time restart()
    {
        const MonoTime now = currTime;
        auto elapsed = now - m_startTime;
        m_startTime = now;

        return microseconds(elapsed.total!"usecs");
    }

}

unittest
{
    import dsfml.system.sleep : sleep;
    import std.math : round;
    import std.stdio : writefln, writeln;

    writeln("Running Clock unittest...");

    Clock clock = new Clock();

    writeln("\tCounting Time for 3 seconds.(rounded to nearest second)");

    for (int i = 0; clock.getElapsedTime().asSeconds() < 3; i++)
    {
        const real et = clock.getElapsedTime().asSeconds();
        const real rnum = round(et);
        writefln("\t%f\t~> %ss elapsed.", et, rnum);
        assert(rnum == i);
        sleep(seconds(1));
    }
}
