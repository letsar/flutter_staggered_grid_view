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
/// Since a child is always placed in the lane with the smallest end, the
/// starts of the children are sorted. The running maximum of the ends is also
/// sorted. This allows to find the visible children with binary searches.
class MasonryCache {
  Float64List _starts = Float64List(0);
  Float64List _ends = Float64List(0);
  Float64List _maxEnds = Float64List(0);
  Uint16List _lanes = Uint16List(0);

  /// The offset at which the next child of each lane can be placed.
  Float64List _laneEnds = Float64List(0);

  int _length = 0;
  int get length => _length;

  int _crossAxisCount = 0;

  double _childCrossAxisExtent = 0;
  double get childCrossAxisExtent => _childCrossAxisExtent;

  double _mainAxisSpacing = 0;

  /// Whether the cached placements can be used for the given configuration.
  bool isValidFor({
    required int crossAxisCount,
    required double childCrossAxisExtent,
    required double mainAxisSpacing,
  }) {
    return _crossAxisCount == crossAxisCount &&
        _childCrossAxisExtent == childCrossAxisExtent &&
        _mainAxisSpacing == mainAxisSpacing;
  }

  /// Removes all the placements and uses the given configuration.
  void reset({
    required int crossAxisCount,
    required double childCrossAxisExtent,
    required double mainAxisSpacing,
  }) {
    // Lanes are stored on 16 bits.
    assert(crossAxisCount > 0 && crossAxisCount <= 0xFFFF);
    _crossAxisCount = crossAxisCount;
    _childCrossAxisExtent = childCrossAxisExtent;
    _mainAxisSpacing = mainAxisSpacing;
    _laneEnds = Float64List(crossAxisCount);
    _length = 0;
  }

  double startOf(int index) => _starts[_checkIndex(index)];

  double extentOf(int index) => _ends[_checkIndex(index)] - _starts[index];

  int laneOf(int index) => _lanes[_checkIndex(index)];

  /// The end of the last cached child in the main axis.
  double get extent => _length == 0 ? 0 : _maxEnds[_length - 1];

  /// Whether every child that is not cached yet would start at or after
  /// [offset].
  bool covers(double offset) => _laneEnds.every((end) => end >= offset);

  /// Places a child of the given [extent] after the last cached child.
  ///
  /// The child is put in the lane with the smallest end. If several lanes have
  /// the same end, the one with the smallest index is chosen.
  void add(double extent) {
    assert(_crossAxisCount > 0);
    _ensureCapacity(_length + 1);

    final lane = _laneEnds.findSmallestIndexWithMinimumValue();

    final start = _laneEnds[lane];
    final end = start + extent;
    final index = _length;
    _starts[index] = start;
    _ends[index] = end;
    _maxEnds[index] = index == 0 ? end : math.max(_maxEnds[index - 1], end);
    _lanes[index] = lane;
    _laneEnds[lane] = end + _mainAxisSpacing;
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
      if (!found[lane]) {
        found[lane] = true;
        remainingLanes--;
        _laneEnds[lane] = _ends[i] + _mainAxisSpacing;
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
    _ends = _grow(_ends, newCapacity);
    _maxEnds = _grow(_maxEnds, newCapacity);
    _lanes = Uint16List(newCapacity)..setRange(0, _length, _lanes);
  }

  static Float64List _grow(Float64List list, int capacity) {
    return Float64List(capacity)..setRange(0, list.length, list);
  }
}
