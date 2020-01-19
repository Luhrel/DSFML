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
 * The `Ftp` class is a very simple FTP client that allows you to communicate with
 * an FTP server. The FTP protocol allows you to manipulate a remote file system
 * (list files, upload, download, create, remove, ...).
 *
 * Using the FTP client consists of 4 parts:
 * - Connecting to the FTP server
 * - Logging in (either as a registered user or anonymously)
 * - Sending commands to the server
 * - Disconnecting (this part can be done implicitly by the destructor)
 *
 * Every command returns a FTP response, which contains the status code as well
 * as a message from the server. Some commands such as `getWorkingDirectory()`
 * and `directoryListing()` return additional data, and use a class derived
 * from `Ftp.Response` to provide this data. The most often used commands are
 * directly provided as member functions, but it is also possible to use
 * specific commands with the `sendCommand()` function.
 *
 * Note that response statuses >= 1000 are not part of the FTP standard,
 * they are generated by SFML when an internal error occurs.
 *
 * All commands, especially upload and download, may take some time to complete.
 * This is important to know if you don't want to block your application while
 * the server is completing the task.
 *
 * Example:
 * ---
 * // Create a new FTP client
 * auto ftp = new Ftp();
 *
 * // Connect to the server
 * auto response = ftp.connect("ftp://ftp.myserver.com");
 * if (response.isOk())
 *     writeln("Connected");
 *
 * // Log in
 * response = ftp.login("laurent", "dF6Zm89D");
 * if (response.isOk())
 *     writeln("Logged in");
 *
 * // Print the working directory
 * auto directory = ftp.workingDirectory();
 * if (directory.isOk())
 *     writeln("Working directory: ", directory.directory());
 *
 * // Create a new directory
 * response = ftp.createDirectory("files");
 * if (response.isOk())
 *     writeln("Created new directory");
 *
 * // Upload a file to this new directory
 * response = ftp.upload("local-path/file.txt", "files", Ftp.Ascii);
 * if (response.isOk())
 *     writeln("File uploaded");
 *
 * // Send specific commands (here: FEAT to list supported FTP features)
 * response = ftp.sendCommand("FEAT");
 * if (response.isOk())
 *     writeln("Feature list:\n", response.message());
 *
 * // Disconnect from the server (optional)
 * ftp.disconnect();
 * ---
 */
module dsfml.network.ftp;

import dsfml.system.time;
import dsfml.network.ipaddress;
import dsfml.network.http;

import std.string;
import std.conv;

/**
 * An FTP client.
 */
class Ftp
{
    /// Enumeration of transfer modes.
    enum TransferMode
    {
        /// Binary mode (file is transfered as a sequence of bytes)
        Binary,
        /// Text mode using ASCII encoding.
        Ascii,
        /// Text mode using EBCDIC encoding.
        Ebcdic,
    }

    // That way we can do Ftp.Ascii (like in SFML).
    alias TransferMode this;

    private sfFtp* m_ftp;

    /// Default Constructor.
    this()
    {
        m_ftp = sfFtp_create();
    }

    /// Destructor.
    ~this()
    {
        sfFtp_destroy(m_ftp);
    }


    /**
     * Get the current working directory.
     *
     * The working directory is the root path for subsequent operations
     * involving directories and/or filenames.
     *
     * Returns:
     *      Server response to the request.
     *
     * See_Also:
     *      directoryListing, changeDirectory, parentDirectory
     */
    @property
    DirectoryResponse workingDirectory()
    {
        return new DirectoryResponse(sfFtp_getWorkingDirectory(m_ftp));
    }

    /**
     * Get the contents of the given directory.
     *
     * This function retrieves the sub-directories and files contained in the
     * given directory. It is not recursive. The directory parameter is relative
     * to the current working directory.
     *
     * Params:
     *      directory = Directory to list
     *
     * Returns:
     *      Server response to the request.
     *
     * See_Also:
     *      workingDirectory, changeDirectory, parentDirectory
     */
    ListingResponse directoryListing(const string directory = "")
    {
        return new ListingResponse(sfFtp_getDirectoryListing(m_ftp,
            directory.toStringz));
    }

    /**
     * Change the current working directory.
     *
     * The new directory must be relative to the current one.
     *
     * Params:
     *      directory = New working directory
     *
     * Returns:
     *      Server response to the request.
     *
     * See_Also:
     *      workingDirectory, directoryListing, parentDirectory
     */
    Response changeDirectory(const string directory)
    {
        return new Response(sfFtp_changeDirectory(m_ftp, directory.toStringz));
    }

