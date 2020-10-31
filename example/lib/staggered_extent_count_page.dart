import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'staggered_grid_view_page.dart';

const List<StaggeredTile> _tiles = <StaggeredTile>[
  StaggeredTile.count(1, 1.5),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1.5),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1.5),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1.5),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1.5),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1.5),
  StaggeredTile.count(1, 1),
];

class StaggeredExtentCountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const StaggeredGridViewPage.extent(
        title: 'Staggered (Extent, Count)',
        maxCrossAxisExtent: 150,
        tiles: _tiles);
  }
}
