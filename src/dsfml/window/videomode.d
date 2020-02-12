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
 * A video mode is defined by a width and a height (in pixels) and a depth (in
 * bits per pixel). Video modes are used to setup windows ($(WINDOW_LINK)) at
 * creation time.
 *
 * The main usage of video modes is for fullscreen mode: indeed you must use one
 * of the valid video modes allowed by the OS (which are defined by what the
 * monitor and the graphics card support), otherwise your window creation will
 *
 * `VideoMode` provides a static function for retrieving the list of all the
 * video modes supported by the system: `getFullscreenModes()`.
 *
 * A custom video mode can also be checked directly for fullscreen compatibility
 * with its `isValid()` function.
 *
 * Additionnally, `VideoMode` provides a static function to get the mode
 * currently used by the desktop: `getDesktopMode()`. This allows to build
 * windows with the same size or pixel depth as the current resolution.
 *
 * Example:
 * ---
 * // Display the list of all the video modes available for fullscreen
 * auto modes = VideoMode.getFullscreenModes();
 * for (size_t i = 0; i < modes.length; ++i)
 * {
 *     VideoMode mode = modes[i];
 *     writeln("Mode #", i, ": ", mode.width, "x", mode.height, " - ",
 *             mode.bitsPerPixel, " bpp");
 * }
 *
 * // Create a window with the same pixel depth as the desktop
 * VideoMode desktop = VideoMode.getDesktopMode();
 * window.create(VideoMode(1024, 768, desktop.bitsPerPixel), "DSFML window");
 * ---
 */
module dsfml.window.videomode;

/**
 * VideoMode defines a video mode (width, height, bpp).
 */
struct VideoMode
{
    /// Video mode width, in pixels.
    uint width;

    /// Video mode height, in pixels.
    uint height;

    /// Video mode pixel depth, in bits per pixels.
    uint bitsPerPixel;

    /**
     * Construct the video mode with its attributes.
     *
     * Params:
     *      modeWidth        = Width in pixels
     *      modeHeight       = Height in pixels
     *      modeBitsPerPixel = Pixel depths in bits per pixel
     */
    @nogc @safe this(uint modeWidth, uint modeHeight, uint modeBitsPerPixel = 32)
    {
        width = modeWidth;
        height = modeHeight;
        bitsPerPixel = modeBitsPerPixel;
    }

    /**
     * Get the current desktop video mode.
     *
     * Returns:
     *      Current desktop video mode.
     */
    @nogc @safe static VideoMode getDesktopMode()
    {
        return sfVideoMode_getDesktopMode();
    }

    /**
     * Retrieve all the video modes supported in fullscreen mode.
     *
     * When creating a fullscreen window, the video mode is restricted to be
     * compatible with what the graphics driver and monitor support. This
     * function returns the complete list of all video modes that can be used in
     * fullscreen mode. The returned array is sorted from best to worst, so that
     * the first element will always give the best mode (higher width, height
     * and bits-per-pixel).
     *
     * Returns:
     *      Array containing all the supported fullscreen modes.
     */
    static VideoMode[] getFullscreenModes()
    {
        // stores all video modes after the first call
        static VideoMode[] videoModes;

        // if getFullscreenModes hasn't been called yet
        if (videoModes.length == 0)
        {
            size_t counts;
            const(VideoMode*) modes = sfVideoMode_getFullscreenModes(&counts);

            videoModes = modes[0 .. counts].dup;
        }
        return videoModes;
    }

    /**
     * Tell whether or not the video mode is valid.
     *
     * The validity of video modes is only relevant when using fullscreen
     * windows; otherwise any video mode can be used with no restriction.
     *
     * Returns:
     *      true if the video mode is valid for fullscreen mode.
     */
    @nogc @safe bool isValid() const
    {
        return sfVideoMode_isValid(this);
    }

    @safe string toString() const
    {
        import std.conv : text;

        return "Width: " ~ text(width) ~ "\tHeight: " ~ text(
                height) ~ "\tBits per pixel: " ~ text(bitsPerPixel);
    }
}

@nogc @safe private extern (C)
{
    VideoMode sfVideoMode_getDesktopMode();
    const(VideoMode*) sfVideoMode_getFullscreenModes(size_t* count);
    bool sfVideoMode_isValid(VideoMode mode);
}

unittest
{
    import std.stdio : writeln;

    writeln("Running VideoMode unittest...");

    VideoMode[] modes = VideoMode.getFullscreenModes();

    assert(modes.length != 0);

    //writeln("\tList of Fullscreen modes:");
    foreach (VideoMode m; modes)
    {
        //writeln("\t", m.toString());
        assert(m.isValid());
    }

    // Waiting for pull 10200
    //auto deskm = VideoMode.getDesktopMode();
    //writeln("DesktopMode:");
    //writeln(deskm.toString());
    //assert(deskm.isValid());
}
