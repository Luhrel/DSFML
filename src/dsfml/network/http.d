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
 * The `Http` class is a very simple HTTP client that allows you to communicate
 * with a web server. You can retrieve web pages, send data to an interactive
 * resource, download a remote file, etc. The HTTPS protocol is not supported.
 *
 * The HTTP client is split into 3 classes:
 * - `Http.Request`
 * - `Http.Response`
 * - `Http`
 *
 * `Http.Request` builds the request that will be sent to the server. A
 * request is made of:
 * - a method (what you want to do)
 * - a target URI (usually the name of the web page or file)
 * - one or more header fields (options that you can pass to the server)
 * - an optional body (for POST requests)
 *
 * `Http.Response` parses the response from the web server and provides
 * getters to read them. The response contains:
 * - a status code
 * - header fields (that may be answers to the ones that you requested)
 * - a body, which contains the contents of the requested resource
 *
 * `Http` provides a simple function, `sendRequest`, to send a
 * `Http.Request` and return the corresponding `Http.Response` from the server.
 *
 * Example:
 * ---
 * // Create a new HTTP client
 * auto http = new Http();
 *
 * // We'll work on http://www.sfml-dev.org
 * http.host = "http://www.sfml-dev.org";
 *
 * // Prepare a request to get the 'features.php' page
 * auto request = new Http.Request("features.php");
 *
 * // Send the request
 * auto response = http.sendRequest(request);
 *
 * // Check the status code and display the result
 * auto status = response.status();
 * if (status == Http.Response.Status.Ok)
 * {
 *     writeln(response.body());
 * }
 * else
 * {
 *     writeln("Error ", status);
 * }
 * ---
 */
 module dsfml.network.http;

 import dsfml.system.time;

 import std.string;
 import std.conv;

/**
 * An HTTP client.
 */
class Http
{
    private sfHttp* m_http;

    /// Default constructor.
    this()
    {
        m_http = sfHttp_create();
    }

    /**
     * Construct the HTTP client with the target host.
     *
     * This is equivalent to calling `setHost(host, port)`. The port has a
     * default value of 0, which means that the HTTP client will use the right
     * port according to the protocol used (80 for HTTP, 443 for HTTPS). You
     * should leave it like this unless you really need a port other than the
     * standard one, or use an unknown protocol.
     *
     * Params:
     * 	    host = Web server to connect to
     * 	    port = Port to use for connection
     */
    this(const string host, ushort port = 0)
    {
        this();
        this.setHost(host, port);
    }

    ///Destructor
    ~this()
    {
        sfHttp_destroy(m_http);
    }

    /**
     * Set the target host.
     *
     * This function just stores the host address and port, it doesn't actually
     * connect to it until you send a request. The port has a default value of
     * 0, which means that the HTTP client will use the right port according to
     * the protocol used (80 for HTTP, 443 for HTTPS). You should leave it like
     * this unless you really need a port other than the standard one, or use an
     * unknown protocol.
     *
     * Params:
     * 	    host = Web server to connect to
     * 	    port = Port to use for connection
     */
    void setHost(const string host, ushort port = 0)
    {
        sfHttp_setHost(m_http, host.toStringz, port);
    }

    /**
     * Send a HTTP request and return the server's response.
     *
     * You must have a valid host before sending a request (see setHost). Any
     * missing mandatory header field in the request will be added with an
     * appropriate value. **Warning:** this function waits for the server's response
     * and may not return instantly; use a thread if you don't want to block
     * your application, or use a timeout to limit the time to wait. A value of
     * Time.Zero means that the client will use the system defaut timeout
     * (which is usually pretty long).
     *
     * Params:
     * 	    request = Request to send
     * 	    timeout = Maximum time to wait
     *
     * Returns:
     *      Server's response.
     */
    Response sendRequest(Request request, Time timeout = Time.Zero)
    {
        return new Response(sfHttp_sendRequest(m_http, request.ptr,
            timeout));
    }

