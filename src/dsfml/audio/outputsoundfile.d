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
  * This class encodes audio samples to a sound file.
 *
 * It is used internally by higher-level classes such as $(SOUNDBUFFER_LINK),
 * but can also be useful if you want to create audio files from custom data
 * sources, like generated audio samples.
 *
 * Example:
 * ---
 * // Create a sound file, ogg/vorbis format, 44100 Hz, stereo
 * auto file = new OutputSoundFile();
 * if (!file.openFromFile("music.ogg", 44100, 2))
 * {
 *     //error
 * }
 *
 * while (...)
 * {
 *     // Read or generate audio samples from your custom source
 *     short[] samples = ...;
 *
 *     // Write them to the file
 *     file.write(samples);
 * }
 * ---
 *
 * See_Also:
 * $(INPUTSOUNDFILE_LINK)
 */
module dsfml.audio.outputsoundfile;

import std.string;
import core.stdc.config;
import core.stdcpp.string;

/**
 * Provide write access to sound files.
 */
extern(C++, sf) class OutputSoundFile
{

    /// Default constructor.
    final this();

    /// Destructor.
    final ~this();

    /**
     * Open the sound file from the disk for writing.
     *
     * The supported audio formats are: WAV, OGG/Vorbis, FLAC.
     *
     * Params:
     *      filename     = Path of the sound file to load
     *      sampleRate   = Sample rate of the sound
     *      channelCount = Number of channels in the sound
     *
     * Returns:
     *      true if the file was successfully opened.
     */
    extern(D) bool openFromFile(const string filename, uint sampleRate, uint channelCount)
    {
        basic_string!char cpp_filename = basic_string!char(filename);
        return openFromFile(cpp_filename, sampleRate, channelCount);
    }

    // SFML C++ implementation
    final bool openFromFile(const ref basic_string!char filename, uint sampleRate, uint channelCount);

    /**
     * Write audio samples to the file.
     *
     * Params:
     *      samples = array of samples to write
     */
    extern(D) void write(const(short)[] samples)
    {
        write(samples.ptr, cast(cpp_ulonglong) samples.length);
    }

    // SFML C++ implementation
    final void write(const short* samples, cpp_ulonglong count);
}

unittest
{
    import std.stdio;
    writeln("Running OutputSoundFile unittest...");

    //OutputSoundFile osf = new OutputSoundFile();
    //osf.openFromFile("unittest/res/TestMusic.ogg", 0, 2); // TODO: set the right sampleRate and channelCount

    // TODO: write
}