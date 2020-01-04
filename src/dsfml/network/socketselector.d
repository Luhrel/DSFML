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
 * Socket selectors provide a way to wait until some data is available on a set
 * of sockets, instead of just one. This is convenient when you have multiple
 * sockets that may possibly receive data, but you don't know which one will be
 * ready first. In particular, it avoids to use a thread for each socket; with
 * selectors, a single thread can handle all the sockets.
 *
 * All types of sockets can be used in a selector:
 * $(UL
 * $(LI $(TCPLISTENER_LINK))
 * $(LI $(TCPSOCKET_LINK))
 * $(LI $(UDPSOCKET_LINK)))
 *
 * $(PARA
 * A selector doesn't store its own copies of the sockets, it simply keeps a
 * reference to the original sockets that you pass to the "add" function.
 * Therefore, you can't use the selector as a socket container, you must store
 * them outside and make sure that they are alive as long as they are used in
 * the selector (i.e., they cannot be collected by the GC).
 *
 * Using a selector is simple:)
 * $(UL
 * $(LI populate the selector with all the sockets that you want to observe)
 * $(LI make it wait until there is data available on any of the sockets)
 * $(LI test each socket to find out which ones are ready))
 *
 * Example:
 * ---
 * // Create a socket to listen to new connections
 * auto listener = new TcpListener();
 * listener.listen(55001);
 *
 * // Create a list to store the future clients
 * TcpSocket[] clients;
 *
 * // Create a selector
 * auto selector = new SocketSelector();
 *
 * // Add the listener to the selector
 * selector.add(listener);
 *
 * // Endless loop that waits for new connections
 * while (running)
 * {
 *     // Make the selector wait for data on any socket
 *     if (selector.wait())
 *     {
 *         // Test the listener
 *         if (selector.isReady(listener))
 *         {
 *             // The listener is ready: there is a pending connection
 *             auto client = new TcpSocket();
 *             if (listener.accept(client) == Socket.Status.Done)
 *             {
 *                 // Add the new client to the clients list
 *                 clients ~= client;
 *
 *                 // Add the new client to the selector so that we will
 *                 // be notified when he sends something
 *                 selector.add(client);
 *             }
 *             else
 *             {
 *                 // Error, we won't get a new connection
 *             }
 *         }
 *         else
 *         {
 *             // The listener socket is not ready, test all other sockets (the clients)
 *             foreach(client; clients)
 *             {
 *                 if (selector.isReady(client))
 *                 {
 *                     // The client has sent some data, we can receive it
 *                     auto packet = new Packet();
 *                     if (client.receive(packet) == Socket.Status.Done)
 *                     {
 *                         ...
 *                     }
 *                 }
 *             }
 *         }
 *     }
 * }
 * ---
 *
 * See_Also:
 * $(SOCKET_LINK)
 */
module dsfml.network.socketselector;

import dsfml.network.tcplistener;
import dsfml.network.tcpsocket;
import dsfml.network.udpsocket;

import dsfml.system.time;

/**
 * Multiplexer that allows to read from multiple sockets.
 */
class SocketSelector
{
    private sfSocketSelector* m_socketSelector;

    /// Default constructor.
    this()
    {
        m_socketSelector = sfSocketSelector_create();
    }

    // Copy constructor.
    package this(sfSocketSelector* socketSelectorPointer)
    {
        m_socketSelector = sfSocketSelector_copy(socketSelectorPointer);
    }

    /// Destructor.
    ~this()
    {
        sfSocketSelector_destroy(m_socketSelector);
    }

    /**
     * Add a new TcpListener to the selector.
     *
     * This function keeps a weak reference to the socket, so you have to make
     * sure that the socket is not destroyed while it is stored in the selector.
     * This function does nothing if the socket is not valid.
     *
     * Params:
     * 	listener = Reference to the listener to add
     * See_Also: remove, clear
     */
    void add(TcpListener listener)
    {
        sfSocketSelector_addTcpListener(m_socketSelector, listener.ptr);
    }

    /**
     * Add a new TcpSocket to the selector.
     *
     * This function keeps a weak reference to the socket, so you have to make
     * sure that the socket is not destroyed while it is stored in the selector.
     * This function does nothing if the socket is not valid.
     *
     * Params:
     *  socket = Reference to the socket to add
     * See_Also: remove, clear
     */
    void add(TcpSocket socket)
    {
        sfSocketSelector_addTcpSocket(m_socketSelector, socket.ptr);
    }

    /**
     * Add a new UdpSocket to the selector.
     *
     * This function keeps a weak reference to the socket, so you have to make
     * sure that the socket is not destroyed while it is stored in the selector.
     * This function does nothing if the socket is not valid.
     *
     * Params:
     * 	socket = Reference to the socket to add
     * See_Also: remove, clear
     */
    void add(UdpSocket socket)
    {
        sfSocketSelector_addUdpSocket(m_socketSelector, socket.ptr);
    }

