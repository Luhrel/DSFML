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
 * Shaders are programs written using a specific language, executed directly by
 * the graphics card and allowing one to apply real-time operations to the
 * rendered entities.
 *
 * There are three kinds of shaders:
 * - Vertex shaders, that process vertices
 * - Geometry shaders, that process primitives
 * - Fragment (pixel) shaders, that process pixels
 *
 * A `Shader` can be composed of either a vertex shader alone, a geometry
 * shader alone, a fragment shader alone, or any combination of them. (see the
 * variants of the load functions).
 *
 * Shaders are written in GLSL, which is a C-like language dedicated to OpenGL
 * shaders. You'll probably need to learn its basics before writing your own
 * shaders for DSFML.
 *
 * Like any D/C/C++ program, a GLSL shader has its own variables called uniforms
 * that you can set from your D application. `Shader` handles different types
 * of uniforms:
 * - scalars: float, int, bool
 * - vectors (2, 3 or 4 components)
 * - matrices (3x3 or 4x4)
 * - samplers (textures)
 *
 * Some DSFML-specific types can be converted:
 * - $(COLOR_LINK) as a 4D vector (`vec4`)
 * - $(TRANSFORM_LINK) as matrices (`mat3` or `mat4`)
 *
 * Every uniform variable in a shader can be set through one of the
 * `uniform()` or `uniformArray()` overloads. For example, if you have a
 * shader with the following uniforms:
 * ---
 * uniform float offset;
 * uniform vec3 point;
 * uniform vec4 color;
 * uniform mat4 matrix;
 * uniform sampler2D overlay;
 * uniform sampler2D current;
 * ---
 *
 * You can set their values from D code as follows, using the types
 * defined in the `dsfml.graphics.glsl` module:
 * ---
 * shader.uniform("offset", 2.f);
 * shader.uniform("point", Vector3f(0.5f, 0.8f, 0.3f));
 * shader.uniform("color", Vec4(color));
 * shader.uniform("matrix", Mat4(transform));
 * shader.uniform("overlay", texture);
 * shader.uniform("current", Shader.CurrentTexture);
 * ---
 *
 * The old `setParameter()` overloads are deprecated and will be removed
 * in a future version. You should use their `uniform()` equivalents instead.
 *
 * It is also worth noting that DSFML supports index overloads for
 * setting uniforms:
 * ---
 * shader["offset"] = 2.f;
 * shader["point"] = Vector3f(0.5f, 0.8f, 0.3f);
 * shader["color"] = Vec4(color);
 * shader["matrix"] = Mat4(transform);
 * shader["overlay"] = texture;
 * shader["current"] = Shader.CurrentTexture;
 * ---
 *
 * The special `Shader.CurrentTexture` argument maps the given
 * `sampler2D` uniform to the current texture of the object being drawn (which
 * cannot be known in advance).
 *
 * To apply a shader to a drawable, you must pass it as part of an additional
 * parameter to the `Window.draw()` function:
 * ---
 * RenderStates states;
 * states.shader = shader;
 * window.draw(sprite, states);
 * ---
 *
 * In the code above we pass a reference to the shader, because it may be
 * null (which means "no shader").
 *
 * Shaders can be used on any drawable, but some combinations are not
 * interesting. For example, using a vertex shader on a $(SPRITE_LINK) is
 * limited because there are only 4 vertices, the sprite would have to be
 * subdivided in order to apply wave effects.
 * Another bad example is a fragment shader with $(TEXT_LINK): the texture of
 * the text is not the actual text that you see on screen, it is a big texture
 * containing all the characters of the font in an arbitrary order; thus,
 * texture lookups on pixels other than the current one may not give you the
 * expected result.
 *
 * Shaders can also be used to apply global post-effects to the current contents
 * of the target. This can be done in two different ways:
 * - draw everything to a $(RENDERTEXTURE_LINK), then draw it to the main
 *   target using the shader
 * - draw everything directly to the main target, then use `Texture.update`
 *   to copy its contents to a texture and draw it to the main target using
 *   the shader
 *
 * The first technique is more optimized because it doesn't involve
 * retrieving the target's pixels to system memory, but the second one doesn't
 * impact the rendering process and can be easily inserted anywhere without
 * impacting all the code.
 *
 * Like $(TEXTURE_LINK) that can be used as a raw OpenGL texture, `Shader`
 * can also be used directly as a raw shader for custom OpenGL geometry.
 * ---
 * Shader.bind(shader);
 * ... render OpenGL geometry ...
 * Shader.bind(null);
 * ---
 *
 * See_Also:
 *      $(GLSL_LINK)
 */
