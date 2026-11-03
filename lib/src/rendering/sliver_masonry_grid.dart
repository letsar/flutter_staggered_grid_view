import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/src/foundation/masonry_cache.dart';
import 'package:flutter_staggered_grid_view/src/rendering/sliver_simple_grid_delegate.dart';

/// Signature for a function that returns the main axis extent of the child at
/// [index] in a masonry grid, where each child is [crossAxisExtent] wide (for
/// a vertical grid).
///
/// Should return null if [index] is greater than the index of the last child.
typedef MasonryMainAxisExtentBuilder = double? Function(
  int index,
  double crossAxisExtent,
);

/// Parent data structure used by [RenderSliverMasonryGrid].
class SliverMasonryGridParentData extends SliverMultiBoxAdaptorParentData {
  /// The index of the child in the non-scrolling axis.
  int? crossAxisIndex;

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
///
/// The placement of a child depends on the extents of all the children before
/// it. The placement of every child laid out at least once is therefore kept,
/// so that scrolling back does not move the children. As a consequence,
/// reaching a child far from the start requires to lay out all the children
/// before it once, like [RenderSliverList] does.
///
/// When the extent of children which are not visible changes (because the
/// width of the grid changed, or because children were inserted or removed
/// before the visible ones), their placement is only checked again when they
/// are laid out. The first visible child then stays in place, but the others
/// can move.
class RenderSliverMasonryGrid extends RenderSliverMultiBoxAdaptor {
  /// Creates a sliver that places its children in a Masonry layout.
  ///
  /// The [mainAxisSpacing] and [crossAxisSpacing] arguments must not be
  /// negative.
  RenderSliverMasonryGrid({
    required RenderSliverBoxChildManager childManager,
    required SliverSimpleGridDelegate gridDelegate,
    required double mainAxisSpacing,
    required double crossAxisSpacing,
    int? itemCount,
    MasonryMainAxisExtentBuilder? mainAxisExtentBuilder,
  })  : assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        _gridDelegate = gridDelegate,
        _mainAxisSpacing = mainAxisSpacing,
        _crossAxisSpacing = crossAxisSpacing,
        _itemCount = itemCount,
        _mainAxisExtentBuilder = mainAxisExtentBuilder,
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

  /// The exact number of children, or null if it is not known.
  ///
  /// It is set by `SliverMasonryGrid` from its delegate, and is used to forget
  /// the placement of the children which have been removed.
  int? get itemCount => _itemCount;
  int? _itemCount;
  set itemCount(int? value) {
    if (_itemCount == value) {
      return;
    }
    _itemCount = value;
    if (value != null) {
      _cache.truncate(value);
    }
    markNeedsLayout();
  }

  /// {@template fsgv.masonry.mainAxisExtentBuilder}
  /// Returns the main axis extent of each child, if known before building it.
  ///
  /// When provided, the children are placed without being built, which makes
  /// jumping far in the grid or changing the number of columns much faster.
  /// Each child is forced to have the returned extent.
  ///
  /// Should return null if the index is greater than the index of the last
  /// child.
  ///
  /// The number of children given by the delegate prevails: the builder is not
  /// called for indexes after it.
  ///
  /// The extents of the children which have already been placed are kept, and
  /// are only checked again when the children are laid out. A function created
  /// in each build makes the grid lay out again, which is cheap.
  /// {@endtemplate}
  MasonryMainAxisExtentBuilder? get mainAxisExtentBuilder =>
      _mainAxisExtentBuilder;
  MasonryMainAxisExtentBuilder? _mainAxisExtentBuilder;
  set mainAxisExtentBuilder(MasonryMainAxisExtentBuilder? value) {
    if (_mainAxisExtentBuilder == value) {
      return;
    }
    _mainAxisExtentBuilder = value;
    markNeedsLayout();
  }

  final MasonryCache _cache = MasonryCache();

  /// Whether the extents of the children are checked against the cache during
  /// the current layout.
  bool _checkExtents = true;

