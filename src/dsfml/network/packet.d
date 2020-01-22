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
 * Packets provide a safe and easy way to serialize data, in order to send it
 * over the network using sockets (`TcpSocket`, `UdpSocket`).
 *
 * Packets solve 2 fundamental problems that arise when transferring data over
 * the network:
 * - data is interpreted correctly according to the endianness
 * - the bounds of the packet are preserved (one send == one receive)
 *
 * The `Packet` class provides both input and output modes.
 *
 * Example:
 * ---
 * int x = 24;
 * string s = "hello";
 * double d = 5.89;
 *
 * // Group the variables to send into a packet
 * auto packet = new Packet();
 * packet.write(x);
 * packet.write(s);
 * packet.write(d);
 *
 * // Send it over the network (socket is a valid TcpSocket)
 * socket.send(packet);
 *
 * ////////////////////////////////////////////////////////////////
 *
 * // Receive the packet at the other end
 * auto packet = new Packet();
 * socket.receive(packet);
 *
 * // Extract the variables contained in the packet
 * int x;
 * string s;
 * double d;
 * if (packet.read(x) && packet.read(s) && packet.read(d))
 * {
 *     // Data extracted successfully...
 * }
 * ---
 *
 * Packets have built-in operator >> and << overloads for standard types:
 * - bool
 * - fixed-size integer types ([u]byte, [u]short, [u]int)
 * - floating point numbers (float, double)
 * - string types (string and wstring)
 *
 * Like standard streams, it is also possible to define your own overloads of
 * operators >> and << in order to handle your custom types.
 * ---
 * struct MyStruct
 * {
 *     float number;
 *     int integer;
 *     string str;
 *
 *     MyStruct opBinaryRight(string op)(Packet packet)
 *        if (op == ">>" || op == "<<")
 *     {
 *        mixin("packet " ~ op ~ " number " ~ op ~ " integer " ~ op ~ " str;");
 *        return this;
 *     }
 * }
 * ---
 *
 * Packets also provide an extra feature that allows to apply custom
 * transformations to the data before it is sent, and after it is received. This
 * is typically used to handle automatic compression or encryption of the data.
 * This is achieved by inheriting from sf::Packet, and overriding the onSend and
 * onReceive functions.
 *
 * Example:
 * ---
 * class ZipPacket : Packet
 * {
 *     override const(void)[] onSend()
 *     {
 *         const(void)[] srcData = getData();
 *
 *         return MySuperZipFunction(srcData);
 *     }
 *
 *     override void onReceive(const(void)[] data)
 *     {
 *         const(void)[] dstData = MySuperUnzipFunction(data);
 *
 *         append(dstData);
 *     }
 * }
 *
 * // Use like regular packets:
 * auto packet = new ZipPacket();
 * packet << x << s << d;
 * ---
 *
 * See_Also:
 *      $(TCPSOCKET_LINK), $(UDPSOCKET_LINK)
 */
module dsfml.network.packet;

import core.stdc.stddef;

import std.conv;
import std.traits;
import std.range;
import std.string;

import dsfml.config;
import dsfml.system.err;

/**
 * Utility class to build blocks of data to transfer over the network.
 */
class Packet
{
    private sfPacket* m_packet;

    /**
     * Default constructor.
     *
     * Creates an empty packet.
     */
    this()
    {
        m_packet = sfPacket_create();
    }

    // Copy constructor.
    @nogc
    package this(const sfPacket* packetPointer)
    {
        m_packet = sfPacket_copy(packetPointer);
    }

    /// Destructor.
    ~this()
    {
        sfPacket_destroy(m_packet);
    }

    /**
     * Get a slice of the data contained in the packet.
     *
     * Returns:
     *      Slice containing the data.
     */
    const(void)[] data() const
    {
        size_t length = sfPacket_getDataSize(m_packet);
        return sfPacket_getData(m_packet)[0 .. length];
    }

    /**
     * Append data to the end of the packet.
     *
     * Params:
     *      data = Pointer to the sequence of bytes to append.
     *
     * See_Also:
     *      clear
     */
    @nogc
    void append(const(void)[] data)
    {
        sfPacket_append(m_packet, data.ptr, data.length);
    }

    /**
     * Clear the packet.
     *
     * After calling Clear, the packet is empty.
     *
     * See_Also:
     *      append
     */
    @nogc
    void clear()
    {
        sfPacket_clear(m_packet);
    }

