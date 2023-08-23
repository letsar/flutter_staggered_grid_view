import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';


/// A scrollable, 2D array of widgets with variable sizes.
///
/// The main axis direction of a grid is the direction in which it scrolls (the
/// [scrollDirection]).
///
/// The most commonly used grid layouts are [StaggeredGridView.count], which
/// creates a layout with a fixed number of tiles in the cross axis, and
/// [StaggeredGridView.extent], which creates a layout with tiles that have a maximum
/// cross-axis extent. A custom [SliverStaggeredGridDelegate] can produce an
/// arbitrary 2D arrangement of children.
///
/// To create a grid with a large (or infinite) number of children, use the
/// [StaggeredGridView.builder] constructor with either a
/// [SliverStaggeredGridDelegateWithFixedCrossAxisCount] or a
/// [SliverStaggeredGridDelegateWithMaxCrossAxisExtent] for the [gridDelegate].
/// You can also use the [StaggeredGridView.countBuilder] or
/// [StaggeredGridView.extentBuilder] constructors.
///
/// To use a custom [SliverVariableSizeChildDelegate], use [StaggeredGridView.custom].
///
/// To create a linear array of children, use a [ListView].
///
/// To control the initial scroll offset of the scroll view, provide a
/// [controller] with its [ScrollController.initialScrollOffset] property set.
///
/// ### Sample code
///
/// Here are two brief snippets showing a [StaggeredGridView] and its equivalent using
/// [CustomScrollView]:
///
/// ```dart
/// StaggeredGridView.count(
///   primary: false,
///   crossAxisCount: 4,
///   mainAxisSpacing: 4.0,
///   crossAxisSpacing: 4.0,
///   children: const <Widget>[
///     const Text('1'),
///     const Text('2'),
///     const Text('3'),
///     const Text('4'),
///     const Text('5'),
///     const Text('6'),
///     const Text('7'),
///     const Text('8'),
///   ],
///   staggeredTiles: const <StaggeredTile>[
///     const StaggeredTile.count(2, 2),
///     const StaggeredTile.count(2, 1),
///     const StaggeredTile.count(2, 2),
///     const StaggeredTile.count(2, 1),
///     const StaggeredTile.count(2, 2),
///     const StaggeredTile.count(2, 1),
///     const StaggeredTile.count(2, 2),
///     const StaggeredTile.count(2, 1),
///   ],
/// )
/// ```
///
/// ```dart
/// CustomScrollView(
///   primary: false,
///   slivers: <Widget>[
///     SliverStaggeredGrid.count(
///       crossAxisCount: 4,
///       mainAxisSpacing: 4.0,
///       crossAxisSpacing: 4.0,
///       children: const <Widget>[
///         const Text('1'),
///         const Text('2'),
///         const Text('3'),
///         const Text('4'),
///         const Text('5'),
///         const Text('6'),
///         const Text('7'),
///         const Text('8'),
///       ],
///       staggeredTiles: const <StaggeredTile>[
///         const StaggeredTile.count(2, 2),
///         const StaggeredTile.count(2, 1),
///         const StaggeredTile.count(2, 2),
///         const StaggeredTile.count(2, 1),
///         const StaggeredTile.count(2, 2),
///         const StaggeredTile.count(2, 1),
///         const StaggeredTile.count(2, 2),
///         const StaggeredTile.count(2, 1),
///       ],
///     )
///   ],
/// )
/// ```
///
/// See also:
///
///  * [SingleChildScrollView], which is a scrollable widget that has a single
///    child.
///  * [ListView], which is scrollable, linear list of widgets.
///  * [PageView], which is a scrolling list of child widgets that are each the
///    size of the viewport.
///  * [CustomScrollView], which is a scrollable widget that creates custom
///    scroll effects using slivers.
///  * [SliverStaggeredGridDelegateWithFixedCrossAxisCount], which creates a
///    layout with a fixed number of tiles in the cross axis.
///  * [SliverStaggeredGridDelegateWithMaxCrossAxisExtent], which creates a
///    layout with tiles that have a maximum cross-axis extent.
///  * [ScrollNotification] and [NotificationListener], which can be used to watch
///    the scroll position without using a [ScrollController].
class StaggeredGridView extends BoxScrollView {
  /// Creates a scrollable, 2D array of widgets with a custom
  /// [SliverStaggeredGridDelegate].
  ///
  /// The [gridDelegate] argument must not be null.
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverVariableSizeChildListDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverVariableSizeChildListDelegate.addRepaintBoundaries] property. Both must not be
  /// null.
  StaggeredGridView({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
    required this.gridDelegate,
    this.addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    List<Widget> children = const <Widget>[],
    String? restorationId,
  })  : childrenDelegate = SliverChildListDelegate(
    children,
    addAutomaticKeepAlives: addAutomaticKeepAlives,
    addRepaintBoundaries: addRepaintBoundaries,
  ),
        super(
        key: key,
        scrollDirection: scrollDirection,
        reverse: reverse,
        controller: controller,
        primary: primary,
        physics: physics,
        shrinkWrap: shrinkWrap,
        padding: padding,
        restorationId: restorationId,
      );

  /// Creates a scrollable, 2D array of widgets that are created on demand.
  ///
  /// This constructor is appropriate for grid views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// Providing a non-null [itemCount] improves the ability of the
  /// [SliverStaggeredGridDelegate] to estimate the maximum scroll extent.
  ///
  /// [itemBuilder] will be called only with indices greater than or equal to
  /// zero and less than [itemCount].
  ///
  /// The [gridDelegate] argument must not be null.
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverVariableSizeChildBuilderDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverVariableSizeChildBuilderDelegate.addRepaintBoundaries] property. Both must not
  /// be null.
  StaggeredGridView.builder({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
    required this.gridDelegate,
    required IndexedWidgetBuilder itemBuilder,
    int? itemCount,
    this.addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    String? restorationId,
  })  : childrenDelegate = SliverChildBuilderDelegate(
    itemBuilder,
    childCount: itemCount,
    addAutomaticKeepAlives: addAutomaticKeepAlives,
    addRepaintBoundaries: addRepaintBoundaries,
  ),
        super(
        key: key,
        scrollDirection: scrollDirection,
        reverse: reverse,
        controller: controller,
        primary: primary,
        physics: physics,
        shrinkWrap: shrinkWrap,
        padding: padding,
        restorationId: restorationId,
      );

  /// Creates a scrollable, 2D array of widgets with both a custom
  /// [SliverStaggeredGridDelegate] and a custom [SliverVariableSizeChildDelegate].
  ///
  /// To use an [IndexedWidgetBuilder] callback to build children, either use
  /// a [SliverVariableSizeChildBuilderDelegate] or use the
  /// [SliverStaggeredGridDelegate.builder] constructor.
  ///
  /// The [gridDelegate] and [childrenDelegate] arguments must not be null.
  const StaggeredGridView.custom({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
    String? restorationId,
    required this.gridDelegate,
    required this.childrenDelegate,
    this.addAutomaticKeepAlives = true,
  }) : super(
    key: key,
    scrollDirection: scrollDirection,
    reverse: reverse,
    controller: controller,
    primary: primary,
    physics: physics,
    shrinkWrap: shrinkWrap,
    padding: padding,
    restorationId: restorationId,
  );

  /// Creates a scrollable, 2D array of widgets of variable sizes with a fixed
  /// number of tiles in the cross axis.
  ///
  /// Uses a [SliverStaggeredGridDelegateWithFixedCrossAxisCount] as the
  /// [gridDelegate].
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverVariableSizeChildListDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverVariableSizeChildListDelegate.addRepaintBoundaries] property. Both must not be
  /// null.
  ///
  /// See also:
  ///
  ///  * [SliverGrid.count], the equivalent constructor for [SliverGrid].
  StaggeredGridView.count({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
    required int crossAxisCount,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    this.addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    List<Widget> children = const <Widget>[],
    List<StaggeredTile> staggeredTiles = const <StaggeredTile>[],
    String? restorationId,
  })  : gridDelegate = SliverStaggeredGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: crossAxisCount,
    mainAxisSpacing: mainAxisSpacing,
    crossAxisSpacing: crossAxisSpacing,
    staggeredTileBuilder: (i) => staggeredTiles[i],
    staggeredTileCount: staggeredTiles.length,
  ),
        childrenDelegate = SliverChildListDelegate(
          children,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
        ),
        super(
        key: key,
        scrollDirection: scrollDirection,
        reverse: reverse,
        controller: controller,
        primary: primary,
        physics: physics,
        shrinkWrap: shrinkWrap,
        padding: padding,
        restorationId: restorationId,
      );

  /// Creates a scrollable, 2D array of widgets of variable sizes with a fixed
  /// number of tiles in the cross axis that are created on demand.
  ///
  /// This constructor is appropriate for grid views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// Uses a [SliverStaggeredGridDelegateWithFixedCrossAxisCount] as the
  /// [gridDelegate].
  ///
  ///  Providing a non-null [itemCount] improves the ability of the
  /// [SliverStaggeredGridDelegate] to estimate the maximum scroll extent.
  ///
  /// [itemBuilder] and [staggeredTileBuilder] will be called only with
  /// indices greater than or equal to
  /// zero and less than [itemCount].
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverVariableSizeChildListDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverVariableSizeChildListDelegate.addRepaintBoundaries] property. Both must not be
  /// null.
  StaggeredGridView.countBuilder({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
    required int crossAxisCount,
    required IndexedWidgetBuilder itemBuilder,
    required IndexedStaggeredTileBuilder staggeredTileBuilder,
    int? itemCount,
    double? cacheExtent,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    this.addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    String? restorationId,
  })  : gridDelegate = SliverStaggeredGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: crossAxisCount,
    mainAxisSpacing: mainAxisSpacing,
    crossAxisSpacing: crossAxisSpacing,
    staggeredTileBuilder: staggeredTileBuilder,
    staggeredTileCount: itemCount,
  ),
        childrenDelegate = SliverChildBuilderDelegate(
          itemBuilder,
          childCount: itemCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
        ),
        super(
        key: key,
        scrollDirection: scrollDirection,
        reverse: reverse,
        controller: controller,
        primary: primary,
        physics: physics,
        shrinkWrap: shrinkWrap,
        padding: padding,
        restorationId: restorationId,
        cacheExtent: cacheExtent,
      );

  /// Creates a scrollable, 2D array of widgets of variable sizes with tiles
  /// that  each have a maximum cross-axis extent.
  ///
  /// Uses a [SliverGridDelegateWithMaxCrossAxisExtent] as the [gridDelegate].
  ///
  ///  Providing a non-null [itemCount] improves the ability of the
  /// [SliverStaggeredGridDelegate] to estimate the maximum scroll extent.
  ///
  /// [itemBuilder] and [staggeredTileBuilder] will be called only with
  /// indices greater than or equal to
  /// zero and less than [itemCount].
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverVariableSizeChildListDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverVariableSizeChildListDelegate.addRepaintBoundaries] property. Both must not be
  /// null.
  ///
  /// See also:
  ///
  ///  * [SliverGrid.extent], the equivalent constructor for [SliverGrid].
  StaggeredGridView.extent({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
    required double maxCrossAxisExtent,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    this.addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    List<Widget> children = const <Widget>[],
    List<StaggeredTile> staggeredTiles = const <StaggeredTile>[],
    String? restorationId,
  })  : gridDelegate = SliverStaggeredGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: maxCrossAxisExtent,
    mainAxisSpacing: mainAxisSpacing,
    crossAxisSpacing: crossAxisSpacing,
    staggeredTileBuilder: (i) => staggeredTiles[i],
    staggeredTileCount: staggeredTiles.length,
  ),
        childrenDelegate = SliverChildListDelegate(
          children,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
        ),
        super(
        key: key,
        scrollDirection: scrollDirection,
        reverse: reverse,
        controller: controller,
        primary: primary,
        physics: physics,
        shrinkWrap: shrinkWrap,
        padding: padding,
        restorationId: restorationId,
      );

  /// Creates a scrollable, 2D array of widgets of variable sizes with tiles
  /// that  each have a maximum cross-axis extent that are created on demand.
  ///
  /// This constructor is appropriate for grid views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// Uses a [SliverGridDelegateWithMaxCrossAxisExtent] as the [gridDelegate].
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverVariableSizeChildListDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverVariableSizeChildListDelegate.addRepaintBoundaries] property. Both must not be
  /// null.
  ///
  /// See also:
  ///
  ///  * [SliverGrid.extent], the equivalent constructor for [SliverGrid].
  StaggeredGridView.extentBuilder({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
    required double maxCrossAxisExtent,
    required IndexedWidgetBuilder itemBuilder,
    required IndexedStaggeredTileBuilder staggeredTileBuilder,
    int? itemCount,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    this.addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    String? restorationId,
  })  : gridDelegate = SliverStaggeredGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: maxCrossAxisExtent,
    mainAxisSpacing: mainAxisSpacing,
    crossAxisSpacing: crossAxisSpacing,
    staggeredTileBuilder: staggeredTileBuilder,
    staggeredTileCount: itemCount,
  ),
        childrenDelegate = SliverChildBuilderDelegate(
          itemBuilder,
          childCount: itemCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
        ),
        super(
        key: key,
        scrollDirection: scrollDirection,
        reverse: reverse,
        controller: controller,
        primary: primary,
        physics: physics,
        shrinkWrap: shrinkWrap,
        padding: padding,
        restorationId: restorationId,
      );

  /// A delegate that controls the layout of the children within the
  /// [StaggeredGridView].
  ///
  /// The [StaggeredGridView] and [StaggeredGridView.custom] constructors let you specify this
  /// delegate explicitly. The other constructors create a [gridDelegate]
  /// implicitly.
  final SliverStaggeredGridDelegate gridDelegate;

  /// A delegate that provides the children for the [StaggeredGridView].
  ///
  /// The [StaggeredGridView.custom] constructor lets you specify this delegate
  /// explicitly. The other constructors create a [childrenDelegate] that wraps
  /// the given child list.
  final SliverChildDelegate childrenDelegate;

  /// Whether to add keepAlives to children
  final bool addAutomaticKeepAlives;

  @override
  Widget buildChildLayout(BuildContext context) {
    return SliverStaggeredGrid(
      delegate: childrenDelegate,
      gridDelegate: gridDelegate,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
    );
  }
}

















