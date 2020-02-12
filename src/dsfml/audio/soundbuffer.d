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
 * A sound buffer holds the data of a sound, which is an array of audio samples.
 * A sample is a 16 bits signed integer that defines the amplitude of the sound
 * at a given time. The sound is then restituted by playing these samples at a
 * high rate (for example, 44100 samples per second is the standard rate used
 * for playing CDs). In short, audio samples are like texture pixels, and a
 * SoundBuffer is similar to a Texture.
 *
 * A sound buffer can be loaded from a file (see `loadFromFile()` for the
 * complete list of supported formats), from memory, from a custom stream
 * (see $(INPUTSTREAM_LINK)) or directly from an array of samples. It can also
 * be saved back to a file.
 *
 * Sound buffers alone are not very useful: they hold the audio data but cannot
 * be played. To do so, you need to use the $(SOUND_LINK) class, which provides
 * functions to play/pause/stop the sound as well as changing the way it is
 * outputted (volume, pitch, 3D position, ...).
 *
 * This separation allows more flexibility and better performances: indeed a
 * `SoundBuffer` is a heavy resource, and any operation on it is slow (often
 * too slow for real-time applications). On the other side, a $(SOUND_LINK) is a
 * lightweight object, which can use the audio data of a sound buffer and change
 * the way it is played without actually modifying that data. Note that it is
 * also possible to bind several $(SOUND_LINK) instances to the same
 * `SoundBuffer`.
 *
 * It is important to note that the Sound instance doesn't copy the buffer that
 * it uses, it only keeps a reference to it. Thus, a `SoundBuffer` must not
 * be destructed while it is used by a Sound (i.e. never write a function that
 * uses a local `SoundBuffer` instance for loading a sound).
 *
 * Example:
 * ---
 * // Declare a new sound buffer
 * auto buffer = SoundBuffer();
 *
 * // Load it from a file
 * if (!buffer.loadFromFile("sound.wav"))
 * {
 *     // error...
 * }
 *
 * // Create a sound source and bind it to the buffer
 * auto sound1 = new Sound();
 * sound1.setBuffer(buffer);
 *
 * // Play the sound
 * sound1.play();
 *
 * // Create another sound source bound to the same buffer
 * auto sound2 = new Sound();
 * sound2.setBuffer(buffer);
 *
 * // Play it with a higher pitch -- the first sound remains unchanged
 * sound2.pitch = 2;
 * sound2.play();
 * ---
 *
 * See_Also:
 *      $(SOUND_LINK), $(SOUNDBUFFERRECORDER_LINK)
 */
module dsfml.audio.soundbuffer;

import dsfml.system.inputstream;
import dsfml.system.time;

import std.string;

/**
 * Storage for audio samples defining a sound.
 */
class SoundBuffer
{
    private sfSoundBuffer* m_soundBuffer = null;

    /// Default constructor.
    @safe this()
    {
        // Nothing to do.
    }

    // Copy constructor.
    @nogc @safe package this(const sfSoundBuffer* soundBufferPointer)
    {
        m_soundBuffer = sfSoundBuffer_copy(soundBufferPointer);
    }

    /// Destructor.
    @nogc @safe ~this()
    {
        sfSoundBuffer_destroy(m_soundBuffer);
    }

    /**
     * Get the array of audio samples stored in the buffer.
     *
     * The format of the returned samples is 16 bits signed integer (short). The
     * total number of samples in this array is given by the `sampleCount()`
     * function.
     *
     * Returns:
     *      Read-only array of sound samples.
     *
     * See_Also:
     *      sampleCount
     */
    @property const(short[]) samples() const
    {
        if (m_soundBuffer !is null)
        {
            ulong sampleCount = sfSoundBuffer_getSampleCount(m_soundBuffer);
            if (sampleCount > 0)
            {
                version (X86)
                    return sfSoundBuffer_getSamples(m_soundBuffer)[0 .. cast(uint) sampleCount];
                else
                    return sfSoundBuffer_getSamples(m_soundBuffer)[0 .. sampleCount];
            }
        }
        return null;
    }

