// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/src/rendering/uniform_track.dart';

class UniformTrack extends MultiChildRenderObjectWidget {
  UniformTrack({
    Key? key,
    required this.division,
    this.spacing = 0,
    this.direction,
    required List<Widget> children,
  })  : assert(spacing >= 0),
        assert(division > 0),
        assert(children.length <= division),
        super(key: key, children: children);

  final double spacing;
  final int division;
  final Axis? direction;

  @override
  RenderUniformTrack createRenderObject(BuildContext context) {
    return RenderUniformTrack(
      direction: direction ??
          flipAxis(axisDirectionToAxis(Scrollable.of(context)!.axisDirection)),
      division: division,
      spacing: spacing,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderUniformTrack renderObject,
  ) {
    renderObject
      ..direction = direction ??
          flipAxis(axisDirectionToAxis(Scrollable.of(context)!.axisDirection))
      ..division = division
      ..spacing = spacing;
  }
}
