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
 *
 * `SoundRecorder` provides a simple interface to access the audio recording
 * capabilities of the computer (the microphone).
 *
 * As an abstract base class, it only cares about capturing sound samples, the
 * task of making something useful with them is left to the derived class. Note
 * that DSFML provides a built-in specialization for saving the captured data to
 * a sound buffer (see $(SOUNDBUFFERRECORDER_LINK)).
 *
 * A derived class has only one virtual function to override:
 * - onProcessSamples provides the new chunks of audio samples while the
 * capture happens
 *
 * Moreover, two additionnal virtual functions can be overriden as well
 * if necessary:
 * - onStart is called before the capture happens, to perform custom
 * initializations
 * - onStop is called after the capture ends, to perform custom cleanup
 *
 * A derived class can also control the frequency of the onProcessSamples calls,
 * with the `setProcessingInterval` protected function. The default interval is
 * chosen so that recording thread doesn't consume too much CPU, but it can be
 * changed to a smaller value if you need to process the recorded data in real
 * time, for example.
 *
 * The audio capture feature may not be supported or activated on every
 * platform, thus it is recommended to check its availability with the
 * `isAvailable()` function. If it returns false, then any attempt to use an
 * audio recorder will fail.
 *
 * If you have multiple sound input devices connected to your  computer (for
 * example: microphone, external soundcard, webcam mic, ...) you can get a list
 * of all available devices through the `availableDevices()` function. You
 * can then select a device by calling `device()` with the appropriate
 * device. Otherwise the default capturing device will be used.
 *
 * By default the recording is in 16-bit mono. Using the setChannelCount method
 * you can change the number of channels used by the audio capture device to
 * record. Note that you have to decide whether you want to record in mono or
 * stereo before starting the recording.
 *
 * It is important to note that the audio capture happens in a separate thread,
 * so that it doesn't block the rest of the program. In particular, the
 * `onProcessSamples` and `onStop` virtual functions (but not `onStart`) will be
 * called from this separate thread. It is important to keep this in mind,
 * because you may have to take care of synchronization issues if you share data
 * between threads.
 *
 * Example:
 * ---
 * class CustomRecorder : SoundRecorder
 * {
 *     ~this()
 *     {
 *         // Make sure to stop the recording thread
 *         stop();
 *     }
 *
 *     override bool onStart() // optional
 *     {
 *         // Initialize whatever has to be done before the capture starts
 *         ...
 *
 *         // Return true to start playing
 *         return true;
 *     }
 *
 *     bool onProcessSamples(const(short)[] samples)
 *     {
 *         // Do something with the new chunk of samples (store them, send them, ...)
 *         ...
 *
 *         // Return true to continue playing
 *         return true;
 *     }
 *
 *     override void onStop() // optional
 *     {
 *         // Clean up whatever has to be done after the capture ends
 *         ...
 *     }
 * }
 *
 * // Usage
 * if (CustomRecorder.isAvailable())
 * {
 *     auto recorder = new CustomRecorder();
 *
 *     if (!recorder.start())
 *         return -1;
 *
 *     ...
 *     recorder.stop();
 * }
 * ---
 *
 * See_Also:
 *      $(SOUNDBUFFERRECORDER_LINK)
 */
module dsfml.audio.soundrecorder;

import dsfml.audio.soundbuffer;
import dsfml.system.time;
import std.conv;
import std.string;


/**
 * Abstract base class for capturing sound data.
 */
class SoundRecorder
{
    private sfSoundRecorder* m_soundRecorder;

    /**
     * Default constructor.
     *
     * This constructor is only meant to be called by derived classes.
     */
    this()
    {
        m_soundRecorder = sfSoundRecorder_create(&onStartCallback,
            &onProcessSamplesCallback, &onStopCallback, cast(void*) this);
    }

    /// Destructor.
    ~this()
    {
        sfSoundRecorder_destroy(m_soundRecorder);
    }