module dsfml.graphics.shader;

import dsfml.graphics.texture;
import dsfml.graphics.transform;
import dsfml.graphics.color;
import dsfml.graphics.glsl;

import dsfml.system.inputstream;
import dsfml.system.vector2;
import dsfml.system.vector3;
import dsfml.system.err;

import std.string;

/**
 * Shader class (vertex and fragment).
 */
class Shader
{
    /// Types of shaders.
    enum Type
    {
        Vertex,  /// Vertex shader
        Geometry,/// Geometry shader
        Fragment /// Fragment (pixel) shader.
    }

    alias Type this;

    private sfShader* m_shader;

    /**
     * Special type that can be passed to uniform(), and that represents the
     * texture of the object being drawn.
     */
    struct CurrentTextureType
    {
        // Nothing to declare.
    }

    /**
     * Represents the texture of the object being drawn.
     *
     * See_Also:
     *      uniform
     */
    static CurrentTextureType currentTexture;

    /// Default constructor.
    this()
    {
        // Nothing to do.
    }

    /// Destructor.
    ~this()
    {
        sfShader_destroy(m_shader);
    }

    /**
     * Load the vertex, geometry, or fragment shader from a file.
     *
     * This function loads a single shader, vertex, geometry, or fragment,
     * identified by the second argument. The source must be a text file
     * containing a valid shader in GLSL language. GLSL is a C-like language
     * dedicated to OpenGL shaders; you'll probably need to read a good
     * documentation for it before writing your own shaders.
     *
     * Params:
     *      filename = Path of the vertex, geometry, or fragment shader file to load
     * 		type     = Type of shader (vertex geometry, or fragment)
     *
     * Returns:
     *      true if loading succeeded, false if it failed.
     *
     * See_Also:
     *      loadFromMemory, loadFromStream
     */
    bool loadFromFile(const(string) filename, Type type)
    {
        if (type == Type.Vertex)
            m_shader = sfShader_createFromFile(filename.toStringz, null, null);
        else if (type == Type.Geometry)
            m_shader = sfShader_createFromFile(null, filename.toStringz, null);
        else
            m_shader = sfShader_createFromFile(null, null, filename.toStringz);
        return m_shader != null;
    }

    /**
     * Load both the vertex and fragment shaders from files.
     *
     * This function loads both the vertex and the fragment shaders. If one of
     * them fails to load, the shader is left empty (the valid shader is
     * unloaded). The sources must be text files containing valid shaders in
     * GLSL language. GLSL is a C-like language dedicated to OpenGL shaders;
     * you'll probably need to read a good documentation for it before writing
     * your own shaders.
     *
     * Params:
     *      vertexShaderFilename   = Path of the vertex shader file to load
     * 		fragmentShaderFilename = Path of the fragment shader file to load
     *
     * Returns:
     *      true if loading succeeded, false if it failed.
     *
     * See_Also:
     *      loadFromMemory, loadFromStream
     */
    bool loadFromFile(const(string) vertexShaderFilename,
        const(string) fragmentShaderFilename)
    {
        m_shader = sfShader_createFromFile(vertexShaderFilename.toStringz, null,
            fragmentShaderFilename.ptr);
        return m_shader != null;
    }

