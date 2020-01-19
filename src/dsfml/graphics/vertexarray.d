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
 * `VertexArray` is a very simple wrapper around a dynamic array of vertices
 * and a primitives type.
 *
 * It inherits $(DRAWABLE_LINK), but unlike other drawables it is not
 * transformable.
 *
 * Example:
 * ---
 * VertexArray lines = New VertexArray(PrimitiveType.LineStrip, 4);
 * lines[0].position = Vector2f(10, 0);
 * lines[1].position = Vector2f(20, 0);
 * lines[2].position = Vector2f(30, 5);
 * lines[3].position = Vector2f(40, 2);
 *
 * window.draw(lines);
 * ---
 *
 * See_Also:
 *      $(VERTEX_LINK)
 */
module dsfml.graphics.vertexarray;

import dsfml.graphics.vertex;
import dsfml.graphics.primitivetype;
import dsfml.graphics.rect;
import dsfml.graphics.drawable;
import dsfml.graphics.rendertarget;
import dsfml.graphics.renderstates;

import dsfml.system.vector2;

/**
 * Define a set of one or more 2D primitives.
 */
class VertexArray : Drawable
{
    private sfVertexArray* m_vertexArray;

    /**
     * Default constructor
     *
     * Creates an empty vertex array.
     */
    this()
    {
        m_vertexArray = sfVertexArray_create();
    }

    /**
     * Construct the vertex array with a type and an initial number of vertices
     *
     * Params:
     *      type        = Type of primitives
     *      vertexCount = Initial number of vertices in the array
     */
    this(PrimitiveType type, size_t vertexCount = 0)
    {
        this();
        primitiveType = type;
        resize(vertexCount);
    }

    // Copy constructor.
    package this(const sfVertexArray* vertexArrayPointer)
    {
        m_vertexArray = sfVertexArray_copy(vertexArrayPointer);
    }

    /// Destructor.
    ~this()
    {
        sfVertexArray_destroy(m_vertexArray);
    }

    /**
     * Compute the bounding rectangle of the vertex array.
     *
     * This function returns the axis-aligned rectangle that contains all the
     * vertices of the array.
     *
     * Returns:
     *      Bounding rectangle of the vertex array.
     */
    @property
    FloatRect bounds() const
    {
        return sfVertexArray_getBounds(cast(sfVertexArray*) m_vertexArray);
    }

    /**
     * Set the type of primitives to draw.
     *
     * This function defines how the vertices must be interpreted when it's time
     * to draw them:
     * - As points
     * - As lines
     * - As triangles
     * - As quads
     *
     * The default primitive type is PrimitiveType.Points.
     *
     * Params:
     *      type = Type of primitive
     */
    @property
    void primitiveType(PrimitiveType type)
    {
        sfVertexArray_setPrimitiveType(m_vertexArray, type);
    }

    /**
     * Get the type of primitives drawn by the vertex array.
     *
     * Returns:
     *      Primitive type
     */
    @property
    PrimitiveType primitiveType() const
    {
        return sfVertexArray_getPrimitiveType(cast(sfVertexArray*) m_vertexArray);
    }

    /**
     * Return the vertex count.
     *
     * Returns:
     *      Number of vertices in the array
     */
    ulong vertexCount() const
    {
        return sfVertexArray_getVertexCount(m_vertexArray);
    }

    /**
     * Add a vertex to the array.
     *
     * Params:
     *      vertex = Vertex to add.
     */
    void append(Vertex vertex)
    {
        sfVertexArray_append(m_vertexArray, vertex);
    }

    /**
     * Clear the vertex array.
     *
     * This function removes all the vertices from the array. It doesn't
     * deallocate the corresponding memory, so that adding new vertices after
     * clearing doesn't involve reallocating all the memory.
     */
    void clear()
    {
        sfVertexArray_clear(m_vertexArray);
    }

    /**
     * Draw the object to a render target.
     *
     * Params:
     *      renderTarget = Render target to draw to
     *  	renderStates = Current render states
     */
    override void draw(RenderTarget renderTarget, RenderStates renderStates)
    {
        renderTarget.draw(this, renderStates);
    }

    /**
     * Resize the vertex array.
     *
     * If vertexCount is greater than the current size, the previous vertices
     * are kept and new (default-constructed) vertices are added. If vertexCount
     * is less than the current size, existing vertices are removed from the
     * array.
     *
     * Params:
     * 		vertexCount	= New size of the array (number of vertices).
     */
    void resize(size_t vertexCount)
    {
        sfVertexArray_resize(m_vertexArray, vertexCount);
    }

    /**
     * Get a read-write access to a vertex by its index
     *
     * This function doesn't check index, it must be in range
     * [0, `vertexCount()` - 1]. The behavior is undefined otherwise.
     *
     * Params:
     *      index = Index of the vertex to get
     *
     * Returns:
     *      Reference to the index-th vertex.
     */
    ref Vertex opIndex(size_t index)
    {
        return *sfVertexArray_getVertex(m_vertexArray, index);
    }

    /// Overrides the $ attribute.
    @property
    ulong opDollar(size_t dim)()
    {
        return vertexCount;
    }

    // Returns the C pointer.
    package sfVertexArray* ptr()
    {
        return m_vertexArray;
    }

    /// Duplicates this VertexArray.
    @property
    VertexArray dup()
    {
        return new VertexArray(m_vertexArray);
    }
}

package extern(C)
{
    struct sfVertexArray;
}

private extern(C)
{
    sfVertexArray* sfVertexArray_create();
    sfVertexArray* sfVertexArray_copy(const sfVertexArray* vertexArray);
    void sfVertexArray_destroy(sfVertexArray* vertexArray);
    size_t sfVertexArray_getVertexCount(const sfVertexArray* vertexArray);
    Vertex* sfVertexArray_getVertex(sfVertexArray* vertexArray, size_t index);
    void sfVertexArray_clear(sfVertexArray* vertexArray);
    void sfVertexArray_resize(sfVertexArray* vertexArray, size_t vertexCount);
    void sfVertexArray_append(sfVertexArray* vertexArray, Vertex vertex);
    void sfVertexArray_setPrimitiveType(sfVertexArray* vertexArray, PrimitiveType type);
    PrimitiveType sfVertexArray_getPrimitiveType(sfVertexArray* vertexArray);
    FloatRect sfVertexArray_getBounds(sfVertexArray* vertexArray);
}

unittest
{
    import std.stdio;
    import dsfml.graphics.color;
    writeln("Running VertexArray unittest...");

    auto va = new VertexArray(PrimitiveType.Triangles, 2);
    assert(va.vertexCount == 2);
    assert(va.primitiveType == PrimitiveType.Triangles);

    auto v0 = Vertex(Vector2f(2, 6));
    auto v1 = Vertex(Vector2f(1, 3));
    auto v2 = Vertex(Vector2f(4, 5));
    va[0] = v0;
    assert(va[0] == v0);
    va[1] = v1;
    assert(va[1] == v1);
    va.append(v2);
    assert(va[2] == v2);

    assert(va.bounds == FloatRect(1, 3, 3, 3));
    va.clear();
}
