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
 * Unlike audio buffers (see $(SOUNDBUFFER_LINK)), audio streams are never
 * completely loaded in memory. Instead, the audio data is acquired continuously
 * while the stream is playing. This behaviour allows to play a sound with no
 * loading delay, and keeps the memory consumption very low.
 *
 * Sound sources that need to be streamed are usually big files (compressed
 * audio musics that would eat hundreds of MB in memory) or files that would
 * take a lot of time to be received (sounds played over the network).
 *
 * `SoundStream` is a base class that doesn't care about the stream source,
 * which is left to the derived class. SFML provides a built-in specialization
 * for big files (see $(MUSIC_LINK)). No network stream source is provided, but
 * you can write your own by combining this class with the network module.
 *
 * A derived class has to override two virtual functions:
 * - `onGetData` fills a new chunk of audio data to be played
 * - `onSeek` changes the current playing position in the source
 *
 * It is important to note that each `SoundStream` is played in its own
 * separate thread, so that the streaming loop doesn't block the rest of the
 * program. In particular, the `onGetData` and `onSeek` virtual functions may
 * sometimes be called from this separate thread. It is important to keep this
 * in mind, because you may have to take care of synchronization issues if you
 * share data between threads.
 *
 * Example:
 * ---
 * class CustomStream : SoundStream
 * {
 *
 *     bool open(const(char)[] location)
 *     {
 *         // Open the source and get audio settings
 *         ...
 *         uint channelCount = ...;
 *         unint sampleRate = ...;
 *
 *         // Initialize the stream -- important!
 *         initialize(channelCount, sampleRate);
 *     }
 *
 * protected:
 *     override bool onGetData(ref const(short)[] samples)
 *     {
 *         // Fill the chunk with audio data from the stream source
 *         // (note: must not be empty if you want to continue playing)
 *
 *         // Return true to continue playing
 *         return true;
 *     }
 *
 *     override void onSeek(Uint32 timeOffset)
 *     {
 *         // Change the current position in the stream source
 *         ...
 *     }
 * }
 *
 * // Usage
 * auto stream = CustomStream();
 * stream.open("path/to/stream");
 * stream.play();
 * ---
 *
 * See_Also:
 *      $(MUSIC_LINK)
 */
module dsfml.audio.soundstream;

import dsfml.system.vector3;
import dsfml.system.time;
import dsfml.audio.soundsource;

/**
 * Abstract base class for streamed audio sources.
 */
class SoundStream : SoundSource
{
    /// Structure defining a chunk of audio data to stream.
    struct Chunk
    {
        short samples; /// Pointer to the audio samples.
        uint sampleCount; /// Number of samples pointed by Samples.
    }

    private sfSoundStream* m_soundStream;

    /**
     * Default constructor.
     *
     * This constructor is only meant to be called by derived classes.
     */
    @nogc
    this()
    {
        m_soundStream = sfSoundStream_create(&onGetDataCallback, &onSeekCallback, 0, 0, cast(void*) this);
    }

    /// Destructor.
    @safe
    ~this()
    {
        sfSoundStream_destroy(m_soundStream);
    }

    /**
     * Define the audio stream parameters.
     *
     * This function must be called by derived classes as soon as they know the
     * audio settings of the stream to play. Any attempt to manipulate the
     * stream (`play()`, ...) before calling this function will fail. It can be
     * called multiple times if the settings of the audio stream change, but
     * only when the stream is stopped.
     *
     * Params:
     *      channelCount = Number of channels of the stream
     *      sampleRate   = Sample rate, in samples per second
     */
    @nogc
    protected void initialize(uint channelCount, uint sampleRate)
    {
        m_soundStream = sfSoundStream_create(&onGetDataCallback, &onSeekCallback,
            channelCount, sampleRate, cast(void*) this);
    }

