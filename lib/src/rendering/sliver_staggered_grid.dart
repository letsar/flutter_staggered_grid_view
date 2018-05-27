import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_staggered_grid_view/src/widgets/staggered_tile.dart';

/// Signature for a function that creates [StaggeredTile] for a given index.
typedef StaggeredTile IndexedStaggeredTileBuilder(int index);

/// Describes the placement of a child in a [RenderSliverStaggeredGrid].
///
/// See also:
///
///  * [SliverStaggeredGridLayout], which represents the geometry of all the tiles in a
///    grid.
///  * [SliverStaggeredGridLayout.getGeometryForChildIndex], which returns this object
///    to describe the child's placement.
///  * [RenderSliverStaggeredGrid], which uses this class during its
///    [RenderSliverStaggeredGrid.performLayout] method.
@immutable
class SliverStaggeredGridGeometry extends SliverGridGeometry {
  /// Creates an object that describes the placement of a child in a [RenderSliverStaggeredGrid].
  const SliverStaggeredGridGeometry({
    @required scrollOffset,
    @required crossAxisOffset,
    @required mainAxisExtent,
    @required crossAxisExtent,
    @required this.crossAxisCellCount,
    @required this.blockIndex,
  }) : super(
            scrollOffset: scrollOffset,
            crossAxisOffset: crossAxisOffset,
            mainAxisExtent: mainAxisExtent,
            crossAxisExtent: crossAxisExtent);

  final int crossAxisCellCount;

  final int blockIndex;

  /// Returns a tight [BoxConstraints] that forces the child to have the
  /// required size.
  @override
  BoxConstraints getBoxConstraints(SliverConstraints constraints) {
    return constraints.asBoxConstraints(
      minExtent: mainAxisExtent ?? 0.0,
      maxExtent: mainAxisExtent ?? double.infinity,
      crossAxisExtent: crossAxisExtent,
    );
  }

  @override
  String toString() {
    return 'SliverStaggeredGridGeometry('
        'scrollOffset: $scrollOffset, '
        'crossAxisOffset: $crossAxisOffset, '
        'mainAxisExtent: $mainAxisExtent, '
        'crossAxisExtent: $crossAxisExtent, '
        'crossAxisCellCount: $crossAxisCellCount, '
        'startIndex: $blockIndex'
        ')';
  }
}

