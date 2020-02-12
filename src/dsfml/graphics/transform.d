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
 * A `Transform` specifies how to translate, rotate, scale, shear, project,
 * whatever things. In mathematical terms, it defines how to transform a
 * coordinate system into another.
 *
 * For example, if you apply a rotation transform to a sprite, the result will
 * be a rotated sprite. And anything that is transformed by this rotation
 * transform will be rotated the same way, according to its initial position.
 *
 * Transforms are typically used for drawing. But they can also be used for any
 * computation that requires to transform points between the local and global
 * coordinate systems of an entity (like collision detection).
 *
 * Example:
 * ---
 * // define a translation transform
 * Transform translation;
 * translation.translate(20, 50);
 *
 * // define a rotation transform
 * Transform rotation;
 * rotation.rotate(45);
 *
 * // combine them
 * Transform transform = translation * rotation;
 *
 * // use the result to transform stuff...
 * Vector2f point = transform.transformPoint(Vector2f(10, 20));
 * FloatRect rect = transform.transformRect(FloatRect(0, 0, 10, 100));
 * ---
 *
 * See_Also:
 *      $(TRANSFORMABLE_LINK), $(RENDERSTATES_LINK)
 */
module dsfml.graphics.transform;

import dsfml.system.vector2;
import dsfml.graphics.rect;

/**
 * Define a 3x3 transform matrix.
 */
struct Transform
{
    private sfTransform m_transform;

    // https://github.com/dlang-community/dfmt#disabling-formatting
    // dfmt off
    /**
     * Construct a transform from a 3x3 matrix.
     *
     * Params:
     *      a00 = Element (0, 0) of the matrix
     *      a01 = Element (0, 1) of the matrix
     *      a02 = Element (0, 2) of the matrix
     *      a10 = Element (1, 0) of the matrix
     *      a11 = Element (1, 1) of the matrix
     *      a12 = Element (1, 2) of the matrix
     *      a20 = Element (2, 0) of the matrix
     *      a21 = Element (2, 1) of the matrix
     *      a22 = Element (2, 2) of the matrix
     */
    @nogc @safe this(float a00, float a01, float a02,
                     float a10, float a11, float a12,
                     float a20, float a21, float a22)
    {
        m_transform = sfTransform_fromMatrix(a00, a01, a02,
                                             a10, a11, a12,
                                             a20, a21, a22);
    }

    /// Construct a transform from a float array describing a 3x3 matrix.
    @nogc @safe
    this(float[9] matrix)
    {
        this(matrix[0], matrix[1], matrix[2],
             matrix[3], matrix[4], matrix[5],
             matrix[6], matrix[7], matrix[8]);
    }

    // dfmt on

    @nogc @safe package this(sfTransform transform)
    {
        m_transform = transform;
    }

    /**
     * Return the inverse of the transform.
     *
     * If the inverse cannot be computed, an identity transform is returned.
     *
     * Returns:
     *      A new transform which is the inverse of self.
     */
    @property @nogc @safe Transform inverse() const
    {
        return Transform(sfTransform_getInverse(&m_transform));
    }

    /**
     * Return the transform as a 4x4 matrix.
     *
     * This function returns a pointer to an array of 16 floats containing the
     * transform elements as a 4x4 matrix, which is directly compatible with
     * OpenGL functions.
     *
     * Example:
     * ---
     * Transform transform = ...;
     * glLoadMatrixf(&transform.getMatrix());
     * ---
     *
     * Returns:
     *      A 4x4 matrix.
     */
    @property const(float)[] matrix() const
    {
        float[] mx;
        sfTransform_getMatrix(&m_transform, mx.ptr);
        return mx;
    }

    /**
     * Combine the current transform with another one.
     *
     * The result is a transform that is equivalent to applying this followed by
     * transform. Mathematically, it is equivalent to a matrix multiplication.
     *
     * Params:
     *      other = Transform to combine with this one
     *
     * Returns:
     *      Reference to this.
     */
    @nogc @safe ref Transform combine(Transform other)
    {
        sfTransform_combine(&m_transform, &other.m_transform);
        return this;
    }

