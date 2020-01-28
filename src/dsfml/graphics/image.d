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
 * `Image` is an abstraction to manipulate images as bidimensional arrays of
 * pixels. The class provides functions to load, read, write and save pixels, as
 * well as many other useful functions.
 *
 * `Image` can handle a unique internal representation of pixels, which is
 * RGBA 32 bits. This means that a pixel must be composed of 8 bits red, green,
 * blue and alpha channels – just like a $(COLOR_LINK). All the functions that
 * return an array of pixels follow this rule, and all parameters that you pass
 * to `Image` functions (such as `loadFromPixels`) must use this
 * representation as well.
 *
 * An `Image` can be copied, but it is a heavy resource and if possible you
 * should always use `const` references to pass or return them to avoid useless
 * copies.
 *
 * Example:
 * ---
 * // Load an image file from a file
 * auto background = new Image();
 * if (!background.loadFromFile("background.jpg"))
 *     return -1;
 *
 * // Create a 20x20 image filled with black color
 * auto image = new Image();
 * image.create(20, 20, Color.Black);
 *
 * // Copy image1 on image2 at position (10, 10)
 * image.copy(background, 10, 10);
 *
 * // Make the top-left pixel transparent
 * auto color = image.getPixel(0, 0);
 * color.a = 0;
 * image.setPixel(0, 0, color);
 *
 * // Save the image to a file
 * if (!image.saveToFile("result.png"))
 *     return -1;
 * ---
 *
 * See_Also:
 *      $(TEXTURE_LINK)
 */
module dsfml.graphics.image;

import dsfml.graphics.color;
import dsfml.graphics.rect;

import dsfml.system.inputstream;
import dsfml.system.vector2;
import dsfml.system.err;

import std.string;

/**
 * Class for loading, manipulating and saving images.
 */
class Image
{
    private sfImage* m_image;

    /**
     * Default constructor.
     *
     * Creates an empty image.
     */
    @nogc @safe
    this()
    {
        m_image = sfImage_create(0, 0);
    }

    // Copy constructor.
    @nogc @safe
    package this(const sfImage* image)
    {
        m_image = sfImage_copy(image);
    }

    /// Destructor.
    @nogc @safe
    ~this()
    {
        sfImage_destroy(m_image);
    }

    /**
     * Create the image and fill it with a unique color.
     *
     * Params:
     *      width  = Width of the image
     *      height = Height of the image
     *      color  = Fill color
     *
     */
    @nogc @safe
    void create(uint width, uint height, Color color = Color.init)
    {
        m_image = sfImage_createFromColor(width, height, color);
    }

    /**
     * Create the image from an array of pixels.
     *
     * The pixel array is assumed to contain 32-bits RGBA pixels, and have the
     * given width and height. If not, this is an undefined behaviour. If pixels
     * is null, an empty image is created.
     *
     * Params:
     *      width  = Width of the image
     *      height = Height of the image
     *      pixels = Array of pixels to copy to the image
     */
    @nogc
    void create(uint width, uint height, const(ubyte)[] pixels)
    {
        m_image = sfImage_createFromPixels(width, height, pixels.ptr);
    }

    /**
     * Load the image from a file on disk.
     *
     * The supported image formats are bmp, png, tga, jpg, gif, psd, hdr and
     * pic. Some format options are not supported, like progressive jpeg. If
     * this function fails, the image is left unchanged.
     *
     * Params:
     *      filename = Path of the image file to load
     *
     * Returns:
     *      true if loading succeeded, false if it failed
     *
     * See_Also:
     *      loadFromMemory, loadFromStream, saveToFile
     */
    @safe
    bool loadFromFile(string filename)
    {
        m_image = sfImage_createFromFile(filename.toStringz);
        return m_image != null;
    }

    /**
     * Load the image from a file in memory.
     *
     * The supported image formats are bmp, png, tga, jpg, gif, psd, hdr and
     * pic. Some format options are not supported, like progressive jpeg. If
     * this function fails, the image is left unchanged.
     *
     * Params:
     *      data = Data file in memory to load
     *
     * Returns:
     *      true if loading succeeded, false if it failed
     *
     * See_Also:
     *      loadFromFile, loadFromStream
     */
    @nogc
    bool loadFromMemory(const(void)[] data)
    {
        m_image = sfImage_createFromMemory(data.ptr, data.length);
        return m_image != null;
    }

