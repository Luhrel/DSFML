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
 * `Color` is a simple color structure composed of 4 components:
 * - Red
 * - Green
 * - Blue
 * - Alpha (opacity)
 *
 * Each component is a public member, an unsigned integer in the range [0, 255].
 * Thus, colors can be constructed and manipulated very easily:
 *
 * ---
 * auto color = Color(255, 0, 0); // red
 * color.r = 0;                   // make it black
 * color.b = 128;                 // make it dark blue
 * ---
 *
 * The fourth component of colors, named "alpha", represents the opacity
 * of the color. A color with an alpha value of 255 will be fully opaque, while
 * an alpha value of 0 will make a color fully transparent, whatever the value
 * of the other components is.
 *
 * The most common colors are already defined as static variables:
 * ---
 * auto black       = Color.Black;
 * auto white       = Color.White;
 * auto red         = Color.Red;
 * auto green       = Color.Green;
 * auto blue        = Color.Blue;
 * auto yellow      = Color.Yellow;
 * auto magenta     = Color.Magenta;
 * auto cyan        = Color.Cyan;
 * auto transparent = Color.Transparent;
 * ---
 *
 * Colors can also be added and modulated (multiplied) using the
 * overloaded operators `+` and `*`.
 */
module dsfml.graphics.color;

import std.algorithm.comparison : min, max;
import std.traits;

/**
 * Color is a utility struct for manipulating 32-bits RGBA colors.
 */
struct Color
{
    /// Red component
    ubyte r = 0;
    /// Green component
    ubyte g = 0;
    /// Blue component
    ubyte b = 0;
    /// Alpha component
    ubyte a = 255;

    /**
     * Construct the color from its 4 RGBA components.
     *
     * Params:
     *      red   = Red component (in the range [0, 255])
     *      green = Green component (in the range [0, 255])
     *      blue  = Blue component (in the range [0, 255])
     *      alpha = Alpha (opacity) component (in the range [0, 255])
     */
    @nogc @safe this(ubyte red, ubyte green, ubyte blue, ubyte alpha = 255)
    {
        r = red;
        g = green;
        b = blue;
        a = alpha;
    }

    /**
     * Construct the color from 32-bit unsigned integer.
     *
     * Params:
     *      color = Number containing the RGBA components (in that order)
     */
    @nogc @safe this(uint color)
    {
        r = (color & 0xff000000) >> 24;
        g = (color & 0x00ff0000) >> 16;
        b = (color & 0x0000ff00) >> 8;
        a = (color & 0x000000ff) >> 0;
    }

    /// Black predefined color.
    static immutable Black = Color(0, 0, 0, 255);
    /// White predefined color.
    static immutable White = Color(255, 255, 255, 255);
    /// Red predefined color.
    static immutable Red = Color(255, 0, 0, 255);
    /// Green predefined color.
    static immutable Green = Color(0, 255, 0, 255);
    /// Blue predefined color.
    static immutable Blue = Color(0, 0, 255, 255);
    /// Yellow predefined color.
    static immutable Yellow = Color(255, 255, 0, 255);
    /// Magenta predefined color.
    static immutable Magenta = Color(255, 0, 255, 255);
    /// Cyan predefined color.
    static immutable Cyan = Color(0, 255, 255, 255);
    /// Transparent predefined color.
    static immutable Transparent = Color(0, 0, 0, 0);

    /**
     * Retrieve the color as a 32-bit unsigned integer.
     *
     * Returns:
     *      Color represented as a 32-bit unsigned integer
     */
    @nogc @safe uint toInteger() const
    {
        return (r << 24) | (g << 16) | (b << 8) | a;
    }

    /// Get the string representation of the Color.
    @safe string toString() const
    {
        import std.conv : text;

        return "R: " ~ text(r) ~ " G: " ~ text(g) ~ " B: " ~ text(b) ~ " A: " ~ text(a);
    }

    /**
     * Overload of the `+`, `-`, `*` and `/` operators.
     *
     * This operator returns the component-wise sum, subtraction, or
     * multiplication (also called "modulation") of two colors.
     *
     * For addition and subtraction, components that exceed 255 are clamped to
     * 255 and those below 0 are clamped to 0. For multiplication, are divided
     * by 255 so that the result is still in the range [0, 255].
     *
     * Params:
     *      otherColor = The Color to be added to/subtracted from/multiplied
     *                   by/divided by this one
     *
     * Returns:
     *      The addition, subtraction, or multiplication between this Color and
     *      the other.
     */
    @safe Color opBinary(string op)(Color otherColor) const
            if (op == "+" || op == "-" || op == "*" || op == "/")
    {
        mixin("ubyte red = assure(r" ~ op ~ "otherColor.r);");
        mixin("ubyte green = assure(g" ~ op ~ "otherColor.g);");
        mixin("ubyte blue = assure(b" ~ op ~ "otherColor.b);");
        mixin("ubyte alpha = assure(a" ~ op ~ "otherColor.a);");
        return Color(red, green, blue, alpha);
    }

    /**
     * Overload of the `+` , `-`, `*` and `/` operators.
     *
     * This operator returns the component-wise multiplicaton or division of a
     * color and a scalar.
     * Components that exceed 255 are clamped to 255 and those below 0 are
     * clamped to 0.
     *
     * Params:
     *      num = the scalar to add/substract/multiply/divide to the Color.
     *
     * Returns:
     *      The multiplication or division of this Color by the scalar.
     */
    @safe Color opBinary(string op, E)(E num) const
            if (isNumeric!(E) && (op == "+" || op == "-" || op == "*" || op == "/"))
    {
        mixin("ubyte red = assure(r" ~ op ~ "num);");
        mixin("ubyte green = assure(g" ~ op ~ "num);");
        mixin("ubyte blue = assure(b" ~ op ~ "num);");
        mixin("ubyte alpha = assure(a" ~ op ~ "num);");
        return Color(red, green, blue, alpha);
    }

