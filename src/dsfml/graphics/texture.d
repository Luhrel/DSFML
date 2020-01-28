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
 * `Texture` stores pixels that can be drawn, with a sprite for example. A
 * texture lives in the graphics card memory, therefore it is very fast to draw
 * a texture to a render target, or copy a render target to a texture (the
 * graphics card can access both directly).
 *
 * Being stored in the graphics card memory has some drawbacks. A texture cannot
 * be manipulated as freely as a $(IMAGE_LINK), you need to prepare the pixels
 * first and then upload them to the texture in a single operation (see
 * `Texture.update`).
 *
 * `Texture` makes it easy to convert from/to Image, but keep in mind that
 * these calls require transfers between the graphics card and the central
 * memory, therefore they are slow operations.
 *
 * A texture can be loaded from an image, but also directly from a
 * file/memory/stream. The necessary shortcuts are defined so that you don't
 * need an image first for the most common cases. However, if you want to
 * perform some modifications on the pixels before creating the final texture,
 * you can load your file to a $(IMAGE_LINK), do whatever you need with the
 * pixels, and then call `Texture.loadFromImage`.
 *
 * Since they live in the graphics card memory, the pixels of a texture cannot
 * be accessed without a slow copy first. And they cannot be accessed
 * individually. Therefore, if you need to read the texture's pixels (like for
 * pixel-perfect collisions), it is recommended to store the collision
 * information separately, for example in an array of booleans.
 *
 * Like $(IMAGE_LINK), `Texture` can handle a unique internal representation
 * of pixels, which is RGBA 32 bits. This means that a pixel must be composed of
 * 8 bits red, green, blue and alpha channels – just like a $(COLOR_LINK).
 *
 * Example:
 * ---
 * // This example shows the most common use of Texture:
 * // drawing a sprite
 *
 * // Load a texture from a file
 * auto texture = new Texture();
 * if (!texture.loadFromFile("texture.png"))
 *     return -1;
 *
 * // Assign it to a sprite
 * auto sprite = new Sprite();
 * sprite.setTexture(texture);
 *
 * // Draw the textured sprite
 * window.draw(sprite);
 * ---
 *
 * ---
 * // This example shows another common use of Texture:
 * // streaming real-time data, like video frames
 *
 * // Create an empty texture
 * auto texture = new Texture();
 * if (!texture.create(640, 480))
 *     return -1;
 *
 * // Create a sprite that will display the texture
 * auto sprite = new Sprite(texture);
 *
 * while (...) // the main loop
 * {
 *     ...
 *
 *     // update the texture
 *
 *     // get a fresh chunk of pixels (the next frame of a movie, for example)
 *     ubyte[] pixels = ...;
 *     texture.update(pixels);
 *
 *     // draw it
 *     window.draw(sprite);
 *
 *     ...
 * }
 *
 * ---
 *
 * Like $(SHADER_LINK) that can be used as a raw OpenGL shader,
 * `Texture` can also be used directly as a raw texture for custom OpenGL
 * geometry.
 * ---
 * Texture.bind(texture);
 * ... render OpenGL geometry ...
 * Texture.bind(null);
 * ---
 *
 * See_Also:
 *      $(SPRITE_LINK), $(IMAGE_LINK), $(RENDERTEXTURE_LINK)
 */
module dsfml.graphics.texture;

import dsfml.graphics.rect;
import dsfml.graphics.image;
import dsfml.graphics.renderwindow;

import dsfml.window.window;

import dsfml.system.inputstream;
import dsfml.system.vector2;

import std.string;

/**
 * Image living on the graphics card that can be used for drawing.
 */
class Texture
{
    private sfTexture* m_texture;

    /// Types of texture coordinates that can be used for rendering.
    enum CoordinateType
    {
        /// Texture coordinates in range [0 .. 1].
        Normalized,
        /// Texture coordinates in range [0 .. size].
        Pixels
    }

    alias CoordinateType this;

    /**
     * Default constructor
     *
     * Creates an empty texture.
     */
    @safe
    this()
    {
        // Nothing to do.
    }

    // Copy constructor.
    @nogc @safe
    package this(const sfTexture* texturePointer)
    {
        m_texture = sfTexture_copy(texturePointer);
    }

    /// Destructor.
    @nogc @safe
    ~this()
    {
        sfTexture_destroy(m_texture);
    }