//dependencies:

/// Signature for a function that creates [StaggeredTile] for a given index.
typedef IndexedStaggeredTileBuilder = StaggeredTile? Function(int index);

/// Specifies how a staggered grid is configured.
@immutable
class StaggeredGridConfiguration {
  ///  Creates an object that holds the configuration of a staggered grid.
  const StaggeredGridConfiguration({
    required this.crossAxisCount,
    required this.staggeredTileBuilder,
    required this.cellExtent,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.reverseCrossAxis,
    required this.staggeredTileCount,
    this.mainAxisOffsetsCacheSize = 3,
  })  : assert(crossAxisCount > 0),
        assert(cellExtent >= 0),
        assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        assert(mainAxisOffsetsCacheSize > 0),
        cellStride = cellExtent + crossAxisSpacing;

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
  final int? staggeredTileCount;

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

  final double cellStride;

  /// The number of pages necessary to cache a mainAxisOffsets value.
  final int mainAxisOffsetsCacheSize;

  List<double> generateMainAxisOffsets() =>
      List.generate(crossAxisCount, (i) => 0.0);

  /// Gets a normalized tile for the given index.
  StaggeredTile? getStaggeredTile(int index) {
    StaggeredTile? tile;
    if (staggeredTileCount == null || index < staggeredTileCount!) {
      // There is maybe a tile for this index.
      tile = _normalizeStaggeredTile(staggeredTileBuilder(index));
    }
    return tile;
  }

  /// Computes the main axis extent of any staggered tile.
  double _getStaggeredTileMainAxisExtent(StaggeredTile tile) {
    return tile.mainAxisExtent ??
        (tile.mainAxisCellCount! * cellExtent) +
            (tile.mainAxisCellCount! - 1) * mainAxisSpacing;
  }