    /**
     * Overload of the `+=`, `-=`, `*=` and `/=` operators.
     *
     * This operation computes the component-wise sum, subtraction, or
     * multiplication (also called"modulation") of two colors and assigns it to
     * the left operand.
     * Components that exceed 255 are clamped to 255 and those below 0 are
     * clamped to 0. For multiplication, are divided
     * by 255 so that the result is still in the range [0, 255].
     *
     * Params:
     *      otherColor = The Color to be added to/subtracted from/multiplied
     *                   by/divided by this one
     *
     * Returns:
     *      A reference to this color after performing the addition, subtraction,
     *      or multiplication.
     */
    @nogc @safe ref Color opOpAssign(string op)(Color otherColor)
            if (op == "+" || op == "-" || op == "*" || op == "/")
    {
        mixin("r = assure(r" ~ op ~ "otherColor.r);");
        mixin("g = assure(g" ~ op ~ "otherColor.g);");
        mixin("b = assure(b" ~ op ~ "otherColor.b);");
        mixin("a = assure(a" ~ op ~ "otherColor.a);");
        return this;
    }

    /**
     * Overload of the `+=`, `-=`, `*=` and `/=` operators.
     *
     * This operation computers the component-wise multiplicaton or division of
     * a color and a scalar, then assignes it to the color.
     * Components that exceed 255 are clamped to 255 and those below 0 are
     * clamped to 0.
     *
     * Params:
     *      num = the scalar to add/substract/multiply/divide to the Color.
     *
     * Returns:
     *      A reference to this color after performing the multiplication or
     *      division.
     */
    @nogc @safe ref Color opOpAssign(string op, E)(E num)
            if (isNumeric!(E) && (op == "+" || op == "-" || op == "*" || op == "/"))
    {
        mixin("r = assure(r" ~ op ~ "num);");
        mixin("g = assure(g" ~ op ~ "num);");
        mixin("b = assure(b" ~ op ~ "num);");
        mixin("a = assure(a" ~ op ~ "num);");
        return this;
    }

    /**
     * Overload of the `==` and `!=` operators.
     *
     * This operator compares two colors and check if they are equal.
     *
     * Params:
     *      otherColor = the Color to be compared with
     *
     * Returns:
     *      true if colors are equal, false if they are different.
     */
    @nogc @safe bool opEquals(Color otherColor) const
    {
        return r == otherColor.r && g == otherColor.g && b == otherColor.b && a == otherColor.a;
    }

    /**
     * This function assures that the number parameter is between 0 and 255.
     * If not, it set it to 0 or 255 (to the closer one).
     * ---
     * int i = -55;
     * i = assure(i);
     * // i now egal 0
     * ---
     *
     * Params:
     *      i = Number to assure
     *
     * Returns:
     *      The number as a ubyte [0 .. 255]
     */
    @nogc @safe private ubyte assure(int i) const
    {
        return cast(ubyte) min(max(i, 0), 255);
    }

    @nogc @safe private ubyte assure(double d) const
    {
        return assure(cast(int) d);
    }
}

private extern (C)
{
    struct sfColor; // @suppress(dscanner.style.phobos_naming_convention)
}

unittest
{
    import std.stdio : writeln;

    writeln("Running Color unittest...");

    //will perform arithmatic on Color to make sure everything works right.

    Color color = Color(100, 101, 102, 255);

    // operator "+"

    color += 100;
    assert(color == Color(200, 201, 202, 255));

    color = color + 5;
    assert(color == Color(205, 206, 207, 255));

    color = color + Color(10, 10, 10, 10);
    assert(color == Color(215, 216, 217, 255));

    color += Color(50, 149, 248, 30);
    assert(color == Color(255, 255, 255, 255));

    // The addition of RGB equals white
    assert(Color.Red + Color.Green + Color.Blue == Color.White);

    // operator "-"

    color -= 75;
    assert(color == Color(180, 180, 180, 180));

    color = color - 250;
    assert(color == Color(0, 0, 0, 0));

    color = Color(255, 255, 255, 255) - Color(255, 0, 95, 135);
    assert(color == Color(0, 255, 160, 120));

    color -= Color(0, 95, 255, 5);
    assert(color == Color(0, 160, 0, 115));

    // White minus RGB equals Transparent
    assert(Color.White - Color.Red - Color.Green - Color.Blue == Color.Transparent);

    // operator "*"

    color *= 2;
    assert(color == Color(0, 255, 0, 230));

    color = color * .5;
    assert(color == Color(0, 127, 0, 115));

    color *= Color(130, 50, 67, 250);
    assert(color == Color(0, 255, 0, 255));

    color = Color(20, 40, 60, 120) * Color(2, 3, 5, 2);
    assert(color == Color(40, 120, 255, 240));

    // operator "/"

    color /= 2;
    assert(color == Color(20, 60, 127, 120));

    color = color / 1.5;
    assert(color == Color(13, 40, 84, 80));

    color /= -2;
    assert(color == Color(0, 0, 0, 0));

    color = Color(120, 120, 180, 160) / Color(2, 2, 2, 2);
    assert(color == Color(60, 60, 90, 80));

    color /= Color(1, 4, 2, 3);
    assert(color == Color(60, 15, 45, 26));

    // 256^3*r + 256^2*g + 256^1*b + 256^0*a
    int i = 16_777_216 * 60 + 65_536 * 15 + 256 * 45 + 26;
    assert(color.toInteger == i);
    i -= 16_777_216 + 65_536 + 256 + 26;
    assert(Color(i) == Color(59, 14, 44, 0));
}
