import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/src/rendering/sliver_masonry_grid.dart';

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
  /// The [mainAxisSpacing] and [crossAxisSpacing] arguments must be greater
  /// than zero.
  const SliverMasonryGrid({
    Key? key,
    required SliverChildDelegate delegate,
    required this.gridDelegate,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
  })  : assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        super(key: key, delegate: delegate);

  /// Creates a sliver that places multiple box children in a Masonry
  /// arrangement with a fixed number of tiles in the cross axis.
  ///
  /// Uses a [SliverMasonryGridDelegateWithFixedCrossAxisCount] as the
  /// [gridDelegate] and a [SliverChildBuilderDelegate] as the [delegate].
  ///
  /// The [crossAxisCount], [mainAxisSpacing] and [crossAxisSpacing] arguments
  /// must be greater than zero.
  SliverMasonryGrid.count({
    Key? key,
    required int crossAxisCount,
    required IndexedWidgetBuilder itemBuilder,
    required int childCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
  }) : this(
          key: key,
          delegate: SliverChildBuilderDelegate(
            itemBuilder,
            childCount: childCount,
          ),
          gridDelegate: SliverMasonryGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
          ),
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        );

  /// Creates a sliver that places multiple box children in a Masonry
  /// arrangement with tiles that each have a maximum cross-axis extent.
  ///
  /// Uses a [SliverMasonryGridDelegateWithMaxCrossAxisExtent] as the
  /// [gridDelegate] and a [SliverChildBuilderDelegate] as the [delegate].
  ///
  /// The [maxCrossAxisExtent], [mainAxisSpacing] and [crossAxisSpacing]
  /// arguments must be greater than zero.
  SliverMasonryGrid.extent({
    Key? key,
    required double maxCrossAxisExtent,
    required IndexedWidgetBuilder itemBuilder,
    required int childCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
  }) : this(
          key: key,
          delegate: SliverChildBuilderDelegate(
            itemBuilder,
            childCount: childCount,
          ),
          gridDelegate: SliverMasonryGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxCrossAxisExtent,
          ),
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        );

  /// {@macro fsgv.masonry.gridDelegate}
  final SliverMasonryGridDelegate gridDelegate;

  /// {@macro fsgv.global.mainAxisSpacing}
  final double mainAxisSpacing;

  /// {@macro fsgv.global.crossAxisSpacing}
  final double crossAxisSpacing;

  @override
  RenderSliverMasonryGrid createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element =
        context as SliverMultiBoxAdaptorElement;
    return RenderSliverMasonryGrid(
      childManager: element,
      gridDelegate: gridDelegate,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
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
      ..crossAxisSpacing = crossAxisSpacing;
  }
}
