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
 * `InputSoundFile` decodes audio samples from a sound file. It is used
 * internally by higher-level classes such as $(SOUNDBUFFER_LINK) and
 * $(MUSIC_LINK), but can also be useful if you want to process or analyze audio
 * files without playing them, or if you want to implement your own version of
 * $(MUSIC_LINK) with more specific features.
 *
 * Example:
 * ---
 * // Open a sound file
 * auto file = new InputSoundFile();
 * if (!file.openFromFile("music.ogg"))
 * {
 *      //error
 * }
 *
 * // Print the sound attributes
 * writeln("duration: ", file.getDuration().total!"seconds");
 * writeln("channels: ", file.getChannelCount());
 * writeln("sample rate: ", file.getSampleRate());
 * writeln("sample count: ", file.getSampleCount());
 *
 * // Read and process batches of samples until the end of file is reached
 * short samples[1024];
 * long count;
 * do
 * {
 *     count = file.read(samples, 1024);
 *
 *     // process, analyze, play, convert, or whatever
 *     // you want to do with the samples...
 * }
 * while (count > 0);
 * ---
 *
 * See_Also:
 *      $(OUTPUTSOUNDFILE_LINK)
 */
module dsfml.audio.inputsoundfile;

import core.stdc.string;
import core.stdc.config;
import core.stdcpp.string;
import dsfml.system.inputstream;
import dsfml.system.time;

/**
 * Provide read access to sound files.
 */
extern(C++, sf) class InputSoundFile
{

    /// Default constructor.
    final this();

    /// Destructor.
    final ~this();

    /**
     * Open a sound file from the disk for reading.
     *
     * The supported audio formats are: WAV (PCM only), OGG/Vorbis, FLAC. The
     * supported sample sizes for FLAC and WAV are 8, 16, 24 and 32 bit.
     *
     * Params:
     *      filename = Path of the sound file to load
     *
     * Returns:
     *      true if the file was successfully opened.
     */
    extern(D) bool openFromFile(const string filename)
    {
        basic_string!char cpp_filename = basic_string!char(filename);
        return openFromFile(cpp_filename);
    }

    // SFML C++ implementation
    final bool openFromFile(const ref basic_string!char filename);

    /**
     * Open a sound file in memory for reading.
     *
     * The supported audio formats are: WAV (PCM only), OGG/Vorbis, FLAC. The
     * supported sample sizes for FLAC and WAV are 8, 16, 24 and 32 bit.
     *
     * Params:
     *      data = file data in memory
     *
     * Returns:
     *      true if the file was successfully opened.
     */
    extern(D) bool openFromMemory(const(void)[] data)
    {
        return openFromMemory(data.ptr, data.sizeof);
    }

    // SFML C++ implementation
    final bool openFromMemory(const(void*) data, size_t sizeInBytes);

    /**
     * Open a sound file from a custom stream for reading.
     *
     * The supported audio formats are: WAV (PCM only), OGG/Vorbis, FLAC. The
     * supported sample sizes for FLAC and WAV are 8, 16, 24 and 32 bit.
     *
     * Params:
     *      stream = Source stream to read from
     *
     * Returns:
     *      true if the file was successfully opened.
     */
    @disable
    extern(D) bool openFromStream(InputStream stream)
    {
        // TODO: convert struct InputStream to sf::InputStream
        return false;
    }

    // SFML C++ implementation
    // bool openFromStream(InputStream stream)

    /**
     * Get the total number of audio samples in the file
     *
     * Returns:
     *      Number of samples.
     */
    final ulong getSampleCount() const;

    /**
     * Get the number of channels used by the sound
     *
     * Returns:
     *      Number of channels (1 = mono, 2 = stereo).
     */
    final uint getChannelCount() const;

    /**
     * Get the sample rate of the sound
     *
     * Returns:
     *      Sample rate, in samples per second.
     */
    final uint getSampleRate() const;

    /**
     * Get the total duration of the sound file.
     *
     * This function is provided for convenience, the duration is deduced from the other sound file attributes.
     *
     * Returns:
     *      Duration of the sound file
     */
    final Time getDuration() const;

    /**
     * Get the read offset of the file in time.
     *
     * Returns:
     *      Time position
     */
    final Time getTimeOffset() const;

    /**
     * Get the read offset of the file in samples.
     *
     * Returns:
     *      Sample position
     */
    final long getSampleOffset() const;

    /**
     * Read audio samples from the open file.
     *
     * Params:
     *      samples = array of samples to fill
     *
     * Returns:
     *      Number of samples actually read (may be less samples.length)
     */
    extern(D) long read(short[] samples)
    {
        return read(samples.ptr, samples.length);
    }

    // SFML C++ implementation
    final long read(short* samples, cpp_ulonglong maxCount);

    /**
     * Change the current read position to the given sample offset.
     *
     * This function takes a sample offset to provide maximum precision. If you
     * need to jump to a given time, use the other overload.
     *
     * The sample offset takes the channels into account. Offsets can be
     * calculated like this: sampleNumber * sampleRate * channelCount.
     * If the given offset exceeds to total number of samples, this function
     * jumps to the end of the sound file.
     *
     * Params:
     *      sampleOffset = Index of the sample to jump to, relative to the beginning
     */
    void seek(ulong sampleOffset)
    {
        seek(cast(cpp_ulonglong) sampleOffset);
    }

    // SFML C++ implementation
    final void seek(cpp_ulonglong sampleOffset);

    /**
     * Change the current read position to the given time offset.
     *
     * Using a time offset is handy but imprecise. If you need an accurate
     * result, consider using the overload which takes a sample offset.
     *
     * If the given time exceeds to total duration, this function jumps to the
     * end of the sound file.
     *
     * Params:
     *      timeOffset = Time to jump to, relative to the beginning
     */
    void seek(Time timeOffset)
    {
        seek(cast(cpp_ulonglong) timeOffset.asSeconds() * getSampleRate() * getChannelCount());
    }
}

unittest
{
    import std.stdio;
    writeln("Running InputSoundFile unittest...");

    InputSoundFile isf = new InputSoundFile();
    //isf.openFromFile("unittest/res/TestMusic.ogg"); // Segfault here

    // TODO: seek, read, ...


    // isf is destroyed by the GC, but the GC doesn't seem to register that and causes a segfault
}
