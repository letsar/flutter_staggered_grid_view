import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showPerformanceOverlay: true,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final rnd = Random();
  late List<int> extents;
  int crossAxisCount = 4;

  @override
  void initState() {
    super.initState();
    extents = List<int>.generate(10000, (int index) => rnd.nextInt(5) + 1);
    // extents = List<int>.generate(100, (int index) => (index % 4) + 1);
    // extents = [2, 2, 2, 3, 4, 4, 1, 1, 2, 1, 4, 4, 4, 4];
    // extents = [2, 2, 2, 2, 4, 4, 3, 2, 2, 1, 4, 4, 4, 4];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Slider(
                min: 1,
                max: 6,
                value: crossAxisCount.toDouble(),
                divisions: 5,
                onChanged: (double value) {
                  setState(() {
                    crossAxisCount = value.toInt();
                  });
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 500,
              child: IndexedTiles(
                crossAxisCount: crossAxisCount,
                children: [
                  ...extents.mapIndexed((int index, int extent) {
                    if (index == 1) {
                      return const VaryingSizeOverTime();
                    }
                    return Tile(extent: extent * 100.0);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IndexedTiles extends StatelessWidget {
  const IndexedTiles({
    Key? key,
    required this.crossAxisCount,
    required this.children,
  }) : super(key: key);

  final int crossAxisCount;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: CustomScrollView(
        // reverse: true,
        slivers: [
          SliverMasonryGrid(
            delegate: SliverChildListDelegate(
              [
                for (int i = 0; i < children.length; i++)
                  IndexedTile(
                    index: i,
                    child: children[i],
                  ),
              ],
            ),
            gridDelegate: SliverMasonryGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
            ),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          )
        ],
      ),
    );
  }
}

class IndexedTile extends StatelessWidget {
  const IndexedTile({
    Key? key,
    required this.index,
    required this.child,
  }) : super(key: key);

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Center(
            child: CircleAvatar(
              minRadius: 20,
              maxRadius: 20,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              child: Text('$index', style: const TextStyle(fontSize: 20)),
            ),
          ),
        ),
      ],
    );
  }
}

class VaryingSizeOverTime extends StatefulWidget {
  const VaryingSizeOverTime({
    Key? key,
  }) : super(key: key);

  @override
  _VaryingSizeOverTimeState createState() => _VaryingSizeOverTimeState();
}

class _VaryingSizeOverTimeState extends State<VaryingSizeOverTime>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
    lowerBound: 100,
    upperBound: 400,
  );

  @override
  void initState() {
    super.initState();
    controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
        valueListenable: controller,
        builder: (context, extent, child) {
          return Tile(
            extent: extent,
          );
        });
  }
}

class Tile extends StatelessWidget {
  const Tile({
    Key? key,
    required this.extent,
  }) : super(key: key);

  final double extent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1.0,
        ),
        color: Colors.red,
      ),
      height: extent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text('$extent'),
        ),
      ),
    );
  }
}
