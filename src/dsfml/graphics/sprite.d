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
 * $(U Sprite) is a drawable class that allows to easily display a texture (or a
 * part of it) on a render target.
 *
 * It inherits all the functions from $(TRANSFORMABLE_LINK): position, rotation,
 * scale, origin. It also adds sprite-specific properties such as the texture to
 * use, the part of it to display, and some convenience functions to change the
 * overall color of the sprite, or to get its bounding rectangle.
 *
 * $(U Sprite) works in combination with the $(TEXTURE_LINK) class, which loads
 * and provides the pixel data of a given texture.
 *
 * The separation of $(U Sprite) and $(TEXTURE_LINK) allows more flexibility and
 * better performances: indeed a $(TEXTURE_LINK) is a heavy resource, and any
 * operation on it is slow (often too slow for real-time applications). On the
 * other side, a $(U Sprite) is a lightweight object which can use the pixel
 * data of a $(TEXTURE_LINK) and draw it with its own
 * transformation/color/blending attributes.
 *
 * It is important to note that the $(U Sprite) instance doesn't copy the
 * texture that it uses, it only keeps a reference to it. Thus, a
 * $(TEXTURE_LINK) must not be destroyed while it is used by a $(U Sprite)
 * (i.e. never write a function that uses a local Texture instance for creating
 * a sprite).
 *
 * See also the note on coordinates and undistorted rendering in
 * $(TRANSFORMABLE_LINK).
 *
 * example:
 * ---
 * // Declare and load a texture
 * auto texture = new Texture();
 * texture.loadFromFile("texture.png");
 *
 * // Create a sprite
 * auto sprite = new Sprite();
 * sprite.setTexture(texture);
 * sprite.textureRect = IntRect(10, 10, 50, 30);
 * sprite.color = Color(255, 255, 255, 200);
 * sprite.position = Vector2f(100, 25);
 *
 * // Draw it
 * window.draw(sprite);
 * ---
 *
 * See_Also:
 * $(TEXTURE_LINK), $(TRANSFORMABLE_LINK)
 */
module dsfml.graphics.sprite;

import dsfml.graphics.drawable;
import dsfml.graphics.transformable;
import dsfml.graphics.transform;
import dsfml.graphics.texture;
import dsfml.graphics.rect;
import dsfml.graphics.vertex;

import dsfml.graphics.color;
import dsfml.graphics.rendertarget;
import dsfml.graphics.renderstates;
import dsfml.graphics.primitivetype;

import dsfml.system.vector2;
//import std.typecons:Rebindable;

/**
 * Drawable representation of a texture, with its own transformations, color,
 * etc.
 */
class Sprite : Transformable, Drawable
{
    private sfSprite* m_sprite;

    /**
     * Default constructor
     *
     * Creates an empty sprite with no source texture.
     */
    this()
    {
        m_sprite = sfSprite_create();
    }

    /**
     * Construct the sprite from a source texture
     *
     * Params:
     * texture = Source texture
     * See_Also: texture
     */
    this(Texture texture)
    {
        this();
        this.texture(texture);
    }

    /**
     * Construct the sprite from a sub-rectangle of a source texture.
     *
     * Params:
     *     texture   = Source texture
     *     rectangle = Sub-rectangle of the texture to assign to the sprite
     *
     * See_Also: texture, textureRect
     */
    this(Texture texture, IntRect rectangle)
    {
        this(texture);
        textureRect = rectangle;
    }

    // Copy constructor.
    package this(const sfSprite* spritePointer)
    {
        m_sprite = sfSprite_copy(spritePointer);
    }

    /// Destructor.
    ~this()
    {
        sfSprite_destroy(m_sprite);
    }

    @property
    {
        /**
         * Set the local origin of the object
         *
         * The origin of an object defines the center point for all
         * transformations (position, scale, rotation). The coordinates of this
         * point must be relative to the top-left corner of the object, and
         * ignore all transformations (position, scale, rotation). The default
         * origin of a transformable object is (0, 0).
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
         * The origin of an object defines the center point for all
         * transformations (position, scale, rotation). The coordinates of this
         * point must be relative to the top-left corner of the object, and
         * ignore all transformations (position, scale, rotation). The default
         * origin of a transformable object is (0, 0).
         *
         * Params:
         *     origin = New origin
         */
        override void origin(Vector2f newOrigin)
        {
            sfSprite_setOrigin(m_sprite, newOrigin);
        }

        /**
         * Get the local origin of the object
         *
         * Returns: Current origin
         */
        override Vector2f origin() const
        {
            return sfSprite_getOrigin(m_sprite);
        }
    }