    /**
     * Get the sample rate of the sound.
     *
     * The sample rate is the number of samples played per second. The higher,
     * the better the quality (for example, 44100 samples/s is CD quality).
     *
     * Returns:
     *      Sample rate (number of samples per second).
     *
     * See_Also:
     *      channelCount, duration
     */
    @property @nogc @safe uint sampleRate() const
    {
        if (m_soundBuffer is null)
            return 0;
        return sfSoundBuffer_getSampleRate(m_soundBuffer);
    }

    /**
     * Get the number of samples stored in the buffer.
     *
     * The array of samples can be accessed with the samples() function.
     *
     * Returns:
     *      Number of samples
     *
     * See_Also:
     *      samples
     */
    @property @nogc @safe ulong sampleCount() const
    {
        if (m_soundBuffer is null)
            return 0;
        return sfSoundBuffer_getSampleCount(m_soundBuffer);
    }

    /**
     * Get the number of channels used by the sound.
     *
     * If the sound is mono then the number of channels will be 1, 2 for stereo,
     * etc.
     *
     * Returns:
     *      Number of channels.
     *
     * See_Also:
     *      sampleRate, duration
     */
    @property @nogc @safe uint channelCount() const
    {
        if (m_soundBuffer is null)
            return 0;
        return sfSoundBuffer_getChannelCount(m_soundBuffer);
    }

    /**
     * Get the total duration of the sound.
     *
     * Returns:
     *      Sound duration.
     *
     * See_Also:
     *      sampleRate, channelCount
     */
    @property @nogc @safe Time duration() const
    {
        if (m_soundBuffer is null)
            return Time();
        return sfSoundBuffer_getDuration(m_soundBuffer);
    }

    /**
     * Load the sound buffer from a file.
     *
     * See the documentation of InputSoundFile for the list of supported formats.
     *
     * Params:
     *      filename = Path of the sound file to load
     *
     * Returns:
     *      true if loading succeeded, false if it failed.
     *
     * See_Also:
     *      loadFromMemory, loadFromStream, loadFromSamples, saveToFile
     */
    @safe bool loadFromFile(string filename)
    {
        m_soundBuffer = sfSoundBuffer_createFromFile(filename.toStringz);
        return m_soundBuffer != null;
    }

    /**
     * Load the sound buffer from a file in memory.
     *
     * See the documentation of InputSoundFile for the list of supported formats.
     *
     * Params:
     *      data = The array of data
     *
     * Returns:
     *      true if loading succeeded, false if it failed.
     *
     * See_Also:
     *      loadFromFile, loadFromStream, loadFromSamples
     */
    @nogc bool loadFromMemory(const(void)[] data)
    {
        m_soundBuffer = sfSoundBuffer_createFromMemory(data.ptr, data.sizeof);
        return m_soundBuffer != null;
    }

    /**
     * Load the sound buffer from a custom stream.
     *
     * See the documentation of InputSoundFile for the list of supported formats.
     *
     * Params:
     *      stream = Source stream to read from
     *
     * Returns:
     *      true if loading succeeded, false if it failed.
     *
     * See_Also:
     *      loadFromFile, loadFromMemory, loadFromSamples
     */
    @nogc @safe bool loadFromStream(InputStream stream)
    {
        m_soundBuffer = sfSoundBuffer_createFromStream(stream.ptr);
        return m_soundBuffer != null;
    }

    /**
     * Load the sound buffer from an array of audio samples.
     *
     * The assumed format of the audio samples is 16 bits signed integer (short).
     *
     * Params:
     *      samples      = Array of samples in memory
     *      channelCount = Number of channels (1 = mono, 2 = stereo, ...)
     *      sampleRate   = Sample rate (number of samples to play per second)
     *
     * Returns:
     *      true if loading succeeded, false if it failed.
     *
     * See_Also:
     *      loadFromFile, loadFromMemory, saveToFile
     */
    @nogc bool loadFromSamples(const(short[]) samples, uint channelCount, uint sampleRate)
    {
        m_soundBuffer = sfSoundBuffer_createFromSamples(samples.ptr,
                samples.length, channelCount, sampleRate);
        return m_soundBuffer != null;
    }

