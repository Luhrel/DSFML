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
 * $(U Shape) is a drawable class that allows to define and display a custom
 * convex shape on a render target.
 *
 * It's only an abstract base, it needs to be specialized for concrete types of
 * shapes (circle, rectangle, convex polygon, star, ...).
 *
 * In addition to the attributes provided by the specialized shape classes, a
 * shape always has the following attributes:
 * $(UL
 * $(LI a texture)
 * $(LI a texture rectangle)
 * $(LI a fill color)
 * $(LI an outline color)
 * $(LI an outline thickness))
 *
 * $(PARA Each feature is optional, and can be disabled easily:)
 * $(UL
 * $(LI the texture can be null)
 * $(LI the fill/outline colors can be Color.Transparent)
 * $(LI the outline thickness can be zero))
 *
 * $(PARA You can write your own derived shape class, there are only two
 * abstract functions to override:)
 * $(UL
 * $(LI `getPointCount` must return the number of points of the shape)
 * $(LI `getPoint` must return the points of the shape))
 *
 * See_Also:
 * $(RECTANGLESHAPE_LINK), $(CIRCLESHAPE_LINK), $(CONVEXSHAPE_LINK),
 * $(TRANSFORMABLE_LINK)
 */
module dsfml.graphics.shape;

import dsfml.system.vector2;

import dsfml.graphics.color;
import dsfml.graphics.drawable;
import dsfml.graphics.rect;
import dsfml.graphics.rendertarget;
import dsfml.graphics.renderstates;
import dsfml.graphics.texture;
import dsfml.graphics.transform;
import dsfml.graphics.transformable;

/**
 * Base class for textured shapes with outline.
 */
class Shape : Transformable, Drawable
{
    private sfShape* m_shape;

    /// Default constructor.
    this()
    {
        m_shape = sfShape_create(&getPointCountCallback, &getPointCallback, cast(void*) this);
    }

    /// Virtual destructor.
    ~this()
    {
        sfShape_destroy(m_shape);
    }

    @property
    {
        /**
         * Change the source texture of the shape.
         *
         * The texture argument refers to a texture that must exist as long as the
         * shape uses it. Indeed, the shape doesn't store its own copy of the
         * texture, but rather keeps a pointer to the one that you passed to this
         * function. If the source texture is destroyed and the shape tries to use
         * it, the behaviour is undefined. texture can be NULL to disable texturing.
         *
         * If resetRect is true, the TextureRect property of the shape is
         * automatically adjusted to the size of the new texture. If it is false,
         * the texture rect is left unchanged.
         *
         * Params:
         *     texture   = New texture
         *     resetRect = Should the texture rect be reset to the size of the new
         *              texture?
         */
        void texture(Texture newTexture, bool resetRect = false)
        {
            sfShape_setTexture(m_shape, newTexture.ptr, resetRect);
        }

        /**
         * Get the source texture of the shape.
         *
         * If the shape has no source texture, a NULL pointer is returned. The
         * returned pointer is const, which means that you can't modify the texture
         * when you retrieve it with this function.
         *
         * Returns: The shape's texture.
         */
        const(Texture) texture() const
        {
            return new Texture(sfShape_getTexture(m_shape));
        }
    }

    @property
    {
        /**
         * Set the sub-rectangle of the texture that the shape will display.
         *
         * The texture rect is useful when you don't want to display the whole texture, but rather a part of it. By default, the texture rect covers the entire texture.
         *
         * Params:
         *     rect = Rectangle defining the region of the texture to display
         * See_Also: texture
         */
        void textureRect(IntRect rect)
        {
            sfShape_setTextureRect(m_shape, rect);
        }

        /**
         * Get the sub-rectangle of the texture displayed by the shape.
         *
         * Returns: Texture rectangle of the shape
         */
        IntRect textureRect() const
        {
            return sfShape_getTextureRect(m_shape);
        }
    }

