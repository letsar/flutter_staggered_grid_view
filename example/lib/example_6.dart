import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Example06 extends StatefulWidget {
  @override
  _Example06State createState() => new _Example06State();
}

class _Example06State extends State<Example06> {
  _Example06State() : crossAxisCount = 4;
  List<int> _sizes = [
    1,
    2,
    3,
    1,
    2,
    1,
    1,
    1,
    2,
    4,
    2,
    1,
    1,
    2,
    3,
    1,
    2,
    4,
  ];

  int _selectedIndex;

  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('dynamic resizing'),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(4.0),
        child: new StaggeredGridView.countBuilder(
          crossAxisCount: crossAxisCount,
          itemCount: _sizes.length,
          itemBuilder: (BuildContext context, int index) => new _Example06Tile(
                key: new ObjectKey(index),
                index: index,
                size: _sizes[index],
                onSizeDown: _handleSizeDown,
                onSizeUp: _handleSizeUp,
                onSelectedItemChanged: _handleSelectedItemChanged,
                maxSize: crossAxisCount,
                isSelected: _selectedIndex == index,
              ),
          staggeredTileBuilder: (int index) =>
              new StaggeredTile.count(_sizes[index], _sizes[index]),
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
        ),
      ),
    );
  }

  void _handleSizeDown(int index) {
    var currentSize = _sizes[index];
    if (currentSize > 0) {
      setState(() {
        _sizes[index] = currentSize - 1;
      });
    }
  }

  void _handleSizeUp(int index) {
    var currentSize = _sizes[index];
    if (currentSize < crossAxisCount) {
      setState(() {
        _sizes[index] = currentSize + 1;
      });
    }
  }

  void _handleSelectedItemChanged(int index) {
    setState(() {
      _selectedIndex = _selectedIndex == index ? null : index;
    });
  }
}

class _Example06Tile extends StatelessWidget {
  const _Example06Tile({
    Key key,
    @required this.index,
    @required this.size,
    @required this.onSizeDown,
    @required this.onSizeUp,
    @required this.onSelectedItemChanged,
    @required this.maxSize,
    @required this.isSelected,
  }) : super(key: key);

  final int index;
  final int size;
  final ValueChanged<int> onSizeDown;
  final ValueChanged<int> onSizeUp;
  final ValueChanged<int> onSelectedItemChanged;
  final int maxSize;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = <Widget>[
      new Padding(
        padding: new EdgeInsets.all(isSelected ? 8.0 : 0.0),
        child: new Card(
          color: Colors.green,
          child: new InkWell(
            onLongPress: () => onSelectedItemChanged(index),
            child: new Center(
              child: new CircleAvatar(
                backgroundColor: Colors.white,
                child: new Text('$index'),
              ),
            ),
          ),
        ),
      ),
    ];

    if (isSelected) {
      widgets.add(_buildTileButton(_kCloseTileButton));

      if (size > 1) {
        widgets.add(_buildTileButton(_kSizeDownTileButton));
      }

      if (size < maxSize) {
        widgets.add(_buildTileButton(_kSizeUpTileButton));
      }
    }

    return new Stack(children: widgets);
  }

  Widget _buildTileButton(_TileButton tileButton) {
    return new Positioned(
      top: tileButton.top,
      bottom: tileButton.bottom,
      left: tileButton.left,
      right: tileButton.right,
      child: new GestureDetector(
        onTap: () => tileButton.onTap(this),
        child: new CircleAvatar(
          radius: 16.0,
          backgroundColor: Colors.teal,
          child: new Text(tileButton.text),
        ),
      ),
    );
  }
}

final _TileButton _kSizeDownTileButton = new _TileButton(
  text: '-',
  isLeft: true,
  isTop: false,
  onTap: (_Example06Tile tile) => tile.onSizeDown(tile.index),
);

final _TileButton _kSizeUpTileButton = new _TileButton(
  text: '+',
  isLeft: false,
  isTop: false,
  onTap: (_Example06Tile tile) => tile.onSizeUp(tile.index),
);

final _TileButton _kCloseTileButton = new _TileButton(
  text: 'x',
  isLeft: false,
  isTop: true,
  onTap: (_Example06Tile tile) => tile.onSelectedItemChanged(tile.index),
);

class _TileButton {
  const _TileButton({
    @required this.text,
    @required this.onTap,
    @required bool isLeft,
    @required bool isTop,
  })  : bottom = isTop ? null : 0.0,
        top = isTop ? 0.0 : null,
        left = isLeft ? 0.0 : null,
        right = isLeft ? null : 0.0;

  final double bottom;
  final double top;
  final double left;
  final double right;
  final String text;
  final ValueChanged<_Example06Tile> onTap;
}