    /**
     * Tell if the reading position has reached the end of the packet.
     *
     * This function is useful to know if there is some data left to be read,
     * without actually reading it.
     *
     * Returns:
     *      true if all data was read, false otherwise.
     *
     * See_Also:
     *      opCast
     */
    @nogc
    bool endOfPacket() const
    {
        return sfPacket_endOfPacket(m_packet);
    }

    /**
     * Reads a primitive data type or string from the packet.
     *
     * The value in the packet at the current read position is set to value.
     *
     * Returns:
     *      true if last data extraction from packet was successful.
     */
    bool read(T)(out T value)
        if (is(T == bool) || is(T == byte) || is(T == ubyte) ||
            is(T == short) || is(T == ushort) || is(T == int) ||
            is(T == uint) || is(T == float) || is(T == double) ||
            is(T == string) || is(T == wstring) || is(T == dstring))
    {
        // Calls this.opCast(bool)().
        bool success = cast(bool) this;

        static if (is(T == bool))
        {
            value = sfPacket_readBool(m_packet);
        }
        else static if (is(T == byte))
        {
            value = sfPacket_readInt8(m_packet);
        }
        else static if (is(T == ubyte))
        {
            value = sfPacket_readUint8(m_packet);
        }
        else static if (is(T == short))
        {
            value = sfPacket_readInt16(m_packet);
        }
        else static if (is(T == ushort))
        {
            value = sfPacket_readUint16(m_packet);
        }
        else static if (is(T == int))
        {
            value = sfPacket_readInt32(m_packet);
        }
        else static if (is(T == uint))
        {
            value = sfPacket_readUint32(m_packet);
        }
        else static if (is(T == float))
        {
            value = sfPacket_readFloat(m_packet);
        }
        else static if (is(T == double))
        {
            value = sfPacket_readDouble(m_packet);
        }
        else static if (is(T == string))
        {
            // This char array is needed because we need to allocate the memory
            // before passing the var to the C function.
            char[PACKET_STR_MAX_SIZE] c;
            sfPacket_readString(m_packet, c.ptr);
            value = fromStringz(c.ptr).to!string;
        }
        else
        {
            // wchar_t is an alias for dchar on Posix, wchar on Windows.
            version (Posix)
            {
                static if (is(T == dstring))
                {
                    dchar[PACKET_STR_MAX_SIZE] dc;
                    sfPacket_readWideString(m_packet, dc.ptr);
                    value = fromStringz(dc.ptr).to!dstring;
                }
                else
                {
                    success = false;
                }
            }
            else version (Windows)
            {
                static if (is(T == wstring))
                {
                    wchar[PACKET_STR_MAX_SIZE] wc;
                    sfPacket_readWideString(m_packet, wc.ptr);
                    value = fromStringz(wc.ptr).to!wstring;
                }
                else
                {
                    success = false;
                }
            }
            else
            {
                success = false;
            }
        }
        return success;
    }

    /// Writes a scalar data type or string to the packet.
    void write(T)(T value)
        if (is(T == bool) || is(T == byte) || is(T == ubyte) ||
            is(T == short) || is(T == ushort) || is(T == int) ||
            is(T == uint) || is(T == float) || is(T == double) ||
            is(T == string) || is(T == wstring) || is(T == dstring))
    {
        static if (is(T == bool))
        {
            sfPacket_writeBool(m_packet, cast(bool) value);
        }
        else static if (is(T == byte))
        {
            sfPacket_writeInt8(m_packet, cast(byte) value);
        }
        else static if (is(T == ubyte))
        {
            sfPacket_writeUint8(m_packet, cast(ubyte) value);
        }
        else static if (is(T == short))
        {
            sfPacket_writeInt16(m_packet, cast(short) value);
        }
        else static if (is(T == ushort))
        {
            sfPacket_writeUint16(m_packet, cast(ushort) value);
        }
        else static if (is(T == int))
        {
            sfPacket_writeInt32(m_packet, cast(int) value);
        }
        else static if (is(T == uint))
        {
            sfPacket_writeUint32(m_packet, cast(uint) value);
        }
        else static if (is(T == float))
        {
            sfPacket_writeFloat(m_packet, cast(float) value);
        }
        else static if (is(T == double))
        {
            sfPacket_writeDouble(m_packet, cast(double) value);
        }
        else static if (is(T == string))
        {
            string s = cast(string) value;
            checkPacketStringSize(s);
            sfPacket_writeString(m_packet, s.toStringz);
        }
        else
        {
            // wchar_t is an alias for dchar on Posix, wchar on Windows.
            version (Posix)
            {
                static if (is(T == dstring))
                {
                    dstring ds = cast(dstring) value;
                    checkPacketStringSize(ds);
                    sfPacket_writeWideString(m_packet, ds.ptr);
                }
            }
            else version (Windows)
            {
                static if (is(T == wstring))
                {
                    wstring ws = cast(wstring) value;
                    checkPacketStringSize(ws);
                    sfPacket_writeWideString(m_packet, ws.ptr);
                }
            }
        }
    }