    /**
     * Connect to the specified FTP server.
     *
     * The port has a default value of 21, which is the standard port used by
     * the FTP protocol. You shouldn't use a different value, unless you really
     * know what you do.
     *
     * This function tries to connect to the server so it may take a while to
     * complete, especially if the server is not reachable. To avoid blocking
     * your application for too long, you can use a timeout. The default value,
     * Time.Zero, means that the system timeout will be used (which is
     * usually pretty long).
     *
     * Params:
     *      address = Address of the FTP server to connect to
     * 	    port    = Port used for the connection
     * 	    timeout = Maximum time to wait
     *
     * Returns:
     *      Server response to the request.
     *
     * See_Also:
     *      disconnect
     */
    Response connect(IpAddress address, ushort port = 21, Time timeout = Time.Zero)
    {
        return new Response(sfFtp_connect(m_ftp, address.toc, port, timeout));
    }

    /**
     * Connect to the specified FTP server.
     *
     * The port has a default value of 21, which is the standard port used by
     * the FTP protocol. You shouldn't use a different value, unless you really
     * know what you do.
     *
     * This function tries to connect to the server so it may take a while to
     * complete, especially if the server is not reachable. To avoid blocking
     * your application for too long, you can use a timeout. The default value,
     * Time.Zero, means that the system timeout will be used (which is
     * usually pretty long).
     *
     * Params:
     * 	    address = Name or ddress of the FTP server to connect to
     * 	    port    = Port used for the connection
     * 	    timeout = Maximum time to wait
     *
     * Returns:
     *      Server response to the request.
     *
     * See_Also:
     *      disconnect
     */
    Response connect(const string address, ushort port = 21, Time timeout = Time.Zero)
    {
        return new Response(sfFtp_connect(m_ftp, IpAddress(address).toc, port,
            timeout));
    }

    /**
     * Remove an existing directory.
     *
     * The directory to remove must be relative to the current working
     * directory. Use this function with caution, the directory will be removed
     * permanently!
     *
     * Params:
     * 	    name = Name of the directory to remove
     *
     * Returns:
     *      Server response to the request.
     *
     * See_Also:
     *      createDirectory
     */
    Response deleteDirectory(const string name)
    {
        return new Response(sfFtp_deleteDirectory(m_ftp, name.toStringz));
    }

    /**
     * Remove an existing file.
     *
     * The file name must be relative to the current working directory. Use this
     * function with caution, the file will be removed permanently!
     *
     * Params:
     *      name = Name of the file to remove
     *
     * Returns:
     *      Server response to the request.
     *
     * See_Also:
     *      renameFile
     */
    Response deleteFile(const string name)
    {
        return new Response(sfFtp_deleteFile(m_ftp, name.toStringz));
    }

    /**
     * Close the connection with the server.
     *
     * Returns:
     *      Server response to the request.
     *
     * See_Also:
     *      connect
     */
    Response disconnect()
    {
        return new Response(sfFtp_disconnect(m_ftp));
    }

    /**
     * Download a file from the server.
     *
     * The filename of the distant file is relative to the current working
     * directory of the server, and the local destination path is relative to
     * the current directory of your application.
     *
     * Params:
     * 	    remoteFile = Filename of the distant file to download
     * 	    localPath  = Where to put to file on the local computer
     * 	    mode       = Transfer mode
     *
     * Returns:
     *      Server response to the request.
     *
     * See_Also:
     *      upload
     */
    Response download(const string remoteFile, const string localPath,
        TransferMode mode = TransferMode.Binary)
    {
        return new Response(sfFtp_download(m_ftp, remoteFile.toStringz,
            localPath.toStringz, mode));
    }

    /**
     * Send a null command to keep the connection alive.
     *
     * This command is useful because the server may close the connection
     * automatically if no command is sent.
     *
     * Returns:
     *      Server response to the request.
     */
    Response keepAlive()
    {
        return new Response(sfFtp_keepAlive(m_ftp));
    }

    /**
     * Log in using an anonymous account.
     *
     * Logging in is mandatory after connecting to the server. Users that are
     * not logged in cannot perform any operation.
     *
     * Returns:
     *      Server response to the request.
     */
    Response login()
    {
        return new Response(sfFtp_loginAnonymous(m_ftp));
    }

