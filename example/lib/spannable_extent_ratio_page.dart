import 'package:example/staggered_grid_view_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

const List<StaggeredTile> _tiles = const <StaggeredTile>[
  const StaggeredTile.ratio(2, 2),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 2),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(4, 1),
  const StaggeredTile.ratio(4, 2),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 4),
  const StaggeredTile.ratio(1, 3),
  const StaggeredTile.ratio(1, 2),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 1),
];

class SpannableExtentRatioPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const StaggeredGridViewPage.extent(
        title: 'Spannable (Extent, Ratio)',
        maxCrossAxisExtent: 75.0,
        tiles: _tiles);
  }
}