    @property
    {
        /**
         * Set the position of the object
         *
         * This function completely overwrites the previous position. See the
         * move function to apply an offset based on the previous position
         * instead. The default position of a transformable object is (0, 0).
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
         * This function completely overwrites the previous position. See the
         * move function to apply an offset based on the previous position
         * instead. The default position of a transformable object is (0, 0).
         *
         * Params:
         *     position = New position
         * See_Also: move
         */
        override void position(Vector2f newPosition)
        {
            sfSprite_setPosition(m_sprite, newPosition);
        }

        /**
         * Get the position of the object
         *
         * Returns: Current position
         */
        override Vector2f position() const
        {
            return sfSprite_getPosition(m_sprite);
        }
    }

    /**
     * Rotate the object.
     *
     * This function adds to the current rotation of the object, unlike the
     * rotation property which overwrites it. Thus, it is equivalent to the
     * following code:
     * ---
     * object.setRotation(object.getRotation() + angle);
     *
     * Params:
     *     angle = Angle of rotation, in degrees
     */
    override void rotate(float angle)
    {
        sfSprite_rotate(m_sprite, angle);
    }

    @property
    {
        /**
         * Set the orientation of the object
         *
         * This function completely overwrites the previous rotation. See the
         * rotate function to add an angle based on the previous rotation
         * instead. The default rotation of a transformable object is 0.
         *
         * Params:
         *     angle	New rotation, in degrees
         * See_Also: rotate
         */
        override void rotation(float angle)
        {
            sfSprite_setRotation(m_sprite, angle);
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
            return sfSprite_getRotation(m_sprite);
        }
    }

    @property
    {
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
        override void scale(float x, float y)
        {
            scale(Vector2f(x, y));
        }

        /**
         * Set the scale factors of the object
         *
         * This function completely overwrites the previous scale. See the scale
         * function to add a factor based on the previous scale instead. The
         * default scale of a transformable object is (1, 1).
         *
         * Params:
         *     factors = New scale factors
         */
        override void scale(Vector2f factors)
        {
            sfSprite_setScale(m_sprite, factors);
        }

        /**
         * Get the current scale of the object
         *
         * Returns: Current scale factors
         */
        override Vector2f scale() const
        {
            return sfSprite_getScale(m_sprite);
        }
    }

    @property
    {
        /**
         * Set the sub-rectangle of the texture that the sprite will display.
         *
         * The texture rect is useful when you don't want to display the whole
         * texture, but rather a part of it. By default, the texture rect covers
         * the entire texture.
         *
         * Params:
         *     rectangle = Rectangle defining the region of the texture to display
         * See_Also: setTexture
         */
        void textureRect(IntRect rectangle)
        {
            sfSprite_setTextureRect(m_sprite, rectangle);
        }
        /**
         * Get the sub-rectangle of the texture displayed by the sprite.
         *
         * Returns: Texture rectangle of the sprite
         */
        IntRect textureRect() const
        {
            return sfSprite_getTextureRect(m_sprite);
        }
    }

    @property
    {
        /**
         * Set the global color of the sprite.
         *
         * This color is modulated (multiplied) with the sprite's texture. It
         * can be used to colorize the sprite, or change its global opacity. By
         * default, the sprite's color is opaque white.
         *
         * Params:
         *     color = New color of the sprite
         */
        void color(Color newColor)
        {
            sfSprite_setColor(m_sprite, newColor);
        }

        /**
         * Get the global color of the sprite.
         *
         * Returns: Global color of the sprite
         */
        Color color() const
        {
            return sfSprite_getColor(m_sprite);
        }

    }

    /**
     * Move the object by a given offset.
     *
     * This function adds to the current position of the object, unlike the
     * position property which overwrites it. Thus, it is equivalent to the
     * following code:
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
     * This function adds to the current position of the object, unlike the
     * position property which overwrites it. Thus, it is equivalent to the
     * following code:
     * ---
     * object.setPosition(object.position() + offset);
     * ---
     *
     * Params:
     *     offset = Offset
     * See_Also: position
     */
    override void move(Vector2f offset)
    {
        sfSprite_move(m_sprite, offset);
    }

