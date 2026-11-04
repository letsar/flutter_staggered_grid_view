import 'package:collection/collection.dart';
import 'package:flutter_staggered_grid_view_example/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class StaggeredPage extends StatefulWidget {
  const StaggeredPage({
    super.key,
  });

  // With these tiles, the dense placement fills the hole after the first
  // tile with the third one, while the sparse placement keeps their order.
  static const tiles = [
    GridTile(2, 2),
    GridTile(3, 1),
    GridTile(1, 1),
    GridTile(2, 1),
    GridTile(1, 2),
    GridTile(2, 2),
    GridTile(1, 1),
    GridTile(3, 1),
    GridTile(1, 1),
    GridTile(4, 1),
  ];

  @override
  State<StaggeredPage> createState() => _StaggeredPageState();
}

class _StaggeredPageState extends State<StaggeredPage> {
  /// Whether the tiles are placed in their order, leaving the holes empty.
  bool sparse = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Staggered',
      actions: [
        IconButton(
          tooltip: sparse ? 'Fill the holes' : 'Keep the order',
          isSelected: sparse,
          icon: const Icon(Icons.format_list_numbered),
          onPressed: () => setState(() => sparse = !sparse),
        ),
      ],
      child: SingleChildScrollView(
        child: StaggeredGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          placement: sparse
              ? StaggeredGridPlacement.sparse
              : StaggeredGridPlacement.dense,
          children: [
            ...StaggeredPage.tiles.mapIndexed((index, tile) {
              return StaggeredGridTile.count(
                crossAxisCellCount: tile.crossAxisCount,
                mainAxisCellCount: tile.mainAxisCount,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ImageTile(
                      index: index,
                      width: tile.crossAxisCount * 100,
                      height: tile.mainAxisCount * 100,
                    ),
                    // The index shows the order of the tiles.
                    Align(
                      alignment: Alignment.topLeft,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: Text('$index'),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class GridTile {
  const GridTile(this.crossAxisCount, this.mainAxisCount);
  final int crossAxisCount;
  final int mainAxisCount;
}
