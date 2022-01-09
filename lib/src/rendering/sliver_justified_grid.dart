import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/src/rendering/sliver_grid_list.dart';

/// Parent data structure used by [RenderSliverJustifiedGrid].
class SliverJustifiedGridParentData extends SliverGridParentData {
  /// The mainAxisExtent of the track.
  /// Used only by the trailing child of a track.
  double? mainAxisExtent;

  @override
  String toString() => 'mainAxisExtent=$mainAxisExtent; ${super.toString()}';
}

/// Signature for a function that returns the aspect ratio for a child with the
/// given [index].
typedef AspectRatioGetter = double? Function(int index);

/// A sliver that layouts its children following a justified grid layout.
///
/// Remark: The algorithm is a slightly modified version of the one described in
/// flickr: https://github.com/flickr/justified-layout
class RenderSliverJustifiedGrid extends RenderSliverGridList {
  /// Creates a [RenderSliverJustifiedGrid].
  RenderSliverJustifiedGrid({
    required RenderSliverBoxChildManager childManager,
    required AspectRatioGetter aspectRatioGetter,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    required double targetMainAxisExtent,
    required double targetMainAxisExtentTolerance,
    required int? estimatedChildCount,
  })  : assert(targetMainAxisExtent > 0),
        assert(
          targetMainAxisExtentTolerance > 0 &&
              targetMainAxisExtentTolerance < 1,
        ),
        _minTargetMainAxisExtent =
            targetMainAxisExtent * (1 - targetMainAxisExtentTolerance),
        _maxTargetMainAxisExtent =
            targetMainAxisExtent * (1 + targetMainAxisExtentTolerance),
        _aspectRatioGetter = aspectRatioGetter,
        _targetMainAxisExtent = targetMainAxisExtent,
        _targetMainAxisExtentTolerance = targetMainAxisExtentTolerance,
        _estimatedChildCount = estimatedChildCount,
        super(
          childManager: childManager,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        );

  /// {@template fsgv.justified.targetMainAxisExtent}
  /// The main axis extent the tracks should try to reach.
  ///
  /// Must be greater than 0.
  /// {@endtemplate}
  double get targetMainAxisExtent => _targetMainAxisExtent;
  double _targetMainAxisExtent;
  set targetMainAxisExtent(double value) {
    assert(value > 0);
    if (_targetMainAxisExtent == value) {
      return;
    }
    _targetMainAxisExtent = value;
    _updateTargetMainAxisExtents();
    markNeedsLayout();
  }

  /// {@template fsgv.justified.targetMainAxisExtentTolerance}
  /// How far the tracks main axis extent can stray from [targetMainAxisExtent].
  ///
  /// Must be greater than 0 and less than 1.
  /// {@endtemplate}
  double get targetMainAxisExtentTolerance => _targetMainAxisExtentTolerance;
  double _targetMainAxisExtentTolerance;
  set targetMainAxisExtentTolerance(double value) {
    assert(value > 0 && value < 1);
    if (_targetMainAxisExtentTolerance == value) {
      return;
    }
    _targetMainAxisExtentTolerance = value;
    _updateTargetMainAxisExtents();
    markNeedsLayout();
  }

  final int? _estimatedChildCount;

  /// {@template fsgv.justified.aspectRatioGetter}
  /// The function used to get the aspect ratio of a child given its index.
  /// {@endtemplate}
  AspectRatioGetter get aspectRatioGetter => _aspectRatioGetter;
  AspectRatioGetter _aspectRatioGetter;
  set aspectRatioGetter(AspectRatioGetter value) {
    if (_aspectRatioGetter == value) {
      return;
    }
    _aspectRatioGetter = value;
    markNeedsLayout();
  }

  double? _aspectRatioOf(int index) {
    final childCount = _estimatedChildCount;
    if (index < 0 || (childCount != null && index >= childCount)) {
      return null;
    }

    return _aspectRatioGetter(index);
  }

