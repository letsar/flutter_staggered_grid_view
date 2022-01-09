import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// A Sliver that layouts its children in a grid with tracks that can have
/// different main axis extents.
abstract class RenderSliverGridList extends RenderSliverMultiBoxAdaptor {
  /// Creates a [RenderSliverGridList].
  RenderSliverGridList({
    required RenderSliverBoxChildManager childManager,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
  })  : assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        _mainAxisSpacing = mainAxisSpacing,
        _crossAxisSpacing = crossAxisSpacing,
        super(childManager: childManager);

  /// {@macro fsgv.global.mainAxisSpacing}
  double get mainAxisSpacing => _mainAxisSpacing;
  double _mainAxisSpacing;
  set mainAxisSpacing(double value) {
    assert(value >= 0);
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

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverGridParentData) {
      child.parentData = SliverGridParentData();
    }
  }

  /// Returns the parent data of the given [child].
  @protected
  SliverGridParentData getParentData(RenderBox child) {
    return child.parentData as SliverGridParentData;
  }

  /// Indicates whether the layout needs to know the children sizes.
  @protected
  bool get useChildSize => false;

  /// Gets the main axis extent of the given [child].
  @protected
  double mainAxisExtentOf(RenderBox child);

  /// Computes the default constraints to pass to each child.
  @protected
  BoxConstraints computeChildConstraints();

  /// Fill the current track by adding new children as necessary or insert a new
  /// track before this one if necessary.
  @protected
  RenderBox? insertAndLayoutLeadingTrack(BoxConstraints constraints);

  /// Layouts the track with the given [leadingChild] and returns its trailing
  /// child.
  @protected
  RenderBox layoutTrack(RenderBox leadingChild, double layoutOffset);

  /// Called at the beginning of the performLayout method. This is a good place
  /// for subclasses to initialize field based on the constraints.
  @protected
  void startLayout();

  @override
  double childCrossAxisPosition(RenderBox child) {
    final childParentData = getParentData(child);
    return childParentData.crossAxisOffset!;
  }

  @override
  void performLayout() {
    childManager.didStartLayout();
    childManager.setDidUnderflow(false);
    startLayout();
    final scrollOffset = constraints.scrollOffset + constraints.cacheOrigin;
    assert(scrollOffset >= 0.0);
    final remainingExtent = constraints.remainingCacheExtent;
    assert(remainingExtent >= 0.0);
    final targetEndScrollOffset = scrollOffset + remainingExtent;
    final childConstraints = computeChildConstraints();
    int leadingGarbage = 0;
    int trailingGarbage = 0;
    bool reachedEnd = false;

    // This algorithm in principle is straight-forward: find the first child
    // that is before the given scrollOffset, keep its next sibling as
    // firstChild, creating more children at the top of the list if necessary,
    // then walk down the list updating and laying out each child and adding
    // more at the end if necessary until we have enough children to cover the
    // entire viewport.
    //
    // It is complicated by one minor issue, which is that any time you update
    // or create a child, it's possible that the some of the children that
    // haven't yet been laid out will be removed, leaving the list in an
    // inconsistent state, and requiring that missing nodes be recreated.
    //
    // To keep this mess tractable, this algorithm starts from what is currently
    // the first child, if any, and then walks up and/or down from there, so
    // that the nodes that might get removed are always at the edges of what has
    // already been laid out.

    // This algorithm is mainly inspired by the one in RenderSliverList.

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

    // Find the first track that is at or before the scrollOffset.
    earliestUsefulChild = firstChild;
    for (double earliestScrollOffset = childScrollOffset(earliestUsefulChild!)!;
        earliestScrollOffset > scrollOffset;
        earliestScrollOffset = childScrollOffset(earliestUsefulChild)!) {
      // We have to add children before the earliestUsefulChild.
      earliestUsefulChild = insertAndLayoutLeadingTrack(childConstraints);
      if (earliestUsefulChild == null) {
        final childParentData = getParentData(firstChild!);
        childParentData.layoutOffset = 0.0;

        if (scrollOffset == 0.0) {
          // insertAndLayoutLeadingChild only lays out the children before
          // firstChild. In this case, nothing has been laid out. We have
          // to lay out first track manually.
          final trailingChild = layoutTrack(firstChild!, 0);
          earliestUsefulChild = firstChild;
          leadingChildWithLayout = earliestUsefulChild;
          trailingChildWithLayout ??= trailingChild;
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

      final firstChildScrollOffset = earliestScrollOffset -
          mainAxisExtentOf(firstChild!) -
          mainAxisSpacing;
      // firstChildScrollOffset may contain double precision error
      if (firstChildScrollOffset < -precisionErrorTolerance) {
        // Let's assume there is no child before the first child. We will
        // correct it on the next layout if it is not.
        geometry = SliverGeometry(
          scrollOffsetCorrection: -firstChildScrollOffset,
        );
        final childParentData = getParentData(firstChild!);
        childParentData.layoutOffset = 0.0;
        return;
      }

      trailingChildWithLayout ??= layoutTrack(
        earliestUsefulChild,
        firstChildScrollOffset,
      );

      // final childParentData = getParentData(earliestUsefulChild);
      // childParentData.layoutOffset = firstChildScrollOffset;
      assert(earliestUsefulChild == firstChild);
      leadingChildWithLayout = earliestUsefulChild;
      // trailingChildWithLayout ??= earliestUsefulChild;
    }

    assert(childScrollOffset(firstChild!)! > -precisionErrorTolerance);

    // If the scroll offset is at zero, we should make sure we are
    // actually at the beginning of the list.
    if (scrollOffset < precisionErrorTolerance) {
      // We iterate from the firstChild in case the leading child has a 0 paint
      // extent.
      while (indexOf(firstChild!) > 0) {
        final earliestScrollOffset = childScrollOffset(firstChild!)!;
        // We correct one child at a time. If there are more children before
        // the earliestUsefulChild, we will correct it once the scroll offset
        // reaches zero again.
        earliestUsefulChild = insertAndLayoutLeadingTrack(childConstraints);
        assert(earliestUsefulChild != null);
        final firstChildScrollOffset = earliestScrollOffset -
            mainAxisExtentOf(firstChild!) -
            mainAxisSpacing;
        final childParentData = getParentData(firstChild!);
        childParentData.layoutOffset = 0.0;
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
      leadingChildWithLayout = earliestUsefulChild;
      trailingChildWithLayout = layoutTrack(
        earliestUsefulChild!,
        childScrollOffset(earliestUsefulChild)!,
      );
    }

    // Here, trailingChildWithLayout is the last child of the track, it's got a
    // scrollOffset that is at or before our actual scrollOffset. It's possible
    // that some children beyond that one have also been laid out.

    bool inLayoutRange = true;
    RenderBox? child = trailingChildWithLayout;
    int index = indexOf(child!);
    double endScrollOffset =
        childScrollOffset(child)! + mainAxisExtentOf(child);
    bool advance() {
      // Returns true if we advanced, false if we have no more children
      assert(child != null);
      if (child == trailingChildWithLayout) {
        inLayoutRange = false;
      }
      child = childAfter(child!);
      if (child == null) {
        inLayoutRange = false;
      }
      index++;
      if (!inLayoutRange) {
        if (child == null || indexOf(child!) != index) {
          // We are missing a child. Insert it (and lay it out) if possible.
          child = insertAndLayoutChild(
            childConstraints,
            after: trailingChildWithLayout,
            parentUsesSize: useChildSize,
          );
          if (child == null) {
            // We have run out of children.
            return false;
          }
        }

        child = layoutTrack(
          child!,
          endScrollOffset + mainAxisSpacing,
        );
        index = indexOf(child!);
        trailingChildWithLayout = child;
      }

      endScrollOffset = childScrollOffset(child!)! + mainAxisExtentOf(child!);
      return true;
    }

    // Find the first child that ends after the scroll offset.
    if (endScrollOffset < scrollOffset) {
      final firstLeadingGarbageIndex = indexOf(leadingChildWithLayout!);
      int lastLeadingGarbageIndex = firstLeadingGarbageIndex;

      while (endScrollOffset < scrollOffset) {
        lastLeadingGarbageIndex = indexOf(child!);
        if (!advance()) {
          assert(child == null);
          // we want to make sure we keep the last child around so we know the end scroll offset
          collectGarbage(childCount - 1, 0);
          final extent =
              childScrollOffset(lastChild!)! + mainAxisExtentOf(lastChild!);
          geometry = SliverGeometry(
            scrollExtent: extent,
            maxPaintExtent: extent,
          );
          return;
        }
      }
      leadingGarbage = (lastLeadingGarbageIndex - firstLeadingGarbageIndex) + 1;
    }

    // Now find the first child that ends after our end.
    while (endScrollOffset < targetEndScrollOffset) {
      if (!advance()) {
        reachedEnd = true;
        break;
      }
    }

    // Finally count up all the remaining children and label them as garbage.
    if (child != null) {
      // This child is the leading child of an hidden track
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
    final double estimatedMaxScrollOffset;
    if (reachedEnd) {
      estimatedMaxScrollOffset = endScrollOffset;
    } else {
      estimatedMaxScrollOffset = childManager.estimateMaxScrollOffset(
        constraints,
        firstIndex: indexOf(firstChild!),
        lastIndex: indexOf(lastChild!),
        leadingScrollOffset: childScrollOffset(firstChild!),
        trailingScrollOffset: endScrollOffset,
      );
      assert(
        estimatedMaxScrollOffset >=
            endScrollOffset - childScrollOffset(firstChild!)!,
      );
    }
    final paintExtent = calculatePaintOffset(
      constraints,
      from: childScrollOffset(firstChild!)!,
      to: endScrollOffset,
    );
    final cacheExtent = calculateCacheOffset(
      constraints,
      from: childScrollOffset(firstChild!)!,
      to: endScrollOffset,
    );
    final targetEndScrollOffsetForPaint =
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
