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
 * Musics are sounds that are streamed rather than completely loaded in memory.
 *
 * This is especially useful for compressed musics that usually take hundreds of
 * MB when they are uncompressed: by streaming it instead of loading it
 * entirely, you avoid saturating the memory and have almost no loading delay.
 *
 * Apart from that, a `Music` has almost the same features as the
 * $(SOUNDBUFFER_LINK)/$(SOUND_LINK) pair: you can play/pause/stop it, request
 * its parameters (channels, sample rate), change the way it is played (pitch,
 * volume, 3D position, ...), etc.
 *
 * As a sound stream, a music is played in its own thread in order not to block
 * the rest of the program. This means that you can leave the music alone after
 * calling `play()`, it will manage itself very well.
 *
 * Example:
 * ---
 * // Declare a new music
 * auto music = new Music();
 *
 * // Open it from an audio file
 * if (!music.openFromFile("music.ogg"))
 * {
 *     // error...
 * }
 *
 * // change its 3D position
 * music.position = Vector3f(0, 1, 10);
 *
 * // increase the pitch
 * music.pitch = 2;
 *
 * // reduce the volume
 * music.volume = 50;
 *
 * // make it loop
 * music.loop = true;
 *
 * // Play it
 * music.play();
 * ---
 *
 * See_Also:
 *      $(SOUND_LINK), $(SOUNDSTREAM_LINK)
 */
module dsfml.audio.music;

import dsfml.system.vector3;
import dsfml.system.inputstream;
import dsfml.system.time;
import dsfml.audio.soundsource;
import dsfml.audio.soundstream;

import std.string;

/// Structure defining a time range using the template type.
struct Span(T)
{
    T offset; /// The beginning offset of the time range.
    T length; /// The length of the time range.
}

alias TimeSpan = Span!(Time);

/**
 * Streamed music played from an audio file.
 */
class Music : SoundStream
{
    private sfMusic* m_music;

    /// Destructor
    ~this()
    {
        //stop();
        sfMusic_destroy(m_music);
    }

    /**
     * Open a music from an audio file.
     *
     * This function doesn't start playing the music (call `play()` to do so).
     * See the documentation of InputSoundFile for the list of supported formats.
     *
     * **Warning:**
     * Since the music is not loaded at once but rather streamed continuously, the
     * file must remain accessible until the Music object loads a new music or is
     * destroyed.
     *
     * Params:
     *      filename = Path of the music file to open
     *
     * Returns:
     *      true if loading succeeded, false if it failed
     *
     * See_Also:
     *      openFromMemory, openFromStream
     */
    @safe
    void openFromFile(string filename)
    {
        m_music = sfMusic_createFromFile(filename.toStringz);
    }

    /**
     * Open a music from an audio file in memory.
     *
     * This function doesn't start playing the music (call `play()` to do so).
     * See the documentation of InputSoundFile for the list of supported formats.
     *
     * **Warning:**
     * Since the music is not loaded at once but rather streamed continuously, the
     * data buffer must remain accessible until the Music object loads a new music
     * or is destroyed. That is, you can't deallocate the buffer right after calling
     * this function.
     *
     * Params:
     *      data = Pointer to the file data in memory
     *
     * Returns:
     *      true if loading succeeded, false if it failed
     *
     * See_Also:
     *      openFromFile, openFromStream
     */
    @nogc
    void openFromMemory(const(void)[] data)
    {
        m_music = sfMusic_createFromMemory(data.ptr, data.length);
    }

