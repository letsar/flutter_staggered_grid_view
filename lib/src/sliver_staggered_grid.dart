import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_staggered_grid_view/src/staggered_tile.dart';

/// Signature for a function that creates [StaggeredTile] for a given index.
typedef StaggeredTile IndexedStaggeredTileBuilder(int index);

/// Creates grid layouts with a fixed number of cells in the cross axis.
///
/// For example, if the grid is vertical, this delegate will create a layout
/// with a fixed number of columns. If the grid is horizontal, this delegate
/// will create a layout with a fixed number of rows.
///
/// This delegate creates grids with variable sized but equally spaced tiles.
///
/// See also:
///
///  * [SliverGridDelegate], which creates arbitrary layouts.
///  * [GridView], which can use this delegate to control the layout of its
///    tiles.
///  * [SliverGrid], which can use this delegate to control the layout of its
///    tiles.
///  * [RenderSliverGrid], which can use this delegate to control the layout of
///    its tiles.
class SliverStaggeredGridDelegate extends SliverGridDelegate {
  const SliverStaggeredGridDelegate({
    @required this.crossAxisCount,
    @required this.staggeredTileBuilder,
    this.mainAxisSpacing: 0.0,
    this.crossAxisSpacing: 0.0,
  })
      : assert(crossAxisCount != null && crossAxisCount > 0),
        assert(staggeredTileBuilder != null),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0);

  /// The number of children in the cross axis.
  final int crossAxisCount;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  /// Called to get the tile at the specified index for the
  /// [SliverGridStaggeredTileLayout].
  final IndexedStaggeredTileBuilder staggeredTileBuilder;

  bool _debugAssertIsValid() {
    assert(crossAxisCount > 0);
    assert(staggeredTileBuilder != null);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    return true;
  }

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    assert(_debugAssertIsValid());
    final double usableCrossAxisExtent =
        constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
    final double cellExtent = usableCrossAxisExtent / crossAxisCount;
    return new SliverGridStaggeredTileLayout(
      crossAxisCount: crossAxisCount,
      staggeredTileBuilder: staggeredTileBuilder,
      cellExtent: cellExtent,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(SliverStaggeredGridDelegate oldDelegate) {
    return oldDelegate.crossAxisCount != crossAxisCount ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.staggeredTileBuilder != staggeredTileBuilder;
  }
}