  void _updateTargetMainAxisExtents() {
    _minTargetMainAxisExtent =
        targetMainAxisExtent * (1 - targetMainAxisExtentTolerance);
    _maxTargetMainAxisExtent =
        targetMainAxisExtent * (1 + targetMainAxisExtentTolerance);
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverJustifiedGridParentData) {
      child.parentData = SliverJustifiedGridParentData();
    }
  }

  @override
  SliverJustifiedGridParentData getParentData(RenderBox child) {
    return child.parentData as SliverJustifiedGridParentData;
  }

  final Map<int, List<double>> _indexToTrackAspectRatios = {};
  double _previousCrossAxisExtent = 0;

  double _minTargetMainAxisExtent;
  double _maxTargetMainAxisExtent;

  double _minTrackAspectRatio = 0;
  double _maxTrackAspectRatio = 0;
  late _JustifiedGridLayoutSolver _solver;

  @override
  double mainAxisExtentOf(RenderBox child) {
    return getParentData(child).mainAxisExtent!;
  }

  @override
  void startLayout() {
    final crossAxisExtent = constraints.crossAxisExtent;
    if (_previousCrossAxisExtent != crossAxisExtent) {
      _indexToTrackAspectRatios.clear();
      _previousCrossAxisExtent = crossAxisExtent;
    }
    _minTrackAspectRatio = crossAxisExtent / _maxTargetMainAxisExtent;
    _maxTrackAspectRatio = crossAxisExtent / _minTargetMainAxisExtent;
    _solver = _JustifiedGridLayoutSolver(
      aspectRatioGetter: _aspectRatioOf,
      crossAxisSpacing: crossAxisSpacing,
      minAspectRatio: _minTrackAspectRatio,
      maxAspectRatio: _maxTrackAspectRatio,
      maxCrossAxisExtent: crossAxisExtent,
      targetMainAxisExtent: _targetMainAxisExtent,
      minTargetMainAxisExtent: _minTargetMainAxisExtent,
      maxTargetMainAxisExtent: _maxTargetMainAxisExtent,
      indexToTrackAspectRatios: _indexToTrackAspectRatios,
    );
  }

  @override
  BoxConstraints computeChildConstraints() {
    return constraints.asBoxConstraints(
      minExtent: _minTargetMainAxisExtent,
      maxExtent: _maxTargetMainAxisExtent,
    );
  }

  @override
  RenderBox layoutTrack(
    RenderBox leadingChild,
    double layoutOffset, {
    _JustifiedGridTrackLayout? preComputedTrackLayout,
  }) {
    final leadingChildIndex = indexOf(leadingChild);
    final trackLayout =
        preComputedTrackLayout ?? _solver.createTrackLayout(leadingChildIndex);
    final mainAxisExent = trackLayout.mainAxisExtent;
    final crossAxisExtents = trackLayout.crossAxisExtents;

    double crossAxisOffset = 0;
    late RenderBox trailingChild;
    int index = 0;
    _visitTrack(
      leadingChild: leadingChild,
      visitor: (child) {
        final crossAxisExtent = crossAxisExtents[index];
        final childConstraints = constraints.asBoxConstraints(
          minExtent: mainAxisExent,
          maxExtent: mainAxisExent,
          crossAxisExtent: crossAxisExtent,
        );
        child.layout(childConstraints);
        final childParentData = getParentData(child);
        trailingChild = child;
        childParentData.crossAxisOffset = crossAxisOffset;
        childParentData.layoutOffset = layoutOffset;
        childParentData.mainAxisExtent = mainAxisExent;
        crossAxisOffset += crossAxisExtent + crossAxisSpacing;
        index++;
      },
      predicate: (child) {
        return index < crossAxisExtents.length;
      },
    );

    return trailingChild;
  }

  @override
  RenderBox? insertAndLayoutLeadingTrack(BoxConstraints constraints) {
    // We need to add a leading child while its cross axis offset is not zero.
    final firstChildParentData = getParentData(firstChild!);
    final firstChildMainAxisOffset = firstChildParentData.layoutOffset!;
    final firstChildCrossAxisOffset = firstChildParentData.crossAxisOffset!;

    RenderBox? child = firstChild;
    RenderBox? trailingChild = firstChild!;
    if (firstChildCrossAxisOffset != 0) {
      // We need to get the trailingChild to compute the track layout.
      while (child != null &&
          childScrollOffset(child) == firstChildMainAxisOffset) {
        trailingChild = child;
        child = childAfter(child);
      }
    } else {
      trailingChild = insertAndLayoutLeadingChild(constraints);
      if (trailingChild == null) {
        // There are no children before, we need to let the superclass make a
        // scrollCorrectionOffset.
        return null;
      }
    }

    // The trailing child is now the trailing child of the track we want to
    // layout.
    final trackLayout = _solver.createTrackLayout(
      indexOf(trailingChild!),
      reversed: true,
    );

    final leadingChildIndex = trackLayout.leadingChildIndex;
    RenderBox? leadingChild = firstChild;
    while (leadingChild != null && indexOf(leadingChild) > leadingChildIndex) {
      leadingChild = insertAndLayoutLeadingChild(constraints);
    }

    // LeadingChild should not be null since we created the layout.
    layoutTrack(
      leadingChild!,
      firstChildMainAxisOffset,
      preComputedTrackLayout: trackLayout,
    );

    return leadingChild;
  }

  RenderBox _visitTrack({
    required RenderBox leadingChild,
    required void Function(RenderBox) visitor,
    required bool Function(RenderBox) predicate,
  }) {
    RenderBox? child = leadingChild;
    RenderBox previousChild = leadingChild;
    final childConstraints = computeChildConstraints();
    while (child != null && predicate(child)) {
      visitor(child);
      previousChild = child;
      child = childAfter(child);
      if (child == null || indexOf(child) != indexOf(previousChild) + 1) {
        child = insertAndLayoutChild(
          childConstraints,
          after: previousChild,
          parentUsesSize: true,
        );
      }
    }

    return previousChild;
  }
}