    /**
     * Open a music from an audio file in a custom stream.
     *
     * This function doesn't start playing the music (call `play()` to do so).
     * See the documentation of InputSoundFile for the list of supported formats.
     *
     * **Warning:**
     * Since the music is not loaded at once but rather streamed continuously, the
     * stream must remain accessible until the `Music` object loads a new music or
     * is destroyed.
     *
     * Params:
     *      stream = Source stream to read from
     *
     * Returns:
     *      true if loading succeeded, false if it failed
     */
    @nogc @safe
    void openFromStream(InputStream stream)
    {
        m_music = sfMusic_createFromStream(stream.ptr);
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
        override void pitch(float _pitch)
        {
            sfMusic_setPitch(m_music, _pitch);
        }

        /**
         * Get the pitch of the sound.
         *
         * Returns:
         *      Pitch of the sound
         */
        @nogc @safe
        override float pitch() const
        {
            return sfMusic_getPitch(m_music);
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
        override void volume(float _volume)
        {
            sfMusic_setVolume(m_music, _volume);
        }

        /**
         * Get the volume of the sound.
         *
         * Returns:
         *      Volume of the sound, in the range [0, 100]
         */
        @nogc @safe
        override float volume() const
        {
            return sfMusic_getVolume(m_music);
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
        override void position(Vector3f _position)
        {
            sfMusic_setPosition(m_music, _position);
        }

        /**
         * Get the 3D position of the sound in the audio scene.
         *
         * Returns:
         *      Position of the sound
         */
        @nogc @safe
        override Vector3f position() const
        {
            return sfMusic_getPosition(m_music);
        }
    }

    @property
    {
        /**
         * Set whether or not the stream should loop after reaching the end.
         *
         * If set, the stream will restart from beginning after reaching the end
         * and so on, until it is stopped or `loop(false)` is called.
         * The default looping state for streams is false.
         *
         * Params:
         *      _loop = true to play in loop, false to play once
         */
        @nogc @safe
        override void loop(bool _loop)
        {
            sfMusic_setLoop(m_music, _loop);
        }

        /**
         * Tell whether or not the stream is in loop mode.
         *
         * Returns:
         *      true if the stream is looping, false otherwise
         */
        @nogc @safe
        override bool loop() const
        {
            return sfMusic_getLoop(m_music);
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
        override void playingOffset(Time offset)
        {
            sfMusic_setPlayingOffset(m_music, offset);

        }

        /**
         * Get the current playing position of the stream.
         *
         * Returns:
         *      Current playing position, from the beginning of the stream
         */
        @nogc @safe
        override Time playingOffset() const
        {
            return sfMusic_getPlayingOffset(m_music);
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
        override void relativeToListener(bool relative)
        {
            sfMusic_setRelativeToListener(m_music, relative);
        }

        /**
         * Tell whether the sound's position is relative to the listener or is absolute.
         *
         * Returns:
         *      true if the position is relative, false if it's absolute
         */
        @nogc @safe
        override bool relativeToListener() const
        {
            return sfMusic_isRelativeToListener(m_music);
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
        override void minDistance(float distance)
        {
            sfMusic_setMinDistance(m_music, distance);
        }

        /**
         * Get the minimum distance of the sound.
         *
         * Returns:
         *      Minimum distance of the sound
         */
        @nogc @safe
        override float minDistance() const
        {
            return sfMusic_getMinDistance(m_music);
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
        override void attenuation(float _attenuation)
        {
            sfMusic_setAttenuation(m_music, _attenuation);
        }

        /**
         * Get the attenuation factor of the sound.
         *
         * Returns:
         *      Attenuation factor of the sound
         */
        @nogc @safe
        override float attenuation() const
        {
            return sfMusic_getAttenuation(m_music);
        }
    }


    @property
    {
        /**
         * The number of channels of the stream.
         *
         * 1 channel means mono sound, 2 means stereo, etc.
         *
         * Returns:
         *      Number of channels
         */
        @nogc @safe
        override uint channelCount() const
        {
            return sfMusic_getChannelCount(m_music);
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
        override uint sampleRate() const
        {
            return sfMusic_getSampleRate(m_music);
        }
    }

    @property
    {
        /**
         * Get the current status of the stream (stopped, paused, playing)
         *
         * Returns: Current status
         */
        @nogc @safe
        override Status status() const
        {
            return cast(Status) sfMusic_getStatus(m_music);
        }
    }

    @property
    {
        /**
         * Get the total duration of the music.
         *
         * Returns:
         *      Music duration
         */
        @nogc @safe
        Time duration()
        {
            return cast(Time) sfMusic_getDuration(m_music);
        }
    }

    @property
    {
        /**
         * Sets the beginning and end of the sound's looping sequence using Time.
         *
         * Loop points allow one to specify a pair of positions such that, when the
         * music is enabled for looping, it will seamlessly seek to the beginning
         * whenever it encounters the end. Valid ranges for `timePoints.offset` and
         * `timePoints.length` are [0, Dur] and [0, Dur-offset] respectively, where
         * Dur is the value returned by `duration()`. Note that the EOF
         * "loop point" from the end to the beginning of the stream is still
         * honored, in case the caller seeks to a point after the end of the loop
         * range. This function can be safely called at any point after a stream is
         * opened, and will be applied to a playing sound without affecting the
         * current playing offset.
         *
         * **Warning:**
         * Setting the loop points while the stream's status is Paused will set
         * its status to Stopped. The playing offset will be unaffected.
         *
         * Params:
         *      timePoints = The definition of the loop.
         *          Can be any time points within the sound's length
         */
        @nogc @safe
        void loopPoints(TimeSpan timePoints)
        {
            sfMusic_setLoopPoints(m_music, timePoints);
        }

        /**
         * Get the positions of the of the sound's looping sequence.
         *
         * **Warning:**
         * Since `loopPoints(TimeSpan timePoints)` performs some adjustments on the
         * provided values and rounds them to internal samples, a call to
         * `loopPoints()` is not guaranteed to return the same times passed into a
         * previous call to `loopPoints(TimeSpan timePoints)`.
         *
         * However, it is guaranteed to return times that will map to the valid
         * internal samples of this `Music` if they are later passed to
         * `loopPoints(TimeSpan timePoints)`.
         *
         * Returns:
         *       Loop Time position class.
         */
        @nogc @safe
        TimeSpan loopPoints()
        {
            return cast(TimeSpan) sfMusic_getLoopPoints(m_music);
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
    override void play()
    {
        sfMusic_play(m_music);
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
    override void pause()
    {
        sfMusic_pause(m_music);
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
    override void stop()
    {
        sfMusic_stop(m_music);
    }

    override bool onGetData(ref Chunk data)
    {
        return true;
    }

    override void onSeek(Time timeOffset)
    {

    }
}

// CSFML's functions.
@nogc @safe
private extern(C)
{
    struct sfMusic;

    sfMusic* sfMusic_createFromFile(const char* filename);
    sfMusic* sfMusic_createFromMemory(const void* data, size_t sizeInBytes);
    sfMusic* sfMusic_createFromStream(sfInputStream* stream);
    void sfMusic_destroy(sfMusic* music);
    void sfMusic_setLoop(sfMusic* music, bool loop);
    bool sfMusic_getLoop(const sfMusic* music);
    Time sfMusic_getDuration(const sfMusic* music);
    TimeSpan sfMusic_getLoopPoints(const sfMusic* music);
    void sfMusic_setLoopPoints(sfMusic* music, TimeSpan timePoints);
    void sfMusic_play(sfMusic* music);
    void sfMusic_pause(sfMusic* music);
    void sfMusic_stop(sfMusic* music);
    uint sfMusic_getChannelCount(const sfMusic* music);
    uint sfMusic_getSampleRate(const sfMusic* music);
    SoundSource.Status sfMusic_getStatus(const sfMusic* music);
    Time sfMusic_getPlayingOffset(const sfMusic* music);
    void sfMusic_setPitch(sfMusic* music, float pitch);
    void sfMusic_setVolume(sfMusic* music, float volume);
    void sfMusic_setPosition(sfMusic* music, Vector3f position);
    void sfMusic_setRelativeToListener(sfMusic* music, bool relative);
    void sfMusic_setMinDistance(sfMusic* music, float distance);
    void sfMusic_setAttenuation(sfMusic* music, float attenuation);
    void sfMusic_setPlayingOffset(sfMusic* music, Time timeOffset);
    float sfMusic_getPitch(const sfMusic* music);
    float sfMusic_getVolume(const sfMusic* music);
    Vector3f sfMusic_getPosition(const sfMusic* music);
    bool sfMusic_isRelativeToListener(const sfMusic* music);
    float sfMusic_getMinDistance(const sfMusic* music);
    float sfMusic_getAttenuation(const sfMusic* music);
}

unittest
{
    import dsfml.system.sleep;
    import std.stdio;
    import std.conv;
    import std.math;

    writeln("Running Music unittest...");
    version (DSFML_Unittest_with_interaction)
    {
        writeln("\tYou should hear some music, otherwise there's a problem.");

        Music music = new Music();
        music.openFromFile("unittest/res/TestMusic.ogg");
        writeln("\tvolume=100");

        // Testing the status
        assert(music.status == Status.Stopped);
        music.play();
        assert(music.status == Status.Playing);
        sleep(seconds(2));
        music.pause();
        assert(music.status == Status.Paused);
        music.play();

        // Testing the volume
        int vol = 30;
        writefln("\tvolume=%s", vol);
        music.volume = vol;
        assert(round(music.volume) == vol);

        sleep(seconds(2));

        music.volume = 100; // Resetting default value

        // Testing the pitch
        int p = 2;
        writefln("\tpitch=%s", p);
        music.pitch = p;

        assert(round(music.pitch) == p);

        sleep(seconds(1));

        music.pitch = 1; // Resetting to the default value

        // Testing the position
        Vector3f pos = Vector3f(2, 2, 2);
        writefln("\tposition=%s", pos);
        music.position = pos;

        // waiting for https://github.com/dlang/dmd/pull/10200
        //assert(music.position == pos);

        sleep(seconds(2));

        music.position = Vector3f(0, 0, 0); // reset to the default value

        // Testing the offset
        Time offset = seconds(10);
        music.playingOffset = offset;

        assert(music.playingOffset == offset);
        writefln("\toffset=%s sec", offset.asSeconds());
        sleep(seconds(1));

        // Testing the loop
        assert(music.loop == false); // default value
        music.loop = true;
        assert(music.loop == true);
        writeln("\tloop=true");
        sleep(seconds(5));

        // Testing relativeToListener
        // Testing default value
        assert(music.relativeToListener == false);
        music.relativeToListener = true;
        assert(music.relativeToListener == true);
        writeln("\trelativeToListener=true");

        sleep(seconds(2));
        music.relativeToListener = false; // Resetting default value

        // Testing minDistance
        int md = 5;
        // Testing default value
        assert(music.minDistance == 1);
        music.minDistance = md;
        assert(music.minDistance == md);
        writefln("\tminDistance=%s", md);
        sleep(seconds(2));
        music.minDistance = 1; // Resetting default value

        // Testing attenuation
        int a = 100;
        writefln("\tattenuation=%s", a);
        music.attenuation = a;
        assert(music.attenuation == a);
        sleep(seconds(3));

        // Testing channelCount (stereo -> 2)
        assert(music.channelCount == 2);
        assert(music.sampleRate == 44100);

        // Duration of TestMusic.ogg
        assert(music.duration == microseconds(14407982));

        TimeSpan ts = TimeSpan(seconds(11), seconds(3));
        music.loopPoints = ts;
        writefln("\tloopPoints: %s", ts);
        assert(music.loopPoints == ts);

        sleep(seconds(5));
        music.stop();
    }
}
