import 'package:flutter/material.dart';

import 'routes.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'StaggeredGridView Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: routes,
    );
  }
}