    /// Define a HTTP request.
    static class Request
    {
        /// Enumerate the available HTTP methods for a request.
        enum Method
        {
            /// Request in get mode, standard method to retrieve a page.
            Get,
            /// Request in post mode, usually to send data to a page.
            Post,
            /// Request a page's header only.
            Head,
            /// Request in put mode, useful for a REST API
            Put,
            /// Request in delete mode, useful for a REST API
            Delete
        }

        alias Method this;

        private sfHttpRequest* m_httpRequest;

        /**
         * Default constructor.
         *
         * This constructor creates a GET request, with the root URI ("/") and
         * an empty body.
         *
         * Params:
         *      uri    = Target URI
         * 	    method = Method to use for the request
         * 	    body   = Content of the request's body
         */
        this(const string uri = "/", Method method = Method.Get,
            const string body = "")
        {
            m_httpRequest = sfHttpRequest_create();
            this.uri = uri;
            this.method = method;
            this.body = body;
        }

        /// Destructor.
        ~this()
        {
            sfHttpRequest_destroy(m_httpRequest);
        }

        /**
         * Set the body of the request.
         *
         * The body of a request is optional and only makes sense for POST
         * requests. It is ignored for all other methods. The body is empty by
         * default.
         *
         * Params:
         * 	    requestBody = Content of the body
         */
        void body(const string requestBody)
        {
            sfHttpRequest_setBody(m_httpRequest, requestBody.toStringz);
        }

        /**
         * Set the value of a field.
         *
         * The field is created if it doesn't exist. The name of the field is
         * case insensitive. By default, a request doesn't contain any field
         * (but the mandatory fields are added later by the HTTP client when
         * sending the request).
         *
         * Params:
         * 	    field = Name of the field to set
         *      value = Value of the field
         */
        void field(const string field, const string value)
        {
            sfHttpRequest_setField(m_httpRequest, field.toStringz, value.toStringz);
        }

        /**
         * Set the HTTP version for the request.
         *
         * The HTTP version is 1.0 by default.
         *
         * Params:
         * 	    major = Major HTTP version number
         * 	    minor = Minor HTTP version number
         */
        void httpVersion(uint major, uint minor)
        {
            sfHttpRequest_setHttpVersion(m_httpRequest, major, minor);
        }

        /**
         * Set the request method.
         *
         * See the Method enumeration for a complete list of all the availale
         * methods. The method is `Http.Request.Get` by default.
         *
         * Params:
         * 	    method = Method to use for the request
         */
        void method(Method method)
        {
            sfHttpRequest_setMethod(m_httpRequest, method);
        }

        /**
         * Set the requested URI.
         *
         * The URI is the resource (usually a web page or a file) that you want
         * to get or post. The URI is "/" (the root page) by default.
         *
         * Params:
         * 	    uri = URI to request, relative to the host
         */
        void uri(const string uri)
        {
            sfHttpRequest_setUri(m_httpRequest, uri.toStringz);
        }

        package sfHttpRequest* ptr()
        {
            return m_httpRequest;
        }
    }

    /// Define a HTTP response.
    static class Response
    {
        /// Enumerate all the valid status codes for a response.
        enum Status
        {
            // 2xx: success
            Ok = 200,
            Created = 201,
            Accepted = 202,
            NoContent = 204,
            ResetContent = 205,
            PartialContent = 206,

            // 3xx: redirection
            MultipleChoices = 300,
            MovedPermanently = 301,
            MovedTemporarily = 302,
            NotModified = 304,

            // 4xx: client error
            BadRequest = 400,
            Unauthorized = 401,
            Forbidden = 403,
            NotFound = 404,
            RangeNotSatisfiable = 407,

            // 5xx: server error
            InternalServerError = 500,
            NotImplemented = 501,
            BadGateway = 502,
            ServiceNotAvailable = 503,
            GatewayTimeout = 504,
            VersionNotSupported = 505,

            // 10xx: SFML custom codes
            InvalidResponse = 1000,
            ConnectionFailed = 1001
        }

        alias Status this;

