import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/src/foundation/extensions.dart';
import 'package:flutter_staggered_grid_view/src/rendering/sliver_simple_grid_delegate.dart';

/// Parent data structure used by [RenderSliverMasonryGrid].
class SliverMasonryGridParentData extends SliverMultiBoxAdaptorParentData {
  /// The index of the child in the non-scrolling axis.
  int? crossAxisIndex;

  /// The last extent for this child before it was garbage.
  /// This is used to retrieve the last offset of this child and prevent
  /// mis-placing issues.
  double? lastMainAxisExtent;

  @override
  String toString() => 'crossAxisIndex=$crossAxisIndex; ${super.toString()}';
}

/// A sliver that places multiple box children in a two dimensional arrangement.
///
/// [RenderSliverMasonryGrid] places each child the nearest as possible at the
/// start of the main axis and then at the start of the cross axis.
/// For example, in a vertical list, with left-to-right text direction, a child
/// will be placed as close as possible at the top of the grid, and then as
/// close as possible to the left side of the grid.
///
/// The [gridDelegate] determines how many children can be placed in the cross
/// axis.
class RenderSliverMasonryGrid extends RenderSliverMultiBoxAdaptor {
  /// Creates a sliver that places its children in a Masonry layout.
  ///
  /// The [mainAxisSpacing] and [crossAxisSpacing] arguments must be greater
  /// than zero.
  RenderSliverMasonryGrid({
    required RenderSliverBoxChildManager childManager,
    required SliverSimpleGridDelegate gridDelegate,
    required double mainAxisSpacing,
    required double crossAxisSpacing,
  })  : assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        _gridDelegate = gridDelegate,
        _mainAxisSpacing = mainAxisSpacing,
        _crossAxisSpacing = crossAxisSpacing,
        super(childManager: childManager);

  /// {@template fsgv.global.gridDelegate}
  /// The delegate that controls the size and position of the children.
  /// {@endtemplate}
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

  /// {@template fsgv.global.mainAxisSpacing}
  /// The number of pixels between each child along the main axis.
  /// {@endtemplate}
  double get mainAxisSpacing => _mainAxisSpacing;
  double _mainAxisSpacing;
  set mainAxisSpacing(double value) {
    if (_mainAxisSpacing == value) {
      return;
    }
    _mainAxisSpacing = value;
    markNeedsLayout();
  }