    /**
     * Start the capture.
     *
     * The sampleRate parameter defines the number of audio samples captured per
     * second. The higher, the better the quality (for example, 44100
     * samples/sec is CD quality). This function uses its own thread so that it
     * doesn't block the rest of the program while the capture runs. Please note
     * that only one capture can happen at the same time.
     *
     * Params:
     *      sampleRate = Desired capture rate, in number of samples per second
     *
     * Returns:
     *      true, if start of capture was successful
     */
    @nogc
    bool start(uint sampleRate = 44100)
    {
        return sfSoundRecorder_start(m_soundRecorder, sampleRate);
    }

    /// Stop the capture.
    @nogc
    void stop()
    {
        sfSoundRecorder_stop(m_soundRecorder);
    }

    @property
    {
        /**
         * Get the sample rate in samples per second.
         *
         * The sample rate defines the number of audio samples captured per second.
         * The higher, the better the quality (for example, 44100 samples/sec is CD
         * quality).
         *
         * Returns:
         *      Sample rate, in samples per second
         */
        @nogc
        uint sampleRate() const
        {
            return sfSoundRecorder_getSampleRate(m_soundRecorder);
        }
    }

    @property
    {
        /**
         * Get the name of the current audio capture device.
         *
         * Returns:
         *      The name of the current audio capture device.
         */
        string device()
        {
            return sfSoundRecorder_getDevice(m_soundRecorder).to!string;
        }

        /**
         * Set the audio capture device.
         *
         * This function sets the audio capture device to the device with the given
         * name. It can be called on the fly (i.e: while recording). If you do so
         * while recording and opening the device fails, it stops the recording.
         *
         * Params:
         *      name = The name of the audio capture device
         *
         * Returns:
         *      true, if it was able to set the requested device.
         *
         * See_Also:
         *      availableDevices
         */
        bool device(string name)
        {
            return sfSoundRecorder_setDevice(m_soundRecorder, name.toStringz);
        }
    }

    @property
    {
        /**
         * Get the number of channels used by this recorder.
         *
         * Currently only mono and stereo are supported, so the value is either 1
         * (for mono) or 2 (for stereo).
         *
         * Returns:
         *      Number of channels
         */
        @nogc
        uint channelCount() const
        {
            return sfSoundRecorder_getChannelCount(m_soundRecorder);
        }

        /**
         * Set the channel count of the audio capture device.
         *
         * This method allows you to specify the number of channels used for
         * recording. Currently only 16-bit mono and 16-bit stereo are supported.
         *
         * Params:
         *      _channelCount=Number of channels. Currently only mono (1) and stereo (2) are supported.
         */
        @nogc
        void channelCount(uint _channelCount)
        {
            sfSoundRecorder_setChannelCount(m_soundRecorder, _channelCount);
        }
    }

    /**
     * Get a list of the names of all available audio capture devices.
     *
     * This function returns an array of strings, containing the names of all
     * available audio capture devices.
     *
     * Returns:
     *      An array of strings containing the names.
     */
    static const(string)[] availableDevices()
    {
        // stores all available devices after the first call
        static string[] availableDevices;

        // if getAvailableDevices hasn't been called yet
        if(availableDevices.length == 0)
        {
            char** devices;
            size_t counts;

            devices = sfSoundRecorder_getAvailableDevices(&counts);

            //calculate real length
            availableDevices.length = counts;

            //populate availableDevices
            for(uint i = 0; i < counts; i++)
            {
                availableDevices[i] = devices[i].to!string;
            }
        }
        return availableDevices;
    }

    /**
     * Get the name of the default audio capture device.
     *
     * This function returns the name of the default audio capture device. If
     * none is available, an empty string is returned.
     *
     * Returns:
     *      The name of the default audio capture device.
     */
    static string getDefaultDevice()
    {
        return sfSoundRecorder_getDefaultDevice().to!string;
    }

    /**
     * Check if the system supports audio capture.
     *
     * This function should always be called before using the audio capture
     * features. If it returns false, then any attempt to use SoundRecorder or
     * one of its derived classes will fail.
     *
     * Returns:
     *      true if audio capture is supported, false otherwise.
     */
    @nogc
    static bool isAvailable()
    {
        return sfSoundRecorder_isAvailable();
    }