    /**
     * Load the texture from a file on disk.
     *
     * This function is a shortcut for the following code:
     * ---
     * Image image;
     * image.loadFromFile(filename);
     * texture.loadFromImage(image, area);
     * ---
     *
     * The area argument can be used to load only a sub-rectangle of the whole
     * image. If you want the entire image then leave the default value (which
     * is an empty IntRect). If the area rectangle crosses the bounds of the
     * image, it is adjusted to fit the image size.
     *
     * The maximum size for a texture depends on the graphics driver and can be
     * retrieved with the `maximumSize` function.
     *
     * If this function fails, the texture is left unchanged.
     *
     * Params:
     *      filename = Path of the image file to load
     *      area     = Area of the image to load
     *
     * Returns:
     *      true if loading was successful, false otherwise.
     *
     * See_Also:
     *      loadFromMemory, loadFromStream, loadFromImage
     */
    bool loadFromFile(string filename, IntRect area = IntRect.init)
    {
        m_texture = sfTexture_createFromFile(filename.toStringz, &area);
        return m_texture != null;
    }

    /**
     * Load the texture from a file in memory.
     *
     * This function is a shortcut for the following code:
     * ---
     * Image image;
     * image.loadFromMemory(data);
     * texture.loadFromImage(image, area);
     * ---
     * The area argument can be used to load only a sub-rectangle of the whole
     * image. If you want the entire image then leave the default value (which
     * is an empty IntRect). If the area rectangle crosses the bounds of the
     * image, it is adjusted to fit the image size.
     *
     * The maximum size for a texture depends on the graphics driver and can be
     * retrieved with the `maximumSize` function.
     *
     * If this function fails, the texture is left unchanged.
     *
     * Params:
     *      data = Image in memory
     *      area = Area of the image to load
     *
     * Returns:
     *      true if loading was successful, false otherwise.
     */
    @nogc
    bool loadFromMemory(const(void)[] data, IntRect area = IntRect.init)
    {
        m_texture = sfTexture_createFromMemory(data.ptr, data.sizeof, &area);
        return m_texture != null;
    }

    /**
     * Load the texture from a custom stream.
     *
     * This function is a shortcut for the following code:
     * ---
     * Image image;
     * image.loadFromStream(stream);
     * texture.loadFromImage(image, area);
     * ---
     * The area argument can be used to load only a sub-rectangle of the whole
     * image. If you want the entire image then leave the default value (which
     * is an empty IntRect). If the area rectangle crosses the bounds of the
     * image, it is adjusted to fit the image size.
     *
     * The maximum size for a texture depends on the graphics driver and can be
     * retrieved with the `maximumSize` function.
     *
     * If this function fails, the texture is left unchanged.
     *
     * Params:
     *      stream = Source stream to read from
     *      area   = Area of the image to load
     *
     * Returns:
     *      true if loading was successful, false otherwise.
     */
    @nogc
    bool loadFromStream(InputStream stream, IntRect area = IntRect.init)
    {
        m_texture = sfTexture_createFromStream(stream.ptr, &area);
        return m_texture != null;
    }

    /**
     * Load the texture from an image.
     *
     * The area argument can be used to load only a sub-rectangle of the whole
     * image. If you want the entire image then leave the default value (which
     * is an empty IntRect). If the area rectangle crosses the bounds of the
     * image, it is adjusted to fit the image size.
     *
     * The maximum size for a texture depends on the graphics driver and can be
     * retrieved with the `maximumSize` function.
     *
     * If this function fails, the texture is left unchanged.
     *
     * Params:
     *      image = Image to load into the texture
     *      area  = Area of the image to load
     *
     * Returns:
     *      true if loading was successful, false otherwise.
     */
    @nogc
    bool loadFromImage(Image image, IntRect area = IntRect.init)
    {
        m_texture = sfTexture_createFromImage(image.ptr, &area);
        return m_texture != null;
    }

    /**
     * Get the maximum texture size allowed.
     *
     * This Maximum size is defined by the graphics driver. You can expect a
     * value of 512 pixels for low-end graphics card, and up to 8192 pixels or
     * more for newer hardware.
     *
     * Returns:
     *      Maximum size allowed for textures, in pixels.
     */
    @property @nogc @safe
    static uint maximumSize()
    {
        return sfTexture_getMaximumSize();
    }

    /**
     * Return the size of the texture.
     *
     * Returns:
     *      Size in pixels.
     */
    @property @nogc @safe
    Vector2u size() const
    {
        if (m_texture is null)
            return Vector2u(0, 0);
        return sfTexture_getSize(m_texture);
    }

