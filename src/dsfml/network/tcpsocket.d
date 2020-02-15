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
 * TCP is a connected protocol, which means that a TCP socket can only
 * communicate with the host it is connected to.
 *
 * It can't send or receive anything if it is not connected.
 *
 * The TCP protocol is reliable but adds a slight overhead. It ensures that your
 * data will always be received in order and without errors (no data corrupted,
 * lost or duplicated).
 *
 * When a socket is connected to a remote host, you can retrieve informations
 * about this host with the `remoteAddress` and `remotePort` functions.
 *
 * You can also get the local port to which the socket is bound (which is
 * automatically chosen when the socket is connected), with the `localPort`
 * function.
 *
 * Sending and receiving data can use either the low-level or the high-level
 * functions. The low-level functions process a raw sequence of bytes, and
 * cannot ensure that one call to Send will exactly match one call to Receive at
 * the other end of the socket.
 *
 * The high-level interface uses packets (see $(PACKET_LINK)), which are easier
 * to use and provide more safety regarding the data that is exchanged. You can
 * look at the $(PACKET_LINK) class to get more details about how they work.
 *
 * The socket is automatically disconnected when it is destroyed, but if you
 * want to explicitely close the connection while the socket instance is still
 * alive, you can call disconnect.
 *
 * Example:
 * ---
 * // ----- The client -----
 *
 * // Create a socket and connect it to 192.168.1.50 on port 55001
 * auto socket = new TcpSocket();
 * socket.connect("192.168.1.50", 55001);
 *
 * // Send a message to the connected host
 * string message = "Hi, I am a client";
 * socket.send(message);
 *
 * // Receive an answer from the server
 * char[1024] buffer;
 * size_t received = 0;
 * socket.receive(buffer, received);
 * writeln("The server said: ", buffer[0 .. received]);
 *
 * // ----- The server -----
 *
 * // Create a listener to wait for incoming connections on port 55001
 * auto listener = TcpListener();
 * listener.listen(55001);
 *
 * // Wait for a connection
 * auto socket = new TcpSocket();
 * listener.accept(socket);
 * writeln("New client connected: ", socket.remoteAddress());
 *
 * // Receive a message from the client
 * char[1024] buffer;
 * size_t received = 0;
 * socket.receive(buffer, received);
 * writeln("The client said: ", buffer[0 .. received]);
 *
 * // Send an answer
 * string message = "Welcome, client";
 * socket.send(message);
 * ---
 *
 * See_Also:
 *      $(SOCKET_LINK), $(UDPSOCKET_LINK), $(PACKET_LINK)
 */
module dsfml.network.tcpsocket;

import dsfml.system.time;

import dsfml.network.ipaddress;
import dsfml.network.packet;
import dsfml.network.socket;

/**
 * Specialized socket using the TCP protocol.
 */
class TcpSocket : Socket
{
    private sfTcpSocket* m_tcpSocket;

    /// Default constructor.
    @nogc @safe this()
    {
        m_tcpSocket = sfTcpSocket_create();
    }

    // Used by TcpListener.accept().
    @nogc @safe package this(sfTcpSocket* tcpSocketPointer)
    {
        m_tcpSocket = tcpSocketPointer;
    }

    /// Destructor.
    @nogc @safe ~this()
    {
        sfTcpSocket_destroy(m_tcpSocket);
    }

    /**
     * Get the port to which the socket is bound locally.
     *
     * If the socket is not connected, this function returns 0.
     *
     * Returns:
     *      Port to which the socket is bound.
     *
     * See_Also:
     *      connect, remotePort
     */
    @property @nogc @safe ushort localPort() const
    {
        return sfTcpSocket_getLocalPort(m_tcpSocket);
    }

    /**
     * Get the address of the connected peer.
     *
     * It the socket is not connected, this function returns `IpAddress.None`.
     *
     * Returns:
     *      Address of the remote peer.
     *
     * See_Also:
     *      remotePort
     */
    @property @safe IpAddress remoteAddress() const
    {
        return IpAddress(sfTcpSocket_getRemoteAddress(m_tcpSocket));
    }

    /**
     * Get the port of the connected peer to which the socket is connected.
     *
     * If the socket is not connected, this function returns 0.
     *
     * Returns:
     *      Remote port to which the socket is connected.
     *
     * See_Also:
     *      remoteAddress
     */
    @property @nogc @safe ushort remotePort() const
    {
        return sfTcpSocket_getRemotePort(m_tcpSocket);
    }

    /**
     * Set the blocking state of the socket.
     *
     * In blocking mode, calls will not return until they have completed their
     * task. For example, a call to `receive` in blocking mode won't return
     * until some data was actually received.
     *
     * In non-blocking mode, calls will always return immediately, using the
     * return code to signal whether there was data available or not. By
     * default, all sockets are blocking.
     *
     * Params:
     *      _blocking = true to set the socket as blocking, false for non-blocking
     */
    @property @nogc @safe void blocking(bool _blocking)
    {
        sfTcpSocket_setBlocking(m_tcpSocket, _blocking);
    }

    /**
     * Connect the socket to a remote peer.
     *
     * In blocking mode, this function may take a while, especially if the
     * remote peer is not reachable. The last parameter allows you to stop
     * trying to connect after a given timeout.
     *
     * If the socket was previously connected, it is first disconnected.
     *
     * Params:
     *      host    = Address of the remote peer
     * 	    port    = Port of the remote peer
     * 	    timeout = Optional maximum time to wait
     *
     * Returns:
     *      Status code.
     *
     * See_Also:
     *      disconnect
     */
    @nogc @safe Status connect(IpAddress host, ushort port, Time timeout = Time.Zero)
    {
        return sfTcpSocket_connect(m_tcpSocket, host.toc, port, timeout);
    }

