/*
 * DSFML - The Simple and Fast Multimedia Library for D
 *
 * Copyright (c) 2013 - 2020 Jeremy DeHaan (dehaan.jeremiah@gmail.com)
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
module dsfml.graphics.renderstates;

import dsfml.graphics.blendmode;
import dsfml.graphics.shader;
import dsfml.graphics.texture;
import dsfml.graphics.transform;

import std.typecons : Rebindable;

/**
 * Define the states used for drawing to a RenderTarget.
 */
struct RenderStates
{
    /// The blending mode.
    BlendMode blendMode = BlendMode.Alpha;
    /// The transform.
    Transform transform = Transform();
    /// The texture.
    Texture texture = null;
    /// The shader.
    Shader shader = null;

    /**
     * Construct a default set of render states with a custom blend mode.
     *
     * Params:
     *      blendMode = Blend mode to use
     */
    @nogc @safe this(BlendMode blendMode)
    {
        this.blendMode = blendMode;
    }

    /**
     * Construct a default set of render states with a custom transform.
     *
     * Params:
     *      transform = Transform to use
     */
    @nogc @safe this(Transform transform)
    {
        this.transform = transform;
    }

    /**
     * Construct a default set of render states with a custom texture
     *
     * Params:
     *      texture = Texture to use
     */
    @nogc @safe this(Texture texture)
    {
        this.texture = texture;
    }

    /**
     * Construct a default set of render states with a custom shader
     *
     * Params:
     *      shader = Shader to use
     */
    @nogc @safe this(Shader shader)
    {
        this.shader = shader;
    }

    /**
     * Construct a set of render states with all its attributes
     *
     * Params:
     *      blendMode = Blend mode to use
     *      transform = Transform to use
     *      texture   = Texture to use
     *      shader    = Shader to use
     */
    @nogc @safe this(BlendMode blendMode, Transform transform, Texture texture, Shader shader)
    {
        this.blendMode = blendMode;
        this.transform = transform;
        this.texture = texture;
        this.shader = shader;
    }
}

@nogc @safe package sfRenderStates convertRenderStates(ref RenderStates states)
{
    if (states.texture is null && states.shader is null)
        return sfRenderStates(states.blendMode, states.transform.toc, null, null);
    else if (states.shader is null)
        return sfRenderStates(states.blendMode, states.transform.toc, states.texture.ptr, null);
    else if (states.texture is null)
        return sfRenderStates(states.blendMode, states.transform.toc, null, states.shader.ptr);
    else
        return sfRenderStates(states.blendMode, states.transform.toc,
                states.texture.ptr, states.shader.ptr);

}

package extern (C)
{
    struct sfRenderStates // @suppress(dscanner.style.phobos_naming_convention)
    {
        BlendMode blendMode; // Blending mode
        sfTransform transform; // Transform
        const sfTexture* texture; // Texture
        const sfShader* shader; // Shader
    }
}