    /**
     * Load the vertex, geometry, and fragment shaders from files.
     *
     * This function loads the vertex, geometry and the fragment shaders. If one
     * of them fails to load, the shader is left empty (the valid shader is
     * unloaded). The sources must be text files containing valid shaders in
     * GLSL language. GLSL is a C-like language dedicated to OpenGL shaders;
     * you'll probably need to read a good documentation for it before writing
     * your own shaders.
     *
     * Params:
     *      vertexShaderFilename   = Path of the vertex shader file to load
     * 		geometryShaderFilename = Path of the geometry shader file to load
     * 		fragmentShaderFilename = Path of the fragment shader file to load
     *
     * Returns: true if loading succeeded, false if it failed.
     * See_Also: loadFromMemory, loadFromStream
     */
    bool loadFromFile(const(string) vertexShaderFilename,
        const(string) geometryShaderFilename, const(string) fragmentShaderFilename)
    {
        m_shader = sfShader_createFromFile(vertexShaderFilename.toStringz,
            geometryShaderFilename.toStringz, fragmentShaderFilename.toStringz);
        return m_shader != null;
    }

    /**
     * Load the vertex, geometry, or fragment shader from a source code in memory.
     *
     * This function loads a single shader, vertex, geometry, or fragment,
     * identified by the second argument. The source code must be a valid shader
     * in GLSL language. GLSL is a C-like language dedicated to OpenGL shaders;
     * you'll probably need to read a good documentation for it before writing
     * your own shaders.
     *
     * Params:
     * 		shader = String containing the source code of the shader
     * 		type   = Type of shader (vertex geometry, or fragment)
     *
     * Returns:
     *      true if loading succeeded, false if it failed.
     *
     * See_Also:
     *      loadFromFile, loadFromStream
     */
    bool loadFromMemory(const(string) shader, Type type)
    {
        if (type == Type.Vertex)
            m_shader = sfShader_createFromMemory(shader.toStringz, null, null);
        else if (type == Type.Geometry)
            m_shader = sfShader_createFromMemory(null, shader.toStringz, null);
        else
            m_shader = sfShader_createFromMemory(null, null, shader.toStringz);
        return m_shader != null;
    }

    /**
     * Load both the vertex and fragment shaders from source codes in memory.
     *
     * This function loads both the vertex and the fragment shaders. If one of
     * them fails to load, the shader is left empty (the valid shader is
     * unloaded). The sources must be valid shaders in GLSL language. GLSL is a
     * C-like language dedicated to OpenGL shaders; you'll probably need to read
     * a good documentation for it before writing your own shaders.
     *
     * Params:
     *      vertexShader   = String containing the source code of the vertex shader
     *      fragmentShader = String containing the source code of the fragment
     *                       shader
     *
     * Returns:
     *      true if loading succeeded, false if it failed.
     *
     * See_Also:
     *      loadFromFile, loadFromStream
     */
    bool loadFromMemory(const(string) vertexShader, const(string) fragmentShader)
    {
        m_shader =  sfShader_createFromMemory(vertexShader.toStringz, null, fragmentShader.toStringz);
        return m_shader != null;
    }

    /**
     * Load the vertex, geometry and fragment shaders from source codes in memory.
     *
     * This function loads the vertex, geometry and the fragment shaders. If one of
     * them fails to load, the shader is left empty (the valid shader is
     * unloaded). The sources must be valid shaders in GLSL language. GLSL is a
     * C-like language dedicated to OpenGL shaders; you'll probably need to read
     * a good documentation for it before writing your own shaders.
     *
     * Params:
     *      vertexShader   = String containing the source code of the vertex shader
     *      geometryShader = String containing the source code of the geometry shader
     *      fragmentShader = String containing the source code of the fragment
     *                       shader
     *
     * Returns:
     *      true if loading succeeded, false if it failed.
     *
     * See_Also:
     *      loadFromFile, loadFromStream
     */
    bool loadFromMemory(const(string) vertexShader, const(string) geometryShader,
        const(string) fragmentShader)
    {
        m_shader = sfShader_createFromMemory(vertexShader.toStringz,
            geometryShader.toStringz, fragmentShader.toStringz);
        return m_shader != null;
    }
    /**
     * Load the vertex, geometry or fragment shader from a custom stream.
     *
     * This function loads a single shader, either vertex, geometry or fragment,
     * identified by the second argument. The source code must be a valid shader
     * in GLSL language. GLSL is a C-like language dedicated to OpenGL shaders;
     * you'll probably need to read a good documentation for it before writing
     * your own shaders.
     *
     * Params:
     *      stream = Source stream to read from
     * 		type   = Type of shader (vertex, geometry or fragment)
     *
     * Returns:
     *      true if loading succeeded, false if it failed.
     *
     * See_Also:
     *      loadFromFile, loadFromMemory
     */
    @nogc
    bool loadFromStream(InputStream stream, Type type)
    {
        if (type == Type.Vertex)
            m_shader = sfShader_createFromStream(stream.ptr, null, null);
        else if (type == Type.Geometry)
            m_shader = sfShader_createFromStream(null, stream.ptr, null);
        else
            m_shader = sfShader_createFromStream(null, null, stream.ptr);
        return m_shader != null;
    }

