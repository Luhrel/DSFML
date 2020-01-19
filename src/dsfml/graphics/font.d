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
 * Fonts can be loaded from a file, from memory or from a custom stream, and
 * supports the most common types of fonts. See the `loadFromFile` function for
 * the complete list of supported formats.
 *
 * Once it is loaded, a `Font` instance provides three types of information
 * about the font:
 * - Global metrics, such as the line spacing
 * - Per-glyph metrics, such as bounding box or kerning
 * - Pixel representation of glyphs
 *
 * Fonts alone are not very useful: they hold the font data but cannot make
 * anything useful of it. To do so you need to use the $(TEXT_LINK) class, which
 * is able to properly output text with several options such as character size,
 * style, color, position, rotation, etc.
 * This separation allows more flexibility and better performances: indeed a
 * `Font` is a heavy resource, and any operation on it is slow (often too
 * slow for real-time applications). On the other side, a $(TEXT_LINK) is a
 * lightweight object which can combine the glyphs data and metrics of a
 * `Font` to display any text on a render target.
 * Note that it is also possible to bind several $(TEXT_LINK) instances to the
 * same `Font`.
 *
 * It is important to note that the $(TEXT_LINK) instance doesn't copy the font
 * that it uses, it only keeps a reference to it. Thus, a `Font` must not be
 * destructed while it is used by a $(TEXT_LINK).
 *
 * Example:
 * ---
 * // Declare a new font
 * auto font = new Font();
 *
 * // Load it from a file
 * if (!font.loadFromFile("arial.ttf"))
 * {
 *     // error...
 * }
 *
 * // Create a text which uses our font
 * auto text1 = new Text();
 * text1.setFont(font);
 * text1.setCharacterSize(30);
 * text1.setStyle(Text.Style.Regular);
 *
 * // Create another text using the same font, but with different parameters
 * auto text2 = new Text();
 * text2.setFont(font);
 * text2.setCharacterSize(50);
 * text2.setStyle(Text.Style.Italic);
 * ---
 *
 * Apart from loading font files, and passing them to instances of
 * $(TEXT_LINK), you should normally not have to deal directly with this class.
 * However, it may be useful to access the font metrics or rasterized glyphs for
 * advanced usage.
 *
 * Note that if the font is a bitmap font, it is not scalable, thus not all
 * requested sizes will be available to use. This needs to be taken into
 * consideration when using $(TEXT_LINK).
 * If you need to display text of a certain size, make sure the corresponding
 * bitmap font that supports that size is used.
 *
 * See_Also:
 *      $(TEXT_LINK)
 */
module dsfml.graphics.font;

import dsfml.graphics.texture;
import dsfml.graphics.glyph;
import dsfml.system.inputstream;

import std.conv;

/**
 * Class for loading and manipulating character fonts.
 */
class Font
{
    /// Holds various information about a font.
    struct Info
    {
        /// The font family.
        const(string) family;
    }

    private sfFont* m_font;

    /**
     * Default constructor.
     *
     * Defines an empty font.
     */
    this()
    {
        // Nothing to do.
    }

    package this(const sfFont* fontPointer)
    {
        m_font = sfFont_copy(fontPointer);
    }

    /**
     * Destructor.
     *
     * Cleans up all the internal resources used by the font
     */
    ~this()
    {
        sfFont_destroy(m_font);
    }

    /**
     * Load the font from a file.
     *
     * The supported font formats are: TrueType, Type 1, CFF, OpenType, SFNT,
     * X11 PCF, Windows FNT, BDF, PFR and Type 42. Note that this function know
     * nothing about the standard fonts installed on the user's system, thus you
     * can't load them directly.
     *
     * **Warning:**
     * DSFML cannot preload all the font data in this function, so the file has
     * to remain accessible until the Font object loads a new font or is
     * destroyed.
     *
     * Params:
     *      filename = Path of the font file to load
     *
     * Returns:
     *      true if loading succeeded, false if it failed.
     *
     * See_Also:
     *      loadFromMemory, loadFromStream
     */
    bool loadFromFile(const(string) filename)
    {
        m_font = sfFont_createFromFile(filename.ptr);
        return m_font != null;
    }

