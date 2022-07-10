import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Represents the geometries of each tile of a pattern.
@immutable
class SliverPatternGridGeometries {
  /// Creates a [SliverPatternGridGeometries].
  const SliverPatternGridGeometries({
    required this.tiles,
    required this.bounds,
  }) : assert(tiles.length == bounds.length);

  /// The visible geometries of each tile.
  final List<SliverGridGeometry> tiles;

  /// The available space of each tile.
  final List<SliverGridGeometry> bounds;
}

/// Controls the layout of a grid which layout a pattern over and over.
abstract class SliverPatternGridDelegate<T> extends SliverGridDelegate {
  const SliverPatternGridDelegate._({
    required this.pattern,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.crossAxisCount,
    this.maxCrossAxisExtent,
  })  : assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        assert(crossAxisCount == null || crossAxisCount > 0),
        assert(maxCrossAxisExtent == null || maxCrossAxisExtent > 0),
        assert(crossAxisCount != null || maxCrossAxisExtent != null),
        tileCount = pattern.length;

  /// Creates a [SliverPatternGridDelegate] with a [crossAxisCount].
  const SliverPatternGridDelegate.count({
    required List<T> pattern,
    required int crossAxisCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
  }) : this._(
          pattern: pattern,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          crossAxisCount: crossAxisCount,
        );

  /// Creates a [SliverPatternGridDelegate] with a [maxCrossAxisExtent].
  const SliverPatternGridDelegate.extent({
    required List<T> pattern,
    required double maxCrossAxisExtent,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
  }) : this._(
          pattern: pattern,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          maxCrossAxisExtent: maxCrossAxisExtent,
        );

  /// {@macro fsgv.global.mainAxisSpacing}
  final double mainAxisSpacing;

  /// {@macro fsgv.global.crossAxisSpacing}
  final double crossAxisSpacing;

  /// The tiles representing the pattern to be repeated.
  final List<T> pattern;

  /// The number of tiles in the pattern.
  final int tileCount;

  /// {@macro fsgv.global.crossAxisCount}
  final int? crossAxisCount;

  /// {@macro fsgv.global.maxCrossAxisExtent}
  final double? maxCrossAxisExtent;

  /// Returns the geometries of each tiles in the pattern.
  @protected
  SliverPatternGridGeometries getGeometries(
    SliverConstraints constraints,
    int crossAxisCount,
  );

  @override
  _SliverPatternGridLayout getLayout(SliverConstraints constraints) {
    final crossAxisCount = this.crossAxisCount ??
        (constraints.crossAxisExtent / (maxCrossAxisExtent! + crossAxisSpacing))
            .ceil();
    final geometries = getGeometries(constraints, crossAxisCount);
    return _SliverPatternGridLayout(
      mainAxisSpacing: mainAxisSpacing,
      crossAxisExtent: constraints.crossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
      tiles: geometries.tiles,
      bounds: geometries.bounds,
    );
  }

  @override
  bool shouldRelayout(SliverPatternGridDelegate oldDelegate) {
    return oldDelegate.pattern != pattern ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing;
  }
}

class _SliverPatternGridLayout extends SliverGridLayout {
  _SliverPatternGridLayout({
    required this.mainAxisSpacing,
    required this.tiles,
    required this.bounds,
    required this.crossAxisExtent,
    this.reverseCrossAxis = false,
  })  : tileCount = tiles.length,
        patternMainAxisExtent =
            bounds.last.trailingScrollOffset + mainAxisSpacing;

  final double mainAxisSpacing;
  final double crossAxisExtent;
  final bool reverseCrossAxis;
  final List<SliverGridGeometry> tiles;
  final List<SliverGridGeometry> bounds;
  final int tileCount;
  final double patternMainAxisExtent;

  @override
  double computeMaxScrollOffset(int childCount) {
    if (childCount == 0) {
      return 0;
    }

    final lastFilledPatternTrailingScrollOffset =
        (childCount ~/ tileCount) * patternMainAxisExtent;

    if (childCount % tileCount == 0) {
      return lastFilledPatternTrailingScrollOffset - mainAxisSpacing;
    }

    // We have to get the max scroll offset for the track where the tile with
    // index, childCount - 1, is.
    // TODO(romain): Can be optimized.
    final maxIndex = (childCount - 1) % tileCount;
    final maxRemainingScrollOffset = tiles
        .take(maxIndex + 1)
        .map((x) => x.trailingScrollOffset)
        .reduce(math.max);
    return lastFilledPatternTrailingScrollOffset + maxRemainingScrollOffset;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final startMainAxisOffset = (index ~/ tileCount) * patternMainAxisExtent;
    final rect = tileRectAt(index);
    final realRect = rect.translate(startMainAxisOffset);

    if (reverseCrossAxis) {
      return SliverGridGeometry(
        scrollOffset: realRect.scrollOffset,
        crossAxisOffset: crossAxisExtent -
            realRect.crossAxisOffset -
            realRect.crossAxisExtent,
        mainAxisExtent: realRect.mainAxisExtent,
        crossAxisExtent: realRect.crossAxisExtent,
      );
    }

    return realRect;
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    final patternCount = (scrollOffset ~/ patternMainAxisExtent);
    final mainAxisOffset = scrollOffset - patternCount * patternMainAxisExtent;
    for (int i = 0; i < tileCount; i++) {
      if (_isRectVisibleAtMainAxisOffset(bounds[i], mainAxisOffset)) {
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
      if (_isRectVisibleAtMainAxisOffset(bounds[i], mainAxisOffset)) {
        return i + patternCount * tileCount;
      }
    }

    return 0;
  }

  bool _isRectVisibleAtMainAxisOffset(
    SliverGridGeometry rect,
    double mainAxisOffset,
  ) {
    return rect.scrollOffset <= mainAxisOffset &&
        rect.trailingScrollOffset >= (mainAxisOffset - mainAxisSpacing);
  }

  SliverGridGeometry tileRectAt(int index) {
    return tiles[index % tileCount];
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