  /// Creates a staggered tile with the computed extent from the given tile.
  StaggeredTile? _normalizeStaggeredTile(StaggeredTile? staggeredTile) {
    if (staggeredTile == null) {
      return null;
    } else {
      final crossAxisCellCount =
      staggeredTile.crossAxisCellCount.clamp(0, crossAxisCount).toInt();
      if (staggeredTile.fitContent) {
        return StaggeredTile.fit(crossAxisCellCount);
      } else {
        return StaggeredTile.extent(
            crossAxisCellCount, _getStaggeredTileMainAxisExtent(staggeredTile));
      }
    }
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

/// Describes the placement of a child in a [RenderSliverStaggeredGrid].
///
/// See also:
///
///  * [RenderSliverStaggeredGrid], which uses this class during its
///    [RenderSliverStaggeredGrid.performLayout] method.
@immutable
class SliverStaggeredGridGeometry {
  /// Creates an object that describes the placement of a child in a [RenderSliverStaggeredGrid].
  const SliverStaggeredGridGeometry({
    required this.scrollOffset,
    required this.crossAxisOffset,
    required this.mainAxisExtent,
    required this.crossAxisExtent,
    required this.crossAxisCellCount,
    required this.blockIndex,
  });

  /// The scroll offset of the leading edge of the child relative to the leading
  /// edge of the parent.
  final double scrollOffset;

  /// The offset of the child in the non-scrolling axis.
  ///
  /// If the scroll axis is vertical, this offset is from the left-most edge of
  /// the parent to the left-most edge of the child. If the scroll axis is
  /// horizontal, this offset is from the top-most edge of the parent to the
  /// top-most edge of the child.
  final double crossAxisOffset;

  /// The extent of the child in the scrolling axis.
  ///
  /// If the scroll axis is vertical, this extent is the child's height. If the
  /// scroll axis is horizontal, this extent is the child's width.
  final double? mainAxisExtent;

  /// The extent of the child in the non-scrolling axis.
  ///
  /// If the scroll axis is vertical, this extent is the child's width. If the
  /// scroll axis is horizontal, this extent is the child's height.
  final double crossAxisExtent;

  final int crossAxisCellCount;

  final int blockIndex;

  bool get hasTrailingScrollOffset => mainAxisExtent != null;

  /// The scroll offset of the trailing edge of the child relative to the
  /// leading edge of the parent.
  double get trailingScrollOffset => scrollOffset + (mainAxisExtent ?? 0);

  SliverStaggeredGridGeometry copyWith({
    double? scrollOffset,
    double? crossAxisOffset,
    double? mainAxisExtent,
    double? crossAxisExtent,
    int? crossAxisCellCount,
    int? blockIndex,
  }) {
    return SliverStaggeredGridGeometry(
      scrollOffset: scrollOffset ?? this.scrollOffset,
      crossAxisOffset: crossAxisOffset ?? this.crossAxisOffset,
      mainAxisExtent: mainAxisExtent ?? this.mainAxisExtent,
      crossAxisExtent: crossAxisExtent ?? this.crossAxisExtent,
      crossAxisCellCount: crossAxisCellCount ?? this.crossAxisCellCount,
      blockIndex: blockIndex ?? this.blockIndex,
    );
  }

  /// Returns a tight [BoxConstraints] that forces the child to have the
  /// required size.
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
        'startIndex: $blockIndex)';
  }
}

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
class RenderSliverStaggeredGrid extends RenderSliverVariableSizeBoxAdaptor {
  /// Creates a sliver that contains multiple box children that whose size and
  /// position are determined by a delegate.
  ///
  /// The [configuration] and [childManager] arguments must not be null.
  RenderSliverStaggeredGrid({
    required RenderSliverVariableSizeBoxChildManager childManager,
    required SliverStaggeredGridDelegate gridDelegate,
  })  : _gridDelegate = gridDelegate,
        _pageSizeToViewportOffsets =
        HashMap<double, SplayTreeMap<int, _ViewportOffsets?>>(),
        super(childManager: childManager);

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverVariableSizeBoxAdaptorParentData) {
      final data = SliverVariableSizeBoxAdaptorParentData();

      // By default we will keep it true.
      //data.keepAlive = true;
      child.parentData = data;
    }
  }

  /// The delegate that controls the configuration of the staggered grid.
  SliverStaggeredGridDelegate get gridDelegate => _gridDelegate;
  SliverStaggeredGridDelegate _gridDelegate;
  set gridDelegate(SliverStaggeredGridDelegate value) {
    if (_gridDelegate == value) {
      return;
    }
    if (value.runtimeType != _gridDelegate.runtimeType ||
        value.shouldRelayout(_gridDelegate)) {
      markNeedsLayout();
    }
    _gridDelegate = value;
  }

  final HashMap<double, SplayTreeMap<int, _ViewportOffsets?>>
  _pageSizeToViewportOffsets;

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

    bool reachedEnd = false;
    double trailingScrollOffset = 0;
    double leadingScrollOffset = double.infinity;
    bool visible = false;
    int firstIndex = 0;
    int lastIndex = 0;

    final configuration = _gridDelegate.getConfiguration(constraints);

    final pageSize = configuration.mainAxisOffsetsCacheSize *
        constraints.viewportMainAxisExtent;
    if (pageSize == 0.0) {
      geometry = SliverGeometry.zero;
      childManager.didFinishLayout();
      return;
    }
    final pageIndex = scrollOffset ~/ pageSize;
    assert(pageIndex >= 0);

    // If the viewport is resized, we keep the in memory the old offsets caches. (Useful if only the orientation changes multiple times).
    final viewportOffsets = _pageSizeToViewportOffsets.putIfAbsent(
        pageSize, () => SplayTreeMap<int, _ViewportOffsets?>());

    _ViewportOffsets? viewportOffset;
    if (viewportOffsets.isEmpty) {
      viewportOffset =
          _ViewportOffsets(configuration.generateMainAxisOffsets(), pageSize);
      viewportOffsets[0] = viewportOffset;
    } else {
      final smallestKey = viewportOffsets.lastKeyBefore(pageIndex + 1);
      viewportOffset = viewportOffsets[smallestKey!];
    }

    // A staggered grid always have to layout the child from the zero-index based one to the last visible.
    final mainAxisOffsets = viewportOffset!.mainAxisOffsets.toList();
    final visibleIndices = HashSet<int>();

    // Iterate through all children while they can be visible.
    for (var index = viewportOffset.firstChildIndex;
    mainAxisOffsets.any((o) => o <= targetEndScrollOffset);
    index++) {
      SliverStaggeredGridGeometry? geometry =
      getSliverStaggeredGeometry(index, configuration, mainAxisOffsets);
      if (geometry == null) {
        // There are either no children, or we are past the end of all our children.
        reachedEnd = true;
        break;
      }

      final bool hasTrailingScrollOffset = geometry.hasTrailingScrollOffset;
      RenderBox? child;
      if (!hasTrailingScrollOffset) {
        // Layout the child to compute its tailingScrollOffset.
        final constraints =
        BoxConstraints.tightFor(width: geometry.crossAxisExtent);
        child = addAndLayoutChild(index, constraints, parentUsesSize: true);
        geometry = geometry.copyWith(mainAxisExtent: paintExtentOf(child!));
      }

      if (!visible &&
          targetEndScrollOffset >= geometry.scrollOffset &&
          scrollOffset <= geometry.trailingScrollOffset) {
        visible = true;
        leadingScrollOffset = geometry.scrollOffset;
        firstIndex = index;
      }

      if (visible && hasTrailingScrollOffset) {
        child =
            addAndLayoutChild(index, geometry.getBoxConstraints(constraints));
      }

      if (child != null) {
        final childParentData =
        child.parentData! as SliverVariableSizeBoxAdaptorParentData;
        childParentData.layoutOffset = geometry.scrollOffset;
        childParentData.crossAxisOffset = geometry.crossAxisOffset;
        assert(childParentData.index == index);
      }

      if (visible && indices.contains(index)) {
        visibleIndices.add(index);
      }

      if (geometry.trailingScrollOffset >=
          viewportOffset!.trailingScrollOffset) {
        final nextPageIndex = viewportOffset.pageIndex + 1;
        final nextViewportOffset = _ViewportOffsets(mainAxisOffsets,
            (nextPageIndex + 1) * pageSize, nextPageIndex, index);
        viewportOffsets[nextPageIndex] = nextViewportOffset;
        viewportOffset = nextViewportOffset;
      }

      final double endOffset =
          geometry.trailingScrollOffset + configuration.mainAxisSpacing;
      for (var i = 0; i < geometry.crossAxisCellCount; i++) {
        mainAxisOffsets[i + geometry.blockIndex] = endOffset;
      }

      trailingScrollOffset = mainAxisOffsets.reduce(math.max);
      lastIndex = index;
    }

    collectGarbage(visibleIndices);

    if (!visible) {
      if (scrollOffset > viewportOffset!.trailingScrollOffset) {
        // We are outside the bounds, we have to correct the scroll.
        final viewportOffsetScrollOffset = pageSize * viewportOffset.pageIndex;
        final correction = viewportOffsetScrollOffset - scrollOffset;
        geometry = SliverGeometry(
          scrollOffsetCorrection: correction,
        );
      } else {
        geometry = SliverGeometry.zero;
        childManager.didFinishLayout();
      }
      return;
    }

    double estimatedMaxScrollOffset;
    if (reachedEnd) {
      estimatedMaxScrollOffset = trailingScrollOffset;
    } else {
      estimatedMaxScrollOffset = childManager.estimateMaxScrollOffset(
        constraints,
        firstIndex: firstIndex,
        lastIndex: lastIndex,
        leadingScrollOffset: leadingScrollOffset,
        trailingScrollOffset: trailingScrollOffset,
      );
      assert(estimatedMaxScrollOffset >=
          trailingScrollOffset - leadingScrollOffset);
    }

    final double paintExtent = calculatePaintOffset(
      constraints,
      from: leadingScrollOffset,
      to: trailingScrollOffset,
    );
    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: leadingScrollOffset,
      to: trailingScrollOffset,
    );

    geometry = SliverGeometry(
      scrollExtent: estimatedMaxScrollOffset,
      paintExtent: paintExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: estimatedMaxScrollOffset,
      // Conservative to avoid flickering away the clip during scroll.
      hasVisualOverflow: trailingScrollOffset > targetEndScrollOffset ||
          constraints.scrollOffset > 0.0,
    );

    // We may have started the layout while scrolled to the end, which would not
    // expose a child.
    if (estimatedMaxScrollOffset == trailingScrollOffset) {
      childManager.setDidUnderflow(true);
    }
    childManager.didFinishLayout();
  }

  static SliverStaggeredGridGeometry? getSliverStaggeredGeometry(int index,
      StaggeredGridConfiguration configuration, List<double> offsets) {
    final tile = configuration.getStaggeredTile(index);
    if (tile == null) {
      return null;
    }

    final block = _findFirstAvailableBlockWithCrossAxisCount(
        tile.crossAxisCellCount, offsets);

    final scrollOffset = block.minOffset;
    var blockIndex = block.index;
    if (configuration.reverseCrossAxis) {
      blockIndex =
          configuration.crossAxisCount - tile.crossAxisCellCount - blockIndex;
    }
    final crossAxisOffset = blockIndex * configuration.cellStride;
    final geometry = SliverStaggeredGridGeometry(
      scrollOffset: scrollOffset,
      crossAxisOffset: crossAxisOffset,
      mainAxisExtent: tile.mainAxisExtent,
      crossAxisExtent: configuration.cellStride * tile.crossAxisCellCount -
          configuration.crossAxisSpacing,
      crossAxisCellCount: tile.crossAxisCellCount,
      blockIndex: block.index,
    );
    return geometry;
  }

  /// Finds the first available block with at least the specified [crossAxisCount] in the [offsets] list.
  static _Block _findFirstAvailableBlockWithCrossAxisCount(
      int crossAxisCount, List<double> offsets) {
    return _findFirstAvailableBlockWithCrossAxisCountAndOffsets(
        crossAxisCount, List.from(offsets));
  }

  /// Finds the first available block with at least the specified [crossAxisCount].
  static _Block _findFirstAvailableBlockWithCrossAxisCountAndOffsets(
      int crossAxisCount, List<double> offsets) {
    final block = _findFirstAvailableBlock(offsets);
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
      final offset = offsets[i];
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

    return _Block(index, crossAxisCount, minBlockOffset, maxBlockOffset);
  }
}

