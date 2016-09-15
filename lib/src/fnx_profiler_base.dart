part of fnx_profiler;

bool profilerExceptions = true;

Map<String, _ProfilerStats> _stats = {};

/// This is the entrypoint for your profiling.
///
/// Open new root profiler and than add children to it.
Profiler openRootProfiler(String name) {
  return new Profiler._(name, null);
}

/// Print overall results of profilers
void printProfilerStats() {

  int maxNameLength = 0;
  _stats.keys.forEach((String name) => maxNameLength = max(maxNameLength, name.length));

  maxNameLength += 1;

  StringBuffer sb = new StringBuffer();
  sb.write("name".padRight(maxNameLength));
  sb.write("|");
  sb.write("calls".padLeft(10));
  sb.write("|");
  sb.write("avg (ms)".padLeft(10));
  sb.write("|");
  sb.write("min (ms)".padLeft(10));
  sb.write("|");
  sb.write("max (ms)".padLeft(10));
  sb.write("|");
  print(sb);

  print("".padRight(maxNameLength + 4*10 + 5, '-'));

  List<_ProfilerStats> sorted = _stats.values.toList();
  sorted.sort((_ProfilerStats p1, _ProfilerStats p2) => p1._name.compareTo(p2._name));
  sorted.forEach((_ProfilerStats ps ) {
    StringBuffer sb = new StringBuffer();
    sb.write(ps._name.padRight(maxNameLength));
    sb.write("|");
    sb.write(ps._count.toString().padLeft(10));
    sb.write("|");
    sb.write(ps._avg.toStringAsFixed(1).padLeft(10));
    sb.write("|");
    sb.write(ps._min.toString().padLeft(10));
    sb.write("|");
    sb.write(ps._max.toString().padLeft(10));
    sb.write("|");
    print(sb);
  });
}

/// Profiler measures duration of one block of a code.
/// Open a root profiler with global function beginRootProfiler("myName") and close it
/// at the end of your program.
class Profiler {

  Profiler _parent;
  bool _closed = false;
  String _name;
  DateTime _started;
  List<Profiler> _children = [];

  Profiler._(String name, this._parent) {
    _started = new DateTime.now();
    if (profilerExceptions && name == null) {
      throw "Please provide short name for your profiler: root, myMethod, myComponent, ...";
    }
    if (_parent != null) {
      _name = _parent._name+"."+name;
    } else {
      _name = name;
    }
  }

  /// Mark the end of profiled block. Stats are created at this point
  /// if you miss some stats results, maybe you didn't close your profiler?
  void close() {
    if (_closed && profilerExceptions) {
      throw "Profiler '${this}' is already closed";
    }
    Duration d = new DateTime.now().difference(_started);
    _ProfilerStats s = _stats[_name];
    if (s == null) {
      s = new _ProfilerStats(_name);
      _stats[_name] = s;
    }
    s._addMeasurement(d.inMilliseconds);
    _closed = true;
    if (_parent != null) {
      _parent._remove(this);
      _parent = null;
    }
  }

  /// Create a new nested profiler. Don't forget to close it at the end of the block
  /// with close() method.
  Profiler openChild(String name) {
    Profiler child = new Profiler._(name, this);
    _children.add(child);
    return child;
  }

  /// Helper method to profile a Future.
  /// Returns Future with the same value as the wrapped one, exceptions
  /// stay untouched.
  Future profileFuture(String name, Future future) async {
    Profiler child = openChild(name);
    var futureResult;
    try {
      futureResult = await future;
    } finally {
      child.close();
    }
    return futureResult;
  }

  @override
  String toString() {
    return _name;
  }

  void _remove(Profiler profiler) {
    _children.remove(profiler);
  }
}

class _ProfilerStats {

  String _name;
  int _count = 0;
  int _min = -1;
  int _max = 0;
  int _sum = 0;
  double get _avg => _count == 0 ? 0 : _sum / _count;

  _ProfilerStats(this._name);

  void _addMeasurement(int duration) {
    _count++;
    if (_min < 0) {
      _min = duration;
    } else {
      _min = min(_min, duration);
    }
    _max = max(_max, duration);
    _sum += duration;
  }

}

/// For testing purposes only
int readStatsValueCount(String name) {
  return _stats[name]?._count;
}

/// For testing purposes only
int readStatsValueMin(String name) {
  return _stats[name]?._min;
}

/// For testing purposes only
void clearAllStats() {
  _stats.clear();
}