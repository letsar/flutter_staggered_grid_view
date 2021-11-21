import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/src/foundation/extensions.dart';

@immutable
class QuiltedGridTile {
  const QuiltedGridTile(
    this.mainAxisCount,
    this.crossAxisCount,
  )   : assert(mainAxisCount > 0),
        assert(crossAxisCount > 0);

  final int crossAxisCount;
  final int mainAxisCount;
}

class SliverQuiltedGridDelegate extends SliverGridDelegate {
  SliverQuiltedGridDelegate({
    required this.crossAxisCount,
    required List<QuiltedGridTile> pattern,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
  })  : assert(crossAxisCount > 0),
        assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        _pattern = pattern.toPattern(crossAxisCount);

  final int crossAxisCount;

  final _QuiltedTilePattern _pattern;

  /// {@macro fsgv.global.mainAxisSpacing}
  final double mainAxisSpacing;

  /// {@macro fsgv.global.crossAxisSpacing}
  final double crossAxisSpacing;

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
    final mainAxisCellCountBeforeLastPattern =
        (childCount ~/ pattern.tileCount) * pattern.mainAxisCellCount;

    // Then we get the number of main axis cells in the last pattern.
    final remainingMainAxisCellCount =
        pattern.maxMainAxisCellCountOf(childCount);

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

extension ListOfQuiltedTileToPatternExtension on List<QuiltedGridTile> {
  _QuiltedTilePattern toPattern(int crossAxisCount) {
    final tileCount = length;
    final minTileIndexes = <int>[];
    final maxTileIndexes = <int>[];
    final maxMainAxisCellCounts = List<int>.filled(tileCount, 0);
    final mainAxisIndexes = List<int>.filled(tileCount, 0);
    final crossAxisIndexes = List<int>.filled(tileCount, 0);

    final offsets = List<int>.generate(crossAxisCount, (index) => 0);
    for (int i = 0; i < tileCount; i++) {
      final tile = this[i];
      final crossAxisIndex = offsets.findSmallestIndexWithMinimumValue();
      final mainAxisIndex = offsets[crossAxisIndex];
      mainAxisIndexes[i] = mainAxisIndex;
      crossAxisIndexes[i] = crossAxisIndex;

      // We update the offsets.
      final crossAxisCount = tile.crossAxisCount;
      final mainAxisCount = tile.mainAxisCount;
      for (int j = 0; j < crossAxisCount; j++) {
        offsets[crossAxisIndex + j] += mainAxisCount;
      }

      // We update the min and max tile indexes.
      for (int j = 0; j < mainAxisCount; j++) {
        final index = mainAxisIndex + j;
        if (minTileIndexes.length == index) {
          minTileIndexes.add(i);
        } else {
          minTileIndexes[index] = math.min(minTileIndexes[index], i);
        }
        if (maxTileIndexes.length == index) {
          maxTileIndexes.add(i);
        } else {
          maxTileIndexes[index] = math.max(maxTileIndexes[index], i);
        }
      }

      maxMainAxisCellCounts[i] = offsets.reduce(math.max);
    }

    return _QuiltedTilePattern(
      tiles: this,
      mainAxisIndexes: mainAxisIndexes,
      crossAxisIndexes: crossAxisIndexes,
      maxMainAxisCellCounts: maxMainAxisCellCounts,
      minTileIndexes: minTileIndexes,
      maxTileIndexes: maxTileIndexes,
      mainAxisCellCount: offsets.reduce(math.max),
    );
  }
}
