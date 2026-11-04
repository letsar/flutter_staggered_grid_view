// ignore_for_file: public_member_api_docs

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_staggered_grid_view/src/foundation/extensions.dart';

/// Stores the placement of every child of a masonry grid, from index 0 up to
/// [length] - 1.
///
/// In a masonry layout, the position of a child depends on the extents of all
/// the children before it. Instead of trying to recompute the position of a
/// child from the ones after it (which is not possible), we record the
/// placement of each child the first time it is laid out, always going
/// forward. The placement of any cached child is then known exactly, even if
/// the child has been garbage collected.
///
/// Since a child is always placed in the lane with the smallest end (or after
/// all the lanes if it spans all of them), the starts of the children are
/// sorted. The running maximum of the ends is also sorted. This allows to find
/// the visible children with binary searches.
class MasonryCache {
  /// The lane of the children which span all the lanes.
  static const int _fullSpanLane = 0xFFFF;

  Float64List _starts = Float64List(0);
  // The extents are stored as is: computing them from the ends would lose
  // precision for large offsets.
  Float64List _extents = Float64List(0);
  Float64List _maxEnds = Float64List(0);
  Uint16List _lanes = Uint16List(0);

  /// The offset at which the next child of each lane can be placed.
  Float64List _laneEnds = Float64List(0);

  int _length = 0;
  int get length => _length;

  int _crossAxisCount = 0;

  double _mainAxisSpacing = 0;

  /// Whether the cached placements can be used for the given configuration.
  bool isValidFor({
    required int crossAxisCount,
    required double mainAxisSpacing,
  }) {
    return _crossAxisCount == crossAxisCount &&
        _mainAxisSpacing == mainAxisSpacing;
  }

  /// Removes all the placements and uses the given configuration.
  void reset({
    required int crossAxisCount,
    required double mainAxisSpacing,
  }) {
    // Lanes are stored on 16 bits, and the last value is reserved.
    assert(crossAxisCount > 0 && crossAxisCount < _fullSpanLane);
    _crossAxisCount = crossAxisCount;
    _mainAxisSpacing = mainAxisSpacing;
    _laneEnds = Float64List(crossAxisCount);
    _length = 0;
  }

  double startOf(int index) => _starts[_checkIndex(index)];

  double extentOf(int index) => _extents[_checkIndex(index)];

  /// The lane of the child at [index], or null if it spans all the lanes.
  int? laneOf(int index) {
    final lane = _lanes[_checkIndex(index)];
    return lane == _fullSpanLane ? null : lane;
  }

  /// The end of the last cached child in the main axis.
  double get extent => _length == 0 ? 0 : _maxEnds[_length - 1];

  /// Whether every child that is not cached yet would start at or after
  /// [offset].
  bool covers(double offset) {
    for (int i = 0; i < _crossAxisCount; i++) {
      if (_laneEnds[i] < offset) {
        return false;
      }
    }
    return true;
  }

  /// Places a child of the given [extent] after the last cached child.
  ///
  /// The child is put in the lane with the smallest end. If several lanes have
  /// the same end, the one with the smallest index is chosen.
  ///
  /// If [fullSpan] is true, the child spans all the lanes: it starts after the
  /// end of all of them, and all of them end with it.
  void add(double extent, {bool fullSpan = false}) {
    assert(_crossAxisCount > 0);
    _ensureCapacity(_length + 1);

    final lane = fullSpan
        ? _fullSpanLane
        : _laneEnds.findSmallestIndexWithMinimumValue();
    final start = fullSpan ? _laneEnds.reduce(math.max) : _laneEnds[lane];
    final end = start + extent;
    final index = _length;
    _starts[index] = start;
    _extents[index] = extent;
    _maxEnds[index] = index == 0 ? end : math.max(_maxEnds[index - 1], end);
    _lanes[index] = lane;
    if (fullSpan) {
      _laneEnds.fillRange(0, _crossAxisCount, end + _mainAxisSpacing);
    } else {
      _laneEnds[lane] = end + _mainAxisSpacing;
    }
    _length++;
  }

  /// Removes the placements of the children at [length] and after.
  void truncate(int length) {
    if (length >= _length) {
      return;
    }
    _length = length;

    // Restores the end of each lane from the last child placed in it.
    _laneEnds.fillRange(0, _crossAxisCount, 0);
    int remainingLanes = _crossAxisCount;
    final found = List<bool>.filled(_crossAxisCount, false);
    for (int i = length - 1; i >= 0 && remainingLanes > 0; i--) {
      final lane = _lanes[i];
      final laneEnd = _starts[i] + _extents[i] + _mainAxisSpacing;
      if (lane == _fullSpanLane) {
        // The lanes which have no child after this one end with it.
        for (int j = 0; j < _crossAxisCount; j++) {
          if (!found[j]) {
            _laneEnds[j] = laneEnd;
          }
        }
        break;
      }
      if (!found[lane]) {
        found[lane] = true;
        remainingLanes--;
        _laneEnds[lane] = laneEnd;
      }
    }
  }

  /// The smallest index of a child which ends at or after [offset], or
  /// [length] if there is none.
  ///
  /// A child with a zero extent at [offset] is included, so that it is built
  /// and can grow.
  int firstIndexEndingAtOrAfter(double offset) {
    return _lowerBound(_maxEnds, (value) => value >= offset);
  }

  /// The smallest index of a child which starts at or after [offset], or
  /// [length] if there is none.
  int firstIndexStartingAtOrAfter(double offset) {
    return _lowerBound(_starts, (value) => value >= offset);
  }

  /// Returns the smallest index in a sorted list for which [test] is true.
  int _lowerBound(Float64List values, bool Function(double value) test) {
    int min = 0;
    int max = _length;
    while (min < max) {
      final mid = min + ((max - min) >> 1);
      if (test(values[mid])) {
        max = mid;
      } else {
        min = mid + 1;
      }
    }
    return min;
  }

  int _checkIndex(int index) {
    if (index < 0 || index >= _length) {
      throw RangeError.index(index, this, 'index', null, _length);
    }
    return index;
  }

  void _ensureCapacity(int capacity) {
    if (_starts.length >= capacity) {
      return;
    }

    final newCapacity = math.max(_starts.length * 2, 64);
    _starts = _grow(_starts, newCapacity);
    _extents = _grow(_extents, newCapacity);
    _maxEnds = _grow(_maxEnds, newCapacity);
    _lanes = Uint16List(newCapacity)..setRange(0, _length, _lanes);
  }

  static Float64List _grow(Float64List list, int capacity) {
    return Float64List(capacity)..setRange(0, list.length, list);
  }
}
