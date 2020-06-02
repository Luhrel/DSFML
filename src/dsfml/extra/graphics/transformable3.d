module dsfml.extra.graphics.transformable3;

import dsfml.system.vector3;
import dsfml.extra.graphics.transform3;

import std.math;

/*
 * Decomposed 3D transform defined by a position, a rotation, and a scale.
 */
class Transformable3
{
    private Vector3f m_position;
    private Vector3f m_rotation;
    private Vector3f m_scale;
    //private Vector3f m_origin;

    private Transform3 m_transform;
    private Transform3 m_inverseTransform;

    /*
     * TODO ; performance test: is it vital to store these variables ?
     * In a 3D world, values changes a lot.
     */
    bool m_transformNeedUpdate = true;
    bool m_inverseTransformNeedUpdate = true;

    this(Vector3f position = Vector3f(0, 0, 0),
         Vector3f rotation = Vector3f(0, 0, 0),
         Vector3f scale    = Vector3f(1, 1, 1))
    {
        m_position = position;
        m_rotation = rotation;
        m_scale = scale;
    }

    @property
    void position(Vector3f _position)
    {
        m_position = _position;
        m_transformNeedUpdate = true;
        m_inverseTransformNeedUpdate = true;
    }

    @property
    Vector3f position()
    {
        return m_position;
    }

    @property
    void rotation(Vector3f _rotation)
    {
        m_rotation = _rotation;
        m_transformNeedUpdate = true;
        m_inverseTransformNeedUpdate = true;
    }

    @property
    Vector3f rotation()
    {
        return m_rotation;
    }

    @property
    void scale(Vector3f _scale)
    {
        m_scale = _scale;
        m_transformNeedUpdate = true;
        m_inverseTransformNeedUpdate = true;
    }

    @property
    Vector3f scale()
    {
        return m_scale;
    }

    Transform3 transform()
    {
        // Recompute the combined transform if needed
        if (m_transformNeedUpdate)
        {
            Vector3f rad  = -m_rotation * 3.141592654f / 180f;
            float cosx = cos(rad.x);
            float cosy = cos(rad.y);
            float cosz = cos(rad.z);

            float sinx = sin(rad.x);
            float siny = sin(rad.y);
            float sinz = sin(rad.z);

            // TODO: positions won't work
            // Need to multiply pos by origin

            // X scale * Y rotation * Z rotation
            float a00 = m_scale.x * cosy * cosz;
            // Z rotation
            float a01 = -sinz;
            // Y rotation
            float a02 = siny;
            // X Position
            float a03 = m_position.x;
            // Z rotation
            float a10 = sinz;
            // Y scale * X rotation * Z rotation
            float a11 = m_scale.y * cosx * cosz;
            // X rotation
            float a12 = -sinx;
            // Y position
            float a13 = m_position.y;
            // Y rotation
            float a20 = -siny;
            // X rotation
            float a21 = sinx;
            // Z scale * X rotation * Y rotation
            float a22 = m_scale.z * cosx * cosy;
            // Z position
            float a23 = m_position.z;

            float a30 = 0;
            float a31 = 0;
            float a32 = 0;
            float a33 = 1;

            m_transform = Transform3(a00, a01, a02, a03,
                                     a10, a11, a12, a13,
                                     a20, a21, a22, a23,
                                     a30, a31, a32, a33);
            m_transformNeedUpdate = false;
        }
        return m_transform;
    }

    Transform3 inverseTransform()
    {
        if (m_inverseTransformNeedUpdate)
        {
            m_inverseTransform = transform().inverse();
            m_inverseTransformNeedUpdate = false;
        }
        return m_inverseTransform;
    }
}

unittest
{
    Transformable3 tf3 = new Transformable3();
    assert(tf3.transform == Transform3.identity);
}
