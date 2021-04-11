import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'staggered_grid_view_page.dart';

const List<StaggeredTile> _tiles = <StaggeredTile>[
  StaggeredTile.extent(1, 50),
  StaggeredTile.extent(1, 180),
  StaggeredTile.extent(1, 160),
  StaggeredTile.extent(1, 140),
  StaggeredTile.extent(1, 120),
  StaggeredTile.extent(1, 130),
  StaggeredTile.extent(1, 50),
  StaggeredTile.extent(1, 60),
  StaggeredTile.extent(1, 130),
  StaggeredTile.extent(1, 140),
  StaggeredTile.extent(1, 60),
  StaggeredTile.extent(1, 150),
];

class StaggeredCountExtentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const StaggeredGridViewPage.count(
        title: 'Staggered (Count, Extent)', crossAxisCount: 2, tiles: _tiles);
  }
}
