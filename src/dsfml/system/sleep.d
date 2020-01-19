module dsfml.system.sleep;

public import dsfml.system.time;

/**
 * Make the current thread sleep for a given duration.
 *
 * sleep is the best way to block a program or one of its threads, as it doesn't
 * consume any CPU power.
 *
 * Params:
 *      duration = The length of time to sleep for
 */
void sleep(Time duration)
{
    import core.thread : Thread;
    import core.time : usecs;
    Thread.sleep(usecs(duration.asMicroseconds()));
}

unittest
{
    import std.stdio;

    writeln("Running sleep() unittest...");

    writeln("\tSleeping for 1 second.");
    sleep(seconds(1));

    writeln("\tSleeping for 2 seconds.");
    sleep(seconds(2));

    writeln("\tDone !");
}