  /// The cross axis extent of the children during the last layout.
  double _childCrossAxisExtent = 0;

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverMasonryGridParentData) {
      child.parentData = SliverMasonryGridParentData();
    }
  }

  SliverMasonryGridParentData _getParentData(RenderObject child) {
    return child.parentData as SliverMasonryGridParentData;
  }

  double _stride = 0;
  int Function(int) _getCrossAxisIndex = (int index) => index;

  @override
  double childCrossAxisPosition(RenderBox child) {
    final crossAxisIndex = _getParentData(child).crossAxisIndex!;
    return _getCrossAxisIndex(crossAxisIndex) * _stride;
  }

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
    final childCrossAxisExtent = math.max(0.0, _stride - crossAxisSpacing);
    final childConstraints = constraints.asBoxConstraints(
      crossAxisExtent: childCrossAxisExtent,
    );
    // The number of children, if known.
    int? knownItemCount = itemCount;

    final double scrollOffset =
        constraints.scrollOffset + constraints.cacheOrigin;
    assert(scrollOffset >= 0.0);
    final double remainingExtent = constraints.remainingCacheExtent;
    assert(remainingExtent >= 0.0);
    final double targetEndScrollOffset = scrollOffset + remainingExtent;

    // The first child visible in the viewport. If the placement of the children
    // before it changes, we correct the scroll offset so that it does not move
    // on screen.
    int? anchorIndex;
    double anchorOffset = 0;
    void saveAnchor() {
      if (constraints.scrollOffset <= 0 || _cache.length == 0) {
        return;
      }
      final index = _cache.firstIndexEndingAtOrAfter(constraints.scrollOffset);
      if (index < _cache.length) {
        anchorIndex = index;
        anchorOffset = _cache.startOf(index);
      }
    }

    // When only the cross axis extent changes, the children which are laid out
    // again are checked against their previous placement, and the cache is
    // truncated at the first one which changed. This keeps the state of the
    // children. When the extents are given by mainAxisExtentBuilder, placing
    // every child again is cheap and exact.
    final crossAxisExtentChanged =
        _childCrossAxisExtent != childCrossAxisExtent;
    _childCrossAxisExtent = childCrossAxisExtent;
    final cacheReset = !_cache.isValidFor(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
        ) ||
        (crossAxisExtentChanged && _mainAxisExtentBuilder != null);
    if (cacheReset) {
      // Every child can be placed differently.
      saveAnchor();
      _cache.reset(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
      );
    }

    bool reachedEnd;
    int firstIndex;
    int lastIndex;
    // Each iteration places again the children after an invalid one, which
    // then becomes valid. Many iterations means a child which changes its
    // extent at each layout: we stop checking the extents to avoid an infinite
    // loop.
    int iterations = 0;
    while (true) {
      assert(
        iterations < 1000,
        'The masonry grid could not place its children: a child changes its '
        'extent at each layout.',
      );
      _checkExtents = iterations++ < 1000;

      // The children which are alive are checked first, so that none of them
      // is released because of an outdated placement.
      final invalidIndex = _firstInvalidChild(childConstraints, knownItemCount);
      if (invalidIndex != null) {
        if (anchorIndex == null) {
          saveAnchor();
        }
        _cache.truncate(invalidIndex);
      }

      reachedEnd = _extendCache(
        childConstraints,
        scrollOffset: scrollOffset,
        targetEndScrollOffset: targetEndScrollOffset,
        minLength: anchorIndex == null ? 0 : anchorIndex! + 1,
        release: cacheReset
            ? _Release.beforeMinLength
            : anchorIndex != null
                ? _Release.none
                : _Release.beforeScrollOffset,
        itemCount: knownItemCount,
      );

      // If the anchor moved, the visible children will change after the
      // correction, there is no need to lay them out now.
      if (anchorIndex != null && anchorIndex! < _cache.length) {
        // We cannot scroll before the start of the grid.
        final scrollOffsetCorrection = math.max(
          _cache.startOf(anchorIndex!) - anchorOffset,
          -constraints.scrollOffset,
        );
        if (scrollOffsetCorrection.abs() > precisionErrorTolerance) {
          geometry = SliverGeometry(
            scrollOffsetCorrection: scrollOffsetCorrection,
          );
          childManager.didFinishLayout();
          return;
        }
      }

      firstIndex = _cache.firstIndexEndingAtOrAfter(scrollOffset);
      lastIndex = _cache.firstIndexStartingAtOrAfter(targetEndScrollOffset) - 1;

      final invalidChild = _layoutChildren(
        childConstraints,
        firstIndex: firstIndex,
        lastIndex: lastIndex,
        itemCount: knownItemCount,
      );
      if (invalidChild == null) {
        break;
      }

      // The child does not have the extent it had when it was placed (or it
      // does not exist anymore). The children after it must be placed again.
      if (invalidChild.missing) {
        knownItemCount =
            math.min(knownItemCount ?? invalidChild.index, invalidChild.index);
      }
      if (anchorIndex == null) {
        saveAnchor();
      }
      _cache.truncate(invalidChild.index);
    }

    final double endScrollOffset = _cache.extent;
    final double estimatedMaxScrollOffset;
    if (reachedEnd || _cache.length == 0) {
      estimatedMaxScrollOffset = endScrollOffset;
    } else {
      estimatedMaxScrollOffset = math.max(
        endScrollOffset,
        childManager.estimateMaxScrollOffset(
          constraints,
          firstIndex: 0,
          lastIndex: _cache.length - 1,
          leadingScrollOffset: 0,
          trailingScrollOffset: endScrollOffset,
        ),
      );
    }

    final double leadingScrollOffset;
    final double trailingScrollOffset;
    if (firstChild == null) {
      leadingScrollOffset = trailingScrollOffset = endScrollOffset;
    } else {
      leadingScrollOffset = _cache.startOf(firstIndex);
      trailingScrollOffset = math.min(endScrollOffset, targetEndScrollOffset);
    }

    final double paintExtent = calculatePaintOffset(
      constraints,
      from: leadingScrollOffset,
      to: trailingScrollOffset,
    );
    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: leadingScrollOffset,
      to: trailingScrollOffset,
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
    if (estimatedMaxScrollOffset == endScrollOffset) {
      childManager.setDidUnderflow(true);
    }
    childManager.didFinishLayout();
  }

  /// Places new children in the cache until every child which can be visible
  /// between [scrollOffset] and [targetEndScrollOffset] is cached, and at least
  /// [minLength] children are cached.
  ///
  /// The children which are not needed anymore are released according to
  /// [release].
  ///
  /// Returns true if there are no more children to place.
  bool _extendCache(
    BoxConstraints childConstraints, {
    required double scrollOffset,
    required double targetEndScrollOffset,
    required int minLength,
    required _Release release,
    required int? itemCount,
  }) {
    // When the extents and the number of children are known, placing all the
    // children is cheap and gives the exact scroll extent.
    if (_mainAxisExtentBuilder != null && itemCount != null) {
      targetEndScrollOffset = double.infinity;
    }

    // The child after the last placed one, if it is alive.
    RenderBox? next;
    while (_cache.length < minLength || !_cache.covers(targetEndScrollOffset)) {
      if (_mainAxisExtentBuilder != null) {
        final extent = _childExtent(_cache.length, itemCount);
        if (extent == null) {
          return true;
        }
        _cache.add(extent);
        continue;
      }

      final child = _obtainChild(
        _cache.length,
        childConstraints,
        next,
        scrollOffset: scrollOffset,
      );
      if (child == null) {
        return true;
      }
      _cache.add(paintExtentOf(child));
      next = childAfter(child);

      if (release == _Release.none) {
        continue;
      }
      // We keep the child we just placed in order to obtain the next one after
      // it.
      final firstIndex =
          release == _Release.beforeMinLength && _cache.length < minLength
              ? _cache.length
              : _cache.firstIndexEndingAtOrAfter(scrollOffset);
      int leadingGarbage = 0;
      RenderBox? garbage = firstChild;
      while (garbage != child && indexOf(garbage!) < firstIndex) {
        leadingGarbage++;
        garbage = childAfter(garbage);
      }
      if (leadingGarbage > 0) {
        collectGarbage(leadingGarbage, 0);
      }
    }
    return false;
  }

  /// Lays out the children which are alive and placed in the cache, and returns
  /// the index of the first one which does not have the extent it had when it
  /// was placed, or null if they are all valid.
  int? _firstInvalidChild(BoxConstraints childConstraints, int? itemCount) {
    if (!_checkExtents) {
      return null;
    }
    for (RenderBox? child = firstChild;
        child != null && indexOf(child) < _cache.length;
        child = childAfter(child)) {
      final index = indexOf(child);
      child.layout(
        _childConstraints(index, childConstraints, itemCount),
        parentUsesSize: true,
      );
      if ((paintExtentOf(child) - _cache.extentOf(index)).abs() >
          precisionErrorTolerance) {
        return index;
      }
    }
    return null;
  }

  /// The main axis extent of the child at [index] given by
  /// [mainAxisExtentBuilder], or null if it is not known.
  double? _childExtent(int index, int? itemCount) {
    if (itemCount != null && index >= itemCount) {
      return null;
    }
    final extent = _mainAxisExtentBuilder?.call(index, _childCrossAxisExtent);
    assert(
      extent == null || (extent.isFinite && extent >= 0),
      'mainAxisExtentBuilder returned $extent for the child at index $index, '
      'but extents must be finite and not negative.',
    );
    assert(
      extent != null || _mainAxisExtentBuilder == null || itemCount == null,
      'mainAxisExtentBuilder returned null for the child at index $index, but '
      'there are $itemCount children.',
    );
    return extent;
  }

  /// The constraints of the child at [index].
  BoxConstraints _childConstraints(
    int index,
    BoxConstraints childConstraints,
    int? itemCount,
  ) {
    final extent = _childExtent(index, itemCount);
    if (extent == null) {
      return childConstraints;
    }
    return constraints.asBoxConstraints(
      minExtent: extent,
      maxExtent: extent,
      crossAxisExtent: _childCrossAxisExtent,
    );
  }

  /// Returns the laid out child at [index], creating it after the last child
  /// if needed. [next] is the child expected at [index], if known.
  ///
  /// The children are created in order, so if the children between the last
  /// one and [index] are visible after [scrollOffset], they are created too.
  /// Otherwise, they are not needed and the current children are released.
  ///
  /// Returns null if there is no child at [index].
  RenderBox? _obtainChild(
    int index,
    BoxConstraints childConstraints,
    RenderBox? next, {
    required double scrollOffset,
  }) {
    if (next != null && indexOf(next) == index) {
      next.layout(childConstraints, parentUsesSize: true);
      return next;
    }
    // Children moved with keys can leave holes between the indexes of the
    // children, so we look for the last child before or at index.
    RenderBox? child = lastChild;
    while (child != null && indexOf(child) > index) {
      child = childBefore(child);
    }
    if (child != null && indexOf(child) == index) {
      child.layout(childConstraints, parentUsesSize: true);
      return child;
    }
    if (child != null &&
        (indexOf(child) == index - 1 ||
            indexOf(child) + 1 >=
                _cache.firstIndexEndingAtOrAfter(scrollOffset))) {
      while (indexOf(child!) < index) {
        child = insertAndLayoutChild(
          childConstraints,
          after: child,
          parentUsesSize: true,
        );
        if (child == null) {
          return null;
        }
      }
      return child;
    }

    // The child at index is not adjacent to the current children.
    collectGarbage(childCount, 0);
    if (!addInitialChild(index: index)) {
      return null;
    }
    firstChild!.layout(childConstraints, parentUsesSize: true);
    return firstChild;
  }

  /// Makes sure that the children from [firstIndex] to [lastIndex] are the only
  /// ones alive, lays them out and positions them from the cache.
  ///
  /// Returns the index of the first child which is not where the cache expects
  /// it to be, and whether it is because it does not exist, or null if every
  /// child is at its place.
  ({int index, bool missing})? _layoutChildren(
    BoxConstraints childConstraints, {
    required int firstIndex,
    required int lastIndex,
    required int? itemCount,
  }) {
    if (firstIndex > lastIndex) {
      if (firstChild != null) {
        collectGarbage(childCount, 0);
      }
      return null;
    }

    // Children moved with keys can leave holes between the indexes of the
    // children. We look for the first child in the range, and the last one
    // before it.
    RenderBox? first = firstChild;
    while (first != null && indexOf(first) < firstIndex) {
      first = childAfter(first);
    }
    if (first == null || indexOf(first) > firstIndex) {
      final previous = first == null ? lastChild : childBefore(first);
      if (previous != null && indexOf(previous) == firstIndex - 1) {
        first = insertAndLayoutChild(
          _childConstraints(firstIndex, childConstraints, itemCount),
          after: previous,
          parentUsesSize: true,
        );
        if (first == null) {
          return (index: firstIndex, missing: true);
        }
      } else {
        // The child at firstIndex can only be inserted before the first child,
        // so the children before it are released.
        if (previous != null) {
          int leadingGarbage = 0;
          for (RenderBox? child = firstChild;
              child != first;
              child = childAfter(child!)) {
            leadingGarbage++;
          }
          collectGarbage(leadingGarbage, 0);
        }
        if (firstChild == null) {
          if (!addInitialChild(index: firstIndex)) {
            return (index: firstIndex, missing: true);
          }
        }
        while (indexOf(firstChild!) > firstIndex) {
          final index = indexOf(firstChild!) - 1;
          if (insertAndLayoutLeadingChild(
                _childConstraints(index, childConstraints, itemCount),
                parentUsesSize: true,
              ) ==
              null) {
            return (index: index, missing: true);
          }
        }
        first = firstChild;
      }
    }

    // Lays out the children from firstIndex to lastIndex, creating the missing
    // ones.
    RenderBox child = first!;
    int index = firstIndex;
    while (true) {
      child.layout(
        _childConstraints(index, childConstraints, itemCount),
        parentUsesSize: true,
      );
      if (_checkExtents &&
          (paintExtentOf(child) - _cache.extentOf(index)).abs() >
              precisionErrorTolerance) {
        return (index: index, missing: false);
      }
      _getParentData(child)
        ..layoutOffset = _cache.startOf(index)
        ..crossAxisIndex = _cache.laneOf(index);

      if (index == lastIndex) {
        break;
      }
      index++;
      final next = childAfter(child);
      if (next != null && indexOf(next) == index) {
        child = next;
      } else {
        final inserted = insertAndLayoutChild(
          _childConstraints(index, childConstraints, itemCount),
          after: child,
          parentUsesSize: true,
        );
        if (inserted == null) {
          return (index: index, missing: true);
        }
        child = inserted;
      }
    }

    // The children outside the range are released only now: an invalid child
    // leads to a scroll correction which can bring them back.
    int leadingGarbage = 0;
    for (RenderBox? garbage = firstChild;
        garbage != first;
        garbage = childAfter(garbage!)) {
      leadingGarbage++;
    }
    int trailingGarbage = 0;
    for (RenderBox? garbage = lastChild;
        garbage != child;
        garbage = childBefore(garbage!)) {
      trailingGarbage++;
    }
    if (leadingGarbage > 0 || trailingGarbage > 0) {
      collectGarbage(leadingGarbage, trailingGarbage);
    }
    return null;
  }
}

/// Which children placed by [RenderSliverMasonryGrid] in its cache can be
/// released right away.
enum _Release {
  /// The children before the first visible one.
  beforeScrollOffset,

  /// The children before the anchor, when every child is placed again: the
  /// scroll offset will be corrected, so none of them is needed. Then the
  /// children before the first visible one.
  beforeMinLength,

  /// None, because the scroll offset may be corrected: we don't know yet which
  /// children will be visible.
  none,
}
