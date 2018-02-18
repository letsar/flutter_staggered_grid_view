import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

const List<Color> _kColors = const <Color>[
  Colors.green,
  Colors.blue,
  Colors.red,
  Colors.pink,
  Colors.indigo,
  Colors.purple,
  Colors.blueGrey,
];

List<StaggeredTile> _generateRandomTiles(int count) {
  Random rnd = new Random();
  return new List.generate(count,
      (i) => new StaggeredTile.count(rnd.nextInt(4) + 1, rnd.nextInt(6) + 1));
}

class Example05 extends StatelessWidget {
  Example05()
      : _random = new Random(),
        _tiles = _generateRandomTiles(_kItemCount);

  static const int _kItemCount = 1000;
  final Random _random;
  final List<StaggeredTile> _tiles;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Random tiles'),
        ),
        body: new StaggeredGridView.countBuilder(
          primary: false,
          crossAxisCount: 4,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
          staggeredTileBuilder: _getTile,
          itemBuilder: _getChild,
          itemCount: _kItemCount,
        ));
  }

  StaggeredTile _getTile(int index) => _tiles[index];

  Widget _getChild(BuildContext context, int index) {
    return new Container(
      key: new ObjectKey('$index'),
      color: _kColors[_random.nextInt(_kColors.length)],
      child: new Center(
        child: new CircleAvatar(
          backgroundColor: Colors.white,
          child: new Text('$index'),
        ),
      ),
    );
  }
}
