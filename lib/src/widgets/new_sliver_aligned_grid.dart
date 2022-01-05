import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/src/rendering/sliver_aligned_grid.dart';

class SliverNewAlignedGrid extends SliverMultiBoxAdaptorWidget {
  const SliverNewAlignedGrid({
    Key? key,
    required SliverChildDelegate delegate,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    required this.crossAxisCount,
  })  : assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        super(
          key: key,
          delegate: delegate,
        );

  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final int crossAxisCount;

  @override
  SliverMultiBoxAdaptorElement createElement() => SliverMultiBoxAdaptorElement(
        this,
        replaceMovedChildren: true,
      );

  @override
  RenderSliverAlignedGrid createRenderObject(BuildContext context) {
    final element = context as SliverMultiBoxAdaptorElement;

    return RenderSliverAlignedGrid(
      childManager: element,
      crossAxisCount: crossAxisCount,
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
      ..crossAxisCount = crossAxisCount
      ..crossAxisSpacing = crossAxisSpacing
      ..mainAxisSpacing = mainAxisSpacing;
  }
}
