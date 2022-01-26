import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/src/foundation/extensions.dart';

/// A tile for [SliverQuiltedGridDelegate].
@immutable
class QuiltedGridTile {
  /// Create a [QuiltedGridTile].
  const QuiltedGridTile(
    this.mainAxisCount,
    this.crossAxisCount,
  )   : assert(mainAxisCount > 0),
        assert(crossAxisCount > 0);

  /// The number of cells that tile takes in the main axis.
  final int mainAxisCount;

  /// The number of cells that tile takes in the cross axis.
  final int crossAxisCount;

  @override
  String toString() {
    return 'QuiltedGridTile($mainAxisCount, $crossAxisCount)';
  }
}

/// Controls the layout of a quilted grid.
class SliverQuiltedGridDelegate extends SliverGridDelegate {
  /// Creates a [SliverQuiltedGridDelegate].
  SliverQuiltedGridDelegate({
    required this.crossAxisCount,
    required List<QuiltedGridTile> pattern,
    this.repeatPattern = QuiltedGridRepeatPattern.same,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
  })  : assert(crossAxisCount > 0),
        assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        assert(pattern.isNotEmpty),
        _pattern = pattern.toPattern(crossAxisCount, repeatPattern);

  /// {@macro fsgv.global.crossAxisCount}
  final int crossAxisCount;

  /// Describes how the pattern is repeating.
  ///
  /// The default value is [QuiltedGridRepeatPattern.same].
  final QuiltedGridRepeatPattern repeatPattern;

  /// {@macro fsgv.global.mainAxisSpacing}
  final double mainAxisSpacing;

  /// {@macro fsgv.global.crossAxisSpacing}
  final double crossAxisSpacing;

  final _QuiltedTilePattern _pattern;

