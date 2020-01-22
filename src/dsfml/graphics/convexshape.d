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
 * It is important to keep in mind that a convex shape must always be... convex,
 * otherwise it may not be drawn correctly. Moreover, the points must be defined
 * in order; using a random order would result in an incorrect shape.
 *
 * Example:
 * ---
 * auto polygon = new ConvexShape();
 * polygon.pointCount = 3;
 * polygon.setPoint(0, Vector2f(0, 0));
 * polygon.setPoint(1, Vector2f(0, 10));
 * polygon.setPoint(2, Vector2f(25, 5));
 * polygon.outlineColor = Color.Red;
 * polygon.outlineThickness = 5;
 * polygon.position = Vector2f(10, 20);
 * ...
 * window.draw(polygon);
 * ---
 *
 * See_Also:
 *      $(SHAPE_LINK), $(RECTANGLESHAPE_LINK), $(CIRCLESHAPE_LINK)
 */
module dsfml.graphics.convexshape;

import dsfml.system.vector2;

import dsfml.graphics.color;
import dsfml.graphics.drawable;
import dsfml.graphics.rect;
import dsfml.graphics.rendertarget;
import dsfml.graphics.renderstates;
import dsfml.graphics.shape;
import dsfml.graphics.texture;
import dsfml.graphics.transform;
import dsfml.graphics.transformable;

/**
 * Specialized shape representing a convex polygon.
 */
class ConvexShape : Shape
{
    private sfConvexShape* m_convexShape;

    /**
     * Default constructor.
     *
     * Params:
     *      pointCount = Number of points of the polygon
     */
    this(size_t pointCount = 0)
    {
        m_convexShape = sfConvexShape_create();
        this.pointCount = pointCount;
    }

    // Copy constructor.
    package this(const sfConvexShape* convexShapePointer)
    {
        m_convexShape = sfConvexShape_copy(convexShapePointer);
    }