    protected
    {
        /**
         * Set the processing interval.
         *
         * The processing interval controls the period between calls to the
         * onProcessSamples function. You may want to use a small interval if
         * you want to process the recorded data in real time, for example.
         *
         * Note: this is only a hint, the actual period may vary. So don't rely
         * on this parameter to implement precise timing.
         *
         * The default processing interval is 100 ms.
         *
         * Params:
         *      interval = Processing interval
         */
        @nogc
        void setProcessingInterval(Time interval)
        {
            sfSoundRecorder_setProcessingInterval(m_soundRecorder, interval);
        }

        /**
         * Start capturing audio data.
         *
         * This virtual function may be overriden by a derived class if
         * something has to be done every time a new capture starts. If not,
         * this function can be ignored; the default implementation does
         * nothing.
         *
         * Returns:
         *      true to the start the capture, or false to abort it.
         */
        bool onStart()
        {
            // Nothing to do
            return true;
        }

        /**
         * Process a new chunk of recorded samples.
         *
         * This virtual function is called every time a new chunk of recorded
         * data is available. The derived class can then do whatever it wants
         * with it (storing it, playing it, sending it over the network, etc.).
         *
         * Params:
         *      samples = Array of the new chunk of recorded samples
         *
         * Returns:
         *      true to continue the capture, or false to stop it.
         */
        abstract bool onProcessSamples(const(short)[] samples);

        /**
         * Stop capturing audio data.
         *
         * This virtual function may be overriden by a derived class if
         * something has to be done every time the capture ends. If not, this
         * function can be ignored; the default implementation does nothing.
         */
        void onStop()
        {
            // Nothing to do
        }
    }

    /**
     * This function is called by CSFML.
     *
     * CSFML's "sfBool" is a byte of 0 or 1.
     * Passing a bool func to CSFML will simply fail.
     */
    private extern(C) static byte onProcessSamplesCallback(const short* samples, size_t sampleCount, void* userData)
    {
        SoundRecorder sr = cast(SoundRecorder) userData;
        return sr.onProcessSamples(samples[0 .. sampleCount]);
    }

    /**
     * This function is called by CSFML.
     *
     * CSFML's "sfBool" is a byte of 0 or 1.
     * That's why we return a byte and not a bool.
     */
    private extern(C) static byte onStartCallback(void* userData)
    {
        SoundRecorder sr = cast(SoundRecorder) userData;
        return sr.onStart();
    }

    /**
     * This function is called by CSFML.
     */
    private extern(C) static void onStopCallback(void* userData)
    {
        SoundRecorder sr = cast(SoundRecorder) userData;
        sr.onStop();
    }
}

// CSFML's functions.
private extern(C)
{
    // C Callbacks
    alias sfSoundRecorderStartCallback = byte function(void*);
    alias sfSoundRecorderProcessCallback = byte function(const short*, size_t, void*);
    alias sfSoundRecorderStopCallback = void function(void*);

    struct sfSoundRecorder;

    @nogc:

    sfSoundRecorder* sfSoundRecorder_create(sfSoundRecorderStartCallback onStart,
        sfSoundRecorderProcessCallback onProcess,
        sfSoundRecorderStopCallback onStop, void* userData);
    void sfSoundRecorder_destroy(sfSoundRecorder* soundRecorder);
    bool sfSoundRecorder_start(sfSoundRecorder* soundRecorder, uint sampleRate);
    void sfSoundRecorder_stop(sfSoundRecorder* soundRecorder);
    uint sfSoundRecorder_getSampleRate(const sfSoundRecorder* soundRecorder);
    bool sfSoundRecorder_isAvailable();
    void sfSoundRecorder_setProcessingInterval(sfSoundRecorder* soundRecorder, Time interval);
    char** sfSoundRecorder_getAvailableDevices(size_t* count);
    char* sfSoundRecorder_getDefaultDevice();
    bool sfSoundRecorder_setDevice(sfSoundRecorder* soundRecorder, const char* name);
    char* sfSoundRecorder_getDevice(sfSoundRecorder* soundRecorder);
    void sfSoundRecorder_setChannelCount(sfSoundRecorder* soundRecorder, uint channelCount);
    uint sfSoundRecorder_getChannelCount(const sfSoundRecorder* soundRecorder);
}

// unittests in soundbufferrecorder.d
