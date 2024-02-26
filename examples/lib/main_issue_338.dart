import 'package:examples/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Staggered Grid View Demo',
      showPerformanceOverlay: true,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverMasonryGrid.count(
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childCount: 20,
            itemBuilder: (context, index) {
              return Tile(
                index: index,
                extent: (index % 5 + 1) * 100,
              );
            },
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 2000,
              color: Colors.amber,
            ),
          ),
          SliverMasonryGrid.count(
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childCount: 40,
            itemBuilder: (context, index) {
              return Tile(
                index: index,
                extent: (index % 5 + 1) * 100,
              );
            },
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 2000,
              color: Colors.red,
            ),
          ),
          SliverMasonryGrid.count(
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childCount: 60,
            itemBuilder: (context, index) {
              return Tile(
                index: index,
                extent: (index % 5 + 1) * 100,
              );
            },
          ),
          SliverGrid.count(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            children: List.generate(
              40,
              (index) => Tile(index: index),
            ).toList(),
          ),
        ],
      ),
    );
  }
}
