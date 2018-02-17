import 'package:example/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

const List<StaggeredTile> _tiles = const <StaggeredTile>[
  const StaggeredTile.ratio(2, 0.5),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(2, 0.5),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 1),
  const StaggeredTile.ratio(1, 1),
];

List<Widget> _children = <Widget>[
  const HomeHeaderTile('Staggered layouts', Colors.indigo),
  const HomeTile(
      'count constructor\nratio tile', Colors.indigo, staggeredCountRatioRoute),
  const HomeTile('extent constructor\nratio tile', Colors.indigo,
      staggeredExtentRatioRoute),
  const HomeTile('count constructor\nextent tile', Colors.indigo,
      staggeredCountExtentRoute),
  const HomeTile('extent constructor\nextent tile', Colors.indigo,
      staggeredExtentExtentRoute),
  const HomeHeaderTile('Spannable layouts', Colors.purple),
  const HomeTile(
      'count constructor\nratio tile', Colors.purple, spannableCountRatioRoute),
  const HomeTile('extent constructor\nratio tile', Colors.purple,
      spannableExtentRatioRoute),
  const HomeTile('count constructor\nextent tile', Colors.purple,
      spannableCountExtentRoute),
  const HomeTile('extent constructor\nextent tile', Colors.purple,
      spannableExtentExtentRoute),
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

class HomeHeaderTile extends StatelessWidget {
  const HomeHeaderTile(this.title, this.backgroundColor);

  final String title;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(
          border: new Border(
              bottom: new BorderSide(
        color: backgroundColor,
      ))),
      child: new Align(
        alignment: Alignment.bottomCenter,
        child: new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Text(
            title,
            textAlign: TextAlign.center,
            style: Theme
                .of(context)
                .primaryTextTheme
                .title
                .copyWith(color: backgroundColor),
          ),
        ),
      ),
    );
  }
}

class HomeTile extends StatelessWidget {
  const HomeTile(this.title, this.backgroundColor, this.route);

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
