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
 * `Text` is a drawable class that allows one to easily display some text
 * with a custom style and color on a render target.
 *
 * It inherits all the functions from $(TRANSFORMABLE_LINK): `position`,
 * `rotation`, `scale`, `origin`. It also adds text-specific properties such as
 * the font to use, the character size, the font style (bold, italic,
 * underlined), the global color and the text to display of course. It also
 * provides convenience functions to calculate the graphical size of the text,
 * or to get the global position of a given character.
 *
 * `Text` works in combination with the $(FONT_LINK) class, which loads and
 * provides the glyphs (visual characters) of a given font.
 *
 * The separation of $(FONT_LINK) and `Text` allows more flexibility and
 * better performances: indeed a $(FONT_LINK) is a heavy resource, and any
 * operation on it is slow (often too slow for real-time applications). On the
 * other side, a `Text` is a lightweight object which can combine the glyphs
 * data and metrics of a $(FONT_LINK) to display any text on a render target.
 *
 * It is important to note that the `Text` instance doesn't copy the font
 * that it uses, it only keeps a reference to it. Thus, a $(FONT_LINK) must not
 * be destructed while it is used by a `Text`.
 *
 * See also the note on coordinates and undistorted rendering in
 * $(TRANSFORMABLE_LINK).
 *
 * Example:
 * ---
 * // Declare and load a font
 * auto font = new Font();
 * font.loadFromFile("arial.ttf");
 *
 * // Create a text
 * auto text = new Text("hello", font);
 * text.characterSize(30);
 * text.style(Text.Style.Bold);
 * text.color(Color.Red);
 *
 * // Draw it
 * window.draw(text);
 * ---
 *
 * See_Also:
 *      $(FONT_LINK), $(TRANSFORMABLE_LINK)
 */
module dsfml.graphics.text;

import dsfml.graphics.font;
import dsfml.graphics.color;
import dsfml.graphics.rect;
import dsfml.graphics.transform;
import dsfml.graphics.transformable;
import dsfml.graphics.drawable;
import dsfml.graphics.vertex;
import dsfml.graphics.rendertarget;
import dsfml.graphics.renderstates;

import dsfml.system.vector2;

import std.string;

/**
 * Graphical text that can be drawn to a render target.
 */
class Text : Transformable, Drawable
{
    /// Enumeration of the string drawing styles.
    enum Style
    {
        /// Regular characters, no style
        Regular = 0,
        /// Bold characters
        Bold = 1 << 0,
        /// Italic characters
        Italic = 1 << 1,
        /// Underlined characters
        Underlined = 1 << 2,
        /// Strike through characters
        StrikeThrough = 1 << 3
    }

    private sfText* m_text;

    /**
     * Default constructor
     *
     * Creates an empty text.
     */
    this()
    {
        m_text = sfText_create();
    }

    /**
     * Construct the text from a string, font and size
     *
     * Note that if the used font is a bitmap font, it is not scalable, thus not
     * all requested sizes will be available to use. This needs to be taken into
     * consideration when setting the character size. If you need to display
     * text of a certain size, make sure the corresponding bitmap font that
     * supports that size is used.
     *
     * Params:
     *      text          = Text assigned to the string
     *      font          = Font used to draw the string
     *      characterSize = Base size of characters, in pixels
     */
    this(const(dstring) text, Font font, uint characterSize = 30)
    {
        this();
        str = text;
        this.font = font;
        this.characterSize = characterSize;

    }

    // Copy constructor.
    package this(const sfText* textPointer)
    {
        m_text = sfText_copy(textPointer);
    }

    /// Destructor.
    ~this()
    {
        sfText_destroy(m_text);
    }

