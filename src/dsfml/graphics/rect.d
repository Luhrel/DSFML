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
 * A rectangle is defined by its top-left corner and its size. It is a very
 * simple structure defined for convenience, so its member variables (`left`,
 * `top`, `width`, and `height`) are public and can be accessed directly, just
 * like the vector structures ($(VECTOR2_LINK) and $(VECTOR3_LINK)).
 *
 * To keep things simple, $(U Rect) doesn't define functions to emulate the
 * properties that are not directly members (such as right, bottom, center,
 * etc.), it rather only provides intersection functions.
 *
 * Rect uses the usual rules for its boundaries:
 * $(UL
 * $(LI The let and top edges are included in the rectangle's area)
 * $(LI The right (left + width) and bottom (top + height) edges are excluded
 * from the rectangle's area))
 *
 * $(PARA This means that `IntRect(0, 0, 1, 1)` and `IntRect(1, 1, 1, 1)` don't
 * intersect.
 *
 * $(U Rect) is a template and may be used with any numeric type, but for
 * simplicity the instanciations used by SFML are aliased:)
 * $(UL
 * $(LI Rect!(int) is IntRect)
 * $(LI Rect!(float) is FloatRect))
 *
 * $(PARA This is so you don't have to care about the template syntax.)
 *
 * Example:
 * ---
 * // Define a rectangle, located at (0, 0) with a size of 20x5
 * auto r1 = IntRect(0, 0, 20, 5);
 *
 * // Define another rectangle, located at (4, 2) with a size of 18x10
 * auto position = Vector2i(4, 2);
 * auto size = Vector2i(18, 10);
 * auto r2 = IntRect(position, size);
 *
 * // Test intersections with the point (3, 1)
 * bool b1 = r1.contains(3, 1); // true
 * bool b2 = r2.contains(3, 1); // false
 *
 * // Test the intersection between r1 and r2
 * IntRect result;
 * bool b3 = r1.intersects(r2, result); // true
 * // result == IntRect(4, 2, 16, 3)
 * ---
 */
module dsfml.graphics.rect;

import std.traits;

import dsfml.system.vector2;

/**
 * Utility structure for manipulating 2D axis aligned rectangles.
 */
struct Rect(T)
    if(isNumeric!(T))
{
    /// Left coordinate of the rectangle.
    T left = 0;
    /// Top coordinate of the rectangle.
    T top = 0;
    /// Width of the rectangle.
    T width = 0;
    /// Height of the rectangle.
    T height = 0;

    /**
     * Construct the rectangle from its coordinates
     *
     * Be careful, the last two parameters are the width
     * and height, not the right and bottom coordinates!
     *
     * Params:
     *    rectLeft   = Left coordinate of the rectangle
     *  rectTop    = Top coordinate of the rectangle
     *  rectWidth  = Width of the rectangle
     *  rectHeight = Height of the rectangle
     */
    this(T rectLeft, T rectTop, T rectWidth, T rectHeight)
    {
        left = rectLeft;
        top = rectTop;
        width = rectWidth;
        height = rectHeight;
    }

    /**
     * Construct the rectangle from position and size
     *
     * Be careful, the last parameter is the size,
     * not the bottom-right corner!
     *
     * Params:
     *  position = Position of the top-left corner of the rectangle
     *  size     = Size of the rectangle
     */
    this(Vector2!(T) position, Vector2!(T) size)
    {
        left = position.x;
        top = position.y;
        width = size.x;
        height = size.y;
    }

    /**
     * Construct the rectangle from another type of rectangle.
     *
     * This constructor doesn't replace the copy constructor, it's called only
     * when U != T. A call to this constructor will fail to compile if U is not
     * convertible to T.
     *
     * Params:
     *     rectangle = Rectangle to convert
     */
    this(U)(Rect!(U) rectangle)
    {
        left = cast(T) rectangle.left;
        top = cast(T) rectangle.top;
        width = cast(T) rectangle.width;
        height = cast(T) rectangle.height;

    }

    /**
     * Check if a point is inside the rectangle's area.
     *
     * Params:
     *         x    = X coordinate of the point to test
     *         y    = Y coordinate of the point to test
     *
     * Returns: true if the point is inside, false otherwise.
     * See_Also: intersects
     */
    bool contains(E)(E x, E y) const
        if(isNumeric!(E))
    {
        return left <= x &&
               x <= (left + width) &&
               top <= y &&
               y <= (top + height);
    }

    /**
     * Check if a point is inside the rectangle's area.
     *
     * Params:
     *         point    = Point to test
     *
     * Returns: true if the point is inside, false otherwise.
     * See_Also: intersects
     */
    bool contains(E)(Vector2!(E) point) const
        if(isNumeric!(E))
    {
        return contains(point.x, point.y);
    }

    /**
     * Check the intersection between two rectangles.
     *
     * Params:
     *         rectangle    = Rectangle to test
     *
     * Returns: true if rectangles overlap, false otherwise.
     * See_Also: contains
     */
    bool intersects(E)(Rect!(E) rectangle) const
    if(isNumeric!(E))
    {
        Rect!(T) rect;
        return intersects(rectangle, rect);
    }

    /**
     * Check the intersection between two rectangles.
     *
     * This overload returns the overlapped rectangle in the intersection
     * parameter.
     *
     * Params:
     *         rectangle        = Rectangle to test
     *         intersection    = Rectangle to be filled with the intersection
     *
     * Returns: true if rectangles overlap, false otherwise.
     * See_Also: contains
     */
    bool intersects(E,O)(Rect!(E) rectangle, out Rect!(O) intersection) const
        if(isNumeric!(E) && isNumeric!(O))
    {
        O interLeft = intersection.max(left, rectangle.left);
        O interTop = intersection.max(top, rectangle.top);
        O interRight = intersection.min(left + width, rectangle.left + rectangle.width);
        O interBottom = intersection.min(top + height, rectangle.top + rectangle.height);

        if ((interLeft < interRight) && (interTop < interBottom))
        {
            intersection = Rect!(O)(interLeft, interTop, interRight - interLeft, interBottom - interTop);
            return true;
        }
        else
        {
            intersection = Rect!(O)(0, 0, 0, 0);
            return false;
        }
    }

    /// Compare two rectangles for equality.
    bool opEquals(E)(const Rect!(E) otherRect) const
        if(isNumeric!(E))
    {
        return left == otherRect.left &&
               top == otherRect.top &&
               width == otherRect.width &&
               height == otherRect.height;
    }

    /// Output the string representation of the Rect.
    string toString() const
    {
        import std.conv;
        return "Left: " ~ text(left) ~ " Top: " ~ text(top) ~ " Width: " ~ text(width) ~ " Height: " ~ text(height);
    }

    private T max(T a, T b) const
    {
        return a>b?a:b;
    }

    private T min(T a, T b) const
    {
        return a<b?a:b;
    }
}

/// Definition of a Rect using integers.
alias IntRect = Rect!(int);
/// Definition of a Rect using floats.
alias FloatRect = Rect!(float);

unittest
{
    import std.stdio;

    writeln("Running Rect unittest...");

    auto rect1 = IntRect(1, 1, 3, 4);

    // Contains should return true when on a corner.
    assert(rect1.contains(1, 1)); // top left edge
    assert(rect1.contains(1, 5)); // bottom left edge
    assert(rect1.contains(4, 5)); // bottom right edge
    assert(rect1.contains(4, 1)); // top right edge

    // Testing others values on the edge
    assert(rect1.contains(1, 2));
    assert(rect1.contains(3, 5));
    assert(rect1.contains(4, 3));
    assert(rect1.contains(2, 1));

    // Testing values in the rectangle
    assert(rect1.contains(2, 2));
    assert(rect1.contains(3, 3));
    assert(rect1.contains(4, 4));
    assert(rect1.contains(4, 2));

    // Testing values out of the rectangle
    assert(!rect1.contains(0, 0));
    assert(!rect1.contains(2, 6));
    assert(!rect1.contains(5, 4));
    assert(!rect1.contains(6, 5));


    auto rect2 = IntRect(0, 2, 10, 10);
    FloatRect interRect;

    assert(rect2.intersects(rect1, interRect));
    assert(interRect == FloatRect(1, 2, 3, 3));

    assert(!rect2.intersects(IntRect(20, 20, 1, 1), interRect));
    assert(interRect == IntRect(0, 0, 0, 0));

    assert(rect1.intersects(rect2));

    assert(rect1 == FloatRect(1, 1, 3, 4));
    assert(rect1 != FloatRect(1, 2, 3, 4));

    auto rect3 = Rect!(ubyte)(IntRect(-1, 1, 46, 256));
    assert(rect3.left == 255);
    assert(rect3.top == 1);
    assert(rect3.width == 46);
    assert(rect3.height == 0);

}
