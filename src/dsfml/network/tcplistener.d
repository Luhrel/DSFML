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
 * A listener socket is a special type of socket that listens to a given port
 * and waits for connections on that port. This is all it can do.
 *
 * When a new connection is received, you must call `accept` and the listener
 * returns a new instance of $(TCPSOCKET_LINK) that is properly initialized and
 * can be used to communicate with the new client.
 *
 * Listener sockets are specific to the TCP protocol, UDP sockets are
 * connectionless and can therefore communicate directly. As a consequence, a
 * listener socket will always return the new connections as $(TCPSOCKET_LINK)
 * instances.
 *
 * A listener is automatically closed on destruction, like all other types of
 * socket. However if you want to stop listening before the socket is destroyed,
 * you can call its `close()` function.
 *
 * Example:
 * ---
 * // Create a listener socket and make it wait for new
 * // connections on port 55001
 * auto listener = new TcpListener();
 * listener.listen(55001);
 *
 * // Endless loop that waits for new connections
 * while (running)
 * {
 *     auto client = new TcpSocket();
 *     if (listener.accept(client) == Socket.Status.Done)
 *     {
 *         // A new client just connected!
 *         writeln("New connection received from ", client.remoteAddress());
 *         doSomethingWith(client);
 *     }
 * }
 * ---
 *
 * See_Also:
 *      $(TCPSOCKET_LINK), $(SOCKET_LINK)
 */
module dsfml.network.tcplistener;

import dsfml.network.ipaddress;
import dsfml.network.socket;
import dsfml.network.tcpsocket;

/**
 * Socket that listens to new TCP connections.
 */
class TcpListener : Socket
{
    private sfTcpListener* m_tcpListener;

    /// Default constructor.
    @nogc @safe this()
    {
        m_tcpListener = sfTcpListener_create();
    }

    /// Destructor.
    @nogc @safe ~this()
    {
        sfTcpListener_destroy(m_tcpListener);
    }

    /**
     * Get the port to which the socket is bound locally.
     *
     * If the socket is not listening to a port, this function returns 0.
     *
     * Returns:
     *      Port to which the socket is bound.
     *
     * See_Also:
     *      listen
     */
    @nogc @safe ushort localPort() const
    {
        return sfTcpListener_getLocalPort(m_tcpListener);
    }

    /**
     * Tell whether the socket is in blocking or non-blocking mode.
     *
     * In blocking mode, calls will not return until they have completed their
     * task. For example, a call to `receive` in blocking mode won't return
     * until some data was actually received.
     *
     * In non-blocking mode, calls will
     * always return immediately, using the return code to signal whether there
     * was data available or not. By default, all sockets are blocking.
     *
     * Params:
     *      _blocking = true to set the socket as blocking, false for non-blocking
     */
    @property @nogc @safe void blocking(bool _blocking)
    {
        sfTcpListener_setBlocking(m_tcpListener, _blocking);
    }

    /**
     * Accept a new connection.
     *
     * If the socket is in blocking mode, this function will not return until a
     * connection is actually received.
     *
     * Params:
     *      socket = Socket that will hold the new connection
     *
     * Returns:
     *      Status code.
     */
    Status accept(out TcpSocket socket)
    {
        sfTcpSocket* client;
        Status status = sfTcpListener_accept(m_tcpListener, &client);
        socket = new TcpSocket(client);
        return status;
    }

    /**
     * Start listening for connections.
     *
     * This functions makes the socket listen to the specified port, waiting for
     * new connections. If the socket was previously listening to another port,
     * it will be stopped first and bound to the new port.
     *
     * Params:
     *      port    = Port to listen for new connections
     *      address = Address of the interface to listen on
     *
     * Returns:
     *      Status code.
     *
     * See_Also:
     *      accept, close
     */
    @nogc @safe Status listen(ushort port, IpAddress address = IpAddress.Any)
    {
        return sfTcpListener_listen(m_tcpListener, port, address.toc);
    }

    /**
     * Tell whether the socket is in blocking or non-blocking mode.
     *
     * Returns:
     *      true if the socket is blocking, false otherwise.
     */
    @property @nogc @safe bool blocking() const
    {
        return sfTcpListener_isBlocking(m_tcpListener);
    }

    @property @nogc @safe package sfTcpListener* ptr()
    {
        return m_tcpListener;
    }
}

package extern (C)
{
    struct sfTcpListener; // @suppress(dscanner.style.phobos_naming_convention)
}

@nogc @safe private extern (C)
{
    sfTcpListener* sfTcpListener_create();
    void sfTcpListener_destroy(sfTcpListener* listener);
    void sfTcpListener_setBlocking(sfTcpListener* listener, bool blocking);
    bool sfTcpListener_isBlocking(const sfTcpListener* listener);
    ushort sfTcpListener_getLocalPort(const sfTcpListener* listener);
    Socket.Status sfTcpListener_listen(sfTcpListener* listener, ushort port, sfIpAddress address);
    Socket.Status sfTcpListener_accept(sfTcpListener* listener, sfTcpSocket** connected);
}

unittest
{

    import dsfml.network.packet : Packet;
    import dsfml.system.sleep : sleep;
    import dsfml.system.thread : Thread;
    import dsfml.system.time : seconds;
    import std.stdio : writeln;

    writeln("Running TcpListener unittest...");

    int clientPort;

    void clientSide()
    {
        // Connect the client to the server
        auto socket = new TcpSocket();
        auto status = socket.connect(IpAddress.LocalHost, 53_000);
        assert(status == Socket.Status.Done);

        clientPort = socket.localPort;

        // Send server's data to the client (server-side)
        int[] clientData = [12, 34, 56];
        status = socket.send(clientData);
        assert(status == Socket.Status.Done);

        sleep(seconds(0.2));

        auto packet = new Packet();
        packet << 12 << "hey" << true;
        assert(status == Socket.Status.Done);
    }

    void serverSide()
    {
        auto listener = new TcpListener();

        // True by default
        assert(listener.blocking);
        listener.blocking = false;
        assert(!listener.blocking);

        // Listen to the port
        const ushort port = 53_000;
        auto status = listener.listen(port);
        assert(status == Socket.Status.Done);
        assert(listener.localPort == port);

        // Accept a new connection
        auto client = new TcpSocket();
        status = listener.accept(client);
        assert(status == Socket.Status.Done);

        // Receive the data
        int[3] clientData; // Be careful, it won't work with dynamic arrays
        size_t sizeReceived;
        status = client.receive(clientData, sizeReceived);
        assert(status == Socket.Status.Done);
        assert(client.remoteAddress == IpAddress.LocalHost);
        assert(clientData == [12, 34, 56]);
        assert(client.remotePort == clientPort);

        Packet packet;
        int i;
        string s;
        bool b;
        status = client.receive(packet);
        assert(status == Socket.Status.Done);
        packet >> i >> s >> b;
        assert(i == 12);
        assert(s == "hey");
        assert(b);
    }

    auto clientTh = new Thread(&clientSide);
    auto serverTh = new Thread(&serverSide);

    serverTh.launch();
    clientTh.launch();

    clientTh.wait();
    serverTh.wait();

}
