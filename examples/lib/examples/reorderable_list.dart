import 'package:examples/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ReorderablePage extends StatelessWidget {
  ReorderablePage({
    Key? key,
  }) : super(key: key);

  final List<StaggeredGridTile> widgets = [
    const StaggeredGridTile.count(
      crossAxisCellCount: 2,
      mainAxisCellCount: 2,
      child: Tile(index: 0),
    ),
    const StaggeredGridTile.count(
      crossAxisCellCount: 2,
      mainAxisCellCount: 1,
      child: Tile(index: 1),
    ),
    const StaggeredGridTile.count(
      crossAxisCellCount: 1,
      mainAxisCellCount: 1,
      child: Tile(index: 2),
    ),
    const StaggeredGridTile.count(
      crossAxisCellCount: 1,
      mainAxisCellCount: 1,
      child: Tile(index: 3),
    ),
    const StaggeredGridTile.count(
      crossAxisCellCount: 4,
      mainAxisCellCount: 2,
      child: Tile(index: 4),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Reorderable',
      child: ReorderableStaggeredLayout(
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: widgets,
        onReorder: (int oldIndex, int newIndex) {
          widgets.insert(newIndex, widgets.removeAt(oldIndex));
        },
      ),
    );
  }
}