    @property
    {
        /**
         * Enable or disable the smooth filter.
         *
         * When the filter is activated, the texture appears smoother so that pixels
         * are less noticeable. However if you want the texture to look exactly the
         * same as its source file, you should leave it disabled. The smooth filter
         * is disabled by default.
         *
         * Params:
         *      _smooth = true to enable smoothing, false to disable it
         */
        @nogc @safe
        void smooth(bool _smooth)
        {
            if (m_texture !is null)
                sfTexture_setSmooth(m_texture, _smooth);
        }


        /**
         * Tell whether the smooth filter is enabled or not.
         *
         * Returns:
         *      true if something is enabled, false if it is disabled.
         */
        @nogc @safe
        bool smooth() const
        {
            if (m_texture is null)
                return false;
            return sfTexture_isSmooth(m_texture);
        }
    }

    @property
    {
        /**
         * Enable or disable repeating.
         *
         * Repeating is involved when using texture coordinates outside the texture
         * rectangle [0, 0, width, height]. In this case, if repeat mode is enabled,
         * the whole texture will be repeated as many times as needed to reach the
         * coordinate (for example, if the X texture coordinate is 3 * width, the
         * texture will be repeated 3 times).
         *
         * If repeat mode is disabled, the "extra space" will instead be filled with
         * border pixels. **Warning:** on very old graphics cards, white pixels may
         * appear when the texture is repeated. With such cards, repeat mode can be
         * used reliably only if the texture has power-of-two dimensions
         * (such as 256x128). Repeating is disabled by default.
         *
         * Params:
         *      _repeated = true to repeat the texture, false to disable repeating
         */
        @nogc @safe
        void repeated(bool _repeated)
        {
            if (m_texture !is null)
                sfTexture_setRepeated(m_texture, _repeated);
        }

        /**
         * Tell whether the texture is repeated or not.
         *
         * Returns:
         *      true if repeat mode is enabled, false if it is disabled.
         */
        @nogc @safe
        bool repeated() const
        {
            if (m_texture is null)
                return false;
            return sfTexture_isRepeated(m_texture);
        }
    }

    /**
     * Bind a texture for rendering.
     *
     * This function is not part of the graphics API, it mustn't be used when
     * drawing DSFML entities. It must be used only if you mix Texture with
     * OpenGL code.
     *
     * ---
     * Texture t1, t2;
     * ...
     * Texture.bind(t1);
     * // draw OpenGL stuff that use t1...
     * Texture.bind(t2);
     * // draw OpenGL stuff that use t2...
     * Texture.bind(null);
     * // draw OpenGL stuff that use no texture...
     * ---
     *
     * Params:
     *      texture = The texture to bind. Can be null to use no texture
     */
    // TODO: CoordinateType arg + desc update
    // Actually not implemented in CSFML
    @nogc @safe
    static void bind(ref Texture texture)
    {
        sfTexture_bind(texture.ptr);
    }

    /**
     * Create the texture.
     *
     * If this function fails, the texture is left unchanged.
     *
     * Params:
     *      width  = Width of the texture
     *      height = Height of the texture
     *
     * Returns:
     *      true if creation was successful, false otherwise.
     */
    @nogc @safe
    bool create(uint width, uint height)
    {
        m_texture = sfTexture_create(width, height);
        return m_texture != null;
    }

    /**
     * Copy the texture pixels to an image.
     *
     * This function performs a slow operation that downloads the texture's
     * pixels from the graphics card and copies them to a new image, potentially
     * applying transformations to pixels if necessary (texture may be padded or
     * flipped).
     *
     * Returns:
     *      Image containing the texture's pixels.
     *
     * See_Also:
     *      loadFromImage
     */
    @safe
    Image copyToImage() const
    {
        if (m_texture is null)
            return null;
        return new Image(sfTexture_copyToImage(m_texture));
    }

    /**
     * Generate a mipmap using the current texture data.
     *
     * Mipmaps are pre-computed chains of optimized textures. Each level of texture
     * in a mipmap is generated by halving each of the previous level's dimensions.
     * This is done until the final level has the size of 1x1. The textures
     * generated in this process may make use of more advanced filters which might
     * improve the visual quality of textures when they are applied to objects much
     * smaller than they are. This is known as minification. Because fewer texels
     * (texture elements) have to be sampled from when heavily minified, usage of
     * mipmaps can also improve rendering performance in certain scenarios.
     *
     * Mipmap generation relies on the necessary OpenGL extension being available.
     * If it is unavailable or generation fails due to another reason, this function
     * will return false. Mipmap data is only valid from the time it is generated
     * until the next time the base level image is modified, at which point this
     * function will have to be called again to regenerate it.
     *
     * Returns:
     *      true if mipmap generation was successful, false if unsuccessful
     */
    @nogc @safe
    bool generateMipmap()
    {
        if (m_texture is null)
            return false;
        return sfTexture_generateMipmap(m_texture);
    }

