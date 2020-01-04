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
 * $(U Mutex) stands for "MUTual EXclusion". A mutex is a synchronization
 * object, used when multiple threads are involved.
 *
 * When you want to protect a part of the code from being accessed
 * simultaneously by multiple threads, you typically use a mutex. When a thread
 * is locked by a mutex, any other thread trying to lock it will be blocked
 * until the mutex is released by the thread that locked it. This way, you can
 * allow only one thread at a time to access a critical region of your code.
 *
 * Example:
 * ---
 * // this is a critical resource that needs some protection
 * Database database;
 * auto mutex = Mutex();
 *
 * void thread1()
 * {
 *     // this call will block the thread if the mutex is already locked by thread2
 *     mutex.lock();
 *     database.write(...);
 *     // if thread2 was waiting, it will now be unblocked
 *     mutex.unlock();
 * }
 *
 * void thread2()
 * {
 *     // this call will block the thread if the mutex is already locked by thread1
 *     mutex.lock();
 *     database.write(...);
 *     mutex.unlock(); // if thread1 was waiting, it will now be unblocked
 * }
 * ---
 *
 * $(PARA Be very careful with mutexes. A bad usage can lead to bad problems,
 * like deadlocks (two threads are waiting for each other and the application is
 * globally stuck).
 *
 * To make the usage of mutexes more robust, particularly in environments where
 * exceptions can be thrown, you should use the helper class $(LOCK_LINK) to
 * lock/unlock mutexes.
 *
 * DSFML mutexes are recursive, which means that you can lock a mutex multiple
 * times in the same thread without creating a deadlock. In this case, the first
 * call to `lock()` behaves as usual, and the following ones have no effect.
 * However, you must call `unlock()` exactly as many times as you called
 * `lock()`. If you don't, the mutex won't be released.
 *
 * Note that the $(U Mutex) class is added for convenience, and is nothing more
 * than a simnple wrapper around the existing core.sync.mutex.Mutex class.)
 *
 * See_Also:
 * $(LOCK_LINK)
 */
module dsfml.system.mutex;

import core = core.sync.mutex;

/**
 * Blocks concurrent access to shared resources from multiple threads.
 */
class Mutex
{
    private core.Mutex m_mutex;

    /// Default Constructor
    this()
    {
        m_mutex = new core.Mutex();
    }

    /**
     * Lock the mutex
     *
     * If the mutex is already locked in another thread, this call will block
     * the execution until the mutex is released.
     */
    void lock()
    {
        m_mutex.lock();
    }

    /// Unlock the mutex.
    void unlock()
    {
        m_mutex.unlock();
    }
}

unittest
{
    import dsfml.system.thread;
    import dsfml.system.sleep;
    import dsfml.system.time;
    import std.stdio;

    writeln("Running Mutex unittest...");

    auto mutex = new Mutex();
    string result = "";

    void thread1()
    {
        mutex.lock();
        for(int i = 0; i < 10; ++i)
        {
            sleep(seconds(0.01));
            result ~= "1";
        }
        mutex.unlock();
    }

    void thread2()
    {
        mutex.lock();
        for(int i = 0; i < 10; ++i)
        {
            sleep(seconds(0.01));
            result ~= "2";
        }
        mutex.unlock();
    }

    auto t1 = new Thread(&thread1);
    auto t2 = new Thread(&thread2);
    t1.launch();
    // Sometimes t2 is launched before t1
    sleep(seconds(0.01));
    t2.launch();

    // waiting for the threads to finish before calling the asserts.
    t1.wait();
    t2.wait();

    assert(result == "11111111112222222222");
}
