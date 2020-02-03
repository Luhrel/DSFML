module dsfml.extra.graphics.vertex3;

import dsfml.graphics.color;
import dsfml.system.vector2;
import dsfml.system.vector3;

struct Vertex3
{
    /// 3D position of the vertex
    Vector3f position = Vector3f(0, 0, 0);
    /// Color of the vertex. Default is White.
    Color color = Color.White;
    /// 2D coordinates of the texture's pixel map to the vertex.
    Vector2f texCoords = Vector2f(0, 0);
}