    /**
     * Load both the vertex and fragment shaders from custom streams.
     *
     * This function loads a single shader, either vertex or fragment,
     * identified by the second argument. The source code must be a valid shader
     * in GLSL language. GLSL is a C-like language dedicated to OpenGL shaders;
     * you'll probably need to read a good documentation for it before writing
     * your own shaders.
     *
     * Params:
     *      vertexShaderStream	 = Source stream to read the vertex shader from
     *      fragmentShaderStream = Source stream to read the fragment shader from
     *
     * Returns:
     *      true if loading succeeded, false if it failed.
     *
     * See_Also:
     *      loadFromFile, loadFromMemory
     */
    @nogc
    bool loadFromStream(InputStream vertexShaderStream, InputStream fragmentShaderStream)
    {
        m_shader = sfShader_createFromStream(vertexShaderStream.ptr, null, fragmentShaderStream.ptr);
        return m_shader != null;
    }

    /**
     * Load the vertex, geometry and fragment shaders from custom streams.
     *
     * This function loads a single shader, either vertex, geometry or fragment,
     * identified by the second argument. The source code must be a valid shader
     * in GLSL language. GLSL is a C-like language dedicated to OpenGL shaders;
     * you'll probably need to read a good documentation for it before writing
     * your own shaders.
     *
     * Params:
     *      vertexShaderStream   = Source stream to read the vertex shader from
     *      geometryShaderStream = Source stream to read the geometry shader from
     * 	    fragmentShaderStream = Source stream to read the fragment shader from
     *
     * Returns:
     *      true if loading succeeded, false if it failed.
     *
     * See_Also:
     *      loadFromFile, loadFromMemory
     */
    @nogc
    bool loadFromStream(InputStream vertexShaderStream, InputStream geometryShaderStream, InputStream fragmentShaderStream)
    {
        m_shader = sfShader_createFromStream(vertexShaderStream.ptr, geometryShaderStream.ptr, fragmentShaderStream.ptr);
        return m_shader != null;
    }

