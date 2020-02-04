module dsfml.extra.graphics.transform3;

import dsfml.system.vector3;

import std.math;

struct Transform3
{
    /*
     * <---- axis ---->
     *  X     Y     Z     T
     * --- | --- | --- | ---
     * a00 | a01 | a02 | a03
     * a10 | a11 | a12 | a13
     * a20 | a21 | a22 | a23
     * a30 | a31 | a32 | a33
     *
     * T = Translation
     * a30, a31 and a32 are always 0.
     * a33 is always 1.
     */
    private float[4 * 4] m_matrix;

    /// The identity transform (does nothing).
    static const Transform3 identity = Transform3([1.0f, 0.0f, 0.0f, 0.0f,
                                                   0.0f, 1.0f, 0.0f, 0.0f,
                                                   0.0f, 0.0f, 1.0f, 0.0f,
                                                   0.0f, 0.0f, 0.0f, 1.0f]);

    /// Construct a Transform3 from a 4x4 matrix.
    @nogc @safe
    this(float[4 * 4] matrix)
    {
        m_matrix = matrix;
    }

    /// ditto
    @nogc @safe
    this(float a00, float a01, float a02, float a03,
         float a10, float a11, float a12, float a13,
         float a20, float a21, float a22, float a23,
         float a30, float a31, float a32, float a33)
    {
        this([a00, a01, a02, a03,
              a10, a11, a12, a13,
              a20, a21, a22, a23,
              a30, a31, a32, a33]);
    }

    @nogc @safe
    float[4 * 4] matrix() const
    {
        return m_matrix;
    }

    /**
     * Overwrite the `*` operator.
     */
    @safe
    Transform3 opBinary(string op)(Transform3 other)
        if (op == "*")
    {
        return combine(other);
    }

    /**
     * Performs a scalar operation between two matrices.
     *
     * Returns: dot product.
     */
    @safe
    ref Transform3 combine(Transform3 other)
    {
        float[4 * 4] result;

        // Every line/column combination
        for (ubyte u = 0; u < 16; u += 4)
        {
            // index of `result`
            ubyte index = u;

            // Dot loop : Multiply the line and the column
            for (ubyte b = 0; b < 4; b++)
            {
                float dot_result = 0; // represents aXX
                ubyte column = b;

                /*
                 * Multiply "a line and a column".
                 *
                 * Once done, `dot_result` contains the dot of the line and the
                 * column.
                 */
                for (ubyte line = u; line < u + 4; line++)
                {
                    dot_result += m_matrix[line] * other.m_matrix[column];
                    // The column index is always 4 more
                    // line[0, 1, 2, 3] -> column[0, 4, 8, 12]
                    column += 4;
                }
                result[index] = dot_result;
                // increment index because `u` make 4 steps (`u += 4`)
                index++;
            }
        }
        m_matrix = result;
        return this;
    }

    // Copy from https://github.com/Dav1dde/gl3n/blob/master/gl3n/linalg.d
    // and https://github.com/g-truc/glm/blob/1498e094b95d1d89164c6442c632d775a2a1bab5/glm/ext/matrix_transform.inl
    ref Transform3 rotate(float angle, Vector3f axis)
    {
        // TODO: normalize vector

        float rad = angle * 3.141592654f / 180.0f;
        float cosr = cos(rad);
        float sinr = sin(rad);

        float[4 * 4] m = Transform3.identity.m_matrix;

        float x = axis.x;
        float y = axis.y;
        float z = axis.z;

        Vector3f mc = (1 - cosr) * axis;

        // https://www.khronos.org/registry/OpenGL-Refpages/gl2.1/xhtml/glRotate.xml

        m[0] = mc.x * x + cosr;
        m[1] = mc.x * y - z * sinr;
        m[2] = mc.x * z + y * sinr;

        m[4] = mc.y * x + z * sinr;
        m[5] = mc.y * y + cosr;
        m[6] = mc.y * z - x * sinr;

        m[8] = mc.z * x - y * sinr;
        m[9] = mc.z * y + x * sinr;
        m[10] = mc.z * z + cosr;

        combine(Transform3(m));
        return this;
    }

    ref Transform3 rotateX(float angle)
    {
        float rad = angle * 3.141592654f / 180.0f;
        float cosr = cos(rad);
        float sinr = sin(rad);

        float[4 * 4] rotx = Transform3.identity.m_matrix;

        rotx[5] = cosr;
        rotx[6] = sinr;
        rotx[9] = -sinr;
        rotx[10] = cosr;

        combine(Transform3(rotx));
        return this;
    }

    ref Transform3 rotateY(float angle)
    {
        float rad = angle * 3.141592654f / 180.0f;
        float cosr = cos(rad);
        float sinr = sin(rad);

        float[4 * 4] roty = Transform3.identity.m_matrix;

        roty[0] = cosr;
        roty[2] = -sinr;
        roty[8] = sinr;
        roty[10] = cosr;

        combine(Transform3(roty));
        return this;
    }

    ref Transform3 rotateZ(float angle)
    {
        float rad = angle * 3.141592654f / 180.0f;
        float cosr = cos(rad);
        float sinr = sin(rad);

        float[4 * 4] rotz = Transform3.identity.m_matrix;

        rotz[0] = cosr;
        rotz[1] = -sinr;
        rotz[4] = sinr;
        rotz[5] = cosr;

        combine(Transform3(rotz));
        return this;
    }

    ref Transform3 translate(Vector3f vector)
    {
        Transform3 transform = Transform3.identity;

        transform.m_matrix[3] = vector.x;
        transform.m_matrix[7] = vector.y;
        transform.m_matrix[11] = vector.z;

        combine(transform);

        return this;
    }

    ref Transform3 scale(Vector3f vector)
    {
        Transform3 transform = Transform3.identity;

        transform.m_matrix[0] = vector.x;
        transform.m_matrix[5] = vector.y;
        transform.m_matrix[10] = vector.z;

        combine(transform);

        return this;
    }
}

unittest
{
    import std.stdio;
    writeln("Running Transform3 unittest...");


    auto matrix1 = Transform3([5, 7, 9, 10,
                               2, 3, 3, 8,
                               8, 10, 2, 3,
                               3, 3, 4, 8]);

    auto matrix2 = Transform3([3, 10, 12, 18,
                               12, 1, 4, 9,
                               9, 10, 12, 2,
                               3, 12, 4, 10]);

    assert(matrix1 * matrix2 == Transform3([210, 267, 236, 271,
                                            93, 149, 104, 149,
                                            171, 146, 172, 268,
                                            105, 169, 128, 169]));

}
