import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// Parent data structure used by [RenderStaggeredGrid].
class StaggeredGridParentData extends ContainerBoxParentData<RenderBox> {
  /// The number of cells in the cross axis taken by the child.
  int? crossAxisCellCount;

  /// The number of cells in the main axis taken by the child.
  num? mainAxisCellCount;

  /// The extent in the main axis of the child.
  double? mainAxisExtent;

  double? _realMainAxisExtent;

  @override
  String toString() =>
      'crossAxisCellCount=$crossAxisCellCount; mainAxisCellCount=$mainAxisCellCount; mainAxisExtent=$mainAxisExtent';
}

/// Controls the layout of a StaggeredGrid.
abstract class StaggeredGridDelegate {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const StaggeredGridDelegate();

  /// Returns the number of children in the cross axis.
  int getCrossAxisCount(double crossAxisExtent, double crossAxisSpacing);

  /// Override this method to return true when the children need to be
  /// laid out.
  ///
  /// This should compare the fields of the current delegate and the given
  /// `oldDelegate` and return true if the fields are such that the layout would
  /// be different.
  bool shouldRelayout(covariant StaggeredGridDelegate oldDelegate);
}

/// Creates grid layouts with a fixed number of tiles in the cross axis.
///
/// For example, if the grid is vertical, this delegate will create a layout
/// with a fixed number of columns. If the grid is horizontal, this delegate
/// will create a layout with a fixed number of rows.
class StaggeredGridDelegateWithFixedCrossAxisCount
    extends StaggeredGridDelegate {
  /// Creates a delegate that makes grid layouts with a fixed number of tiles in
  /// the cross axis.
  ///
  /// The [crossAxisCount] argument must be greater than zero.
  const StaggeredGridDelegateWithFixedCrossAxisCount({
    required this.crossAxisCount,
  }) : assert(crossAxisCount > 0);

  /// {@macro fsgv.global.crossAxisCount}
  final int crossAxisCount;

  @override
  int getCrossAxisCount(double crossAxisExtent, double crossAxisSpacing) {
    return crossAxisCount;
  }

  @override
  bool shouldRelayout(
    StaggeredGridDelegateWithFixedCrossAxisCount oldDelegate,
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
class StaggeredGridDelegateWithMaxCrossAxisExtent
    extends StaggeredGridDelegate {
  /// Creates a delegate that makes grid layouts with tiles that have a maximum
  /// cross-axis extent.
  ///
  /// The [maxCrossAxisExtent] argument must be greater than zero.
  const StaggeredGridDelegateWithMaxCrossAxisExtent({
    required this.maxCrossAxisExtent,
  }) : assert(maxCrossAxisExtent > 0);

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
  final double maxCrossAxisExtent;

  @override
  int getCrossAxisCount(double crossAxisExtent, double crossAxisSpacing) {
    return (crossAxisExtent / (maxCrossAxisExtent + crossAxisSpacing)).ceil();
  }

  @override
  bool shouldRelayout(
    StaggeredGridDelegateWithMaxCrossAxisExtent oldDelegate,
  ) {
    return oldDelegate.maxCrossAxisExtent != maxCrossAxisExtent;
  }
}

/// A sliver that places multiple box children with different sizes in a two
/// dimensional arrangement.
class RenderStaggeredGrid extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, StaggeredGridParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, StaggeredGridParentData> {
  /// Creates a [RenderStaggeredGrid].
  RenderStaggeredGrid({
    List<RenderBox>? children,
    required StaggeredGridDelegate delegate,
    required double mainAxisSpacing,
    required double crossAxisSpacing,
    required AxisDirection axisDirection,
    required TextDirection textDirection,
  })  : assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        _axisDirection = axisDirection,
        _textDirection = textDirection,
        _delegate = delegate,
        _mainAxisSpacing = mainAxisSpacing,
        _crossAxisSpacing = crossAxisSpacing {
    addAll(children);
  }

  /// The delegate that controls the size and position of the children.
  StaggeredGridDelegate get delegate => _delegate;
  StaggeredGridDelegate _delegate;
  set delegate(StaggeredGridDelegate newDelegate) {
    if (_delegate == newDelegate) {
      return;
    }
    if (newDelegate.runtimeType != _delegate.runtimeType ||
        newDelegate.shouldRelayout(_delegate)) {
      markNeedsLayout();
    }
    _delegate = newDelegate;
  }

  /// {@macro fsgv.global.mainAxisSpacing}
  double get mainAxisSpacing => _mainAxisSpacing;
  double _mainAxisSpacing;
  set mainAxisSpacing(double value) {
    if (_mainAxisSpacing == value) {
      return;
    }
    _mainAxisSpacing = value;
    markNeedsLayout();
  }

  /// {@macro fsgv.global.crossAxisSpacing}
  double get crossAxisSpacing => _crossAxisSpacing;
  double _crossAxisSpacing;
  set crossAxisSpacing(double value) {
    if (_crossAxisSpacing == value) {
      return;
    }
    _crossAxisSpacing = value;
    markNeedsLayout();
  }

  /// {@template fsgv.global.axisDirection}
  /// The direction in which the children are laid out.
  ///
  /// For example, if the [axisDirection] is [AxisDirection.down], each child
  /// will be laid out below the next, vertically.
  /// {@endtemplate}
  AxisDirection get axisDirection => _axisDirection;
  AxisDirection _axisDirection;
  set axisDirection(AxisDirection value) {
    if (_axisDirection == value) {
      return;
    }
    _axisDirection = value;
    markNeedsLayout();
  }

  /// The axis (horizontal or vertical) corresponding to the current
  /// [axisDirection].
  Axis get mainAxis => axisDirectionToAxis(_axisDirection);

  /// The direction in which the columns are ordered if the [mainAxis] is
  /// [Axis.vertical].
  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) {
      return;
    }
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! StaggeredGridParentData)
      child.parentData = StaggeredGridParentData();
  }

  StaggeredGridParentData _getParentData(RenderBox child) {
    return child.parentData as StaggeredGridParentData;
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      _computeIntrinsicWidth(height);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _computeIntrinsicWidth(height);

  double _computeIntrinsicWidth(double height) => 0;

  @override
  double computeMinIntrinsicHeight(double width) =>
      _computeIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _computeIntrinsicHeight(width);

  double _computeIntrinsicHeight(double width) => 0;

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  bool _hasVisualOverflow = false;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final size = _computeSize(
      constraints: constraints,
      layoutChild: _dryLayoutChild,
    );
    return constraints.constrain(size);
  }

  Size _computeSize({
    required BoxConstraints constraints,
    required _ChildLayouter layoutChild,
  }) {
    final crossAxisExtent = mainAxis == Axis.vertical
        ? constraints.maxWidth
        : constraints.maxHeight;
    final crossAxisCount =
        delegate.getCrossAxisCount(crossAxisExtent, crossAxisSpacing);
    final stride = (crossAxisExtent + crossAxisSpacing) / crossAxisCount;

    int computeCrossAxisCellCount(
      StaggeredGridParentData childParentData,
      int crossAxisCount,
    ) {
      return math.min(
        childParentData.crossAxisCellCount ?? 1,
        crossAxisCount,
      );
    }

    final offsets = List.filled(crossAxisCount, 0.0);
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = _getParentData(child);
      final crossAxisCellCount = computeCrossAxisCellCount(
        childParentData,
        crossAxisCount,
      );
      final crossAxisExtent = stride * crossAxisCellCount - crossAxisSpacing;
      final shouldFitContent = childParentData.mainAxisExtent == null &&
          childParentData.mainAxisCellCount == null;
      double mainAxisExtent = 0;
      if (shouldFitContent) {
        final childConstraints = mainAxis == Axis.vertical
            ? BoxConstraints.tightFor(width: crossAxisExtent)
            : BoxConstraints.tightFor(height: crossAxisExtent);
        layoutChild(child, childConstraints, parentUsesSize: true);
        final childSize = child.size;
        mainAxisExtent =
            mainAxis == Axis.vertical ? childSize.height : childSize.width;
      } else {
        final mainAxisCellCount = childParentData.mainAxisCellCount ?? 1;
        final mainAxisFixedExtent = childParentData.mainAxisExtent;
        mainAxisExtent =
            mainAxisFixedExtent ?? stride * mainAxisCellCount - mainAxisSpacing;

        // We set the real mainAxisExtent in case we need it if the axis direction
        // is reversed.
        childParentData._realMainAxisExtent = mainAxisExtent;

        final childSize = mainAxis == Axis.vertical
            ? Size(crossAxisExtent, mainAxisExtent)
            : Size(mainAxisExtent, crossAxisExtent);
        final childConstraints = BoxConstraints.tight(childSize);
        layoutChild(child, childConstraints);
      }

      final origin = _findBestCandidate(offsets, crossAxisCellCount);
      final mainAxisOffset = origin.mainAxisOffset;
      final crossAxisOffset = origin.crossAxisIndex * stride;
      final offset = mainAxis == Axis.vertical
          ? Offset(crossAxisOffset, mainAxisOffset)
          : Offset(mainAxisOffset, crossAxisOffset);

      childParentData.offset = offset;

      // Don't forget to update the offsets.
      final nextTileOffset = mainAxisOffset + mainAxisExtent + mainAxisSpacing;
      for (int i = 0; i < crossAxisCellCount; i++) {
        offsets[origin.crossAxisIndex + i] = nextTileOffset;
      }

      child = childAfter(child);
    }

    final mainAxisExtent = offsets.reduce(math.max) - mainAxisSpacing;
    if (axisDirectionIsReversed(axisDirection)) {
      // If the axis direction is reversed, we need to reverse the main axis
      // offsets.
      child = firstChild;
      while (child != null) {
        final childParentData = _getParentData(child);
        final offset = childParentData.offset;
        final crossAxisOffset = offset.getCrossAxisOffset(mainAxis);
        final mainAxisOffset = mainAxisExtent -
            offset.getMainAxisOffset(mainAxis) -
            childParentData._realMainAxisExtent!;
        final newOffset = mainAxis == Axis.vertical
            ? Offset(crossAxisOffset, mainAxisOffset)
            : Offset(mainAxisOffset, crossAxisOffset);
        childParentData.offset = newOffset;
        child = childAfter(child);
      }
    }

    if (mainAxis == Axis.vertical && textDirection == TextDirection.rtl) {
      // If the direction is vertical && the text direction is right-to-left, we
      // need to reverse the cross axis offsets.
      child = firstChild;
      while (child != null) {
        final childParentData = _getParentData(child);
        final crossAxisCellCount = computeCrossAxisCellCount(
          childParentData,
          crossAxisCount,
        );
        final crossAxisCellExtent =
            stride * crossAxisCellCount - crossAxisSpacing;
        final offset = childParentData.offset;
        final crossAxisOffset =
            crossAxisExtent - offset.dx - crossAxisCellExtent;
        final mainAxisOffset = offset.dy;
        final newOffset = Offset(crossAxisOffset, mainAxisOffset);
        childParentData.offset = newOffset;
        child = childAfter(child);
      }
    }

    final size = mainAxis == Axis.vertical
        ? Size(crossAxisExtent, mainAxisExtent)
        : Size(mainAxisExtent, crossAxisExtent);
    return size;
  }

  @override
  void performLayout() {
    final requestedSize = _computeSize(
      constraints: constraints,
      layoutChild: _layoutChild,
    );
    size = constraints.constrain(requestedSize);
    _hasVisualOverflow = size != requestedSize;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_hasVisualOverflow) {
      context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        defaultPaint,
      );
    } else {
      defaultPaint(context, offset);
    }
  }
}