    /**
     * Called before the packet is sent over the network.
     *
     * This function can be defined by derived classes to transform the data
     * before it is sent; this can be used for compression, encryption, etc.
     *
     * The function must return an array of the modified data, with a length of
     * the number of bytes to send. The default implementation provides the
     * packet's data without transforming it.
     *
     * Returns:
     *      Array of bytes to send.
     */
    protected const(void)[] onSend()
    {
        return data();
    }

    /**
     * Called after the packet is received over the network.
     *
     * This function can be defined by derived classes to transform the data
     * after it is received; this can be used for uncompression, decryption,
     * etc.
     *
     * The function receives an array of the received data, and must fill the
     * packet with the transformed bytes. The default implementation fills the
     * packet directly without transforming the data.
     *
     * Params:
     *      data = Array of the received bytes
     *
     * See_Also:
     *      onSend
     */
    protected void onReceive(const(void)[] data)
    {
        append(data);
    }

    /**
     * Overloads the `>>` operator.
     *
     * This function simply calls `read()`.
     */
    Packet opBinary(string op, T)(out T value)
        if (op == ">>")
    {
        read(value);
        return this;
    }

    /**
     * Overloads the `<<` operator.
     *
     * This function simply calls `write()`.
     */
    Packet opBinary(string op, T)(T value)
        if (op == "<<")
    {
        write(value);
        return this;
    }

    /*
     * Allow other DSFML's classes to call onReceive() without breaking the
     * protected attribute.
     *
     * Used by [Udp/Tcp]Socket.send() .
     */
    package void onSendJunction()
    {
        onSend();
    }

    /*
     * Allow other DSFML's classes to call onReceive() without breaking the
     * protected attribute.
     *
     * Used by [Udp/Tcp]Socket.receive() .
     */
    package void onReceiveJunction(const(void)[] data)
    {
        onReceive(data);
    }

    /**
     * Test the validity of the packet, for reading.
     *
     * This operator allows to test the packet as a boolean variable, to check
     * if a reading operation was successful.
     *
     * A packet will be in an invalid state if it has no more data to read.
     *
     * This behavior is the same as standard C++ streams.
     *
     * Usage example:
     * ---
     * float x;
     * packet >> x;
     * if (packet)
     * {
     *     // ok, x was extracted successfully
     * }
     * // -- or --
     * float x;
     * if (packet >> x)
     * {
     *     // ok, x was extracted successfully
     * }
     * ---
     *
     * Don't focus on the return type, it's equivalent to bool but it disallows
     * unwanted implicit conversions to integer or pointer types.
     *
     * Returns:
     *      true if last data extraction from packet was successful
     *
     * See_Also:
     *      endOfPacket
     */
    @nogc
    bool opCast(T : bool)()
    {
        // sfPacket_canRead calls the BoolType operator of SFML's sf::Packet
        return sfPacket_canRead(m_packet);
    }

    @property @nogc
    package sfPacket* ptr()
    {
        return m_packet;
    }

    /// Duplicates this Packet.
    @property
    Packet dup()
    {
        return new Packet(m_packet);
    }
}

// Shows a warning if the string exceed the max size for packets.
private void checkPacketStringSize(T)(T str)
    if (is(T == string) || is(T == dstring) || is(T == wstring))
{
    if (str.length > PACKET_STR_MAX_SIZE)
    {
        err.writefln("Warning: the string passed to the packet exceed the size limit of %s characters.",
            PACKET_STR_MAX_SIZE);
    }
}

package extern(C)
{
    struct sfPacket;
}

