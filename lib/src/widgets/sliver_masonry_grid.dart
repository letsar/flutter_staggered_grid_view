import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/src/rendering/sliver_masonry_grid.dart';
import 'package:flutter_staggered_grid_view/src/rendering/sliver_simple_grid_delegate.dart';

/// A sliver that places multiple box children in a two dimensional arrangement.
///
/// [SliverMasonryGrid] places each child the nearest as possible at the
/// start of the main axis and then at the start of the cross axis.
/// For example, in a vertical list, with left-to-right text direction, a child
/// will be placed as close as possible at the top of the grid, and then as
/// close as possible to the left side of the grid.
///
/// The [gridDelegate] determines how many children can be placed in the cross
/// axis.
class SliverMasonryGrid extends SliverMultiBoxAdaptorWidget {
  /// Creates a sliver that places its children in a Masonry arrangement.
  ///
  /// The [mainAxisSpacing] and [crossAxisSpacing] arguments must not be
  /// negative.
  const SliverMasonryGrid({
    Key? key,
    required SliverChildDelegate delegate,
    required this.gridDelegate,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.mainAxisExtentBuilder,
    this.isFullSpan,
  })  : assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        super(key: key, delegate: delegate);

  /// Creates a sliver that places multiple box children in a Masonry
  /// arrangement with a fixed number of tiles in the cross axis.
  ///
  /// Uses a [SliverSimpleGridDelegateWithFixedCrossAxisCount] as the
  /// [gridDelegate] and a [SliverChildBuilderDelegate] as the [delegate].
  ///
  /// The [crossAxisCount] argument must be greater than zero, and the
  /// [mainAxisSpacing] and [crossAxisSpacing] arguments must not be negative.
  SliverMasonryGrid.count({
    Key? key,
    required int crossAxisCount,
    required NullableIndexedWidgetBuilder itemBuilder,
    int? childCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    MasonryMainAxisExtentBuilder? mainAxisExtentBuilder,
    MasonryFullSpanPredicate? isFullSpan,
  }) : this(
          key: key,
          delegate: SliverChildBuilderDelegate(
            itemBuilder,
            childCount: childCount,
          ),
          gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
          ),
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisExtentBuilder: mainAxisExtentBuilder,
          isFullSpan: isFullSpan,
        );

  /// Creates a sliver that places multiple box children in a Masonry
  /// arrangement with tiles that each have a maximum cross-axis extent.
  ///
  /// Uses a [SliverSimpleGridDelegateWithMaxCrossAxisExtent] as the
  /// [gridDelegate] and a [SliverChildBuilderDelegate] as the [delegate].
  ///
  /// The [maxCrossAxisExtent] argument must be greater than zero, and the
  /// [mainAxisSpacing] and [crossAxisSpacing] arguments must not be negative.
  SliverMasonryGrid.extent({
    Key? key,
    required double maxCrossAxisExtent,
    required NullableIndexedWidgetBuilder itemBuilder,
    int? childCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    MasonryMainAxisExtentBuilder? mainAxisExtentBuilder,
    MasonryFullSpanPredicate? isFullSpan,
  }) : this(
          key: key,
          delegate: SliverChildBuilderDelegate(
            itemBuilder,
            childCount: childCount,
          ),
          gridDelegate: SliverSimpleGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxCrossAxisExtent,
          ),
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisExtentBuilder: mainAxisExtentBuilder,
          isFullSpan: isFullSpan,
        );

  /// {@macro fsgv.global.gridDelegate}
  final SliverSimpleGridDelegate gridDelegate;

  /// {@macro fsgv.global.mainAxisSpacing}
  final double mainAxisSpacing;

  /// {@macro fsgv.global.crossAxisSpacing}
  final double crossAxisSpacing;

  /// {@macro fsgv.masonry.mainAxisExtentBuilder}
  final MasonryMainAxisExtentBuilder? mainAxisExtentBuilder;

  /// {@macro fsgv.masonry.isFullSpan}
  final MasonryFullSpanPredicate? isFullSpan;

  /// The exact number of children, if the delegate knows it.
  ///
  /// [SliverChildDelegate.estimatedChildCount] is only an estimate for other
  /// delegates.
  int? get _itemCount {
    final delegate = this.delegate;
    if (delegate is SliverChildBuilderDelegate) {
      return delegate.childCount;
    }
    if (delegate is SliverChildListDelegate) {
      return delegate.children.length;
    }
    return null;
  }

  // Like SliverList, children moved with keys are replaced, so that inserting a
  // child does not leave a hole between the indexes of the children.
  @override
  SliverMultiBoxAdaptorElement createElement() =>
      SliverMultiBoxAdaptorElement(this, replaceMovedChildren: true);

  @override
  RenderSliverMasonryGrid createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element =
        context as SliverMultiBoxAdaptorElement;
    return RenderSliverMasonryGrid(
      childManager: element,
      gridDelegate: gridDelegate,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      itemCount: _itemCount,
      mainAxisExtentBuilder: mainAxisExtentBuilder,
      isFullSpan: isFullSpan,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverMasonryGrid renderObject,
  ) {
    renderObject
      ..gridDelegate = gridDelegate
      ..mainAxisSpacing = mainAxisSpacing
      ..crossAxisSpacing = crossAxisSpacing
      ..itemCount = _itemCount
      ..mainAxisExtentBuilder = mainAxisExtentBuilder
      ..isFullSpan = isFullSpan;
  }
}
