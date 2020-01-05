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
 *
 * The interface and template are provided for convenience, on top of
 * $(TRANSFORM_LINK).
 *
 * $(TRANSFORM_LINK), as a low-level class, offers a great level of flexibility
 * but it is not always convenient to manage. Indeed, one can easily combine any
 * kind of operation, such as a translation followed by a rotation followed by a
 * scaling, but once the result transform is built, there's no way to go
 * backward and, let's say, change only the rotation without modifying the
 * translation and scaling.
 *
 * The entire transform must be recomputed, which means that you need to
 * retrieve the initial translation and scale factors as well, and combine them
 * the same way you did before updating the rotation. This is a tedious
 * operation, and it requires to store all the individual components of the
 * final transform.
 *
 * That's exactly what $(U Transformable) and $(U NormalTransformable) were
 * written for: they hides these variables and the composed transform behind an
 * easy to use interface. You can set or get any of the individual components
 * without worrying about the others. It also provides the composed transform
 * (as a $(TRANSFORM_LINK)), and keeps it up-to-date.
 *
 * In addition to the position, rotation and scale, $(U Transformable) provides
 * an "origin" component, which represents the local origin of the three other
 * components. Let's take an example with a 10x10 pixels sprite. By default, the
 * sprite is positioned/rotated/scaled relatively to its top-left corner,
 * because it is the local point (0, 0). But if we change the origin to be
 * (5, 5), the sprite will be positioned/rotated/scaled around its center
 * instead. And if we set the origin to (10, 10), it will be transformed around
 * its bottom-right corner.
 *
 * To keep $(U Transformable) and $(U NormalTransformable) simple, there's only
 * one origin for all the components. You cannot position the sprite relatively
 * to its top-left corner while rotating it around its center, for example. To
 * do such things, use $(TRANSFORM_LINK) directly.
 *
 * $(U Transformable) is meant to be used as a base for other classes. It is
 * often combined with $(DRAWABLE_LINK) -- that's what DSFML's sprites, texts
 * and shapes do.
 * ---
 * class MyEntity : Transformable, Drawable
 * {
 *     //generates the boilerplate code for Transformable
 *     mixin NormalTransformable;
 *
 *     void draw(RenderTarget target, RenderStates states) const
 *     {
 *         states.transform *= getTransform();
 *         target.draw(..., states);
 *     }
 * }
 *
 * auto entity = new MyEntity();
 * entity.position = Vector2f(10, 20);
 * entity.rotation = 45;
 * window.draw(entity);
 * ---
 *
 * $(PARA If you don't want to use the API directly (because you don't need all
 * the functions, or you have different naming conventions for example), you can
 * have a $(U TransformableMember) as a member variable.)
 * ---
 * class MyEntity
 * {
 *     this()
 *     {
 *         myTransform = new TransformableMember();
 *     }
 *
 *     void setPosition(MyVector v)
 *     {
 *         myTransform.setPosition(v.x, v.y);
 *     }
 *
 *     void draw(RenderTarget target, RenderStates states) const
 *     {
 *         states.transform *= myTransform.getTransform();
 *         target.draw(..., states);
 *     }
 *
 * private TransformableMember myTransform;
 * }
 * ---
 *
 * $(PARA A note on coordinates and undistorted rendering:
 * By default, DSFML (or more exactly, OpenGL) may interpolate drawable objects
 * such as sprites or texts when rendering. While this allows transitions like
 * slow movements or rotations to appear smoothly, it can lead to unwanted
 * results in some cases, for example blurred or distorted objects. In order to
 * render a $(DRAWABLE_LINK) object pixel-perfectly, make sure the involved
 * coordinates allow a 1:1 mapping of pixels in the window to texels (pixels in
 * the texture). More specifically, this means:)
 * $(UL
 * $(LI The object's position, origin and scale have no fractional part)
 * $(LI The object's and the view's rotation are a multiple of 90 degrees)
 * $(LI The view's center and size have no fractional part))
 *
 * See_Also:
 * $(TRANSFORM_LINK)
 */
module dsfml.graphics.transformable;

import dsfml.system.vector2;
import dsfml.graphics.transform;

/**
 * Decomposed transform defined by a position, a rotation, and a scale.
 */
class Transformable
{
    private sfTransformable* m_transformable;

    /// Default constructor.
    this()
    {
        m_transformable = sfTransformable_create();
    }

    // Copy constructor.
    package this(const sfTransformable* transformablePointer)
    {
        m_transformable = sfTransformable_copy(transformablePointer);
    }

    /// Virtual destructor.
    ~this()
    {
        sfTransformable_destroy(m_transformable);
    }


    @property
    {
        /**
         * Set the local origin of the object
         *
         * The origin of an object defines the center point for all transformations
         * (position, scale, rotation). The coordinates of this point must be
         * relative to the top-left corner of the object, and ignore all
         * transformations (position, scale, rotation). The default origin of a
         * transformable object is (0, 0).
         *
         * Params:
         *     origin = New origin
         */
        void origin(Vector2f newOrigin)
        {
            sfTransformable_setOrigin(m_transformable, newOrigin);
        }

        /**
         * Set the local origin of the object
         *
         * The origin of an object defines the center point for all transformations
         * (position, scale, rotation). The coordinates of this point must be
         * relative to the top-left corner of the object, and ignore all
         * transformations (position, scale, rotation). The default origin of a
         * transformable object is (0, 0).
         *
         * Params:
         *     x = X coordinate of the new origin
         *     y = Y coordinate of the new origin
         */
        void origin(float x, float y)
        {
            origin(Vector2f(x, y));
        }

        /**
         * Get the local origin of the object
         *
         * Returns: Current origin
         */
        Vector2f origin() const
        {
            return sfTransformable_getOrigin(m_transformable);
        }
    }

    @property
    {
        /**
         * Set the position of the object
         *
         * This function completely overwrites the previous position. See the move
         * function to apply an offset based on the previous position instead. The
         * default position of a transformable object is (0, 0).
         *
         * Params:
         *     position = New position
         * See_Also: move
         */
        void position(Vector2f newPosition)
        {
            sfTransformable_setPosition(m_transformable, newPosition);
        }

        /**
         * Set the position of the object
         *
         * This function completely overwrites the previous position. See the move
         * function to apply an offset based on the previous position instead. The
         * default position of a transformable object is (0, 0).
         *
         * Params:
         *     x = X coordinate of the new position
         *     y = Y coordinate of the new position
         * See_Also: move
         */
        void position(float x, float y)
        {
            position(Vector2f(x, y));
        }

        /**
         * Get the position of the object
         *
         * Returns: Current position
         */
        Vector2f position() const
        {
            return sfTransformable_getPosition(m_transformable);
        }
    }

    /**
     * Rotate the object.
     *
     * This function adds to the current rotation of the object, unlike the
     * rotation property which overwrites it. Thus, it is equivalent to the
     * following code:
     * ---
     * object.rotation(object.rotation() + angle);
     * ---
     *
     * Params:
     *     angle = Angle of rotation, in degrees
     */
    void rotate(float angle)
    {
        sfTransformable_rotate(m_transformable, angle);
    }

    @property
    {
        /**
         * Set the orientation of the object
         *
         * This function completely overwrites the previous rotation. See the rotate
         * function to add an angle based on the previous rotation instead. The
         * default rotation of a transformable object is 0.
         *
         * Params:
         *     angle = New rotation, in degrees
         * See_Also: rotate
         */
        void rotation(float angle)
        {
            sfTransformable_setRotation(m_transformable, angle);
        }

        /**
         * Get the orientation of the object
         *
         * The rotation is always in the range [0, 360].
         *
         * Returns: Current rotation, in degrees
         * See_Also: rotate
         */
        float rotation() const
        {
            return sfTransformable_getRotation(m_transformable);
        }
    }

    @property
    {
        /**
         * Set the scale factors of the object
         *
         * This function completely overwrites the previous scale. See the scale
         * function to add a factor based on the previous scale instead. The default
         * scale of a transformable object is (1, 1).
         *
         * Params:
         *     factors = New scale factors
         */
        void scale(Vector2f newScale)
        {
            sfTransformable_setScale(m_transformable, newScale);
        }

        /**
         * Set the scale factors of the object
         *
         * This function completely overwrites the previous scale. See the scale
         * function to add a factor based on the previous scale instead. The
         * default scale of a transformable object is (1, 1).
         *
         * Params:
         *     factorX = New horizontal scale factor
         *     factorY = New vertical scale factor
         */
        void scale(float factorX, float factorY)
        {
            scale(Vector2f(factorX, factorY));
        }

        /**
         * Get the current scale of the object
         *
         * Returns: Current scale factors
         */
        Vector2f scale() const
        {
            return sfTransformable_getScale(m_transformable);
        }
    }

    /**
     * Get the combined transform of the object
     *
     * Returns: Transform combining the position/rotation/scale/origin of the object
     * See_Also: inverseTransform
     */
    const(Transform) transform()
    {
        return Transform(sfTransformable_getTransform(m_transformable));
    }

    /**
     * get the inverse of the combined transform of the object
     *
     * Returns: Inverse of the combined transformations applied to the object
     * See_Also: transform
     */
    const(Transform) inverseTransform()
    {
        return Transform(sfTransformable_getInverseTransform(m_transformable));
    }

    /**
     * Move the object by a given offset.
     *
     * This function adds to the current position of the object, unlike the
     * position property which overwrites it. Thus, it is equivalent to the
     * following code:
     * ---
     * object.position(object.position() + offset);
     * ---
     *
     * Params:
     *     offset = The offset
     * See_Also: position
     */
    void move(Vector2f offset)
    {
        sfTransformable_move(m_transformable, offset);
    }

    /**
     * Move the object by a given offset.
     *
     * This function adds to the current position of the object, unlike the
     * position property which overwrites it. Thus, it is equivalent to the
     * following code:
     * ---
     * Vector2f pos = object.position();
     * object.setPosition(pos.x + offsetX, pos.y + offsetY);
     * ---
     *
     * Params:
     *     offsetX = X offset
     *     offsetY = Y offset
     * See_Also: position
     */
    void move(float offsetX, float offsetY)
    {
        move(Vector2f(offsetX, offsetY));
    }

    /// Duplicates this Transformable.
    @property
    Transformable dup()
    {
        return new Transformable(m_transformable);
    }
}

private extern(C)
{
    struct sfTransformable;

    sfTransformable* sfTransformable_create();
    sfTransformable* sfTransformable_copy(const sfTransformable* transformable);
    void sfTransformable_destroy(sfTransformable* transformable);
    void sfTransformable_setPosition(sfTransformable* transformable, Vector2f position);
    void sfTransformable_setRotation(sfTransformable* transformable, float angle);
    void sfTransformable_setScale(sfTransformable* transformable, Vector2f scale);
    void sfTransformable_setOrigin(sfTransformable* transformable, Vector2f origin);
    Vector2f sfTransformable_getPosition(const sfTransformable* transformable);
    float sfTransformable_getRotation(const sfTransformable* transformable);
    Vector2f sfTransformable_getScale(const sfTransformable* transformable);
    Vector2f sfTransformable_getOrigin(const sfTransformable* transformable);
    void sfTransformable_move(sfTransformable* transformable, Vector2f offset);
    void sfTransformable_rotate(sfTransformable* transformable, float angle);
    void sfTransformable_scale(sfTransformable* transformable, Vector2f factors);
    sfTransform sfTransformable_getTransform(const sfTransformable* transformable);
    sfTransform sfTransformable_getInverseTransform(const sfTransformable* transformable);
}

unittest
{
    import std.stdio;

    writeln("Running Transformable unittest...");

    auto t = new Transformable();

    auto pos = Vector2f(5, 6);
    t.position = pos;
    assert(t.position == pos);
    t.move(5, 3);
    assert(t.position == Vector2f(10, 9));

    int angle = 90;
    t.rotation = angle;
    assert(t.rotation == angle);
    t.rotate(angle);
    assert(t.rotation == angle*2);

    auto scl = Vector2f(3, 4);
    t.scale = scl;
    assert(t.scale == scl);
    // TODO: https://issues.dlang.org/show_bug.cgi?id=8006
    //t.scale *= Vector2f(2, 3);
    //assert(t.scale == Vector2f(6, 12));

    auto orgn = Vector2f(1, 3);
    t.origin = orgn;
    assert(t.origin == orgn);

    //TODO: god dawn floats
    //assert(t.transform == Transform(-3, 0, 12.999999, 0, -4, 21, 0, 0, 1));
    assert(t.transform.inverse == t.inverseTransform);
}