    /**
     * Get the global bounding rectangle of the entity.
     *
     * The returned rectangle is in global coordinates, which means that it
     * takes in account the transformations (translation, rotation, scale, ...)
     * that are applied to the entity. In other words, this function returns the
     * bounds of the sprite in the global 2D world's coordinate system.
     *
     * Returns: Global bounding rectangle of the entity.
     */
    FloatRect globalBounds() const
    {
        return sfSprite_getGlobalBounds(m_sprite);
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
    FloatRect localBounds() const
    {
        return sfSprite_getLocalBounds(m_sprite);
    }

    /**
     * Get the source texture of the sprite.
     *
     * If the sprite has no source texture, a NULL pointer is returned. The
     * returned pointer is const, which means that you can't modify the texture
     * when you retrieve it with this function.
     *
     * Returns: The sprite's texture.
     */
    Texture texture() const
    {
        return new Texture(sfSprite_getTexture(m_sprite));
    }

    /**
     * Change the source texture of the shape.
     *
     * The texture argument refers to a texture that must exist as long as the
     * sprite uses it. Indeed, the sprite doesn't store its own copy of the
     * texture, but rather keeps a pointer to the one that you passed to this
     * function. If the source texture is destroyed and the sprite tries to use
     * it, the behaviour is undefined. texture can be NULL to disable texturing.
     *
     * If resetRect is true, the TextureRect property of the sprite is
     * automatically adjusted to the size of the new texture. If it is false,
     * the texture rect is left unchanged.
     *
     * Params:
     * 	texture	  = New texture
     * 	rectReset = Should the texture rect be reset to the size of the new
     *              texture?
     * See_Also: texture, textureRect
     */
    void texture(Texture texture, bool rectReset = false)
    {
        sfSprite_setTexture(m_sprite, texture.ptr, rectReset);
    }

    /**
     * Get the combined transform of the object
     *
     * Returns: Transform combining the position/rotation/scale/origin of the object
     */
    override const(Transform) transform() const
    {
        return Transform(sfSprite_getTransform(m_sprite));
    }

    /**
     * Get the inverse of the combined transform of the object
     *
     * Returns: Inverse of the combined transformations applied to the object
     *
     * See_Also: transform
     */
    override const(Transform) inverseTransform() const
    {
        return Transform(sfSprite_getInverseTransform(m_sprite));
    }

    /**
     * Draw the sprite to a render target.
     *
     * Params:
     * 		renderTarget	= Target to draw to
     * 		renderStates	= Current render states
     */
    override void draw(RenderTarget renderTarget, RenderStates renderStates)
    {
        renderTarget.draw(this, renderStates);
    }

    /**
     * Create a new Sprite with the same data.
     *
     * Returns: A new Sprite object with the same data.
     */
    @property
    override Sprite dup() const
    {
        return new Sprite(m_sprite);
    }

    package sfSprite* ptr()
    {
        return m_sprite;
    }
}

package extern(C)
{
    struct sfSprite;
}

private extern(C)
{
    sfSprite* sfSprite_create();
    sfSprite* sfSprite_copy(const sfSprite* sprite);
    void sfSprite_destroy(sfSprite* sprite);
    void sfSprite_setPosition(sfSprite* sprite, Vector2f position);
    void sfSprite_setRotation(sfSprite* sprite, float angle);
    void sfSprite_setScale(sfSprite* sprite, Vector2f scale);
    void sfSprite_setOrigin(sfSprite* sprite, Vector2f origin);
    Vector2f sfSprite_getPosition(const sfSprite* sprite);
    float sfSprite_getRotation(const sfSprite* sprite);
    Vector2f sfSprite_getScale(const sfSprite* sprite);
    Vector2f sfSprite_getOrigin(const sfSprite* sprite);
    void sfSprite_move(sfSprite* sprite, Vector2f offset);
    void sfSprite_rotate(sfSprite* sprite, float angle);
    void sfSprite_scale(sfSprite* sprite, Vector2f factors);
    sfTransform sfSprite_getTransform(const sfSprite* sprite);
    sfTransform sfSprite_getInverseTransform(const sfSprite* sprite);
    void sfSprite_setTexture(sfSprite* sprite, const sfTexture* texture, bool resetRect);
    void sfSprite_setTextureRect(sfSprite* sprite, IntRect rectangle);
    void sfSprite_setColor(sfSprite* sprite, Color color);
    const(sfTexture)* sfSprite_getTexture(const sfSprite* sprite);
    IntRect sfSprite_getTextureRect(const sfSprite* sprite);
    Color sfSprite_getColor(const sfSprite* sprite);
    FloatRect sfSprite_getLocalBounds(const sfSprite* sprite);
    FloatRect sfSprite_getGlobalBounds(const sfSprite* sprite);
}

unittest
{
    import std.stdio;
    writeln("Running Sprite unittest...");

    // TODO
    auto sprite = new Sprite();

    auto pos = Vector2f(9.15, 10);
    sprite.position = pos;
    assert(sprite.position == pos);
    sprite.move(5.85, 1);
    assert(sprite.position == Vector2f(15, 11));

    auto rot = 180;
    sprite.rotation = rot;
    assert(sprite.rotation == rot);
    sprite.rotate(rot);
    assert(sprite.rotation == 0);

    auto scl = Vector2f(10, 20);
    sprite.scale = scl;
    assert(sprite.scale == scl);

    auto orgn = Vector2f(500, 897);
    sprite.origin = orgn;
    assert(sprite.origin == orgn);

    auto t = sprite.transform;
    auto it = sprite.inverseTransform;
    // TODO
    //assert(t == Transform());
    assert(t.inverse == it);

    //TODO:
    // sprite.texture

    auto texR = IntRect(5, 8, 1, 9);
    sprite.textureRect = texR;
    assert(sprite.textureRect == texR);

    auto clr = Color.Magenta;
    sprite.color = clr;
    assert(sprite.color == clr);

    //TODO:
    // localBounds
    // globalBounds
}