    /// ditto
    @nogc @safe Status connect(string host, ushort port, Time timeout = Time.Zero)
    {
        return connect(m_tcpSocket, IpAddress(host), port, timeout);
    }

    /**
     * Disconnect the socket from its remote peer.
     *
     * This function gracefully closes the connection. If the socket is not
     * connected, this function has no effect.
     *
     * See_Also:
     *      connect
     */
    @nogc @safe void disconnect()
    {
        sfTcpSocket_disconnect(m_tcpSocket);
    }

    /**
     * Tell whether the socket is in blocking or non-blocking mode.
     *
     * Returns:
     *      true if the socket is blocking, false otherwise.
     */
    @property @nogc @safe bool blocking() const
    {
        return sfTcpSocket_isBlocking(m_tcpSocket);
    }

    /**
     * Send raw data to the remote peer.
     *
     * To be able to handle partial sends over non-blocking sockets, use the
     * `send(const(void)[], out size_t)` overload instead.
     * This function will fail if the socket is not connected.
     *
     * Params:
     *      data = Sequence of bytes to send
     *
     * Returns:
     *      Status code.
     *
     * See_Also:
     *      receive
     */
    @nogc Status send(const(void)[] data)
    {
        return sfTcpSocket_send(m_tcpSocket, data.ptr, data.length);
    }

    /**
     * Send raw data to the remote peer.
     *
     * This function will fail if the socket is not connected.
     *
     * Params:
     *      data = Sequence of bytes to send
     *      sent = The number of bytes sent will be written here
     *
     * Returns:
     *      Status code.
     *
     * See_Also:
     *      receive
     */
    @nogc Status send(const(void)[] data, out size_t sent)
    {
        return sfTcpSocket_sendPartial(m_tcpSocket, data.ptr, data.length, &sent);
    }

    /**
     * Send a formatted packet of data to the remote peer.
     *
     * This function will fail if the socket is not connected.
     *
     * Params:
     * 	    packet = Packet to send
     *
     * Returns:
     *      Status code.
     *
     * See_Also:
     *      receive
     */
    @nogc @safe Status send(Packet packet)
    {
        return sfTcpSocket_sendPacket(m_tcpSocket, packet.ptr);
    }

    /**
     * Receive raw data from the remote peer.
     *
     * In blocking mode, this function will wait until some bytes are actually
     * received. This function will fail if the socket is not connected.
     *
     * Params:
     *      data         = Array to fill with the received bytes
     * 	    sizeReceived = This variable is filled with the actual number of
     *                     bytes received
     *
     * Returns:
     *      Status code.
     *
     * See_Also:
     *      send
     */
    @nogc Status receive(void[] data, out size_t sizeReceived)
    {
        return sfTcpSocket_receive(m_tcpSocket, data.ptr, data.length, &sizeReceived);
    }

    /**
     * Receive a formatted packet of data from the remote peer.
     *
     * In blocking mode, this function will wait until the whole packet has been
     * received. This function will fail if the socket is not connected.
     *
     * Params:
     *      packet = Packet to fill with the received data
     *
     * Returns:
     *      Status code.
     *
     * See_Also:
     *      send
     */
    Status receive(Packet packet)
    {
        // Temporary packet that will be filled.
        auto tmp = new Packet();
        Status status = sfTcpSocket_receivePacket(m_tcpSocket, tmp.ptr);

        // Put the temporary data into the packet so that it can process it first if it wants.
        packet.onReceiveJunction(tmp.data);
        return status;
    }

    @property @nogc @safe package sfTcpSocket* ptr()
    {
        return m_tcpSocket;
    }
}

package extern (C)
{
    struct sfTcpSocket; // @suppress(dscanner.style.phobos_naming_convention)
}

@nogc @safe private extern (C)
{
    sfTcpSocket* sfTcpSocket_create();
    void sfTcpSocket_destroy(sfTcpSocket* socket);
    void sfTcpSocket_setBlocking(sfTcpSocket* socket, bool blocking);
    bool sfTcpSocket_isBlocking(const sfTcpSocket* socket);
    ushort sfTcpSocket_getLocalPort(const sfTcpSocket* socket);
    sfIpAddress sfTcpSocket_getRemoteAddress(const sfTcpSocket* socket);
    ushort sfTcpSocket_getRemotePort(const sfTcpSocket* socket);
    Socket.Status sfTcpSocket_connect(sfTcpSocket* socket,
            sfIpAddress remoteAddress, ushort remotePort, Time timeout);
    void sfTcpSocket_disconnect(sfTcpSocket* socket);
    Socket.Status sfTcpSocket_send(sfTcpSocket* socket, const void* data, size_t size);
    Socket.Status sfTcpSocket_sendPartial(sfTcpSocket* socket, const void* data,
            size_t size, size_t* sent);
    Socket.Status sfTcpSocket_receive(sfTcpSocket* socket, void* data,
            size_t size, size_t* received);
    Socket.Status sfTcpSocket_sendPacket(sfTcpSocket* socket, sfPacket* packet);
    Socket.Status sfTcpSocket_receivePacket(sfTcpSocket* socket, sfPacket* packet);
}

unittest
{
    import std.stdio : writeln;

    writeln("Running TcpSocket unittest...");

    auto tcpSoc = new TcpSocket();

    // True by default
    assert(tcpSoc.blocking);
    tcpSoc.blocking = false;
    assert(!tcpSoc.blocking);

    // other unittests in TcpListener
}
