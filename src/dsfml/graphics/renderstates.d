module dsfml.graphics.renderstates;

import dsfml.graphics.blendmode;
import dsfml.graphics.transform;
import dsfml.graphics.texture;
import dsfml.graphics.shader;

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
     *     theBlendMode = Blend mode to use
     */
    this(BlendMode theBlendMode)
    {
        blendMode = theBlendMode;
    }

    /**
     * Construct a default set of render states with a custom transform.
     *
     * Params:
     *     theTransform = Transform to use
     */
    this(Transform theTransform)
    {
        transform = theTransform;
    }

    /**
     * Construct a default set of render states with a custom texture
     *
     * Params:
     *     theTexture = Texture to use
     */
    this(Texture theTexture)
    {
        texture = theTexture;
    }

    /**
     * Construct a default set of render states with a custom shader
     *
     * Params:
     * theShader = Shader to use
     */
    this(Shader theShader)
    {
        shader = theShader;
    }

    /**
     * Construct a set of render states with all its attributes
     *
     * Params:
     *     theBlendMode = Blend mode to use
     *     theTransform = Transform to use
     *     theTexture   = Texture to use
     *     theShader    = Shader to use
     */
    this(BlendMode theBlendMode, Transform theTransform, Texture theTexture, Shader theShader)
    {
        blendMode = theBlendMode;
        transform = theTransform;
        texture = theTexture;
        shader = theShader;
    }
}

package sfRenderStates convertRenderStates(ref RenderStates states)
{
    if (states.texture !is null && states.shader !is null)
        return sfRenderStates(states.blendMode, states.transform.toc, states.texture.ptr, states.shader.ptr);
    else if (states.shader is null)
        return sfRenderStates(states.blendMode, states.transform.toc, states.texture.ptr, null);
    else if (states.texture is null)
        return sfRenderStates(states.blendMode, states.transform.toc, null, states.shader.ptr);
    else
        return sfRenderStates(states.blendMode, states.transform.toc, null, null);
}

package extern(C)
{
    struct sfRenderStates
    {
        BlendMode blendMode; ///< Blending mode
        sfTransform transform; ///< Transform
        const sfTexture* texture; ///< Texture
        const sfShader* shader; ///< Shader
    }
}