    /**
     * Transform a 2D point.
     *
     * Params:
     *      x = X coordinate of the point to transform
     *      y = Y coordinate of the point to transform
     *
     * Returns:
     *      Transformed point.
     */
    @nogc @safe Vector2f transformPoint(float x, float y) const
    {
        return transformPoint(Vector2f(x, y));
    }

    /**
     * Transform a 2D point.
     *
     * Params:
     *      point = Point to transform
     *
     * Returns:
     *      Transformed point.
     */
    @nogc @safe Vector2f transformPoint(Vector2f point) const
    {
        return sfTransform_transformPoint(&m_transform, point);
    }

    /**
     * Transform a rectangle.
     *
     * Since SFML doesn't provide support for oriented rectangles, the result of
     * this function is always an axis-aligned rectangle. Which means that if
     * the transform contains a rotation, the bounding rectangle of the
     * transformed rectangle is returned.
     *
     * Params:
     *      rectangle = Rectangle to transform
     *
     * Returns:
     *      Transformed rectangle.
     */
    @nogc @safe FloatRect transformRect(const(FloatRect) rectangle) const
    {
        return sfTransform_transformRect(&m_transform, rectangle);
    }

    /**
     * Combine the current transform with a translation.
     *
     * This function returns a reference to this, so that calls can be chained.
     * ---
     * Transform transform;
     * transform.translate(Vector2f(100, 200)).rotate(45);
     * ---
     *
     * Params:
     *      offset = Translation offset to apply
     *
     * Returns:
     *      Reference to this
     *
     * See_Also:
     *      rotate, scale
     */
    @nogc @safe ref Transform translate(Vector2f offset)
    {
        return translate(offset.x, offset.y);
    }

    /**
     * Combine the current transform with a translation.
     *
     * This function returns a reference to this, so that calls can be chained.
     * ---
     * Transform transform;
     * transform.translate(100, 200).rotate(45);
     * ---
     *
     * Params:
     *      x = Offset to apply on X axis
     *      y = Offset to apply on Y axis
     *
     * Returns:
     *      Reference to this
     *
     * See_Also:
     *      rotate, scale
     */
    @nogc @safe ref Transform translate(float x, float y)
    {
        sfTransform_translate(&m_transform, x, y);
        return this;
    }

    /**
     * Combine the current transform with a rotation.
     *
     * This function returns a reference to this, so that calls can be chained.
     * ---
     * Transform transform;
     * transform.rotate(90).translate(50, 20);
     * ---
     * Params:
     *      angle = Rotation angle, in degrees
     *
     * Returns:
     *      Reference to this
     *
     * See_Also:
     *      translate, scale
     */
    @nogc @safe ref Transform rotate(float angle)
    {
        sfTransform_rotate(&m_transform, angle);
        return this;
    }

    /**
     * Combine the current transform with a rotation.
     *
     * The center of rotation is provided for convenience as a second argument,
     * so that you can build rotations around arbitrary points more easily (and
     * efficiently) than the usual
     * `translate(-center).rotate(angle).translate(center)`.
     *
     * This function returns a reference to this, so that calls can be chained.
     * ---
     * Transform transform;
     * transform.rotate(90, 8, 3).translate(50, 20);
     * ---
     *
     * Params:
     *      angle   = Rotation angle, in degrees
     *      centerX = X coordinate of the center of rotation
     *      centerY = Y coordinate of the center of rotation
     *
     * Returns:
     *      Reference to this
     *
     * See_Also:
     *      translate, scale
     */
    @nogc @safe ref Transform rotate(float angle, float centerX, float centerY)
    {
        sfTransform_rotateWithCenter(&m_transform, angle, centerX, centerY);
        return this;
    }

