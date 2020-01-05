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
 * VertexBuffer is a simple wrapper around a dynamic buffer of vertices and a
 * primitives type.
 *
 * Unlike VertexArray, the vertex data is stored in graphics memory.
 *
 * In situations where a large amount of vertex data would have to be
 * transferred from system memory to graphics memory every frame, using
 * VertexBuffer can help. By using a VertexBuffer, data that has not been
 * changed between frames does not have to be re-transferred from system to
 * graphics memory as would be the case with VertexArray. If data transfer is a
 * bottleneck, this can lead to performance gains.
 *
 * Using VertexBuffer, the user also has the ability to only modify a portion of
 * the buffer in graphics memory. This way, a large buffer can be allocated at
 * the start of the application and only the applicable portions of it need to
 * be updated during the course of the application. This allows the user to take
 * full control of data transfers between system and graphics memory if they
 * need to.
 *
 * In special cases, the user can make use of multiple threads to update vertex
 * data in multiple distinct regions of the buffer simultaneously. This might
 * make sense when e.g. the position of multiple objects has to be recalculated
 * very frequently. The computation load can be spread across multiple threads
 * as long as there are no other data dependencies.
 *
 * Simultaneous updates to the vertex buffer are not guaranteed to be carried
 * out by the driver in any specific order. Updating the same region of the
 * buffer from multiple threads will not cause undefined behaviour, however the
 * final state of the buffer will be unpredictable.
 *
 * Simultaneous updates of distinct non-overlapping regions of the buffer are
 * also not guaranteed to complete in a specific order. However, in this case
 * the user can make sure to synchronize the writer threads at well-defined
 * points in their code. The driver will make sure that all pending data
 * transfers complete before the vertex buffer is sourced by the rendering
 * pipeline.
 *
 * It inherits Drawable, but unlike other drawables it is not transformable.
 *
 * Example:
 * ---
 * Vertex[15] vertices;
 * //...
 * VertexBuffer triangles = new VertexBuffer(PrimitiveType.Triangles);
 * triangles.create(15);
 * triangles.update(vertices);
 * //...
 * window.draw(triangles);
 * ---
 * See_Also: Vertex, VertexArray
 */
module dsfml.graphics.vertexbuffer;

import dsfml.graphics.drawable;
import dsfml.graphics.vertex;
import dsfml.graphics.primitivetype;
import dsfml.graphics.rendertarget;
import dsfml.graphics.renderstates;

/**
 * Vertex buffer storage for one or more 2D primitives.
 */
class VertexBuffer : Drawable
{
    /**
     * Usage specifiers.
     *
     * If data is going to be updated once or more every frame, set the usage to
     * Stream. If data is going to be set once and used for a long time without
     * being modified, set the usage to Static. For everything else Dynamic
     * should be a good compromise.
     */
    enum Usage
    {
        /// Constantly changing data.
        Stream,
        /// Occasionally changing data.
        Dynamic,
        /// Rarely changing data.
        Static
    }

    alias Usage this;

    private sfVertexBuffer* m_vertexBuffer;

    /**
     * Construct a VertexBuffer with a specific usage specifier.
     *
     * Creates an empty vertex buffer and sets its usage to usage.
     *
     * Params:
     *     usage = Usage specifier
     */
    this(Usage usage)
    {
        this(PrimitiveType.Points, usage);
    }

    /**
     * Construct a VertexBuffer with a specific PrimitiveType and usage specifier.
     *
     * Creates an empty vertex buffer and sets its primitive type to type and usage to usage.
     *
     * Params:
     *     type  = Type of primitive
     *     usage = Usage specifier
     */
    this(PrimitiveType type = PrimitiveType.Points, Usage usage = Usage.Stream)
    {
        m_vertexBuffer = sfVertexBuffer_create(0, type, usage);
    }

    /*
     * Copy constructor.
     *
     * Params:
     *     vertexBufferPointer = C pointer to sfVertexBuffer to assign
     */
    package this(const sfVertexBuffer* vertexBufferPointer)
    {
        m_vertexBuffer = sfVertexBuffer_copy(vertexBufferPointer);
    }

    /// Desructor.
    ~this()
    {
        sfVertexBuffer_destroy(m_vertexBuffer);
    }

    /**
     * Bind a vertex buffer for rendering.
     *
     * This function is not part of the graphics API, it mustn't be used when
     * drawing SFML entities. It must be used only if you mix VertexBuffer with
     * OpenGL code.
     * ---
     * VertexBuffer vb1, vb2;
     * //...
     * VertexBuffer.bind(vb1);
     * // draw OpenGL stuff that use vb1...
     * VertexBuffer.bind(vb2);
     * // draw OpenGL stuff that use vb2...
     * VertexBuffer.bind(NULL);
     * // draw OpenGL stuff that use no vertex buffer...
     *
     * Params:
     *     vertexBuffer = Pointer to the vertex buffer to bind, can be null to use no vertex buffer
     */
    static void bind(VertexBuffer vertexBuffer)
    {
        sfVertexBuffer_bind(vertexBuffer.ptr);
    }

