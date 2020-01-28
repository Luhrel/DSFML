
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
 * This class inherits all the functions of $(TRANSFORMABLE_LINK) (position,
 * rotation, scale, bounds, ...) as well as the functions of $(SHAPE_LINK)
 * (outline, color, texture, ...).
 *
 * Example:
 * ---
 * auto rectangle = new RectangleShape();
 * rectangle.size = Vector2f(100, 50);
 * rectangle.outlineColor = Color.Red;
 * rectangle.outlineThickness = 5;
 * rectangle.position = Vector2f(10, 20);
 * ...
 * window.draw(rectangle);
 * ---
 * See_Also:
 *      $(SHAPE_LINK), $(RectangleShape_LINK), $(CONVEXSHAPE_LINK)
 */
module dsfml.graphics.rectangleshape;

import dsfml.graphics.circleshape;
import dsfml.graphics.color;
import dsfml.graphics.texture;
import dsfml.graphics.rendertarget;
import dsfml.graphics.renderstates;
import dsfml.graphics.transform;
import dsfml.graphics.rect;
import dsfml.graphics.shape;

import dsfml.system.vector2;

/**
 * Specialized shape representing a rectangle.
 */
class RectangleShape : Shape
{
    private sfRectangleShape* m_rectangleShape;

    /**
     * Default constructor.
     *
     * Params:
     *      size = Size of the rectangle
     */
    @nogc
    this(Vector2f size = Vector2f(0, 0))
    {
        m_rectangleShape = sfRectangleShape_create();
        this.size = size;
    }

    // Copy constructor.
    @nogc
    private this(const sfRectangleShape* rectangleShapePointer)
    {
        m_rectangleShape = sfRectangleShape_copy(rectangleShapePointer);
    }

    /// Destructor
    @nogc @safe
    ~this()
    {
        sfRectangleShape_destroy(m_rectangleShape);
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
         * it, the behaviour is undefined. texture can be null to disable texturing.
         *
         * If resetRect is true, the TextureRect property of the shape is
         * automatically adjusted to the size of the new texture. If it is false,
         * the texture rect is left unchanged.
         *
         * Params:
         *      _texture  = New texture
         *      resetRect = Should the texture rect be reset to the size of the
         *                  new texture?
         */
        @nogc @safe
        override void texture(Texture _texture, bool resetRect = false)
        {
            sfRectangleShape_setTexture(m_rectangleShape, _texture.ptr, resetRect);
        }

        /**
         * Get the source texture of the shape.
         *
         * If the shape has no source texture, a null pointer is returned. The
         * returned pointer is const, which means that you can't modify the texture
         * when you retrieve it with this function.
         *
         * Returns:
         *      The shape's texture.
         */
        @safe
        override const(Texture) texture() const
        {
            return new Texture(sfRectangleShape_getTexture(m_rectangleShape));
        }
    }

