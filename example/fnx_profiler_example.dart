// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:fnx_profiler/fnx_profiler.dart' as p;

main() async {

  // open the root profiler, father of all
  p.Profiler root = p.beginRootProfiler("root");

  // do something expensive
  await createDelayFuture(50);

  for (int a=0; a<10; a++) {
    // open child profiler
    p.Profiler child = root.begin("myFunction");
    await createDelayFuture(40);
    // close it after execution
    child.end();
  }

  for (int a=0; a<10; a++) {
    // profile Future with this helper method
    await root.profileFuture("myFuture", createDelayFuture(30));
  }

  for (int a=0; a<3; a++) {
    p.Profiler child = root.begin("child${a}");
    for (int b=0; b<5; b++) {
      // nest your profilers as needed and drill down to the bottleneck
      p.Profiler grandChild = child.begin("grandchild");
      await new Future.delayed(new Duration(milliseconds: 20));
      // just remember to close them
      grandChild.end();
    }
    child.end();
  }

  // close profiler
  root.end();

  // print results, find the bottleneck, optimize, repeat!
  p.printProfilerStats();
}

Future createDelayFuture(int milliseconds) {
  return new Future.delayed(new Duration(milliseconds: milliseconds));
}