  @override
  _SliverQuiltedGridLayout getLayout(SliverConstraints constraints) {
    final crossAxisExtent = constraints.crossAxisExtent;
    final cellExtent = (crossAxisExtent + crossAxisSpacing) / crossAxisCount -
        crossAxisSpacing;
    return _SliverQuiltedGridLayout(
      cellExtent: cellExtent,
      crossAxisExtent: crossAxisExtent,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      pattern: _pattern,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(SliverQuiltedGridDelegate oldDelegate) {
    return oldDelegate.crossAxisCount != crossAxisCount ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing;
  }
}

class _QuiltedTilePattern {
  const _QuiltedTilePattern({
    required this.tiles,
    required this.crossAxisIndexes,
    required this.mainAxisIndexes,
    required this.maxMainAxisCellCounts,
    required this.minTileIndexes,
    required this.maxTileIndexes,
    required this.mainAxisCellCount,
  }) : tileCount = tiles.length;

  final List<QuiltedGridTile> tiles;
  final int tileCount;
  final List<int> crossAxisIndexes;
  final List<int> mainAxisIndexes;
  final List<int> maxMainAxisCellCounts;
  final List<int> minTileIndexes;
  final List<int> maxTileIndexes;
  final int mainAxisCellCount;

  /// Gets the cross axis index of the tile at the given [index].
  int crossAxisIndexOf(int index) {
    return crossAxisIndexes[index % tileCount];
  }

  /// Gets the main axis index of the tile at the given [index].
  int mainAxisIndexOf(int index) {
    return mainAxisIndexes[index % tileCount];
  }

  /// Gets the number of cells in the main axis to fully displayed all the tiles
  /// of this pattern if we want to display [count] tiles.
  int maxMainAxisCellCountOf(int count) {
    return maxMainAxisCellCounts[count % tileCount];
  }

  int getMinTileIndexForMainAxisIndex(int mainAxisIndex) {
    return minTileIndexes[mainAxisIndex % mainAxisCellCount];
  }

  int getMaxTileIndexForMainAxisIndex(int mainAxisIndex) {
    return maxTileIndexes[mainAxisIndex % mainAxisCellCount];
  }

  QuiltedGridTile tileOf(int index) {
    return tiles[index % tileCount];
  }
}

/// Layout that looks like the Quilted image list in
/// https://material.io/components/image-lists.
class _SliverQuiltedGridLayout extends SliverGridLayout {
  const _SliverQuiltedGridLayout({
    required double cellExtent,
    required this.crossAxisExtent,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.pattern,
    required this.reverseCrossAxis,
  })  : assert(cellExtent > 0),
        assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        mainAxisStride = cellExtent + mainAxisSpacing,
        crossAxisStride = cellExtent + crossAxisSpacing;

  final double crossAxisExtent;

  /// {@macro fsgv.global.mainAxisSpacing}
  final double mainAxisSpacing;

  /// {@macro fsgv.global.crossAxisSpacing}
  final double crossAxisSpacing;

  final double mainAxisStride;

  final double crossAxisStride;

  final _QuiltedTilePattern pattern;

  /// Whether the children should be placed in the opposite order of increasing
  /// coordinates in the cross axis.
  ///
  /// For example, if the cross axis is horizontal, the children are placed from
  /// left to right when [reverseCrossAxis] is false and from right to left when
  /// [reverseCrossAxis] is true.
  ///
  /// Typically set to the return value of [axisDirectionIsReversed] applied to
  /// the [SliverConstraints.crossAxisDirection].
  final bool reverseCrossAxis;

  @override
  double computeMaxScrollOffset(int childCount) {
    // First we compute the number cells occupied in the main axis by the filled
    // patterns.

    if (childCount == 0) {
      return 0;
    }

    final mainAxisCellCountBeforeLastPattern =
        (childCount ~/ pattern.tileCount) * pattern.mainAxisCellCount;

    final remainingChildCount = childCount % pattern.tileCount;

    // Then we get the number of main axis cells in the last pattern.
    final remainingMainAxisCellCount = remainingChildCount == 0
        ? 0
        : pattern.maxMainAxisCellCountOf(remainingChildCount - 1);

    // We compute the total number of cells in the main axis.
    final nbCellsInMainAxis =
        mainAxisCellCountBeforeLastPattern + remainingMainAxisCellCount;

    return nbCellsInMainAxis * mainAxisStride - mainAxisSpacing;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    // First we compute the number cells occupied in the main axis by the filled
    // patterns.
    final mainAxisCellCountBeforeLastPattern =
        (index ~/ pattern.tileCount) * pattern.mainAxisCellCount;
    final mainAxisIndex =
        mainAxisCellCountBeforeLastPattern + pattern.mainAxisIndexOf(index);
    final crossAxisIndex = pattern.crossAxisIndexOf(index);
    final tile = pattern.tileOf(index);

    final crossAxisExtent =
        tile.crossAxisCount * crossAxisStride - crossAxisSpacing;

    return SliverGridGeometry(
      scrollOffset: mainAxisIndex * mainAxisStride,
      crossAxisOffset: _getOffsetFromStartInCrossAxis(
        crossAxisIndex * crossAxisStride,
        crossAxisExtent,
      ),
      mainAxisExtent: tile.mainAxisCount * mainAxisStride - mainAxisSpacing,
      crossAxisExtent: crossAxisExtent,
    );
  }

  double _getOffsetFromStartInCrossAxis(
    double crossAxisStart,
    double childCrossAxisExtent,
  ) {
    if (reverseCrossAxis)
      return crossAxisExtent - crossAxisStart - childCrossAxisExtent;
    return crossAxisStart;
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    final mainAxisIndex = (scrollOffset ~/ mainAxisStride);
    final a = (mainAxisIndex ~/ pattern.tileCount) * pattern.tileCount;
    final result = a + pattern.getMinTileIndexForMainAxisIndex(mainAxisIndex);
    return result;
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    final mainAxisIndex = (scrollOffset ~/ mainAxisStride);
    final a = (mainAxisIndex ~/ pattern.mainAxisCellCount) * pattern.tileCount;
    final result = a + pattern.getMaxTileIndexForMainAxisIndex(mainAxisIndex);
    return result;
  }
}

/// Defines how a pattern is repeating.
abstract class QuiltedGridRepeatPattern {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const QuiltedGridRepeatPattern();

  /// The same pattern is repeating over and over.
  static const QuiltedGridRepeatPattern same = _QuiltedGridRepeatSamePattern();

  /// Every two blocks, the pattern is inverted (by central inversion).
  ///
  /// For example, the following pattern:
  ///
  /// A A C D
  /// A A E E
  ///
  /// Will be inverted to:
  ///
  /// E E A A
  /// D C A A
  static const QuiltedGridRepeatPattern inverted =
      _QuiltedGridRepeatInvertedPattern();

  /// Every two blocks, the pattern is mirrored (by axial symmetry).
  ///
  /// For example, the following pattern:
  ///
  /// A A C D
  /// A A E E
  ///
  /// Will be mirrored to:
  ///
  /// A A E E
  /// A A C D
  static const QuiltedGridRepeatPattern mirrored =
      _QuiltedGridRepeatMirroredPattern();

  /// Returns the indexes in the repeating pattern order.
  List<int> repeatedIndexes(List<int> indexes, int crossAxisCount);

  /// Returns the number of tiles in the repeating pattern.
  int repeatedTileCount(int tileCount);
}

class _QuiltedGridRepeatSamePattern extends QuiltedGridRepeatPattern {
  const _QuiltedGridRepeatSamePattern();

  @override
  List<int> repeatedIndexes(List<int> indexes, int crossAxisCount) {
    return [];
  }

  @override
  int repeatedTileCount(int tileCount) => 0;
}

class _QuiltedGridRepeatInvertedPattern extends QuiltedGridRepeatPattern {
  const _QuiltedGridRepeatInvertedPattern();

  @override
  List<int> repeatedIndexes(List<int> indexes, int crossAxisCount) {
    // We iterate through the indexes in reverse order to get the index of the
    // tiles in inversed order.
    final result = <int>[];
    final added = <int>{};
    for (int i = indexes.length - 1; i >= 0; i--) {
      final index = indexes[i];
      if (index != -1 && !added.contains(index)) {
        result.add(index);
        added.add(index);
      }
    }

    return result;
  }

  @override
  int repeatedTileCount(int tileCount) => tileCount;
}

class _QuiltedGridRepeatMirroredPattern extends QuiltedGridRepeatPattern {
  const _QuiltedGridRepeatMirroredPattern();

  @override
  List<int> repeatedIndexes(List<int> indexes, int crossAxisCount) {
    // We iterate through the indexes in reverse order to get the index of the
    // tiles in inversed order.
    final result = <int>[];
    final added = <int>{};

    final mainAxisCount = indexes.length ~/ crossAxisCount;

    for (int i = mainAxisCount - 1; i >= 0; i--) {
      for (int j = 0; j < crossAxisCount; j++) {
        final index = indexes[i * crossAxisCount + j];
        if (index != -1 && !added.contains(index)) {
          result.add(index);
          added.add(index);
        }
      }
    }

    return result;
  }

  @override
  int repeatedTileCount(int tileCount) => tileCount;
}

extension on List<QuiltedGridTile> {
  _QuiltedTilePattern toPattern(
    int crossAxisCount,
    QuiltedGridRepeatPattern repeatPattern,
  ) {
    final tileCount = length + repeatPattern.repeatedTileCount(length);
    final minTileIndexes = <int>[];
    final maxTileIndexes = <int>[];
    final maxMainAxisCellCounts = List<int>.filled(tileCount, 0);
    final mainAxisIndexes = List<int>.filled(tileCount, 0);
    final crossAxisIndexes = List<int>.filled(tileCount, 0);
    // The index of the tile occupied by each cell.
    final indexes = <int, int>{};

    final offsets = List<int>.generate(crossAxisCount, (index) => 0);
    void position(
      List<QuiltedGridTile> tiles,
      Map<int, int>? indexes,
      int start,
    ) {
      for (int i = 0; i < tiles.length; i++) {
        final tile = tiles[i];
        final fullIndex = start + i;
        final crossAxisIndex = offsets.findSmallestIndexWithMinimumValue();
        final mainAxisIndex = offsets[crossAxisIndex];
        mainAxisIndexes[fullIndex] = mainAxisIndex;
        crossAxisIndexes[fullIndex] = crossAxisIndex;

        // We update the offsets.
        final tileCrossAxisCount = tile.crossAxisCount;
        final tileMainAxisCount = tile.mainAxisCount;
        for (int j = 0; j < tileCrossAxisCount; j++) {
          offsets[crossAxisIndex + j] += tileMainAxisCount;

          if (indexes != null) {
            for (int k = 0; k < tileMainAxisCount; k++) {
              final cellIndex =
                  (crossAxisIndex + j) + (mainAxisIndex + k) * crossAxisCount;
              indexes[cellIndex] = i;
            }
          }
        }

        // We update the min and max tile indexes.
        for (int j = 0; j < tileMainAxisCount; j++) {
          final index = mainAxisIndex + j;
          if (minTileIndexes.length == index) {
            minTileIndexes.add(fullIndex);
          } else {
            minTileIndexes[index] = math.min(minTileIndexes[index], fullIndex);
          }
          if (maxTileIndexes.length == index) {
            maxTileIndexes.add(fullIndex);
          } else {
            maxTileIndexes[index] = math.max(maxTileIndexes[index], fullIndex);
          }
        }

        maxMainAxisCellCounts[fullIndex] = offsets.reduce(math.max);
      }
    }

    position(this, indexes, 0);
    final indexList = List<int>.filled(indexes.length, -1);
    for (final index in indexes.keys) {
      indexList[index] = indexes[index]!;
    }
    final repeatedIndexes = repeatPattern.repeatedIndexes(
      indexList,
      crossAxisCount,
    );
    final tiles = toList();
    if (repeatedIndexes.isNotEmpty) {
      final repeatedTiles =
          repeatedIndexes.map((index) => this[index]).toList();
      position(repeatedTiles, null, length);
      tiles.addAll(repeatedTiles);
    }

    return _QuiltedTilePattern(
      tiles: tiles,
      mainAxisIndexes: mainAxisIndexes,
      crossAxisIndexes: crossAxisIndexes,
      maxMainAxisCellCounts: maxMainAxisCellCounts,
      minTileIndexes: minTileIndexes,
      maxTileIndexes: maxTileIndexes,
      mainAxisCellCount: offsets.reduce(math.max),
    );
  }
}
