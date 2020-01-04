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
 * Sound is the class used to play sounds.
 *
 * It provides:
 * $(UL
 * $(LI Control (play, pause, stop))
 * $(LI Ability to modify output parameters in real-time (pitch, volume, ...))
 * $(LI 3D spatial features (position, attenuation, ...)))
 *
 * $(PARA
 * Sound is perfect for playing short sounds that can fit in memory and require
 * no latency, like foot steps or gun shots. For longer sounds, like background
 * musics or long speeches, rather see Music (which is based on streaming).
 *
 * In order to work, a sound must be given a buffer of audio data to play. Audio
 * data (samples) is stored in SoundBuffer, and attached to a sound with the
 * setBuffer() function. The buffer object attached to a sound must remain alive
 * as long as the sound uses it. Note that multiple sounds can use the same
 * sound buffer at the same time.
 *)
 *
 * Example:
 * ---
 * auto buffer = new SoundBuffer();
 * buffer.loadFromFile("sound.wav");
 *
 * auto sound = new Sound();
 * sound.setBuffer(buffer);
 * sound.play();
 * ---
 *
 * See_Also:
 * $(SOUNDBUFFER_LINK), $(MUSIC_LINK)
 */
module dsfml.audio.sound;

import dsfml.audio.soundbuffer;
import dsfml.audio.soundsource;
import dsfml.system.vector3;
import dsfml.system.time;

/**
 * Regular sound that can be played in the audio environment.
 */
class Sound : SoundSource
{
    private sfSound* m_sound;

    /// Default constructor.
    this()
    {
        m_sound = sfSound_create();
    }

    /**
     * Construct the sound with a buffer.
     *
     * Params:
     *    buffer = Sound buffer containing the audio data to play with the sound
     */
    this(SoundBuffer theBuffer)
    {
        this();
        buffer = theBuffer;
    }

    /// Destructor.
    ~this()
    {
        sfSound_destroy(m_sound);
    }

    @property
    {
        /**
         * Whether or not the sound should loop after reaching the end.
         *
         * If set, the sound will restart from beginning after reaching the end and
         * so on, until it is stopped or setLoop(false) is called.
         *
         * The default looping state for sound is false.
         *
         * Params:
         * loop=True to play in loop, false to play once
         */
        void loop(bool loop)
        {
            sfSound_setLoop(m_sound, loop);
        }

        /**
         * Tell whether or not the sound is in loop mode.
         *
         * Returns
         * True if the sound is looping, false otherwise
         */
        bool loop() const
        {
            return sfSound_getLoop(m_sound);
        }
    }

    @property
    {
        /**
         * Change the current playing position (from the beginning) of the sound.
         *
         * The playing position can be changed when the sound is either paused or
         * playing. Changing the playing position when the sound is stopped has no
         * effect, since playing the sound will reset its position.
         *
         * Params:
         * timeOffset=New playing position, from the beginning of the sound
         */
        void playingOffset(Time offset)
        {
            sfSound_setPlayingOffset(m_sound, offset);
        }

        /**
         * Get the current playing position of the sound.
         *
         * Returns: Current playing position, from the beginning of the sound
         */
        Time playingOffset() const
        {
            return sfSound_getPlayingOffset(m_sound);
        }
    }

    @property
    {
        /**
         * Get the current status of the sound (stopped, paused, playing).
         *
         * Returns: Current status of the sound
         */
        Status status() const
        {
            return cast(Status) sfSound_getStatus(m_sound);
        }
    }

    //from SoundSource
    @property
    {
        /**
         * The pitch of the sound.
         *
         * The pitch represents the perceived fundamental frequency of a sound; thus
         * you can make a sound more acute or grave by changing its pitch. A side
         * effect of changing the pitch is to modify the playing speed of the sound
         * as well. The default value for the pitch is 1.
         * Params:
         * pitch=New pitch to apply to the sound
         */
        void pitch(float newPitch)
        {
            sfSound_setPitch(m_sound, newPitch);
        }

        /**
         * Get the pitch of the sound.
         *
         * Returns: Pitch of the sound
         */
        float pitch() const
        {
            return sfSound_getPitch(m_sound);
        }
    }