        private sfHttpResponse* m_httpResponse;

        // Internally used constructor
        package this(sfHttpResponse* httpResponsePointer)
        {
            m_httpResponse = httpResponsePointer;
        }

        /**
         * Get the body of the response.
         *
         * The body of a response may contain:
         * - the requested page (for GET requests)
         * - a response from the server (for POST requests)
         * - nothing (for HEAD requests)
         * - an error message (in case of an error)
         *
         * Returns:
         *      The response body.
         */
        string body() const
        {
            return sfHttpResponse_getBody(m_httpResponse).fromStringz.to!string;
        }

        /**
         * Get the value of a field.
         *
         * If the field field is not found in the response header, the empty
         * string is returned. This function uses case-insensitive comparisons.
         *
         * Params:
         * 	    field = Name of the field to get
         *
         * Returns:
         *      Value of the field, or empty string if not found.
         */
        string field(const string field) const
        {
            return sfHttpResponse_getField(m_httpResponse, field.toStringz).
                fromStringz.to!string;
        }

        /**
         * Get the major HTTP version number of the response.
         *
         * Returns:
         *      Major HTTP version number.
         *
         * See_Also:
         *      minorHttpVersion
         */
        uint majorHttpVersion() const
        {
            return sfHttpResponse_getMajorVersion(m_httpResponse);
        }

        /**
         * Get the minor HTTP version number of the response.
         *
         * Returns:
         *      Minor HTTP version number.
         *
         * See_Also:
         *      majorHttpVersion
         */
        uint minorHttpVersion() const
        {
            return sfHttpResponse_getMinorVersion(m_httpResponse);
        }

        /**
         * Get the response status code.
         *
         * The status code should be the first thing to be checked after
         * receiving a response, it defines whether it is a success, a failure
         * or anything else (see the Status enumeration).
         *
         * Returns:
         *      Status code of the response.
         */
        Status status() const
        {
            return sfHttpResponse_getStatus(m_httpResponse);
        }
    }
}

private extern(C)
{
    struct sfHttp;
    struct sfHttpRequest;
    struct sfHttpResponse;

    sfHttpRequest* sfHttpRequest_create();
    void sfHttpRequest_destroy(sfHttpRequest* httpRequest);
    void sfHttpRequest_setField(sfHttpRequest* httpRequest, const char* field, const char* value);
    void sfHttpRequest_setMethod(sfHttpRequest* httpRequest, Http.Request.Method method);
    void sfHttpRequest_setUri(sfHttpRequest* httpRequest, const char* uri);
    void sfHttpRequest_setHttpVersion(sfHttpRequest* httpRequest, uint major, uint minor);
    void sfHttpRequest_setBody(sfHttpRequest* httpRequest, const char* body);

    void sfHttpResponse_destroy(sfHttpResponse* httpResponse);
    const(char)* sfHttpResponse_getField(const sfHttpResponse* httpResponse, const char* field);
    Http.Response.Status sfHttpResponse_getStatus(const sfHttpResponse* httpResponse);
    uint sfHttpResponse_getMajorVersion(const sfHttpResponse* httpResponse);
    uint sfHttpResponse_getMinorVersion(const sfHttpResponse* httpResponse);
    const(char)* sfHttpResponse_getBody(const sfHttpResponse* httpResponse);

    sfHttp* sfHttp_create();
    void sfHttp_destroy(sfHttp* http);
    void sfHttp_setHost(sfHttp* http, const char* host, ushort port);
    sfHttpResponse* sfHttp_sendRequest(sfHttp* http, const sfHttpRequest* request, Time timeout);
}

unittest
{
    import std.stdio;
    writeln("Running Http unittest...");

    auto http = new Http();

    http.setHost("dsfml.com", 80);

    // Prepare a request to get the 'doc.html' page
    auto request = new Http.Request("doc.html");

    // Send the request
    auto response = http.sendRequest(request);

    // Check the status code and display the result
    auto status = response.status();
    assert(status == Http.Response.Status.Ok);
}
