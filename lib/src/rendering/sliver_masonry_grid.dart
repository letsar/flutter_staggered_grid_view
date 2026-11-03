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
/// so that scrolling back never moves a child. As a consequence, reaching a
/// child far from the start requires to lay out all the children before it
/// once, like [RenderSliverList] does.
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
    int? estimatedChildCount,
    MasonryMainAxisExtentBuilder? mainAxisExtentBuilder,
  })  : assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        _gridDelegate = gridDelegate,
        _mainAxisSpacing = mainAxisSpacing,
        _crossAxisSpacing = crossAxisSpacing,
        _estimatedChildCount = estimatedChildCount,
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

  /// The number of children, if known.
  ///
  /// It is set by [SliverMasonryGrid] from its delegate, and is used to forget
  /// the placement of the children which have been removed.
  int? get estimatedChildCount => _estimatedChildCount;
  int? _estimatedChildCount;
  set estimatedChildCount(int? value) {
    if (_estimatedChildCount == value) {
      return;
    }
    _estimatedChildCount = value;
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
  /// The extents of the children which have already been placed are kept, so
  /// the builder must always return the same extent for a given child. If the
  /// data changes, use a different key for the grid.
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
    final childCrossAxisExtent = _stride - crossAxisSpacing;
    final childConstraints = constraints.asBoxConstraints(
      crossAxisExtent: childCrossAxisExtent,
    );
    // The number of children, if known.
    int? childCount = estimatedChildCount;

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

    if (!_cache.isValidFor(
      crossAxisCount: crossAxisCount,
      childCrossAxisExtent: childCrossAxisExtent,
      mainAxisSpacing: mainAxisSpacing,
    )) {
      // Every child can be placed differently.
      saveAnchor();
      _cache.reset(
        crossAxisCount: crossAxisCount,
        childCrossAxisExtent: childCrossAxisExtent,
        mainAxisSpacing: mainAxisSpacing,
      );
    }

    bool reachedEnd;
    int firstIndex;
    int lastIndex;
    while (true) {
      reachedEnd = _extendCache(
        childConstraints,
        scrollOffset: scrollOffset,
        targetEndScrollOffset: targetEndScrollOffset,
        minLength: anchorIndex == null ? 0 : anchorIndex! + 1,
        childCount: childCount,
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
        childCount: childCount,
      );
      if (invalidChild == null) {
        break;
      }

      // The child does not have the extent it had when it was placed (or it
      // does not exist anymore). The children after it must be placed again.
      if (invalidChild.missing) {
        childCount =
            math.min(childCount ?? invalidChild.index, invalidChild.index);
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
  /// Returns true if there are no more children to place.
  bool _extendCache(
    BoxConstraints childConstraints, {
    required double scrollOffset,
    required double targetEndScrollOffset,
    required int minLength,
    required int? childCount,
  }) {
    // When the extents and the number of children are known, placing all the
    // children is cheap and gives the exact scroll extent.
    if (_mainAxisExtentBuilder != null && childCount != null) {
      targetEndScrollOffset = double.infinity;
    }

    while (_cache.length < minLength || !_cache.covers(targetEndScrollOffset)) {
      if (_mainAxisExtentBuilder != null) {
        final extent = _childExtent(_cache.length, childCount);
        if (extent == null) {
          return true;
        }
        _cache.add(extent);
        continue;
      }

      final child = _obtainChild(_cache.length, childConstraints);
      if (child == null) {
        return true;
      }
      _cache.add(paintExtentOf(child));

      // Children placed before the first visible one will not be needed, we
      // can release them now. We keep the last child in order to insert the
      // next one after it. While we are placing the children up to the anchor,
      // the scroll offset will be corrected, so none of them is needed.
      final firstIndex = _cache.length < minLength
          ? _cache.length
          : _cache.firstIndexEndingAtOrAfter(scrollOffset);
      int leadingGarbage = 0;
      RenderBox? garbage = firstChild;
      while (garbage != lastChild && indexOf(garbage!) < firstIndex) {
        leadingGarbage++;
        garbage = childAfter(garbage);
      }
      if (leadingGarbage > 0) {
        collectGarbage(leadingGarbage, 0);
      }
    }
    return false;
  }

  /// The main axis extent of the child at [index] given by
  /// [mainAxisExtentBuilder], or null if it is not known.
  double? _childExtent(int index, int? childCount) {
    if (childCount != null && index >= childCount) {
      return null;
    }
    return _mainAxisExtentBuilder?.call(index, _cache.childCrossAxisExtent);
  }

  /// The constraints of the child at [index].
  BoxConstraints _childConstraints(
    int index,
    BoxConstraints childConstraints,
    int? childCount,
  ) {
    final extent = _childExtent(index, childCount);
    if (extent == null) {
      return childConstraints;
    }
    return constraints.asBoxConstraints(
      minExtent: extent,
      maxExtent: extent,
      crossAxisExtent: _cache.childCrossAxisExtent,
    );
  }

  /// Returns the laid out child at [index], creating it after the last child
  /// if needed.
  ///
  /// Returns null if there is no child at [index].
  RenderBox? _obtainChild(int index, BoxConstraints childConstraints) {
    if (firstChild != null) {
      final firstIndex = indexOf(firstChild!);
      final lastIndex = indexOf(lastChild!);
      if (index == lastIndex + 1) {
        return insertAndLayoutChild(
          childConstraints,
          after: lastChild,
          parentUsesSize: true,
        );
      }
      if (index >= firstIndex && index <= lastIndex) {
        RenderBox child = lastChild!;
        while (indexOf(child) != index) {
          child = childBefore(child)!;
        }
        child.layout(childConstraints, parentUsesSize: true);
        return child;
      }
      // The child at index is not adjacent to the current children.
      collectGarbage(lastIndex - firstIndex + 1, 0);
    }

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
    required int? childCount,
  }) {
    if (firstChild != null) {
      final firstChildIndex = indexOf(firstChild!);
      final lastChildIndex = indexOf(lastChild!);
      if (firstIndex > lastIndex ||
          lastChildIndex < firstIndex ||
          firstChildIndex > lastIndex) {
        collectGarbage(lastChildIndex - firstChildIndex + 1, 0);
      } else {
        collectGarbage(
          math.max(0, firstIndex - firstChildIndex),
          math.max(0, lastChildIndex - lastIndex),
        );
      }
    }

    if (firstIndex > lastIndex) {
      return null;
    }

    if (firstChild == null) {
      if (!addInitialChild(index: firstIndex)) {
        return (index: firstIndex, missing: true);
      }
    }

    while (indexOf(firstChild!) > firstIndex) {
      final index = indexOf(firstChild!) - 1;
      if (insertAndLayoutLeadingChild(
            _childConstraints(index, childConstraints, childCount),
            parentUsesSize: true,
          ) ==
          null) {
        return (index: index, missing: true);
      }
    }

    while (indexOf(lastChild!) < lastIndex) {
      final index = indexOf(lastChild!) + 1;
      if (insertAndLayoutChild(
            _childConstraints(index, childConstraints, childCount),
            after: lastChild,
            parentUsesSize: true,
          ) ==
          null) {
        return (index: index, missing: true);
      }
    }

    RenderBox? child = firstChild;
    while (child != null) {
      final index = indexOf(child);
      child.layout(
        _childConstraints(index, childConstraints, childCount),
        parentUsesSize: true,
      );
      if ((paintExtentOf(child) - _cache.extentOf(index)).abs() >
          precisionErrorTolerance) {
        return (index: index, missing: false);
      }
      _getParentData(child)
        ..layoutOffset = _cache.startOf(index)
        ..crossAxisIndex = _cache.laneOf(index);
      child = childAfter(child);
    }

    return null;
  }
}