  /// {@template fsgv.global.crossAxisSpacing}
  /// The number of pixels between each child along the cross axis.
  /// {@endtemplate}
  double get crossAxisSpacing => _crossAxisSpacing;
  double _crossAxisSpacing;
  set crossAxisSpacing(double value) {
    if (_crossAxisSpacing == value) {
      return;
    }
    _crossAxisSpacing = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverMasonryGridParentData)
      child.parentData = SliverMasonryGridParentData();
  }

  SliverMasonryGridParentData _getParentData(RenderObject child) {
    return child.parentData as SliverMasonryGridParentData;
  }

  double _stride = 0;
  int Function(int) _getCrossAxisIndex = (int index) => index;

  @override
  double childCrossAxisPosition(RenderBox child) {
    final crossAxisIndex = _childCrossAxisIndex(child)!;
    return _getCrossAxisIndex(crossAxisIndex) * _stride;
  }

  int? _childCrossAxisIndex(RenderBox child) {
    return _getParentData(child).crossAxisIndex;
  }

  /// Contains the cross axis indexes of all children before the current
  /// firstChild.
  final _previousCrossAxisIndexes = <int>[];

  /// Contains the main axis extents of all children before the current
  /// firstChild.
  /// We have to keep track of these because the size may have changed since,
  /// and we don't want to screw up the layout.
  final _previousMainAxisExtents = <double>[];

  @override
  bool addInitialChild({int index = 0, double layoutOffset = 0.0}) {
    final hasFirstChild = super.addInitialChild(
      index: index,
      layoutOffset: layoutOffset,
    );
    if (hasFirstChild) {
      final parentData = _getParentData(firstChild!);
      parentData.applyZero();
    }
    return hasFirstChild;
  }

  @override
  void collectGarbage(int leadingGarbage, int trailingGarbage) {
    int count = leadingGarbage;
    RenderBox? child = firstChild!;
    while (count > 0 && child != null) {
      final crossAxisIndex = _childCrossAxisIndex(child);
      if (crossAxisIndex != null) {
        _previousCrossAxisIndexes.add(crossAxisIndex);
        _previousMainAxisExtents.add(paintExtentOf(child));
      }
      child = childAfter(child);
      count -= 1;
    }
    super.collectGarbage(leadingGarbage, trailingGarbage);
  }

  int _lastFirstVisibleChildIndex = 0;

  @override
  RenderBox? insertAndLayoutLeadingChild(
    BoxConstraints childConstraints, {
    bool parentUsesSize = false,
  }) {
    final child = super.insertAndLayoutLeadingChild(
      childConstraints,
      parentUsesSize: parentUsesSize,
    );
    if (child != null) {
      final parentData = _getParentData(child);
      parentData.crossAxisIndex = _previousCrossAxisIndexes.isNotEmpty
          ? _previousCrossAxisIndexes.removeLast()
          : 0;
      parentData.lastMainAxisExtent = _previousMainAxisExtents.isNotEmpty
          ? _previousMainAxisExtents.removeLast()
          : 0;
    }

    return child;
  }

  int? _lastCrossAxisCount;

  @override
  void performLayout() {
    childManager.didStartLayout();
    childManager.setDidUnderflow(false);

    final crossAxisCount = _gridDelegate.getCrossAxisCount(
      constraints,
      crossAxisSpacing,
    );

    _getCrossAxisIndex = axisDirectionIsReversed(constraints.crossAxisDirection)
        ? (int index) => crossAxisCount - index - 1
        : (int index) => index;

    // The stride is the cross extent of a cell + crossAxisSpacing.
    _stride = (constraints.crossAxisExtent + crossAxisSpacing) / crossAxisCount;
    final childCrossAxisExtent = _stride - crossAxisSpacing;
    final childConstraints = constraints.asBoxConstraints(
      crossAxisExtent: childCrossAxisExtent,
    );

    final double scrollOffset =
        constraints.scrollOffset + constraints.cacheOrigin;

    assert(scrollOffset >= 0.0);
    final double remainingExtent = constraints.remainingCacheExtent;
    assert(remainingExtent >= 0.0);
    final double targetEndScrollOffset = scrollOffset + remainingExtent;
    int leadingGarbage = 0;
    int trailingGarbage = 0;
    bool reachedEnd = false;

    final scrollOffsets = List.filled(crossAxisCount, 0.0);

    double positionChild(RenderBox child) {
      // We always put the next child at the smallest index with the minimum
      // value.
      final crossAxisIndex = scrollOffsets.findSmallestIndexWithMinimumValue();
      final childParentData = _getParentData(child);
      childParentData.layoutOffset = scrollOffsets[crossAxisIndex];
      childParentData.crossAxisIndex = crossAxisIndex;
      scrollOffsets[crossAxisIndex] =
          childScrollOffset(child)! + paintExtentOf(child) + mainAxisSpacing;
      return scrollOffsets[crossAxisIndex];
    }

    // If the crossAxisCount changed, we need to relayout-everything and scroll
    // to the previous first visible item.
    if (_lastCrossAxisCount != null && _lastCrossAxisCount != crossAxisCount) {
      _previousCrossAxisIndexes.clear();
      _previousMainAxisExtents.clear();

      if (firstChild != null) {
        final firstIndex = indexOf(firstChild!);

        // We don't need to do this if the first element is already visible.
        if (firstIndex != 0) {
          final lastIndex = indexOf(lastChild!);
          collectGarbage(0, lastIndex - firstIndex + 1);
          // We need to make a scroll correction between the old firstChild offset
          // and the new one.
          // For that we need to recreate all children from 0 to
          // _lastFirstVisibleChildIndex in order to get the new main axis offset.
          // This is very expensive though.
          scrollOffsets.fillRange(0, crossAxisCount, 0);
          addInitialChild();
          RenderBox? child = firstChild;
          child!.layout(childConstraints, parentUsesSize: true);
          int index = indexOf(firstChild!);
          double newPositionOfLastFirstChild = 0;

          // This is not really in usable in debug with a lot of children.
          // Can we compute the new position with another way?

          while (child != null && index <= _lastFirstVisibleChildIndex) {
            // We always put the next child at the smallest index with the minimum
            // value.
            positionChild(child);
            newPositionOfLastFirstChild = childScrollOffset(child)!;
            child = insertAndLayoutChild(
              childConstraints,
              after: child,
              parentUsesSize: true,
            );
            index++;
          }

          final scrollOffsetCorrection =
              newPositionOfLastFirstChild - scrollOffset;
          if (scrollOffsetCorrection != 0) {
            geometry = SliverGeometry(
              scrollOffsetCorrection: scrollOffsetCorrection,
            );
            return;
          }
        }
      }
    }

    _lastCrossAxisCount = crossAxisCount;

    // This algorithm is a more generic one that the one used by the SliverList.

    // Make sure we have at least one child to start from.
    if (firstChild == null) {
      if (!addInitialChild()) {
        // There are no children.
        geometry = SliverGeometry.zero;
        childManager.didFinishLayout();
        return;
      }
    }

    // We have at least one child.

    // These variables track the range of children that we have laid out. Within
    // this range, the children have consecutive indices. Outside this range,
    // it's possible for a child to get removed without notice.
    RenderBox? leadingChildWithLayout, trailingChildWithLayout;

    RenderBox? earliestUsefulChild = firstChild;

    // A firstChild with null layout offset is likely a result of children
    // reordering.
    //
    // We rely on firstChild to have accurate layout offset. In the case of null
    // layout offset, we have to find the first child that has valid layout
    // offset.
    if (childScrollOffset(firstChild!) == null) {
      int leadingChildrenWithoutLayoutOffset = 0;
      while (earliestUsefulChild != null &&
          childScrollOffset(earliestUsefulChild) == null) {
        earliestUsefulChild = childAfter(earliestUsefulChild);
        leadingChildrenWithoutLayoutOffset += 1;
      }
      // We should be able to destroy children with null layout offset safely,
      // because they are likely outside of viewport
      collectGarbage(leadingChildrenWithoutLayoutOffset, 0);
      // If can not find a valid layout offset, start from the initial child.
      if (firstChild == null) {
        if (!addInitialChild()) {
          // There are no children.
          geometry = SliverGeometry.zero;
          childManager.didFinishLayout();
          return;
        }
      }
    }

    // We need to compute the scroll offset of the earliest chidren.
    // Each scroll offset should be less or equals to the scrollOffset.
    // For the moment the scroll offsets represents the target scroll offset of
    // the child before the firstChild.
    scrollOffsets.fillRange(0, crossAxisCount, double.infinity);

    // Computes the SliverMasonryGridParentData for the firstChild.
    SliverMasonryGridParentData computeFirstChildParentData() {
      // We already laid out this child once before, so we must have retain it
      // last extent and crossAxisIndex.
      final firstChildParentData = _getParentData(firstChild!);
      final mainAxisExtent =
          firstChildParentData.lastMainAxisExtent! + mainAxisSpacing;
      final crossAxisIndex = firstChildParentData.crossAxisIndex!;

      double offset = scrollOffsets[crossAxisIndex] - mainAxisExtent;

      // It's possible that we have offset is very close of other offsets, but
      // not exactly the same, due to precision errors. To avoid mis-placement,
      // we check if the offset is close to other offsets. If it's the case, we
      // change the offset with the other one.
      for (int i = 0; i < crossAxisCount; i++) {
        if (i == crossAxisIndex) {
          continue;
        }
        final otherOffset = scrollOffsets[i];
        if ((offset - otherOffset).abs() < precisionErrorTolerance) {
          offset = otherOffset;
          break;
        }
      }

      return SliverMasonryGridParentData()
        ..layoutOffset = offset
        ..crossAxisIndex = crossAxisIndex;
    }

    RenderBox? child = firstChild;

    // If a new child is inserted and does not have a valid crossAxisIndex, we
    // have to set it.
    if (child != null && indexOf(child) == 0) {
      final firstChildParentData = _getParentData(child);
      firstChildParentData.crossAxisIndex = 0;
    }

    // We populate our earliestScrollOffsets list.
    while (child != null && scrollOffsets.any((x) => x.isInfinite)) {
      final index = _childCrossAxisIndex(child);
      if (index != null) {
        final scrollOffset = childScrollOffset(child)!;
        // We only need to set the scroll offsets of the earliest children.
        if (scrollOffsets[index] == double.infinity) {
          scrollOffsets[index] = scrollOffset;
        }
      }
      child = childAfter(child);
    }

    // Find the first child that is visible in the viewport.
    earliestUsefulChild = firstChild;
    while (scrollOffsets.any((x) => x > scrollOffset)) {
      // We have to add children before the earliestUsefulChild.
      earliestUsefulChild = insertAndLayoutLeadingChild(
        childConstraints,
        parentUsesSize: true,
      );

      if (earliestUsefulChild == null) {
        // There are no more child before the current firstChild.
        final childParentData = _getParentData(firstChild!);
        childParentData.layoutOffset = 0;

        if (scrollOffset == 0) {
          // insertAndLayoutLeadingChild only lays out the children before
          // firstChild. In this case, nothing has been laid out. We have
          // to lay out firstChild manually.
          firstChild!.layout(childConstraints, parentUsesSize: true);
          earliestUsefulChild = firstChild;
          leadingChildWithLayout = earliestUsefulChild;
          trailingChildWithLayout ??= earliestUsefulChild;
          break;
        } else {
          // We ran out of children before reaching the scroll offset.
          // We must inform our parent that this sliver cannot fulfill
          // its contract and that we need a scroll offset correction.
          geometry = SliverGeometry(
            scrollOffsetCorrection: -scrollOffset,
          );
          return;
        }
      }

      final earliestScrollOffset = scrollOffsets.reduce(math.min);

      // firstChildScrollOffset may contain double precision error
      if (earliestScrollOffset < -precisionErrorTolerance) {
        // Let's assume there is no child before the first child. We will
        // correct it on the next layout if it is not.
        geometry = SliverGeometry(
          scrollOffsetCorrection: -earliestScrollOffset,
        );
        final childParentData = _getParentData(firstChild!);
        final compute = computeFirstChildParentData();
        childParentData.apply(compute);
        childParentData.layoutOffset = 0;
        return;
      }

      final firstChildParentData = computeFirstChildParentData();
      final childParentData = _getParentData(earliestUsefulChild);
      childParentData.apply(firstChildParentData);
      // Don't forget to update the earliestScrollOffsets.
      scrollOffsets[firstChildParentData.crossAxisIndex!] =
          firstChildParentData.layoutOffset!;
      assert(earliestUsefulChild == firstChild);
      leadingChildWithLayout = earliestUsefulChild;
      trailingChildWithLayout ??= earliestUsefulChild;
    }

    assert(childScrollOffset(firstChild!)! > -precisionErrorTolerance);

    // If the scroll offset is at zero, we should make sure we are
    // actually at the beginning of the list.
    if (scrollOffset < precisionErrorTolerance) {
      // We iterate from the firstChild in case the leading child has a 0
      // paint extent.
      while (indexOf(firstChild!) > 0) {
        final childParentData = _getParentData(firstChild!);
        // We correct one child at a time. If there are more children before
        // the earliestUsefulChild, we will correct it once the scroll offset
        // reaches zero again.
        earliestUsefulChild = insertAndLayoutLeadingChild(
          childConstraints,
          parentUsesSize: true,
        );
        assert(earliestUsefulChild != null);
        final firstChildParentData = computeFirstChildParentData();
        childParentData.apply(firstChildParentData);
        final firstChildScrollOffset = firstChildParentData.layoutOffset!;
        // We only need to correct if the leading child actually has a
        // paint extent.
        if (firstChildScrollOffset < -precisionErrorTolerance) {
          geometry = SliverGeometry(
            scrollOffsetCorrection: -firstChildScrollOffset,
          );
          return;
        }
      }
    }

    // At this point, earliestUsefulChild is the first child, and is a child
    // whose scrollOffset is at or before the scrollOffset, and
    // leadingChildWithLayout and trailingChildWithLayout are either null or
    // cover a range of render boxes that we have laid out with the first being
    // the same as earliestUsefulChild and the last being either at or after the
    // scroll offset.

    assert(earliestUsefulChild == firstChild);
    assert(childScrollOffset(earliestUsefulChild!)! <= scrollOffset);

    // Make sure we've laid out at least one child.
    if (leadingChildWithLayout == null) {
      earliestUsefulChild!.layout(childConstraints, parentUsesSize: true);
      leadingChildWithLayout = earliestUsefulChild;
      trailingChildWithLayout = earliestUsefulChild;
    }

    // Here, earliestUsefulChild is still the first child, it's got a
    // scrollOffset that is at or before our actual scrollOffset, and it has
    // been laid out, and is in fact our leadingChildWithLayout. It's possible
    // that some children beyond that one have also been laid out.
    final leadingScrollOffset = scrollOffsets.reduce(math.min);

    bool inLayoutRange = true;
    child = earliestUsefulChild;
    int index = indexOf(child!);

    // From now on, the scrollOffsets will be the next possible scroll offsets
    // for new children.
    // As earliestUsefulChild is already laid out, we start by updating the
    // scroll offsets for the next children.
    scrollOffsets[_childCrossAxisIndex(child)!] =
        childScrollOffset(child)! + paintExtentOf(child) + mainAxisSpacing;

    // We also make sure that any infinite scroll offset is set to 0 now.
    for (int i = 0; i < scrollOffsets.length; i++) {
      if (scrollOffsets[i] == double.infinity) {
        scrollOffsets[i] = 0.0;
      }
    }

    bool foundFirstVisibleChild = scrollOffsets
        .any((scrollOffset) => scrollOffset >= constraints.scrollOffset);
    _lastFirstVisibleChildIndex = indexOf(firstChild!);

    // Returns true if we advanced, false if we have no more children
    bool advance() {
      assert(child != null);
      if (child == trailingChildWithLayout) {
        inLayoutRange = false;
      }
      child = childAfter(child!);
      if (child == null) {
        inLayoutRange = false;
      }
      index += 1;
      if (!inLayoutRange) {
        if (child == null || indexOf(child!) != index) {
          // We are missing a child. Insert it (and lay it out) if possible.
          child = insertAndLayoutChild(
            childConstraints,
            after: trailingChildWithLayout,
            parentUsesSize: true,
          );
          if (child == null) {
            // We have run out of children.
            return false;
          }
        } else {
          // Lay out the child.
          child!.layout(childConstraints, parentUsesSize: true);
        }
        trailingChildWithLayout = child;
      }
      assert(child != null);
      positionChild(child!);
      if (!foundFirstVisibleChild &&
          scrollOffsets.any(
            (scrollOffset) => scrollOffset >= constraints.scrollOffset,
          )) {
        foundFirstVisibleChild = true;
        _lastFirstVisibleChildIndex = indexOf(child!);
      }
      assert(indexOf(child!) == index);
      return true;
    }

    // Find the first child that ends after the scroll offset.
    while (scrollOffsets
        .every((offset) => offset - mainAxisSpacing < scrollOffset)) {
      leadingGarbage += 1;
      final tag = !advance();
      if (lastChild == trailingChildWithLayout) {
        // trigger the last, but this call the last few children not collectGarbage
        return;
      }
      if (tag) {
        assert(leadingGarbage == childCount);
        assert(child == null);
        // we want to make sure we keep the last child around so we know the end scroll offset
        collectGarbage(leadingGarbage - 1, 0);
        assert(firstChild == lastChild);
        final double extent = scrollOffsets.reduce(math.max) - mainAxisSpacing;
        geometry = SliverGeometry(
          scrollExtent: extent,
          maxPaintExtent: extent,
        );
        return;
      }
    }

    // Now find the first child that ends after our end.
    while (scrollOffsets.any(
      (offset) => offset - mainAxisSpacing < targetEndScrollOffset,
    )) {
      if (!advance()) {
        reachedEnd = true;
        break;
      }
    }

    // Finally count up all the remaining children and label them as garbage.
    if (child != null) {
      child = childAfter(child!);
      while (child != null) {
        trailingGarbage += 1;
        child = childAfter(child!);
      }
    }

    // At this point everything should be good to go, we just have to clean up
    // the garbage and report the geometry.
    collectGarbage(leadingGarbage, trailingGarbage);

    assert(debugAssertChildListIsNonEmptyAndContiguous());
    final endScrollOffset = scrollOffsets.reduce(math.max) - mainAxisSpacing;
    final double estimatedMaxScrollOffset;
    if (reachedEnd) {
      estimatedMaxScrollOffset = endScrollOffset;
    } else {
      estimatedMaxScrollOffset = childManager.estimateMaxScrollOffset(
        constraints,
        firstIndex: indexOf(firstChild!),
        lastIndex: indexOf(lastChild!),
        leadingScrollOffset: leadingScrollOffset,
        trailingScrollOffset: endScrollOffset,
      );
      assert(
        estimatedMaxScrollOffset >= endScrollOffset - leadingScrollOffset,
      );
    }
    final double paintExtent = calculatePaintOffset(
      constraints,
      from: leadingScrollOffset,
      to: endScrollOffset,
    );
    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: leadingScrollOffset,
      to: endScrollOffset,
    );
    final double targetEndScrollOffsetForPaint =
        constraints.scrollOffset + constraints.remainingPaintExtent;
    geometry = SliverGeometry(
      scrollExtent: estimatedMaxScrollOffset,
      paintExtent: paintExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: estimatedMaxScrollOffset,
      // Conservative to avoid flickering away the clip during scroll.
      hasVisualOverflow: endScrollOffset > targetEndScrollOffsetForPaint ||
          constraints.scrollOffset > 0.0,
    );

    // We may have started the layout while scrolled to the end, which would not
    // expose a new child.
    if (estimatedMaxScrollOffset == endScrollOffset)
      childManager.setDidUnderflow(true);
    childManager.didFinishLayout();
  }
}

extension on SliverMasonryGridParentData {
  void applyZero() {
    layoutOffset = 0.0;
    crossAxisIndex = 0;
  }

  void apply(SliverMasonryGridParentData parentData) {
    layoutOffset = parentData.layoutOffset;
    crossAxisIndex = parentData.crossAxisIndex;
  }
}
