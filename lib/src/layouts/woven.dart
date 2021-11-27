import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/src/layouts/sliver_patterned_grid_delegate.dart';

@immutable
class WovenGridTile {
  const WovenGridTile(
    this.crossAxisRatio,
    this.aspectRatio,
  )   : assert(crossAxisRatio > 0 && crossAxisRatio <= 1),
        assert(aspectRatio > 0);

  final double aspectRatio;
  final double crossAxisRatio;
}

class SliverWovenGridDelegate extends SliverPatternGridDelegate<WovenGridTile> {
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

  final bool startCrossAxisDirectionReversed;

  @override
  List<TileRect> getPattern(SliverConstraints constraints) {
    final maxCrossAxisExtent = constraints.crossAxisExtent;
    final List<TileRect> tileRects = List.filled(tiles.length, TileRect.zero);
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
        final tileRect = TileRect(
          mainAxisOffset: mainAxisOffset,
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
