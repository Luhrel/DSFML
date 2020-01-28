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
 * `Vector2` is a simple structure that defines a mathematical vector with
 * two coordinates (x and y).  It can be used to represent anything that has two
 * dimensions: a size, a point, a velocity, etc.
 *
 * The template parameter T is the type of the coordinates. It can be any type
 * that supports arithmetic operations (+, -, /, *) and comparisons (==, !=),
 * for example int or float.
 *
 * You generally don't have to care about the templated form (`Vector2!(T)`),
 * the most common specializations have special aliases:
 * - `Vector2!(float)` is `Vector2f`
 * - `Vector2!(int)` is `Vector2i`
 * - `Vector2!(uint)` is `Vector2u`
 *
 * The `Vector2` struct has a small and simple interface, its x and y members
 * can be accessed directly (there are no accessors like `setX()`, `getX()`) and
 * it contains no mathematical function like dot product, cross product, length,
 * etc.
 *
 * Example:
 * ---
 * auto v1 = Vector2f(16.5f, 24.f);
 * v1.x = 18.2f;
 * float y = v1.y;
 *
 * auto v2 = v1 * 5.f;
 * Vector2f v3;
 * v3 = v1 + v2;
 *
 * bool different = (v2 != v3);
 * ---
 *
 * See_Also:
 *      $(VECTOR3_LINK)
 */
module dsfml.system.vector2;

import std.traits;

/**
 * Utility template struct for manipulating 2-dimensional vectors.
 */
struct Vector2(T)
    if(isNumeric!(T) || is(T == bool))
{
    /// X coordinate of the vector.
    T x;

    /// Y coordinate of the vector.
    T y;

    /**
     * Construct the vector from its coordinates.
     *
     * Params:
     *      x = X coordinate
     *      y = Y coordinate
     */
    @nogc @safe
    this(T x,T y)
    {
        this.x = x;
        this.y = y;
    }

    /**
     * Construct the vector from another type of vector.
     *
     * Params:
     *      otherVector = Vector to convert
     */
    @nogc @safe
    this(E)(Vector2!(E) otherVector)
    {
        x = cast(T) otherVector.x;
        y = cast(T) otherVector.y;
    }

    /// Invert the members of the vector.
    @nogc @safe
    Vector2!(T) opUnary(string s)() const
        if (s == "-")
    {
        return Vector2!(T)(-x, -y);
    }

    /// Overload of the `+`, `-`, `*` and `/` operators.
    @nogc @safe
    Vector2!(T) opBinary(string op, E)(Vector2!(E) otherVector) const
        if(isNumeric!(E) && (op == "+" || op == "-" || op == "*" || op == "/"))
    {
        mixin("T axeX = x" ~ op ~ "otherVector.x;");
        mixin("T axeY = y" ~ op ~ "otherVector.y;");
        return Vector2!(T)(axeX, axeY);
    }

    /// Overload of the `+` , `-`, `*` and `/` operators.
    @nogc @safe
    Vector2!(T) opBinary(string op, E)(E num) const
        if(isNumeric!(E) && (op == "+" || op == "-" || op == "*" || op == "/"))
    {
        mixin("T axeX = x" ~ op ~ "num;");
        mixin("T axeY = y" ~ op ~ "num;");
        return Vector2!(T)(axeX, axeY);
    }

    /// Overload of the `+` , `-`, `*` and `/` operators.
    @nogc @safe
    Vector2!(T) opBinaryRight(string op, E)(E num) const
    if(isNumeric!(E) && (op == "+" || op == "-" || op == "*" || op == "/"))
    {
        mixin("T axeX = num" ~ op ~ "x;");
        mixin("T axeY = num" ~ op ~ "y;");
        return Vector2!(T)(axeX, axeY);
    }

    /// Overload of the `+=`, `-=`, `*=` and `/=` operators.
    @nogc @safe
    ref Vector2!(T) opOpAssign(string op, E)(Vector2!(E) otherVector)
        if(isNumeric!(E) && (op == "+" || op == "-" || op == "*" || op == "/"))
    {
        mixin("x " ~ op ~ "= otherVector.x;");
        mixin("y " ~ op ~ "= otherVector.y;");
        return this;
    }

    /// Overload of the `+=`, `-=`, `*=` and `/=` operators.
    @nogc @safe
    ref Vector2!(T) opOpAssign(string op,E)(E num)
        if(isNumeric!(E) && (op == "+" || op == "-" || op == "*" || op == "/"))
    {
        mixin("x " ~ op ~ "= num;");
        mixin("y " ~ op ~ "= num;");
        return this;
    }

    /// Assign the value of another vector whose type can be converted to T.
    @nogc @safe
    ref Vector2!(T) opAssign(E)(Vector2!(E) otherVector)
    {
        x = cast(T) otherVector.x;
        y = cast(T) otherVector.y;
        return this;
    }

    /// Compare two vectors for equality.
    @nogc @safe
    bool opEquals(E)(const Vector2!(E) otherVector) const
        if(isNumeric!(E) || is(E == bool))
    {
        return x == otherVector.x && y == otherVector.y;
    }

    /// Output the string representation of the Vector2.
    @safe
    string toString() const
    {
        import std.conv;
        return "X: " ~ text(x) ~ " Y: " ~ text(y);
    }
}

/// Definition of a Vector2 of integers.
alias Vector2i = Vector2!(int);

/// Definition of a Vector2 of floats.
alias Vector2f = Vector2!(float);

/// Definition of a Vector2 of unsigned integers.
alias Vector2u = Vector2!(uint);

unittest
{
    import std.stdio;
    writeln("Running Vector2 unittest...");

    auto floatVector2 = Vector2f(100, 100);

    assert(floatVector2 + 20 == Vector2f(120, 120));
    assert(floatVector2 - 20 == Vector2f(80, 80));
    assert(floatVector2 * 2 == Vector2f(200, 200));
    assert(floatVector2 / 2 == Vector2f(50, 50));

    assert(floatVector2 + Vector2f(50, 0) == Vector2f(150, 100));
    assert(floatVector2 - Vector2f(50, 0) == Vector2f(50, 100));
    assert(floatVector2 * Vector2f(5, 2) == Vector2f(500, 200));
    assert(floatVector2 / Vector2f(5, 0.1) == Vector2f(20, 1000));

    floatVector2 += Vector2f(50, 0);
    assert(floatVector2 == Vector2f(150, 100));

    floatVector2 -= Vector2f(50, 100);
    assert(floatVector2 == Vector2f(100, 0));

    floatVector2 *= Vector2f(2, 2);
    assert(floatVector2 == Vector2f(200, 0));

    floatVector2 /= Vector2f(50, 100);
    assert(floatVector2 == Vector2f(4, 0));


    floatVector2 += 100;
    assert(floatVector2 == Vector2f(104, 100));

    floatVector2 -= 4;
    assert(floatVector2 == Vector2f(100, 96));

    floatVector2 *= 2;
    assert(floatVector2 == Vector2f(200, 192));

    floatVector2 /= 2;
    assert(floatVector2 == Vector2f(100, 96));

    floatVector2 = Vector2f(3, 3);

    assert(6 + floatVector2 == Vector2f(9, 9));
    assert(1 - floatVector2 == Vector2f(-2, -2));
    assert(2 * floatVector2 == Vector2f(6, 6));
    assert(3 / floatVector2 == Vector2f(1, 1));
}
