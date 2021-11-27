import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/src/layouts/sliver_patterned_grid_delegate.dart';

/// A tile of a woven pattern.
@immutable
class WovenGridTile {
  /// Creates a [WovenGridTile].
  const WovenGridTile(
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
}

/// Controls the layout of tiles in a woven grid.
class SliverWovenGridDelegate extends SliverPatternGridDelegate<WovenGridTile> {
  /// Creates a [SliverWovenGridDelegate].
  const SliverWovenGridDelegate({
    required List<WovenGridTile> tiles,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    this.tileBottomSpace = 0,
    this.startCrossAxisDirectionReversed = false,
  })  : assert(tileBottomSpace >= 0),
        super(
          tiles: tiles,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        );

  /// {@template fsgv.woven.titleHeight}
  /// The number of logical pixels of the space below each tile.
  /// {@endtemplate}
  final double tileBottomSpace;

  /// Indicates whether we should start to place the tile in the reverse cross
  /// axis direction.
  final bool startCrossAxisDirectionReversed;

  @override
  List<SliverGridGeometry> getPattern(SliverConstraints constraints) {
    final maxCrossAxisExtent = constraints.crossAxisExtent;
    final List<SliverGridGeometry> tileRects = List.filled(
      tiles.length,
      const SliverGridGeometry(
        scrollOffset: 0,
        crossAxisOffset: 0,
        mainAxisExtent: 0,
        crossAxisExtent: 0,
      ),
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
        crossAxisRatioSum += tiles[i].crossAxisRatio;
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

      double mainAxisExtent = 0;
      for (int j = startIndex; j < i; j++) {
        final tile = tiles[j];
        final crossAxisExtent = usableCrossAxisExtent * tile.crossAxisRatio +
            (isHorizontal ? tileBottomSpace : 0);
        mainAxisExtent = crossAxisExtent * tile.aspectRatio +
            (isHorizontal ? 0 : tileBottomSpace);
        crossAxisOffset =
            reversed ? crossAxisOffset - crossAxisExtent : crossAxisOffset;
        final tileRect = SliverGridGeometry(
          scrollOffset: mainAxisOffset,
          crossAxisOffset: crossAxisOffset,
          mainAxisExtent: mainAxisExtent,
          crossAxisExtent: crossAxisExtent,
        );
        crossAxisOffset = reversed
            ? crossAxisOffset - crossAxisSpacing
            : crossAxisOffset + crossAxisExtent + crossAxisSpacing;
        mainAxisOffset += mainAxisSpacing;
        tileRects[j] = tileRect;
      }
      mainAxisOffset += mainAxisExtent;
      reversed = !reversed;
      crossAxisOffset =
          reversed ? maxCrossAxisExtent - crossAxisSpacing : crossAxisSpacing;
    }

    return tileRects;
  }

  @override
  bool shouldRelayout(SliverWovenGridDelegate oldDelegate) {
    return super.shouldRelayout(oldDelegate) ||
        oldDelegate.tileBottomSpace != tileBottomSpace;
  }
}
