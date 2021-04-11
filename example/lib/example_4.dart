import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Example04 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('customScrollView'),
        ),
        body: CustomScrollView(
          primary: false,
          slivers: <Widget>[
            SliverStaggeredGrid.count(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              staggeredTiles: const <StaggeredTile>[
                StaggeredTile.count(2, 2),
                StaggeredTile.count(2, 1),
                StaggeredTile.count(2, 2),
                StaggeredTile.count(2, 1),
                StaggeredTile.count(2, 2),
                StaggeredTile.count(2, 1),
                StaggeredTile.count(2, 2),
                StaggeredTile.count(2, 1),
              ],
              children: const <Widget>[
                Text('1'),
                Text('2'),
                Text('3'),
                Text('4'),
                Text('5'),
                Text('6'),
                Text('7'),
                Text('8'),
              ],
            )
          ],
        ));
  }
}