    /**
     * Combine the current transform with a rotation.
     *
     * The center of rotation is provided for convenience as a second argument,
     * so that you can build rotations around arbitrary points more easily (and
     * efficiently) than the usual
     * `translate(-center).rotate(angle).translate(center)`.
     *
     * This function returns a reference to this, so that calls can be chained.
     * ---
     * Transform transform;
     * transform.rotate(90, Vector2f(8, 3)).translate(Vector2f(50, 20));
     * ---
     *
     * Params:
     *      angle  = Rotation angle, in degrees
     *      center = Center of rotation
     *
     * Returns:
     *      Reference to this
     *
     * See_Also:
     *      translate, scale
     */
    @nogc @safe ref Transform rotate(float angle, Vector2f center)
    {
        return rotate(angle, center.x, center.y);
    }

    /**
     * Combine the current transform with a scaling.
     *
     * This function returns a reference to this, so that calls can be chained.
     * ---
     * Transform transform;
     * transform.scale(2, 1).rotate(45);
     * ---
     *
     * Params:
     *      scaleX = Scaling factor on the X-axis.
     *      scaleY = Scaling factor on the Y-axis.
     *
     * Returns:
     *      Reference to this
     *
     * See_Also:
     *      translate, rotate
     */
    @nogc @safe ref Transform scale(float scaleX, float scaleY)
    {
        sfTransform_scale(&m_transform, scaleX, scaleY);
        return this;
    }

    /**
     * Combine the current transform with a scaling.
     *
     * This function returns a reference to this, so that calls can be chained.
     * ---
     * Transform transform;
     * transform.scale(Vector2f(2, 1)).rotate(45);
     * ---
     *
     * Params:
     *      factors = Scaling factors
     *
     * Returns:
     *      Reference to this
     *
     * See_Also:
     *      translate, rotate
     */
    @nogc @safe ref Transform scale(Vector2f factors)
    {
        return scale(factors.x, factors.y);
    }

    /**
     * Combine the current transform with a scaling.
     *
     * The center of scaling is provided for convenience as a second argument,
     * so that you can build scaling around arbitrary points more easily
     * (and efficiently) than the usual
     * `translate(-center).scale(factors).translate(center)`.
     *
     * This function returns a reference to this, so that calls can be chained.
     * ---
     * Transform transform;
     * transform.scale(2, 1, 8, 3).rotate(45);
     * ---
     *
     * Params:
     *      scaleX  = Scaling factor on the X-axis
     *      scaleY  = Scaling factor on the Y-axis
     *      centerX = X coordinate of the center of scaling
     *      centerY = Y coordinate of the center of scaling
     *
     * Returns:
     *      Reference to this
     *
     * See_Also:
     *      translate, rotate
     */
    @nogc @safe ref Transform scale(float scaleX, float scaleY, float centerX, float centerY)
    {
        sfTransform_scaleWithCenter(&m_transform, scaleX, scaleY, centerX, centerY);
        return this;
    }

    /**
     * Combine the current transform with a scaling.
     *
     * The center of scaling is provided for convenience as a second argument,
     * so that you can build scaling around arbitrary points more easily
     * (and efficiently) than the usual
     * `translate(-center).scale(factors).translate(center)`.
     *
     * This function returns a reference to this, so that calls can be chained.
     *
     * Params:
     *      factors = Scaling factors
     *      center  = Center of scaling
     *
     * Returns:
     *      Reference to this
     */
    @nogc @safe ref Transform scale(Vector2f factors, Vector2f center)
    {
        return scale(factors.x, factors.y, center.x, center.y);
    }

    /**
     * Overload of binary operator `*` and `/` to combine two transforms.
     *
     * For rhe `*` operator, this call is equivalent to:
     * ---
     * Transform combined = transform;
     * combined.combine(rhs);
     * ---
     *
     * For the `/` operator, this call is equivalent to:
     * ---
     * transform.combine(rhs).inverse();
     * ---
     *
     * Params:
     *      rhs = the second transform to be combined with the first
     *
     * Returns:
     *      New combined transform.
     */
    @safe Transform opBinary(string op)(Transform rhs) const
            if (op == "*" || op == "/")
    {
        static if (op == "*")
            return dup().combine(rhs);
        else static if (op == "/")
            return this * rhs.inverse();
    }

