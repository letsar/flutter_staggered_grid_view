import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// The size of a tile that can be used by a [StaggeredGridView].
class StaggeredGridViewTileSize{
  /// Creates a tile with a span and an extent.
  ///
  /// The arguments must be positive.
  const StaggeredGridViewTileSize();

  final int crossAxisCount;

  final double mainAxisExtent;
}

/// Signature for a function that creates a [TileSize] for a given index.
typedef StaggeredGridViewTileSize IndexedTileSizeBuilder(int index);

class SliverStaggeredGridDelegateWithFixedCrossAxisCount extends SliverGridDelegate {
  const SliverStaggeredGridDelegateWithFixedCrossAxisCount({
    @required this.crossAxisCount,
    this.mainAxisSpacing: 0.0,
    this.crossAxisSpacing: 0.0,
    this.childAspectRatio: 1.0,
  }) : assert(crossAxisCount != null && crossAxisCount > 0),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0),
        assert(childAspectRatio != null && childAspectRatio > 0);

  /// The number of children in the cross axis.
  final int crossAxisCount;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  /// The ratio of the cross-axis to the main-axis extent of each child.
  final double childAspectRatio;

  bool _debugAssertIsValid() {
    assert(crossAxisCount > 0);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    assert(childAspectRatio > 0.0);
    return true;
  }

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    // TODO: implement getLayout
  }

  @override
  bool shouldRelayout(SliverGridDelegate oldDelegate) {
    // TODO: implement shouldRelayout
  }
}

/// The size and position of all the tiles in a [RenderSliverStaggeredGrid].
///
/// Rather that providing a grid with a [SliverGridLayout] directly, you instead
/// provide the grid a [SliverGridDelegate], which can compute a
/// [SliverGridLayout] given the current [SliverConstraints].
///
@immutable
class SliverStaggeredGridLayout extends SliverGridLayout{
  @override
  double computeMaxScrollOffset(int childCount) {
    // TODO: implement computeMaxScrollOffset
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    // TODO: implement getGeometryForChildIndex
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    // TODO: implement getMaxChildIndexForScrollOffset
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    // TODO: implement getMinChildIndexForScrollOffset
  }
}

/// A sliver that places multiple box children in a two dimensional arrangement.
///
/// TODO: better description.
/// The difference with [RenderSliverGrid] is that this one does not need its
/// children to be linearly visible.
class RenderSliverStaggeredGrid extends RenderSliverMultiBoxAdaptor {
  /// Creates a sliver that contains multiple box children that whose size and
  /// position are determined by a delegate.
  ///
  /// The [childManager] and [gridDelegate] arguments must not be null.
  RenderSliverStaggeredGrid({
    @required RenderSliverBoxChildManager childManager,
    @required SliverStaggeredGridDelegate gridDelegate,
  }) : assert(gridDelegate != null),
        _gridDelegate = gridDelegate,
        super(childManager: childManager);

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverGridParentData)
      child.parentData = new SliverGridParentData();
  }

  /// The delegate that controls the size and position of the children.
  SliverStaggeredGridDelegate get gridDelegate => _gridDelegate;
  SliverStaggeredGridDelegate _gridDelegate;
  set gridDelegate(SliverStaggeredGridDelegate value) {
    assert(value != null);
    if (_gridDelegate == value)
      return;
    if (value.runtimeType != _gridDelegate.runtimeType ||
        value.shouldRelayout(_gridDelegate))
      markNeedsLayout();
    _gridDelegate = value;
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

    final double scrollOffset = constraints.scrollOffset;
    assert(scrollOffset >= 0.0);
    final double remainingPaintExtent = constraints.remainingPaintExtent;
    assert(remainingPaintExtent >= 0.0);
    final double targetEndScrollOffset = scrollOffset + remainingPaintExtent;

    final SliverStaggeredGridLayout layout = _gridDelegate.getLayout(constraints);


  }
}
