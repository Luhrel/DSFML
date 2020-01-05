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
 * $(U View) defines a camera in the 2D scene. This is a very powerful concept:
 * you can scroll, rotate or zoom the entire scene without altering the way that
 * your drawable objects are drawn.
 *
 * A view is composed of a source rectangle, which defines what part of the 2D
 * scene is shown, and a target viewport, which defines where the contents of
 * the source rectangle will be displayed on the render target (window or
 * texture).
 *
 * The viewport allows to map the scene to a custom part of the render target,
 * and can be used for split-screen or for displaying a minimap, for example.
 * If the source rectangle has not the same size as the viewport, its contents
 * will be stretched to fit in.
 *
 * To apply a view, you have to assign it to the render target. Then, every
 * objects drawn in this render target will be affected by the view until you
 * use another view.
 *
 * Example:
 * ---
 * auto window = RenderWindow();
 * auto view = View();
 *
 * // Initialize the view to a rectangle at (100, 100) and a size of 400x200
 * view.reset(FloatRect(100, 100, 400, 200));
 *
 * // Rotate it by 45 degrees
 * view.rotate(45);
 *
 * // Set its target viewport to be half of the window
 * view.setViewport(FloatRect(0.f, 0.f, 0.5f, 1.f));
 *
 * // Apply it
 * window.view = view;
 *
 * // Render stuff
 * window.draw(someSprite);
 *
 * // Set the default view back
 * window.view = window.getDefaultView();
 *
 * // Render stuff not affected by the view
 * window.draw(someText);
 * ---
 *
 * $(PARA See also the note on coordinates and undistorted rendering in
 * $(TRANSFORMABLE_LINK).)
 *
 * See_Also:
 * $(RENDERWINDOW_LINK), $(RENDERTEXTURE_LINK)
 */
module dsfml.graphics.view;

import dsfml.graphics.rect;
import dsfml.system.vector2;
import dsfml.graphics.transform;

/**
 * 2D camera that defines what region is shown on screen.
 */
class View
{
    private sfView* m_view;

    /**
     * Default constructor.
     *
     * This constructor creates a default view of (0, 0, 1000, 1000)
     */
    this()
    {
        m_view = sfView_create();
    }

    /**
     * Construct the view from a rectangle
     *
     * Params:
     *    rectangle = Rectangle defining the zone to display
     */
    this(FloatRect rectangle)
    {
        m_view = sfView_createFromRect(rectangle);
    }

    /**
     * Construct the view from its center and size
     *
     * Params:
     * center = Center of the zone to display
     * size   = Size of zone to display
     */
    this(Vector2f center, Vector2f size)
    {
        this();
        this.center = center;
        this.size = size;
    }

    // Copy constructor.
    package this(const sfView* viewPointer)
    {
        m_view = sfView_copy(viewPointer);
    }

    /// Destructor.
    ~this()
    {
        sfView_destroy(m_view);
    }

    @property
    {
        /**
         * Set the center of the view.
         *
         * Params:
         *         center    = New center
         * See_Also: size
         */
        void center(Vector2f newCenter)
        {
            sfView_setCenter(m_view, newCenter);
        }

        /**
         * Set the center of the view.
         *
         * Params:
         *     x = X coordinate of the new center
         *     y = Y coordinate of the new center
         * See_Also: size
         */
        void center(float x, float y)
        {
            center(Vector2f(x, y));
        }

        /**
         * Get the center of the view.
         *
         * Returns: Center of the view
         * See_Also: size
         */
        Vector2f center() const
        {
            return sfView_getCenter(m_view);
        }
    }

    @property
    {
        /**
         * Set the orientation of the view.
         *
         * The default rotation of a view is 0 degree.
         *
         * Params:
         *         angle    = New angle, in degrees
         */
        void rotation(float angle)
        {
            sfView_setRotation(m_view, angle);
        }

        /**
         * Get the current orientation of the view.
         *
         * Returns: Rotation angle of the view, in degrees
         */
        float rotation() const
        {
            return sfView_getRotation(m_view);

        }
    }

    /**
     * Rotate the view relatively to its current orientation.
     *
     * Params:
     *         angle    = Angle to rotate, in degrees
     * See_Also: rotation, move, zoom
     */
    void rotate(float angle)
    {
        sfView_rotate(m_view, angle);
    }

    @property
    {
        /**
         * Set the size of the view.
         *
         * Params:
         *         size    = New size
         * See_Also: center
         */
        void size(Vector2f newSize)
        {
            sfView_setSize(m_view, newSize);
        }

        /**
         * Set the size of the view.
         *
         * Params:
         *         width    = New width of the view
         *         height    = New height of the view
         * See_Also: center
         */
        void size(float width, float height)
        {
            size(Vector2f(width, height));
        }

        /**
         * Get the size of the view.
         *
         * Returns: Size of the view
         * See_Also: center
         */
        Vector2f size() const
        {
            return sfView_getSize(m_view);
        }
    }