    /**
     * Create the vertex buffer.
     *
     * Creates the vertex buffer and allocates enough graphics memory to hold
     * vertexCount vertices. Any previously allocated memory is freed in the
     * process.
     *
     * In order to deallocate previously allocated memory pass 0 as vertexCount.
     * Don't forget to recreate with a non-zero value when graphics memory
     * should be allocated again.
     *
     * Params:
     *     vertexCount = Number of vertices worth of memory to allocate
     * Returns: True if creation was successful
     */
    bool create(uint vertexCount)
    {
        m_vertexBuffer = sfVertexBuffer_create(vertexCount, primitiveType, usage);
        return m_vertexBuffer != null;
    }

    /**
     * Get the underlying OpenGL handle of the vertex buffer.
     *
     * You shouldn't need to use this function, unless you have very specific
     * stuff to implement that SFML doesn't support, or implement a temporary
     * workaround until a bug is fixed.
     *
     * Returns: OpenGL handle of the vertex buffer or 0 if not yet created
     */
    @property
    uint nativeHandle() const
    {
        return sfVertexBuffer_getNativeHandle(cast(sfVertexBuffer*) m_vertexBuffer);
    }

    /**
     * Get the type of primitives drawn by the vertex buffer.
     *
     * Returns: Primitive type
     */
    @property
    PrimitiveType primitiveType() const
    {
        return sfVertexBuffer_getPrimitiveType(m_vertexBuffer);
    }

    /**
     * Set the type of primitives to draw.
     *
     * This function defines how the vertices must be interpreted when it's time
     * to draw them.
     *
     * The default primitive type is sf::Points.
     *
     * Params:
     *     type = Type of primitive
     */
    @property
    void primitiveType(PrimitiveType type)
    {
        sfVertexBuffer_setPrimitiveType(m_vertexBuffer, type);
    }

    /**
     * Get the usage specifier of this vertex buffer.
     *
     * Returns: Usage specifier
     */
    @property
    Usage usage() const
    {
        return sfVertexBuffer_getUsage(m_vertexBuffer);
    }

    /**
     * Set the usage specifier of this vertex buffer.
     *
     * This function provides a hint about how this vertex buffer is going to be used in terms of data update frequency.
     *
     * After changing the usage specifier, the vertex buffer has to be updated with new data for the usage specifier to take effect.
     *
     * The default primitive type is sf::VertexBuffer::Stream.
     *
     * Params:
     *     usage = Usage specifier
     */
    @property
    void usage(Usage newUsage)
    {
        sfVertexBuffer_setUsage(m_vertexBuffer, newUsage);
    }

    /**
     * Return the vertex count.
     *
     * Returns: Number of vertices in the vertex buffer
     */
    @property
    size_t vertexCount() const
    {
        return sfVertexBuffer_getVertexCount(m_vertexBuffer);
    }

    /**
     * Tell whether or not the system supports vertex buffers.
     *
     * This function should always be called before using the vertex buffer
     * features. If it returns false, then any attempt to use VertexBuffer will
     * fail.
     *
     * Returns: True if vertex buffers are supported, false otherwise
     */
    static bool isAvailable()
    {
        return sfVertexBuffer_isAvailable();
    }

    /**
     * Swap the contents of this vertex buffer with those of another.
     *
     * Params:
     *     right = Instance to swap with
     */
    void swap(VertexBuffer right)
    {
        sfVertexBuffer_swap(m_vertexBuffer, right.ptr);
    }

    /**
     * Update the whole buffer from an array of vertices.
     *
     * The vertex array is assumed to have the same size as the created buffer.
     *
     * No additional check is performed on the size of the vertex array, passing
     * invalid arguments will lead to undefined behavior.
     *
     * This function does nothing if vertices is null or if the buffer was not
     * previously created.
     *
     * Params:
     *     vertices = Array of vertices to copy to the buffer
     * Returns: True if the update was successful
     */
    bool update(Vertex[] vertices)
    {
        return update(vertices, cast(uint) vertices.length, 0);
    }

