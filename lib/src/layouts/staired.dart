import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/src/foundation/constants.dart';
import 'package:flutter_staggered_grid_view/src/layouts/sliver_patterned_grid_delegate.dart';

/// A tile of a staired pattern.
@immutable
class StairedGridTile {
  /// Creates a [StairedGridTile].
  const StairedGridTile(
    this.crossAxisRatio,
    this.aspectRatio,
  )   : assert(crossAxisRatio > 0 && crossAxisRatio <= 1),
        assert(aspectRatio > 0);

  /// The amount of extent this tile is taking in the cross axis, according to
  /// the usable cross axis extent.
  /// For exemple if [crossAxisRatio] is 0.5, and the usable cross axis extent
  /// is 100. The the tile will have a cross axis extent of 50.
  ///
  /// Must be between 0 and 1.
  final double crossAxisRatio;

  /// The ratio of the cross-axis to the main-axis extent of the tile.
  ///
  /// Must be greater than 0.
  final double aspectRatio;

  @override
  String toString() {
    return 'StairedGridTile($crossAxisRatio, $aspectRatio)';
  }
}

/// Controls the layout of tiles in a staired grid.
class SliverStairedGridDelegate
    extends SliverPatternGridDelegate<StairedGridTile> {
  /// Creates a [SliverStairedGridDelegate].
  const SliverStairedGridDelegate({
    required List<StairedGridTile> pattern,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    this.tileBottomSpace = 0,
    this.startCrossAxisDirectionReversed = false,
  })  : assert(tileBottomSpace >= 0),
        super.count(
          pattern: pattern,
          crossAxisCount: 1,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        );

  /// {@template fsgv.global.tileBottomSpace}
  /// The number of logical pixels of the space below each tile.
  /// {@endtemplate}
  final double tileBottomSpace;

  /// Indicates whether we should start to place the tile in the reverse cross
  /// axis direction.
  final bool startCrossAxisDirectionReversed;

  @override
  SliverPatternGridGeometries getGeometries(
    SliverConstraints constraints,
    int crossAxisCount,
  ) {
    final maxCrossAxisExtent = constraints.crossAxisExtent;
    final List<SliverGridGeometry> geometries = List.filled(
      pattern.length,
      kZeroGeometry,
    );
    int i = 0;
    double mainAxisOffset = 0;
    double crossAxisOffset =
        startCrossAxisDirectionReversed ? maxCrossAxisExtent : 0;
    bool reversed = startCrossAxisDirectionReversed;
    while (i < tileCount) {
      int startIndex = i;
      double crossAxisRatioSum = 0;
      while (crossAxisRatioSum < 1 && i < tileCount) {
        crossAxisRatioSum += pattern[i].crossAxisRatio;
        i++;
      }
      final tileBottomSpaceSum = tileBottomSpace * (i - startIndex);
      final isHorizontal = constraints.axis == Axis.horizontal;
      final usableCrossAxisExtent = ((startIndex == 0
                  ? maxCrossAxisExtent
                  : maxCrossAxisExtent - crossAxisSpacing) -
              (i - startIndex - 1) * crossAxisSpacing -
              (i == tileCount ? crossAxisSpacing : 0) -
              (isHorizontal ? tileBottomSpaceSum : 0))
          .clamp(0, maxCrossAxisExtent);

      double targetMainAxisOffset = 0;
      final startMainAxisOffset = mainAxisOffset;
      for (int j = startIndex; j < i; j++) {
        final tile = pattern[j];
        final crossAxisExtent = usableCrossAxisExtent * tile.crossAxisRatio +
            (isHorizontal ? tileBottomSpace : 0);
        final mainAxisExtent = crossAxisExtent / tile.aspectRatio +
            (isHorizontal ? 0 : tileBottomSpace);
        crossAxisOffset =
            reversed ? crossAxisOffset - crossAxisExtent : crossAxisOffset;
        final tileRect = SliverGridGeometry(
          scrollOffset: mainAxisOffset,
          crossAxisOffset: crossAxisOffset,
          mainAxisExtent: mainAxisExtent,
          crossAxisExtent: crossAxisExtent,
        );
        final endMainAxisOffset = mainAxisOffset + mainAxisExtent;

        crossAxisOffset = reversed
            ? crossAxisOffset - crossAxisSpacing
            : crossAxisOffset + crossAxisExtent + crossAxisSpacing;
        mainAxisOffset += mainAxisSpacing;
        geometries[j] = tileRect;
        if (endMainAxisOffset > targetMainAxisOffset) {
          targetMainAxisOffset = endMainAxisOffset;
        }
      }
      mainAxisOffset =
          startMainAxisOffset + targetMainAxisOffset + mainAxisSpacing;
      reversed = !reversed;
      crossAxisOffset =
          reversed ? maxCrossAxisExtent - crossAxisSpacing : crossAxisSpacing;
    }

    return SliverPatternGridGeometries(tiles: geometries, bounds: geometries);
  }

  @override
  bool shouldRelayout(SliverStairedGridDelegate oldDelegate) {
    return super.shouldRelayout(oldDelegate) ||
        oldDelegate.tileBottomSpace != tileBottomSpace ||
        oldDelegate.startCrossAxisDirectionReversed !=
            startCrossAxisDirectionReversed;
  }
}
