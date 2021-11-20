import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// Parent data structure used by [RenderSliverMasonryGrid].
class SliverMasonryGridParentData extends SliverGridParentData {
  /// The index of the child in the non-scrolling axis.
  int? crossAxisIndex;

  double? lastMainAxisExtent;

  @override
  String toString() => 'crossAxisIndex=$crossAxisIndex; ${super.toString()}';
}

class RenderSliverMasonryGrid extends RenderSliverMultiBoxAdaptor {
  RenderSliverMasonryGrid({
    required RenderSliverBoxChildManager childManager,
    required int crossAxisCount,
    required double mainAxisSpacing,
    required double crossAxisSpacing,
  })  : assert(crossAxisCount > 0),
        assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        _crossAxisCount = crossAxisCount,
        _mainAxisSpacing = mainAxisSpacing,
        _crossAxisSpacing = crossAxisSpacing,
        super(childManager: childManager);

  int get crossAxisCount => _crossAxisCount;
  int _crossAxisCount;
  set crossAxisCount(int value) {
    if (_crossAxisCount == value) {
      return;
    }
    _crossAxisCount = value;
    // Everything changed, we need to recompute our layout entirely.
    _reset();
    markNeedsLayout();
  }

  double get mainAxisSpacing => _mainAxisSpacing;
  double _mainAxisSpacing;
  set mainAxisSpacing(double value) {
    if (_mainAxisSpacing == value) {
      return;
    }
    _mainAxisSpacing = value;
    markNeedsLayout();
  }

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

  SliverMasonryGridParentData getParentData(RenderObject child) {
    return child.parentData as SliverMasonryGridParentData;
  }

  @override
  double childCrossAxisPosition(RenderBox child) {
    return getParentData(child).crossAxisOffset!;
  }

