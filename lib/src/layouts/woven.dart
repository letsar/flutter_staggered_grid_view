import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/src/foundation/constants.dart';
import 'package:flutter_staggered_grid_view/src/layouts/sliver_patterned_grid_delegate.dart';

/// A tile of a woven pattern.
@immutable
class WovenGridTile {
  /// Creates a [WovenGridTile].
  const WovenGridTile(
    this.aspectRatio, {
    this.crossAxisRatio = 1,
    this.alignment = AlignmentDirectional.center,
  })  : assert(aspectRatio > 0),
        assert(crossAxisRatio > 0 && crossAxisRatio <= 1);

  /// The ratio of the cross-axis to the main-axis extent of the tile.
  ///
  /// Must be greater than 0.
  final double aspectRatio;

  /// The ratio taken by this tile in the cross-axis.
  ///
  /// Must be between 0 (exclusive) and 1 (inclusive).
  final double crossAxisRatio;

  /// The alignment of the tile within the available space.
  final AlignmentDirectional alignment;

  @override
  String toString() {
    return 'WovenGridTile($aspectRatio${crossAxisRatio > 1 ? ', $crossAxisRatio' : ''}${alignment != AlignmentDirectional.center ? ', $alignment' : ''})';
  }
}

/// Controls the layout of tiles in a woven grid.
class SliverWovenGridDelegate extends SliverPatternGridDelegate<WovenGridTile> {
  /// Creates a [SliverWovenGridDelegate].
  const SliverWovenGridDelegate.count({
    required List<WovenGridTile> pattern,
    required int crossAxisCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    this.tileBottomSpace = 0,
    this.textDirection = TextDirection.ltr,
  })  : assert(pattern.length <= crossAxisCount),
        super.count(
          pattern: pattern,
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        );

  /// Creates a [SliverWovenGridDelegate].
  const SliverWovenGridDelegate.extent({
    required List<WovenGridTile> pattern,
    required double maxCrossAxisExtent,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    this.tileBottomSpace = 0,
    this.textDirection = TextDirection.ltr,
  }) : super.extent(
          pattern: pattern,
          maxCrossAxisExtent: maxCrossAxisExtent,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        );

  /// {@macro fsgv.global.tileBottomSpace}
  final double tileBottomSpace;

  /// The direction in which the columns are ordered if the scroll is vertical.
  final TextDirection textDirection;

  @override
  SliverPatternGridGeometries getGeometries(
    SliverConstraints constraints,
    int crossAxisCount,
  ) {
    final isHorizontal = constraints.axis == Axis.horizontal;
    final usableCrossAxisExtent = isHorizontal
        ? constraints.crossAxisExtent - crossAxisCount * tileBottomSpace
        : constraints.crossAxisExtent;
    final crossAxisExtent =
        (usableCrossAxisExtent + crossAxisSpacing) / crossAxisCount -
            crossAxisSpacing;
    final crossAxisStride = crossAxisExtent + crossAxisSpacing;
    final patternCount = pattern.length;
    // The minimum aspect ratio give us the main axis extent of a run.
    final maxMainAxisExtentRatio =
        pattern.map((t) => t.crossAxisRatio / t.aspectRatio).reduce(math.max);
    final mainAxisExtent = crossAxisExtent * maxMainAxisExtentRatio +
        (isHorizontal ? 0 : tileBottomSpace);

    // We always provide 2 runs where the layout follow this pattern:
    // A B A || A B A B || A B C
    // B A B || B A B A || C B A

    final count = crossAxisCount * 2;
    final tiles = List.filled(count, kZeroGeometry);
    final bounds = List.filled(count, kZeroGeometry);
    for (int i = 0; i < count; i++) {
      final startScrollOffset =
          i < crossAxisCount ? 0.0 : mainAxisExtent + mainAxisSpacing;
      final tilePatternIndex = i < crossAxisCount
          ? i % patternCount
          : (crossAxisCount - 1 - i) % patternCount;
      final tilePattern = pattern[tilePatternIndex];
      final tileCrossAxisExtent = crossAxisExtent * tilePattern.crossAxisRatio +
          (isHorizontal ? tileBottomSpace : 0);
      final tileMainAxisExtent = tileCrossAxisExtent / tilePattern.aspectRatio +
          (isHorizontal ? 0 : tileBottomSpace);
      final effectiveTextDirection = i < crossAxisCount
          ? textDirection
          : textDirection == TextDirection.ltr
              ? TextDirection.rtl
              : TextDirection.ltr;
      final effectiveAlignment =
          tilePattern.alignment.resolve(effectiveTextDirection);
      final rect = effectiveAlignment.inscribe(
        Size(tileCrossAxisExtent, tileMainAxisExtent),
        Rect.fromLTWH(0, 0, crossAxisExtent, mainAxisExtent),
      );
      final startCrossAxisOffset = (i % crossAxisCount) * crossAxisStride;
      tiles[i] = SliverGridGeometry(
        scrollOffset: startScrollOffset + rect.top,
        crossAxisOffset: startCrossAxisOffset + rect.left,
        mainAxisExtent: tileMainAxisExtent,
        crossAxisExtent: tileCrossAxisExtent,
      );
      bounds[i] = SliverGridGeometry(
        scrollOffset: startScrollOffset,
        crossAxisOffset: startCrossAxisOffset,
        mainAxisExtent: mainAxisExtent,
        crossAxisExtent: crossAxisExtent,
      );
    }

    return SliverPatternGridGeometries(tiles: tiles, bounds: bounds);
  }

  @override
  bool shouldRelayout(SliverWovenGridDelegate oldDelegate) {
    return super.shouldRelayout(oldDelegate) ||
        oldDelegate.tileBottomSpace != tileBottomSpace ||
        oldDelegate.crossAxisCount != crossAxisCount ||
        oldDelegate.textDirection != textDirection;
  }
}