    /**
     * Log in using a username and a password.
     *
     * Logging in is mandatory after connecting to the server. Users that are
     * not logged in cannot perform any operation.
     *
     * Params:
     * 	    name     = User name
     * 	    password = The password
     *
     * Returns:
     *      Server response to the request.
     */
    Response login(const string name, const string password)
    {
        return new Response(sfFtp_login(m_ftp, name.toStringz, password.toStringz));
    }

    /**
     * Go to the parent directory of the current one.
     *
     * Returns:
     *      Server response to the request.
     *
     * See_Also:
     *      workingDirectory, directoryListing, changeDirectory
     */
    Response parentDirectory()
    {
        return new Response(sfFtp_parentDirectory(m_ftp));
    }

    /**
     * Create a new directory.
     *
     * The new directory is created as a child of the current working directory.
     *
     * Params:
     * 	    name = Name of the directory to create
     *
     * Returns:
     *      Server response to the request.
     *
     * See_Also:
     *      deleteDirectory
     */
    Response createDirectory(const string name)
    {
        return new Response(sfFtp_createDirectory(m_ftp, name.toStringz));
    }

    /**
     * Rename an existing file.
     *
     * The filenames must be relative to the current working directory.
     *
     * Params:
     * 	    file = File to rename
     * 	    name = New name of the file
     *
     * Returns:
     *      Server response to the request.
     *
     * See_Also:
     *      deleteFile
     */
    Response renameFile(const string file, const string name)
    {
        return new Response(sfFtp_renameFile(m_ftp, file.toStringz,
            name.toStringz));
    }

    /**
     * Upload a file to the server.
     *
     * The name of the local file is relative to the current working directory
     * of your application, and the remote path is relative to the current
     * directory of the FTP server.
     *
     * The append parameter controls whether the remote file is appended to or
     * overwritten if it already exists.
     *
     * Params:
     * 	    localFile  = Path of the local file to upload
     * 	    remotePath = Where to put the file on the server
     * 	    mode       = Transfer mode
     *      append     = Pass true to append to or false to overwrite the remote
     *                   file if it already exists
     *
     * Returns:
     *      Server response to the request.
     *
     * See_Also:
     *      download
     */
    Response upload(const string localFile, const string remotePath,
        TransferMode mode = TransferMode.Binary, bool append = false)
    {
        return new Response(sfFtp_upload(m_ftp, localFile.toStringz,
            remotePath.toStringz, mode, append));
    }

    /**
     * Send a command to the FTP server.
     *
     * While the most often used commands are provided as member functions in
     * the `Ftp` class, this method can be used to send any FTP command to the
     * server. If the command requires one or more parameters, they can be
     * specified in parameter. If the server returns information, you can
     * extract it from the response using `message()`.
     *
     * Params:
     * 	    command   = Command to send
     * 	    parameter = Command parameter
     *
     * Returns:
     *      Server response to the request.
     */
    Response sendCommand(const string command, const string parameter)
    {
        return new Response(sfFtp_sendCommand(m_ftp, command.toStringz,
            parameter.toStringz));
    }

    /// Specialization of FTP response returning a directory.
    static class DirectoryResponse : Response
    {
        private sfFtpDirectoryResponse* m_directoryResponse;

        // Internally used constructor.
        package this(sfFtpDirectoryResponse* directoryResponsePointer)
        {
            m_directoryResponse = directoryResponsePointer;
            super(null);
        }

        /// Destructor.
        ~this()
        {
            sfFtpDirectoryResponse_destroy(m_directoryResponse);
        }

        /**
         * Check if the status code means a success.
         *
         * This function is defined for convenience, it is equivalent to testing
         * if the status code is < 400.
         *
         * Returns:
         *      true if the status is a success, false if it is a failure
         */
        override bool isOk() const
        {
            return sfFtpDirectoryResponse_isOk(m_directoryResponse);
        }

        /**
         * Get the status code of the response.
         *
         * Returns:
         *      Status code
         */
        override Status status() const
        {
            return Status(sfFtpDirectoryResponse_getStatus(m_directoryResponse));
        }

        /**
         * Get the full message contained in the response.
         *
         * Returns:
         *      The response message
         */
        override string message() const
        {
            return sfFtpDirectoryResponse_getMessage(m_directoryResponse)
                .fromStringz.to!string;
        }

        /**
         * Get the directory returned in the response.
         *
         * Returns:
         *      Directory name.
         */
        string directory() const
        {
            return sfFtpDirectoryResponse_getDirectory(m_directoryResponse)
                .fromStringz.to!string;
        }
    }

