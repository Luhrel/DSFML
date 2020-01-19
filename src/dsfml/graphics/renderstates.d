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
     *      blendMode = Blend mode to use
     */
    this(BlendMode blendMode)
    {
        this.blendMode = blendMode;
    }

    /**
     * Construct a default set of render states with a custom transform.
     *
     * Params:
     *      transform = Transform to use
     */
    this(Transform transform)
    {
        this.transform = transform;
    }

    /**
     * Construct a default set of render states with a custom texture
     *
     * Params:
     *      texture = Texture to use
     */
    this(Texture texture)
    {
        this.texture = texture;
    }

    /**
     * Construct a default set of render states with a custom shader
     *
     * Params:
     *      shader = Shader to use
     */
    this(Shader shader)
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
    this(BlendMode blendMode, Transform transform, Texture texture, Shader shader)
    {
        this.blendMode = blendMode;
        this.transform = transform;
        this.texture = texture;
        this.shader = shader;
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
        BlendMode blendMode;      // Blending mode
        sfTransform transform;    // Transform
        const sfTexture* texture; // Texture
        const sfShader* shader;   // Shader
    }
}
