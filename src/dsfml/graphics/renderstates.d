module dsfml.graphics.renderstates;

import dsfml.graphics.blendmode;
import dsfml.graphics.transform;
import dsfml.graphics.texture;
import dsfml.graphics.shader;

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

    // Internal C struct copy. Cannot set to a pointer due to the const members.
    private sfRenderStates m_renderStates;

    /**
     * Construct a default set of render states with a custom blend mode.
     *
     * Params:
     *     theBlendMode = Blend mode to use
     */
    this(BlendMode theBlendMode)
    {
        blendMode = theBlendMode;

        m_renderStates = sfRenderStates(blendMode.toc, transform.toc, null, null);
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

        m_renderStates = sfRenderStates(blendMode.toc, transform.toc, null, null);
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

        m_renderStates = sfRenderStates(blendMode.toc, transform.toc, texture.ptr, null);
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

        m_renderStates = sfRenderStates(blendMode.toc, transform.toc, null, shader.ptr);
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

        m_renderStates = sfRenderStates(blendMode.toc, transform.toc, texture.ptr, shader.ptr);
    }

    // Returns a pointer to the C struct.
    package sfRenderStates* ptr()
    {
        return &m_renderStates;
    }
}

package extern(C)
{
    struct sfRenderStates
    {
        sfBlendMode blendMode; ///< Blending mode
        sfTransform transform; ///< Transform
        const sfTexture* texture; ///< Texture
        const sfShader* shader; ///< Shader
    }
}
