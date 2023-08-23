import 'package:examples/common.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class StaggeredPage extends StatelessWidget {
  const StaggeredPage({
    Key? key,
  }) : super(key: key);

  static const tiles = [
    GridTile(1, 1),
    GridTile(1, 4),
    GridTile(1, 2),
    GridTile(1, 1),
    GridTile(1, 4),
    GridTile(1, 1),
    GridTile(1, 1),
    GridTile(1, 1),
    GridTile(1, 1),
    GridTile(1, 4),
    GridTile(1, 1),
    GridTile(1, 1),
    GridTile(1, 4),
    GridTile(1, 2),
    GridTile(1, 2),
    GridTile(1, 1),
    GridTile(1, 1),
    GridTile(1, 2),
    GridTile(1, 1),
    GridTile(1, 1),
    GridTile(1, 1),
    GridTile(1, 4),
    GridTile(1, 2),
    GridTile(1, 1),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Staggered',
      child: StaggeredGridView.countBuilder(
        mainAxisSpacing: 9,
        crossAxisSpacing: 9,
        cacheExtent: 5,
        addAutomaticKeepAlives: false,
        itemBuilder: (context, index) {
          return ContainTile(
            index: index,
            width: tiles[index].crossAxisCount * 100,
            height: tiles[index].mainAxisCount * 100,
          );
        },
        crossAxisCount: 2,
        staggeredTileBuilder: (int index) {
          return StaggeredTile.count(tiles[index].crossAxisCount,
              tiles[index].mainAxisCount.toDouble());
        },
        itemCount: tiles.length,
      ),
    );
  }
}

class GridTile {
  const GridTile(this.crossAxisCount, this.mainAxisCount);
  final int crossAxisCount;
  final int mainAxisCount;
}