    @property
    {
        /**
         * Set the pitch of the sound.
         *
         * The pitch represents the perceived fundamental frequency of a sound; thus
         * you can make a sound more acute or grave by changing its pitch. A side
         * effect of changing the pitch is to modify the playing speed of the sound
         * as well. The default value for the pitch is 1.
         *
         * Params:
         *      _pitch = New pitch to apply to the sound
         */
        @nogc @safe
        void pitch(float _pitch)
        {
            sfSoundStream_setPitch(m_soundStream, _pitch);
        }

        /**
         * Get the pitch of the sound.
         *
         * Returns:
         *      Pitch of the sound
         */
        @nogc @safe
        float pitch() const
        {
            return sfSoundStream_getPitch(m_soundStream);
        }
    }

    @property
    {
        /**
         * Set the volume of the sound.
         *
         * The volume is a value between 0 (mute) and 100 (full volume). The default
         * value for the volume is 100.
         *
         * Params:
         *      _volume = Volume of the sound
         */
        @nogc @safe
        void volume(float _volume)
        {
            sfSoundStream_setVolume(m_soundStream, _volume);
        }

        /**
         * Get the volume of the sound.
         *
         * Returns:
         *      Volume of the sound, in the range [0, 100]
         */
        @nogc @safe
        float volume() const
        {
            return sfSoundStream_getVolume(m_soundStream);
        }
    }

    @property
    {
        /**
         * Set the 3D position of the sound in the audio scene.
         *
         * Only sounds with one channel (mono sounds) can be spatialized. The
         * default position of a sound is (0, 0, 0).
         *
         * Params:
         *      _position = Position of the sound in the scene
         */
        @nogc @safe
        void position(Vector3f _position)
        {
            sfSoundStream_setPosition(m_soundStream, _position);
        }

        /**
         * Get the 3D position of the sound in the audio scene.
         *
         * Returns:
         *      Position of the sound
         */
        @nogc @safe
        Vector3f position() const
        {
            return sfSoundStream_getPosition(m_soundStream);
        }
    }

    @property
    {
        /**
         * Set whether or not the stream should loop after reaching the end.
         *
         * If set, the stream will restart from beginning after reaching the end and
         *  so on, until it is stopped or `loop(false)` is called. The default
         * looping state for streams is false.
         *
         * Params:
         *      _loop = true to play in loop, false to play once
         */
        @nogc @safe
        void loop(bool _loop)
        {
            sfSoundStream_setLoop(m_soundStream, _loop);
        }

        /**
         * Tell whether or not the stream is in loop mode.
         *
         * Returns:
         *      true if the stream is looping, false otherwise
         */
        @nogc @safe
        bool loop() const
        {
            return sfSoundStream_getLoop(m_soundStream);
        }
    }

    @property
    {
        /**
         * Change the current playing position of the stream.
         *
         * The playing position can be changed when the stream is either paused or
         * playing. Changing the playing position when the stream is stopped has no
         * effect, since playing the stream would reset its position.
         *
         * Params:
         *      offset = New playing position, from the beginning of the stream
         */
        @nogc @safe
        void playingOffset(Time offset)
        {
            sfSoundStream_setPlayingOffset(m_soundStream, offset);

        }

        /**
         * Get the current playing position of the stream.
         *
         * Returns:
         *      Current playing position, from the beginning of the stream
         */
        @nogc @safe
        Time playingOffset() const
        {
            return sfSoundStream_getPlayingOffset(m_soundStream);
        }
    }

    @property
    {
        /**
         * Make the sound's position relative to the listener or absolute.
         *
         * Making a sound relative to the listener will ensure that it will always
         * be played the same way regardless the position of the listener. This can
         * be useful for non-spatialized sounds, sounds that are produced by the
         * listener, or sounds attached to it. The default value is false (position
         * is absolute).
         *
         * Params:
         *      relative = true to set the position relative, false to set it absolute
         */
        @nogc @safe
        void relativeToListener(bool relative)
        {
            sfSoundStream_setRelativeToListener(m_soundStream, relative);
        }

        /**
         * Tell whether the sound's position is relative to the listener or is absolute.
         *
         * Returns:
         *      true if the position is relative, false if it's absolute
         */
        @nogc @safe
        bool relativeToListener() const
        {
            return sfSoundStream_isRelativeToListener(m_soundStream);
        }
    }