    /**
     * Get the underlying OpenGL handle of the texture.
     *
     * You shouldn't need to use this function, unless you have very specific stuff
     * to implement that SFML doesn't support, or implement a temporary workaround
     * until a bug is fixed.
     *
     * Returns:
     *      OpenGL handle of the texture or 0 if not yet created
     */
    @property @nogc @safe
    uint nativeHandle() const
    {
        if (m_texture is null)
            return 0;
        return sfTexture_getNativeHandle(m_texture);
    }

    @property
    {
        /**
         * Tell whether the texture source is converted from sRGB or not.
         *
         * Returns:
         *      true if the texture source is converted from sRGB, false if not
         */
        @nogc @safe
        bool srgb()
        {
            if (m_texture is null)
                return false;
            return sfTexture_isSrgb(m_texture);
        }

        /**
         * Enable or disable conversion from sRGB.
         *
         * When providing texture data from an image file or memory, it can either
         * be stored in a linear color space or an sRGB color space. Most digital
         * images account for gamma correction already, so they would need to be
         * "uncorrected" back to linear color space before being processed by the
         * hardware. The hardware can automatically convert it from the sRGB color
         * space to a linear color space when it gets sampled. When the rendered
         * image gets output to the final framebuffer, it gets converted back to
         * sRGB.
         *
         * After enabling or disabling sRGB conversion, make sure to reload the
         * texture data in order for the setting to take effect.
         *
         * This option is only useful in conjunction with an sRGB capable
         * framebuffer. This can be requested during window creation.
         *
         * Params:
         *      sRGB = true to enable sRGB conversion, false to disable it
         */
        @nogc @safe
        void srgb(bool sRGB)
        {
            if (m_texture !is null)
                sfTexture_setSrgb(m_texture, sRGB ? 1 : 0);
        }
    }

    /**
     * Swap the contents of this texture with those of another.
     *
     * Params:
     *      right = Instance to swap with
     */
    @nogc @safe
    void swap(Texture right)
    {
        if (m_texture !is null && right.ptr !is null)
            sfTexture_swap(m_texture, right.ptr);
    }

    /**
     * Update part of the texture from an array of pixels.
     *
     * The size of the pixel array must match the width and height arguments,
     * and it must contain 32-bits RGBA pixels.
     *
     * No additional check is performed on the size of the pixel array or the
     * bounds of the area to update, passing invalid arguments will lead to an
     * undefined behaviour.
     *
     * This function does nothing if pixels is empty or if the texture was not
     * previously created.
     *
     * Params:
     *      pixels = Array of pixels to copy to the texture.
     *      width  = Width of the pixel region contained in pixels
     *      height = Height of the pixel region contained in pixels
     *      x      = X offset in the texture where to copy the source pixels
     *      y      = Y offset in the texture where to copy the source pixels
     */
    @nogc
    void update(const(ubyte)[] pixels, uint width = size.x,
        uint height = size.y, uint x = 0, uint y = 0)
    {
        if (m_texture !is null)
            sfTexture_updateFromPixels(m_texture, pixels.ptr, width, height, x, y);
    }

    /*
     * Update a part of this texture from another texture.
     *
     * No additional check is performed on the size of the texture, passing an
     * invalid combination of texture size and offset will lead to an undefined
     * behavior.
     *
     * This function does nothing if either texture was not previously created.
     *
     * Params:
     *      texture = Source texture to copy to this texture
     *      x       = X offset in this texture where to copy the source texture
     *      y       = Y offset in this texture where to copy the source texture
     */
    @nogc @safe
    void update(Texture texture, uint x = 0, uint y = 0)
    {
        if (m_texture !is null)
            sfTexture_updateFromTexture(m_texture, texture.ptr, x, y);
    }

    /**
     * Update the texture from an image.
     *
     * No additional check is performed on the size of the image, passing an
     * invalid combination of image size and offset will lead to an undefined
     * behavior.
     *
     * This function does nothing if the texture was not previously created.
     *
     * Params:
     *      image = Image to copy to the texture.
     *      y     = Y offset in the texture where to copy the source image.
     *      x     = X offset in the texture where to copy the source image.
     */
    @nogc @safe
    void update(Image image, uint x = 0, uint y = 0)
    {
        if (m_texture !is null)
            sfTexture_updateFromImage(m_texture, image.ptr, x, y);
    }

