import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'tile_widget.dart';

class StaggeredGridViewPage extends StatelessWidget {
  const StaggeredGridViewPage.count({
    @required this.title,
    @required this.crossAxisCount,
    @required this.tiles,
    this.mainAxisSpacing = 4,
    this.crossAxisSpacing = 4,
  })  : _staggeredGridViewMode = _StaggeredGridViewMode.count,
        maxCrossAxisExtent = null;

  const StaggeredGridViewPage.extent({
    @required this.title,
    @required this.maxCrossAxisExtent,
    @required this.tiles,
    this.mainAxisSpacing = 4,
    this.crossAxisSpacing = 4,
  })  : _staggeredGridViewMode = _StaggeredGridViewMode.extent,
        crossAxisCount = null;

  static const EdgeInsetsGeometry padding = EdgeInsets.symmetric(horizontal: 4);

  final String title;
  final List<StaggeredTile> tiles;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double maxCrossAxisExtent;
  final _StaggeredGridViewMode _staggeredGridViewMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _buildStaggeredGridView(context)));
  }

  Widget _buildStaggeredGridView(BuildContext context) {
    switch (_staggeredGridViewMode) {
      case _StaggeredGridViewMode.count:
        return StaggeredGridView.countBuilder(
          crossAxisCount: crossAxisCount,
          itemCount: tiles.length,
          itemBuilder: _getChild,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          padding: padding,
          staggeredTileBuilder: _getStaggeredTile,
        );
      default:
        return StaggeredGridView.extentBuilder(
          maxCrossAxisExtent: maxCrossAxisExtent,
          itemCount: tiles.length,
          itemBuilder: _getChild,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          padding: padding,
          staggeredTileBuilder: _getStaggeredTile,
        );
    }
  }

  StaggeredTile _getStaggeredTile(int i) {
    return i >= tiles.length ? null : tiles[i];
  }

  TileWidget _getChild(BuildContext context, int index) {
    return TileWidget(key: ObjectKey(index), index: index);
  }
}

enum _StaggeredGridViewMode { count, extent }
