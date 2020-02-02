module dsfml.extra.graphics.transform3;

import dsfml.graphics.glsl;
import dsfml.system.vector3;

struct Transform3
{
    private Mat4 m_matrix;

    /// The identity transform (does nothing).
    static const Transform3 identity = Transform3([1.0f, 0.0f, 0.0f, 0.0f,
                                                   0.0f, 1.0f, 0.0f, 0.0f,
                                                   0.0f, 0.0f, 1.0f, 0.0f,
                                                   0.0f, 0.0f, 0.0f, 1.0f]);

    /// Construct a Transform3 from a 4x4 matrix.
    @nogc @safe
    this(float[4 * 4] matrix)
    {
        m_matrix = Mat4(matrix);
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
                    dot_result += m_matrix.array[line] * other.m_matrix.array[column];
                    // The column index is always 4 more
                    // line[0, 1, 2, 3] -> column[0, 4, 8, 12]
                    column += 4;
                }
                result[index] = dot_result;
                // increment index because `u` make 4 steps (`u += 4`)
                index++;
            }
        }
        m_matrix = Mat4(result);
        return this;
    }
}

unittest
{
    import std.stdio;
    writeln("Running Transform3 unittest...");


    auto matrix1 = new Transform3([5, 7, 9, 10,
                                   2, 3, 3, 8,
                                   8, 10, 2, 3,
                                   3, 3, 4, 8]);

    auto matrix2 = new Transform3([3, 10, 12, 18,
                                   12, 1, 4, 9,
                                   9, 10, 12, 2,
                                   3, 12, 4, 10]);

    assert(matrix1 * matrix2 == Transform3([210, 267, 236, 271,
                                            93, 149, 104, 149,
                                            171, 146, 172, 268,
                                            105, 169, 128, 169]));
}