    /// Specialization of FTP response returning a filename lisiting.
    static class ListingResponse : Response
    {
        private sfFtpListingResponse* m_listingResponse;

        // Internally used constructor.
        package this(sfFtpListingResponse* listingResponsePointer)
        {
            m_listingResponse = listingResponsePointer;
            super(null);
        }

        /// Destructor.
        ~this()
        {
            sfFtpListingResponse_destroy(m_listingResponse);
        }

        /**
         * Check if the status code means a success.
         *
         * This function is defined for convenience, it is equivalent to testing
         * if the status code is < 400.
         *
         * Returns:
         *      true if the status is a success, false if it is a failure
         */
        override bool isOk() const
        {
            return sfFtpListingResponse_isOk(m_listingResponse);
        }

        /**
         * Get the status code of the response.
         *
         * Returns:
         *      Status code
         */
        override Status status() const
        {
            return sfFtpListingResponse_getStatus(m_listingResponse);
        }

        /**
         * Get the full message contained in the response.
         *
         * Returns:
         *      The response message
         */
        override string message() const
        {
            return sfFtpListingResponse_getMessage(m_listingResponse)
                .fromStringz.to!string;
        }

        /**
         * Return the array of directory/file names.
         *
         * Returns:
         *      Array containing the requested listing.
         */
        string[] listing() const
        {
            string[] filenames;
            size_t count = sfFtpListingResponse_getCount(m_listingResponse);

            for (uint i = 0; i < count; i++)
            {
                filenames ~= sfFtpListingResponse_getName(m_listingResponse, i)
                    .fromStringz.to!string;
            }

            return filenames;
        }
    }

    ///Define a FTP response.
    static class Response
    {
        /// Status codes possibly returned by a FTP response.
        enum Status
        {
            RestartMarkerReply = 110,
            ServiceReadySoon = 120,
            DataConnectionAlreadyOpened = 125,
            OpeningDataConnection = 150,

            Ok = 200,
            PointlessCommand = 202,
            SystemStatus = 211,
            DirectoryStatus = 212,
            FileStatus = 213,
            HelpMessage = 214,
            SystemType = 215,
            ServiceReady = 220,
            ClosingConnection = 221,
            DataConnectionOpened = 225,
            ClosingDataConnection = 226,
            EnteringPassiveMode = 227,
            LoggedIn = 230,
            FileActionOk = 250,
            DirectoryOk = 257,

            NeedPassword = 331,
            NeedAccountToLogIn = 332,
            NeedInformation = 350,
            ServiceUnavailable = 421,
            DataConnectionUnavailable = 425,
            TransferAborted = 426,
            FileActionAborted = 450,
            LocalError = 451,
            InsufficientStorageSpace = 452,

            CommandUnknown = 500,
            ParametersUnknown = 501,
            CommandNotImplemented = 502,
            BadCommandSequence = 503,
            ParameterNotImplemented = 504,
            NotLoggedIn = 530,
            NeedAccountToStore = 532,
            FileUnavailable = 550,
            PageTypeUnknown = 551,
            NotEnoughMemory = 552,
            FilenameNotAllowed = 553,

            InvalidResponse = 1000,
            ConnectionFailed = 1001,
            ConnectionClosed = 1002,
            InvalidFile = 1003,
        }

        alias Status this;

        private sfFtpResponse* m_response;

        // Internally used constructor.
        package this(sfFtpResponse* responsePointer)
        {
            m_response = responsePointer;
        }

        /// Destructor.
        ~this()
        {
            sfFtpResponse_destroy(m_response);
        }

        /**
         * Get the full message contained in the response.
         *
         * Returns:
         *      The message.
         */
        string message() const
        {
            return sfFtpResponse_getMessage(m_response).fromStringz.to!string;
        }

        /**
         * Get the status code of the response.
         *
         * Returns:
         *      Status code.
         */
        Status status() const
        {
            return Status(sfFtpResponse_getStatus(m_response));
        }

        /**
         * Check if the status code means a success.
         *
         * This function is defined for convenience, it is equivalent to testing
         * if the status code is < 400.
         *
         * Returns:
         *      true if the status is a success, false if it is a failure.
         */
        bool isOk() const
        {
            return sfFtpResponse_isOk(m_response);
        }
    }
}

