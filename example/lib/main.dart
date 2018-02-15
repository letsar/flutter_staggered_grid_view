import 'package:example/staggered_grid_view_count.dart';
import 'package:example/staggered_view_1.dart';
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
      home: new StaggeredView(), // new StaggeredGridViewCountPage(),
    );
  }
}