    @property
    {
        /**
         * Set the target viewport.
         *
         * The viewport is the rectangle into which the contents of the view are
         * displayed, expressed as a factor (between 0 and 1) of the size of the
         * RenderTarget to which the view is applied. For example, a view which
         * takes the left side of the target would be defined with
         * `View.setViewport(FloatRect(0, 0, 0.5, 1))`. By default, a view has a
         * viewport which covers the entire target.
         *
         * Params:
         *         viewport    = New viewport rectangle
         */
        void viewport(FloatRect newViewport)
        {
            sfView_setViewport(m_view, newViewport);
        }

        /**
         * Get the target viewport rectangle of the view.
         *
         * Returns: Viewport rectangle, expressed as a factor of the target size
         */
        FloatRect viewport() const
        {
            return sfView_getViewport(m_view);
        }
    }

    /**
     * Move the view relatively to its current position.
     *
     * Params:
     *         offset    = Move offset
     * See_Also: center, rotate, move
     */
    void move(Vector2f offset)
    {
        sfView_move(m_view, offset);
    }

    /**
     * Move the view relatively to its current position.
     *
     * Params:
     *         offsetX    = X coordinate of the move offset
     *         offsetY    = Y coordinate of the move offset
     * See_Also: center, rotate, move
     */
    void move(float offsetX, float offsetY)
    {
        move(Vector2f(offsetX, offsetY));
    }

    /**
     * Reset the view to the given rectangle.
     *
     * Note that this function resets the rotation angle to 0.
     *
     * Params:
     *         rectangle    = Rectangle defining the zone to display.
     * See_Also: center, size, rotation
     */
    void reset(FloatRect rectangle)
    {
        sfView_reset(m_view, rectangle);
    }

    /**
     * Resize the view rectangle relatively to its current size.
     *
     * Resizing the view simulates a zoom, as the zone displayed on screen grows
     * or shrinks. factor is a multiplier:
     * $(UL
     * $(LI `1` keeps the size unchanged.)
     * $(LI `> 1` makes the view bigger (objects appear smaller).)
     * $(LI `< 1` makes the view smaller (objects appear bigger).))
     *
     * Params:
     *         factor    = Zoom factor to apply
     * See_Also: size, move, rotate
     */
    void zoom(float factor)
    {
        sfView_zoom(m_view, factor);
    }

    /**
     * Get the projection transform of the view.
     *
     * This function is meant for internal use only.
     *
     * Returns: Projection transform defining the view.
     * See_Also: inverseTransform
     */
    // Disabled: This function is meant for internal use only.
    @disable
    const(Transform) transform()
    {
        import std.math;
        // Rotation components
        float angle  = rotation() * 3.141592654f / 180.0f; // Not using constant PI, because it's too large
        float cosine = cos(angle);
        float sine   = sin(angle);
        float tx     = -center.x * cosine - center.y * sine + center.x;
        float ty     =  center.x * sine - center.y * cosine + center.y;

        // Projection components
        float a =  2.0f / size.x;
        float b = -2.0f / size.y;
        float c = -a * center.x;
        float d = -b * center.y;

        // Rebuild the projection matrix
        return Transform( a * cosine, a * sine,   a * tx + c,
                         -b * sine,   b * cosine, b * ty + d,
                          0.0f,       0.0f,       1.0f);
    }

    /**
     * Get the inverse projection transform of the view.
     *
     * This function is meant for internal use only.
     *
     * Returns: Inverse of the projection transform defining the view.
     *
     * See_Also: transform
     */
    // Disabled: This function is meant for internal use only.
    @disable
    const(Transform) inverseTransform()
    {
        return transform().inverse();
    }

    // Returns the C pointer
    @property
    package sfView* ptr()
    {
        return m_view;
    }

    /// Duplicates this View.
    @property
    View dup()
    {
        return new View(m_view);
    }
}

package extern(C)
{
    struct sfView;
}

private extern(C)
{
    sfView* sfView_create();
    sfView* sfView_createFromRect(FloatRect rectangle);
    sfView* sfView_copy(const sfView* view);
    void sfView_destroy(sfView* view);
    void sfView_setCenter(sfView* view, Vector2f center);
    void sfView_setSize(sfView* view, Vector2f size);
    void sfView_setRotation(sfView* view, float angle);
    void sfView_setViewport(sfView* view, FloatRect viewport);
    void sfView_reset(sfView* view, FloatRect rectangle);
    Vector2f sfView_getCenter(const sfView* view);
    Vector2f sfView_getSize(const sfView* view);
    float sfView_getRotation(const sfView* view);
    FloatRect sfView_getViewport(const sfView* view);
    void sfView_move(sfView* view, Vector2f offset);
    void sfView_rotate(sfView* view, float angle);
    void sfView_zoom(sfView* view, float factor);
}

unittest
{
    import std.stdio;
    writeln("Running View unittest...");

    View v = new View();

    int cx = 10;
    int cy = 20;
    v.center(cx, cy);
    assert(v.center == Vector2f(cx, cy));

    int sx = 600;
    int sy = 800;
    v.size(sx, sy);
    assert(v.size == Vector2f(sx, sy));

    int angle = 90;
    v.rotation = angle;
    assert(v.rotation == angle);
    v.rotate(angle);
    assert(v.rotation == 2*angle);

    FloatRect vp = FloatRect(100, 100, 200, 200);
    v.viewport = vp;
    assert(v.viewport == vp);

    v.move(10, 10);
    v.zoom(2);

    v.reset(vp);
    assert(v.rotation == 0);

}
