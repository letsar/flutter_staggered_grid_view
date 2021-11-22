import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

class StaggeredGridParentData extends ContainerBoxParentData<RenderBox> {
  int? crossAxisCellCount;

  num? mainAxisCellCount;

  double? mainAxisExtent;

  @override
  String toString() =>
      'crossAxisCellCount=$crossAxisCellCount; mainAxisCellCount=$mainAxisCellCount; mainAxisExtent=$mainAxisExtent';
}

class RenderStaggeredGrid extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, StaggeredGridParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, StaggeredGridParentData> {
  RenderStaggeredGrid({
    List<RenderBox>? children,
    required int crossAxisCount,
    required double mainAxisSpacing,
    required double crossAxisSpacing,
    required AxisDirection axisDirection,
    required TextDirection textDirection,
  })  : assert(crossAxisCount > 0),
        assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        _axisDirection = axisDirection,
        _textDirection = textDirection,
        _crossAxisCount = crossAxisCount,
        _mainAxisSpacing = mainAxisSpacing,
        _crossAxisSpacing = crossAxisSpacing {
    addAll(children);
  }

  int get crossAxisCount => _crossAxisCount;
  int _crossAxisCount;
  set crossAxisCount(int value) {
    if (_crossAxisCount == value) {
      return;
    }
    _crossAxisCount = value;
    markNeedsLayout();
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

  AxisDirection get axisDirection => _axisDirection;
  AxisDirection _axisDirection;
  set axisDirection(AxisDirection value) {
    if (_axisDirection == value) {
      return;
    }
    _axisDirection = value;
    markNeedsLayout();
  }

  Axis get mainAxis => axisDirectionToAxis(_axisDirection);

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
    final stride = (crossAxisExtent + crossAxisSpacing) / crossAxisCount;

    final offsets = List.filled(crossAxisCount, 0.0);
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = _getParentData(child);
      final crossAxisCellCount = childParentData.crossAxisCellCount ?? 1;
      final mainAxisCellCount = childParentData.mainAxisCellCount ?? 1;
      final mainAxisFixedExtent = childParentData.mainAxisExtent;

      assert(
        crossAxisCellCount <= crossAxisCount,
        'The `crossAxisCellCount` of a StaggeredGridTile is cannot be greater '
        'than the `crossAxisCount` of the StaggeredGrid.'
        '$crossAxisCellCount > $crossAxisCount',
      );
      final crossAxisExtent = stride * crossAxisCellCount - crossAxisSpacing;
      final mainAxisExtent =
          mainAxisFixedExtent ?? stride * mainAxisCellCount - mainAxisSpacing;

      // We set the real mainAxisExtent in case we need it if the axis direction
      // is reversed.
      childParentData.mainAxisExtent = mainAxisExtent;

      final childSize = mainAxis == Axis.vertical
          ? Size(crossAxisExtent, mainAxisExtent)
          : Size(mainAxisExtent, crossAxisExtent);
      final childConstraints = BoxConstraints.tight(childSize);
      layoutChild(child, childConstraints);

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
            childParentData.mainAxisExtent!;
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
        final crossAxisCellCount = childParentData.crossAxisCellCount ?? 1;
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
  BoxConstraints constraints,
);

void _dryLayoutChild(RenderBox child, BoxConstraints constraints) {
  child.getDryLayout(constraints);
}

void _layoutChild(RenderBox child, BoxConstraints constraints) {
  child.layout(constraints, parentUsesSize: false);
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
