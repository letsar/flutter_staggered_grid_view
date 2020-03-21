import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'routes.dart';

const List<StaggeredTile> _tiles = const <StaggeredTile>[
  StaggeredTile.count(2, 0.5),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(2, 0.5),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(2, 0.5),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1),
  //StaggeredTile.count(1, 1),
];

List<Widget> _children = const <Widget>[
  HomeHeaderTile('Staggered layouts', Colors.indigo),
  HomeTile(
      'count constructor\ncount tile', Colors.indigo, staggeredCountCountRoute),
  HomeTile('extent constructor\ncount tile', Colors.indigo,
      staggeredExtentCountRoute),
  HomeTile('count constructor\nextent tile', Colors.indigo,
      staggeredCountExtentRoute),
  HomeTile('extent constructor\nextent tile', Colors.indigo,
      staggeredExtentExtentRoute),
  HomeHeaderTile('Spannable layouts', Colors.purple),
  HomeTile(
      'count constructor\ncount tile', Colors.purple, spannableCountCountRoute),
  HomeTile('extent constructor\ncount tile', Colors.purple,
      spannableExtentCountRoute),
  HomeTile('count constructor\nextent tile', Colors.purple,
      spannableCountExtentRoute),
  HomeTile('extent constructor\nextent tile', Colors.purple,
      spannableExtentExtentRoute),
  HomeHeaderTile('More examples', Colors.pink),
  HomeTile('example 01', Colors.pink, example01),
  HomeTile('example 02', Colors.pink, example02),
  HomeTile('example 03', Colors.pink, example03),
  HomeTile('example 04', Colors.pink, example04),
  HomeTile('random tiles', Colors.pink, example05),
  HomeTile('dynamic resizing', Colors.pink, example06),
  HomeTile('dynamic tile sizes', Colors.pink, example07),
  HomeTile('vertical random dynamic tile sizes', Colors.pink, example08),
  HomeTile('hoizontal random dynamic tile sizes', Colors.pink, example09),
  //HomeTile('test', Colors.pink, exampleTests),
];

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('StaggeredGridView Demo'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: StaggeredGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            staggeredTiles: _tiles,
            children: _children,
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
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
        color: backgroundColor,
      ))),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .primaryTextTheme
                .headline6!
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
    return Card(
      color: backgroundColor,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(route),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).primaryTextTheme.headline6!.copyWith(
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
