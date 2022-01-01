// ignore_for_file: comment_references

import 'package:flutter/rendering.dart';

/// Controls the layout of tiles in a some slivers.
///
/// See also:
///
///  * [SliverSimpleGridDelegateWithFixedCrossAxisCount], which creates a
///    layout with a fixed number of tiles in the cross axis.
///  * [SliverSimpleGridDelegateWithMaxCrossAxisExtent], which creates a layout
///    with tiles that have a maximum cross-axis extent.
///  * [RenderSliverMasonryGrid], which uses this delegate to control the layout
///  of its tiles.
abstract class SliverSimpleGridDelegate {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const SliverSimpleGridDelegate();

  /// Returns the number of children than can be layout in the cross axis.
  int getCrossAxisCount(SliverConstraints constraints, double crossAxisSpacing);

  /// Override this method to return true when the children need to be
  /// laid out.
  ///
  /// This should compare the fields of the current delegate and the given
  /// `oldDelegate` and return true if the fields are such that the layout would
  /// be different.
  bool shouldRelayout(covariant SliverSimpleGridDelegate oldDelegate);
}

/// Creates grid layouts with a fixed number of tiles in the cross axis.
///
/// For example, if the grid is vertical, this delegate will create a layout
/// with a fixed number of columns. If the grid is horizontal, this delegate
/// will create a layout with a fixed number of rows.
///
/// This delegate creates grids with equally sized and spaced tiles.
class SliverSimpleGridDelegateWithFixedCrossAxisCount
    extends SliverSimpleGridDelegate {
  /// Creates a delegate that makes grid layouts with a fixed number of tiles in
  /// the cross axis.
  ///
  /// The [crossAxisCount] argument must be greater than zero.
  const SliverSimpleGridDelegateWithFixedCrossAxisCount({
    required this.crossAxisCount,
  }) : assert(crossAxisCount > 0);

  /// {@template fsgv.global.crossAxisCount}
  /// The number of children in the cross axis.
  /// {@endtemplate}
  final int crossAxisCount;

  @override
  int getCrossAxisCount(
    SliverConstraints constraints,
    double crossAxisSpacing,
  ) {
    return crossAxisCount;
  }

  @override
  bool shouldRelayout(
    SliverSimpleGridDelegateWithFixedCrossAxisCount oldDelegate,
  ) {
    return oldDelegate.crossAxisCount != crossAxisCount;
  }
}

/// Creates grid layouts with tiles that each have a maximum cross-axis extent.
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
/// This delegate creates grids with equally sized and spaced tiles.
///
/// See also:
///
///  * [SliverSimpleGridDelegateWithFixedCrossAxisCount], which creates a
///    layout with a fixed number of tiles in the cross axis.
///  * [SliverSimpleGridDelegate], which creates arbitrary layouts.
///  * [RenderSliverMasonryGrid], which can use this delegate to control the
///    layout of its tiles.
class SliverSimpleGridDelegateWithMaxCrossAxisExtent
    extends SliverSimpleGridDelegate {
  /// Creates a delegate that makes grid layouts with tiles that have a maximum
  /// cross-axis extent.
  ///
  /// The [maxCrossAxisExtent] argument must be greater than zero.
  const SliverSimpleGridDelegateWithMaxCrossAxisExtent({
    required this.maxCrossAxisExtent,
  }) : assert(maxCrossAxisExtent > 0);

  /// {@template fsgv.global.maxCrossAxisExtent}
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
  /// {@endtemplate}
  final double maxCrossAxisExtent;

  @override
  int getCrossAxisCount(
    SliverConstraints constraints,
    double crossAxisSpacing,
  ) {
    return (constraints.crossAxisExtent /
            (maxCrossAxisExtent + crossAxisSpacing))
        .ceil();
  }

  @override
  bool shouldRelayout(
    SliverSimpleGridDelegateWithMaxCrossAxisExtent oldDelegate,
  ) {
    return oldDelegate.maxCrossAxisExtent != maxCrossAxisExtent;
  }
}