    @property
    {
        /**
         * Set the character size.
         *
         * The default size is 30.
         *
         * Note that if the used font is a bitmap font, it is not scalable, thus
         * not all requested sizes will be available to use. This needs to be
         * taken into consideration when setting the character size. If you need
         * to display text of a certain size, make sure the corresponding bitmap
         * font that supports that size is used.
         *
         * Params:
         *      size = New character size, in pixels
         */
        void characterSize(uint size)
        {
            sfText_setCharacterSize(m_text, size);
        }

        /**
         * Get the character size.
         *
         * Returns:
         *      Size of the characters, in pixels
         */
        uint characterSize() const
        {
            return sfText_getCharacterSize(m_text);
        }
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
     *      x = X coordinate of the new origin
     *      y = Y coordinate of the new origin
     */
    @property
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
    @property
    override void origin(Vector2f _origin)
    {
        sfText_setOrigin(m_text, _origin);
    }

    /**
     * Get the local origin of the object
     *
     * Returns:
     *      Current origin
     */
    @property
    override Vector2f origin() const
    {
        return sfText_getOrigin(m_text);
    }

    /**
     * Set the fill color of the text.
     *
     * By default, the text's fill color is opaque white. Setting the fill color
     * to a transparent color with an outline will cause the outline to be
     * displayed in the fill area of the text.
     *
     * Parameters
     *      _color = New fill color of the text
     *
     * See_Also:
     *      fillColor
     */
    @property
    deprecated("There is now fill and outline colors instead of a single global color. Use fillColor() or outlineColor() instead.")
    void color(Color _color)
    {
        sfText_setColor(m_text, _color);
    }

    /**
     * Get the fill color of the text.
     *
     * Returns:
     *      Fill color of the text
     *
     * See_Also:
     *      fillColor
     */
    @property
    deprecated("There is now fill and outline colors instead of a single global color. Use fillColor() or outlineColor() instead.")
    Color color()
    {
        return sfText_getColor(m_text);
    }

    @property
    {
        /**
         * Set the fill color of the text.
         *
         * By default, the text's fill color is opaque white. Setting the fill
         * color to a transparent color with an outline will cause the outline
         * to be displayed in the fill area of the text.
         *
         * Params:
         *      color = New fill color of the text
         */
        void fillColor(Color color)
        {
            sfText_setFillColor(m_text, color);
        }

        /**
         * Get the fill color of the text.
         *
         * Returns:
         *      Fill color of the text
         */
        Color fillColor() const
        {
            return sfText_getFillColor(m_text);
        }
    }

    @property
    {
        /**
         * Set the outline color of the text.
         *
         * By default, the text's outline color is opaque black.
         *
         * Params:
         *      color = New outline color of the text
         */
        void outlineColor(Color color)
        {
            sfText_setOutlineColor(m_text, color);
        }

        /**
         * Get the outline color of the text.
         *
         * Returns:
         *      Outline color of the text
         */
        Color outlineColor() const
        {
            return sfText_getOutlineColor(m_text);
        }
    }

    @property
    {
        /**
         * Set the thickness of the text's outline.
         *
         * By default, the outline thickness is 0.
         *
         * Be aware that using a negative value for the outline thickness will
         * cause distorted rendering.
         *
         * Params:
         *      thickness = New outline thickness, in pixels
         */
        void outlineThickness(float thickness)
        {
            sfText_setOutlineThickness(m_text, thickness);
        }

        /**
         * Get the outline thickness of the text.
         *
         * Returns:
         *      Outline thickness of the text, in pixels
         */
        float outlineThickness() const
        {
            return sfText_getOutlineThickness(m_text);
        }
    }

    @property
    {
        /**
         * Set the text's font.
         *
         * The font argument refers to a font that must exist as long as the
         * text uses it. Indeed, the text doesn't store its own copy of the
         * font, but rather keeps a pointer to the one that you passed to this
         * function. If the font is destroyed and the text tries to use it, the
         * behavior is undefined.
         *
         * Params:
         *      _font = New font
         */
        void font(Font _font)
        {
            sfText_setFont(m_text, _font.ptr);
        }

        /**
         * Get the text's font.
         *
         * If the text has no font attached, a null pointer is returned. The
         * returned pointer is const, which means that you cannot modify the
         * font when you get it from this function.
         *
         * Returns:
         *      Text's font
         */
        const(Font) font() const
        {
            return new Font(sfText_getFont(m_text));
        }
    }

    /**
     * Get the global bounding rectangle of the entity.
     *
     * The returned rectangle is in global coordinates, which means that it
     * takes in account the transformations (translation, rotation, scale, ...)
     * that are applied to the entity. In other words, this function returns the
     * bounds of the sprite in the global 2D world's coordinate system.
     *
     * Returns:
     *      Global bounding rectangle of the entity.
     */
    @property
    FloatRect globalBounds()
    {
        return sfText_getGlobalBounds(m_text);
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
    @property
    FloatRect localBounds() const
    {
        return sfText_getLocalBounds(m_text);
    }

    /**
     * Move the object by a given offset.
     *
     * This function adds to the current position of the object, unlike the
     * `position` property which overwrites it. Thus, it is equivalent to the
     * following code:
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
    override void move(float offsetX, float offsetY)
    {
        move(Vector2f(offsetX, offsetY));
    }

    /**
     * Move the object by a given offset.
     *
     * This function adds to the current position of the object, unlike the
     * `position` property which overwrites it. Thus, it is equivalent to the
     * following code:
     * ---
     * object.position(object.position() + offset);
     * ---
     *
     * Params:
     *      offset = Offset
     *
     * See_Also:
     *      position
     */
    override void move(Vector2f offset)
    {
        sfText_move(m_text, offset);
    }

    @property
    {
        /**
         * Set the text's style.
         *
         * You can pass a combination of one or more styles, for example
         * `Text.Bold | Text.Italic`.
         *
         * The default style is `Text.Regular`.
         *
         * Params:
         *      _style = New style
         */
        void style(Style _style)
        {
            sfText_setStyle(m_text, _style);
        }

        /**
         * Get the text's style.
         *
         * Returns:
         *      Text's style
         */
        Style style() const
        {
            return sfText_getStyle(m_text);
        }
    }

    @property
    {
        /**
         * Set the text's string.
         *
         * A text's string is empty by default.
         *
         * Params:
         *      text = New string
         */
        void str(dstring text)
        {
            sfText_setUnicodeString(m_text, representation(text).ptr);
        }

        /**
         * Get the text's string.
         *
         * Returns:
         *      Text's string
         */
        const(dstring) str() const
        {
            uint* utf32 = sfText_getUnicodeString(m_text);
            // Converts uint* to uint[] and then to dchar[]
            dstring converted = utf32[0 .. utf32.sizeof].assumeUTF;
            // Remove pending zeros
            return converted.ptr.fromStringz;
        }
    }

    /**
     * Draw the object to a render target.
     *
     * Params:
     *      renderTarget = Render target to draw to
     *      renderStates = Current render states
     */
    void draw(RenderTarget renderTarget, RenderStates renderStates)
    {
        renderTarget.draw(this, renderStates);
    }

    /**
     * Return the position of the index-th character.
     *
     * This function computes the visual position of a character from its index
     * in the string. The returned position is in global coordinates
     * (translation, rotation, scale and origin are applied). If index is out of
     * range, the position of the end of the string is returned.
     *
     * Params:
     *      index = Index of the character
     *
     * Returns:
     *      Position of the character.
     */
    Vector2f findCharacterPos(size_t index)
    {
        return sfText_findCharacterPos(m_text, index);
    }

    /**
     * Set the letter spacing factor.
     *
     * The default spacing between letters is defined by the font. This factor
     * doesn't directly apply to the existing spacing between each character, it
     * rather adds a fixed space between them which is calculated from the font
     * metrics and the character size. Note that factors below 1 (including
     * negative numbers) bring characters closer to each other. By default the
     * letter spacing factor is 1.
     *
     * Params:
     *      spacingFactor = New letter spacing factor
     */
    @property
    void letterSpacing(float spacingFactor)
    {
        sfText_setLetterSpacing(m_text, spacingFactor);
    }

    /**
     * Get the size of the letter spacing factor.
     *
     * Returns:
     *      Size of the letter spacing factor
     */
    @property
    float letterSpacing() const
    {
        return sfText_getLetterSpacing(m_text);
    }

    /**
     * Set the line spacing factor.
     *
     * The default spacing between lines is defined by the font. This method
     * enables you to set a factor for the spacing between lines.
     * By default the line spacing factor is 1.
     *
     * Params:
     *      spacingFactor = New line spacing factor
     */
    @property
    void lineSpacing(float spacingFactor)
    {
        sfText_setLineSpacing(m_text, spacingFactor);
    }

    /**
     * Get the size of the line spacing factor.
     *
     * Returns:
     *      Size of the line spacing factor
     */
    @property
    float lineSpacing()
    {
        return sfText_getLineSpacing(m_text);
    }

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
     * See_Also: move
     */
    @property
    override void position(float x, float y)
    {
        position(Vector2f(x, y));
    }

    /**
     * Set the position of the object
     *
     * This function completely overwrites the previous position. See the `move`
     * function to apply an offset based on the previous position instead.
     * The default position of a transformable object is (0, 0).
     *
     * Params:
     *      _position = New position
     *
     * See_Also:
     *      move
     */
    @property
    override void position(Vector2f _position)
    {
        sfText_setPosition(m_text, _position);
    }

    /**
     * Get the position of the object
     *
     * Returns:
     *      Current position
     */
    @property
    override Vector2f position() const
    {
        return sfText_getPosition(m_text);
    }

    /**
     * Rotate the object.
     *
     * This function adds to the current rotation of the object, unlike the
     * `rotation` property which overwrites it. Thus, it is equivalent to the
     * following code:
     * ---
     * object.rotation(object.rotation() + angle);
     * ---
     *
     * Params:
     *      angle = Angle of rotation, in degrees
     */
    override void rotate(float angle)
    {
        sfText_rotate(m_text, angle);
    }

    /**
     * Set the orientation of the object
     *
     * This function completely overwrites the previous rotation. See the `rotate`
     * function to add an angle based on the previous rotation instead. The
     * default rotation of a transformable object is 0.
     *
     * Params:
     *      angle = New rotation, in degrees
     */
    @property
    override void rotation(float angle)
    {
        sfText_setRotation(m_text, angle);
    }

    /**
     * Get the orientation of the object
     *
     * The rotation is always in the range [0, 360].
     *
     * Returns:
     *      Current rotation, in degrees
     */
    @property
    override float rotation() const
    {
        return sfText_getRotation(m_text);
    }

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
    @property
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
    @property
    override void scale(Vector2f factors)
    {
        sfText_setScale(m_text, factors);
    }

    /**
     * Get the current scale of the object
     *
     * Returns:
     *      Current scale factors
     */
    @property
    override Vector2f scale() const
    {
        return sfText_getScale(m_text);
    }

    /**
     * Get the combined transform of the object
     *
     * Returns:
     *      Transform combining the position/rotation/scale/origin of the object
     */
    override const(Transform) transform() const
    {
        return Transform(sfText_getTransform(m_text));
    }

    /**
     * Get the inverse of the combined transform of the object
     *
     * Returns:
     *      Inverse of the combined transformations applied to the object
     */
    override const(Transform) inverseTransform() const
    {
        return Transform(sfText_getInverseTransform(m_text));
    }

    // Returns the C pointer.
    package sfText* ptr()
    {
        return m_text;
    }

    /// Duplicates this Text.
    @property
    override Text dup()
    {
        return new Text(m_text);
    }
}

package extern(C)
{
    struct sfText;
}

private extern(C)
{
    //enum sfTextStyle;

    sfText* sfText_create();
    sfText* sfText_copy(const sfText* text);
    void sfText_destroy(sfText* text);
    void sfText_setPosition(sfText* text, Vector2f position);
    void sfText_setRotation(sfText* text, float angle);
    void sfText_setScale(sfText* text, Vector2f scale);
    void sfText_setOrigin(sfText* text, Vector2f origin);
    Vector2f sfText_getPosition(const sfText* text);
    float sfText_getRotation(const sfText* text);
    Vector2f sfText_getScale(const sfText* text);
    Vector2f sfText_getOrigin(const sfText* text);
    void sfText_move(sfText* text, Vector2f offset);
    void sfText_rotate(sfText* text, float angle);
    void sfText_scale(sfText* text, Vector2f factors);
    sfTransform sfText_getTransform(const sfText* text);
    sfTransform sfText_getInverseTransform(const sfText* text);
    void sfText_setString(sfText* text, const char* str);
    void sfText_setUnicodeString(sfText* text, const uint* str);
    void sfText_setFont(sfText* text, const sfFont* font);
    void sfText_setCharacterSize(sfText* text, uint size);
    void sfText_setLineSpacing(sfText* text, float spacingFactor);
    void sfText_setLetterSpacing(sfText* text, float spacingFactor);
    void sfText_setStyle(sfText* text, uint style);
    void sfText_setColor(sfText* text, Color color);
    void sfText_setFillColor(sfText* text, Color color);
    void sfText_setOutlineColor(sfText* text, Color color);
    void sfText_setOutlineThickness(sfText* text, float thickness);
    char* sfText_getString(const sfText* text); //const
    uint* sfText_getUnicodeString(const sfText* text); //const
    sfFont* sfText_getFont(const sfText* text); //const
    uint sfText_getCharacterSize(const sfText* text);
    float sfText_getLetterSpacing(const sfText* text);
    float sfText_getLineSpacing(const sfText* text);
    Text.Style sfText_getStyle(const sfText* text);
    Color sfText_getColor(const sfText* text);
    Color sfText_getFillColor(const sfText* text);
    Color sfText_getOutlineColor(const sfText* text);
    float sfText_getOutlineThickness(const sfText* text);
    Vector2f sfText_findCharacterPos(const sfText* text, size_t index);
    FloatRect sfText_getLocalBounds(const sfText* text);
    FloatRect sfText_getGlobalBounds(const sfText* text);
}

unittest
{
    import std.stdio;
    writeln("Running Text unittest...");

    auto font = new Font();
    font.loadFromFile("unittest/res/Warenhaus-Standard.ttf");
    dstring str = "DSFML";
    uint csize = 15;

    Text text = new Text(str, font, csize);

    assert(text.str == str);
    dstring utf32 = "å ø ∑ 😦";
    text.str = utf32;
    assert(text.str == utf32);

    assert(text.characterSize == csize);
    csize = 12;
    text.characterSize = csize;
    assert(text.characterSize == csize);

    // text.font is const
    assert(text.font != font);

    auto pos = Vector2f(20, 30);
    text.position = pos;
    assert(text.position == pos);
    text.move(30, 20);
    assert(text.position == Vector2f(50, 50));

    assert(text.findCharacterPos(1) == Vector2f(56, 50));

    float rot = 44.5;
    text.rotation = rot;
    assert(text.rotation == rot);
    text.rotate(rot);
    assert(text.rotation == 2*rot);

    auto scl = Vector2f(2, 5);
    text.scale = scl;
    assert(text.scale == scl);

    auto orgn = Vector2f(123.456, 456.789);
    text.origin = orgn;
    assert(text.origin == orgn);

    auto t = text.transform;
    auto it = text.inverseTransform;
    // TODO:
    //assert(t == Transform());
    assert(t.inverse == it);

    float ls = 10;
    text.lineSpacing = ls;
    assert(text.lineSpacing == ls);

    text.letterSpacing = ls;
    assert(text.letterSpacing == ls);

    auto style = Text.Style.Bold;
    text.style = style;
    assert(text.style == style);

    auto color = Color.Red;
    text.color = color;
    assert(text.color == color);

    text.fillColor = color;
    assert(text.color == color);

    text.outlineColor = color;
    assert(text.outlineColor == color);

    float thck = 10;
    text.outlineThickness = thck;
    assert(text.outlineThickness == thck);

    // TODO:
    //localBounds
    //globalBounds
}
