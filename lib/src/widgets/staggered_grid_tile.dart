import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/src/rendering/staggered_grid.dart';
import 'package:flutter_staggered_grid_view/src/widgets/staggered_grid.dart';

class StaggeredGridTile extends ParentDataWidget<StaggeredGridParentData> {
  const StaggeredGridTile._({
    Key? key,
    required this.crossAxisCellCount,
    required this.mainAxisCellCount,
    required this.mainAxisExtent,
    required Widget child,
  })  : assert(crossAxisCellCount > 0),
        assert(mainAxisCellCount == null || mainAxisCellCount > 0),
        assert(mainAxisExtent == null || mainAxisExtent > 0),
        super(key: key, child: child);

  const StaggeredGridTile.count({
    Key? key,
    required int crossAxisCellCount,
    required num mainAxisCellCount,
    required Widget child,
  }) : this._(
          key: key,
          crossAxisCellCount: crossAxisCellCount,
          mainAxisCellCount: mainAxisCellCount,
          mainAxisExtent: null,
          child: child,
        );

  const StaggeredGridTile.extent({
    Key? key,
    required int crossAxisCellCount,
    required double mainAxisExtent,
    required Widget child,
  }) : this._(
          key: key,
          crossAxisCellCount: crossAxisCellCount,
          mainAxisCellCount: null,
          mainAxisExtent: mainAxisExtent,
          child: child,
        );

  final int crossAxisCellCount;
  final num? mainAxisCellCount;
  final double? mainAxisExtent;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData;
    if (parentData is StaggeredGridParentData) {
      bool needsLayout = false;

      if (parentData.crossAxisCellCount != crossAxisCellCount) {
        parentData.crossAxisCellCount = crossAxisCellCount;
        needsLayout = true;
      }

      if (parentData.mainAxisCellCount != mainAxisCellCount) {
        parentData.mainAxisCellCount = mainAxisCellCount;
        needsLayout = true;
      }

      if (parentData.mainAxisExtent != mainAxisExtent) {
        parentData.mainAxisExtent = mainAxisExtent;
        needsLayout = true;
      }

      if (needsLayout) {
        final targetParent = renderObject.parent;
        if (targetParent is RenderStaggeredGrid) {
          targetParent.markNeedsLayout();
        }
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => StaggeredGrid;
}
