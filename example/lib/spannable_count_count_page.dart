import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'staggered_grid_view_page.dart';

const List<StaggeredTile> _tiles = const <StaggeredTile>[
  const StaggeredTile.count(2, 2),
  const StaggeredTile.count(1, 1),
  const StaggeredTile.count(1, 2),
  const StaggeredTile.count(1, 1),
  const StaggeredTile.count(4, 1),
  const StaggeredTile.count(4, 2),
  const StaggeredTile.count(1, 1),
  const StaggeredTile.count(1, 1),
  const StaggeredTile.count(1, 1),
  const StaggeredTile.count(1, 1),
  const StaggeredTile.count(1, 4),
  const StaggeredTile.count(1, 3),
  const StaggeredTile.count(1, 2),
  const StaggeredTile.count(1, 1),
  const StaggeredTile.count(1, 1),
  const StaggeredTile.count(1, 1),
  const StaggeredTile.count(1, 1),
  const StaggeredTile.count(1, 1),
  const StaggeredTile.count(1, 1),
  const StaggeredTile.count(1, 1),
];

class SpannableCountCountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const StaggeredGridViewPage.count(
        title: 'Spannable (Count, Count)', crossAxisCount: 4, tiles: _tiles);
  }
}