    /**
     * Specify value for x uniform.
     *
     * `x` parameter can be: `float`, `Vec2`, `Vec3`, `Vec4`, `Color`, `int`,
     * `Ivec2`, `Ivec3`, `Ivec4`, `bool`, `Bvec2`, `Bvec3`, `Bvec4`, `Mat3*`,
     * `Mat4*`, `Texture`, `CurrentTextureType`
     *
     * See original SFML's documentation for more informations.
     *
     * Params:
     *      name = Name of the uniform variable in GLSL
     *      x    = Value of the numeric scalar
     */
    void uniform(T)(const(string) name, T x)
    {
        if (m_shader is null)
            return;

        static if(is(T == float))
            sfShader_setFloatUniform(m_shader, name.toStringz, cast(float) x);
        else static if(is(T == Vec2))
            sfShader_setVec2Uniform(m_shader, name.toStringz, cast(Vec2) x);
        else static if(is(T == Vec3))
            sfShader_setVec3Uniform(m_shader, name.toStringz, cast(Vec3) x);
        else static if(is(T == Vec4))
            sfShader_setVec4Uniform(m_shader, name.toStringz, cast(Vec4) x);
        else static if(is(T == Color))
            sfShader_setColorUniform(m_shader, name.toStringz, cast(Color) x);
        else static if(is(T == int))
            sfShader_setIntUniform(m_shader, name.toStringz, cast(int) x);
        else static if(is(T == Ivec2))
            sfShader_setIvec2Uniform(m_shader, name.toStringz, cast(Ivec2) x);
        else static if(is(T == Ivec3))
            sfShader_setIvec3Uniform(m_shader, name.toStringz, cast(Ivec3) x);
        else static if(is(T == Ivec4))
            sfShader_setIvec4Uniform(m_shader, name.toStringz, cast(Ivec4) x);
        else static if(is(T == bool))
            sfShader_setBoolUniform(m_shader, name.toStringz, cast(bool) x);
        else static if(is(T == Bvec2))
            sfShader_setBvec2Uniform(m_shader, name.toStringz, cast(Bvec2) x);
        else static if(is(T == Bvec3))
            sfShader_setBvec3Uniform(m_shader, name.toStringz, cast(Bvec3) x);
        else static if(is(T == Bvec4))
            sfShader_setBvec4Uniform(m_shader, name.toStringz, cast(Bvec4) x);
        else static if(is(T == Mat3))
            sfShader_setMat3Uniform(m_shader, name.toStringz, &(cast(Mat3) x));
        else static if(is(T == Mat4))
            sfShader_setMat4Uniform(m_shader, name.toStringz, &(cast(Mat4) x));
        else static if(is(T == Texture))
            sfShader_setTextureUniform(m_shader, name.toStringz, (cast(Texture) x).ptr);
        else static if(is(T == CurrentTextureType))
            sfShader_setCurrentTextureUniform(m_shader, name.toStringz);
        else
            err.writefln("Template uniform(T)(const(string) name, T x) doesn't support type %s.", T);
    }

    /**
     * Specify value for an array uniform.
     *
     * Params:
     *      name  = Name of the uniform variable in GLSL
     * 	    array = Value of the vector
     */
    void uniformArray(T)(const(string) name, ref T[] array)
    {
        if (m_shader is null)
            return;

        static if(is(T == float))
            sfShader_setFloatUniformArray(m_shader, name.toStringz, &array, array.length);
        else static if(is(T == Vec2))
            sfShader_setVec2UniformArray(m_shader, name.toStringz, &array, array.length);
        else static if(is(T == Vec3))
            sfShader_setVec3UniformArray(m_shader, name.toStringz, &array, array.length);
        else static if(is(T == Vec4))
            sfShader_setVec4UniformArray(m_shader, name.toStringz, &array, array.length);
        else static if(is(T == Mat3))
            sfShader_setMat3UniformArray(m_shader, name.toStringz, &array, array.length);
        else static if(is(T == Mat4))
            sfShader_setMat4UniformArray(m_shader, name.toStringz, &array, array.length);
        else
            err.writefln("Template uniformArray(T)(const(string) name, ref T[] array) doesn't support type %s.", T);
    }

