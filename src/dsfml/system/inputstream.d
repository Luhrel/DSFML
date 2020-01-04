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
* This interface allows users to define their own file input sources from which
* DSFML can load resources.
*
* DSFML resource classes like $(TEXTURE_LINK) and $(SOUNDBUFFER_LINK) provide
* `loadFromFile` and `loadFromMemory` functions, which read data from
* conventional sources. However, if you have data coming from a different source
* (over a network, embedded, encrypted, compressed, etc) you can derive your own
* class from $(U InputStream) and load DSFML resources with their
* `loadFromStream` function.
*
* Usage example:
* ---
* // custom stream class that reads from inside a zip file
* class ZipStream : InputStream
* {
* public:
*
*     ZipStream(string archive);
*
*     bool open(string filename);
*
*     long read(void[] data);
*
*     long seek(long position);
*
*     long tell();
*
*     long getSize();
*
* private:
*
*     ...
* };
*
* // now you can load textures...
* auto texture = new Texture();
* auto stream = new ZipStream("resources.zip");
* stream.open("images/img.png");
* texture.loadFromStream(stream);
*
* // musics...
* auto music = new Music();
* auto stream = new ZipStream("resources.zip");
* stream.open("musics/msc.ogg");
* music.openFromStream(stream);
*
* // etc.
* ---
*/
module dsfml.system.inputstream;

/**
 * Abstract class for custom file input streams.
 */
abstract class InputStream
{
    private sfInputStream* m_inputstream;

    this()
    {
        m_inputstream.read = &readCallback;
        m_inputstream.seek = &seekCallback;
        m_inputstream.tell = &tellCallback;
        m_inputstream.getSize = &getSizeCallback;
        m_inputstream.userData = cast(void*) this;
    }

    /**
     * Read data from the stream.
     *
     * Params:
      *     data =    Buffer where to copy the read data
      *             and sized to the amount of bytes to be read
      *
      * Returns: The number of bytes actually read, or -1 on error.
     */
    long read(void[] data);

    /**
     * Change the current reading position.
     * Params:
     *         position = The position to seek to, from the beginning
     *
     * Returns: The position actually sought to, or -1 on error.
     */
    long seek(long position);

    /**
     * Get the current reading position in the stream.
     *
     * Returns: The current position, or -1 on error.
     */
    long tell();

    /**
     * Return the size of the stream.
     *
     * Returns: Total number of bytes available in the stream, or -1 on error.
     */
    long size();

    /**
     * C Callback for the read function.
     */
    private extern(C) static long readCallback(void* data, long size, void* userData)
    {
        void[] data_array = data[0..size];
        InputStream inputstream = cast(InputStream) userData;
        return inputstream.read(data_array);
    }

    /**
     * C Callback for the seek function.
     */
    private extern(C) static long seekCallback(long position, void* userData)
    {
        InputStream inputstream = cast(InputStream) userData;
        return inputstream.seek(position);
    }

    /**
     * C Callback for the tell function.
     */
    private extern(C) static long tellCallback(void* userData)
    {
        InputStream inputstream = cast(InputStream) userData;
        return inputstream.tell();
    }

    /**
     * C Callback for the getSize function.
     */
    private extern(C) static long getSizeCallback(void* userData)
    {
        InputStream inputstream = cast(InputStream) userData;
        return inputstream.size();
    }

    // Returns the C pointer.
    package(dsfml) sfInputStream* ptr()
    {
        return m_inputstream;
    }
}

package(dsfml) extern(C)
{
    struct sfInputStream
    {
        sfInputStreamReadFunc    read;
        sfInputStreamSeekFunc    seek;
        sfInputStreamTellFunc    tell;
        sfInputStreamGetSizeFunc getSize;
        void*                    userData;
    }
}

private extern(C)
{
    alias sfInputStreamReadFunc = long function(void* data, long size, void* userData);
    alias sfInputStreamSeekFunc = long function(long position, void* userData);
    alias sfInputStreamTellFunc = long function(void* userData);
    alias sfInputStreamGetSizeFunc = long function(void* userData);
}
