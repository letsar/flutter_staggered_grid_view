import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/src/rendering/staggered_grid.dart';

class StaggeredGrid extends MultiChildRenderObjectWidget {
  StaggeredGrid({
    Key? key,
    required this.crossAxisCount,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.axisDirection,
    List<Widget> children = const <Widget>[],
  })  : assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        super(key: key, children: children);

  /// {@macro fsgv.global.crossAxisCount}
  final int crossAxisCount;

  /// {@macro fsgv.global.mainAxisSpacing}
  final double mainAxisSpacing;

  /// {@macro fsgv.global.crossAxisSpacing}
  final double crossAxisSpacing;

  final AxisDirection? axisDirection;

  @override
  RenderStaggeredGrid createRenderObject(BuildContext context) {
    return RenderStaggeredGrid(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      axisDirection: axisDirection ??
          Scrollable.of(context)?.axisDirection ??
          AxisDirection.down,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderStaggeredGrid renderObject,
  ) {
    renderObject
      ..crossAxisCount = crossAxisCount
      ..mainAxisSpacing = mainAxisSpacing
      ..crossAxisSpacing = crossAxisSpacing
      ..axisDirection = axisDirection ??
          Scrollable.of(context)?.axisDirection ??
          AxisDirection.down
      ..textDirection = Directionality.of(context);
  }
}
