import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/src/rendering/sliver_masonry_grid.dart';

class SliverMasonryGrid extends SliverMultiBoxAdaptorWidget {
  const SliverMasonryGrid({
    Key? key,
    required SliverChildDelegate delegate,
    required this.crossAxisCount,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
  })  : assert(crossAxisCount >= 0),
        assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        super(key: key, delegate: delegate);

  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  @override
  RenderSliverMasonryGrid createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element =
        context as SliverMultiBoxAdaptorElement;
    return RenderSliverMasonryGrid(
      childManager: element,
      crossAxisCount: crossAxisCount,
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
      ..crossAxisCount = crossAxisCount
      ..mainAxisSpacing = mainAxisSpacing
      ..crossAxisSpacing = crossAxisSpacing;
  }
}