    @property
    {
        /**
         * Set the fill color of the shape.
         *
         * This color is modulated (multiplied) with the shape's texture if any. It
         * can be used to colorize the shape, or change its global opacity. You can
         * use Color.Transparent to make the inside of the shape transparent, and
         * have the outline alone. By default, the shape's fill color is opaque
         * white.
         *
         * Params:
         *     color = New color of the shape
         * See_Also: outlineColor
         */
        void fillColor(Color color)
        {
            sfShape_setFillColor(m_shape, color);
        }

        /**
         * Get the fill color of the shape.
         *
         * Returns: Fill color of the shape
         */
        Color fillColor() const
        {
            return sfShape_getFillColor(m_shape);
        }
    }

    @property
    {
        /**
         * Set the outline color of the shape.
         *
         * By default, the shape's outline color is opaque white.
         *
         * Params:
         *     color = New outline color of the shape
         * See_Also: fillColor
         */
        void outlineColor(Color color)
        {
            sfShape_setOutlineColor(m_shape, color);
        }

        /**
         * Get the outline color of the shape.
         *
         * Returns: Outline color of the shape
         * See_Also: fillColor
         */
        Color outlineColor() const
        {
            return sfShape_getOutlineColor(m_shape);
        }
    }

    @property
    {
        /**
         * Set the thickness of the shape's outline.
         *
         * Note that negative values are allowed (so that the outline expands
         * towards the center of the shape), and using zero disables the outline.
         * By default, the outline thickness is 0.
         *
         * Params:
         *     thickness = New outline thickness
         */
        void outlineThickness(float thickness)
        {
            sfShape_setOutlineThickness(m_shape, thickness);
        }

        /**
         * Get the outline thickness of the shape.
         *
         * Returns: Outline thickness of the shape
         */
        float outlineThickness() const
        {
            return sfShape_getOutlineThickness(m_shape);
        }
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
         *     x = X coordinate of the new origin
         *     y = Y coordinate of the new origin
         */
        override void origin(float x, float y)
        {
            origin(Vector2f(x, y));
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
         *     origin = New origin
         */
        override void origin(Vector2f newOrigin)
        {
            sfShape_setOrigin(m_shape, newOrigin);
        }

        /**
         * Get the local origin of the object
         *
         * Returns: Current origin
         */
        override Vector2f origin() const
        {
            return sfShape_getOrigin(m_shape);
        }
    }

    @property
    {
        /**
         * Get the total number of points of the shape.
         *
         * Returns: Number of points of the shape
         * See_Also: getPoint
         */
        abstract size_t pointCount() const;
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
         *     x = X coordinate of the new position
         *     y = Y coordinate of the new position
         * See_Also: move
         */
        override void position(float x, float y)
        {
            position(Vector2f(x, y));
        }

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
        override void position(Vector2f newPosition)
        {
            sfShape_setPosition(m_shape, newPosition);
        }

        /**
         * Get the position of the object
         *
         * Returns: Current position
         */
        override Vector2f position() const
        {
            return sfShape_getPosition(m_shape);
        }
    }

    /**
     * Rotate the object.
     *
     * This function adds to the current rotation of the object, unlike the rotation
     * property which overwrites it. Thus, it is equivalent to the following code:
     * ---
     * object.setRotation(object.rotation() + angle);
     * ---
     *
     * Params:
     *     angle = Angle of rotation, in degrees
     */
    override void rotate(float angle)
    {
        sfShape_rotate(m_shape, angle);
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
        override void rotation(float angle)
        {
            sfShape_setRotation(m_shape, angle);
        }

        /**
         * Get the orientation of the object
         *
         * The rotation is always in the range [0, 360].
         *
         * Returns: Current rotation, in degrees
         */
        override float rotation() const
        {
            return sfShape_getRotation(m_shape);
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
         *     factorX = New horizontal scale factor
         *     factorY = New vertical scale factor
         */
        override void scale(float factorX, float factorY)
        {
            scale(Vector2f(factorX, factorY));
        }

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
        override void scale(Vector2f factors)
        {
            sfShape_setScale(m_shape, factors);
        }

        /**
         * Get the current scale of the object
         *
         * Returns: Current scale factors
         */
        override Vector2f scale() const
        {
            return sfShape_getScale(m_shape);
        }
    }

    /**
     * Get the global (non-minimal) bounding rectangle of the entity.
     *
     * The returned rectangle is in global coordinates, which means that it takes
     * into account the transformations (translation, rotation, scale, ...) that are
     * applied to the entity. In other words, this function returns the bounds of
     * the shape in the global 2D world's coordinate system.
     *
     * This function does not necessarily return the minimal bounding rectangle. It
     * merely ensures that the returned rectangle covers all the vertices (but
     * possibly more). This allows for a fast approximation of the bounds as a first
     * check; you may want to use more precise checks on top of that.
     *
     * Returns: Global bounding rectangle of the entity
     */
    @property
    FloatRect globalBounds() const
    {
        return sfShape_getGlobalBounds(m_shape);
    }

    /**
     * Get the local bounding rectangle of the entity.
     *
     * The returned rectangle is in local coordinates, which means that it
     * ignores the transformations (translation, rotation, scale, ...) that are
     * applied to the entity. In other words, this function returns the bounds
     * of the entity in the entity's coordinate system.
     *
     * Returns: Local bounding rectangle of the entity.
     */
    @property
    FloatRect localBounds() const
    {
        return sfShape_getLocalBounds(m_shape);
    }

    /**
     * Get a point of the shape.
     *
     * The returned point is in local coordinates, that is, the shape's transforms
     * (position, rotation, scale) are not taken into account. The result is
     * undefined if index is out of the valid range.
     *
     * Params:
     *     index = Index of the point to get, in range [0 .. pointCount() - 1]
     *
     * Returns: Index-th point of the shape.
     * See_Also: pointCount
     */
    abstract Vector2f getPoint(size_t index = 0) const;

    /**
     * Draw the shape to a render target.
     *
     * Params:
     *         renderTarget    = Target to draw to
     *         renderStates    = Current render states
     */
    override void draw(RenderTarget renderTarget, RenderStates renderStates = RenderStates.init)
    {
        renderTarget.draw(this, renderStates);
    }

    /**
     * Get the inverse of the combined transform of the object
     *
     * Returns: Inverse of the combined transformations applied to the object
     */
    override Transform inverseTransform() const
    {
        return Transform(sfShape_getInverseTransform(m_shape));
    }

    /**
     * Get the combined transform of the object
     *
     * Returns: Transform combining the position/rotation/scale/origin of the object
     * See_Also: inverseTransform
     */
    override Transform transform()
    {
        return Transform(sfShape_getTransform(m_shape));
    }

    /**
     * Move the object by a given offset.
     *
     * This function adds to the current position of the object, unlike the position
     * property which overwrites it. Thus, it is equivalent to the following code:
     * ---
     * Vector2f pos = object.position();
     * object.position(pos.x + offsetX, pos.y + offsetY);
     * ---
     *
     * Params:
     *     offsetX = X offset
     *     offsetY = Y offset
     * See_Also: position
     */
    override void move(float offsetX, float offsetY)
    {
        move(Vector2f(offsetX, offsetY));
    }

    /**
     * Move the object by a given offset.
     *
     * This function adds to the current position of the object, unlike the position
     * property which overwrites it. Thus, it is equivalent to the following code:
     * ---
     * object.position(object.getPosition() + offset);
     * ---
     *
     * Params:
     *     offset = Offset
     */
    override void move(Vector2f offset)
    {
        sfShape_move(m_shape, offset);
    }

    /**
     * Recompute the internal geometry of the shape.
     *
     * This function must be called by the derived class everytime the shape's
     * points change (i.e. the result of either getPointCount or getPoint is
     * different).
     */
    protected void update()
    {
        sfShape_update(m_shape);
    }

    /**
     * Overload of the slice operator (get).
     * This function simply call `point(index)`.
     *
     * example:
     * ---
     * Vector2f p2 = shape[2];
     * ---
     */
    Vector2f opIndex(size_t index) const
    {
        return getPoint(index);
    }

    /*
     * Called by CSFML when sfShape_getPointCount() is called.
     */
    private extern(C) static size_t getPointCountCallback(void* userData)
    {
        Shape shape = cast(Shape) userData;
        return shape.pointCount();
    }

    /*
     * Called by CSFML when sfShape_getPoint(index) is called.
     */
    private extern(C) static Vector2f getPointCallback(size_t index, void* userData)
    {
        Shape shape = cast(Shape) userData;
        return shape.getPoint(index);
    }

    // Returns the C pointer.
    package sfShape* ptr()
    {
        return m_shape;
    }
}

package extern(C)
{
    struct sfShape;
}

private extern(C)
{
    alias sfShapeGetPointCountCallback = size_t function(void*);
    alias sfShapeGetPointCallback = Vector2f function(size_t, void*);

    sfShape* sfShape_create(sfShapeGetPointCountCallback getPointCount,
                                           sfShapeGetPointCallback getPoint,
                                           void* userData);
    void sfShape_destroy(sfShape* shape);
    void sfShape_setPosition(sfShape* shape, Vector2f position);
    void sfShape_setRotation(sfShape* shape, float angle);
    void sfShape_setScale(sfShape* shape, Vector2f scale);
    void sfShape_setOrigin(sfShape* shape, Vector2f origin);
    Vector2f sfShape_getPosition(const sfShape* shape);
    float sfShape_getRotation(const sfShape* shape);
    Vector2f sfShape_getScale(const sfShape* shape);
    Vector2f sfShape_getOrigin(const sfShape* shape);
    void sfShape_move(sfShape* shape, Vector2f offset);
    void sfShape_rotate(sfShape* shape, float angle);
    void sfShape_scale(sfShape* shape, Vector2f factors);
    sfTransform sfShape_getTransform(const sfShape* shape);
    sfTransform sfShape_getInverseTransform(const sfShape* shape);
    void sfShape_setTexture(sfShape* shape, const sfTexture* texture, bool resetRect);
    void sfShape_setTextureRect(sfShape* shape, IntRect rect);
    void sfShape_setFillColor(sfShape* shape, Color color);
    void sfShape_setOutlineColor(sfShape* shape, Color color);
    void sfShape_setOutlineThickness(sfShape* shape, float thickness);
    const(sfTexture)* sfShape_getTexture(const sfShape* shape);
    IntRect sfShape_getTextureRect(const sfShape* shape);
    Color sfShape_getFillColor(const sfShape* shape);
    Color sfShape_getOutlineColor(const sfShape* shape);
    float sfShape_getOutlineThickness(const sfShape* shape);
    size_t sfShape_getPointCount(const sfShape* shape);
    Vector2f sfShape_getPoint(const sfShape* shape, size_t index);
    FloatRect sfShape_getLocalBounds(const sfShape* shape);
    FloatRect sfShape_getGlobalBounds(const sfShape* shape);
    void sfShape_update(sfShape* shape);
}

unittest
{
    import std.stdio;
    writeln("Running Shape unittest...");

    class MyShape : Shape
    {
        this() { super(); }

        // Dummy implementation
        @property
        override size_t pointCount() const
        {
            return 1;
        }

        // Dummy implementation
        override Vector2f getPoint(size_t index = 0) const
        {
            return Vector2f(0, 0);
        }
    }

    auto shape = new MyShape();

    auto pos = Vector2f(2.945, 6.1);
    shape.position = pos;
    assert(shape.position == pos);
    shape.move(1.055, 0.9);
    assert(shape.position == Vector2f(4, 7));

    auto rot = 80;
    shape.rotation = rot;
    assert(shape.rotation == rot);
    shape.rotate(rot);
    assert(shape.rotation == 2*rot);

    auto scl = Vector2f(1, 2);
    shape.scale = scl;
    assert(shape.scale == scl);

    auto orgn = Vector2f(5, 6);
    shape.origin = orgn;
    assert(shape.origin == orgn);

    auto t = shape.transform;
    auto it = shape.inverseTransform;
    // TODO:
    // assert(t == Transform());
    assert(t.inverse == it);

    // TODO:
    // assert(shape.texture == );

    auto texR = IntRect(2, 4, 6, 8);
    shape.textureRect = texR;
    assert(shape.textureRect == texR);

    auto fc = Color.Red;
    shape.fillColor = fc;
    assert(shape.fillColor == fc);

    auto oc = Color.Green;
    shape.outlineColor = oc;
    assert(shape.outlineColor == oc);

    float thck = 18;
    shape.outlineThickness = thck;
    assert(shape.outlineThickness == thck);

    //TODO:
    // localBounds
    // globalBounds
}
