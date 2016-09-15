# fnx_profiler

A library for Dart developers. It is awesome!

fnx_profiler is an "imperative" profiler. You manually
mark blocks of code you want to profile. Profiler is hierarchical,
you can add children to it and grandchildren to them, whole clans of profilers
will help you to drill down to that performance bottleneck.

Use it like this:

    import 'package:fnx_profiler/fnx_profiler.dart'

    Profiler p = beginRootProfiler("root");
    // do something expensive
    p.end();
    printProfilerStats();

Or this:

    Profiler p = beginRootProfiler("root");
    for (int a=0; a<3; a++) {
        Profiler ch = p.begin("child");
        // do something nested
        ch.end();
    }
    p.end();

Or even this:

    Profiler p = beginRootProfiler("root");
    await p.profileFuture("future", someFuture);
    p.end();

Yes, it's pretty straightforward, even naive, but it works. Run your code,
check the results at the end, find the bottleneck, optimize and repeat.

## Example

Please see the full [example](https://github.com/fnx-io/fnx_profiler/blob/master/example/fnx_profiler_example.dart).
Example generates this output:

    name                   |     calls|  avg (ms)|  min (ms)|  max (ms)|
    --------------------------------------------------------------------
    root                   |         1|    1219.0|      1219|      1219|
    root.child0            |         1|     116.0|       116|       116|
    root.child0.grandchild |         5|      22.6|        21|        24|
    root.child1            |         1|     125.0|       125|       125|
    root.child1.grandchild |         5|      24.6|        22|        26|
    root.child2            |         1|     123.0|       123|       123|
    root.child2.grandchild |         5|      24.2|        23|        25|
    root.myFunction        |        10|      44.2|        42|        45|
    root.myFuture          |        10|      33.4|        30|        35|

## Features and bugs

Please file feature requests and bugs on [Github](https://github.com/fnx-io/fnx_profiler).