  int? childCrossAxisIndex(RenderBox child) {
    return getParentData(child).crossAxisIndex;
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
      final parentData = getParentData(firstChild!);
      parentData.applyZero();
    }
    return hasFirstChild;
  }

  @override
  void collectGarbage(int leadingGarbage, int trailingGarbage) {
    int count = leadingGarbage;
    RenderBox? child = firstChild!;
    while (count > 0 && child != null) {
      final crossAxisIndex = childCrossAxisIndex(child);
      if (crossAxisIndex != null) {
        _previousCrossAxisIndexes.add(crossAxisIndex);
        _previousMainAxisExtents.add(paintExtentOf(child));
      }
      child = childAfter(child);
      count -= 1;
    }
    super.collectGarbage(leadingGarbage, trailingGarbage);
  }

  bool _needsReset = false;

  void _reset() {
    _previousCrossAxisIndexes.clear();
    _previousMainAxisExtents.clear();
    _needsReset = true;
  }

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
      final parentData = getParentData(child);
      parentData.crossAxisIndex = _previousCrossAxisIndexes.isNotEmpty
          ? _previousCrossAxisIndexes.removeLast()
          : 0;
      parentData.lastMainAxisExtent = _previousMainAxisExtents.isNotEmpty
          ? _previousMainAxisExtents.removeLast()
          : 0;
      print('RRL_X2: ${indexOf(firstChild!)}: $_previousCrossAxisIndexes');
    }

    return child;
  }

  @override
  void performLayout() {
    childManager.didStartLayout();
    childManager.setDidUnderflow(false);

    if (_needsReset) {
      if (firstChild != null) {
        final firstIndex = indexOf(firstChild!);
        final lastIndex = indexOf(lastChild!);
        collectGarbage(lastIndex - firstIndex + 1, 0);
      }
      _needsReset = false;
    }

    // The stride is the cross extent of a cell + crossAxisSpacing.
    final stride =
        (constraints.crossAxisExtent + crossAxisSpacing) / crossAxisCount;
    final childCrossAxisExtent = stride - crossAxisSpacing;
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

    // This algotithm is a more generic one that the one used by the SliverList.

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
      // print('zone A');
      int leadingChildrenWithoutLayoutOffset = 0;
      while (earliestUsefulChild != null &&
          childScrollOffset(earliestUsefulChild) == null) {
        earliestUsefulChild = childAfter(earliestUsefulChild);
        leadingChildrenWithoutLayoutOffset += 1;
      }
      // We should be able to destroy children with null layout offset safely,
      // because they are likely outside of viewport
      // print('collectGarbage 1');
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
    final scrollOffsets = List.generate(
      crossAxisCount,
      (index) => double.infinity,
    );

    // Computes the SliverMasonryGridParentData for the firstChild.
    SliverMasonryGridParentData computeFirstChildParentData() {
      // The current child is either at indexBefore or
      // smallestIndexWithMinimumValue.
      // If its scroll index at indexBefore is less than the minimum scroll
      // offset, we know that it cannot be at indexBefore.
      // But if we can't put it at smallestIndexWithMinimumValue
      // (because the scroll offset would be less than the origin), then we
      // suppose that there was a change and we ask to recompute everything.
      final firstChildParentData = getParentData(firstChild!);
      final mainAxisExtent =
          firstChildParentData.lastMainAxisExtent! + mainAxisSpacing;

      // The crossAxisIndex should already be set.
      final crossAxisIndex = firstChildParentData.crossAxisIndex!;
      print('RRL_po: [${indexOf(firstChild!)}]: $crossAxisIndex');

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
        ..crossAxisIndex = crossAxisIndex
        ..crossAxisOffset = crossAxisIndex * stride;
    }

    RenderBox? child = firstChild;

    // We populate our earliestScrollOffsets list.
    while (child != null && scrollOffsets.any((x) => x.isInfinite)) {
      final index = childCrossAxisIndex(child)!;
      final scrollOffset = childScrollOffset(child)!;
      // final pd = getParentData(child);
      // We only need to set the scroll offsets of the earliest children.
      if (scrollOffsets[index] == double.infinity) {
        scrollOffsets[index] = scrollOffset;
      }
      // print(
      //   'RRL xo child: [${pd.index}]: c:${pd.crossAxisIndex},o:${pd.layoutOffset} | $scrollOffsets',
      // );
      child = childAfter(child);
    }

    if (scrollOffsets.any((x) => x.isInfinite) ||
        scrollOffsets.any((x) => x == 0)) {
      print(
          'RRL_nn: $scrollOffsets, [${indexOf(firstChild!)},${indexOf(lastChild!)}]');
    }

    // Find the first child that is visible in the viewport.
    earliestUsefulChild = firstChild;
    while (scrollOffsets.any((x) => x > scrollOffset)) {
      // We have to add children before the earliestUsefulChild.
      // print('RRL_po $scrollOffsets, ${indexOf(firstChild!)}');
      earliestUsefulChild = insertAndLayoutLeadingChild(
        childConstraints,
        parentUsesSize: true,
      );

      if (earliestUsefulChild == null) {
        // There are no more child before the current firstChild.
        final childParentData = getParentData(firstChild!);
        // childParentData.applyZero();
        childParentData.layoutOffset = 0;

        print('RRL 1 apply zero to ${indexOf(firstChild!)}');

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
          print('RRL 1 scrollOffsetCorrection: $scrollOffset $scrollOffsets');

          geometry = SliverGeometry(
            scrollOffsetCorrection: -scrollOffset,
          );
          return;
        }
      }

      final earliestScrollOffset = scrollOffsets.reduce(math.min);

      // TODO may be we should ne test the firstChildScrollOffset, but the
      // mimimum scrollOffsets value.

      // firstChildScrollOffset may contain double precision error
      if (earliestScrollOffset < -precisionErrorTolerance) {
        // Let's assume there is no child before the first child. We will
        // correct it on the next layout if it is not.
        // TODO ERROR HERE
        print('RRL_4 scrollOffsetCorrection:$earliestScrollOffset');

        geometry = SliverGeometry(
          scrollOffsetCorrection: -earliestScrollOffset,
        );
        final childParentData = getParentData(firstChild!);
        final pd = childParentData;
        print(
          'RRL_4 before: [${pd.index}]: c:${pd.crossAxisIndex},o:${pd.layoutOffset} | $scrollOffsets',
        );
        final compute = computeFirstChildParentData();
        // childParentData.applyZero();
        childParentData.apply(compute);
        childParentData.layoutOffset = 0;
        print(
          'RRL_4 after: [${pd.index}]: c:${pd.crossAxisIndex},o:${pd.layoutOffset} | $scrollOffsets',
        );
        return;
      }

      final firstChildParentData = computeFirstChildParentData();
      final childParentData = getParentData(earliestUsefulChild);
      childParentData.apply(firstChildParentData);
      print('RRL 3 apply $childParentData => $scrollOffsets');
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
        final childParentData = getParentData(firstChild!);
        // print('RRL_2 index:${childParentData.index}');
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
          print('RRL_2 scrollOffsetCorrection');
          geometry = SliverGeometry(
            scrollOffsetCorrection: -firstChildScrollOffset,
          );
          return;
        }
      }
    }

    // TODO(romain): We should check if the firstChild at index 0 is at the
    // top left.

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

    // TODO

    // We maintain the scroll offsets of the next items.
    // The rule to place the next item is to place it the earliest as
    // possible (in both directions), the scroll direction being the most
    // important one.
    // For example in left-to-right text direction and top-to-bottom scroll
    // direction, we try to place the next item at the top-most as possible
    // and then at the left-most as possible.
    // final scrollOffsets = List.generate(crossAxisCount, (index) => 0.0);

    // From now on, the scrollOffsets will be the next possible scroll offsets
    // for new children.
    // As earliestUsefulChild is already laid out, we start by updating the
    // scroll offsets for the next children.

    // print('bf: $scrollOffsets');
    print('RRL indexOf: ${indexOf(child)}');
    scrollOffsets[childCrossAxisIndex(child)!] =
        childScrollOffset(child)! + paintExtentOf(child) + mainAxisSpacing;
    // print('af: $scrollOffsets');

    void logParentData(String tag, RenderBox? child) {
      if (child != null) {
        final pd = child.parentData as SliverMasonryGridParentData;
        print(
          '$tag: [${pd.index}]: c:${pd.crossAxisIndex},o:${pd.layoutOffset} | $scrollOffsets',
        );
      }
    }

    // print(
    //   'RRL mo child: [${pd.index}]: c:${pd.crossAxisIndex},o:${pd.layoutOffset} | $scrollOffsets',
    // );

    // We also make sure that any infinite scroll offset is set to 0 now.
    for (int i = 0; i < scrollOffsets.length; i++) {
      if (scrollOffsets[i] == double.infinity) {
        print('was infinite');
        scrollOffsets[i] = 0.0;
      }
    }

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
          print('insertAndLayoutChild 473');
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
      // We always put the next child at the smallest index with the minimum
      // value.

      final crossAxisIndex = scrollOffsets.findSmallestIndexWithMinimumValue();
      if (indexOf(child!) == 1) {
        print('RRL_po: [1]: $crossAxisIndex | $scrollOffsets');
      }

      final childParentData = getParentData(child!);

      childParentData.layoutOffset = scrollOffsets[crossAxisIndex];
      childParentData.crossAxisIndex = crossAxisIndex;
      childParentData.crossAxisOffset = crossAxisIndex * stride;
      scrollOffsets[crossAxisIndex] =
          childScrollOffset(child!)! + paintExtentOf(child!) + mainAxisSpacing;
      // logParentData('RRL_po', child);
      // print('RRL $scrollOffsets');
      assert(childParentData.index == index);
      return true;
    }

    // print('RRL scrollOffset: $scrollOffset');

    // Find the first child that ends after the scroll offset.
    while (scrollOffsets
        .every((offset) => offset - mainAxisSpacing < scrollOffset)) {
      leadingGarbage += 1;
      if (!advance()) {
        assert(leadingGarbage == childCount);
        assert(child == null);
        // we want to make sure we keep the last child around so we know the end scroll offset
        // print('collectGarbage 2');
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
    // print('RRL targetEndScrollOffset: $targetEndScrollOffset');
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
    // print('collectGarbage 3');
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
      // log('RRL firstIndex=${indexOf(firstChild!)}, lastIndex=${indexOf(lastChild!)}');
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

extension on List<double> {
  int findSmallestIndexWithMinimumValue() {
    int index = 0;
    for (int i = 1; i < length; i++) {
      if (this[i] < this[index]) {
        index = i;
      }
    }
    return index;
  }
}

extension on SliverMasonryGridParentData {
  void applyZero() {
    layoutOffset = 0.0;
    crossAxisOffset = 0.0;
    crossAxisIndex = 0;
  }

  void apply(SliverMasonryGridParentData parentData) {
    layoutOffset = parentData.layoutOffset;
    crossAxisOffset = parentData.crossAxisOffset;
    crossAxisIndex = parentData.crossAxisIndex;
  }
}

void log(Object message) {
  print(message);
}