    deprecated("Please use uniform(T)(const(string) name, T x) template instead.")
    {
        /**
         * Change a T parameter of the shader.
         *
         * Params:
         *      name	= The name of the variable to change in the shader.
         *                The corresponding parameter in the shader must be
         *                a float (float GLSL type).
         *      x		= Value to assign
         */
        void setParameter(T)(const(string) name, T x)
        {
            if (m_shader is null)
                return;

            static if(is(T == Vector2f))
                sfShader_setVector2Parameter(m_shader, name.ptr, cast(Vector2f) x);
            else static if(is(T == Vector3f))
                sfShader_setVector3Parameter(m_shader, name.ptr, cast(Vector3f) x);
            else static if(is(T == Color))
                sfShader_setColorParameter(m_shader, name.ptr, cast(Color) x);
            else static if(is(T == Transform))
                sfShader_setTransformParameter(m_shader, name.ptr, (cast(Transform) x).marshal);
            else static if(is(T == Texture))
                sfShader_setTextureParameter(m_shader, name.ptr, (cast(Texture) x).ptr);
            else static if(is(T == CurrentTextureType))
                sfShader_setCurrentTextureParameter(m_shader, name.ptr);
            else static if(is(T == float))
                sfShader_setFloatParameter(m_shader, name.ptr, cast(float) x);
            else
                err.writefln("Template setParameter(T)(const(string) name, ref T[] array) doesn't support type %s.", T);
        }
/*
        void setParameter(const(string) name, float x, float y)
        {
            sfShader_setFloat2Parameter(m_shader, name.ptr, x, y);
        }

        void setParameter(const(string) name, float x, float y, float z, float w)
        {
            sfShader_setFloat3Parameter(m_shader, name.ptr, x, y, z);
        }

        void setParameter(const(string) name, float x, float y, float z, float w)
        {
            sfShader_setFloat4Parameter(m_shader, name.ptr, x, y, z, w);
        }
*/
    }

    /**
     * Bind a shader for rendering.sfGlslVec4
     *
     * This function is not part of the graphics API, it mustn't be used when
     * drawing SFML entities. It must be used only if you mix Shader with OpenGL
     * code.
     * ---
     * Shader s1, s2;
     * //...
     * Shader.bind(s1);
     * // draw OpenGL stuff that use s1...
     * Shader.bind(s2);
     * // draw OpenGL stuff that use s2...
     * Shader.bind(null);
     * // draw OpenGL stuff that use no shader...
     * ---
     *
     * Params:
     *      shader = Shader to bind. Can be null to use no shader.
     */
    @nogc
    static void bind(Shader shader)
    {
        sfShader_bind(shader.ptr);
    }

    /**
     * Tell whether or not the system supports shaders.sfGlslVec4
     *
     * This function should always be called before using the shader features.
     * If it returns false, then any attempt to use Shader will fail.
     *
     * Returns:
     *      true if shaders are supported, false otherwise.
     */
    @nogc
    static bool isAvailable()
    {
        return sfShader_isAvailable();
    }

    /**
     * Tell whether or not the system supports geometry shaders.
     *
     * This function should always be called before using the geometry shader
     * features. If it returns false, then any attempt to use Shader geometry
     * shader features will fail.
     *
     * This function can only return true if isAvailable() would also return
     * true, since shaders in general have to be supported in order for geometry
     * shaders to be supported as well.
     *
     * Note: The first call to this function, whether by your code or SFML will
     * result in a context switch.
     *
     * Returns:
     *      true if geometry shaders are supported, false otherwise.
     */
    @nogc
    static bool isGeometryAvailable()
    {
        return sfShader_isGeometryAvailable();
    }

    /**
     * Get the underlying OpenGL handle of the shader.
     *
     * You shouldn't need to use this function, unless you have very specific
     * stuff to implement that SFML doesn't support, or implement a temporary
     * workaround until a bug is fixed.
     *
     * Returns:
     *      OpenGL handle of the shader or 0 if not yet loaded
     */
    @nogc
    uint nativeHandle() const
    {
        if (m_shader is null)
            return 0;
        return sfShader_getNativeHandle(m_shader);
    }

    // Retuns the C pointer
    @property @nogc
    package sfShader* ptr()
    {
        return m_shader;
    }
}

package extern(C)
{
    struct sfShader;
}