@nogc
private extern(C)
{
    sfPacket* sfPacket_create();
    sfPacket* sfPacket_copy(const sfPacket* packet);
    void sfPacket_destroy(sfPacket* packet);
    void sfPacket_append(sfPacket* packet, const void* data, size_t sizeInBytes);
    void sfPacket_clear(sfPacket* packet);
    const(void)* sfPacket_getData(const sfPacket* packet);
    size_t sfPacket_getDataSize(const sfPacket* packet);
    bool sfPacket_endOfPacket(const sfPacket* packet);

    bool sfPacket_canRead(const sfPacket* packet);
    bool sfPacket_readBool(sfPacket* packet);
    byte sfPacket_readInt8(sfPacket* packet);
    ubyte sfPacket_readUint8(sfPacket* packet);
    short sfPacket_readInt16(sfPacket* packet);
    ushort sfPacket_readUint16(sfPacket* packet);
    int sfPacket_readInt32(sfPacket* packet);
    uint sfPacket_readUint32(sfPacket* packet);
    float sfPacket_readFloat(sfPacket* packet);
    double sfPacket_readDouble(sfPacket* packet);
    void sfPacket_readString(sfPacket* packet, char* _string);
    void sfPacket_readWideString(sfPacket* packet, wchar_t* _string);

    void sfPacket_writeBool(sfPacket* packet, bool value);
    void sfPacket_writeInt8(sfPacket* packet, byte value);
    void sfPacket_writeUint8(sfPacket* packet, ubyte value);
    void sfPacket_writeInt16(sfPacket* packet, short value);
    void sfPacket_writeUint16(sfPacket* packet, ushort value);
    void sfPacket_writeInt32(sfPacket* packet, int value);
    void sfPacket_writeUint32(sfPacket* packet, uint value);
    void sfPacket_writeFloat(sfPacket* packet, float value);
    void sfPacket_writeDouble(sfPacket* packet, double value);
    void sfPacket_writeString(sfPacket* packet, const char* _string);
    void sfPacket_writeWideString(sfPacket* packet, const wchar_t* _string);
}

unittest
{
    import std.stdio;
    import dsfml.network.socket;
    import dsfml.network.tcpsocket;
    import dsfml.network.tcplistener;
    import dsfml.network.ipaddress;
    writeln("Running Packet unittest...");

    auto sendPacket = new Packet();
    auto receivePacket = new Packet();

    bool b = true;
    byte bt = -123;
    ubyte ubt = 137;
    short s = -31954;
    ushort us = 62043;
    int i = -19928121;
    uint ui = 2147483647;
    float f = 341.1238641246;
    double d = 2542.1245315135;
    string str = "Hello, I'm a client !\nIf this string exceed 512 characters, it may not work :(";

    sendPacket << b << bt << ubt << s << us << i << ui << f << d << str;
    receivePacket.onReceiveJunction(sendPacket.onSend());


    bool b1;
    byte bt1;
    ubyte ubt1;
    short s1;
    ushort us1;
    int i1;
    uint ui1;
    float f1;
    double d1;
    string str1;

    receivePacket >> b1 >> bt1 >> ubt1 >> s1 >> us1 >> i1 >> ui1 >> f1 >> d1 >> str1;

    assert(b == b1);
    assert(bt == bt1);
    assert(ubt == ubt1);
    assert(s == s1);
    assert(us == us1);
    assert(i == i1);
    assert(ui == ui1);
    assert(f == f1);
    assert(d == d1);


    sendPacket.clear();
    receivePacket.clear();

    version (Posix)
    {
        dstring dstr = "❄ 🍷 🍓 弈 ⯳";
        sendPacket.write(dstr);
        receivePacket.onReceiveJunction(sendPacket.onSend());

        dstring dstr1;
        receivePacket.read(dstr1);

        assert(dstr == dstr1);
    }
    else version (Windows)
    {
        wstring wstr = "❄ 🍷 🍓 弈 ⯳";
        sendPacket.write(wstr);
        receivePacket.onReceiveJunction(sendPacket.onSend());

        wstring wstr1;
        receivePacket.read(wstr1);

        assert(wstr == wstr1);
    }


    class EmptyPacket : Packet
    {
        override protected void onReceive(const(void)[] data)
        {
            // Not calling append, so the data will always be null
            //append(data);
        }
    }

    auto emptyPacket = new EmptyPacket();

    const(void)[] randomData = ["hey", "ho"];
    emptyPacket.onReceiveJunction(randomData);

    assert(emptyPacket.data() == null);

    ////////////
    // Stuck by https://issues.dlang.org/show_bug.cgi?id=8863
    /+
    struct MyStruct
    {
        float number;
        int integer;
        string str;

        MyStruct opBinaryRight(string op)(Packet packet)
            if (op == ">>" || op == "<<")
        {
            if (op == ">>")
            {
                packet >> number >> integer >> str;
            }
            else if (op == "<<")
            {
                packet << number << integer << str;
            }
            //mixin("packet " ~ op ~ " number " ~ op ~ " integer " ~ op ~ " str;");
            return this;
        }
    }

    Packet packet = new Packet();
    MyStruct ms1 = MyStruct(42.124, 123, "hellow");
    MyStruct ms2;

    packet << ms1;
    packet >> ms2;
    assert(ms1 == ms2);
    +/
}