    /**
     * Save the sound buffer to an audio file.
     *
     * See the documentation of OutputSoundFile for the list of supported formats.
     *
     * Params:
     *      filename =    Path of the sound file to write
     *
     * Returns:
     *      true if saving succeeded, false if it failed.
     *
     * See_Also:
     *      loadFromFile, loadFromMemory, loadFromSamples
     */
    @safe bool saveToFile(string filename) const
    {
        if (m_soundBuffer != null)
            return sfSoundBuffer_saveToFile(m_soundBuffer, filename.toStringz);
        return false;
    }

    // Returns de C pointer.
    @property @nogc @safe package sfSoundBuffer* ptr()
    {
        return m_soundBuffer;
    }

    /// Duplicates this SoundBuffer.
    @property @safe SoundBuffer dup()
    {
        return new SoundBuffer(m_soundBuffer);
    }
}

package extern (C)
{
    struct sfSoundBuffer; // @suppress(dscanner.style.phobos_naming_convention)
}

// CSFML's functions.
@nogc @safe private extern (C)
{
    void sfSoundBuffer_destroy(sfSoundBuffer* soundBuffer);
    sfSoundBuffer* sfSoundBuffer_createFromFile(const char* filename);
    sfSoundBuffer* sfSoundBuffer_createFromMemory(const void* data, size_t sizeInBytes);
    sfSoundBuffer* sfSoundBuffer_createFromStream(sfInputStream* stream);
    sfSoundBuffer* sfSoundBuffer_createFromSamples(const short* samples,
            long sampleCount, uint channelCount, uint sampleRate);
    sfSoundBuffer* sfSoundBuffer_copy(const sfSoundBuffer* soundBuffer);
    bool sfSoundBuffer_saveToFile(const sfSoundBuffer* soundBuffer, const char* filename);
    const(short)* sfSoundBuffer_getSamples(const sfSoundBuffer* soundBuffer);
    ulong sfSoundBuffer_getSampleCount(const sfSoundBuffer* soundBuffer);
    uint sfSoundBuffer_getSampleRate(const sfSoundBuffer* soundBuffer);
    uint sfSoundBuffer_getChannelCount(const sfSoundBuffer* soundBuffer);
    Time sfSoundBuffer_getDuration(const sfSoundBuffer* soundBuffer);
}

unittest
{
    import std.file : exists;
    import std.path : baseName, extension, stripExtension;
    import std.stdio : writefln, writeln;

    writeln("Running Soundbuffer unittest...");

    string filename = "unittest/res/The Paragon Axis - Spirits of Fall.wav";

    SoundBuffer soundbuffer = new SoundBuffer();
    // Should not crash when m_soundBuffer is null
    // Same for all others delegates
    soundbuffer.sampleRate;
    assert(soundbuffer.loadFromFile(filename));

    // Checking if the music has the correct informations
    assert(soundbuffer.duration.asMicroseconds() == 221_325_120);
    // 44100 Hz
    assert(soundbuffer.sampleRate == 44_100);
    // 2 channels (stereo)
    assert(soundbuffer.channelCount == 2);

    string filename_copy = baseName(stripExtension(filename)) ~
        " (Copy from DSFML)" ~ extension(filename);

    // Displaying sampleCount because I didn't found how to get it (externally/not with SFML)
    writefln("\tsampleCount: %s", soundbuffer.sampleCount);
    writeln("\tsaving file '" ~ filename_copy ~ "'...");
    assert(soundbuffer.saveToFile(filename_copy));
    writeln("\tFile saved !");

    assert(exists(filename_copy));

    // TODO: loadFromMemory, loadFromStream
}
