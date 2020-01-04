
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
 * $(U IpAddress) is a utility structure for manipulating network addresses. It
 * provides a set a implicit constructors and conversion functions to easily
 * build or transform an IP address from/to various representations.
 *
 *
 * Note that $(U IpAddress) currently doesn't support IPv6 nor other types of
 * network addresses.
 * Example:
 * ---
 * // an invalid address
 * IpAddress a0;
 *
 * // an invalid address (same as a0)
 * IpAddress a1 = IpAddress.None;
 *
 * // the local host address
 * IpAddress a2 = IpAddress("127.0.0.1");
 *
 * // the broadcast address
 * IpAddress a3 = IpAddress.Broadcast;
 *
 * // a local address
 * IpAddress a4 = IpAddress(192, 168, 1, 56);
 *
 * // a local address created from a network name
 * IpAddress a5 = IpAddress("my_computer");
 *
 * // a distant address
 * IpAddress a6 = IpAddress("89.54.1.169");
 *
 * // a distant address created from a network name
 * IpAddress a7("www.google.com");
 *
 * // my address on the local network
 * IpAddress a8 = IpAddress.localAddress();
 *
 * // my address on the internet
 * IpAddress a9 = IpAddress.publicAddress();
 * ---
 */
module dsfml.network.ipaddress;

import dsfml.system.time;

import std.string;
import std.conv;

/**
 * Encapsulate an IPv4 network address.
 */
struct IpAddress
{
    /// Value representing an empty/invalid address.
    static immutable(IpAddress) None;
    /// Value representing any address (0.0.0.0)
    static immutable(IpAddress) Any = IpAddress(0,0,0,0);
    /// The "localhost" address (for connecting a computer to itself locally)
    static immutable(IpAddress) LocalHost = IpAddress(127,0,0,1);
    /// The "broadcast" address (for sending UDP messages to everyone on a local network)
    static immutable(IpAddress) Broadcast = IpAddress(255,255,255,255);

    private uint m_address;
    private bool m_valid;

    /**
     * Construct the address from a string.
     *
     * Here address can be either a decimal address (ex: "192.168.1.56") or a
     * network name (ex: "localhost").
     *
     * Params:
     * 		address = IP address or network name.
     */
    this(const(string) address)
    {
        m_address = htonl(sfIpAddress_toInteger(
            sfIpAddress_fromString(address.toStringz)));
        m_valid = true;
    }

    /**
     * Construct the address from 4 bytes.
     *
     * Calling `IpAddress(a, b, c, d)` is equivalent to calling
     * `IpAddress("a.b.c.d")`, but safer as it doesn't have to parse a string to
     * get the address components.
     *
     * Params:
     * 		byte0 = First byte of the address.
     * 		byte1 = Second byte of the address.
     * 		byte2 = Third byte of the address.
     * 		byte3 = Fourth byte of the address.
     */
    this(ubyte byte0, ubyte byte1, ubyte byte2, ubyte byte3)
    {
        m_address = htonl((byte0 << 24) | (byte1 << 16) | (byte2 << 8) | byte3);
        m_valid = true;
    }

    /**
     * Construct the address from a 32-bits integer.
     *
     * This constructor uses the internal representation of the address
     * directly. It should be used only if you got that representation from
     * `IpAddress.toInteger()`.
     *
     * Params:
     * 	address = 4 bytes of the address packed into a 32-bits integer
     * See_Also: toInteger
     */
    this(uint address)
    {
        m_address = htonl(address);
        m_valid = true;
    }

    // Internally used constructor.
    package this(sfIpAddress ipAddress)
    {
        this(ipAddress.address.to!string);
    }

    /**
     * Get an integer representation of the address.
     *
     * The returned number is the internal representation of the address, and
     * should be used for optimization purposes only (like sending the address
     * through a socket). The integer produced by this function can then be
     * converted back to an $(U IpAddress) with the proper constructor.
     *
     * Returns: 32-bits unsigned integer representation of the address.
     * See_Also: toString
     */
    uint toInteger() const
    {
        return ntohl(m_address);
    }