    @property
    {
        /**
         * Set the volume of the sound.
         *
         * The volume is a value between 0 (mute) and 100 (full volume). The
         * default value for the volume is 100.
         *
         * Params:
         * volume=Volume of the sound
         */
        void volume(float newVolume)
        {
            sfSound_setVolume(m_sound, newVolume);
        }

        /**
         * Get the volume of the sound.
         *
         * Returns: Volume of the sound, in the range [0, 100]
         */
        float volume() const
        {
            return sfSound_getVolume(m_sound);
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
         * position=Position of the sound in the scene
         */
        void position(Vector3f position)
        {
            sfSound_setPosition(m_sound, position);
        }

        /**
         * Get the 3D position of the sound in the audio scene.
         *
         * Returns: Position of the sound
         */
        Vector3f position() const
        {
            return cast(Vector3f) sfSound_getPosition(m_sound);
        }
    }

    @property
    {
        /**
         * Make the sound's position relative to the listener or absolute.
         *
         * Making a sound relative to the listener will ensure that it will always
         * be played the same way regardless the position of the listener.  This can
         * be useful for non-spatialized sounds, sounds that are produced by the
         * listener, or sounds attached to it. The default value is false
         * (position is absolute).
         *
         * Params:
         * relative=True to set the position relative, false to set it absolute
         */
        void relativeToListener(bool relative)
        {
            sfSound_setRelativeToListener(m_sound, relative);
        }

        /**
         * Tell whether the sound's position is relative to the listener or is absolute.
         *
         * Returns: True if the position is relative, false if it's absolute

         */
        bool relativeToListener() const
        {
            return sfSound_isRelativeToListener(m_sound);
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
         * distance=New minimum distance of the sound
         * See_Also: attenuation
         */
        void minDistance(float distance)
        {
            sfSound_setMinDistance(m_sound, distance);
        }

        /**
         * Get the minimum distance of the sound.
         *
         * Returns
         * Minimum distance of the sound
         * See_Also: attenuation
         */
        float minDistance() const
        {
            return sfSound_getMinDistance(m_sound);
        }
    }

    @property
    {
        /**
         * The attenuation factor of the sound.
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
         * attenuation=New attenuation factor of the sound
         * See_Also: minDistance
         */
        void attenuation(float newAttenuation)
        {
            sfSound_setAttenuation(m_sound, newAttenuation);
        }

        /**
         * Get the attenuation factor of the sound.
         *
         * Returns: Attenuation factor of the sound
         * See_Also: minDistance
         */
        float attenuation() const
        {
            return sfSound_getAttenuation(m_sound);
        }
    }

    @property
    {
        /*
         * Set the source buffer containing the audio data to play.
         *
         * It is important to note that the sound buffer is not copied, thus the
         * SoundBuffer instance must remain alive as long as it is attached to the
         * sound.
         *
         * Params:
         *         buffer=Sound buffer to attach to the sound
         */
        void buffer(SoundBuffer newBuffer)
        {
            sfSound_setBuffer(m_sound, newBuffer.ptr);
        }

        /**
         * Get the audio buffer attached to the sound.
         *
         * Returns: Sound buffer attached to the sound (can be NULL)
         */
        SoundBuffer buffer()
        {
            return new SoundBuffer(cast(sfSoundBuffer*) sfSound_getBuffer(m_sound));
        }
    }

    /**
     * Pause the sound.
     *
     * This function pauses the sound if it was playing, otherwise
     * (sound already paused or stopped) it has no effect.
     *
     * See_Also: play, pause
     */
    void pause()
    {
        sfSound_pause(m_sound);
    }

    /**
     * Start or resume playing the sound.
     *
     * This function starts the stream if it was stopped, resumes it if it was
     * paused, and restarts it from beginning if it was it already playing.
     *
     * This function uses its own thread so that it doesn't block the rest of
     * the program while the sound is played.
     *
     * See_Also: pause, stop
     */
    void play()
    {
        sfSound_play(m_sound);
    }

    /**
     * Stop playing the sound.
     *
     * This function stops the sound if it was playing or paused, and does
     * nothing if it was already stopped. It also resets the playing position
     * (unlike `pause()`).
     *
     * See_Also: play, pause
     */
    void stop()
    {
        sfSound_stop(m_sound);
    }
}

// CSFML's functions.
private extern(C)
{
    struct sfSound;

    sfSound* sfSound_create();
    sfSound* sfSound_copy(const sfSound* sound);
    void sfSound_destroy(sfSound* sound);
    void sfSound_play(sfSound* sound);
    void sfSound_pause(sfSound* sound);
    void sfSound_stop(sfSound* sound);
    void sfSound_setBuffer(sfSound* sound, const sfSoundBuffer* buffer);
    const(sfSoundBuffer)* sfSound_getBuffer(const sfSound* sound);
    void sfSound_setLoop(sfSound* sound, bool loop);
    bool sfSound_getLoop(const sfSound* sound);
    Status sfSound_getStatus(const sfSound* sound);
    void sfSound_setPitch(sfSound* sound, float pitch);
    void sfSound_setVolume(sfSound* sound, float volume);
    void sfSound_setPosition(sfSound* sound, Vector3f position);
    void sfSound_setRelativeToListener(sfSound* sound, bool relative);
    void sfSound_setMinDistance(sfSound* sound, float distance);
    void sfSound_setAttenuation(sfSound* sound, float attenuation);
    void sfSound_setPlayingOffset(sfSound* sound, Time timeOffset);
    float sfSound_getPitch(const sfSound* sound);
    float sfSound_getVolume(const sfSound* sound);
    Vector3f sfSound_getPosition(const sfSound* sound);
    bool sfSound_isRelativeToListener(const sfSound* sound);
    float sfSound_getMinDistance(const sfSound* sound);
    float sfSound_getAttenuation(const sfSound* sound);
    Time sfSound_getPlayingOffset(const sfSound* sound);
}

unittest
{
    import dsfml.system.sleep;
    import std.stdio;
    import std.conv;

    writeln("Running Sound unittest...");
    version (DSFML_Unittest_with_interaction)
    {
        writeln("\tYou should hear some music, otherwise there's a problem.");

        // first, get a sound buffer
        SoundBuffer soundbuffer = new SoundBuffer();
        assert(soundbuffer.loadFromFile("unittest/res/The Paragon Axis - Spirits of Fall.wav"));
        Sound sound = new Sound(soundbuffer);
        writeln("\tvolume=100"); // (default value)

        // Testing the status
        assert(sound.status == Status.Stopped);
        sound.play();
        assert(sound.status == Status.Playing);
        sleep(seconds(3));
        sound.pause();
        assert(sound.status == Status.Paused);
        sound.play();

        // Testing the volume
        int vol = 30;
        writefln("\tvolume=%s", vol);
        sound.volume = vol;
        // to!string because: https://issues.dlang.org/show_bug.cgi?id=5570
        // waiting for https://github.com/dlang/dmd/pull/10200
        assert(sound.volume.to!string == vol.to!string);
        sleep(seconds(2));
        sound.volume = 100; // Resetting default value

        // Testing the pitch
        int p = 2;
        writefln("\tpitch=%s", p);
        sound.pitch = p;
        // to!string because: https://issues.dlang.org/show_bug.cgi?id=5570
        // waiting for https://github.com/dlang/dmd/pull/10200
        assert(sound.pitch.to!string == p.to!string);
        sleep(seconds(3));
        sound.pitch = 1; // Resetting to the default value

        // Testing the position
        Vector3f pos = Vector3f(2, 2, 2);
        writefln("\tposition=%s", pos);
        sound.position = pos;
        // waiting for https://github.com/dlang/dmd/pull/10200
        //assert(sound.position == pos);
        sleep(seconds(4));
        sound.position = Vector3f(0, 0, 0); // reset to the default value

        // Testing the offset
        Time offset = seconds(213);
        sound.playingOffset = offset;
        // waiting for https://github.com/dlang/dmd/pull/10200
        //assert(sound.playingOffset == offset);
        writefln("\toffset=%s sec", offset.asSeconds());
        sleep(seconds(5));

        // Testing the loop
        assert(sound.loop == false); // default value
        sound.loop = true;
        assert(sound.loop == true);
        writeln("\tloop=true");
        sleep(seconds(5));

        // Testing relativeToListener
        // Testing default value
        assert(sound.relativeToListener == false);
        sound.relativeToListener = true;
        assert(sound.relativeToListener == true);
        writeln("\trelativeToListener=true");
        sleep(seconds(2));
        sound.relativeToListener = false; // Resetting default value

        // Testing minDistance
        int md = 5;
        // Testing default value
        assert(sound.minDistance == 1);
        sound.minDistance = md;
        assert(sound.minDistance == md);
        writefln("\tminDistance=%s", md);
        sleep(seconds(2));
        sound.minDistance = 1; // Resetting default value

        // Testing attenuation
        int a = 5;
        writefln("\tattenuation=%s", a);
        sound.attenuation = a;
        assert(sound.attenuation == a);
        sleep(seconds(5));
        sound.stop();
        assert(sound.status == Status.Stopped);
    }
}
