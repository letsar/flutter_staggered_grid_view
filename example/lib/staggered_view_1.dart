import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class StaggeredView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final widgets = new List<Widget>.generate(20, (int i) {
      return new Builder(
        builder: (BuildContext context) {
          return new Container(
            color: Colors.green,
            child: new Text('$i'),
          );
        },
      );
    });
    final tiles = const <StaggeredTile>[
      const StaggeredTile.cellCount(2, 2),
      const StaggeredTile.cellCount(1, 1),
      const StaggeredTile.cellCount(1, 2),
      const StaggeredTile.cellCount(1, 1),
      const StaggeredTile.cellCount(4, 1),
      const StaggeredTile.cellCount(4, 2),
      const StaggeredTile.cellCount(1, 1),
      const StaggeredTile.cellCount(1, 1),
      const StaggeredTile.cellCount(1, 1),
      const StaggeredTile.cellCount(1, 1),
      const StaggeredTile.cellCount(1, 4),
      const StaggeredTile.cellCount(1, 3),
      const StaggeredTile.cellCount(1, 2),
      const StaggeredTile.cellCount(1, 1),
      const StaggeredTile.cellCount(1, 1),
      const StaggeredTile.cellCount(1, 1),
      const StaggeredTile.cellCount(1, 1),
      const StaggeredTile.cellCount(1, 1),
      const StaggeredTile.cellCount(1, 1),
      const StaggeredTile.cellCount(1, 1),
    ];

    return new Directionality(
      textDirection : TextDirection.ltr,
      child: new StaggeredGridView(
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
        crossAxisCount: 4,
        staggeredTiles: tiles,
        children: widgets,
        reverse: false,
      ),
    );
  }
}