    /**
     * Update a part of the buffer from an array of vertices.
     *
     * offset is specified as the number of vertices to skip from the beginning
     * of the buffer.
     *
     * If offset is 0 and vertexCount is equal to the size of the currently
     * created buffer, its whole contents are replaced.
     *
     * If offset is 0 and vertexCount is greater than the size of the currently
     * created buffer, a new buffer is created containing the vertex data.
     *
     * If offset is 0 and vertexCount is less than the size of the currently
     * created buffer, only the corresponding region is updated.
     *
     * If offset is not 0 and offset + vertexCount is greater than the size of
     * the currently created buffer, the update fails.
     *
     * No additional check is performed on the size of the vertex array, passing
     * invalid arguments will lead to undefined behavior.
     *
     * Params:
     *     vertices    = Array of vertices to copy to the buffer
     *     vertexCount = Number of vertices to copy
     *     offset      = Offset in the buffer to copy to
     * Returns: True if the update was successful
     */
    bool update(Vertex[] vertices, uint vertexCount, uint offset)
    {
        return sfVertexBuffer_update(m_vertexBuffer, vertices.ptr, vertexCount, offset);
    }

    /**
     * Copy the contents of another buffer into this buffer.
     *
     * Params:
     *     vertexBuffer = Vertex buffer whose contents to copy into this vertex buffer
     * Returns: True if the copy was successful
     */
    bool update(VertexBuffer vertexBuffer)
    {
        return sfVertexBuffer_updateFromVertexBuffer(m_vertexBuffer, vertexBuffer.ptr);
    }

    /**
     * Draw the vertex buffer to a render target
     *
     * Params:
     *     target = Render target to draw to
     *     states = Current render states
     */
    void draw(RenderTarget target, RenderStates states)
    {
        target.draw(this, states);
    }

    // Returns the C pointer
    package sfVertexBuffer* ptr()
    {
        return m_vertexBuffer;
    }

    /// Duplicates this VertexBuffer.
    @property
    VertexBuffer dup()
    {
        return new VertexBuffer(m_vertexBuffer);
    }
}

package extern(C)
{
    struct sfVertexBuffer;
}

private extern(C)
{
    sfVertexBuffer* sfVertexBuffer_create(uint vertexCount, PrimitiveType type, VertexBuffer.Usage usage);
    sfVertexBuffer* sfVertexBuffer_copy(const sfVertexBuffer* vertexBuffer);
    void sfVertexBuffer_destroy(sfVertexBuffer* vertexBuffer);
    uint sfVertexBuffer_getVertexCount(const sfVertexBuffer* vertexBuffer);
    bool sfVertexBuffer_update(sfVertexBuffer* vertexBuffer, const(Vertex)* vertices, uint vertexCount, uint offset);
    bool sfVertexBuffer_updateFromVertexBuffer(sfVertexBuffer* vertexBuffer, const sfVertexBuffer* other);
    void sfVertexBuffer_swap(sfVertexBuffer* left, sfVertexBuffer* right);
    uint sfVertexBuffer_getNativeHandle(sfVertexBuffer* vertexBuffer);
    void sfVertexBuffer_setPrimitiveType(sfVertexBuffer* vertexBuffer, PrimitiveType type);
    PrimitiveType sfVertexBuffer_getPrimitiveType(const sfVertexBuffer* vertexBuffer);
    void sfVertexBuffer_setUsage(sfVertexBuffer* vertexBuffer, VertexBuffer.Usage usage);
    VertexBuffer.Usage sfVertexBuffer_getUsage(const sfVertexBuffer* vertexBuffer);
    void sfVertexBuffer_bind(const sfVertexBuffer* vertexBuffer);
    bool sfVertexBuffer_isAvailable();
}

unittest
{
    import std.stdio;
    import dsfml.graphics.vertexarray;
    import dsfml.graphics.color;
    import dsfml.system.vector2;
    writeln("Running VertexBuffer unittest...");

    assert(VertexBuffer.isAvailable());

    auto vb = new VertexBuffer();

    assert(vb.primitiveType == PrimitiveType.Points);
    assert(vb.usage == VertexBuffer.Stream);
    assert(vb.vertexCount == 0);

    vb.create(1);
    assert(vb.vertexCount == 1);

    auto va = new VertexArray();
    va.append(Vertex(Vector2f(1, 2)));
    va.append(Vertex(Vector2f(3, 4), Color.Red));
    assert(vb.update([va[0], va[1]]));
    assert(vb.vertexCount == 2);

    auto vb2 = new VertexBuffer(PrimitiveType.Quads, VertexBuffer.Dynamic);
    vb.swap(vb2);

    assert(vb.primitiveType == PrimitiveType.Quads);
    assert(vb.usage == VertexBuffer.Dynamic);
    assert(vb2.primitiveType == PrimitiveType.Points);
    assert(vb2.usage == VertexBuffer.Stream);

    auto va2 = new VertexArray();
    va2.append(Vertex(Vector2f(0, 9), Color.Blue));
    assert(vb.update([va2[0]]));

    assert(vb.update(vb2));

    // The size of vb is 1. update() doesn't resize to buffer.
    // Maybe a bug because update() returned true.
    // Got the same results in c++.
    assert(vb.vertexCount == 1);

    assert(vb.nativeHandle() != 0);

    // TODO: bind()
}
