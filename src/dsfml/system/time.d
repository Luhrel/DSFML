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
 * `Time` encapsulates a time value in a flexible way. It allows to define a
 * time value either as a number of seconds, milliseconds or microseconds. It
 * also works the other way round: you can read a time value as either a number
 * of seconds, milliseconds or microseconds.
 *
 * By using such a flexible interface, the API doesn't impose any fixed type or
 * resolution for time values, and let the user choose its own favorite
 * representation.
 *
 * Time values support the usual mathematical operations:
 * you can add or subtract two times, multiply or divide  a time by a number,
 * compare two times, etc.
 *
 * Since they represent a time span and not an absolute time value, times can
 * also be negative.
 *
 * Example:
 * ---
 * Time t1 = seconds(0.1f);
 * Int milli = t1.asMilliseconds(); // 100
 *
 * Time t2 = sf::milliseconds(30);
 * long micro = t2.asMicroseconds(); // 30000
 *
 * Time t3 = sf::microseconds(-800000);
 * float sec = t3.asSeconds(); // -0.8
 * ---
 *
 * ---
 * void update(Time elapsed)
 * {
 *    position += speed * elapsed.asSeconds();
 * }
 *
 * update(milliseconds(100));
 * ---
 *
 * See_Also:
 *      $(CLOCK_LINK)
 */
module dsfml.system.time;

import core.time : Duration, usecs;
import std.traits : isNumeric;

/**
 * Represents a time value.
 */
struct Time
{
    private long m_microseconds;

    //Internal constructor
    @nogc @safe package this(long microseconds)
    {
        m_microseconds = microseconds;
    }

    /**
     * Return the time value as a number of seconds.
     *
     * Returns:
     *      Time in seconds.
     */
    @nogc @safe float asSeconds() const
    {
        return m_microseconds / 1_000_000f;
    }

    /**
     * Return the time value as a number of milliseconds.
     *
     * Returns:
     *      Time in milliseconds.
     */
    @nogc @safe int asMilliseconds() const
    {
        return cast(int)(m_microseconds / 1_000);
    }

    /**
     * Return the time value as a number of microseconds.
     *
     * Returns:
     *      Time in microseconds.
     */
    @nogc @safe long asMicroseconds() const
    {
        return m_microseconds;
    }

    /**
     * Return the time value as a `Duration`.
     *
     * Returns:
     *      Time as `Duration`
     */
    @nogc @safe Duration asDuration() const
    {
        return usecs(m_microseconds);
    }

    /**
     * Predefined "zero" time value.
     */
    static immutable(Time) Zero;

    @nogc @safe bool opEquals(const Time rhs) const
    {
        return m_microseconds == rhs.m_microseconds;
    }

    @nogc @safe int opCmp(const ref Time rhs) const
    {
        if (opEquals(rhs))
        {
            return 0;
        }
        else if (m_microseconds < rhs.m_microseconds)
        {
            return -1;
        }
        else
        {
            return 1;
        }
    }

    /**
     * Overload of unary - operator to negate a time value.
     */
    @nogc @safe Time opUnary(string s)() const if (s == "-")
    {
        return microseconds(-m_microseconds);
    }

    /**
     * Overload of binary + and - operators toadd or subtract two time values.
     */
    @nogc @safe Time opBinary(string op)(Time rhs) const if (op == "+" || op == "-")
    {
        static if (op == "+")
        {
            return microseconds(m_microseconds + rhs.m_microseconds);
        }
        static if (op == "-")
        {
            return microseconds(m_microseconds - rhs.m_microseconds);
        }
    }

    /**
     * Overload of += and -= assignment operators.
     */
    @nogc @safe ref Time opOpAssign(string op)(Time rhs) if (op == "+" || op == "-")
    {
        static if (op == "+")
        {
            m_microseconds += rhs.m_microseconds;
            return this;
        }
        static if (op == "-")
        {
            m_microseconds -= rhs.m_microseconds;
            return this;
        }
    }

    /**
     * Overload of binary * and / operators to scale a time value.
     */
    @nogc @safe Time opBinary(string op, E)(E num) const
            if (isNumeric!(E) && (op == "*" || op == "/"))
    {
        static if (op == "*")
        {
            return microseconds(m_microseconds * num);
        }
        static if (op == "/")
        {
            return microseconds(m_microseconds / num);
        }
    }

    /**
     * Overload of *= and /= assignment operators.
     */
    @nogc @safe ref Time opOpAssign(string op, E)(E num)
            if (isNumeric!(E) && (op == "*" || op == "/"))
    {
        static if (op == "*")
        {
            m_microseconds *= num;
            return this;
        }
        static if (op == "/")
        {
            m_microseconds /= num;
            return this;
        }
    }

}
/**
 * Construct a time value from a number of seconds.
 *
 * Params:
 *      amount = Number of seconds.
 *
 * Returns:
 *      Time value constructed from the amount of microseconds.
 */
@nogc @safe Time seconds(float amount)
{
    return Time(cast(long)(amount * 1_000_000));
}
/**
 * Construct a time value from a number of milliseconds.
 *
 * Params:
 *      amount = Number of milliseconds.
 *
 * Returns:
 *      Time value constructed from the amount of microseconds.
 */
@nogc @safe Time milliseconds(int amount)
{
    return Time(amount * 1000);
}

/**
 * Construct a time value from a number of microseconds.
 *
 * Params:
 *      amount = Number of microseconds.
 *
 * Returns:
 *      Time value constructed from the amount of microseconds.
 */
@nogc @safe Time microseconds(long amount)
{
    return Time(amount);
}

/**
 * Construct a time value from a Duration.
 *
 * Params:
 *      dur = The time duration.
 *
 * Returns:
 *      Time value constructed from the time duration.
 */
@nogc @safe Time duration(Duration dur)
{
    return Time(dur.total!"usecs"());
}

unittest
{
    import std.stdio : writeln;

    writeln("Running Time unittest...");

    auto time = seconds(1);

    assert(time.asSeconds() == 1);

    assert((time * 2).asSeconds() == 2);
    assert((time / 2).asSeconds() == .5f);

    assert((time + seconds(1)).asSeconds() == 2);
    assert((time - seconds(1)).asSeconds() == 0);

    time += seconds(1);
    assert(time.asSeconds() == 2);

    time -= seconds(1);
    assert(time.asSeconds() == 1);

    time /= 2;
    assert(time.asSeconds() == .5f);

    time *= 2;
    assert(time.asSeconds() == 1);
}
