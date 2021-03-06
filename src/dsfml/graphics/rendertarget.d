/*
 * DSFML - The Simple and Fast Multimedia Library for D
 *
 * Copyright (c) 2013 - 2020 Jeremy DeHaan (dehaan.jeremiah@gmail.com)
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
 * `RenderTarget` defines the common behaviour of all the 2D render targets
 * usable in the graphics module. It makes it possible to draw 2D entities like
 * sprites, shapes, text without using any OpenGL command directly.
 *
 * A `RenderTarget` is also able to use views which are a kind of 2D cameras.
 * With views you can globally scroll, rotate or zoom everything that is drawn,
 * without having to transform every single entity.
 *
 * On top of that, render targets are still able to render direct OpenGL stuff.
 * It is even possible to mix together OpenGL calls and regular DSFML drawing
 * commands. When doing so, make sure that OpenGL states are not messed up by
 * calling the `pushGLStates`/`popGLStates` functions.
 *
 * See_Also:
 *      $(RENDERWINDOW_LINK), $(RENDERTEXTURE_LINK), $(VIEW_LINK)
 */
module dsfml.graphics.rendertarget;

import dsfml.graphics.color;
import dsfml.graphics.drawable;
import dsfml.graphics.primitivetype;
import dsfml.graphics.rect;
import dsfml.graphics.renderstates;
import dsfml.graphics.rendertexture;
import dsfml.graphics.renderwindow;
import dsfml.graphics.vertex;
import dsfml.graphics.vertexbuffer;
import dsfml.graphics.view;

import dsfml.system.vector2;

/**
 * Base interface for all render targets (window, texture, ...).
 */
interface RenderTarget
{
    /**
     * Activate or deactivate the render target for rendering.
     *
     * This function makes the render target's context current for future OpenGL
     * rendering operations (so you shouldn't care about it if you're not doing
     * direct OpenGL stuff). A render target's context is active only on the
     * current thread, if you want to make it active on another thread you have
     * to deactivate it on the previous thread first if it was active. Only one
     * context can be current in a thread, so if you want to draw OpenGL
     * geometry to another render target don't forget to activate it again.
     * Activating a render target will automatically deactivate the previously
     * active context (if any).
     *
     * Params:
     *      active = true to activate, false to deactivate
     *
     * Returns:
     *      true if operation was successful, false otherwise
     */
    @property bool active(bool active = true);

    /**
     * The current active view.
     *
     * The view is like a 2D camera, it controls which part of the 2D scene
     * is visible, and how it is viewed in the render-target. The new view
     * will affect everything that is drawn, until another view is set.
     *
     * The render target keeps its own copy of the view object, so it is not
     * necessary to keep the original one alive after calling this function.
     * To restore the original view of the target, you can pass the result
     * of `defaultView()` to this function.
     */
    @property void view(View newView);

    /**
     * Get the view currently in use in the render target.
     *
     * Returns:
     *      The view object that is currently used
     *
     * See_Also:
     *      defaultView
     */
    @property View view() const;

    /**
     * Get the default view of the render target.
     *
     * The default view has the initial size of the render target, and never
     * changes after the target has been created.
     *
     * Returns:
     *      The default view of the render target.
     *
     * See_Also:
     *      view
     */
    @property View defaultView() const;

    /**
     * Return the size of the rendering region of the target.
     *
     * Returns:
     *      Size in pixels.
     */
    @property Vector2u size() const;

    /**
     * Get the viewport of a view, applied to this render target.
     *
     * The viewport is defined in the view as a ratio, this function simply
     * applies this ratio to the current dimensions of the render target to
     * calculate the pixels rectangle that the viewport actually covers in the
     * target.
     *
     * Params:
     *      view = The view for which we want to compute the viewport
     *
     * Returns:
     *      Viewport rectangle, expressed in pixels.
     */
    @property IntRect viewport(View view) const;

    /**
     * Clear the entire target with a single color.
     *
     * This function is usually called once every frame, to clear the previous
     * contents of the target.
     *
     * Params:
     *      color = Fill color to use to clear the render target
     */
    void clear(Color color = Color.Black);

    /**
     * Draw a drawable object to the render target.
     *
     * Params:
     *      drawable = Object to draw
     *      states   = Render states to use for drawing
     */
    void draw(Drawable drawable, RenderStates states = RenderStates.init);

    /**
     * Draw primitives defined by an array of vertices.
     *
     * Params:
     *      vertices = Array of vertices to draw
     *      type     = Type of primitives to draw
     *      states   = Render states to use for drawing
     */
    void draw(const(Vertex)[] vertices, PrimitiveType type, RenderStates states = RenderStates.init);