    /**
     * Overload of assignment operator `*=` to combine two transforms.
     *
     * This call is equivalent to calling `transform.combine(rhs)`.
     *
     * Params:
     *      rhs = the second transform to be combined with the first
     *
     * Returns:
     *      The combined transform.
     */
    @nogc @safe ref Transform opOpAssign(string op)(Transform rhs)
            if (op == "*" || op == "/")
    {
        static if (op == "*")
            return this.combine(rhs);
        else static if (op == "/")
            return this * rhs.inverse();
    }

    /**
     * Overload of binary operator `*` to transform a point
     *
     * This call is equivalent to calling `transform.transformPoint(vector)`.
     *
     * Params:
     *      vector = the point to transform
     *
     * Returns:
     *      New transformed point.
     */
    @nogc @safe Vextor2f opBinary(string op)(Vector2f vector) if (op == "*")
    {
        return transformPoint(vector);
    }

    // dfmt off
    /// The identity transform (does nothing).
    @nogc @safe static const(Transform) identity()
    {
        return Transform([1, 0, 0,
                          0, 1, 0,
                          0, 0, 1]);
    }

    @safe string toString() const
    {
        import std.conv : text;

        const float[9] mx = m_transform.matrix;
        return text(mx[0]) ~ ", " ~ text(mx[1]) ~ ", " ~ text(mx[2]) ~ "\n" ~
               text(mx[3]) ~ ", " ~ text(mx[4]) ~ ", " ~ text(mx[5]) ~ "\n" ~
               text(mx[6]) ~ ", " ~ text(mx[7]) ~ ", " ~ text(mx[8]);
    }
    // dfmt on

    // Returns the C struct.
    @nogc @safe package sfTransform toc()
    {
        return m_transform;
    }

    /// Duplicates this Transform
    @safe Transform dup() const
    {
        return Transform(m_transform.matrix);
    }
}

package extern (C)
{
    struct sfTransform // @suppress(dscanner.style.phobos_naming_convention)
    {
        float[9] matrix;
    }
}

@nogc @safe private extern (C)
{
    //const sfTransform sfTransform_Identity;
    // dfmt off
    sfTransform sfTransform_fromMatrix(float a00, float a01, float a02,
                                       float a10, float a11, float a12,
                                       float a20, float a21, float a22);
    // dfmt on
    void sfTransform_getMatrix(const sfTransform* transform, float* matrix);
    sfTransform sfTransform_getInverse(const sfTransform* transform);
    Vector2f sfTransform_transformPoint(const sfTransform* transform, Vector2f point);
    FloatRect sfTransform_transformRect(const sfTransform* transform, FloatRect rectangle);
    void sfTransform_combine(sfTransform* transform, const sfTransform* other);
    void sfTransform_translate(sfTransform* transform, float x, float y);
    void sfTransform_rotate(sfTransform* transform, float angle);
    void sfTransform_rotateWithCenter(sfTransform* transform, float angle,
            float centerX, float centerY);
    void sfTransform_scale(sfTransform* transform, float scaleX, float scaleY);
    void sfTransform_scaleWithCenter(sfTransform* transform, float scaleX,
            float scaleY, float centerX, float centerY);
    bool sfTransform_equal(sfTransform* left, sfTransform* right);
}

unittest
{
    import std.stdio : writeln;

    writeln("Running Transform unittest...");

    // dfmt off
    float[9] mx = [1, 2, 3,
                   2, 4, 3,
                   4, 4, 6];
    // dfmt on
    const auto t = Transform(mx);

    assert(t == Transform(mx));
    // PR #10200
    //assert(t.matrix.length == 16);

    // This should work :
    /*
    assert(t.inverse() == Transform(-1,         0,        0.5,
                                     0,         0.5,     -0.25,
                                     0.666667, -0.333333, 0));
    */

    // A matrix multiplicated by its inverse gives the identity
    assert(t * t.inverse == Transform.identity);

    //const Vector2f vec = Vector2f(2, 2);
    // PR #10200
    //const auto vv = t.transformPoint(vec);
    //assert(t.transformPoint(vec) == Vector2f(9, 15));

    //const FloatRect fr = FloatRect(1, 2, 3, 4);
    // PR #10200
    //assert(t.transformRect(fr) == FloatRect(8, 13, 11, 22));
}
