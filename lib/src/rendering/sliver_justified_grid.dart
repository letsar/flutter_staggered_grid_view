import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/src/rendering/sliver_grid_list.dart';

class RenderSliverJustifiedGrid extends RenderSliverGridList {
  RenderSliverJustifiedGrid({
    required RenderSliverBoxChildManager childManager,
    double mainAxisSpacing = 0,
    required double targetTrackExtent,
    required double targetTrackExtentTolerance,
  })  : assert(targetTrackExtent > 0),
        assert(
          targetTrackExtentTolerance > 0 && targetTrackExtentTolerance < 1,
        ),
        _targetTrackExtent = targetTrackExtent,
        _targetTrackExtentTolerance = targetTrackExtentTolerance,
        super(childManager: childManager, mainAxisSpacing: mainAxisSpacing);

  double get targetTrackExtent => _targetTrackExtent;
  double _targetTrackExtent;
  set targetTrackExtent(double value) {
    assert(value > 0);
    if (_targetTrackExtent == value) {
      return;
    }
    _targetTrackExtent = value;
    markNeedsLayout();
  }

  double get targetTrackExtentTolerance => _targetTrackExtentTolerance;
  double _targetTrackExtentTolerance;
  set targetTrackExtentTolerance(double value) {
    assert(value > 0 && value < 1);
    if (_targetTrackExtentTolerance == value) {
      return;
    }
    _targetTrackExtentTolerance = value;
    markNeedsLayout();
  }

  @override
  BoxConstraints computeChildConstraints() {
    final min = _targetTrackExtent * (1 - _targetTrackExtentTolerance);
    final max = _targetTrackExtent * (1 + _targetTrackExtentTolerance);
    return constraints.asBoxConstraints(
      minExtent: min,
      maxExtent: max,
    );
  }

  @override
  RenderBox layoutTrack(RenderBox leadingChild, double layoutOffset) {
    throw UnimplementedError();
  }

  @override
  RenderBox? insertAndLayoutLeadingTrack(BoxConstraints constraints) {
    throw UnimplementedError();
  }
}
