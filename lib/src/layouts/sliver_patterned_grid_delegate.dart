import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Controls the layout of a grid which layout a pattern over and over.
abstract class SliverPatternGridDelegate<T> extends SliverGridDelegate {
  /// Creates a [SliverPatternGridDelegate].
  const SliverPatternGridDelegate({
    required this.tiles,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
  })  : assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        tileCount = tiles.length;

  /// {@macro fsgv.global.mainAxisSpacing}
  final double mainAxisSpacing;

  /// {@macro fsgv.global.crossAxisSpacing}
  final double crossAxisSpacing;

  /// The tiles representing the pattern to be repeated.
  final List<T> tiles;

  /// The number of tiles in the pattern.
  final int tileCount;

  /// Returns the geometries of each tiles in the pattern.
  @protected
  List<SliverGridGeometry> getPattern(SliverConstraints constraints);

  @override
  _SliverPatternGridLayout getLayout(SliverConstraints constraints) {
    return _SliverPatternGridLayout(
      mainAxisSpacing: mainAxisSpacing,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
      tileRects: getPattern(constraints),
    );
  }

  @override
  bool shouldRelayout(SliverPatternGridDelegate oldDelegate) {
    return oldDelegate.tiles != tiles ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing;
  }
}

class _SliverPatternGridLayout extends SliverGridLayout {
  _SliverPatternGridLayout({
    required this.mainAxisSpacing,
    required this.tileRects,
    this.reverseCrossAxis = false,
  })  : tileCount = tileRects.length,
        patternMainAxisExtent =
            tileRects.last.trailingScrollOffset + mainAxisSpacing;

  /// Whether the children should be placed in the opposite order of increasing
  /// coordinates in the cross axis.
  ///
  /// For example, if the cross axis is horizontal, the children are placed from
  /// left to right when [reverseCrossAxis] is false and from right to left when
  /// [reverseCrossAxis] is true.
  ///
  /// Typically set to the return value of [axisDirectionIsReversed] applied to
  /// the [SliverConstraints.crossAxisDirection].
  final bool reverseCrossAxis;
  final double mainAxisSpacing;
  final List<SliverGridGeometry> tileRects;
  final int tileCount;
  final double patternMainAxisExtent;

  @override
  double computeMaxScrollOffset(int childCount) {
    final tileRect = tileRectAt(childCount);
    return (childCount ~/ tileCount) * patternMainAxisExtent +
        tileRect.trailingScrollOffset;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final startMainAxisOffset = (index ~/ tileCount) * patternMainAxisExtent;
    final rect = tileRectAt(index);
    final realRect = rect.translate(startMainAxisOffset);

    return realRect;
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    final patternCount = (scrollOffset ~/ patternMainAxisExtent);
    final mainAxisOffset = scrollOffset - patternCount * patternMainAxisExtent;
    for (int i = 0; i < tileCount; i++) {
      if (_isRectVisibleAtMainAxisOffset(tileRects[i], mainAxisOffset)) {
        return i + patternCount * tileCount;
      }
    }

    return 0;
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    final patternCount = (scrollOffset ~/ patternMainAxisExtent);

    final mainAxisOffset = scrollOffset - patternCount * patternMainAxisExtent;
    for (int i = tileCount - 1; i >= 0; i--) {
      if (_isRectVisibleAtMainAxisOffset(tileRects[i], mainAxisOffset)) {
        return i + patternCount * tileCount;
      }
    }

    return 0;
  }

  /// Gets the main axis offset of the tile at the given global [index].
  double mainAxisOffset(int index) {
    return tileRects[index % tileCount].scrollOffset;
  }

  bool _isRectVisibleAtMainAxisOffset(
    SliverGridGeometry rect,
    double mainAxisOffset,
  ) {
    return rect.scrollOffset <= mainAxisOffset &&
        rect.trailingScrollOffset >= (mainAxisOffset - mainAxisSpacing);
  }

  SliverGridGeometry tileRectAt(int index) {
    return tileRects[index % tileCount];
  }
}

extension on SliverGridGeometry {
  SliverGridGeometry translate(double translation) {
    return SliverGridGeometry(
      scrollOffset: scrollOffset + translation,
      crossAxisOffset: crossAxisOffset,
      mainAxisExtent: mainAxisExtent,
      crossAxisExtent: crossAxisExtent,
    );
  }
}