    /**
     * Get a string representation of the address.
     *
     * The returned string is the decimal representation of the IP address
     * (like "192.168.1.56"), even if it was constructed from a host name.
     *
     * This string is built using an internal buffer. If you need to store the
     * string, make a copy.
     *
     * Returns: String representation of the address
     * See_Also: toInteger
     */
    const(string) toString() const @trusted
    {
        import core.stdc.stdio : sprintf;

        //internal string buffer to prevent using the GC to build the strings
        static char[16] m_string;

        ubyte* bytes = cast(ubyte*) &m_address;
        int length = sprintf(m_string.ptr, "%d.%d.%d.%d", bytes[0], bytes[1],
                                                          bytes[2], bytes[3]);
        return m_string[0..length].to!string;
    }

    /**
     * Get the computer's local address.
     *
     * The local address is the address of the computer from the LAN point of
     * view, i.e. something like 192.168.1.56. It is meaningful only for
     * communications over the local network. Unlike `getPublicAddress`, this
     * function is fast and may be used safely anywhere.
     *
     * Returns: Local IP address of the computer.
     * See_Also: publicAddress
     */
    static IpAddress localAddress()
    {
        return IpAddress(sfIpAddress_getLocalAddress().address.to!string);
    }

    /**
     * Get the computer's public address.
     *
     * The public address is the address of the computer from the internet point
     * of view, i.e. something like 89.54.1.169.
     *
     * It is necessary for communications over the world wide web. The only way
     * to get a public address is to ask it to a distant website; as a
     * consequence, this function depends on both your network connection and
     * the server, and may be very slow. You should use it as few as possible.
     *
     * Because this function depends on the network connection and on a distant
     * server, you may use a time limit if you don't want your program to be
     * possibly stuck waiting in case there is a problem; this limit is
     * deactivated by default.
     *
     * Params:
     * 	timeout = Maximum time to wait
     *
     * Returns: Public IP address of the computer.
     * See_Also: localAddress
     */
    static IpAddress publicAddress(Time timeout = Time.Zero)
    {
        return IpAddress(sfIpAddress_getPublicAddress(timeout).address.to!string);
    }

    // Overloads the == operator.
    bool opEquals(IpAddress otherIpAddress)
    {
        return m_valid == otherIpAddress.m_valid &&
            m_address == otherIpAddress.m_address;
    }

    // Overloads the < > <= >= operators.
    int opCmp(ref const IpAddress otherIpAddress) const
    {
        if (m_valid < otherIpAddress.m_valid)
            return -1;
        else if (otherIpAddress.m_valid < m_valid)
            return 1;
        else if (m_address < otherIpAddress.m_address)
            return -1;
        return 1;
    }

    /*
     * Allow to declare (e.g.): IpAddress address = "192.168.0.124";
     */
    IpAddress opAssign(string address)
    {
        return IpAddress(address);
    }

    // Returns the C struct.
    package sfIpAddress toc()
    {
        return sfIpAddress_fromInteger(ntohl(m_address));
    }
}

//these have the same implementation, but use different names for readability
private uint htonl(uint host) nothrow @nogc @safe
{
    version(LittleEndian)
    {
        import core.bitop;
        return bswap(host);
    }
    else
    {
        return host;
    }
}

private alias ntohl = htonl;

package extern(C)
{
    struct sfIpAddress
    {
        char[16] address;
    }
}

private extern(C)
{
    sfIpAddress sfIpAddress_fromString(const char* address);
    sfIpAddress sfIpAddress_fromBytes(ubyte byte0, ubyte byte1, ubyte byte2, ubyte byte3);
    sfIpAddress sfIpAddress_fromInteger(uint address);
    void sfIpAddress_toString(sfIpAddress address, char* _string);
    uint sfIpAddress_toInteger(sfIpAddress address);
    sfIpAddress sfIpAddress_getLocalAddress();
    sfIpAddress sfIpAddress_getPublicAddress(Time timeout);
}

unittest
{
    import std.stdio;
    writeln("Running IpAddress unittest...");

    auto ia1 = IpAddress(192,168,0,55);
    auto ia2 = IpAddress(192,168,0,54);

    assert(ia1 != ia2);
    assert(ia1 == ia1);
    assert(ia2 < ia1);
    assert(ia1 > ia2);
    assert(ia1 >= ia2);
    assert(ia2 <= ia1);

    assert(ia2.toInteger == 3232235574);
    assert(ia1.toInteger == 3232235575);

    version (DSFML_Unittest_with_interaction)
    {
        writeln("\nYour local address: %s", IpAddress.localAddress);
        writeln("\nYour public address: %s", IpAddress.publicAddress);
    }

    IpAddress myIp = "192.168.0.124";
    assert(myIp == IpAddress(192,168,0,124));
}
