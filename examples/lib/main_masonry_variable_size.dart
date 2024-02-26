import 'package:examples/common.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

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
      body: MasonryGridView.extent(
        cacheExtent: 0,
        dragStartBehavior: DragStartBehavior.down,
        maxCrossAxisExtent: 200,
        itemBuilder: (context, index) {
          return Tile(
            key: ValueKey(index),
            index: index,
            extent: ((index % 4) + 1) * 100,
          );
        },
        itemCount: 12,
      ),
    );
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverMasonryGrid.count(
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childCount: 40,
            itemBuilder: (context, index) {
              if (index == 1) {
                return const AnimatedTile(
                  index: 1,
                  minExtent: 100,
                  maxExtent: 400,
                  backgroundColor: Colors.red,
                );
              }
              return Tile(
                index: index,
                extent: (index % 5 + 1) * 100,
              );
            },
          ),
        ],
      ),
    );
  }
}