    /**
     * Load the image from a custom stream.
     *
     * The supported image formats are bmp, png, tga, jpg, gif, psd, hdr and
     * pic. Some format options are not supported, like progressive jpeg. If
     * this function fails, the image is left unchanged.
     *
     * Params:
     *      stream = Source stream to read from
     *
     * Returns:
     *      true if loading succeeded, false if it failed
     *
     * See_Also:
     *      loadFromFile, loadFromMemory
     */
    @nogc @safe
    bool loadFromStream(InputStream stream)
    {
        m_image = sfImage_createFromStream(stream.ptr);
        return m_image != null;
    }

    /**
     * Get the read-only array of pixels that make up the image.
     *
     * The returned value points to an array of RGBA pixels made of 8 bits
     * integers components. The size of the array is:
     * `width * height * 4 (size().x * size().y * 4)`.
     *
     * **Warning:**
     * the returned slice may become invalid if you modify the image, so you
     * should never store it for too long.
     *
     * Returns:
     *      Read-only array of pixels that make up the image.
     */
    const(ubyte[]) pixelArray() const
    {
        int length = size.x * size.y * 4;
        if(length > 0)
            return sfImage_getPixelsPtr(m_image)[0 .. length];
        err.writeln("Trying to access the pixels of an empty image");
        return [];
    }

    /**
     * Return the size (width and height) of the image.
     *
     * Returns:
     *      Size of the image, in pixels.
     */
    @property @nogc @safe
    Vector2u size() const
    {
        return sfImage_getSize(m_image);
    }

    /**
     * Get the color of a pixel
     *
     * This function doesn't check the validity of the pixel coordinates; using
     * out-of-range values will result in an undefined behaviour.
     *
     * Params:
     *      x = X coordinate of the pixel to get
     *      y = Y coordinate of the pixel to get
     *
     * Returns:
     *      Color of the pixel at coordinates (x, y)
     */
    @nogc @safe
    Color pixel(uint x, uint y) const
    {
        return sfImage_getPixel(m_image, x, y);
    }

    /**
     * Change the color of a pixel.
     *
     * This function doesn't check the validity of the pixel coordinates, using
     * out-of-range values will result in an undefined behaviour.
     *
     * Params:
     *      x     = X coordinate of pixel to change
     *      y     = Y coordinate of pixel to change
     *      color = New color of the pixel
     */
    @nogc @safe
    void pixel(uint x, uint y, Color color)
    {
        sfImage_setPixel(m_image, x, y, color);
    }

    /**
     * Overload of the slice operator (set).
     * This function simply call `pixel(x, y, color)`.
     *
     * Example:
     * ---
     * image[2, 3] = Color.Red;
     * ---
     */
    @nogc @safe
    void opIndexAssign(Color color, uint x, uint y)
    {
        pixel(x, y, color);
    }

    /**
     * Overload of the slice operator (set with operator).
     *
     * Example:
     * ---
     * image[2, 3] += Color.Green;
     * ---
     */
    @safe
    void opIndexOpAssign(string op)(Color color, uint x, uint y)
    {
        mixin("Color res = pixel(x, y) " ~ op ~ " color;");
        pixel(x, y, res);
    }

    /**
     * Overload of the slice operator (set with operator).
     *
     * Example:
     * ---
     * image[2, 3] += 50;
     * ---
     */
    @safe
    void opIndexOpAssign(string op)(size_t num, uint x, uint y)
    {
        mixin("Color res = pixel(x, y) " ~ op ~ " num;");
        pixel(x, y, res);
    }

    /**
     * Overload of the slice operator (get).
     * This function simply call `pixel(x, y)`.
     *
     * Example:
     * ---
     * Color pixelX2Y3 = convex[2, 3];
     * ---
     */
    @nogc @safe
    Color opIndex(uint x, uint y) const
    {
        return pixel(x, y);
    }

    /**
     * Copy pixels from another image onto this one.
     *
     * This function does a slow pixel copy and should not be used intensively.
     * It can be used to prepare a complex static image from several others, but
     * if you need this kind of feature in real-time you'd better use
     * RenderTexture.
     *
     * If sourceRect is empty, the whole image is copied. If applyAlpha is set
     * to true, the transparency of source pixels is applied. If it is false,
     * the pixels are copied unchanged with their alpha value.
     *
     * Params:
     *      source     = Source image to copy
     *      destX      = X coordinate of the destination position
     *      destY      = Y coordinate of the destination position
     *      sourceRect = Sub-rectangle of the source image to copy
     *      applyAlpha = Should the copy take the source transparency into account?
     */
    @nogc @safe
    void copy(Image source, uint destX, uint destY, IntRect sourceRect = IntRect.init, bool applyAlpha = false)
    {
        sfImage_copyImage(m_image, source.ptr, destX, destY, sourceRect, applyAlpha);
    }

