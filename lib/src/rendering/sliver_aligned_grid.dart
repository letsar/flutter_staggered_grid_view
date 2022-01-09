import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/src/rendering/sliver_grid_list.dart';
import 'package:flutter_staggered_grid_view/src/rendering/sliver_simple_grid_delegate.dart';

/// A Sliver that layouts its children in a grid with tracks that can have
/// different main axis extents.
class RenderSliverAlignedGrid extends RenderSliverGridList {
  /// Creates a [RenderSliverAlignedGrid].
  RenderSliverAlignedGrid({
    required RenderSliverBoxChildManager childManager,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    required SliverSimpleGridDelegate gridDelegate,
  })  : _gridDelegate = gridDelegate,
        super(
          childManager: childManager,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        );

  /// {@macro fsgv.global.gridDelegate}
  SliverSimpleGridDelegate get gridDelegate => _gridDelegate;
  SliverSimpleGridDelegate _gridDelegate;
  set gridDelegate(SliverSimpleGridDelegate value) {
    if (_gridDelegate == value) {
      return;
    }

    if (value.runtimeType != _gridDelegate.runtimeType ||
        value.shouldRelayout(_gridDelegate)) {
      markNeedsLayout();
    }

    _gridDelegate = value;
  }

  int _crossAxisIndexOf(RenderBox child) {
    return indexOf(child) % _crossAxisCount;
  }

  int _trackIndexOf(RenderBox child) {
    return indexOf(child) ~/ _crossAxisCount;
  }

  int _crossAxisCount = 1;

  @override
  double mainAxisExtentOf(RenderBox child) {
    return paintExtentOf(child);
  }

  @override
  bool get useChildSize => true;

  @override
  void startLayout() {
    _crossAxisCount = _gridDelegate.getCrossAxisCount(
      constraints,
      crossAxisSpacing,
    );
  }

  @override
  BoxConstraints computeChildConstraints() {
    final childCrossAxisExtent =
        ((constraints.crossAxisExtent + crossAxisSpacing) / _crossAxisCount) -
            crossAxisSpacing;
    return constraints.asBoxConstraints(
      crossAxisExtent: childCrossAxisExtent,
    );
  }

  @override
  RenderBox layoutTrack(
    RenderBox leadingChild,
    double layoutOffset, {
    bool insertBefore = false,
  }) {
    final isDirectionReversed = axisDirectionIsReversed(
      constraints.crossAxisDirection,
    );
    final trackMainAxisExtent = _computeMaxMainAxisExtent(leadingChild);

    final crossAxisExtent = constraints.crossAxisExtent;
    final childCrossAxisExtent =
        ((crossAxisExtent + crossAxisSpacing) / _crossAxisCount) -
            crossAxisSpacing;
    final secondPassChildConstraints = constraints.asBoxConstraints(
      minExtent: trackMainAxisExtent,
      maxExtent: trackMainAxisExtent,
      crossAxisExtent: childCrossAxisExtent,
    );

    // Second pass to position the children and relayout those who have not the
    // maximum cross axis extent.
    final stride = childCrossAxisExtent + crossAxisSpacing;

    double getCrossAxisPosition(int crossAxisIndex) {
      final effectiveIndex = isDirectionReversed
          ? _crossAxisCount - crossAxisIndex - 1
          : crossAxisIndex;
      return effectiveIndex * stride;
    }

    final effectiveLayoutOffset = insertBefore
        ? layoutOffset - mainAxisSpacing - trackMainAxisExtent
        : layoutOffset;
    // print(
    //   'RRL layoutTrack from ${indexOf(leadingChild)} at $effectiveLayoutOffset, insertBefore: $insertBefore',
    // );

    final trailingChild = _visitTrack(leadingChild, (child) {
      if (paintExtentOf(child) != trackMainAxisExtent) {
        child.layout(secondPassChildConstraints, parentUsesSize: true);
      }
      final childParentData = getParentData(child);
      final crossAxisIndex = _crossAxisIndexOf(child);
      final childCrossAxisPosition = getCrossAxisPosition(crossAxisIndex);

      childParentData.layoutOffset = effectiveLayoutOffset;
      childParentData.crossAxisOffset = childCrossAxisPosition;
    });

    return trailingChild;
  }

  @override
  RenderBox? insertAndLayoutLeadingTrack(BoxConstraints constraints) {
    // We need to add a new child while the child's cross axis index is not 0.
    final firstChildLayoutOffset = childScrollOffset(firstChild!)!;
    final firstChildTrackIndex = _trackIndexOf(firstChild!);
    RenderBox? child = firstChild;
    do {
      child = insertAndLayoutLeadingChild(constraints, parentUsesSize: true);
    } while (child != null && _crossAxisIndexOf(child) != 0);
    if (child == null) {
      return null;
    }
    if (_trackIndexOf(child) == firstChildTrackIndex) {
      layoutTrack(child, firstChildLayoutOffset);
    } else {
      // This is a new track. The layout offset must be considered as the
      // endScrollOffset.
      layoutTrack(child, firstChildLayoutOffset, insertBefore: true);
    }
    return child;
  }

  double _computeMaxMainAxisExtent(RenderBox leadingChild) {
    final crossAxisExtent = constraints.crossAxisExtent;
    final childCrossAxisExtent =
        ((crossAxisExtent + crossAxisSpacing) / _crossAxisCount) -
            crossAxisSpacing;
    final childConstraints = constraints.asBoxConstraints(
      crossAxisExtent: childCrossAxisExtent,
    );

    double maxChildMainAxisExtent = 0;

    // First pass to get the maximum child cross axis extent.
    _visitTrack(leadingChild, (child) {
      child.layout(childConstraints, parentUsesSize: true);
      maxChildMainAxisExtent = math.max(
        maxChildMainAxisExtent,
        paintExtentOf(child),
      );
    });

    return maxChildMainAxisExtent;
  }

  RenderBox _visitTrack(
    RenderBox leadingChild,
    void Function(RenderBox) visitor,
  ) {
    final trackIndex = _trackIndexOf(leadingChild);
    final childConstraints = computeChildConstraints();
    RenderBox? child = leadingChild;
    RenderBox previousChild = leadingChild;
    while (child != null && _trackIndexOf(child) == trackIndex) {
      visitor(child);
      previousChild = child;
      child = childAfter(child);
      if (child == null || indexOf(child) != indexOf(previousChild) + 1) {
        child = insertAndLayoutChild(
          childConstraints,
          after: previousChild,
          parentUsesSize: true,
        );
      }
    }

    return previousChild;
  }
}