    @property
    {
        /**
         * Set the minimum distance of the sound.
         *
         * The "minimum distance" of a sound is the maximum distance at which it is
         * heard at its maximum volume. Further than the minimum distance, it will
         * start to fade out according to its attenuation factor. A value of 0
         * ("inside the head of the listener") is an invalid value and is forbidden.
         * The default value of the minimum distance is 1.
         *
         * Params:
         *      distance = New minimum distance of the sound
         *
         * See_Also:
         *      attenuation
         */
        @nogc @safe
        void minDistance(float distance)
        {
            sfSoundStream_setMinDistance(m_soundStream, distance);
        }

        /**
         * Get the minimum distance of the sound.
         *
         * Returns:
         *      Minimum distance of the sound
         */
        @nogc @safe
        float minDistance() const
        {
            return sfSoundStream_getMinDistance(m_soundStream);
        }
    }

    @property
    {
        /**
         * Set the attenuation factor of the sound.
         *
         * The attenuation is a multiplicative factor which makes the sound more or
         * less loud according to its distance from the listener. An attenuation of
         * 0 will produce a non-attenuated sound, i.e. its volume will always be the
         * same whether it is heard from near or from far.
         *
         * On the other hand, an attenuation value such as 100 will make the sound
         * fade out very quickly as it gets further from the listener. The default
         * value of the attenuation is 1.
         *
         * Params:
         *      _attenuation = New attenuation factor of the sound
         *
         * See_Also:
         *      minDistance
         */
        @nogc @safe
        void attenuation(float _attenuation)
        {
            sfSoundStream_setAttenuation(m_soundStream, _attenuation);
        }

        /**
         * Get the attenuation factor of the sound.
         *
         * Returns:
         *      Attenuation factor of the sound
         *
         * See_Also:
         *      minDistance
         */
        @nogc @safe
        float attenuation() const
        {
            return sfSoundStream_getAttenuation(m_soundStream);
        }
    }


    @property
    {
        /**
         * Return the number of channels of the stream.
         *
         * 1 channel means mono sound, 2 means stereo, etc.
         *
         * Returns:
         *      Number of channels
         */
        @nogc @safe
        uint channelCount() const
        {
            return sfSoundStream_getChannelCount(m_soundStream);
        }
    }

    @property
    {
        /**
         * Get the stream sample rate of the stream
         *
         * The sample rate is the number of audio samples played per second. The
         * higher, the better the quality.
         *
         * Returns:
         *      Sample rate, in number of samples per second
         */
        @nogc @safe
        uint sampleRate() const
        {
            return sfSoundStream_getSampleRate(m_soundStream);
        }
    }

    @property
    {
        /**
         * Get the current status of the stream (stopped, paused, playing)
         *
         * Returns:
         *      Current status
         */
        @nogc @safe
        Status status() const
        {
            return cast(Status) sfSoundStream_getStatus(m_soundStream);
        }
    }

    /**
     * Start or resume playing the audio stream.
     *
     * This function starts the stream if it was stopped, resumes it if it was
     * paused, and restarts it from the beginning if it was already playing. This
     * function uses its own thread so that it doesn't block the rest of the
     * program while the stream is played.
     *
     * See_Also:
     *      pause, stop
     */
    @nogc @safe
    void play()
    {
        sfSoundStream_play(m_soundStream);
    }

    /**
     * Pause the audio stream.
     *
     * This function pauses the stream if it was playing, otherwise (stream
     * already paused or stopped) it has no effect.
     *
     * See_Also:
     *      play, stop
     */
    @nogc @safe
    void pause()
    {
        sfSoundStream_pause(m_soundStream);
    }

    /**
     * Stop playing the audio stream.
     *
     * This function stops the stream if it was playing or paused, and does
     * nothing if it was already stopped. It also resets the playing position
     * (unlike `pause()`).
     *
     * See_Also:
     *      play, pause
     */
    @nogc @safe
    void stop()
    {
        sfSoundStream_stop(m_soundStream);
    }

    /**
     * Request a new chunk of audio samples from the stream source.
     *
     * This function must be overridden by derived classes to provide the audio
     * samples to play. It is called continuously by the streaming loop, in a
     * separate thread. The source can choose to stop the streaming loop at any
     * time, by returning false to the caller. If you return true (i.e. continue
     * streaming) it is important that the returned array of samples is not
     * empty; this would stop the stream due to an internal limitation.
     *
     * Params:
     *      data = Chunk of data to fill
     *
     * Returns:
     *      true to continue playback, false to stop
     */
    protected abstract bool onGetData(ref Chunk data);

