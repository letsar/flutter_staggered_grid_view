import 'package:example/staggered_grid_view_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

const List<StaggeredTile> _tiles = const <StaggeredTile>[
  const StaggeredTile.ratio(1, 1.5),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 1.5),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 1.5),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 1.5),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 1.5),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 1.5),
  const StaggeredTile.ratio(1, 1),
];

class StaggeredCountRatioPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const StaggeredGridViewPage.count(
        title: 'Staggered (Count, Ratio)', crossAxisCount: 2, tiles: _tiles);
  }
}
