import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/src/rendering/sliver_aligned_grid.dart';
import 'package:flutter_staggered_grid_view/src/rendering/sliver_simple_grid_delegate.dart';

/// A sliver that places multiple box children in a two dimensional aligned
/// arrangement.
///
/// [SliverAlignedGrid] sizes each child within the same track with the maximum
/// main axis extent of the track's children.
///
/// The [gridDelegate] determines how many children can be placed in the cross
/// axis.
class SliverAlignedGrid extends SliverMultiBoxAdaptorWidget {
  /// Creates a sliver that places its children in an aligned arrangement.
  ///
  /// The [mainAxisSpacing] and [crossAxisSpacing] arguments must be greater
  /// than zero.
  const SliverAlignedGrid({
    Key? key,
    required SliverChildDelegate delegate,
    required this.gridDelegate,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
  })  : assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        super(key: key, delegate: delegate);

  /// Creates a sliver that places multiple box children in an aligned
  /// arrangement with a fixed number of tiles in the cross axis.
  ///
  /// Uses a [SliverSimpleGridDelegateWithFixedCrossAxisCount] as the
  /// [gridDelegate] and a [SliverChildBuilderDelegate] as the [delegate].
  ///
  /// The [crossAxisCount], [mainAxisSpacing] and [crossAxisSpacing] arguments
  /// must be greater than zero.
  SliverAlignedGrid.count({
    Key? key,
    required int crossAxisCount,
    required IndexedWidgetBuilder itemBuilder,
    int? childCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
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
        );

  /// Creates a sliver that places multiple box children in an aligned
  /// arrangement with tiles that each have a maximum cross-axis extent.
  ///
  /// Uses a [SliverSimpleGridDelegateWithMaxCrossAxisExtent] as the
  /// [gridDelegate] and a [SliverChildBuilderDelegate] as the [delegate].
  ///
  /// The [maxCrossAxisExtent], [mainAxisSpacing] and [crossAxisSpacing]
  /// arguments must be greater than zero.
  SliverAlignedGrid.extent({
    Key? key,
    required double maxCrossAxisExtent,
    required IndexedWidgetBuilder itemBuilder,
    int? childCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
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
        );

  /// {@macro fsgv.global.mainAxisSpacing}
  final double mainAxisSpacing;

  /// {@macro fsgv.global.crossAxisSpacing}
  final double crossAxisSpacing;

  /// {@macro fsgv.global.gridDelegate}
  final SliverSimpleGridDelegate gridDelegate;

  @override
  SliverMultiBoxAdaptorElement createElement() {
    return SliverMultiBoxAdaptorElement(this, replaceMovedChildren: true);
  }

  @override
  RenderSliverAlignedGrid createRenderObject(BuildContext context) {
    final element = context as SliverMultiBoxAdaptorElement;

    return RenderSliverAlignedGrid(
      childManager: element,
      gridDelegate: gridDelegate,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverAlignedGrid renderObject,
  ) {
    renderObject
      ..gridDelegate = gridDelegate
      ..crossAxisSpacing = crossAxisSpacing
      ..mainAxisSpacing = mainAxisSpacing;
  }
}
