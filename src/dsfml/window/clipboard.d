/*
 * DSFML - The Simple and Fast Multimedia Library for D
 *
 * Copyright (c) 2013 - 2019 Jeremy DeHaan (dehaan.jeremiah@gmail.com)
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
 * Clipboard provides an interface for getting and setting the contents of the
 * system clipboard.
 *
 * It is important to note that due to limitations on some operating systems,
 * setting the clipboard contents is only guaranteed to work if there is currently
 * an open window for which events are being handled.
 *
 * Usage example:
 * ---
 * // get the clipboard content as a string
 * string str = Clipboard.getString();
 * // or use it in the event loop
 * Event event;
 * while(window.pollEvent(event))
 * {
 *     if(event.type == Event.Closed)
 *         window.close();
 *     if(event.type == Event.KeyPressed)
 *     {
 *         // Using Ctrl + V to paste a string into DSFML
 *         if(event.key.control && event.key.code == Keyboard.V)
 *             str = Clipboard.getString();
 *         // Using Ctrl + C to copy a string out of DSFML
 *         if(event.key.control && event.key.code == Keyboard.C)
 *             Clipboard.setString("Hello World!");
 *     }
 * }
 * ---
 *
 * See_Also: Event
 */
module dsfml.window.clipboard;

//import std.conv;
import std.string;

/**
 * Give access to the system clipboard.
 */
struct Clipboard
{

    /**
     * Get the content of the clipboard as string data.
     *
     * This function returns the content of the clipboard as a string. If the
     * clipboard does not contain string it returns an empty string.
     *
     * Returns: Clipboard contents as a string
     */
    @property
    static const(dstring) str()
    {
        const(uint)* utf32 = sfClipboard_getUnicodeString();
        // Converts uint* to uint[] and then to dchar[]
        dstring converted = utf32[0 .. utf32.sizeof].assumeUTF;
        // Remove pending zeros
        return converted.ptr.fromStringz;
    }

    /**
     * Set the content of the clipboard as string data.
     *
     * This function sets the content of the clipboard as a string.
     *
     * Warning:
     * Due to limitations on some operating systems, setting the clipboard contents
     * is only guaranteed to work if there is currently an open window for which
     * events are being handled.
     *
     * Params:
     *         text    = String containing the data to be sent to the clipboard
     */
    @property
    static void str(dstring text)
    {
        sfClipboard_setUnicodeString(representation(text).ptr);
    }
}

private extern(C)
{
    //const(char)* sfClipboard_getString();
    const(uint)* sfClipboard_getUnicodeString();
    //void sfClipboard_setString(const char* text);
    void sfClipboard_setUnicodeString(const uint* text);
}

unittest
{
    import std.stdio;
    writeln("Running Clipboard unit test...");

    dstring myPaste = "Hello 😊 ! 🀩";
    Clipboard.str = myPaste;
    assert(Clipboard.str == myPaste);
}
