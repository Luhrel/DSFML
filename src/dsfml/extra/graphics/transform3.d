module dsfml.extra.graphics.transform3;

import dsfml.system.vector3;

import std.math;

/*
 * Represents a 4x4 matrix.
 */
struct Transform3
{
    /*
     *    <---- axis ---->
     *   |  X  |  Y  |  Z  |  T
     *   | --- | --- | --- | ---
     * X | a00 | a01 | a02 | a03
     * Y | a10 | a11 | a12 | a13
     * Z | a20 | a21 | a22 | a23
     *   | a30 | a31 | a32 | a33
     *
     * T = Translation
     * a30, a31 and a32 are always 0.
     * a33 is always 1.
     */
    float[4 * 4] matrix;

    /// The identity transform (does nothing).
    static const Transform3 identity = Transform3([1.0f, 0.0f, 0.0f, 0.0f,
                                                   0.0f, 1.0f, 0.0f, 0.0f,
                                                   0.0f, 0.0f, 1.0f, 0.0f,
                                                   0.0f, 0.0f, 0.0f, 1.0f]);

    /// Construct a Transform3 from a 4x4 matrix.
    @nogc @safe
    this(float[4 * 4] matrix)
    {
        this.matrix = matrix;
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

    /**
     * Performs a scalar operation between two matrices.
     *
     * Returns: dot product.
     */
    @safe
    ref Transform3 combine(Transform3 other) return
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
                    dot_result += matrix[line] * other.matrix[column];
                    // The column index is always 4 more
                    // line[0, 1, 2, 3] -> column[0, 4, 8, 12]
                    column += 4;
                }
                result[index] = dot_result;
                // increment index because `u` make 4 steps (`u += 4`)
                index++;
            }
        }
        matrix = result;
        return this;
    }

    // Copy from https://github.com/Dav1dde/gl3n/blob/master/gl3n/linalg.d
    // and https://github.com/g-truc/glm/blob/1498e094b95d1d89164c6442c632d775a2a1bab5/glm/ext/matrix_transform.inl
    ref Transform3 rotate(float angle, Vector3f axis) return
    {
        // TODO: normalize vector

        float rad = angle * 3.141592654f / 180.0f;
        float cosr = cos(rad);
        float sinr = sin(rad);

        float[4 * 4] m = Transform3.identity.matrix;

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

    ref Transform3 rotateX(float angle) return
    {
        float rad = angle * 3.141592654f / 180.0f;
        float cosr = cos(rad);
        float sinr = sin(rad);

        float[4 * 4] rotx = Transform3.identity.matrix;

        rotx[5] = cosr;
        rotx[6] = sinr;
        rotx[9] = -sinr;
        rotx[10] = cosr;

        combine(Transform3(rotx));
        return this;
    }

    ref Transform3 rotateY(float angle) return
    {
        float rad = angle * 3.141592654f / 180.0f;
        float cosr = cos(rad);
        float sinr = sin(rad);

        float[4 * 4] roty = Transform3.identity.matrix;

        roty[0] = cosr;
        roty[2] = -sinr;
        roty[8] = sinr;
        roty[10] = cosr;

        combine(Transform3(roty));
        return this;
    }

    ref Transform3 rotateZ(float angle) return
    {
        float rad = angle * 3.141592654f / 180.0f;
        float cosr = cos(rad);
        float sinr = sin(rad);

        float[4 * 4] rotz = Transform3.identity.matrix;

        rotz[0] = cosr;
        rotz[1] = -sinr;
        rotz[4] = sinr;
        rotz[5] = cosr;

        combine(Transform3(rotz));
        return this;
    }

    ref Transform3 translate(Vector3f vector) return
    {
        Transform3 transform = Transform3.identity;

        transform.matrix[3] = vector.x;
        transform.matrix[7] = vector.y;
        transform.matrix[11] = vector.z;

        combine(transform);

        return this;
    }

    ref Transform3 scale(Vector3f vector) return
    {
        Transform3 transform = Transform3.identity;

        transform.matrix[0] = vector.x;
        transform.matrix[5] = vector.y;
        transform.matrix[10] = vector.z;

        combine(transform);

        return this;
    }

    Transform3 inverse()
    {
        // https://en.wikipedia.org/wiki/Minor_(linear_algebra)#Inverse_of_a_matrix
        float[4 * 4] m = matrix;
        float[4 * 4] inv;

        // Column 0 (aX0)

        inv[0] = m[5]  * m[10] * m[15] - m[5]  * m[11] * m[14] -
                 m[9]  * m[6]  * m[15] + m[9]  * m[7]  * m[14] +
                 m[13] * m[6]  * m[11] - m[13] * m[7]  * m[10];

        inv[4] = -m[4]  * m[10] * m[15] + m[4]  * m[11] * m[14] +
                  m[8]  * m[6]  * m[15] - m[8]  * m[7]  * m[14] -
                  m[12] * m[6]  * m[11] + m[12] * m[7]  * m[10];

        inv[8] = m[4]  * m[9] * m[15] - m[4]  * m[11] * m[13] -
                 m[8]  * m[5] * m[15] + m[8]  * m[7]  * m[13] +
                 m[12] * m[5] * m[11] - m[12] * m[7]  * m[9];

        inv[12] = -m[4]  * m[9] * m[14] + m[4]  * m[10] * m[13] +
                   m[8]  * m[5] * m[14] - m[8]  * m[6]  * m[13] -
                   m[12] * m[5] * m[10] + m[12] * m[6]  * m[9];

        float det = m[0] * inv[0] + m[1] * inv[4] +
                    m[2] * inv[8] + m[3] * inv[12];

        // Invalid matrix
        if (det == 0)
        {
            return identity;
        }

        // Column 1 (aX1)

        inv[1] = -m[1]  * m[10] * m[15] + m[1]  * m[11] * m[14] +
                  m[9]  * m[2]  * m[15] - m[9]  * m[3]  * m[14] -
                  m[13] * m[2]  * m[11] + m[13] * m[3]  * m[10];

        inv[5] = m[0]  * m[10] * m[15] - m[0]  * m[11] * m[14] -
                 m[8]  * m[2]  * m[15] + m[8]  * m[3]  * m[14] +
                 m[12] * m[2]  * m[11] - m[12] * m[3]  * m[10];

        inv[9] = -m[0]  * m[9] * m[15] + m[0]  * m[11] * m[13] +
                  m[8]  * m[1] * m[15] - m[8]  * m[3]  * m[13] -
                  m[12] * m[1] * m[11] + m[12] * m[3]  * m[9];

        inv[13] = m[0]  * m[9] * m[14] - m[0]  * m[10] * m[13] -
                  m[8]  * m[1] * m[14] + m[8]  * m[2]  * m[13] +
                  m[12] * m[1] * m[10] - m[12] * m[2]  * m[9];

        // Column 2 (aX2)

        inv[2] = m[1]  * m[6] * m[15] - m[1]  * m[7] * m[14] -
                 m[5]  * m[2] * m[15] + m[5]  * m[3] * m[14] +
                 m[13] * m[2] * m[7]  - m[13] * m[3] * m[6];

        inv[6] = -m[0]  * m[6] * m[15] + m[0]  * m[7] * m[14] +
                  m[4]  * m[2] * m[15] - m[4]  * m[3] * m[14] -
                  m[12] * m[2] * m[7]  + m[12] * m[3] * m[6];

        inv[10] = m[0]  * m[5] * m[15] - m[0]  * m[7] * m[13] -
                  m[4]  * m[1] * m[15] + m[4]  * m[3] * m[13] +
                  m[12] * m[1] * m[7]  - m[12] * m[3] * m[5];

        inv[14] = -m[0]  * m[5] * m[14] + m[0]  * m[6] * m[13] +
                   m[4]  * m[1] * m[14] - m[4]  * m[2] * m[13] -
                   m[12] * m[1] * m[6]  + m[12] * m[2] * m[5];

        // Column 3 (aX3)

        inv[3] = -m[1] * m[6] * m[11] + m[1] * m[7] * m[10] +
                  m[5] * m[2] * m[11] - m[5] * m[3] * m[10] -
                  m[9] * m[2] * m[7]  + m[9] * m[3] * m[6];

        inv[7] = m[0] * m[6] * m[11] - m[0] * m[7] * m[10] -
                 m[4] * m[2] * m[11] + m[4] * m[3] * m[10] +
                 m[8] * m[2] * m[7]  - m[8] * m[3] * m[6];

        inv[11] = -m[0] * m[5] * m[11] + m[0] * m[7] * m[9] +
                   m[4] * m[1] * m[11] - m[4] * m[3] * m[9] -
                   m[8] * m[1] * m[7]  + m[8] * m[3] * m[5];

        inv[15] = m[0] * m[5] * m[10] - m[0] * m[6] * m[9] -
                  m[4] * m[1] * m[10] + m[4] * m[2] * m[9] +
                  m[8] * m[1] * m[6]  - m[8] * m[2] * m[5];

        float odet = 1.0 / det;
        float[4 * 4] result;

        for (ubyte b = 0; b < 16; b++)
        {
            result[b] = inv[b] * odet;
        }

        return Transform3(result);
    }

    /**
     * Overwrite the `*` and `/` operators.
     */
    @safe
    Transform3 opBinary(string op)(Transform3 other)
        if (op == "*" || op == "/")
    {
        static if (op == "*")
            return Transform3(matrix).combine(other);
        else static if (op == "/")
            return Transform3(matrix).combine(other.inverse());
    }

    /**
     * Overwrite the `*=` and `/=` operators.
     */
    @safe
    Transform3 opOpAssign(string op)(Transform3 other)
        if (op == "*" || op == "/")
    {
        static if (op == "*")
            return combine(other);
        else static if (op == "/")
            return combine(other.inverse());
    }

    /**
     * Overwrite the `==` operator.
     */
    @nogc @safe
    bool opEquals(float[16] matrix)
    {
        return this.matrix == matrix;
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

    Transform3 inv = matrix2.inverse();
    float[] invResult = [-47/906f,  104/1359f, 53/2718f,  28/1359f,
                          -7/151f,  -14/453f,   19/906f,   97/906f,
                          85/1208f, -11/302f,   73/1208f, -16/151f,
                          13/302f,   13/453f,  -25/453f,   7/906f];

    for (ubyte b = 0; b < 16; b++)
    {
        assert(approxEqual(inv.matrix[b], invResult[b]));
    }
}
