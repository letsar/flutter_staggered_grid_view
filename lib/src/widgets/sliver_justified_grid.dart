import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/src/rendering/sliver_justified_grid.dart';

/// A sliver that layouts its children following a justified grid layout.
///
/// Remark: The algorithm is a slightly modified version of the one described in
/// flickr: https://github.com/flickr/justified-layout
class SliverJustifiedGrid extends SliverMultiBoxAdaptorWidget {
  /// Creates a [SliverJustifiedGrid].
  const SliverJustifiedGrid({
    Key? key,
    required SliverChildDelegate delegate,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    required this.trackMainAxisExtent,
    this.trackMainAxisExtentTolerance = 0.25,
    required this.aspectRatioGetter,
  })  : assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        assert(trackMainAxisExtent > 0),
        assert(
          trackMainAxisExtentTolerance > 0 && trackMainAxisExtentTolerance < 1,
        ),
        super(key: key, delegate: delegate);

  /// {@macro fsgv.global.mainAxisSpacing}
  final double mainAxisSpacing;

  /// {@macro fsgv.global.crossAxisSpacing}
  final double crossAxisSpacing;

  /// {@macro fsgv.justified.trackMainAxisExtent}
  final double trackMainAxisExtent;

  /// {@macro fsgv.justified.trackMainAxisExtentTolerance}
  final double trackMainAxisExtentTolerance;

  /// {@macro fsgv.justified.aspectRatioGetter}
  final AspectRatioGetter aspectRatioGetter;

  @override
  RenderSliverJustifiedGrid createRenderObject(BuildContext context) {
    final element = context as SliverMultiBoxAdaptorElement;

    return RenderSliverJustifiedGrid(
      childManager: element,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      targetMainAxisExtent: trackMainAxisExtent,
      targetMainAxisExtentTolerance: trackMainAxisExtentTolerance,
      aspectRatioGetter: aspectRatioGetter,
      estimatedChildCount: element.estimatedChildCount,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverJustifiedGrid renderObject,
  ) {
    renderObject
      ..aspectRatioGetter = aspectRatioGetter
      ..targetMainAxisExtent = trackMainAxisExtent
      ..targetMainAxisExtentTolerance = trackMainAxisExtentTolerance
      ..crossAxisSpacing = crossAxisSpacing
      ..mainAxisSpacing = mainAxisSpacing;
  }
}
