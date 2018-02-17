import 'dart:math';

import 'package:example/tile_widget.dart';
import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

enum StaggeredTileMode { count, extent, mixed }

class StatefulStaggeredGridView extends StatefulWidget {
  @override
  _StatefulStaggeredGridViewState createState() =>
      new _StatefulStaggeredGridViewState();
}

class _StatefulStaggeredGridViewState extends State<StatefulStaggeredGridView> {
  _StatefulStaggeredGridViewState()
      : _tileColor = Colors.green,
        _mainAxisSpacing = 4.0,
        _crossAxisSpacing = 4.0,
        _crossAxisCount = 4,
        _mainAxisExtent = 50.0,
        _itemCount = 20,
        _maxTileCrossAxisCount = 10,
        _maxTileRatio = 4,
        _maxTileMainAxisExtent = 100,
        _staggeredTileMode = StaggeredTileMode.count,
        _isConfigurationPanelExpanded = true{
    _tiles = _computeRandomTiles();
  }

  final Color _tileColor;
  double _mainAxisSpacing;
  double _crossAxisSpacing;
  double _mainAxisExtent;
  int _crossAxisCount;
  int _itemCount;
  bool _isConfigurationPanelExpanded;
  int _maxTileCrossAxisCount;
  int _maxTileRatio;
  int _maxTileMainAxisExtent;
  StaggeredTileMode _staggeredTileMode;
  List<StaggeredTile> _tiles;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new SafeArea(
          child: new Column(
        children: <Widget>[
          _buildConfigurationPanel(context),
          new Expanded(child: _buildStaggeredGridView(context)),
        ],
      )),
    );
  }

  Widget _buildConfigurationPanel(BuildContext context) {
    return new ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _isConfigurationPanelExpanded = !isExpanded;
        });
      },
      children: <ExpansionPanel>[
        new ExpansionPanel(
          isExpanded: _isConfigurationPanelExpanded,
          headerBuilder: (context, isSelected) =>
              const Center(child: const Text('Configuration Panel')),
          body: new Column(
            children: <Widget>[
              _buildMainAxisSpacingConfigurationPanel(context),
              _buildCrossAxisSpacingConfigurationPanel(context),
              _buildItemCountConfigurationPanel(context),
              _buildCrossAxisCountConfigurationPanel(context),
              _buildMainAxisExtentConfigurationPanel(context),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildMainAxisSpacingConfigurationPanel(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Slider(
            value: _mainAxisSpacing,
            label: '${_mainAxisSpacing.round()}',
            min: 0.0,
            max: 30.0,
            thumbOpenAtMin: false,
            onChanged: (double value) => setState(() {
                  _mainAxisSpacing = value;
                })),
        new Text('Main axis spacing'),
      ],
    );
  }

  Widget _buildCrossAxisSpacingConfigurationPanel(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Slider(
            value: _crossAxisSpacing,
            label: '${_crossAxisSpacing.round()}',
            min: 0.0,
            max: 30.0,
            thumbOpenAtMin: false,
            onChanged: (double value) => setState(() {
                  _crossAxisSpacing = value;
                })),
        new Text('Cross axis spacing'),
      ],
    );
  }

  Widget _buildItemCountConfigurationPanel(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Slider(
            value: _itemCount.toDouble(),
            label: '$_itemCount',
            min: 20.0,
            max: 50.0,
            divisions: 29,
            thumbOpenAtMin: false,
            onChanged: (double value) => setState(() {
                  _itemCount = value.toInt();
                  _tiles = _computeRandomTiles();
                })),
        new Text('Item count'),
      ],
    );
  }

  Widget _buildCrossAxisCountConfigurationPanel(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Slider(
            value: _crossAxisCount.toDouble(),
            label: '$_crossAxisCount',
            min: 2.0,
            max: 10.0,
            divisions: 7,
            thumbOpenAtMin: false,
            onChanged: (double value) => setState(() {
                  _crossAxisCount = value.toInt();
                })),
        new Text('Cross axis count'),
      ],
    );
  }

  Widget _buildMainAxisExtentConfigurationPanel(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Slider(
            value: _mainAxisExtent,
            label: '${_mainAxisExtent.round()}',
            min: 50.0,
            max: 100.0,
            thumbOpenAtMin: false,
            onChanged: (double value) => setState(() {
                  _mainAxisExtent = value;
                })),
        new Text('Main axis extent'),
      ],
    );
  }

  Widget _buildStaggeredGridView(BuildContext context) {
    return new StaggeredGridView.countBuilder(
        shrinkWrap: true,
        crossAxisCount: _crossAxisCount,
        crossAxisSpacing: _crossAxisSpacing,
        mainAxisSpacing: _mainAxisSpacing,
        itemCount: _itemCount,
        itemBuilder: _getChild,
        staggeredTileBuilder: _getTile);
  }

  Widget _getChild(BuildContext context, int index) {
    return new TileWidget(
        key: new ObjectKey(index), index: index, backgroundColor: _tileColor);
  }

  StaggeredTile _getTile(int index) {
    return index >= _itemCount ? null : _tiles[index];
  }

  List<StaggeredTile> _computeRandomTiles(){
    return new List.generate(_itemCount, _computeRandomTile);
  }

  StaggeredTile _computeRandomTile(int index){
    Random rnd = new Random();
    int crossAxisCount = rnd.nextInt(_maxTileCrossAxisCount) + 1;
    int ratio = rnd.nextInt(_maxTileRatio) + 1;
    int mainAxisExtent = rnd.nextInt(_maxTileMainAxisExtent - 50) + 51;

    switch (_staggeredTileMode) {
      case StaggeredTileMode.count:
        return new StaggeredTile.ratio(crossAxisCount, ratio);
      case StaggeredTileMode.extent:
        return new StaggeredTile.extent(
            crossAxisCount, mainAxisExtent.toDouble());
      default:
        if (rnd.nextBool()) {
          return new StaggeredTile.ratio(crossAxisCount, ratio);
        } else {
          return new StaggeredTile.extent(
              crossAxisCount, mainAxisExtent.toDouble());
        }
    }
  }
}
