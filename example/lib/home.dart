import 'package:example/routes.dart';
import 'package:example/staggered_view_1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

const List<StaggeredTile> _tiles = const <StaggeredTile>[
  const StaggeredTile.ratio(2, 0.5),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 1),

  const StaggeredTile.ratio(2, 0.5),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 1),
];

List<Widget> _children = <Widget>[
  new HomeTile('Staggered layouts', Colors.green),
  const HomeTile('count', Colors.green, staggeredGridViewCountRoute),
  const HomeTile('extent', Colors.green, staggeredGridViewCountRoute),

  new HomeTile('Spannable layouts', Colors.red),
  const HomeTile('count', Colors.red, staggeredGridViewCountRoute),
  const HomeTile('extent', Colors.red, staggeredGridViewCountRoute),
];

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('StaggeredGridView Demo'),
        ),
        body: new Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: new StaggeredGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            children: _children,
            staggeredTiles: _tiles,
          ),
        ));
  }
}

class HomeTile extends StatelessWidget {
  const HomeTile(this.title, this.backgroundColor, [this.route]);

  final String title;
  final String route;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return new Card(
      color: backgroundColor,
      child: new InkWell(
        onTap:
            route == null ? null : () => Navigator.of(context).pushNamed(route),
        child: new Center(
          child: new Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).primaryTextTheme.title.copyWith(
                  color:
                      ThemeData.estimateBrightnessForColor(backgroundColor) ==
                              Brightness.dark
                          ? Colors.white
                          : Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