    /**
     * Remove all the sockets stored in the selector.
     *
     * This function doesn't destroy any instance, it simply removes all the
     * references that the selector has to external sockets.
     *
     * See_Also: add, remove
     */
    void clear()
    {
        sfSocketSelector_clear(m_socketSelector);
    }

    /**
     * Test a socket to know if it is ready to receive data.
     *
     * This function must be used after a call to Wait, to know which sockets
     * are ready to receive data. If a socket is ready, a call to receive will
     * never block because we know that there is data available to read. Note
     * that if this function returns true for a TcpListener, this means that it
     * is ready to accept a new connection.
     *
     * Params:
     *     socket = Socket to test
     * Returns: True if the socket is ready to read, false otherwise.
     */
    bool isReady(TcpListener listener) const
    {
        return sfSocketSelector_isTcpListenerReady(m_socketSelector, listener.ptr);
    }

    /// ditto
    bool isReady(TcpSocket socket) const
    {
        return sfSocketSelector_isTcpSocketReady(m_socketSelector, socket.ptr);
    }

    /// ditto
    bool isReady(UdpSocket socket) const
    {
        return sfSocketSelector_isUdpSocketReady(m_socketSelector, socket.ptr);
    }

    /**
     * Remove a socket from the selector.
     *
     * This function doesn't destroy the socket, it simply removes the reference
     * that the selector has to it.
     *
     * Params:
     *  socket = Reference to the socket to remove
     * See_Also: add, clear
     */
    void remove(TcpListener socket)
    {
        sfSocketSelector_removeTcpListener(m_socketSelector, socket.ptr);
    }

    /**
     * Remove a socket from the selector.
     *
     * This function doesn't destroy the socket, it simply removes the reference
     * that the selector has to it.
     *
     * Params:
     *  socket = Reference to the socket to remove
     * See_Also: add, clear
     */
    void remove(TcpSocket socket)
    {
        sfSocketSelector_removeTcpSocket(m_socketSelector, socket.ptr);
    }

    /**
     * Remove a socket from the selector.
     *
     * This function doesn't destroy the socket, it simply removes the reference
     * that the selector has to it.
     *
     * Params:
     *  socket = Reference to the socket to remove
     * See_Also: add, clear
     */
    void remove(UdpSocket socket)
    {
        sfSocketSelector_removeUdpSocket(m_socketSelector, socket.ptr);
    }

    /**
     * Wait until one or more sockets are ready to receive.
     *
     * This function returns as soon as at least one socket has some data
     * available to be received. To know which sockets are ready, use the
     * isReady function. If you use a timeout and no socket is ready before the
     * timeout is over, the function returns false.
     *
     * Parameters
     * 		timeout = Maximum time to wait, (use Time.Zero for infinity)
     *
     * Returns: true if there are sockets ready, false otherwise.
     * See_Also: isReady
     */
    bool wait(Time timeout = Time.Zero)
    {
        return sfSocketSelector_wait(m_socketSelector, timeout);
    }

    // Duplicate a SocketSelector
    @property
    SocketSelector dup()
    {
        return new SocketSelector(m_socketSelector);
    }
}

private extern(C)
{
    struct sfSocketSelector;

    sfSocketSelector* sfSocketSelector_create();
    sfSocketSelector* sfSocketSelector_copy(const sfSocketSelector* selector);
    void sfSocketSelector_destroy(sfSocketSelector* selector);

    void sfSocketSelector_addTcpListener(sfSocketSelector* selector, sfTcpListener* socket);
    void sfSocketSelector_addTcpSocket(sfSocketSelector* selector, sfTcpSocket* socket);
    void sfSocketSelector_addUdpSocket(sfSocketSelector* selector, sfUdpSocket* socket);

    void sfSocketSelector_removeTcpListener(sfSocketSelector* selector, sfTcpListener* socket);
    void sfSocketSelector_removeTcpSocket(sfSocketSelector* selector, sfTcpSocket* socket);
    void sfSocketSelector_removeUdpSocket(sfSocketSelector* selector, sfUdpSocket* socket);

    void sfSocketSelector_clear(sfSocketSelector* selector);
    bool sfSocketSelector_wait(sfSocketSelector* selector, Time timeout);

    bool sfSocketSelector_isTcpListenerReady(const sfSocketSelector* selector, sfTcpListener* socket);
    bool sfSocketSelector_isTcpSocketReady(const sfSocketSelector* selector, sfTcpSocket* socket);
    bool sfSocketSelector_isUdpSocketReady(const sfSocketSelector* selector, sfUdpSocket* socket);

}