class _ViewportOffsets {
  _ViewportOffsets(
      List<double> mainAxisOffsets,
      this.trailingScrollOffset, [
        this.pageIndex = 0,
        this.firstChildIndex = 0,
      ]) : mainAxisOffsets = mainAxisOffsets.toList();

  final int pageIndex;

  final int firstChildIndex;

  final double trailingScrollOffset;

  final List<double> mainAxisOffsets;

  @override
  String toString() =>
      '[$pageIndex-$trailingScrollOffset] ($firstChildIndex, $mainAxisOffsets)';
}

/// Creates staggered grid layouts.
///
/// This delegate creates grids with variable sized but equally spaced tiles.
///
/// See also:
///
///  * [StaggeredGridView], which can use this delegate to control the layout of its
///    tiles.
///  * [SliverStaggeredGrid], which can use this delegate to control the layout of its
///    tiles.
///  * [RenderSliverStaggeredGrid], which can use this delegate to control the layout of
///    its tiles.
abstract class SliverStaggeredGridDelegate {
  /// Creates a delegate that makes staggered grid layouts
  ///
  /// All of the arguments must not be null. The [mainAxisSpacing] and
  /// [crossAxisSpacing] arguments must not be negative.
  const SliverStaggeredGridDelegate({
    required this.staggeredTileBuilder,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.staggeredTileCount,
  })  : assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0);

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  /// Called to get the tile at the specified index for the
  /// [RenderSliverStaggeredGrid].
  final IndexedStaggeredTileBuilder staggeredTileBuilder;

  /// The total number of tiles this delegate can provide.
  ///
  /// If null, the number of tiles is determined by the least index for which
  /// [builder] returns null.
  final int? staggeredTileCount;

  bool _debugAssertIsValid() {
    assert(mainAxisSpacing >= 0);
    assert(crossAxisSpacing >= 0);
    return true;
  }

  /// Returns information about the staggered grid configuration.
  StaggeredGridConfiguration getConfiguration(SliverConstraints constraints);

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
///  * [StaggeredGridView], which can use this delegate to control the layout of its
///    tiles.
///  * [SliverStaggeredGrid], which can use this delegate to control the layout of its
///    tiles.
///  * [RenderSliverStaggeredGrid], which can use this delegate to control the layout of
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
    required this.crossAxisCount,
    required IndexedStaggeredTileBuilder staggeredTileBuilder,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    int? staggeredTileCount,
  })  : assert(crossAxisCount > 0),
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
  StaggeredGridConfiguration getConfiguration(SliverConstraints constraints) {
    assert(_debugAssertIsValid());
    final double usableCrossAxisExtent =
        constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
    final double cellExtent = usableCrossAxisExtent / crossAxisCount;
    return StaggeredGridConfiguration(
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
///  * [StaggeredGridView], which can use this delegate to control the layout of its
///    tiles.
///  * [SliverStaggeredGrid], which can use this delegate to control the layout of its
///    tiles.
///  * [RenderSliverStaggeredGrid], which can use this delegate to control the layout of
///    its tiles.
class SliverStaggeredGridDelegateWithMaxCrossAxisExtent
    extends SliverStaggeredGridDelegate {
  /// Creates a delegate that makes staggered grid layouts with tiles that
  /// have a maximum cross-axis extent.
  ///
  /// All of the arguments must not be null. The [maxCrossAxisExtent],
  /// [mainAxisSpacing] and [crossAxisSpacing] arguments must not be negative.
  const SliverStaggeredGridDelegateWithMaxCrossAxisExtent({
    required this.maxCrossAxisExtent,
    required IndexedStaggeredTileBuilder staggeredTileBuilder,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    int? staggeredTileCount,
  })  : assert(maxCrossAxisExtent > 0),
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
  StaggeredGridConfiguration getConfiguration(SliverConstraints constraints) {
    assert(_debugAssertIsValid());
    final int crossAxisCount =
    ((constraints.crossAxisExtent + crossAxisSpacing) /
        (maxCrossAxisExtent + crossAxisSpacing))
        .ceil();

    final double usableCrossAxisExtent =
        constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);

    final double cellExtent = usableCrossAxisExtent / crossAxisCount;
    return StaggeredGridConfiguration(
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
/// Holds the dimensions of a [StaggeredGridView]'s tile.
///
/// A [StaggeredTile] always overlaps an exact number of cells in the cross
/// axis of a [StaggeredGridView].
/// The main axis extent can either be a number of pixels or a number of
/// cells to overlap.
class StaggeredTile {
  /// Creates a [StaggeredTile] with the given [crossAxisCellCount] and
  /// [mainAxisCellCount].
  ///
  /// The main axis extent of this tile will be the length of
  /// [mainAxisCellCount] cells (inner spacings included).
  const StaggeredTile.count(this.crossAxisCellCount, this.mainAxisCellCount)
      : assert(crossAxisCellCount >= 0),
        assert(mainAxisCellCount != null && mainAxisCellCount >= 0),
        mainAxisExtent = null;

  /// Creates a [StaggeredTile] with the given [crossAxisCellCount] and
  /// [mainAxisExtent].
  ///
  /// This tile will have a fixed main axis extent.
  const StaggeredTile.extent(this.crossAxisCellCount, this.mainAxisExtent)
      : assert(crossAxisCellCount >= 0),
        assert(mainAxisExtent != null && mainAxisExtent >= 0),
        mainAxisCellCount = null;

  /// Creates a [StaggeredTile] with the given [crossAxisCellCount] that
  /// fit its main axis extent to its content.
  ///
  /// This tile will have a fixed main axis extent.
  const StaggeredTile.fit(this.crossAxisCellCount)
      : assert(crossAxisCellCount >= 0),
        mainAxisExtent = null,
        mainAxisCellCount = null;

  /// The number of cells occupied in the cross axis.
  final int crossAxisCellCount;

  /// The number of cells occupied in the main axis.
  final double? mainAxisCellCount;

  /// The number of pixels occupied in the main axis.
  final double? mainAxisExtent;

  bool get fitContent => mainAxisCellCount == null && mainAxisExtent == null;
}


/// A delegate used by [RenderSliverVariableSizeBoxAdaptor] to manage its children.
///
/// [RenderSliverVariableSizeBoxAdaptor] objects reify their children lazily to avoid
/// spending resources on children that are not visible in the viewport. This
/// delegate lets these objects create and remove children as well as estimate
/// the total scroll offset extent occupied by the full child list.
abstract class RenderSliverVariableSizeBoxChildManager {
  /// Called during layout when a new child is needed. The child should be
  /// inserted into the child list in the appropriate position. Its index and
  /// scroll offsets will automatically be set appropriately.
  ///
  /// The `index` argument gives the index of the child to show. It is possible
  /// for negative indices to be requested. For example: if the user scrolls
  /// from child 0 to child 10, and then those children get much smaller, and
  /// then the user scrolls back up again, this method will eventually be asked
  /// to produce a child for index -1.
  ///
  /// If no child corresponds to `index`, then do nothing.
  ///
  /// Which child is indicated by index zero depends on the [GrowthDirection]
  /// specified in the [RenderSliverVariableSizeBoxAdaptor.constraints]. For example
  /// if the children are the alphabet, then if
  /// [SliverConstraints.growthDirection] is [GrowthDirection.forward] then
  /// index zero is A, and index 25 is Z. On the other hand if
  /// [SliverConstraints.growthDirection] is [GrowthDirection.reverse]
  /// then index zero is Z, and index 25 is A.
  ///
  /// During a call to [createChild] it is valid to remove other children from
  /// the [RenderSliverVariableSizeBoxAdaptor] object if they were not created during
  /// this frame and have not yet been updated during this frame. It is not
  /// valid to add any other children to this render object.
  ///
  /// If this method does not create a child for a given `index` greater than or
  /// equal to zero, then [computeMaxScrollOffset] must be able to return a
  /// precise value.
  void createChild(int index);

  /// Remove the given child from the child list.
  ///
  /// Called by [RenderSliverVariableSizeBoxAdaptor.collectGarbage], which itself is
  /// called from [RenderSliverVariableSizeBoxAdaptor.performLayout].
  ///
  /// The index of the given child can be obtained using the
  /// [RenderSliverVariableSizeBoxAdaptor.indexOf] method, which reads it from the
  /// [SliverVariableSizeBoxAdaptorParentData.index] field of the child's
  /// [RenderObject.parentData].
  void removeChild(RenderBox child);

  /// Called to estimate the total scrollable extents of this object.
  ///
  /// Must return the total distance from the start of the child with the
  /// earliest possible index to the end of the child with the last possible
  /// index.
  double estimateMaxScrollOffset(
      SliverConstraints constraints, {
        int? firstIndex,
        int? lastIndex,
        double? leadingScrollOffset,
        double? trailingScrollOffset,
      });

  /// Called to obtain a precise measure of the total number of children.
  ///
  /// Must return the number that is one greater than the greatest `index` for
  /// which `createChild` will actually create a child.
  ///
  /// This is used when [createChild] cannot add a child for a positive `index`,
  /// to determine the precise dimensions of the sliver. It must return an
  /// accurate and precise non-null value. It will not be called if
  /// [createChild] is always able to create a child (e.g. for an infinite
  /// list).
  int get childCount;

  /// Called during [RenderSliverVariableSizeBoxAdaptor.adoptChild].
  ///
  /// Subclasses must ensure that the [SliverVariableSizeBoxAdaptorParentData.index]
  /// field of the child's [RenderObject.parentData] accurately reflects the
  /// child's index in the child list after this function returns.
  void didAdoptChild(RenderBox child);

  /// Called during layout to indicate whether this object provided insufficient
  /// children for the [RenderSliverVariableSizeBoxAdaptor] to fill the
  /// [SliverConstraints.remainingPaintExtent].
  ///
  /// Typically called unconditionally at the start of layout with false and
  /// then later called with true when the [RenderSliverVariableSizeBoxAdaptor]
  /// fails to create a child required to fill the
  /// [SliverConstraints.remainingPaintExtent].
  ///
  /// Useful for subclasses to determine whether newly added children could
  /// affect the visible contents of the [RenderSliverVariableSizeBoxAdaptor].
  // ignore: avoid_positional_boolean_parameters
  void setDidUnderflow(bool value);

  /// Called at the beginning of layout to indicate that layout is about to
  /// occur.
  void didStartLayout() {}

  /// Called at the end of layout to indicate that layout is now complete.
  void didFinishLayout() {}

  /// In debug mode, asserts that this manager is not expecting any
  /// modifications to the [RenderSliverVariableSizeBoxAdaptor]'s child list.
  ///
  /// This function always returns true.
  ///
  /// The manager is not required to track whether it is expecting modifications
  /// to the [RenderSliverVariableSizeBoxAdaptor]'s child list and can simply return
  /// true without making any assertions.
  bool debugAssertChildListLocked() => true;
}

/// Parent data structure used by [RenderSliverVariableSizeBoxAdaptor].
class SliverVariableSizeBoxAdaptorParentData
    extends SliverMultiBoxAdaptorParentData {
  /// The offset of the child in the non-scrolling axis.
  ///
  /// If the scroll axis is vertical, this offset is from the left-most edge of
  /// the parent to the left-most edge of the child. If the scroll axis is
  /// horizontal, this offset is from the top-most edge of the parent to the
  /// top-most edge of the child.
  late double crossAxisOffset;

  /// Whether the widget is currently in the
  /// [RenderSliverVariableSizeBoxAdaptor._keepAliveBucket].
  bool _keptAlive = false;

  @override
  String toString() => 'crossAxisOffset=$crossAxisOffset; ${super.toString()}';
}

/// A sliver with multiple variable size box children.
///
/// [RenderSliverVariableSizeBoxAdaptor] is a base class for slivers that have multiple
/// variable size box children. The children are managed by a [RenderSliverBoxChildManager],
/// which lets subclasses create children lazily during layout. Typically
/// subclasses will create only those children that are actually needed to fill
/// the [SliverConstraints.remainingPaintExtent].
///
/// The contract for adding and removing children from this render object is
/// more strict than for normal render objects:
///
/// * Children can be removed except during a layout pass if they have already
///   been laid out during that layout pass.
/// * Children cannot be added except during a call to [childManager], and
///   then only if there is no child corresponding to that index (or the child
///   child corresponding to that index was first removed).
///
/// See also:
///
///  * [RenderSliverToBoxAdapter], which has a single box child.
///  * [RenderSliverList], which places its children in a linear
///    array.
///  * [RenderSliverFixedExtentList], which places its children in a linear
///    array with a fixed extent in the main axis.
///  * [RenderSliverGrid], which places its children in arbitrary positions.
abstract class RenderSliverVariableSizeBoxAdaptor extends RenderSliver
    with
        TileContainerRenderObjectMixin<RenderBox,
            SliverVariableSizeBoxAdaptorParentData>,
        RenderSliverWithKeepAliveMixin,
        RenderSliverHelpers {
  /// Creates a sliver with multiple box children.
  ///
  /// The [childManager] argument must not be null.
  RenderSliverVariableSizeBoxAdaptor(
      {required RenderSliverVariableSizeBoxChildManager childManager})
      : _childManager = childManager;

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverVariableSizeBoxAdaptorParentData) {
      child.parentData = SliverVariableSizeBoxAdaptorParentData();
    }
  }

  /// The delegate that manages the children of this object.
  ///
  /// Rather than having a concrete list of children, a
  /// [RenderSliverVariableSizeBoxAdaptor] uses a [RenderSliverVariableSizeBoxChildManager] to
  /// create children during layout in order to fill the
  /// [SliverConstraints.remainingPaintExtent].
  @protected
  RenderSliverVariableSizeBoxChildManager get childManager => _childManager;
  final RenderSliverVariableSizeBoxChildManager _childManager;

  /// The nodes being kept alive despite not being visible.
  final Map<int, RenderBox> _keepAliveBucket = <int, RenderBox>{};

  @override
  void adoptChild(RenderObject child) {
    super.adoptChild(child);
    final childParentData =
    child.parentData! as SliverVariableSizeBoxAdaptorParentData;
    if (!childParentData._keptAlive) {
      childManager.didAdoptChild(child as RenderBox);
    }
  }

  bool _debugAssertChildListLocked() =>
      childManager.debugAssertChildListLocked();

  @override
  void remove(int index) {
    final RenderBox? child = this[index];

    // if child is null, it means this element was cached - drop the cached element
    if (child == null) {
      final RenderBox? cachedChild = _keepAliveBucket[index];
      if (cachedChild != null) {
        dropChild(cachedChild);
        _keepAliveBucket.remove(index);
      }
      return;
    }

    final childParentData =
    child.parentData! as SliverVariableSizeBoxAdaptorParentData;
    if (!childParentData._keptAlive) {
      super.remove(index);
      return;
    }
    assert(_keepAliveBucket[childParentData.index!] == child);
    _keepAliveBucket.remove(childParentData.index);
    dropChild(child);
  }

  @override
  void removeAll() {
    super.removeAll();
    _keepAliveBucket.values.forEach(dropChild);
    _keepAliveBucket.clear();
  }

  void _createOrObtainChild(int index) {
    invokeLayoutCallback<SliverConstraints>((SliverConstraints constraints) {
      assert(constraints == this.constraints);
      if (_keepAliveBucket.containsKey(index)) {
        final RenderBox child = _keepAliveBucket.remove(index)!;
        final childParentData =
        child.parentData! as SliverVariableSizeBoxAdaptorParentData;
        assert(childParentData._keptAlive);
        dropChild(child);
        child.parentData = childParentData;
        this[index] = child;
        childParentData._keptAlive = false;
      } else {
        _childManager.createChild(index);
      }
    });
  }

  void _destroyOrCacheChild(int index) {
    final RenderBox child = this[index]!;
    final childParentData =
    child.parentData! as SliverVariableSizeBoxAdaptorParentData;
    if (childParentData.keepAlive) {
      assert(!childParentData._keptAlive);
      remove(index);
      _keepAliveBucket[childParentData.index!] = child;
      child.parentData = childParentData;
      super.adoptChild(child);
      childParentData._keptAlive = true;
    } else {
      assert(child.parent == this);
      _childManager.removeChild(child);
      assert(child.parent == null);
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _keepAliveBucket.values.forEach((child) => child.attach(owner));
  }

  @override
  void detach() {
    super.detach();
    _keepAliveBucket.values.forEach((child) => child.detach());
  }

  @override
  void redepthChildren() {
    super.redepthChildren();
    _keepAliveBucket.values.forEach(redepthChild);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    super.visitChildren(visitor);
    _keepAliveBucket.values.forEach(visitor);
  }

  bool addChild(int index) {
    assert(_debugAssertChildListLocked());
    _createOrObtainChild(index);
    final child = this[index];
    if (child != null) {
      assert(indexOf(child) == index);
      return true;
    }
    childManager.setDidUnderflow(true);
    return false;
  }

  RenderBox? addAndLayoutChild(
      int index,
      BoxConstraints childConstraints, {
        bool parentUsesSize = false,
      }) {
    assert(_debugAssertChildListLocked());
    _createOrObtainChild(index);
    final child = this[index];
    if (child != null) {
      assert(indexOf(child) == index);
      child.layout(childConstraints, parentUsesSize: parentUsesSize);
      return child;
    }
    childManager.setDidUnderflow(true);
    return null;
  }

  /// Called after layout with the number of children that can be garbage
  /// collected at the head and tail of the child list.
  ///
  /// Children whose [SliverVariableSizeBoxAdaptorParentData.keepAlive] property is
  /// set to true will be removed to a cache instead of being dropped.
  ///
  /// This method also collects any children that were previously kept alive but
  /// are now no longer necessary. As such, it should be called every time
  /// [performLayout] is run, even if the arguments are both zero.
  @protected
  void collectGarbage(Set<int> visibleIndices) {
    assert(_debugAssertChildListLocked());
    assert(childCount >= visibleIndices.length);
    invokeLayoutCallback<SliverConstraints>((SliverConstraints constraints) {
      // We destroy only those which are not visible.
      indices.toSet().difference(visibleIndices).forEach(_destroyOrCacheChild);

      // Ask the child manager to remove the children that are no longer being
      // kept alive. (This should cause _keepAliveBucket to change, so we have
      // to prepare our list ahead of time.)
      _keepAliveBucket.values
          .where((RenderBox child) {
        final childParentData =
        child.parentData! as SliverVariableSizeBoxAdaptorParentData;
        return !childParentData.keepAlive;
      })
          .toList()
          .forEach(_childManager.removeChild);
      assert(_keepAliveBucket.values.where((RenderBox child) {
        final childParentData =
        child.parentData! as SliverVariableSizeBoxAdaptorParentData;
        return !childParentData.keepAlive;
      }).isEmpty);
    });
  }

  /// Returns the index of the given child, as given by the
  /// [SliverVariableSizeBoxAdaptorParentData.index] field of the child's [parentData].
  int indexOf(RenderBox child) {
    final childParentData =
    child.parentData! as SliverVariableSizeBoxAdaptorParentData;
    assert(childParentData.index != null);
    return childParentData.index!;
  }

  /// Returns the dimension of the given child in the main axis, as given by the
  /// child's [RenderBox.size] property. This is only valid after layout.
  @protected
  double paintExtentOf(RenderBox child) {
    assert(child.hasSize);
    switch (constraints.axis) {
      case Axis.horizontal:
        return child.size.width;
      case Axis.vertical:
        return child.size.height;
    }
  }

  @override
  bool hitTestChildren(HitTestResult result,
      {required double mainAxisPosition, required double crossAxisPosition}) {
    for (final child in children) {
      if (hitTestBoxChild(BoxHitTestResult.wrap(result), child,
          mainAxisPosition: mainAxisPosition,
          crossAxisPosition: crossAxisPosition)) {
        return true;
      }
    }
    return false;
  }

  @override
  double childMainAxisPosition(RenderBox child) {
    return childScrollOffset(child)! - constraints.scrollOffset;
  }

  @override
  double childCrossAxisPosition(RenderBox child) {
    final childParentData =
    child.parentData! as SliverVariableSizeBoxAdaptorParentData;
    return childParentData.crossAxisOffset;
  }

  @override
  double? childScrollOffset(RenderObject child) {
    assert(child.parent == this);
    final childParentData =
    child.parentData! as SliverVariableSizeBoxAdaptorParentData;
    assert(childParentData.layoutOffset != null);
    return childParentData.layoutOffset;
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    applyPaintTransformForBoxChild(child as RenderBox, transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (childCount == 0) {
      return;
    }
    // offset is to the top-left corner, regardless of our axis direction.
    // originOffset gives us the delta from the real origin to the origin in the axis direction.
    Offset? mainAxisUnit, crossAxisUnit, originOffset;
    bool? addExtent;
    switch (applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection)) {
      case AxisDirection.up:
        mainAxisUnit = const Offset(0, -1);
        crossAxisUnit = const Offset(1, 0);
        originOffset = offset + Offset(0, geometry!.paintExtent);
        addExtent = true;
        break;
      case AxisDirection.right:
        mainAxisUnit = const Offset(1, 0);
        crossAxisUnit = const Offset(0, 1);
        originOffset = offset;
        addExtent = false;
        break;
      case AxisDirection.down:
        mainAxisUnit = const Offset(0, 1);
        crossAxisUnit = const Offset(1, 0);
        originOffset = offset;
        addExtent = false;
        break;
      case AxisDirection.left:
        mainAxisUnit = const Offset(-1, 0);
        crossAxisUnit = const Offset(0, 1);
        originOffset = offset + Offset(geometry!.paintExtent, 0);
        addExtent = true;
        break;
    }

    for (final child in children) {
      final double mainAxisDelta = childMainAxisPosition(child);
      final double crossAxisDelta = childCrossAxisPosition(child);
      Offset childOffset = Offset(
        originOffset.dx +
            mainAxisUnit.dx * mainAxisDelta +
            crossAxisUnit.dx * crossAxisDelta,
        originOffset.dy +
            mainAxisUnit.dy * mainAxisDelta +
            crossAxisUnit.dy * crossAxisDelta,
      );
      if (addExtent) {
        childOffset += mainAxisUnit * paintExtentOf(child);
      }
      context.paintChild(child, childOffset);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsNode.message(childCount > 0
        ? 'currently live children: ${indices.join(',')}'
        : 'no children current live'));
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> childList = <DiagnosticsNode>[];
    if (childCount > 0) {
      for (final child in children) {
        final childParentData =
        child.parentData! as SliverVariableSizeBoxAdaptorParentData;
        childList.add(child.toDiagnosticsNode(
            name: 'child with index ${childParentData.index}'));
      }
    }
    if (_keepAliveBucket.isNotEmpty) {
      final List<int> indices = _keepAliveBucket.keys.toList()..sort();
      for (final index in indices) {
        childList.add(_keepAliveBucket[index]!.toDiagnosticsNode(
          name: 'child with index $index (kept alive offstage)',
          style: DiagnosticsTreeStyle.offstage,
        ));
      }
    }
    return childList;
  }
}


/// Generic mixin for render objects with a list of children.
///
/// Provides a child model for a render object subclass that stores children
/// in a HashMap.
mixin TileContainerRenderObjectMixin<ChildType extends RenderObject,
ParentDataType extends ParentData> on RenderObject {
  final SplayTreeMap<int, ChildType> _childRenderObjects =
  SplayTreeMap<int, ChildType>();

  /// The number of children.
  int get childCount => _childRenderObjects.length;

  Iterable<ChildType> get children => _childRenderObjects.values;

  Iterable<int> get indices => _childRenderObjects.keys;

  /// Checks whether the given render object has the correct [runtimeType] to be
  /// a child of this render object.
  ///
  /// Does nothing if assertions are disabled.
  ///
  /// Always returns true.
  bool debugValidateChild(RenderObject child) {
    assert(() {
      if (child is! ChildType) {
        throw FlutterError(
            'A $runtimeType expected a child of type $ChildType but received a '
                'child of type ${child.runtimeType}.\n'
                'RenderObjects expect specific types of children because they '
                'coordinate with their children during layout and paint. For '
                'example, a RenderSliver cannot be the child of a RenderBox because '
                'a RenderSliver does not understand the RenderBox layout protocol.\n'
                '\n'
                'The $runtimeType that expected a $ChildType child was created by:\n'
                '  $debugCreator\n'
                '\n'
                'The ${child.runtimeType} that did not match the expected child type '
                'was created by:\n'
                '  ${child.debugCreator}\n');
      }
      return true;
    }());
    return true;
  }

  ChildType? operator [](int index) => _childRenderObjects[index];

  void operator []=(int index, ChildType child) {
    if (index < 0) {
      throw ArgumentError(index);
    }
    _removeChild(_childRenderObjects[index]);
    adoptChild(child);
    _childRenderObjects[index] = child;
  }

  void forEachChild(void Function(ChildType child) f) {
    _childRenderObjects.values.forEach(f);
  }

  /// Remove the child at the specified index from the child list.
  void remove(int index) {
    final child = _childRenderObjects.remove(index);
    _removeChild(child);
  }

  void _removeChild(ChildType? child) {
    if (child != null) {
      // Remove the old child.
      dropChild(child);
    }
  }

  /// Remove all their children from this render object's child list.
  ///
  /// More efficient than removing them individually.
  void removeAll() {
    _childRenderObjects.values.forEach(dropChild);
    _childRenderObjects.clear();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _childRenderObjects.values.forEach((child) => child.attach(owner));
  }

  @override
  void detach() {
    super.detach();
    _childRenderObjects.values.forEach((child) => child.detach());
  }

  @override
  void redepthChildren() {
    _childRenderObjects.values.forEach(redepthChild);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    _childRenderObjects.values.forEach(visitor);
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> children = <DiagnosticsNode>[];
    _childRenderObjects.forEach((index, child) =>
        children.add(child.toDiagnosticsNode(name: 'child $index')));
    return children;
  }
}
















/// A base class for sliver that have multiple variable size box children.
///
/// Helps subclasses build their children lazily using a [SliverVariableSizeChildDelegate].
abstract class SliverVariableSizeBoxAdaptorWidget
    extends SliverWithKeepAliveWidget {
  /// Initializes fields for subclasses.
  const SliverVariableSizeBoxAdaptorWidget({
    Key? key,
    required this.delegate,
    this.addAutomaticKeepAlives = true,
  }) : super(key: key);

  /// Whether to add keepAlives to children
  final bool addAutomaticKeepAlives;

  /// The delegate that provides the children for this widget.
  ///
  /// The children are constructed lazily using this widget to avoid creating
  /// more children than are visible through the [Viewport].
  ///
  /// See also:
  ///
  ///  * [SliverChildBuilderDelegate] and [SliverChildListDelegate], which are
  ///    commonly used subclasses of [SliverChildDelegate] that use a builder
  ///    callback and an explicit child list, respectively.
  final SliverChildDelegate delegate;

  @override
  SliverVariableSizeBoxAdaptorElement createElement() =>
      SliverVariableSizeBoxAdaptorElement(
        this,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
      );

  @override
  RenderSliverVariableSizeBoxAdaptor createRenderObject(BuildContext context);

  /// Returns an estimate of the max scroll extent for all the children.
  ///
  /// Subclasses should override this function if they have additional
  /// information about their max scroll extent.
  ///
  /// This is used by [SliverMultiBoxAdaptorElement] to implement part of the
  /// [RenderSliverBoxChildManager] API.
  ///
  /// The default implementation defers to [delegate] via its
  /// [SliverChildDelegate.estimateMaxScrollOffset] method.
  double? estimateMaxScrollOffset(
      SliverConstraints constraints,
      int firstIndex,
      int lastIndex,
      double leadingScrollOffset,
      double trailingScrollOffset,
      ) {
    assert(lastIndex >= firstIndex);
    return delegate.estimateMaxScrollOffset(
      firstIndex,
      lastIndex,
      leadingScrollOffset,
      trailingScrollOffset,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<SliverChildDelegate>('delegate', delegate),
    );
  }
}

/// An element that lazily builds children for a [SliverVariableSizeBoxAdaptorWidget].
///
/// Implements [RenderSliverVariableSizeBoxChildManager], which lets this element manage
/// the children of subclasses of [RenderSliverVariableSizeBoxAdaptor].
class SliverVariableSizeBoxAdaptorElement extends RenderObjectElement
    implements RenderSliverVariableSizeBoxChildManager {
  /// Creates an element that lazily builds children for the given widget.
  SliverVariableSizeBoxAdaptorElement(SliverVariableSizeBoxAdaptorWidget widget,
      {this.addAutomaticKeepAlives = true})
      : super(widget);

  /// Whether to add keepAlives to children
  final bool addAutomaticKeepAlives;

  @override
  SliverVariableSizeBoxAdaptorWidget get widget =>
      super.widget as SliverVariableSizeBoxAdaptorWidget;

  @override
  RenderSliverVariableSizeBoxAdaptor get renderObject =>
      super.renderObject as RenderSliverVariableSizeBoxAdaptor;

  @override
  void update(covariant SliverVariableSizeBoxAdaptorWidget newWidget) {
    final SliverVariableSizeBoxAdaptorWidget oldWidget = widget;
    super.update(newWidget);
    final SliverChildDelegate newDelegate = newWidget.delegate;
    final SliverChildDelegate oldDelegate = oldWidget.delegate;
    if (newDelegate != oldDelegate &&
        (newDelegate.runtimeType != oldDelegate.runtimeType ||
            newDelegate.shouldRebuild(oldDelegate))) {
      performRebuild();
    }
  }

  // We inflate widgets at two different times:
  //  1. When we ourselves are told to rebuild (see performRebuild).
  //  2. When our render object needs a child (see createChild).
  // In both cases, we cache the results of calling into our delegate to get the widget,
  // so that if we do case 2 later, we don't call the builder again.
  // Any time we do case 1, though, we reset the cache.

  final Map<int, Widget?> _childWidgets = HashMap<int, Widget?>();
  final SplayTreeMap<int, Element> _childElements =
  SplayTreeMap<int, Element>();

  @override
  void performRebuild() {
    _childWidgets.clear(); // Reset the cache, as described above.
    super.performRebuild();
    assert(_currentlyUpdatingChildIndex == null);
    try {
      late final int firstIndex;
      late final int lastIndex;
      if (_childElements.isEmpty) {
        firstIndex = 0;
        lastIndex = 0;
      } else if (_didUnderflow) {
        firstIndex = _childElements.firstKey()!;
        lastIndex = _childElements.lastKey()! + 1;
      } else {
        firstIndex = _childElements.firstKey()!;
        lastIndex = _childElements.lastKey()!;
      }

      for (int index = firstIndex; index <= lastIndex; ++index) {
        _currentlyUpdatingChildIndex = index;
        final Element? newChild =
        updateChild(_childElements[index], _build(index), index);
        if (newChild != null) {
          _childElements[index] = newChild;
        } else {
          _childElements.remove(index);
        }
      }
    } finally {
      _currentlyUpdatingChildIndex = null;
    }
  }

  Widget? _build(int index) {
    return _childWidgets.putIfAbsent(
        index, () => widget.delegate.build(this, index));
  }

  @override
  void createChild(int index) {
    assert(_currentlyUpdatingChildIndex == null);
    owner!.buildScope(this, () {
      Element? newChild;
      try {
        _currentlyUpdatingChildIndex = index;
        newChild = updateChild(_childElements[index], _build(index), index);
      } finally {
        _currentlyUpdatingChildIndex = null;
      }
      if (newChild != null) {
        _childElements[index] = newChild;
      } else {
        _childElements.remove(index);
      }
    });
  }

  @override
  Element? updateChild(Element? child, Widget? newWidget, dynamic newSlot) {
    final oldParentData = child?.renderObject?.parentData
    as SliverVariableSizeBoxAdaptorParentData?;
    final Element? newChild = super.updateChild(child, newWidget, newSlot);
    final newParentData = newChild?.renderObject?.parentData
    as SliverVariableSizeBoxAdaptorParentData?;

    // set keepAlive to true in order to populate the cache
    if (addAutomaticKeepAlives && newParentData != null) {
      newParentData.keepAlive = true;
    }

    // Preserve the old layoutOffset if the renderObject was swapped out.
    if (oldParentData != newParentData &&
        oldParentData != null &&
        newParentData != null) {
      newParentData.layoutOffset = oldParentData.layoutOffset;
    }

    return newChild;
  }

  @override
  void forgetChild(Element child) {
    assert(child.slot != null);
    assert(_childElements.containsKey(child.slot));
    _childElements.remove(child.slot);
    super.forgetChild(child);
  }

  @override
  void removeChild(RenderBox child) {
    final int index = renderObject.indexOf(child);
    assert(_currentlyUpdatingChildIndex == null);
    assert(index >= 0);
    owner!.buildScope(this, () {
      assert(_childElements.containsKey(index));
      try {
        _currentlyUpdatingChildIndex = index;
        final Element? result = updateChild(_childElements[index], null, index);
        assert(result == null);
      } finally {
        _currentlyUpdatingChildIndex = null;
      }
      _childElements.remove(index);
      assert(!_childElements.containsKey(index));
    });
  }

  double? _extrapolateMaxScrollOffset(
      int? firstIndex,
      int? lastIndex,
      double? leadingScrollOffset,
      double? trailingScrollOffset,
      ) {
    final int? childCount = widget.delegate.estimatedChildCount;
    if (childCount == null) {
      return double.infinity;
    }
    if (lastIndex == childCount - 1) {
      return trailingScrollOffset;
    }
    final int reifiedCount = lastIndex! - firstIndex! + 1;
    final double averageExtent =
        (trailingScrollOffset! - leadingScrollOffset!) / reifiedCount;
    final int remainingCount = childCount - lastIndex - 1;
    return trailingScrollOffset + averageExtent * remainingCount;
  }

  @override
  double estimateMaxScrollOffset(
      SliverConstraints constraints, {
        int? firstIndex,
        int? lastIndex,
        double? leadingScrollOffset,
        double? trailingScrollOffset,
      }) {
    return widget.estimateMaxScrollOffset(
      constraints,
      firstIndex!,
      lastIndex!,
      leadingScrollOffset!,
      trailingScrollOffset!,
    ) ??
        _extrapolateMaxScrollOffset(
          firstIndex,
          lastIndex,
          leadingScrollOffset,
          trailingScrollOffset,
        )!;
  }

  @override
  int get childCount => widget.delegate.estimatedChildCount ?? 0;

  @override
  void didStartLayout() {
    assert(debugAssertChildListLocked());
  }

  @override
  void didFinishLayout() {
    assert(debugAssertChildListLocked());
    final int firstIndex = _childElements.firstKey() ?? 0;
    final int lastIndex = _childElements.lastKey() ?? 0;
    widget.delegate.didFinishLayout(firstIndex, lastIndex);
  }

  int? _currentlyUpdatingChildIndex;

  @override
  bool debugAssertChildListLocked() {
    assert(_currentlyUpdatingChildIndex == null);
    return true;
  }

  @override
  void didAdoptChild(RenderBox child) {
    assert(_currentlyUpdatingChildIndex != null);
    final childParentData =
    child.parentData! as SliverVariableSizeBoxAdaptorParentData;
    childParentData.index = _currentlyUpdatingChildIndex;
  }

  bool _didUnderflow = false;

  @override
  void setDidUnderflow(bool value) {
    _didUnderflow = value;
  }

  @override
  void insertRenderObjectChild(covariant RenderBox child, int slot) {
    assert(_currentlyUpdatingChildIndex == slot);
    assert(renderObject.debugValidateChild(child));
    renderObject[_currentlyUpdatingChildIndex!] = child;
    assert(() {
      final childParentData =
      child.parentData! as SliverVariableSizeBoxAdaptorParentData;
      assert(slot == childParentData.index);
      return true;
    }());
  }

  @override
  void moveRenderObjectChild(
      covariant RenderObject child,
      covariant Object? oldSlot,
      covariant Object? newSlot,
      ) {
    assert(false);
  }

  @override
  void removeRenderObjectChild(
      covariant RenderObject child,
      covariant Object? slot,
      ) {
    assert(_currentlyUpdatingChildIndex != null);
    renderObject.remove(_currentlyUpdatingChildIndex!);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    // The toList() is to make a copy so that the underlying list can be modified by
    // the visitor:
    _childElements.values.toList().forEach(visitor);
  }

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    _childElements.values.where((Element child) {
      final parentData =
      child.renderObject!.parentData as SliverMultiBoxAdaptorParentData?;
      late double itemExtent;
      switch (renderObject.constraints.axis) {
        case Axis.horizontal:
          itemExtent = child.renderObject!.paintBounds.width;
          break;
        case Axis.vertical:
          itemExtent = child.renderObject!.paintBounds.height;
          break;
      }

      return parentData!.layoutOffset! <
          renderObject.constraints.scrollOffset +
              renderObject.constraints.remainingPaintExtent &&
          parentData.layoutOffset! + itemExtent >
              renderObject.constraints.scrollOffset;
    }).forEach(visitor);
  }
}

/// A sliver that places multiple box children in a two dimensional arrangement.
///
/// [SliverStaggeredGrid] places its children in arbitrary positions determined by
/// [gridDelegate]. Each child is forced to have the size specified by the
/// [gridDelegate].
///
/// The main axis direction of a grid is the direction in which it scrolls; the
/// cross axis direction is the orthogonal direction.
///
/// ## Sample code
///
/// This example, which would be inserted into a [CustomScrollView.slivers]
/// list, shows 8 boxes:
///
/// ```dart
///SliverStaggeredGrid.count(
///  crossAxisCount: 4,
///  mainAxisSpacing: 4.0,
///  crossAxisSpacing: 4.0,
///  children: const <Widget>[
///    const Text('1'),
///    const Text('2'),
///    const Text('3'),
///    const Text('4'),
///    const Text('5'),
///    const Text('6'),
///    const Text('7'),
///    const Text('8'),
///  ],
///  staggeredTiles: const <StaggeredTile>[
///    const StaggeredTile.count(2, 2),
///    const StaggeredTile.count(2, 1),
///    const StaggeredTile.count(2, 2),
///    const StaggeredTile.count(2, 1),
///    const StaggeredTile.count(2, 2),
///    const StaggeredTile.count(2, 1),
///    const StaggeredTile.count(2, 2),
///    const StaggeredTile.count(2, 1),
///  ],
///)
/// ```
///
/// See also:
///
///  * [SliverList], which places its children in a linear array.
///  * [SliverFixedExtentList], which places its children in a linear
///    array with a fixed extent in the main axis.
///  * [SliverPrototypeExtentList], which is similar to [SliverFixedExtentList]
///    except that it uses a prototype list item instead of a pixel value to define
///    the main axis extent of each item.
class SliverStaggeredGrid extends SliverVariableSizeBoxAdaptorWidget {
  /// Creates a sliver that places multiple box children in a two dimensional
  /// arrangement.
  const SliverStaggeredGrid({
    Key? key,
    required SliverChildDelegate delegate,
    required this.gridDelegate,
    bool addAutomaticKeepAlives = true,
  }) : super(
    key: key,
    delegate: delegate,
    addAutomaticKeepAlives: addAutomaticKeepAlives,
  );

  /// Creates a sliver that places multiple box children in a two dimensional
  /// arrangement with a fixed number of tiles in the cross axis.
  ///
  /// Uses a [SliverStaggeredGridDelegateWithFixedCrossAxisCount] as the [gridDelegate],
  /// and a [SliverVariableSizeChildListDelegate] as the [delegate].
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  //  [SliverVariableSizeChildListDelegate.addAutomaticKeepAlives] property. The
  ///
  /// See also:
  ///
  ///  * [StaggeredGridView.count], the equivalent constructor for [StaggeredGridView] widgets.
  SliverStaggeredGrid.count({
    Key? key,
    required int crossAxisCount,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    List<Widget> children = const <Widget>[],
    List<StaggeredTile> staggeredTiles = const <StaggeredTile>[],
    bool addAutomaticKeepAlives = true,
  })  : gridDelegate = SliverStaggeredGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: crossAxisCount,
    mainAxisSpacing: mainAxisSpacing,
    crossAxisSpacing: crossAxisSpacing,
    staggeredTileBuilder: (i) => staggeredTiles[i],
    staggeredTileCount: staggeredTiles.length,
  ),
        super(
        key: key,
        delegate: SliverChildListDelegate(
          children,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
        ),
      );

  /// Creates a sliver that builds multiple box children in a two dimensional
  /// arrangement with a fixed number of tiles in the cross axis.
  ///
  /// This constructor is appropriate for grid views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// Uses a [SliverStaggeredGridDelegateWithFixedCrossAxisCount] as the
  /// [gridDelegate], and a [SliverVariableSizeChildBuilderDelegate] as the [delegate].
  ///
  /// See also:
  ///
  ///  * [StaggeredGridView.countBuilder], the equivalent constructor for
  ///  [StaggeredGridView] widgets.
  SliverStaggeredGrid.countBuilder({
    Key? key,
    required int crossAxisCount,
    required IndexedStaggeredTileBuilder staggeredTileBuilder,
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    bool addAutomaticKeepAlives = true,
  })  : gridDelegate = SliverStaggeredGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: crossAxisCount,
    mainAxisSpacing: mainAxisSpacing,
    crossAxisSpacing: crossAxisSpacing,
    staggeredTileBuilder: staggeredTileBuilder,
    staggeredTileCount: itemCount,
  ),
        super(
        key: key,
        delegate: SliverChildBuilderDelegate(
          itemBuilder,
          childCount: itemCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
        ),
      );

  /// Creates a sliver that places multiple box children in a two dimensional
  /// arrangement with tiles that each have a maximum cross-axis extent.
  ///
  /// Uses a [SliverStaggeredGridDelegateWithMaxCrossAxisExtent] as the [gridDelegate],
  /// and a [SliverVariableSizeChildListDelegate] as the [delegate].
  ///
  /// See also:
  ///
  ///  * [StaggeredGridView.extent], the equivalent constructor for [StaggeredGridView] widgets.
  SliverStaggeredGrid.extent({
    Key? key,
    required double maxCrossAxisExtent,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    List<Widget> children = const <Widget>[],
    List<StaggeredTile> staggeredTiles = const <StaggeredTile>[],
    bool addAutomaticKeepAlives = true,
  })  : gridDelegate = SliverStaggeredGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: maxCrossAxisExtent,
    mainAxisSpacing: mainAxisSpacing,
    crossAxisSpacing: crossAxisSpacing,
    staggeredTileBuilder: (i) => staggeredTiles[i],
    staggeredTileCount: staggeredTiles.length,
  ),
        super(
        key: key,
        delegate: SliverChildListDelegate(
          children,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
        ),
      );

  /// Creates a sliver that builds multiple box children in a two dimensional
  /// arrangement with tiles that each have a maximum cross-axis extent.
  ///
  /// This constructor is appropriate for grid views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// Uses a [SliverStaggeredGridDelegateWithMaxCrossAxisExtent] as the
  /// [gridDelegate], and a [SliverVariableSizeChildBuilderDelegate] as the [delegate].
  ///
  /// See also:
  ///
  ///  * [StaggeredGridView.extentBuilder], the equivalent constructor for
  ///  [StaggeredGridView] widgets.
  SliverStaggeredGrid.extentBuilder({
    Key? key,
    required double maxCrossAxisExtent,
    required IndexedStaggeredTileBuilder staggeredTileBuilder,
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    bool addAutomaticKeepAlives = true,
  })  : gridDelegate = SliverStaggeredGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: maxCrossAxisExtent,
    mainAxisSpacing: mainAxisSpacing,
    crossAxisSpacing: crossAxisSpacing,
    staggeredTileBuilder: staggeredTileBuilder,
    staggeredTileCount: itemCount,
  ),
        super(
        key: key,
        delegate: SliverChildBuilderDelegate(
          itemBuilder,
          childCount: itemCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
        ),
      );

  /// The delegate that controls the size and position of the children.
  final SliverStaggeredGridDelegate gridDelegate;

  @override
  RenderSliverStaggeredGrid createRenderObject(BuildContext context) {
    final element = context as SliverVariableSizeBoxAdaptorElement;
    return RenderSliverStaggeredGrid(
        childManager: element, gridDelegate: gridDelegate);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderSliverStaggeredGrid renderObject) {
    renderObject.gridDelegate = gridDelegate;
  }
}