    /**
     * Load the font from a file in memory.
     *
     * The supported font formats are: TrueType, Type 1, CFF, OpenType, SFNT,
     * X11 PCF, Windows FNT, BDF, PFR and Type 42.
     *
     * DSFML cannot preload all the font data in this function, so the buffer
     * pointed by data has to remain valid until the Font object loads a new
     * font or is destroyed.
     *
     * Params:
     *      data = data holding the font file
     *
     * Returns:
     *      true if loading succeeded, false if it failed.
     *
     * See_Also:
     *      loadFromFile, loadFromStream
     */
    bool loadFromMemory(const(void)[] data)
    {
        m_font = sfFont_createFromMemory(data.ptr, data.sizeof);
        return m_font != null;
    }

    /**
     * Load the font from a custom stream.
     *
     * The supported font formats are: TrueType, Type 1, CFF, OpenType, SFNT,
     * X11 PCF, Windows FNT, BDF, PFR and Type 42.
     *
     * DSFML cannot preload all the font data in this function, so the contents
     * of stream have to remain valid as long as the font is used.
     *
     * Params:
     *      stream = Source stream to read from
     *
     * Returns:
     *      true if loading succeeded, false if it failed.
     *
     * See_Also:
     *      loadFromFile, loadFromMemory
     */
    bool loadFromStream(InputStream stream)
    {
        m_font = sfFont_createFromStream(stream.ptr);
        return m_font != null;
    }

    /**
     * Get the font information.
     *
     * Returns:
     *      A structure that holds the font information
     */
    @property
    const(Info) info() const
    {
        if (m_font is null)
            return Info.init;
        return Info(sfFont_getInfo(m_font).family.to!string);
    }

    /**
     * Retrieve a glyph of the font.
     *
     * If the font is a bitmap font, not all character sizes might be available. If
     * the glyph is not available at the requested size, an empty glyph is returned.
     *
     * Be aware that using a negative value for the outline thickness will cause
     * distorted rendering
     *
     * Params:
     *      codePoint        = Unicode code point of the character ot get
     * 		characterSize    = Reference character size
     * 		bold             = Retrieve the bold version or the regular one?
     *      outlineThickness = Thickness of outline (when != 0 the glyph will not be filled)
     *
     * Returns:
     *      The glyph corresponding to codePoint and characterSize.
     */
    Glyph glyph(dchar codePoint, uint characterSize, bool bold, float outlineThickness = 0) const
    {
        if (m_font is null)
            return Glyph.init;
        return sfFont_getGlyph(m_font, cast(uint) codePoint, characterSize, bold, outlineThickness);
    }

    /**
     * Get the kerning offset of two glyphs.
     *
     * The kerning is an extra offset (negative) to apply between two glyphs
     * when rendering them, to make the pair look more "natural". For example,
     * the pair "AV" have a special kerning to make them closer than other
     * characters. Most of the glyphs pairs have a kerning offset of zero,
     * though.
     *
     * Params:
     *      first         = Unicode code point of the first character
     *      second        = Unicode code point of the second character
     *      characterSize = Reference character size
     *
     * Returns:
     *      Kerning value for first and second, in pixels.
     */
    float kerning(dchar first, dchar second, uint characterSize) const
    {
        if (m_font is null)
            return 0;
        return sfFont_getKerning(m_font, cast(uint) first, cast(uint) second, characterSize);
    }

    /**
     * Get the line spacing.
     *
     * Line spacing is the vertical offset to apply between two consecutive lines
     * of text.
     *
     * Params:
     *      characterSize = Reference character size
     *
     * Returns:
     *      Line spacing, in pixels.
     */
    float lineSpacing(uint characterSize) const
    {
        if (m_font is null)
            return 0;
        return sfFont_getLineSpacing(m_font, characterSize);
    }