/// A [SliverGridLayout] that uses variable sized but equally spaced tiles.
///
/// This layout is used by [SliverStaggeredGridDelegate].
class SliverGridStaggeredTileLayout extends SliverGridLayout {
  /// Creates a layout that uses variable sized but equally spaced tiles.
  ///
  /// All of the arguments must not be null and must not be negative. The
  /// [crossAxisCount] argument must be greater than zero.
  SliverGridStaggeredTileLayout({
    @required this.crossAxisCount,
    @required this.staggeredTileBuilder,
    @required this.cellExtent,
    @required this.mainAxisSpacing,
    @required this.crossAxisSpacing,
    @required this.reverseCrossAxis,
  })
      : assert(crossAxisCount != null && crossAxisCount > 0),
        assert(staggeredTileBuilder != null),
        assert(cellExtent != null && cellExtent >= 0),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0),
        assert(reverseCrossAxis != null),
        _cellStride = cellExtent + crossAxisSpacing,
        _staggeredTileGeometries = new Map(),
        _mainAxisOffsets = new List.generate(crossAxisCount, (i) => 0.0);

  /// The maximum number of children in the cross axis.
  final int crossAxisCount;

  /// The number of pixels from the leading edge of one cell to the trailing
  /// edge of the same cell in both axis.
  final double cellExtent;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  /// Called to get the tile at the specified index for the
  /// [SliverGridStaggeredTileLayout].
  final IndexedStaggeredTileBuilder staggeredTileBuilder;

  final Map<int, _StaggeredTileGeometry> _staggeredTileGeometries;

  final List<double> _mainAxisOffsets;

  final double _cellStride;

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
    if (childCount == null) {
      return null;
    } else {
      _getStaggeredTileGeometry(childCount - 1);
      var maxScrollOffset = _mainAxisOffsets.reduce(math.max);
      return maxScrollOffset;
    }
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    return _getStaggeredTileGeometry(index).geometry;
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    int index = 0;
    List<double> offsets = new List.generate(crossAxisCount, (i) => 0.0);

    while (true) {
      var tileGeometry = _getStaggeredTileGeometry(index);
      if (tileGeometry == null) return index - 1;
      for (var i = 0; i < tileGeometry.tile.crossAxisCellCount; i++) {
        offsets[i + tileGeometry.startIndex] =
            tileGeometry.geometry.trailingScrollOffset;
      }
      if (!offsets.any((i) => i <= scrollOffset)) return index;
      ++index;
    }
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    int index = 0;
    while (true) {
      var geometry = _getStaggeredTileGeometry(index)?.geometry;
      if (geometry == null) return index - 1;
      if (geometry.trailingScrollOffset >= scrollOffset) return index;
      ++index;
    }
  }

  /// Finds the first available block with at least the specified [crossAxisCount].
  _Block _findFirstAvailableBlockWithCrossAxisCount(int crossAxisCount) {
    return _findFirstAvailableBlockWithCrossAxisCountAndOffsets(
        crossAxisCount, new List.from(_mainAxisOffsets));
  }

  _StaggeredTileGeometry _getStaggeredTileGeometry(int index) {
    _StaggeredTileGeometry tileGeometry = _staggeredTileGeometries[index];

    if (tileGeometry == null) {
      // Populates the tiles geometries from the last computed index to this
      // index.
      for (var i = _staggeredTileGeometries.length; i < index; ++i) {
        var x = _getStaggeredTileGeometry(i);
        if (x == null) return null;
      }

      var staggeredTile = _normalizeStaggeredTile(staggeredTileBuilder(index));
      if (staggeredTile == null) {
        return null;
      }

      var block = _findFirstAvailableBlockWithCrossAxisCount(
          staggeredTile.crossAxisCellCount);

      var scrollOffset = block.minOffset;

      var blockIndex = block.index;
      if (reverseCrossAxis) {
        blockIndex = crossAxisCount - 1 - blockIndex;
      }
      var crossAxisOffset = blockIndex * _cellStride;

      var geometry = new SliverGridGeometry(
          scrollOffset: scrollOffset,
          crossAxisOffset: crossAxisOffset,
          mainAxisExtent: staggeredTile.mainAxisExtent,
          crossAxisExtent: _cellStride * staggeredTile.crossAxisCellCount -
              crossAxisSpacing);
      tileGeometry =
          new _StaggeredTileGeometry(staggeredTile, geometry, block.index);
      _staggeredTileGeometries[index] = tileGeometry;
      var stride = staggeredTile.mainAxisExtent + mainAxisSpacing;
      for (var i = 0; i < staggeredTile.crossAxisCellCount; i++) {
        _mainAxisOffsets[i + block.index] = block.minOffset + stride;
      }
    }
    return tileGeometry;
  }

  double _getStaggeredTileMainAxisExtent(StaggeredTile tile) {
    return tile.mainAxisExtent ??
        (tile.mainAxisCellCount * cellExtent) +
            (tile.mainAxisCellCount - 1) * mainAxisSpacing;
  }

  StaggeredTile _normalizeStaggeredTile(StaggeredTile staggeredTile) {
    if (staggeredTile == null) {
      return null;
    } else {
      int crossAxisCellCount =
          staggeredTile.crossAxisCellCount.clamp(0, crossAxisCount);
      return new StaggeredTile.extent(
          crossAxisCellCount, _getStaggeredTileMainAxisExtent(staggeredTile));
    }
  }

  /// Finds the first available block with at least the specified [crossAxisCount].
  static _Block _findFirstAvailableBlockWithCrossAxisCountAndOffsets(
      int crossAxisCount, List<double> offsets) {
    _Block block = _findFirstAvailableBlock(offsets);
    if (block.crossAxisCount < crossAxisCount) {
      // Not enough space for the specified cross axis count.
      // We have to fill this block and try again.
      for (var i = 0; i < block.crossAxisCount; ++i) {
        offsets[i + block.index] = block.maxOffset;
      }
      return _findFirstAvailableBlockWithCrossAxisCountAndOffsets(
          crossAxisCount, offsets);
    } else {
      return block;
    }
  }

  /// Finds the first available block for the specified [offsets] list.
  static _Block _findFirstAvailableBlock(List<double> offsets) {
    int index = 0;
    double minBlockOffset = double.INFINITY;
    double maxBlockOffset = double.INFINITY;
    int crossAxisCount = 1;
    bool contiguous = false;

    for (var i = index; i < offsets.length; ++i) {
      var offset = offsets[i];
      if (offset < minBlockOffset) {
        index = i;
        maxBlockOffset = minBlockOffset;
        minBlockOffset = offset;
        crossAxisCount = 1;
        contiguous = true;
      } else if (offset == minBlockOffset && contiguous) {
        crossAxisCount++;
      } else if (offset < maxBlockOffset && offset > minBlockOffset) {
        contiguous = false;
        maxBlockOffset = offset;
      } else {
        contiguous = false;
      }
    }

    return new _Block(index, crossAxisCount, minBlockOffset, maxBlockOffset);
  }
}

class _Block {
  const _Block(this.index, this.crossAxisCount, this.minOffset, this.maxOffset);

  final int index;
  final int crossAxisCount;
  final double minOffset;
  final double maxOffset;
}

class _StaggeredTileGeometry {
  const _StaggeredTileGeometry(this.tile, this.geometry, this.startIndex);

  final StaggeredTile tile;
  final SliverGridGeometry geometry;
  final int startIndex;
}
