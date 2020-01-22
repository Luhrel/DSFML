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
 * **Warning:**
 * Features related to Cursor are not supported on iOS and Android.
 *
 * This class abstracts the operating system resources associated with either a
 * native system cursor or a custom cursor.
 *
 * After loading the cursor the graphical appearance with either
 * `loadFromPixels()` or `loadFromSystem()`, the cursor can be changed with
 * `Window.mouseCursor()`.
 *
 * The behaviour is undefined if the cursor is destroyed while in use by the window.
 *
 * Usage example:
 * ---
 * Window window;
 * // ... create window as usual ...
 * Cursor cursor;
 * if (cursor.loadFromSystem(Cursor.Hand))
 *     window.mouseCursor = cursor;
 * ---
 *
 * See_Also:
 *      $(WINDOW_LINK).mouseCursor
 */
module dsfml.window.cursor;

import dsfml.system.vector2;

/**
 * `Cursor` defines the appearance of a system cursor.
 */
class Cursor
{
    private sfCursor* m_cursor = null;

    /**
     * Default constructor.
     *
     * This constructor doesn't actually create the cursor; initially the new
     * instance is invalid and must not be used until either `loadFromPixels()`
     * or `loadFromSystem()` is called and successfully created a cursor.
    */
    this()
    {
        // Nothing to do
    }

    /**
     * Destructor.
     *
     * This destructor releases the system resources associated with this cursor, if
     * any.
     */
    ~this()
    {
        if (m_cursor != null)
            sfCursor_destroy(m_cursor);
    }

    /**
     * Create a cursor with the provided image.
     * `pixels` must be an array of width by height pixels in 32-bit RGBA format.
     * If not, this will cause undefined behavior.
     *
     * If `pixels` is null or either width or height are 0, the current cursor
     * is left unchanged and the function will return false.
     *
     * In addition to specifying the pixel data, you can also specify the location
     * of the hotspot of the cursor. The hotspot is the pixel coordinate within the
     * cursor image which will be located exactly where the mouse pointer position
     * is. Any mouse actions that are performed will return the window/screen
     * location of the hotspot.
     *
     * **Warning:**
     * On Unix, the pixels are mapped into a monochrome bitmap: pixels with an alpha
     * channel to 0 are transparent, black if the RGB channel are close to zero, and
     * white otherwise.
     *
     * Params:
     *      pixels  = Array of pixels of the image
     *      size    = Width and height of the image
     *      hotspot = (x, y) location of the hotspot
     *
     * Returns:
     *      true if the cursor was successfully loaded; false otherwise
     */
    bool loadFromPixels(ubyte[] pixels, Vector2u size, Vector2u hotspot)
    {
        m_cursor = sfCursor_createFromPixels(pixels.ptr, size, hotspot);
        return m_cursor != null;
    }

    /**
     * Create a native system cursor.
     *
     * Refer to the list of cursor available on each system (see `Cursor.Type`)
     * to know whether a given cursor is expected to load successfully or is not
     * supported by the operating system.
     *
     * Params:
     *      type = Native system cursor type
     *
     * Returns:
     *      true if and only if the corresponding cursor is natively supported
     *      by the operating system; false otherwise
     */
    bool loadFromSystem(Cursor.Type type)
    {
        m_cursor = sfCursor_createFromSystem(type);
        return m_cursor != null;
    }

    /**
     * Enumeration of the native system cursor types.
     *
     * Refer to the following table to determine which cursor is available on
     * which platform.
     * | Type                   | Linux | Mac OS X  | Windows |
     * | ---------------------: | :---- | :-------- | :------ |
     * | Arrow                  | yes   | yes       | yes     |
     * | ArrowWait              | no    | no        | yes     |
     * | Wait                   | yes   | no        | yes     |
     * | Text                   | yes   | yes       | yes     |
     * | Hand                   | yes   | yes       | yes     |
     * | SizeHorizontal         | yes   | yes       | yes     |
     * | SizeVertical           | yes   | yes       | yes     |
     * | SizeTopLeftBottomRight | no    | yes*      | yes     |
     * | SizeBottomLeftTopRight | no    | yes*      | yes     |
     * | SizeAll                | yes   | no        | yes     |
     * | Cross                  | yes   | yes       | yes     |
     * | Help                   | yes   | yes*      | yes     |
     * | NotAllowed             | yes   | yes       | yes     |
     *
     * *These cursor types are undocumented so may not be available on all
     * versions, but have been tested on 10.13
     */
    enum Type
    {
        Arrow,                  /// Arrow cursor (default)
        ArrowWait,              /// Busy arrow cursor
        Wait,                   /// Busy cursor
        Text,                   /// I-beam, cursor when hovering over a field allowing text entry
        Hand,                   /// Pointing hand cursor
        SizeHorizontal,         /// Horizontal double arrow cursor
        SizeVertical,           /// Vertical double arrow cursor
        SizeTopLeftBottomRight, /// Double arrow cursor going from top-left to bottom-right
        SizeBottomLeftTopRight, /// Double arrow cursor going from bottom-left to top-right
        SizeAll,                /// Combination of SizeHorizontal and SizeVertical
        Cross,                  /// Crosshair cursor
        Help,                   /// Help cursor
        NotAllowed              /// Action not allowed cursor
    }

    alias Type this;

    // Retuns the C pointer
    @property @nogc
    package(dsfml) sfCursor* ptr()
    {
        return m_cursor;
    }
}

package(dsfml) extern(C)
{
    struct sfCursor;
}

@nogc
private extern(C)
{
    sfCursor* sfCursor_createFromPixels(const ubyte* pixels, Vector2u size, Vector2u hotspot);
    sfCursor* sfCursor_createFromSystem(Cursor.Type type);
    void sfCursor_destroy(sfCursor* cursor);
}
