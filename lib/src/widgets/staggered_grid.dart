import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/src/rendering/staggered_grid.dart';
import 'package:flutter_staggered_grid_view/src/widgets/staggered_grid_tile.dart';

/// A grid which lays out children in a staggered arrangement.
/// Each child can have a different size.
/// Wrap your children with a [StaggeredGridTile] to specify their size if it's
/// different from a 1x1 tile.
class StaggeredGrid extends MultiChildRenderObjectWidget {
  /// Creates a [StaggeredGrid] with a custom [delegate].
  StaggeredGrid.custom({
    Key? key,
    required this.delegate,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.axisDirection,
    List<Widget> children = const <Widget>[],
  })  : assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        super(key: key, children: children);

  /// Creates a [StaggeredGrid] using a custom
  /// [StaggeredGridDelegateWithFixedCrossAxisCount] as [delegate].
  ///
  /// The grid will have a fixed number of tiles in the cross axis.
  StaggeredGrid.count({
    Key? key,
    required int crossAxisCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    AxisDirection? axisDirection,
    List<Widget> children = const <Widget>[],
  }) : this.custom(
          key: key,
          delegate: StaggeredGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
          ),
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          axisDirection: axisDirection,
          children: children,
        );

  /// Creates a [StaggeredGrid] using a custom
  /// [StaggeredGridDelegateWithMaxCrossAxisExtent] as [delegate].
  ///
  /// The grid will have tiles that each have a maximum cross-axis extent.
  StaggeredGrid.extent({
    Key? key,
    required double maxCrossAxisExtent,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    AxisDirection? axisDirection,
    List<Widget> children = const <Widget>[],
  }) : this.custom(
          key: key,
          delegate: StaggeredGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxCrossAxisExtent,
          ),
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          axisDirection: axisDirection,
          children: children,
        );

  /// The delegate that controls the layout of the children.
  final StaggeredGridDelegate delegate;

  /// {@macro fsgv.global.mainAxisSpacing}
  final double mainAxisSpacing;

  /// {@macro fsgv.global.crossAxisSpacing}
  final double crossAxisSpacing;

  /// {@macro fsgv.global.axisDirection}
  final AxisDirection? axisDirection;

  @override
  RenderStaggeredGrid createRenderObject(BuildContext context) {
    return RenderStaggeredGrid(
      delegate: delegate,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      axisDirection: axisDirection ??
          Scrollable.maybeOf(context)?.axisDirection ??
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
      ..delegate = delegate
      ..mainAxisSpacing = mainAxisSpacing
      ..crossAxisSpacing = crossAxisSpacing
      ..axisDirection = axisDirection ??
          Scrollable.maybeOf(context)?.axisDirection ??
          AxisDirection.down
      ..textDirection = Directionality.of(context);
  }
}
