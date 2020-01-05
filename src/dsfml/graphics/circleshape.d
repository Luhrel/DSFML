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
 * auto circle = new CircleShape();
 * circle.radius = 150;
 * circle.outlineColor = Color.Red;
 * circle.outlineThickness = 5;
 * circle.position = Vector2f(10, 20);
 * ...
 * window.draw(circle);
 * ---
 *
 *$(PARA Since the graphics card can't draw perfect circles, we have to fake
 * them with multiple triangles connected to each other. The "points count"
 * property of $(U CircleShape) defines how many of these triangles to use, and
 * therefore defines the quality of the circle.)
 *
 * See_Also:
 * $(SHAPE_LINK), $(RECTANGLESHAPE_LINK), $(CONVEXSHAPE_LINK)
 */
module dsfml.graphics.circleshape;

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
 * Specialized shape representing a circle.
 */
class CircleShape : Shape
{
    private sfCircleShape* m_circleShape;

    /**
     * Default constructor.
     *
     * Params:
     *     radius     = Radius of the circle
     *     pointCount = Number of points composing the circle
    */
    this(float radius = 0, size_t pointCount = 30)
    {
        m_circleShape = sfCircleShape_create();
        this.radius = radius;
        this.pointCount = pointCount;
    }

    // Copy constructor.
    package this(const sfCircleShape* circleShapePointer)
    {
        m_circleShape = sfCircleShape_copy(circleShapePointer);
    }

