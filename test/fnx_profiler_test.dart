// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:fnx_profiler/fnx_profiler.dart';
import 'package:test/test.dart';

main() {
  group('Profiler tests', () {

    setUp(() {
      clearAllStats();
    });

    test('Test basic measurements', () async {
      Profiler p = openRootProfiler("root");
      await createDelayFuture(20);
      expect(readStatsValueCount("root"), null);
      p.close();
      expect(readStatsValueCount("root"), 1);
      expect(readStatsValueMin("root") >= 20, isTrue);
    });

    test('Test Future wrapper', () async {
      Profiler p = openRootProfiler("root");
      var result = await p.profileFuture("future", createDelayFuture(20));
      expect(result, 555);
      expect(readStatsValueCount("root"), null);
      expect(readStatsValueCount("root.future"), 1);
      p.close();
      expect(readStatsValueCount("root"), 1);
      expect(readStatsValueCount("root.future"), 1);
      expect(readStatsValueMin("root") >= 20, isTrue);
      expect(readStatsValueMin("root.future") >= 20, isTrue);
    });

    test('Test Future wrapper', () async {
      Profiler p = openRootProfiler("root");
      try {
        await p.profileFuture("future", createFutureWithException());
        fail("I shouldn't get here!");
      } catch (e) {
        expect(e, "Oups!");
      }
      p.close();
      expect(readStatsValueCount("root"), 1);
      expect(readStatsValueCount("root.future"), 1);
    });

  });
}

Future createDelayFuture(int milliseconds) async {
  await new Future.delayed(new Duration(milliseconds: milliseconds));
  return 555;
}

Future createFutureWithException() async {
  await createDelayFuture(10);
  throw "Oups!";
}