private extern(C)
{
    struct sfFtp;

    struct sfFtpResponse;

    struct sfFtpDirectoryResponse;

    struct sfFtpListingResponse;

    // sfFtpListingResponse
    void sfFtpListingResponse_destroy(sfFtpListingResponse* ftpListingResponse);
    bool sfFtpListingResponse_isOk(const sfFtpListingResponse* ftpListingResponse);
    Ftp.Response.Status sfFtpListingResponse_getStatus(const sfFtpListingResponse* ftpListingResponse);
    const(char)* sfFtpListingResponse_getMessage(const sfFtpListingResponse* ftpListingResponse);
    size_t sfFtpListingResponse_getCount(const sfFtpListingResponse* ftpListingResponse);
    const(char)* sfFtpListingResponse_getName(const sfFtpListingResponse* ftpListingResponse, size_t index);

    //sfFtpDirectoryResponse
    void sfFtpDirectoryResponse_destroy(sfFtpDirectoryResponse* ftpDirectoryResponse);
    bool sfFtpDirectoryResponse_isOk(const sfFtpDirectoryResponse* ftpDirectoryResponse);
    Ftp.Response.Status sfFtpDirectoryResponse_getStatus(const sfFtpDirectoryResponse* ftpDirectoryResponse);
    const(char)* sfFtpDirectoryResponse_getMessage(const sfFtpDirectoryResponse* ftpDirectoryResponse);
    const(char)* sfFtpDirectoryResponse_getDirectory(const sfFtpDirectoryResponse* ftpDirectoryResponse);

    //sfFtpResponse
    void sfFtpResponse_destroy(sfFtpResponse* ftpResponse);
    bool sfFtpResponse_isOk(const sfFtpResponse* ftpResponse);
    Ftp.Response.Status sfFtpResponse_getStatus(const sfFtpResponse* ftpResponse);
    const(char)* sfFtpResponse_getMessage(const sfFtpResponse* ftpResponse);

    // sfFtp
    sfFtp* sfFtp_create();
    void sfFtp_destroy(sfFtp* ftp);
    sfFtpResponse* sfFtp_connect(sfFtp* ftp, sfIpAddress server, ushort port, Time timeout);
    sfFtpResponse* sfFtp_loginAnonymous(sfFtp* ftp);
    sfFtpResponse* sfFtp_login(sfFtp* ftp, const char* name, const char* password);
    sfFtpResponse* sfFtp_disconnect(sfFtp* ftp);
    sfFtpResponse* sfFtp_keepAlive(sfFtp* ftp);
    sfFtpDirectoryResponse* sfFtp_getWorkingDirectory(sfFtp* ftp);
    sfFtpListingResponse* sfFtp_getDirectoryListing(sfFtp* ftp, const char* directory);
    sfFtpResponse* sfFtp_changeDirectory(sfFtp* ftp, const char* directory);
    sfFtpResponse* sfFtp_parentDirectory(sfFtp* ftp);
    sfFtpResponse* sfFtp_createDirectory(sfFtp* ftp, const char* name);
    sfFtpResponse* sfFtp_deleteDirectory(sfFtp* ftp, const char* name);
    sfFtpResponse* sfFtp_renameFile(sfFtp* ftp, const char* file, const char* newName);
    sfFtpResponse* sfFtp_deleteFile(sfFtp* ftp, const char* name);
    sfFtpResponse* sfFtp_download(sfFtp* ftp, const char* remoteFile, const char* localPath, Ftp.TransferMode mode);
    sfFtpResponse* sfFtp_upload(sfFtp* ftp, const char* localFile, const char* remotePath, Ftp.TransferMode mode, bool append);
    sfFtpResponse* sfFtp_sendCommand(sfFtp* ftp, const char* command, const char* parameter);

}

unittest
{
    import std.stdio;
    import dsfml.system.time;
    writeln("Running Ftp unittest...");

    auto ftp = new Ftp();

    auto res = ftp.connect("cirrus.ucsd.edu", 21, seconds(15)); // Thanks, UCSanDiego !

    writefln("\tConnection response: %s", res.status());
    assert(res.isOk());

    //anonymous log in
    res = ftp.login();
    writefln("\tAnonymous login response: %s", res.status());
    assert(res.isOk());

    auto directory = ftp.workingDirectory();
    writefln("\tWorking directory response: %s", directory.status());

    assert(directory.isOk());
    writefln("\tWorking directory: %s", directory.directory());

    auto listing = ftp.directoryListing();

    assert(listing.isOk());
    writefln("\tDirectory listing: %s", listing.status());
    writeln("\tDirectory content:");

    const string[] list = listing.listing();
    assert(list.length != 0);

    foreach(string dir; list)
    {
        writefln("\t\t%s", dir);
    }
}