    /// Destructor.
    ~this()
    {
        sfCircleShape_destroy(m_circleShape);
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
        override void texture(Texture newTexture, bool resetRect = false)
        {
            sfCircleShape_setTexture(m_circleShape, newTexture.ptr, resetRect);
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
        override const(Texture) texture() const
        {
            const sfTexture* t = sfCircleShape_getTexture(m_circleShape);
            if (t is null)
                return null;
            return new Texture(t);
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
        override void textureRect(IntRect rect)
        {
            sfCircleShape_setTextureRect(m_circleShape, rect);
        }

        /**
         * Get the sub-rectangle of the texture displayed by the shape.
         *
         * Returns: Texture rectangle of the shape
         */
        override IntRect textureRect() const
        {
            return sfCircleShape_getTextureRect(m_circleShape);
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
        override void fillColor(Color color)
        {
            sfCircleShape_setFillColor(m_circleShape, color);
        }

        /**
         * Get the fill color of the shape.
         *
         * Returns: Fill color of the shape
         */
        override Color fillColor() const
        {
            return sfCircleShape_getFillColor(m_circleShape);
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
        override void outlineColor(Color color)
        {
            sfCircleShape_setOutlineColor(m_circleShape, color);
        }

        /**
         * Get the outline color of the shape.
         *
         * Returns: Outline color of the shape
         * See_Also: fillColor
         */
        override Color outlineColor() const
        {
            return sfCircleShape_getOutlineColor(m_circleShape);
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
        override void outlineThickness(float thickness)
        {
            sfCircleShape_setOutlineThickness(m_circleShape, thickness);
        }

        /**
         * Get the outline thickness of the shape.
         *
         * Returns: Outline thickness of the shape
         */
        override float outlineThickness() const
        {
            return sfCircleShape_getOutlineThickness(m_circleShape);
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
            sfCircleShape_setOrigin(m_circleShape, newOrigin);
        }

        /**
         * Get the local origin of the object
         *
         * Returns: Current origin
         */
        override Vector2f origin() const
        {
            return sfCircleShape_getOrigin(m_circleShape);
        }
    }

    @property
    {
        /**
         * Set the number of points of the circle.
         *
         * Params:
         *     count = New number of points of the circle
         */
        void pointCount(size_t count)
        {
            sfCircleShape_setPointCount(m_circleShape, count);
        }

        /**
         * Get the total number of points of the shape.
         *
         * Returns: Number of points of the shape
         * See_Also: getPoint
         */
        override size_t pointCount() const
        {
            return sfCircleShape_getPointCount(m_circleShape);
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
            sfCircleShape_setPosition(m_circleShape, newPosition);
        }

        /**
         * Get the position of the object
         *
         * Returns: Current position
         */
        override Vector2f position() const
        {
            return sfCircleShape_getPosition(m_circleShape);
        }
    }

    @property
    {
        /**
         * Set the radius of the circle.
         *
         * Params:
         *     radius = New radius of the circle
         */
        void radius(float newRadius)
        {
            sfCircleShape_setRadius(m_circleShape, newRadius);
        }

        /**
         * Get the radius of the circle.
         *
         * Returns: Radius of the circle
         */
        float radius()
        {
            return sfCircleShape_getRadius(m_circleShape);
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
        sfCircleShape_rotate(m_circleShape, angle);
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
            sfCircleShape_setRotation(m_circleShape, angle);
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
            return sfCircleShape_getRotation(m_circleShape);
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
            sfCircleShape_setScale(m_circleShape, factors);
        }

        /**
         * Get the current scale of the object
         *
         * Returns: Current scale factors
         */
        override Vector2f scale() const
        {
            return sfCircleShape_getScale(m_circleShape);
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
    override FloatRect globalBounds() const
    {
        return sfCircleShape_getGlobalBounds(m_circleShape);
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
    override FloatRect localBounds() const
    {
        return sfCircleShape_getLocalBounds(m_circleShape);
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
    override Vector2f getPoint(size_t index = 0) const
    {
        return sfCircleShape_getPoint(m_circleShape, index);
    }

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
        return Transform(sfCircleShape_getInverseTransform(m_circleShape));
    }

    /**
     * Get the combined transform of the object
     *
     * Returns: Transform combining the position/rotation/scale/origin of the object
     * See_Also: inverseTransform
     */
    override Transform transform()
    {
        return Transform(sfCircleShape_getTransform(m_circleShape));
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
        sfCircleShape_move(m_circleShape, offset);
    }

    /// Duplicates this CircleShape.
    @property
    override CircleShape dup() const
    {
        return new CircleShape(m_circleShape);
    }

    // Returns the C pointer.
    package sfCircleShape* ptr()
    {
        return m_circleShape;
    }
}

package extern(C)
{
    struct sfCircleShape;
}

private extern(C)
{
    sfCircleShape* sfCircleShape_create();
    sfCircleShape* sfCircleShape_copy(const sfCircleShape* shape);
    void sfCircleShape_destroy(sfCircleShape* shape);
    void sfCircleShape_setPosition(sfCircleShape* shape, Vector2f position);
    void sfCircleShape_setRotation(sfCircleShape* shape, float angle);
    void sfCircleShape_setScale(sfCircleShape* shape, Vector2f scale);
    void sfCircleShape_setOrigin(sfCircleShape* shape, Vector2f origin);
    Vector2f sfCircleShape_getPosition(const sfCircleShape* shape);
    float sfCircleShape_getRotation(const sfCircleShape* shape);
    Vector2f sfCircleShape_getScale(const sfCircleShape* shape);
    Vector2f sfCircleShape_getOrigin(const sfCircleShape* shape);
    void sfCircleShape_move(sfCircleShape* shape, Vector2f offset);
    void sfCircleShape_rotate(sfCircleShape* shape, float angle);
    void sfCircleShape_scale(sfCircleShape* shape, Vector2f factors);
    sfTransform sfCircleShape_getTransform(const sfCircleShape* shape);
    sfTransform sfCircleShape_getInverseTransform(const sfCircleShape* shape);
    void sfCircleShape_setTexture(sfCircleShape* shape, const sfTexture* texture, bool resetRect);
    void sfCircleShape_setTextureRect(sfCircleShape* shape, IntRect rect);
    void sfCircleShape_setFillColor(sfCircleShape* shape, Color color);
    void sfCircleShape_setOutlineColor(sfCircleShape* shape, Color color);
    void sfCircleShape_setOutlineThickness(sfCircleShape* shape, float thickness);
    const(sfTexture)* sfCircleShape_getTexture(const sfCircleShape* shape);
    IntRect sfCircleShape_getTextureRect(const sfCircleShape* shape);
    Color sfCircleShape_getFillColor(const sfCircleShape* shape);
    Color sfCircleShape_getOutlineColor(const sfCircleShape* shape);
    float sfCircleShape_getOutlineThickness(const sfCircleShape* shape);
    size_t sfCircleShape_getPointCount(const sfCircleShape* shape);
    Vector2f sfCircleShape_getPoint(const sfCircleShape* shape, size_t index);
    void sfCircleShape_setRadius(sfCircleShape* shape, float radius);
    float sfCircleShape_getRadius(const sfCircleShape* shape);
    void sfCircleShape_setPointCount(sfCircleShape* shape, size_t count);
    FloatRect sfCircleShape_getLocalBounds(const sfCircleShape* shape);
    FloatRect sfCircleShape_getGlobalBounds(const sfCircleShape* shape);
}

unittest
{
    import std.stdio;
    writeln("Running CircleShape unittest...");

    CircleShape circle = new CircleShape();

    assert(circle.radius == 0);
    circle.radius = 10;
    assert(circle.radius == 10);

    assert(circle.pointCount == 30);
    circle.pointCount = 60;
    assert(circle.pointCount == 60);

    Vector2f pos = Vector2f(20, 30);
    circle.position = pos;
    assert(circle.position == pos);
    circle.move(pos);
    assert(circle.position == pos*2);
    circle.move(5, 2);
    assert(circle.position == Vector2f(45, 62));

    float angle = 90;
    circle.rotation = angle;
    assert(circle.rotation == angle);
    circle.rotate(angle);
    assert(circle.rotation == 2*angle);

    Color g = Color.Green;
    circle.fillColor = g;
    assert(circle.fillColor == g);

    Color r = Color.Red;
    circle.outlineColor = r;
    assert(circle.outlineColor == r);

    Vector2f or = Vector2f(3, 4);
    assert(circle.origin == Vector2f(0, 0)); // Default value
    circle.origin = or;
    assert(circle.origin == or);

    // diameter = 20
    assert(circle.localBounds == FloatRect(0, 0, 20, 20));
    // = pos - diameter + origin = (28, 46)
    assert(circle.globalBounds == FloatRect(28, 46, 20, 20));

    Transform t = circle.transform();
    Transform it = circle.inverseTransform();
    //TODO:
    // assert(t == Transform());
    assert(t.inverse == it);

    assert(circle.getPoint(0) == Vector2f(10, 0));
    assert(circle.getPoint(15) == Vector2f(20, 10));
    assert(circle.getPoint(30) == Vector2f(10, 20));

    // Y equals 10.000001907 but that should be 10.
    assert(circle.getPoint(45) == Vector2f(0, 10.000001907));

    circle.scale(10, 20);
    assert(circle.scale == Vector2f(10, 20));

    float ct = 20;
    circle.outlineThickness = ct;
    assert(circle.outlineThickness == ct);

    Texture tex = new Texture();
    tex.create(10, 20);
    circle.texture = tex;
    const Texture tex2 = circle.texture;
    assert(tex2 !is null);
    assert(tex.size == tex2.size);
    // tex2 is const but tex not
    assert(tex2 != tex);

    IntRect ir = IntRect(2, 3, 5, 8);
    circle.textureRect = ir;
    assert(circle.textureRect == ir);
}
