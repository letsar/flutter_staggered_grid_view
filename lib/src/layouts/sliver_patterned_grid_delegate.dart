import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TileRect {
  TileRect({
    required double mainAxisOffset,
    required double crossAxisOffset,
    required double mainAxisExtent,
    required double crossAxisExtent,
  }) : this._fromRect(
          Rect.fromLTWH(
            crossAxisOffset,
            mainAxisOffset,
            crossAxisExtent,
            mainAxisExtent,
          ),
        );

  const TileRect._fromRect(this._rect);

  static const TileRect zero = TileRect._fromRect(Rect.zero);

  final Rect _rect;
  double get mainAxisOffset => _rect.top;
  double get crossAxisOffset => _rect.left;
  double get mainAxisExtent => _rect.height;
  double get crossAxisExtent => _rect.width;
  double get mainAxisEndOffset => _rect.bottom;

  TileRect translate(double translation) {
    return TileRect(
      mainAxisOffset: mainAxisOffset + translation,
      crossAxisOffset: crossAxisOffset,
      mainAxisExtent: mainAxisExtent,
      crossAxisExtent: crossAxisExtent,
    );
  }
}

abstract class SliverPatternGridDelegate<T> extends SliverGridDelegate {
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

  final List<T> tiles;

  final int tileCount;

  @protected
  List<TileRect> getPattern(SliverConstraints constraints);

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
            tileRects.last.mainAxisEndOffset + mainAxisSpacing;

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
  final List<TileRect> tileRects;
  final int tileCount;
  final double patternMainAxisExtent;

  @override
  double computeMaxScrollOffset(int childCount) {
    final tileRect = tileRectAt(childCount);
    return (childCount ~/ tileCount) * patternMainAxisExtent +
        tileRect.mainAxisEndOffset;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final startMainAxisOffset = (index ~/ tileCount) * patternMainAxisExtent;
    final rect = tileRectAt(index);
    final realRect = rect.translate(startMainAxisOffset);

    return SliverGridGeometry(
      scrollOffset: realRect.mainAxisOffset,
      crossAxisOffset: realRect.crossAxisOffset,
      mainAxisExtent: realRect.mainAxisExtent,
      crossAxisExtent: realRect.crossAxisExtent,
    );
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
    return tileRects[index % tileCount].mainAxisOffset;
  }

  bool _isRectVisibleAtMainAxisOffset(TileRect rect, double mainAxisOffset) {
    return rect.mainAxisOffset <= mainAxisOffset &&
        rect.mainAxisEndOffset >= (mainAxisOffset - mainAxisSpacing);
  }

  TileRect tileRectAt(int index) {
    return tileRects[index % tileCount];
  }
}