    /**
     * Draw primitives defined by a vertex buffer.
     *
     * Params:
     *      vertexBuffer = Vertex buffer
     *      states       = Render states to use for drawing
     */
    void draw(VertexBuffer vertexBuffer, RenderStates states = RenderStates.init);

    /**
     * Draw primitives defined by a vertex buffer.
     *
     * Params:
     *      vertexBuffer = Vertex buffer
     *      firstVertex  = Index of the first vertex to render
     *      vertexCount  = Number of vertices to render
     *      states       = Render states to use for drawing
     */
    void draw(VertexBuffer vertexBuffer, size_t firstVertex, size_t vertexCount,
            RenderStates states = RenderStates.init);

    /**
     * Convert a point from target coordinates to world coordinates, using the
     * current view.
     *
     * This function is an overload of the `mapPixelToCoords` function that
     * implicitely uses the current view.
     *
     * Params:
     *      point = Pixel to convert
     *
     * Returns: The converted point, in "world" coordinates.
     */
    Vector2f mapPixelToCoords(Vector2i point) inout;

    /**
     * Convert a point from target coordinates to world coordinates.
     *
     * This function finds the 2D position that matches the given pixel of the
     * render-target. In other words, it does the inverse of what the graphics
     * card does, to find the initial position of a rendered pixel.
     *
     * Initially, both coordinate systems (world units and target pixels) match
     * perfectly. But if you define a custom view or resize your render-target,
     * this assertion is not true anymore, ie. a point located at (10, 50) in
     * your render-target may map to the point (150, 75) in your 2D world – if
     * the view is translated by (140, 25).
     *
     * For render-windows, this function is typically used to find which point
     * (or object) is located below the mouse cursor.
     *
     * This version uses a custom view for calculations, see the other overload
     * of the function if you want to use the current view of the render-target.
     *
     * Params:
     *      point = Pixel to convert
     *      view  = The view to use for converting the point
     *
     * Returns:
     *      The converted point, in "world" coordinates.
     */
    Vector2f mapPixelToCoords(Vector2i point, View view) inout;

    /**
     * Convert a point from target coordinates to world coordinates, using the
     * curtheView.view.
     *
     * This function is an overload of the `mapCoordsToPixel` function that
     * implicitely uses the current view.
     *
     * Params:
     *      point = Point to convert
     *
     * Returns:
     *      The converted point, in "world" coordinates.
     */
    Vector2i mapCoordsToPixel(Vector2f point) inout;

    /**
     * Convert a point from world coordinates to target coordinates.
     *
     * This function finds the pixel of the render-target that matches the given
     * 2D point. In other words, it goes through the same process as the
     * graphics card, to compute the final position of a rendered point.
     *
     * Initially, both coordinate systems (world units and target pixels) match
     * perfectly. But if you define a custom view or resize your render-target,
     * this assertion is not true anymore, ie. a point located at (150, 75) in
     * your 2D world may map to the pixel (10, 50) of your render-target – if
     * the view is translated by (140, 25).
     *
     * This version uses a custom view for calculations, see the other overload
     * of the function if you want to use the current view of the render-target.
     *
     * Params:
     *      point = Point to convert
     *      view  = The view to use for converting the point
     *
     * Returns:
     *      The converted point, in target coordinates (pixels).
     */
    Vector2i mapCoordsToPixel(Vector2f point, View view) inout;

    /**
     * Restore the previously saved OpenGL render states and matrices.
     *
     * See the description of `pushGLStates` to get a detailed description of
     * these functions.
     */
    void popGLStates();

    /**
     * Save the current OpenGL render states and matrices.
     *
     * This function can be used when you mix SFML drawing and direct OpenGL
     * rendering. Combined with `popGLStates`, it ensures that:
     * - DSFML's internal states are not messed up by your OpenGL code
     * - your OpenGL states are not modified by a call to an SFML function
     *
     * More specifically, it must be used around the code that calls
     * `draw` functions.
     *
     * Note that this function is quite expensive: it saves all the possible
     * OpenGL states and matrices, even the ones you don't care about.Therefore
     * it should be used wisely. It is provided for convenience, but the best
     * results will be achieved if you handle OpenGL states yourself (because
     * you know which states have really changed, and need to be saved and
     * restored). Take a look at the `resetGLStates` function if you do so.
     */
    void pushGLStates();

    /**
     * Reset the internal OpenGL states so that the target is ready for drawing.
     *
     * This function can be used when you mix SFML drawing and direct OpenGL
     * rendering, if you choose not to use `pushGLStates`/`popGLStates`. It
     * makes sure that all OpenGL states needed by SFML are set, so that
     * subsequent `draw()` calls will work as expected.
     */
    void resetGLStates();
}
