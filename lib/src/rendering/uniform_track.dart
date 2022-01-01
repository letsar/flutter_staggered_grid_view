// ignore_for_file: public_member_api_docs

import 'dart:math' as math;

import 'package:flutter/rendering.dart';

class UniformTrackParentData extends ContainerBoxParentData<RenderBox> {}

class RenderUniformTrack extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, UniformTrackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, UniformTrackParentData> {
  RenderUniformTrack({
    List<RenderBox>? children,
    double spacing = 0,
    required int division,
    required AxisDirection direction,
  })  : assert(spacing >= 0),
        assert(division > 0),
        _spacing = spacing,
        _direction = direction,
        _isHorizontal = axisDirectionToAxis(direction) == Axis.horizontal,
        _isDirectionReversed = axisDirectionIsReversed(direction),
        _division = division {
    addAll(children);
  }

  double get spacing => _spacing;
  double _spacing;
  set spacing(double value) {
    assert(value >= 0);
    if (_spacing == value) {
      return;
    }
    _spacing = value;
    markNeedsLayout();
  }

  AxisDirection get direction => _direction;
  AxisDirection _direction;
  set direction(AxisDirection value) {
    if (_direction == value) {
      return;
    }
    _direction = value;
    _isHorizontal = axisDirectionToAxis(value) == Axis.horizontal;
    _isDirectionReversed = axisDirectionIsReversed(value);
    markNeedsLayout();
  }

  bool _isHorizontal;
  bool _isDirectionReversed;

  int get division => _division;
  int _division;
  set division(int value) {
    assert(value > 0);
    if (_division == value) {
      return;
    }
    _division = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! UniformTrackParentData)
      child.parentData = UniformTrackParentData();
  }

  UniformTrackParentData _getParentData(RenderBox child) {
    return child.parentData as UniformTrackParentData;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeSize(constraints, ChildLayoutHelper.dryLayoutChild);
  }

  Size _computeSize(BoxConstraints constraints, ChildLayouter layoutChild) {
    final mainAxisExtent =
        _isHorizontal ? constraints.maxWidth : constraints.maxHeight;
    final childMainAxisExtent =
        ((mainAxisExtent + spacing) / division) - spacing;
    final childConstraints = _isHorizontal
        ? BoxConstraints.tightFor(width: childMainAxisExtent)
        : BoxConstraints.tightFor(height: childMainAxisExtent);
    RenderBox? child = firstChild;

    double getChildCrossAxisExtent(Size size) {
      return _isHorizontal ? size.height : size.width;
    }

    double maxChildCrossAxisExtent = 0;

    // First pass to get the maximum child cross axis extent.
    while (child != null) {
      final size = layoutChild(child, childConstraints);
      maxChildCrossAxisExtent = math.max(
        maxChildCrossAxisExtent,
        getChildCrossAxisExtent(size),
      );
      child = childAfter(child);
    }

    return size = constraints.constrain(
      _isHorizontal
          ? Size(mainAxisExtent, maxChildCrossAxisExtent)
          : Size(maxChildCrossAxisExtent, mainAxisExtent),
    );
  }

  @override
  void performLayout() {
    size = _computeSize(constraints, ChildLayoutHelper.layoutChild);
    final mainAxisExtent =
        _isHorizontal ? constraints.maxWidth : constraints.maxHeight;
    final childMainAxisExtent =
        ((mainAxisExtent + spacing) / division) - spacing;
    final maxChildCrossAxisExtent = _isHorizontal ? size.height : size.width;

    double getChildCrossAxisExtent(RenderBox child) {
      return _isHorizontal ? child.size.height : child.size.width;
    }

    // Second pass to position the children and relayout those who have not the
    // maximum cross axis extent.
    final secondPassChildConstraints = _isHorizontal
        ? BoxConstraints.tightFor(
            width: childMainAxisExtent,
            height: maxChildCrossAxisExtent,
          )
        : BoxConstraints.tightFor(
            height: childMainAxisExtent,
            width: maxChildCrossAxisExtent,
          );

    RenderBox? child = firstChild;
    final stride = childMainAxisExtent + spacing;
    int index = 0;

    double getMainAxisPosition(int index) {
      final effectiveIndex =
          _isDirectionReversed ? division - index - 1 : index;
      return effectiveIndex * stride;
    }

    while (child != null) {
      if (getChildCrossAxisExtent(child) != maxChildCrossAxisExtent) {
        child.layout(secondPassChildConstraints, parentUsesSize: true);
      }
      final childParentData = _getParentData(child);
      final childMainAxisPosition = getMainAxisPosition(index);
      childParentData.offset = _isHorizontal
          ? Offset(childMainAxisPosition, 0)
          : Offset(0, childMainAxisPosition);
      index++;
      child = childParentData.nextSibling;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