    @property
    {
        /**
         * Set the sub-rectangle of the texture that the shape will display.
         *
         * The texture rect is useful when you don't want to display the whole
         * texture, but rather a part of it. By default, the texture rect covers
         * the entire texture.
         *
         * Params:
         *      rect = Rectangle defining the region of the texture to display
         *
         * See_Also:
         *      texture
         */
        @nogc @safe
        override void textureRect(IntRect rect)
        {
            sfRectangleShape_setTextureRect(m_rectangleShape, rect);
        }

        /**
         * Get the sub-rectangle of the texture displayed by the shape.
         *
         * Returns:
         *      Texture rectangle of the shape
         */
        @nogc @safe
        override IntRect textureRect() const
        {
            return sfRectangleShape_getTextureRect(m_rectangleShape);
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
         *      color = New color of the shape
         *
         * See_Also:
         *      outlineColor
         */
        @nogc @safe
        override void fillColor(Color color)
        {
            sfRectangleShape_setFillColor(m_rectangleShape, color);
        }

        /**
         * Get the fill color of the shape.
         *
         * Returns:
         *      Fill color of the shape
         */
        @nogc @safe
        override Color fillColor() const
        {
            return sfRectangleShape_getFillColor(m_rectangleShape);
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
         *      color = New outline color of the shape
         *
         * See_Also:
         *      fillColor
         */
        @nogc @safe
        override void outlineColor(Color color)
        {
            sfRectangleShape_setOutlineColor(m_rectangleShape, color);
        }

        /**
         * Get the outline color of the shape.
         *
         * Returns:
         *      Outline color of the shape
         *
         * See_Also:
         *      fillColor
         */
        @nogc @safe
        override Color outlineColor() const
        {
            return sfRectangleShape_getOutlineColor(m_rectangleShape);
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
         *      thickness = New outline thickness
         */
        @nogc @safe
        override void outlineThickness(float thickness)
        {
            sfRectangleShape_setOutlineThickness(m_rectangleShape, thickness);
        }

        /**
         * Get the outline thickness of the shape.
         *
         * Returns:
         *      Outline thickness of the shape
         */
        @nogc @safe
        override float outlineThickness() const
        {
            return sfRectangleShape_getOutlineThickness(m_rectangleShape);
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
         *      x = X coordinate of the new origin
         *      y = Y coordinate of the new origin
         */
        @nogc @safe
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
         *      _origin = New origin
         */
        @nogc @safe
        override void origin(Vector2f _origin)
        {
            sfRectangleShape_setOrigin(m_rectangleShape, _origin);
        }

        /**
         * Get the local origin of the object
         *
         * Returns:
         *      Current origin
         */
        @nogc @safe
        override Vector2f origin() const
        {
            return sfRectangleShape_getOrigin(m_rectangleShape);
        }
    }

    @property
    {
        /**
         * Get the number of points defining the shape.
         *
         * Returns:
         *      Number of points of the shape. For rectangle shapes, this number
         *      is always 4.
         */
        @nogc @safe
        override size_t pointCount() const
        {
            return sfRectangleShape_getPointCount(m_rectangleShape);
        }
    }

    @property
    {
        /**
         * Set the position of the object
         *
         * This function completely overwrites the previous position. See the `move`
         * function to apply an offset based on the previous position instead. The
         * default position of a transformable object is (0, 0).
         *
         * Params:
         *      x = X coordinate of the new position
         *      y = Y coordinate of the new position
         *
         * See_Also:
         *      move
         */
        @nogc @safe
        override void position(float x, float y)
        {
            position(Vector2f(x, y));
        }

        /**
         * Set the position of the object
         *
         * This function completely overwrites the previous position. See the `move`
         * function to apply an offset based on the previous position instead. The
         * default position of a transformable object is (0, 0).
         *
         * Params:
         *      _position = New position
         *
         * See_Also:
         *      move
         */
        @nogc @safe
        override void position(Vector2f _position)
        {
            sfRectangleShape_setPosition(m_rectangleShape, _position);
        }

        /**
         * Get the position of the object
         *
         * Returns:
         *      Current position
         */
        @nogc @safe
        override Vector2f position() const
        {
            return sfRectangleShape_getPosition(m_rectangleShape);
        }
    }

    /**
     * Rotate the object.
     *
     * This function adds to the current rotation of the object, unlike the `rotation`
     * property which overwrites it. Thus, it is equivalent to the following code:
     * ---
     * object.setRotation(object.rotation() + angle);
     * ---
     *
     * Params:
     *      angle = Angle of rotation, in degrees
     */
    @nogc @safe
    override void rotate(float angle)
    {
        sfRectangleShape_rotate(m_rectangleShape, angle);
    }

    @property
    {
        /**
         * Set the orientation of the object
         *
         * This function completely overwrites the previous rotation. See the `rotate`
         * function to add an angle based on the previous rotation instead. The
         * default rotation of a transformable object is 0.
         *
         * Params:
         *      angle = New rotation, in degrees
         *
         * See_Also:
         *      rotate
         */
        @nogc @safe
        override void rotation(float angle)
        {
            sfRectangleShape_setRotation(m_rectangleShape, angle);
        }

        /**
         * Get the orientation of the object
         *
         * The rotation is always in the range [0, 360].
         *
         * Returns:
         *      Current rotation, in degrees
         */
        @nogc @safe
        override float rotation() const
        {
            return sfRectangleShape_getRotation(m_rectangleShape);
        }
    }

    @property
    {
        /**
         * Set the scale factors of the object
         *
         * This function completely overwrites the previous scale. See the `scale`
         * function to add a factor based on the previous scale instead. The default
         * scale of a transformable object is (1, 1).
         *
         * Params:
         *      factorX = New horizontal scale factor
         *      factorY = New vertical scale factor
         */
        @nogc @safe
        override void scale(float factorX, float factorY)
        {
            scale(Vector2f(factorX, factorY));
        }

        /**
         * Set the scale factors of the object
         *
         * This function completely overwrites the previous scale. See the `scale`
         * function to add a factor based on the previous scale instead. The default
         * scale of a transformable object is (1, 1).
         *
         * Params:
         *      factors = New scale factors
         */
        @nogc @safe
        override void scale(Vector2f factors)
        {
            sfRectangleShape_setScale(m_rectangleShape, factors);
        }

        /**
         * Get the current scale of the object
         *
         * Returns:
         *      Current scale factors
         */
        @nogc @safe
        override Vector2f scale() const
        {
            return sfRectangleShape_getScale(m_rectangleShape);
        }
    }

    @property
    {
        /**
         * Set the size of the rectangle.
         *
         * Params:
         *      _size = New size of the rectangle
         */
        @nogc @safe
        void size(Vector2f _size)
        {
            sfRectangleShape_setSize(m_rectangleShape, _size);
        }

        /**
         * Get the size of the rectangle.
         *
         * Returns:
         *      Size of the rectangle
         */
        @nogc @safe
        Vector2f size()
        {
            return sfRectangleShape_getSize(m_rectangleShape);
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
     * Returns:
     *      Global bounding rectangle of the entity
     */
    @property @nogc @safe
    override FloatRect globalBounds() const
    {
        return sfRectangleShape_getGlobalBounds(m_rectangleShape);
    }

    /**
     * Get the local bounding rectangle of the entity.
     *
     * The returned rectangle is in local coordinates, which means that it
     * ignores the transformations (translation, rotation, scale, ...) that are
     * applied to the entity. In other words, this function returns the bounds
     * of the entity in the entity's coordinate system.
     *
     * Returns:
     *      Local bounding rectangle of the entity.
     */
    @property @nogc @safe
    override FloatRect localBounds() const
    {
        return sfRectangleShape_getLocalBounds(m_rectangleShape);
    }

    /**
     * Get a point of the rectangle.
     *
     * The returned point is in local coordinates, that is, the shape's transforms
     * (position, rotation, scale) are not taken into account. The result is
     * undefined if index is out of the valid range.
     *
     * Params:
     *      index = Index of the point to get, in range [0 .. 3]
     *
     * Returns:
     *      Index-th point of the shape.
     */
    @nogc @safe
    override Vector2f getPoint(size_t index = 0) const
    {
        return sfRectangleShape_getPoint(m_rectangleShape, index);
    }

    /**
     * Draw the shape to a render target.
     *
     * Params:
     *      renderTarget = Target to draw to
     *      renderStates = Current render states
     */
    override void draw(RenderTarget renderTarget, RenderStates renderStates = RenderStates.init)
    {
        renderTarget.draw(this, renderStates);
    }

    /**
     * Get the inverse of the combined transform of the object.
     *
     * Returns:
     *      Inverse of the combined transformations applied to the object
     */
    @nogc @safe
    override Transform inverseTransform() const
    {
        return Transform(sfRectangleShape_getInverseTransform(m_rectangleShape));
    }

    /**
     * Get the combined transform of the object.
     *
     * Returns:
     *      Transform combining the position/rotation/scale/origin of the object
     *
     * See_Also:
     *      inverseTransform
     */
    @nogc @safe
    override Transform transform()
    {
        return Transform(sfRectangleShape_getTransform(m_rectangleShape));
    }

    /**
     * Move the object by a given offset.
     *
     * This function adds to the current position of the object, unlike the `position`
     * property which overwrites it. Thus, it is equivalent to the following code:
     * ---
     * Vector2f pos = object.position();
     * object.position(pos.x + offsetX, pos.y + offsetY);
     * ---
     *
     * Params:
     *      offsetX = X offset
     *      offsetY = Y offset
     *
     * See_Also:
     *      position
     */
    @nogc @safe
    override void move(float offsetX, float offsetY)
    {
        move(Vector2f(offsetX, offsetY));
    }

    /**
     * Move the object by a given offset.
     *
     * This function adds to the current position of the object, unlike the `position`
     * property which overwrites it. Thus, it is equivalent to the following code:
     * ---
     * object.position(object.getPosition() + offset);
     * ---
     *
     * Params:
     *      offset = Offset
     */
    @nogc @safe
    override void move(Vector2f offset)
    {
        sfRectangleShape_move(m_rectangleShape, offset);
    }

    /// Duplicates this RectangleShape.
    @property
    override RectangleShape dup() const
    {
        return new RectangleShape(m_rectangleShape);
    }

    // Returns the C Pointer.
    @property @nogc @safe
    package sfRectangleShape* ptr()
    {
        return m_rectangleShape;
    }
}

package extern(C)
{
    struct sfRectangleShape;
}

@nogc @safe
private extern(C)
{
    sfRectangleShape* sfRectangleShape_create();
    sfRectangleShape* sfRectangleShape_copy(const sfRectangleShape* shape);
    void sfRectangleShape_destroy(sfRectangleShape* shape);
    void sfRectangleShape_setPosition(sfRectangleShape* shape, Vector2f position);
    void sfRectangleShape_setRotation(sfRectangleShape* shape, float angle);
    void sfRectangleShape_setScale(sfRectangleShape* shape, Vector2f scale);
    void sfRectangleShape_setOrigin(sfRectangleShape* shape, Vector2f origin);
    Vector2f sfRectangleShape_getPosition(const sfRectangleShape* shape);
    float sfRectangleShape_getRotation(const sfRectangleShape* shape);
    Vector2f sfRectangleShape_getScale(const sfRectangleShape* shape);
    Vector2f sfRectangleShape_getOrigin(const sfRectangleShape* shape);
    void sfRectangleShape_move(sfRectangleShape* shape, Vector2f offset);
    void sfRectangleShape_rotate(sfRectangleShape* shape, float angle);
    void sfRectangleShape_scale(sfRectangleShape* shape, Vector2f factors);
    sfTransform sfRectangleShape_getTransform(const sfRectangleShape* shape);
    sfTransform sfRectangleShape_getInverseTransform(const sfRectangleShape* shape);
    void sfRectangleShape_setTexture(sfRectangleShape* shape, const sfTexture* texture, bool resetRect);
    void sfRectangleShape_setTextureRect(sfRectangleShape* shape, IntRect rect);
    void sfRectangleShape_setFillColor(sfRectangleShape* shape, Color color);
    void sfRectangleShape_setOutlineColor(sfRectangleShape* shape, Color color);
    void sfRectangleShape_setOutlineThickness(sfRectangleShape* shape, float thickness);
    const(sfTexture)* sfRectangleShape_getTexture(const sfRectangleShape* shape);
    IntRect sfRectangleShape_getTextureRect(const sfRectangleShape* shape);
    Color sfRectangleShape_getFillColor(const sfRectangleShape* shape);
    Color sfRectangleShape_getOutlineColor(const sfRectangleShape* shape);
    float sfRectangleShape_getOutlineThickness(const sfRectangleShape* shape);
    size_t sfRectangleShape_getPointCount(const sfRectangleShape* shape);
    Vector2f sfRectangleShape_getPoint(const sfRectangleShape* shape, size_t index);
    void sfRectangleShape_setSize(sfRectangleShape* shape, Vector2f size);
    Vector2f sfRectangleShape_getSize(const sfRectangleShape* shape);
    FloatRect sfRectangleShape_getLocalBounds(const sfRectangleShape* shape);
    FloatRect sfRectangleShape_getGlobalBounds(const sfRectangleShape* shape);
}

unittest
{
    import std.stdio;
    writeln("Running RectangleShape unittest...");

    auto rectangle = new RectangleShape();

    auto pos = Vector2f(6.5224151, 7.1);
    rectangle.position = pos;
    assert(rectangle.position == pos);
    rectangle.move(0.4775849, 0.9);
    assert(rectangle.position == Vector2f(7, 8));

    auto rot = 120;
    rectangle.rotation = rot;
    assert(rectangle.rotation == rot);
    rectangle.rotate(2*rot);
    assert(rectangle.rotation == 0);

    auto scl = Vector2f(5, 7);
    rectangle.scale = scl;
    assert(rectangle.scale == scl);

    auto orgn = Vector2f(9, 19);
    rectangle.origin = orgn;
    assert(rectangle.origin == orgn);

    auto t = rectangle.transform;
    auto it = rectangle.inverseTransform;
    //TODO:
    // assert(t == Transform());
    assert(t.inverse == it);

    auto texR = IntRect(0, 0, 20, 30);
    rectangle.textureRect = texR;
    assert(rectangle.textureRect == texR);

    auto color = Color.Yellow;
    rectangle.fillColor = color;
    assert(rectangle.fillColor == color);

    rectangle.outlineColor = color;
    assert(rectangle.outlineColor == color);

    float thc = 10;
    rectangle.outlineThickness = thc;
    assert(rectangle.outlineThickness == thc);

    assert(rectangle.pointCount == 4);

    auto newSize = Vector2f(20, 20);
    rectangle.size = newSize;
    assert(rectangle.size == newSize);

    assert(rectangle[0] == Vector2f(0, 0));
    assert(rectangle[1] == Vector2f(20, 0));
    assert(rectangle[2] == Vector2f(20, 20));
    assert(rectangle[3] == Vector2f(0, 20));

    assert(rectangle.localBounds == IntRect(-10, -10, 40, 40));
    assert(rectangle.globalBounds == IntRect(-88, -195, 200, 280));
}