class _TileOrigin {
  const _TileOrigin(this.crossAxisIndex, this.mainAxisOffset);
  final int crossAxisIndex;
  final double mainAxisOffset;
}

_TileOrigin _findBestCandidate(List<double> offsets, int crossAxisCount) {
  final length = offsets.length;
  _TileOrigin bestCandidate = const _TileOrigin(0, double.infinity);
  for (int i = 0; i < length; i++) {
    final offset = offsets[i];
    if (_lessOrNearEqual(bestCandidate.mainAxisOffset, offset)) {
      // The potential candidate is already higher than the current best.
      continue;
    }

    int start = 0;
    int span = 0;
    for (int j = 0;
        span < crossAxisCount &&
            j < length &&
            length - j >= crossAxisCount - span;
        j++) {
      if (_lessOrNearEqual(offsets[j], offset)) {
        span++;
        if (span == crossAxisCount) {
          bestCandidate = _TileOrigin(start, offset);
        }
      } else {
        start = j + 1;
        span = 0;
      }
    }
  }
  return bestCandidate;
}

typedef _ChildLayouter = void Function(
  RenderBox child,
  BoxConstraints constraints, {
  bool parentUsesSize,
});

void _dryLayoutChild(
  RenderBox child,
  BoxConstraints constraints, {
  bool parentUsesSize = false,
}) {
  child.getDryLayout(constraints);
}

void _layoutChild(
  RenderBox child,
  BoxConstraints constraints, {
  bool parentUsesSize = false,
}) {
  child.layout(constraints, parentUsesSize: parentUsesSize);
}

bool _lessOrNearEqual(double a, double b) {
  return a < b || (a - b).abs() < precisionErrorTolerance;
}

extension on Offset {
  double getCrossAxisOffset(Axis direction) {
    return direction == Axis.vertical ? dx : dy;
  }

  double getMainAxisOffset(Axis direction) {
    return direction == Axis.vertical ? dy : dx;
  }
}
