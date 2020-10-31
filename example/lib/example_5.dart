import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

const List<Color> _kColors = <Color>[
  Colors.green,
  Colors.blue,
  Colors.red,
  Colors.pink,
  Colors.indigo,
  Colors.purple,
  Colors.blueGrey,
];

List<StaggeredTile> _generateRandomTiles(int count) {
  final rnd = Random();
  return List.generate(
      count,
      (i) => StaggeredTile.count(
          rnd.nextInt(4) + 1, rnd.nextInt(6).toDouble() + 1));
}

List<Color> _generateRandomColors(int count) {
  final rnd = Random();
  return List.generate(count, (i) => _kColors[rnd.nextInt(_kColors.length)]);
}

class Example05 extends StatelessWidget {
  Example05()
      : _tiles = _generateRandomTiles(_kItemCount).toList(),
        _colors = _generateRandomColors(_kItemCount).toList();

  static const int _kItemCount = 1000;
  final List<StaggeredTile> _tiles;
  final List<Color> _colors;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('random tiles'),
        ),
        body: StaggeredGridView.countBuilder(
          primary: false,
          crossAxisCount: 4,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          staggeredTileBuilder: _getTile,
          itemBuilder: _getChild,
          itemCount: _kItemCount,
        ));
  }

  StaggeredTile _getTile(int index) => _tiles[index];

  Widget _getChild(BuildContext context, int index) {
    return Container(
      key: ObjectKey('$index'),
      color: _colors[index],
      child: Center(
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: Text('$index'),
        ),
      ),
    );
  }
}
