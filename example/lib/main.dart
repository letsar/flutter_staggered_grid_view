import 'package:example/routes.dart';
import 'package:example/stateful_staggered_grid_view.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'StaggeredGridView Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new StatefulStaggeredGridView(),
    );
  }
}