class _JustifiedGridTrackLayout {
  const _JustifiedGridTrackLayout({
    required this.leadingChildIndex,
    required this.mainAxisExtent,
    required this.crossAxisExtents,
  });

  final int leadingChildIndex;
  final double mainAxisExtent;
  final List<double> crossAxisExtents;
}

class _JustifiedGridLayoutSolver {
  const _JustifiedGridLayoutSolver({
    required this.aspectRatioGetter,
    required this.maxCrossAxisExtent,
    required this.minAspectRatio,
    required this.maxAspectRatio,
    required this.crossAxisSpacing,
    required this.targetMainAxisExtent,
    required this.minTargetMainAxisExtent,
    required this.maxTargetMainAxisExtent,
    required this.indexToTrackAspectRatios,
  });

  final AspectRatioGetter aspectRatioGetter;
  final double maxCrossAxisExtent;
  final double minAspectRatio;
  final double maxAspectRatio;
  final double crossAxisSpacing;
  final double targetMainAxisExtent;
  final double minTargetMainAxisExtent;
  final double maxTargetMainAxisExtent;
  final Map<int, List<double>> indexToTrackAspectRatios;

  _JustifiedGridTrackLayout createTrackLayout(
    int leadingChildIndex, {
    bool reversed = false,
  }) {
    List<double> crossAxisExtents = <double>[];
    double totalAspectRatio = 0;
    int childCount = 0;
    double mainAxisExtent = 0;
    double previousCrossAxisExtentWithoutSpacing = 0;
    double previousTotalAspectRatio = 0;
    double previousTargetAspectRatio = 0;
    int realIndex(int index) {
      return reversed ? -index : index;
    }

    void completeLayout(
      double crossAxisExtent,
      double aspectRatio, {
      bool clamp = true,
    }) {
      final extent = (crossAxisExtent / aspectRatio);

      void fillCrossAxisExtents(double multiplier) {
        if (reversed) {
          final trailingChildIndex = leadingChildIndex;
          indexToTrackAspectRatios[trailingChildIndex] = [
            for (int i = childCount - 1; i >= 0; i--)
              aspectRatioGetter(leadingChildIndex - i)!
          ];
          crossAxisExtents = [
            for (int i = childCount - 1; i >= 0; i--)
              aspectRatioGetter(leadingChildIndex - i)! * multiplier
          ];
        } else {
          final trailingChildIndex = leadingChildIndex + childCount - 1;
          indexToTrackAspectRatios[trailingChildIndex] = [
            for (int i = 0; i < childCount; i++)
              aspectRatioGetter(leadingChildIndex + i)!
          ];
          crossAxisExtents = [
            for (int i = 0; i < childCount; i++)
              aspectRatioGetter(leadingChildIndex + i)! * multiplier
          ];
        }
      }

      if (clamp) {
        mainAxisExtent = extent.clamp(
          minTargetMainAxisExtent,
          maxTargetMainAxisExtent,
        );

        final clampedToNativeRatio =
            mainAxisExtent == extent ? 1 : extent / mainAxisExtent;

        fillCrossAxisExtents(mainAxisExtent * clampedToNativeRatio);
      } else {
        mainAxisExtent = extent;
        fillCrossAxisExtents(mainAxisExtent);
      }
    }

    bool advance(double aspectRatio) {
      previousTotalAspectRatio = totalAspectRatio;
      totalAspectRatio += aspectRatio;
      final crossAxisExtentWithoutSpacing =
          maxCrossAxisExtent - crossAxisSpacing * childCount;
      final targetAspectRatio =
          crossAxisExtentWithoutSpacing / targetMainAxisExtent;

      if (totalAspectRatio < minAspectRatio) {
        // The total aspect ratio is too narrow or the track is too tall.
        // Accept the child.
        childCount++;
        return true;
      }

      if (totalAspectRatio > maxAspectRatio) {
        // The total aspect ratio is too wide or the track is too short.
        // Accept the child if the resulting aspect ratio is closer to target
        // than it would be without the child.

        if (childCount == 0) {
          // There are no previous child. This child will take the whole track.

          childCount++;
          completeLayout(crossAxisExtentWithoutSpacing, totalAspectRatio);
          return true;
        }

        previousCrossAxisExtentWithoutSpacing =
            maxCrossAxisExtent - crossAxisSpacing * childCount;
        previousTargetAspectRatio =
            previousCrossAxisExtentWithoutSpacing / targetMainAxisExtent;

        if ((totalAspectRatio - targetAspectRatio).abs() <
            (previousTotalAspectRatio - previousTargetAspectRatio).abs()) {
          // Reject the child because we are far away with it than without.
          completeLayout(
            previousCrossAxisExtentWithoutSpacing,
            previousTotalAspectRatio,
          );
          return false;
        } else {
          childCount++;
          completeLayout(crossAxisExtentWithoutSpacing, totalAspectRatio);
          return true;
        }
      }

      // We can accept the child.
      childCount++;
      // completeLayout(crossAxisExtentWithoutSpacing, totalAspectRatio);
      return true;
    }

    if (reversed) {
      // We check if we have already computed the layout before and if it's the
      // same.
      final previousAspectRatios = indexToTrackAspectRatios[leadingChildIndex];
      if (previousAspectRatios != null) {
        final trackChildCount = previousAspectRatios.length;
        final realLeadingChildIndex = leadingChildIndex - trackChildCount + 1;
        bool sameLayout = true;
        for (int i = 0; i < trackChildCount; i++) {
          final index = realLeadingChildIndex + i;
          final oldAspectRatio = previousAspectRatios[i];
          final newAspectRatio = aspectRatioGetter(index);
          if (oldAspectRatio != newAspectRatio) {
            sameLayout = false;
            break;
          }
        }
        if (sameLayout) {
          childCount = trackChildCount;
          final crossAxisExtentWithoutSpacing =
              maxCrossAxisExtent - crossAxisSpacing * (childCount - 1);
          final totalAspectRatio = previousAspectRatios.reduce((a, b) => a + b);
          // We already computed the layout.
          // We can complete it.
          completeLayout(
            crossAxisExtentWithoutSpacing,
            totalAspectRatio,
          );
          return _JustifiedGridTrackLayout(
            leadingChildIndex: realLeadingChildIndex,
            mainAxisExtent: mainAxisExtent,
            crossAxisExtents: crossAxisExtents,
          );
        }
      }
    }

    bool trackFilled = true;

    while (mainAxisExtent == 0) {
      final aspectRatio =
          aspectRatioGetter(leadingChildIndex + realIndex(childCount));
      if (aspectRatio == null) {
        // The track is not filled. We need to make the children fit the cross
        // axis extent.
        // The target main axis extent tolerance may not be respected.
        trackFilled = false;
        break;
      }

      advance(aspectRatio);
    }

    if (!trackFilled) {
      if (reversed) {
        // We need to relayout this track considering the last index as the
        // new leading child index.
        return createTrackLayout(
          leadingChildIndex - childCount + 1,
        );
      }

      // We ned to make the children fit the cross axis extent.
      final crossAxisExtentWithoutSpacing =
          maxCrossAxisExtent - crossAxisSpacing * (childCount - 1);
      completeLayout(
        crossAxisExtentWithoutSpacing,
        totalAspectRatio,
        clamp: false,
      );
    }

    return _JustifiedGridTrackLayout(
      leadingChildIndex:
          reversed ? leadingChildIndex - childCount + 1 : leadingChildIndex,
      mainAxisExtent: mainAxisExtent,
      crossAxisExtents: crossAxisExtents,
    );
  }
}