@nogc
private extern(C)
{
    sfShader* sfShader_createFromFile(const char* vertexShaderFilename, const char* geometryShaderFilename, const char* fragmentShaderFilename);
    sfShader* sfShader_createFromMemory(const char* vertexShader, const char* geometryShader, const char* fragmentShader);
    sfShader* sfShader_createFromStream(sfInputStream* vertexShaderStream, sfInputStream* geometryShaderStream, sfInputStream* fragmentShaderStream);
    void sfShader_destroy(sfShader* shader);

    void sfShader_setFloatUniform(sfShader* shader, const char* name, float x);
    void sfShader_setVec2Uniform(sfShader* shader, const char* name, Vec2 vector);
    void sfShader_setVec3Uniform(sfShader* shader, const char* name, Vec3 vector);
    void sfShader_setVec4Uniform(sfShader* shader, const char* name, Vec4 vector);
    void sfShader_setColorUniform(sfShader* shader, const char* name, Color color);
    void sfShader_setIntUniform(sfShader* shader, const char* name, int x);
    void sfShader_setIvec2Uniform(sfShader* shader, const char* name, Ivec2 vector);
    void sfShader_setIvec3Uniform(sfShader* shader, const char* name, Ivec3 vector);
    void sfShader_setIvec4Uniform(sfShader* shader, const char* name, Ivec4 vector);
    // useless ; SFML has no setUniform with Color parameter
    //void sfShader_setIntColorUniform(sfShader* shader, const char* name, Color color);
    void sfShader_setBoolUniform(sfShader* shader, const char* name, bool x);
    void sfShader_setBvec2Uniform(sfShader* shader, const char* name, Bvec2 vector);
    void sfShader_setBvec3Uniform(sfShader* shader, const char* name, Bvec3 vector);
    void sfShader_setBvec4Uniform(sfShader* shader, const char* name, Bvec4 vector);
    void sfShader_setMat3Uniform(sfShader* shader, const char* name, const Mat3* matrix);
    void sfShader_setMat4Uniform(sfShader* shader, const char* name, const Mat4* matrix);
    void sfShader_setTextureUniform(sfShader* shader, const char* name, const sfTexture* texture);
    void sfShader_setCurrentTextureUniform(sfShader* shader, const char* name);

    void sfShader_setFloatUniformArray(sfShader* shader, const char* name, const float* scalarArray, size_t length);
    void sfShader_setVec2UniformArray(sfShader* shader, const char* name, const Vec2* vectorArray, size_t length);
    void sfShader_setVec3UniformArray(sfShader* shader, const char* name, const Vec3* vectorArray, size_t length);
    void sfShader_setVec4UniformArray(sfShader* shader, const char* name, const Vec4* vectorArray, size_t length);
    void sfShader_setMat3UniformArray(sfShader* shader, const char* name, const Mat3* matrixArray, size_t length);
    void sfShader_setMat4UniformArray(sfShader* shader, const char* name, const Mat4* matrixArray, size_t length);

    uint sfShader_getNativeHandle(const sfShader* shader);
    void sfShader_bind(const sfShader* shader);
    bool sfShader_isAvailable();
    bool sfShader_isGeometryAvailable();

    // Deprecated :

    void sfShader_setFloatParameter(sfShader* shader, const char* name, float x);
    void sfShader_setFloat2Parameter(sfShader* shader, const char* name, float x, float y);
    void sfShader_setFloat3Parameter(sfShader* shader, const char* name, float x, float y, float z);
    void sfShader_setFloat4Parameter(sfShader* shader, const char* name, float x, float y, float z, float w);
    void sfShader_setVector2Parameter(sfShader* shader, const char* name, Vector2f vector);
    void sfShader_setVector3Parameter(sfShader* shader, const char* name, Vector3f vector);
    void sfShader_setColorParameter(sfShader* shader, const char* name, Color color);
    void sfShader_setTransformParameter(sfShader* shader, const char* name, sfTransform transform);
    void sfShader_setTextureParameter(sfShader* shader, const char* name, const sfTexture* texture);
    void sfShader_setCurrentTextureParameter(sfShader* shader, const char* name);
}

unittest
{
    import std.stdio;
    import dsfml.graphics.glsl;
    //writeln("Running Shader unittest...");

    auto shader = new Shader();

    // 10200 ? segfault
    /*
    shader.uniform("test", Mat3([0, 0, 0,
                                 0, 0, 0,
                                 0, 0, 0]));
    shader.uniform("test", Mat4([0, 0, 0, 0,
                                 0, 0, 0, 0,
                                 0, 0, 0, 0,
                                 0, 0, 0, 0]));
    */
}