    /**
     * Get the position of the underline.
     *
     * Underline position is the vertical offset to apply between the baseline
     * and the underline.
     *
     * Params:
     *      characterSize = Reference character size
     *
     * Returns:
     *      Underline position, in pixels.
     *
     * See_Also:
     *      getUnderlineThickness
     */
    float getUnderlinePosition(uint characterSize) const
    {
        if (m_font is null)
            return 0;
        return sfFont_getUnderlinePosition(m_font, characterSize);
    }

    /**
     * Get the thickness of the underline.
     *
     * Underline thickness is the vertical size of the underline.
     *
     * Params:
     *      characterSize = Reference character size
     *
     * Returns:
     *      Underline thickness, in pixels.
     *
     * See_Also:
     *      getUnderlinePosition
     */
    float getUnderlineThickness(uint characterSize) const
    {
        if (m_font is null)
            return 0;
        return sfFont_getUnderlineThickness(m_font, characterSize);
    }

    /**
     * Retrieve the texture containing the loaded glyphs of a certain size.
     *
     * The contents of the returned texture changes as more glyphs are
     * requested, thus it is not very relevant. It is mainly used internally by
     * Text.
     *
     * Params:
     *      characterSize = Reference character size
     *
     * Returns:
     *      Texture containing the glyphs of the requested size.
     */
    const(Texture) texture(uint characterSize)
    {
        if (m_font is null)
            return null;
        return new Texture(sfFont_getTexture(m_font, characterSize));
    }

    /**
     * Performs a deep copy on the font.
     *
     * Returns:
     *      The duplicated font.
     */
    @property
    Font dup() const
    {
        return new Font(m_font);
    }

    // Returns the C pointer
    package sfFont* ptr()
    {
        return m_font;
    }
}

package extern(C)
{
    struct sfFont;
    struct sfFontInfo
    {
        const(char)* family;
    }
}

private extern(C)
{
    sfFont* sfFont_createFromFile(const char* filename);
    sfFont* sfFont_createFromMemory(const void* data, size_t sizeInBytes);
    sfFont* sfFont_createFromStream(sfInputStream* stream);
    sfFont* sfFont_copy(const sfFont* font);
    void sfFont_destroy(sfFont* font);
    Glyph sfFont_getGlyph(const sfFont* font, uint codePoint, uint characterSize, bool bold, float outlineThickness);
    float sfFont_getKerning(const sfFont* font, uint first, uint second, uint characterSize);
    float sfFont_getLineSpacing(const sfFont* font, uint characterSize);
    float sfFont_getUnderlinePosition(const sfFont* font, uint characterSize);
    float sfFont_getUnderlineThickness(const sfFont* font, uint characterSize);
    const(sfTexture)* sfFont_getTexture(sfFont* font, uint characterSize);
    sfFontInfo sfFont_getInfo(const sfFont* font);
}

unittest
{
    import std.stdio;
    import dsfml.graphics.rect;

    writeln("Running Font unittest...");

    auto font = new Font();
    assert(font.loadFromFile("unittest/res/Warenhaus-Standard.ttf"));

    uint charSize = 12;

    assert(font.glyph('G', charSize, true, 2) == Glyph(7, FloatRect(0, -7, 10, 11), IntRect(1, 4, 11, 12)));
    assert(font.kerning('A', 'V', charSize) == 0);
    assert(font.lineSpacing(charSize) == 13);
    assert(font.getUnderlinePosition(charSize) == 1.734375);
    assert(font.getUnderlineThickness(charSize) == 0.578125);
    assert(font.info == Font.Info("Warenhaus Typenhebel"));

    Font fakeFont = new Font();
    // ... or whatever function
    fakeFont.lineSpacing(charSize); // Shouldn't crash


    //draw text or something

}