    /**
     * Create a transparency mask from a specified color-key.
     *
     * This function sets the alpha value of every pixel matching the given
     * color to alpha (0 by default) so that they become transparent.
     *
     * Params:
     *      color = Color to make transparent
     *      alpha = Alpha value to assign to transparent pixels
     */
    @nogc @safe
    void createMaskFromColor(Color color, ubyte alpha = 0)
    {
        sfImage_createMaskFromColor(m_image, color, alpha);
    }

    /// Flip the image horizontally (left <-> right)
    @nogc @safe
    void flipHorizontally()
    {
        sfImage_flipHorizontally(m_image);
    }

    /// Flip the image vertically (top <-> bottom)
    @nogc @safe
    void flipVertically()
    {
        sfImage_flipVertically(m_image);
    }

    /**
     * Save the image to a file on disk.
     *
     * The format of the image is automatically deduced from the extension. The
     * supported image formats are bmp, png, tga and jpg. The destination file
     * is overwritten if it already exists. This function fails if the image is
     * empty.
     *
     * Params:
     *      filename = Path of the file to save
     *
     * Returns:
     *      true if saving was successful
     *
     * See_Also:
     *      create, loadFromFile, loadFromMemory
     */
    @safe
    bool saveToFile(string filename) const
    {
        return sfImage_saveToFile(m_image, filename.toStringz);
    }

    // Returns the C pointer.
    @property @nogc @safe
    package sfImage* ptr()
    {
        return m_image;
    }

    /// Duplicates this Image.
    @property @safe
    Image dup() const
    {
        return new Image(m_image);
    }
}

package extern(C)
{
    struct sfImage;
}

@nogc @safe
private extern(C)
{
    sfImage* sfImage_create(uint width, uint height);
    sfImage* sfImage_createFromColor(uint width, uint height, Color color);
    sfImage* sfImage_createFromPixels(uint width, uint height, const ubyte* pixels);
    sfImage* sfImage_createFromFile(const char* filename);
    sfImage* sfImage_createFromMemory(const void* data, size_t size);
    sfImage* sfImage_createFromStream(sfInputStream* stream);
    sfImage* sfImage_copy(const sfImage* image);
    void sfImage_destroy(sfImage* image);
    bool sfImage_saveToFile(const sfImage* image, const char* filename);
    Vector2u sfImage_getSize(const sfImage* image);
    void sfImage_createMaskFromColor(sfImage* image, Color color, ubyte alpha);
    void sfImage_copyImage(sfImage* image, const sfImage* source, uint destX, uint destY, IntRect sourceRect, bool applyAlpha);
    void sfImage_setPixel(sfImage* image, uint x, uint y, Color color);
    Color sfImage_getPixel(const sfImage* image, uint x, uint y);
    const(ubyte*) sfImage_getPixelsPtr(const sfImage* image);
    void sfImage_flipHorizontally(sfImage* image);
    void sfImage_flipVertically(sfImage* image);
}

unittest
{
    import std.stdio;
    writeln("Running Image unittest...");

    auto image = new Image();
    assert(image.ptr !is null);

    assert(image.loadFromFile("unittest/res/TestImage.png"));
    assert(image.size == Vector2u(640, 640));

    assert(image[0, 0] == Color.Transparent);
    assert(image[218, 150] == Color.Black);
    assert(image[150, 218] == Color(217, 9, 9, 255));
    image[0, 0] = Color.Green;
    assert(image[0, 0] == Color.Green);
    image[0, 0] += 50;
    assert(image[0, 0] == Color(50, 255, 50, 255));
    image[0, 0] -= Color.Red;
    assert(image[0, 0] == Color(0, 255, 50, 0));

    const(ubyte[]) pixels = image.pixelArray();
    assert(image[0, 0] == Color(pixels[0], pixels[1], pixels[2], pixels[3]));


    auto image2 = new Image();
    image2.create(2, 2, [255, 0, 0, 255,
                         0, 255, 0, 255,
                         0, 0, 255, 255,
                         127, 127, 127, 255]);
    assert(image2[0, 0] == Color.Red);
    assert(image2[1, 0] == Color.Green);
    assert(image2[0, 1] == Color.Blue);
    assert(image2[1, 1] == Color(127, 127, 127, 255));

    image2.flipHorizontally();
    assert(image2[0, 0] == Color.Green);
    assert(image2[1, 0] == Color.Red);

    image2.flipVertically();
    assert(image2[0, 1] == Color.Green);
    assert(image2[1, 1] == Color.Red);

    image2.createMaskFromColor(Color.Red);
    assert(image2[1, 1] == Color(255, 0, 0, 0));

    image.copy(image2, 10, 10);
    assert(image[10, 10] == Color(127, 127, 127, 255));

    //TODO:
    // saveToFile
}
