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
 * `SoundBufferRecorder` allows to access a recorded sound through a
 * $(SOUNDBUFFER_LINK), so that it can be played, saved to a file, etc.
 *
 * It has the same simple interface as its base class (`start()`, `stop()`) and
 * adds a function to retrieve the recorded sound buffer (`buffer()`).
 *
 * As usual, don't forget to call the `isAvailable()` function before using this
 * class (see $(SOUNDRECORDER_LINK) for more details about this).
 *
 * Example:
 * ---
 * if (SoundBufferRecorder.isAvailable())
 * {
 *     // Record some audio data
 *     auto recorder = SoundBufferRecorder();
 *     recorder.start();
 *     ...
 *     recorder.stop();
 *
 *     // Get the buffer containing the captured audio data
 *     auto buffer = recorder.buffer();
 *
 *     // Save it to a file (for example...)
 *     buffer.saveToFile("my_record.ogg");
 * }
 * ---
 *
 * See_Also:
 *      $(SOUNDRECORDER_LINK)
 */
module dsfml.audio.soundbufferrecorder;

import dsfml.audio.soundrecorder;
import dsfml.audio.soundbuffer;

/**
 * Specialized SoundRecorder which stores the captured audio data into a sound
 * buffer.
 */
class SoundBufferRecorder : SoundRecorder
{
    private
    {
        short[] m_samples;
        SoundBuffer m_soundBuffer;
    }

    /// Default constructor.
    this()
    {
        m_soundBuffer = new SoundBuffer();
        super();
    }

    /**
     * Get the sound buffer containing the captured audio data.
     *
     * The sound buffer is valid only after the capture has ended. This function
     * provides a read-only access to the internal sound buffer, but it can be
     * copied if you need to make any modification to it.
     *
     * Returns:
     *      Read-only access to the sound buffer.
     */
    @property @nogc
    const(SoundBuffer) buffer()
    {
        return m_soundBuffer;
    }

    protected
    {
        /**
         * Start capturing audio data.
         *
         * Returns:
         *      true to start the capture, or false to abort it.
         */
        override bool onStart()
        {
            m_samples = [];
            m_soundBuffer = new SoundBuffer();
            return true;
        }

        /**
         * Process a new chunk of recorded samples.
         *
         * Params:
         *      samples = Array of the new chunk of recorded samples
         *
         * Returns:
         *      true to continue the capture, or false to stop it.
         */
        override bool onProcessSamples(const(short)[] samples)
        {
            m_samples ~= samples;
            return true;
        }

        /**
         * Stop capturing audio data.
         */
        override void onStop()
        {
            if(m_samples.length > 0)
            {
                m_soundBuffer.loadFromSamples(m_samples, channelCount, sampleRate);
            }
        }
    }
}

unittest
{
    import std.stdio;
    import dsfml.system.sleep;

    writeln("Running SoundBufferRecorder unittest...");
    version (DSFML_Unittest_with_interaction)
    {
        if(!SoundBufferRecorder.isAvailable())
        {
            writeln("\tNo capture device available. Aborting audio capture unittest.");
            return;
        }

        SoundBufferRecorder recorder = new SoundBufferRecorder();

        // Testing sampleRate (0 because not started)
        assert(recorder.sampleRate == 0);
        writefln("\tDefault device: %s", SoundRecorder.getDefaultDevice());

        const string[] devices = recorder.getAvailableDevices();

        foreach(string d; devices)
        {
            writefln("\tStarting audio capture test for device '%s'", d);

            if (!recorder.device(d) || !recorder.start())
            {
                writeln("\tUnable to start capture.\n
                    \tAborting audio capture unittest for this device.");
                break;
            }
            // Testing default value once started
            assert(recorder.sampleRate == 44100);

            writeln("\tPlease speak for 2s.");
            sleep(seconds(2));
            recorder.stop();

            writefln("\tSaving to file 'record_%s.wav'...", d);
            recorder.buffer.saveToFile("record_"~d~".wav");
            writeln("\tFile saved !");
        }

        if (devices.length == 0)
            writeln("\tNo audio device found !");
        else
            writeln("\tListen to your records so see if it has worked.");
    }
}