    /// Virtual destructor.
    ~this()
    {
        sfConvexShape_destroy(m_convexShape);
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
         *                  new texture ?
         */
        @nogc
        override void texture(Texture _texture, bool resetRect = false)
        {
            sfConvexShape_setTexture(m_convexShape, _texture.ptr, resetRect);
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
        override const(Texture) texture() const
        {
            return new Texture(sfConvexShape_getTexture(m_convexShape));
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
        @nogc
        override void textureRect(IntRect rect)
        {
            sfConvexShape_setTextureRect(m_convexShape, rect);
        }

        /**
         * Get the sub-rectangle of the texture displayed by the shape.
         *
         * Returns:
         *      Texture rectangle of the shape
         */
        @nogc
        override IntRect textureRect() const
        {
            return sfConvexShape_getTextureRect(m_convexShape);
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
        @nogc
        override void fillColor(Color color)
        {
            sfConvexShape_setFillColor(m_convexShape, color);
        }

        /**
         * Get the fill color of the shape.
         *
         * Returns:
         *      Fill color of the shape
         */
        @nogc
        override Color fillColor() const
        {
            return sfConvexShape_getFillColor(m_convexShape);
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
        @nogc
        override void outlineColor(Color color)
        {
            sfConvexShape_setOutlineColor(m_convexShape, color);
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
        @nogc
        override Color outlineColor() const
        {
            return sfConvexShape_getOutlineColor(m_convexShape);
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
        @nogc
        override void outlineThickness(float thickness)
        {
            sfConvexShape_setOutlineThickness(m_convexShape, thickness);
        }

        /**
         * Get the outline thickness of the shape.
         *
         * Returns:
         *      Outline thickness of the shape
         */
        @nogc
        override float outlineThickness() const
        {
            return sfConvexShape_getOutlineThickness(m_convexShape);
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
        @nogc
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
         *     _origin = New origin
         */
        @nogc
        override void origin(Vector2f _origin)
        {
            sfConvexShape_setOrigin(m_convexShape, _origin);
        }

        /**
         * Get the local origin of the object
         *
         * Returns:
         *      Current origin
         */
        @nogc
        override Vector2f origin() const
        {
            return sfConvexShape_getOrigin(m_convexShape);
        }
    }

    @property
    {
        /**
         * Set the number of points of the polygon.
         *
         * `count` must be greater than 2 to define a valid shape.
         *
         * Params:
         *      count = New number of points of the polygon
         */
        @nogc
        void pointCount(size_t count)
        {
            sfConvexShape_setPointCount(m_convexShape, count);
        }

        /**
         * Get the number of points of the polygon.
         *
         * Returns:
         *      Number of points of the polygon
         */
        @nogc
        override size_t pointCount() const
        {
            return sfConvexShape_getPointCount(m_convexShape);
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
        @nogc
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
        @nogc
        override void position(Vector2f _position)
        {
            sfConvexShape_setPosition(m_convexShape, _position);
        }

        /**
         * Get the position of the object
         *
         * Returns:
         *      Current position
         */
        @nogc
        override Vector2f position() const
        {
            return sfConvexShape_getPosition(m_convexShape);
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
    @nogc
    override void rotate(float angle)
    {
        sfConvexShape_rotate(m_convexShape, angle);
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
        @nogc
        override void rotation(float angle)
        {
            sfConvexShape_setRotation(m_convexShape, angle);
        }

        /**
         * Get the orientation of the object
         *
         * The rotation is always in the range [0, 360].
         *
         * Returns:
         *      Current rotation, in degrees
         */
        @nogc
        override float rotation() const
        {
            return sfConvexShape_getRotation(m_convexShape);
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
        @nogc
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
        @nogc
        override void scale(Vector2f factors)
        {
            sfConvexShape_setScale(m_convexShape, factors);
        }

        /**
         * Get the current scale of the object
         *
         * Returns:
         *      Current scale factors
         */
        @nogc
        override Vector2f scale() const
        {
            return sfConvexShape_getScale(m_convexShape);
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
    @property @nogc
    override FloatRect globalBounds() const
    {
        return sfConvexShape_getGlobalBounds(m_convexShape);
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
    @property @nogc
    override FloatRect localBounds() const
    {
        return sfConvexShape_getLocalBounds(m_convexShape);
    }

    /**
     * Get the position of a point.
     *
     * The returned point is in local coordinates, that is, the shape's
     * transforms (position, rotation, scale) are not taken into account.
     * The result is undefined if index is out of the valid range.
     *
     * Params:
     *      index = Index of the point to get, in range [0 .. pointCount() - 1]
     *
     * Returns:
     *      Position of the index-th point of the polygon
     *
     * See_Also:
     *      setPoint
     */
    @nogc
    override Vector2f getPoint(size_t index = 0) const
    {
        return sfConvexShape_getPoint(m_convexShape, index);
    }

    /**
     * Set the position of a point.
     *
     * Don't forget that the polygon must remain convex, and the points need to
     * stay ordered! `pointCount` must be changed first in order to set the total
     * number of points. The result is undefined if index is out of the valid
     * range.
     *
     * Params:
     *      index =	Index of the point to change, in range
     *              [0 .. `pointCount` - 1]
     *      point =	New position of the point
     *
     * See_Also:
     *      getPoint
     */
    @nogc
    void setPoint(size_t index, Vector2f point)
    {
        sfConvexShape_setPoint(m_convexShape, index, point);
    }

    /**
     * Overload of the slice operator (set).
     * This function simply call `point(index, vec)`.
     *
     * Example:
     * ---
     * convex[4] = Vector2f(4, 2);
     * ---
     */
    @nogc
    void opIndexAssign(Vector2f vec, size_t index)
    {
        setPoint(index, vec);
    }

    /**
     * Overload of the slice operator (set with operator).
     *
     * Example:
     * ---
     * convex[4] += Vector2f(1, 6);
     * ---
     */
    void opIndexOpAssign(string op)(Vector2f vec, size_t index)
    {
        mixin("Vector2f res = getPoint(index) " ~ op ~ " vec;");
        setPoint(index, res);
    }

    /**
     * Overload of the slice operator (set with operator).
     *
     * Example:
     * ---
     * convex[4] -= 3;
     * ---
     */
    void opIndexOpAssign(string op)(size_t num, size_t index)
    {
        mixin("Vector2f res = getPoint(index) " ~ op ~ " num;");
        setPoint(index, res);
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
     * Get the inverse of the combined transform of the object
     *
     * Returns:
     *      Inverse of the combined transformations applied to the object
     */
    @nogc
    override Transform inverseTransform() const
    {
        return Transform(sfConvexShape_getInverseTransform(m_convexShape));
    }

    /**
     * Get the combined transform of the object
     *
     * Returns:
     *      Transform combining the position/rotation/scale/origin of the object
     *
     * See_Also:
     *      inverseTransform
     */
    @nogc
    override Transform transform()
    {
        return Transform(sfConvexShape_getTransform(m_convexShape));
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
    @nogc
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
     *     offset = Offset
     */
    @nogc
    override void move(Vector2f offset)
    {
        sfConvexShape_move(m_convexShape, offset);
    }

    // Returns the C pointer.
    @property @nogc
    package sfConvexShape* ptr()
    {
        return m_convexShape;
    }

    /// Duplicates this ConvexShape.
    @property
    override ConvexShape dup()
    {
        return new ConvexShape(m_convexShape);
    }
}

package extern(C)
{
    struct sfConvexShape;
}

@nogc
private extern(C)
{
    sfConvexShape* sfConvexShape_create();
    sfConvexShape* sfConvexShape_copy(const sfConvexShape* shape);
    void sfConvexShape_destroy(sfConvexShape* shape);
    void sfConvexShape_setPosition(sfConvexShape* shape, Vector2f position);
    void sfConvexShape_setRotation(sfConvexShape* shape, float angle);
    void sfConvexShape_setScale(sfConvexShape* shape, Vector2f scale);
    void sfConvexShape_setOrigin(sfConvexShape* shape, Vector2f origin);
    Vector2f sfConvexShape_getPosition(const sfConvexShape* shape);
    float sfConvexShape_getRotation(const sfConvexShape* shape);
    Vector2f sfConvexShape_getScale(const sfConvexShape* shape);
    Vector2f sfConvexShape_getOrigin(const sfConvexShape* shape);
    void sfConvexShape_move(sfConvexShape* shape, Vector2f offset);
    void sfConvexShape_rotate(sfConvexShape* shape, float angle);
    void sfConvexShape_scale(sfConvexShape* shape, Vector2f factors);
    sfTransform sfConvexShape_getTransform(const sfConvexShape* shape);
    sfTransform sfConvexShape_getInverseTransform(const sfConvexShape* shape);
    void sfConvexShape_setTexture(sfConvexShape* shape, const sfTexture* texture, bool resetRect);
    void sfConvexShape_setTextureRect(sfConvexShape* shape, IntRect rect);
    void sfConvexShape_setFillColor(sfConvexShape* shape, Color color);
    void sfConvexShape_setOutlineColor(sfConvexShape* shape, Color color);
    void sfConvexShape_setOutlineThickness(sfConvexShape* shape, float thickness);
    const(sfTexture)* sfConvexShape_getTexture(const sfConvexShape* shape);
    IntRect sfConvexShape_getTextureRect(const sfConvexShape* shape);
    Color sfConvexShape_getFillColor(const sfConvexShape* shape);
    Color sfConvexShape_getOutlineColor(const sfConvexShape* shape);
    float sfConvexShape_getOutlineThickness(const sfConvexShape* shape);
    size_t sfConvexShape_getPointCount(const sfConvexShape* shape);
    Vector2f sfConvexShape_getPoint(const sfConvexShape* shape, size_t index);
    void sfConvexShape_setPointCount(sfConvexShape* shape, size_t count);
    void sfConvexShape_setPoint(sfConvexShape* shape, size_t index, Vector2f point);
    FloatRect sfConvexShape_getLocalBounds(const sfConvexShape* shape);
    FloatRect sfConvexShape_getGlobalBounds(const sfConvexShape* shape);
}

unittest
{
    import std.stdio;
    writeln("Running ConvexShape unittest...");

    auto convex = new ConvexShape();

    auto pos = Vector2f(54_756.12593234f, 1325.312434736234f);
    convex.position = pos;
    assert(convex.position == pos);
    convex.move(45_243.87406766, 74.687565264);
    assert(convex.position == Vector2f(100_000, 1400));

    auto rot = 60;
    convex.rotation = rot;
    assert(convex.rotation == rot);
    convex.rotate(2*rot);
    assert(convex.rotation == 3*rot);

    auto scl = Vector2f(9876.54321f, 3.141515142314);
    convex.scale = scl;
    assert(convex.scale == scl);

    auto orgn = Vector2f(2349, 87103);
    convex.origin = orgn;
    assert(convex.origin == orgn);

    Transform t = convex.transform;
    Transform it = convex.inverseTransform;
    // TODO:
    //assert(t == Transform());
    assert(t.inverse == it);

    Texture tex = new Texture();
    tex.create(50, 270);
    convex.texture = tex;
    const Texture tex2 = convex.texture;
    assert(tex2 !is null);
    assert(tex.size == tex2.size);

    IntRect ir = IntRect(90, 12, 54, 77);
    convex.textureRect = ir;
    assert(convex.textureRect == ir);

    auto fcol = Color.Green;
    convex.fillColor = fcol;
    assert(convex.fillColor == fcol);

    auto ocol = Color.Magenta;
    convex.outlineColor = ocol;
    assert(convex.outlineColor == ocol);

    float thc = 30.78;
    convex.outlineThickness = thc;
    assert(convex.outlineThickness == thc);

    int pc = 4;
    convex.pointCount = pc;
    assert(convex.pointCount == pc);

    Vector2f p0 = Vector2f(2, 3);
    convex[0] = p0;
    assert(convex[0] == p0);
    convex[0] *= 2;
    assert(convex[0] == Vector2f(4, 6));
    convex[0] += Vector2f(2, 8);
    assert(convex[0] == Vector2f(6, 14));

    assert(convex.localBounds == FloatRect(-28.291285, -12.124836, 56.582569, 26.124836));
    assert(convex.globalBounds == FloatRect(23020580, 274993.4375, 558840, 82.125));
}