    /**
     * Update a part of the texture from the contents of a window.
     *
     * No additional check is performed on the size of the window, passing an
     * invalid combination of window size and offset will lead to an undefined
     * behavior.
     *
     * This function does nothing if either the texture or the window was not
     * previously created.
     *
     * Params:
     *       window = Window to copy to the texture
     *       x      = X offset in the texture where to copy the source window
     *       y      = Y offset in the texture where to copy the source window
     *
     */
    @nogc @safe
    void update(Window window, uint x = 0, uint y = 0)
    {
        if (m_texture !is null)
            sfTexture_updateFromWindow(m_texture, window.ptr, x, y);
    }

    /**
     * Update a part of the texture from the contents of a window.
     *
     * No additional check is performed on the size of the window, passing an
     * invalid combination of window size and offset will lead to an undefined
     * behavior.
     *
     * This function does nothing if either the texture or the window was not
     * previously created.
     *
     * Params:
     *      window = Window to copy to the texture
     *      x      = X offset in the texture where to copy the source window
     *      y      = Y offset in the texture where to copy the source window
     *
     */
    @nogc @safe
    void update(RenderWindow window, uint x = 0, uint y = 0)
    {
        if (m_texture !is null)
            sfTexture_updateFromRenderWindow(m_texture, window.ptr, x, y);
    }

    /// Duplicates this Texture.
    @property @safe
    Texture dup() const
    {
        return new Texture(m_texture);
    }

    // Returns the C pointer.
    @property @nogc @safe
    package sfTexture* ptr()
    {
        return m_texture;
    }
}

package extern(C)
{
    struct sfTexture;
}

@nogc @safe
private extern(C)
{
    sfTexture* sfTexture_create(uint width, uint height);
    sfTexture* sfTexture_createFromFile(const char* filename, const IntRect* area);
    sfTexture* sfTexture_createFromMemory(const void* data, size_t sizeInBytes, const IntRect* area);
    sfTexture* sfTexture_createFromStream(sfInputStream* stream, const IntRect* area);
    sfTexture* sfTexture_createFromImage(const sfImage* image, const IntRect* area);
    sfTexture* sfTexture_copy(const sfTexture* texture);
    void sfTexture_destroy(sfTexture* texture);
    Vector2u sfTexture_getSize(const sfTexture* texture);
    sfImage* sfTexture_copyToImage(const sfTexture* texture);
    void sfTexture_updateFromPixels(sfTexture* texture, const ubyte* pixels, uint width, uint height, uint x, uint y);
    void sfTexture_updateFromTexture(sfTexture* destination, const sfTexture* texture, uint x, uint y);
    void sfTexture_updateFromImage(sfTexture* texture, const sfImage* image, uint x, uint y);
    void sfTexture_updateFromWindow(sfTexture* texture, const sfWindow* window, uint x, uint y);
    void sfTexture_updateFromRenderWindow(sfTexture* texture, const sfRenderWindow* renderWindow, uint x, uint y);
    void sfTexture_setSmooth(sfTexture* texture, bool smooth);
    bool sfTexture_isSmooth(const sfTexture* texture);
    void sfTexture_setSrgb(sfTexture* texture, byte sRgb);
    bool sfTexture_isSrgb(const sfTexture* texture);
    void sfTexture_setRepeated(sfTexture* texture, bool repeated);
    bool sfTexture_isRepeated(const sfTexture* texture);
    bool sfTexture_generateMipmap(sfTexture* texture);
    void sfTexture_swap(sfTexture* left, sfTexture* right);
    uint sfTexture_getNativeHandle(const sfTexture* texture);
    void sfTexture_bind(const sfTexture* texture);
    uint sfTexture_getMaximumSize();
}

unittest
{
    import std.stdio;
    writeln("Running Texture unittest...");

    Texture t = new Texture();

    int width = 20;
    int height = 20;
    assert(t.create(width, height));
    assert(t.size == Vector2u(width, height));

    bool smo = true;
    t.smooth = smo;
    assert(t.smooth == smo);

    bool rgb = true;
    t.srgb = rgb;
    assert(t.srgb == rgb);

    bool r = true;
    t.repeated = r;
    assert(t.repeated == r);

    assert(t.generateMipmap());

    version (DSFML_Unittest_with_interaction)
    {
        int nh = t.nativeHandle();
        writefln("\tOpenGL native handle: %s", nh);
        int ms = t.maximumSize();
        writefln("\tmaximum size supported by the graphic card: %s", ms);
    }
    Texture t2 = new Texture();
    t.swap(t2);

    Texture emptyTex = new Texture();
    // ... or whatever function
    emptyTex.smooth; // Shouldn't crash

    // TODO: bind()
    // TODO: update()
    // TODO: copyToImage
    // TODO: loadFromX
}