/// A [SliverStaggeredGridLayout] that uses variable sized but equally spaced tiles.
///
/// Rather that providing a grid with a [SliverStaggeredGridLayout] directly, you instead
/// provide the grid a [SliverStaggeredGridDelegate], which can compute a
/// [SliverStaggeredGridLayout] given the current [SliverConstraints].
///
/// This layout is used by [SliverStaggeredGridDelegateWithFixedCrossAxisCount] and
/// [SliverStaggeredGridDelegateWithMaxCrossAxisExtent].
///
/// See also:
///
///  * [SliverStaggeredGridDelegateWithFixedCrossAxisCount], which uses this layout.
///  * [SliverStaggeredGridDelegateWithMaxCrossAxisExtent], which uses this layout.
///  * [SliverGridGeometry], which represents the size and position of a single
///    tile in a grid.
///  * [SliverGridDelegate.getLayout], which returns this object to describe the
///    delegate's layout.
///  * [RenderSliverStaggeredGrid], which uses this class during its
///    [RenderSliverStaggeredGrid.performLayout] method.
@immutable
class SliverStaggeredGridLayout {
  /// Creates a layout that uses variable sized but equally spaced tiles.
  ///
  /// All of the arguments must not be null and must not be negative. The
  /// [crossAxisCount] argument must be greater than zero.
  SliverStaggeredGridLayout({
    @required this.crossAxisCount,
    @required this.staggeredTileBuilder,
    @required this.cellExtent,
    @required this.mainAxisSpacing,
    @required this.crossAxisSpacing,
    @required this.reverseCrossAxis,
    @required this.staggeredTileCount,
  })  : assert(crossAxisCount != null && crossAxisCount > 0),
        assert(staggeredTileBuilder != null),
        assert(cellExtent != null && cellExtent >= 0),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0),
        assert(reverseCrossAxis != null),
        _cellStride = cellExtent + crossAxisSpacing,
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

  /// The total number of tiles this delegate can provide.
  ///
  /// If null, the number of tiles is determined by the least index for which
  /// [builder] returns null.
  final int staggeredTileCount;

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

  final List<double> _mainAxisOffsets;

  final double _cellStride;

  SliverStaggeredGridGeometry createSliverStaggeredGridGeometryForIndex(
      int index) {
    // Gets the normalized tile.
    StaggeredTile tile;
    if (staggeredTileCount == null || index < staggeredTileCount) {
      // There is maybe a tile for this index.
      tile = _normalizeStaggeredTile(staggeredTileBuilder(index));
    }
    if (tile == null) {
      return null;
    }

    var block =
        _findFirstAvailableBlockWithCrossAxisCount(tile.crossAxisCellCount);

    var scrollOffset = block.minOffset;
    var blockIndex = block.index;
    if (reverseCrossAxis) {
      blockIndex = crossAxisCount - tile.crossAxisCellCount - blockIndex;
    }
    var crossAxisOffset = blockIndex * _cellStride;
    var geometry = new SliverStaggeredGridGeometry(
      scrollOffset: scrollOffset,
      crossAxisOffset: crossAxisOffset,
      mainAxisExtent: tile.mainAxisExtent,
      crossAxisExtent: _cellStride * tile.crossAxisCellCount - crossAxisSpacing,
      crossAxisCellCount: tile.crossAxisCellCount,
      blockIndex: blockIndex,
    );
    return geometry;
  }

  void updateAfterCreateSliverStaggeredGridGeometryForIndex(
      SliverStaggeredGridGeometry geometry, double mainAxisExtent) {
    var stride = mainAxisExtent + mainAxisSpacing;
    for (var i = 0; i < geometry.crossAxisCellCount; i++) {
      _mainAxisOffsets[i + geometry.blockIndex] =
          geometry.scrollOffset + stride;
    }
  }

  SliverStaggeredGridGeometry getSliverStaggeredGridGeometryForIndex(
      int index) {
    SliverStaggeredGridGeometry geometry =
        _sliverStaggeredGridGeometries[index];

    if (geometry == null) {
      // Populates the sliver staggered grid geometries from the last computed to this index.
      for (var i = _sliverStaggeredGridGeometries.length; i < index; ++i) {
        var _ = getSliverStaggeredGridGeometryForIndex(i);
        if (_ == null) {
          return null;
        }
      }

      geometry = createSliverStaggeredGridGeometryForIndex(index);
      _sliverStaggeredGridGeometries[index] = geometry;

      // Updates the mainAxisOffsets.
      // TODO: find a way to get the real tile.mainAxisExtent.
    }

    return geometry;
  }

  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    int index = 0;
    List<double> offsets = new List.generate(crossAxisCount, (i) => 0.0);

    // We iterate through staggered tile geometries until we find one
    // that is not visible for the given scrollOffset or we reached the end
    // of the tiles.
    _StaggeredTileGeometry tileGeometry;
    do {
      tileGeometry = _getStaggeredTileGeometry(index);
      if (tileGeometry != null) {
        for (var i = 0; i < tileGeometry.tile.crossAxisCellCount; i++) {
          offsets[i + tileGeometry.startIndex] =
              tileGeometry.geometry.trailingScrollOffset;
        }
        index++;
      }
    } while (tileGeometry != null && offsets.any((i) => i <= scrollOffset));

    return index - 1;
  }

  int getMinChildIndexForScrollOffset(double scrollOffset) {
    int index = 0;
    SliverStaggeredGridGeometry geometry;

    /// We iterate through staggered tile geometries until we find one that
    /// is visible for the given scrollOffset or we reached the end of the
    /// tiles.
    do {
      geometry = _getStaggeredTileGeometry(index)?.geometry;
      if (geometry != null) {
        index++;
      }
    } while (geometry != null &&
        geometry.trailingScrollOffset + mainAxisSpacing < scrollOffset);

    return index - 1;
  }

  /// Finds the first available block with at least the specified [crossAxisCount].
  _Block _findFirstAvailableBlockWithCrossAxisCount(int crossAxisCount) {
    return _findFirstAvailableBlockWithCrossAxisCountAndOffsets(
        crossAxisCount, new List.from(_mainAxisOffsets));
  }

  /// Computes the main axis extent of any staggered tile.
  double _getStaggeredTileMainAxisExtent(StaggeredTile tile) {
    return tile.mainAxisExtent ??
        (tile.mainAxisCellCount * cellExtent) +
            (tile.mainAxisCellCount - 1) * mainAxisSpacing;
  }

  /// Creates a staggered tile with the computed extent from the given tile.
  StaggeredTile _normalizeStaggeredTile(StaggeredTile staggeredTile) {
    if (staggeredTile == null) {
      return null;
    } else {
      int crossAxisCellCount =
          staggeredTile.crossAxisCellCount.clamp(0, crossAxisCount);
      if (staggeredTile.fit) {
        return new StaggeredTile.fitContent(crossAxisCellCount);
      } else {
        return new StaggeredTile.extent(
            crossAxisCellCount, _getStaggeredTileMainAxisExtent(staggeredTile));
      }
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
    double minBlockOffset = double.infinity;
    double maxBlockOffset = double.infinity;
    int crossAxisCount = 1;
    bool contiguous = false;

    // We have to use the _nearEqual function because of floating-point arithmetic.
    // Ex: 0.1 + 0.2 = 0.30000000000000004 and not 0.3.

    for (var i = index; i < offsets.length; ++i) {
      double offset = offsets[i];
      if (offset < minBlockOffset && !_nearEqual(offset, minBlockOffset)) {
        index = i;
        maxBlockOffset = minBlockOffset;
        minBlockOffset = offset;
        crossAxisCount = 1;
        contiguous = true;
      } else if (_nearEqual(offset, minBlockOffset) && contiguous) {
        crossAxisCount++;
      } else if (offset < maxBlockOffset &&
          offset > minBlockOffset &&
          !_nearEqual(offset, minBlockOffset)) {
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

const double _epsilon = 0.0001;
bool _nearEqual(double d1, double d2) {
  return (d1 - d2).abs() < _epsilon;
}

/// Creates staggered grid layouts.
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
abstract class SliverStaggeredGridDelegate {
  /// Creates a delegate that makes staggered grid layouts
  ///
  /// All of the arguments must not be null. The [mainAxisSpacing] and
  /// [crossAxisSpacing] arguments must not be negative.
  const SliverStaggeredGridDelegate({
    @required this.staggeredTileBuilder,
    this.mainAxisSpacing: 0.0,
    this.crossAxisSpacing: 0.0,
    this.staggeredTileCount,
  })  : assert(staggeredTileBuilder != null),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0);

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  /// Called to get the tile at the specified index for the
  /// [SliverGridStaggeredTileLayout].
  final IndexedStaggeredTileBuilder staggeredTileBuilder;

  /// The total number of tiles this delegate can provide.
  ///
  /// If null, the number of tiles is determined by the least index for which
  /// [builder] returns null.
  final int staggeredTileCount;

  bool _debugAssertIsValid() {
    assert(staggeredTileBuilder != null);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    return true;
  }

  /// Returns information about the size and position of the tiles in the grid.
  SliverStaggeredGridLayout getLayout(SliverConstraints constraints);

  /// Override this method to return true when the children need to be
  /// laid out.
  ///
  /// This should compare the fields of the current delegate and the given
  /// `oldDelegate` and return true if the fields are such that the layout would
  /// be different.
  bool shouldRelayout(SliverStaggeredGridDelegate oldDelegate) {
    return oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.staggeredTileCount != staggeredTileCount ||
        oldDelegate.staggeredTileBuilder != staggeredTileBuilder;
  }
}

/// Creates staggered grid layouts with a fixed number of cells in the cross
/// axis.
///
/// For example, if the grid is vertical, this delegate will create a layout
/// with a fixed number of columns. If the grid is horizontal, this delegate
/// will create a layout with a fixed number of rows.
///
/// This delegate creates grids with variable sized but equally spaced tiles.
///
/// See also:
///
///  * [SliverStaggeredGridDelegate], which creates staggered grid layouts.
///  * [GridView], which can use this delegate to control the layout of its
///    tiles.
///  * [SliverGrid], which can use this delegate to control the layout of its
///    tiles.
///  * [RenderSliverGrid], which can use this delegate to control the layout of
///    its tiles.
class SliverStaggeredGridDelegateWithFixedCrossAxisCount
    extends SliverStaggeredGridDelegate {
  /// Creates a delegate that makes staggered grid layouts with a fixed number
  /// of tiles in the cross axis.
  ///
  /// All of the arguments must not be null. The [mainAxisSpacing] and
  /// [crossAxisSpacing] arguments must not be negative. The [crossAxisCount]
  /// argument must be greater than zero.
  const SliverStaggeredGridDelegateWithFixedCrossAxisCount({
    @required this.crossAxisCount,
    @required IndexedStaggeredTileBuilder staggeredTileBuilder,
    double mainAxisSpacing: 0.0,
    double crossAxisSpacing: 0.0,
    int staggeredTileCount,
  })  : assert(crossAxisCount != null && crossAxisCount > 0),
        super(
          staggeredTileBuilder: staggeredTileBuilder,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileCount: staggeredTileCount,
        );

  /// The number of children in the cross axis.
  final int crossAxisCount;

  @override
  bool _debugAssertIsValid() {
    assert(crossAxisCount > 0);
    return super._debugAssertIsValid();
  }

  @override
  SliverStaggeredGridLayout getLayout(SliverConstraints constraints) {
    assert(_debugAssertIsValid());
    final double usableCrossAxisExtent =
        constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
    final double cellExtent = usableCrossAxisExtent / crossAxisCount;
    return new SliverStaggeredGridLayout(
      crossAxisCount: crossAxisCount,
      staggeredTileBuilder: staggeredTileBuilder,
      staggeredTileCount: staggeredTileCount,
      cellExtent: cellExtent,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(
      covariant SliverStaggeredGridDelegateWithFixedCrossAxisCount
          oldDelegate) {
    return oldDelegate.crossAxisCount != crossAxisCount ||
        super.shouldRelayout(oldDelegate);
  }
}

/// Creates staggered grid layouts with tiles that each have a maximum
/// cross-axis extent.
///
/// This delegate will select a cross-axis extent for the tiles that is as
/// large as possible subject to the following conditions:
///
///  - The extent evenly divides the cross-axis extent of the grid.
///  - The extent is at most [maxCrossAxisExtent].
///
/// For example, if the grid is vertical, the grid is 500.0 pixels wide, and
/// [maxCrossAxisExtent] is 150.0, this delegate will create a grid with 4
/// columns that are 125.0 pixels wide.
///
/// This delegate creates grids with variable sized but equally spaced tiles.
///
/// See also:
///
///  * [SliverStaggeredGridDelegate], which creates staggered grid layouts.
///  * [GridView], which can use this delegate to control the layout of its
///    tiles.
///  * [SliverGrid], which can use this delegate to control the layout of its
///    tiles.
///  * [RenderSliverGrid], which can use this delegate to control the layout of
///    its tiles.
class SliverStaggeredGridDelegateWithMaxCrossAxisExtent
    extends SliverStaggeredGridDelegate {
  /// Creates a delegate that makes staggered grid layouts with tiles that
  /// have a maximum cross-axis extent.
  ///
  /// All of the arguments must not be null. The [maxCrossAxisExtent],
  /// [mainAxisSpacing] and [crossAxisSpacing] arguments must not be negative.
  const SliverStaggeredGridDelegateWithMaxCrossAxisExtent({
    @required this.maxCrossAxisExtent,
    @required IndexedStaggeredTileBuilder staggeredTileBuilder,
    double mainAxisSpacing: 0.0,
    double crossAxisSpacing: 0.0,
    int staggeredTileCount,
  })  : assert(maxCrossAxisExtent != null && maxCrossAxisExtent > 0),
        super(
          staggeredTileBuilder: staggeredTileBuilder,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileCount: staggeredTileCount,
        );

  /// The maximum extent of tiles in the cross axis.
  ///
  /// This delegate will select a cross-axis extent for the tiles that is as
  /// large as possible subject to the following conditions:
  ///
  ///  - The extent evenly divides the cross-axis extent of the grid.
  ///  - The extent is at most [maxCrossAxisExtent].
  ///
  /// For example, if the grid is vertical, the grid is 500.0 pixels wide, and
  /// [maxCrossAxisExtent] is 150.0, this delegate will create a grid with 4
  /// columns that are 125.0 pixels wide.
  final double maxCrossAxisExtent;

  @override
  bool _debugAssertIsValid() {
    assert(maxCrossAxisExtent >= 0);
    return super._debugAssertIsValid();
  }

  @override
  SliverStaggeredGridLayout getLayout(SliverConstraints constraints) {
    assert(_debugAssertIsValid());
    final int crossAxisCount =
        ((constraints.crossAxisExtent + crossAxisSpacing) /
                (maxCrossAxisExtent + crossAxisSpacing))
            .ceil();

    final double usableCrossAxisExtent =
        constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);

    final double cellExtent = usableCrossAxisExtent / crossAxisCount;
    return new SliverStaggeredGridLayout(
      crossAxisCount: crossAxisCount,
      staggeredTileBuilder: staggeredTileBuilder,
      staggeredTileCount: staggeredTileCount,
      cellExtent: cellExtent,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(
      covariant SliverStaggeredGridDelegateWithMaxCrossAxisExtent oldDelegate) {
    return oldDelegate.maxCrossAxisExtent != maxCrossAxisExtent ||
        super.shouldRelayout(oldDelegate);
  }
}

// === Regarder RenderSliverList !!! ===

/// A sliver that places multiple box children in a two dimensional arrangement.
///
/// [RenderSliverGrid] places its children in arbitrary positions determined by
/// [gridDelegate]. Each child is forced to have the size specified by the
/// [gridDelegate].
///
/// See also:
///
///  * [RenderSliverList], which places its children in a linear
///    array.
///  * [RenderSliverFixedExtentList], which places its children in a linear
///    array with a fixed extent in the main axis.
class RenderSliverStaggeredGrid extends RenderSliverMultiBoxAdaptor {
  /// Creates a sliver that contains multiple box children that whose size and
  /// position are determined by a delegate.
  ///
  /// The [childManager] and [gridDelegate] arguments must not be null.
  RenderSliverStaggeredGrid({
    @required RenderSliverBoxChildManager childManager,
    @required SliverStaggeredGridDelegate gridDelegate,
  })  : assert(gridDelegate != null),
        _gridDelegate = gridDelegate,
        _sliverStaggeredGridGeometries = new Map(),
        super(childManager: childManager);

  /// A map containing the SliverStaggeredGridGeometries already computed.
  final Map<int, SliverStaggeredGridGeometry> _sliverStaggeredGridGeometries;

  /// The delegate that controls the size and position of the children.
  SliverStaggeredGridDelegate get gridDelegate => _gridDelegate;
  SliverStaggeredGridDelegate _gridDelegate;
  set gridDelegate(SliverStaggeredGridDelegate value) {
    assert(value != null);
    if (_gridDelegate == value) return;
    if (value.runtimeType != _gridDelegate.runtimeType ||
        value.shouldRelayout(_gridDelegate)) markNeedsLayout();
    _gridDelegate = value;
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverGridParentData)
      child.parentData = new SliverGridParentData();
  }

  @override
  double childCrossAxisPosition(RenderBox child) {
    final SliverGridParentData childParentData = child.parentData;
    return childParentData.crossAxisOffset;
  }

  @override
  void performLayout() {
    childManager.didStartLayout();
    childManager.setDidUnderflow(false);

    final double scrollOffset =
        constraints.scrollOffset + constraints.cacheOrigin;
    assert(scrollOffset >= 0.0);
    final double remainingExtent = constraints.remainingCacheExtent;
    assert(remainingExtent >= 0.0);
    final double targetEndScrollOffset = scrollOffset + remainingExtent;
    //final BoxConstraints childConstraints = constraints.asBoxConstraints();
    int leadingGarbage = 0;
    int trailingGarbage = 0;
    bool reachedEnd = false;

    // Due to the StaggeredTile.fit constructor the algorithm needs to layout some children
    // in order to get their size. This is not very good performance-wise.
    // There is maybe a better solution, but right now the algorithm is straigth-forward:
    // 1. Create children until we ran out of children or we find one child which scrolloffset is greater than targetEndScrollOffset.

    final SliverStaggeredGridLayout layout =
        _gridDelegate.getLayout(constraints);

    // Create the first child (index 0).
    if (!addInitialChild()) {
      // There are no children.
      geometry = SliverGeometry.zero;
      childManager.didFinishLayout();
      return;
    }

    // We have our firstChild. Now we have to get the geometry of it.

    // These variables track the range of children that we have laid out. Within
    // this range, the children have consecutive indices. Outside this range,
    // it's possible for a child to get removed without notice.
    RenderBox leadingChildWithLayout, trailingChildWithLayout;

    // Find the last child that is at or before the scrollOffset.
    RenderBox earliestUsefulChild = firstChild;
    for (double earliestScrollOffset = childScrollOffset(earliestUsefulChild);
        earliestScrollOffset > scrollOffset;
        earliestScrollOffset = childScrollOffset(earliestUsefulChild)) {
      // We have to add children before the earliestUsefulChild.
      int firstChildIndex = indexOf(firstChild);
      BoxConstraints childConstraints = layout
          ?.getSliverStaggeredGridGeometryForIndex(firstChildIndex - 1)
          ?.getBoxConstraints(constraints);

      if (childConstraints == null) {
        earliestUsefulChild = null;
      } else {
        earliestUsefulChild =
            insertAndLayoutLeadingChild(childConstraints, parentUsesSize: true);
      }

      if (earliestUsefulChild == null) {
        final SliverMultiBoxAdaptorParentData childParentData =
            firstChild.parentData;
        childParentData.layoutOffset = 0.0;

        if (scrollOffset == 0.0) {
          earliestUsefulChild = firstChild;
          leadingChildWithLayout = earliestUsefulChild;
          trailingChildWithLayout ??= earliestUsefulChild;
          break;
        } else {
          // We ran out of children before reaching the scroll offset.
          // We must inform our parent that this sliver cannot fulfill
          // its contract and that we need a scroll offset correction.
          geometry = new SliverGeometry(
            scrollOffsetCorrection: -scrollOffset,
          );
          return;
        }
      }

      final double firstChildScrollOffset =
          earliestScrollOffset - paintExtentOf(firstChild);
      if (firstChildScrollOffset < 0.0) {
        // The first child doesn't fit within the viewport (underflow) and
        // there may be additional children above it. Find the real first child
        // and then correct the scroll position so that there's room for all and
        // so that the trailing edge of the original firstChild appears where it
        // was before the scroll offset correction.
        // TODO(hansmuller): do this work incrementally, instead of all at once,
        // i.e. find a way to avoid visiting ALL of the children whose offset
        // is < 0 before returning for the scroll correction.
        double correction = 0.0;
        while (earliestUsefulChild != null) {
          assert(firstChild == earliestUsefulChild);
          correction += paintExtentOf(firstChild);
          earliestUsefulChild = insertAndLayoutLeadingChild(childConstraints,
              parentUsesSize: true);
        }
        geometry = new SliverGeometry(
          scrollOffsetCorrection: correction - earliestScrollOffset,
        );
        final SliverMultiBoxAdaptorParentData childParentData =
            firstChild.parentData;
        childParentData.layoutOffset = 0.0;
        return;
      }

      final SliverMultiBoxAdaptorParentData childParentData =
          earliestUsefulChild.parentData;
      childParentData.layoutOffset = firstChildScrollOffset;
      assert(earliestUsefulChild == firstChild);
      leadingChildWithLayout = earliestUsefulChild;
      trailingChildWithLayout ??= earliestUsefulChild;
    }

    // At this point, earliestUsefulChild is the first child, and is a child
    // whose scrollOffset is at or before the scrollOffset, and
    // leadingChildWithLayout and trailingChildWithLayout are either null or
    // cover a range of render boxes that we have laid out with the first being
    // the same as earliestUsefulChild and the last being either at or after the
    // scroll offset.

    assert(earliestUsefulChild == firstChild);
    assert(childScrollOffset(earliestUsefulChild) <= scrollOffset);

    // Make sure we've laid out at least one child.
    if (leadingChildWithLayout == null) {
      earliestUsefulChild.layout(childConstraints, parentUsesSize: true);
      leadingChildWithLayout = earliestUsefulChild;
      trailingChildWithLayout = earliestUsefulChild;
    }

    // Here, earliestUsefulChild is still the first child, it's got a
    // scrollOffset that is at or before our actual scrollOffset, and it has
    // been laid out, and is in fact our leadingChildWithLayout. It's possible
    // that some children beyond that one have also been laid out.

    bool inLayoutRange = true;
    RenderBox child = earliestUsefulChild;
    int index = indexOf(child);
    double endScrollOffset = childScrollOffset(child) + paintExtentOf(child);
    bool advance() {
      // returns true if we advanced, false if we have no more children
      // This function is used in two different places below, to avoid code duplication.
      assert(child != null);
      if (child == trailingChildWithLayout) inLayoutRange = false;
      child = childAfter(child);
      if (child == null) inLayoutRange = false;
      index += 1;
      if (!inLayoutRange) {
        if (child == null || indexOf(child) != index) {
          // We are missing a child. Insert it (and lay it out) if possible.
          child = insertAndLayoutChild(
            childConstraints,
            after: trailingChildWithLayout,
            parentUsesSize: true,
          );
          if (child == null) {
            // We have run out of children.
            return false;
          }
        } else {
          // Lay out the child.
          child.layout(childConstraints, parentUsesSize: true);
        }
        trailingChildWithLayout = child;
      }
      assert(child != null);
      final SliverMultiBoxAdaptorParentData childParentData = child.parentData;
      childParentData.layoutOffset = endScrollOffset;
      assert(childParentData.index == index);
      endScrollOffset = childScrollOffset(child) + paintExtentOf(child);
      return true;
    }

    // Find the first child that ends after the scroll offset.
    while (endScrollOffset < scrollOffset) {
      leadingGarbage += 1;
      if (!advance()) {
        assert(leadingGarbage == childCount);
        assert(child == null);
        // we want to make sure we keep the last child around so we know the end scroll offset
        collectGarbage(leadingGarbage - 1, 0);
        assert(firstChild == lastChild);
        final double extent =
            childScrollOffset(lastChild) + paintExtentOf(lastChild);
        geometry = new SliverGeometry(
          scrollExtent: extent,
          paintExtent: 0.0,
          maxPaintExtent: extent,
        );
        return;
      }
    }

    // Now find the first child that ends after our end.
    while (endScrollOffset < targetEndScrollOffset) {
      if (!advance()) {
        reachedEnd = true;
        break;
      }
    }

    // Finally count up all the remaining children and label them as garbage.
    if (child != null) {
      child = childAfter(child);
      while (child != null) {
        trailingGarbage += 1;
        child = childAfter(child);
      }
    }

    // At this point everything should be good to go, we just have to clean up
    // the garbage and report the geometry.

    collectGarbage(leadingGarbage, trailingGarbage);

    assert(debugAssertChildListIsNonEmptyAndContiguous());
    double estimatedMaxScrollOffset;
    if (reachedEnd) {
      estimatedMaxScrollOffset = endScrollOffset;
    } else {
      estimatedMaxScrollOffset = childManager.estimateMaxScrollOffset(
        constraints,
        firstIndex: indexOf(firstChild),
        lastIndex: indexOf(lastChild),
        leadingScrollOffset: childScrollOffset(firstChild),
        trailingScrollOffset: endScrollOffset,
      );
      assert(estimatedMaxScrollOffset >=
          endScrollOffset - childScrollOffset(firstChild));
    }
    final double paintExtent = calculatePaintOffset(
      constraints,
      from: childScrollOffset(firstChild),
      to: endScrollOffset,
    );
    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: childScrollOffset(firstChild),
      to: endScrollOffset,
    );
    geometry = new SliverGeometry(
      scrollExtent: estimatedMaxScrollOffset,
      paintExtent: paintExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: estimatedMaxScrollOffset,
      // Conservative to avoid flickering away the clip during scroll.
      hasVisualOverflow: endScrollOffset > targetEndScrollOffset ||
          constraints.scrollOffset > 0.0,
    );

    // We may have started the layout while scrolled to the end, which would not
    // expose a new child.
    if (estimatedMaxScrollOffset == endScrollOffset)
      childManager.setDidUnderflow(true);
    childManager.didFinishLayout();
  }

  SliverStaggeredGridGeometry _getSliverStaggeredGridGeometry(
      SliverStaggeredGridLayout layout, int index) {
    SliverStaggeredGridGeometry geometry =
        _sliverStaggeredGridGeometries[index];

    if (geometry == null) {
      // Populates the geometries from the last computed index to this index.
      for (var i = _sliverStaggeredGridGeometries.length; i < index; ++i) {
        var x = _getSliverStaggeredGridGeometry(layout, i);
        if (x == null) return null;
      }

      geometry = layout.createSliverStaggeredGridGeometryForIndex(index);

      // Layout child if needed.
      if(geometry.mainAxisExtent == null){
        // The main axis extent should depend of the child size.
        
      }

      double mainAxisExtent = 0.0;

      layout.updateAfterCreateSliverStaggeredGridGeometryForIndex(
          geometry, mainAxisExtent);
    }

    return geometry;
  }
}