    /**
     * Change the current playing position in the stream source.
     *
     * This function must be overridden by derived classes to allow random
     * seeking into the stream source.
     *
     * Params:
     *    timeOffset = New playing position, relative to the start of the stream
     */
    protected abstract void onSeek(Time timeOffset);

    /**
     * Change the current playing position in the stream source to the beginning of
     * the loop.
     *
     * This function can be overridden by derived classes to allow implementation
     * of custom loop points. Otherwise, it just calls `onSeek(Time.Zero)` and
     * returns 0.
     *
     * Returns:
     *      The seek position after looping (or -1 if there's no loop)
     */
    protected long onLoop()
    {
        onSeek(Time.Zero);
        return 0;
    }

    /**
     * This function is called by CSFML.
     *
     * CSFML's "sfBool" is a byte of 0 or 1.
     * Passing a bool to CSFML will simply fail.
     */
    private extern(C) static byte onGetDataCallback(Chunk* data, void* userData)
    {
        SoundStream ss = cast(SoundStream) userData;
        return ss.onGetData(*data) ? 1 : 0;
    }

    /**
     * This function is called by CSFML.
     */
    private extern(C) static void onSeekCallback(Time time, void* userData)
    {
        SoundStream ss = cast(SoundStream) userData;
        ss.onSeek(time);
    }
}

// CSFML's functions.
private extern(C)
{
    // C Callbacks
    /// Type of the callback used to get a sound stream data
    alias sfSoundStreamGetDataCallback = byte function(SoundStream.Chunk*, void*);
    /// Type of the callback used to seek in a sound stream
    alias sfSoundStreamSeekCallback = void function(Time, void*);

    struct sfSoundStream;

    @nogc @safe:

    sfSoundStream* sfSoundStream_create(sfSoundStreamGetDataCallback getData,
        sfSoundStreamSeekCallback  seek, uint  channelCount, uint  sampleRate,
        void* userData);
    void sfSoundStream_destroy(sfSoundStream* soundStream);
    void sfSoundStream_play(sfSoundStream* soundStream);
    void sfSoundStream_pause(sfSoundStream* soundStream);
    void sfSoundStream_stop(sfSoundStream* soundStream);
    SoundSource.Status sfSoundStream_getStatus(const sfSoundStream* soundStream);
    uint sfSoundStream_getChannelCount(const sfSoundStream* soundStream);
    uint sfSoundStream_getSampleRate(const sfSoundStream* soundStream);
    void sfSoundStream_setPitch(sfSoundStream* soundStream, float pitch);
    void sfSoundStream_setVolume(sfSoundStream* soundStream, float volume);
    void sfSoundStream_setPosition(sfSoundStream* soundStream, Vector3f position);
    void sfSoundStream_setRelativeToListener(sfSoundStream* soundStream, bool relative);
    void sfSoundStream_setMinDistance(sfSoundStream* soundStream, float distance);
    void sfSoundStream_setAttenuation(sfSoundStream* soundStream, float attenuation);
    void sfSoundStream_setPlayingOffset(sfSoundStream* soundStream, Time timeOffset);
    void sfSoundStream_setLoop(sfSoundStream* soundStream, bool loop);
    float sfSoundStream_getPitch(const sfSoundStream* soundStream);
    float sfSoundStream_getVolume(const sfSoundStream* soundStream);
    Vector3f sfSoundStream_getPosition(const sfSoundStream* soundStream);
    bool sfSoundStream_isRelativeToListener(const sfSoundStream* soundStream);
    float sfSoundStream_getMinDistance(const sfSoundStream* soundStream);
    float sfSoundStream_getAttenuation(const sfSoundStream* soundStream);
    bool sfSoundStream_getLoop(const sfSoundStream* soundStream);
    Time sfSoundStream_getPlayingOffset(const sfSoundStream* soundStream);

}

// unittests in music.d
