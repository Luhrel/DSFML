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
 * `SoundSource` is not meant to be used directly, it only serves as a common
 * base for all audio objects that can live in the audio environment.
 *
 * It defines several properties for the sound: pitch, volume, position,
 * attenuation, etc. All of them can be changed at any time with no impact on
 * performances.
 *
 * See_Also:
 *      $(SOUND_LINK), $(SOUNDSTREAM_LINK)
 */
module dsfml.audio.soundsource;

import dsfml.system.vector3;

/**
 * Interface defining a sound's properties.
 */
interface SoundSource
{
    /// Enumeration of the sound source states.
    enum Status
    {
        /// Sound is not playing.
        Stopped,
        /// Sound is paused.
        Paused,
        /// Sound is playing.
        Playing
    }

    alias Status this;

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
        void pitch(float _pitch);

        /**
         * Get the pitch of the sound.
         *
         * Returns:
         *      Pitch of the sound
         */
        float pitch();
    }

    @property
    {
        /**
         * Set the volume of the sound.
         *
         * The volume is a vlue between 0 (mute) and 100 (full volume). The default
         * value for the volume is 100.
         *
         * Params:
         *      _volume = Volume of the sound
         */
        void volume(float _volume);

        /**
         * Get the volume of the sound.
         *
         * Returns:
         *      Volume of the sound, in the range [0, 100]
         */
        float volume();
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
        void position(Vector3f _position);

        /**
         * Get the 3D position of the sound in the audio scene.
         *
         * Returns: Position of the sound
         */
        Vector3f position();
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
         *      relative = True to set the position relative, false to set it absolute
         */
        void relativeToListener(bool relative);

        /**
         * Tell whether the sound's position is relative to the listener or is absolute.
         *
         * Returns:
         *      true if the position is relative, false if it's absolute.
         */
        bool relativeToListener();
    }

    @property
    {
        /**
         * The minimum distance of the sound.
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
        void minDistance(float distance);

        /**
         * Get the minimum distance of the sound.
         *
         * Returns:
         *      Minimum distance of the sound
         */
        float minDistance();
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
         *      _attenuation = New attenuation factor of the sound
         *
         * See_Also:
         *      minDistance
         */
        void attenuation(float _attenuation);

        /**
         * Get the attenuation factor of the sound.
         *
         * Returns:
         *      Attenuation factor of the sound
         *
         * See_Also:
         *      minDistance
         */
        float attenuation();
    }

    @property
    {
        /**
         * Get the current status of the sound (stopped, paused, playing)
         *
         * Returns:
         *      Current status of the sound
         */
        Status status();
    }

    /**
     * Start or resume playing the sound source.
     *
     * This function starts the source if it was stopped, resumes it if it was
     * paused, and restarts it from the beginning if it was already playing.
     *
     * See_Also:
     *      pause, stop
     */
    void play();

    /**
     * Pause the sound source.
     *
     * This function pauses the source if it was playing, otherwise (source already
     * paused or stopped) it has no effect.
     *
     * See_Also:
     *      play, stop
     */
    void pause();

    /**
     * Stop playing the sound source.
     *
     * This function stops the source if it was playing or paused, and does nothing
     * if it was already stopped. It also resets the playing position (unlike
     * `pause()`).
     *
     * See_Also:
     *      play, pause
     */
    void stop();
}
