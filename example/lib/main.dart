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
      home: const WovenPage(),
    );
  }
}

class WovenPage extends StatelessWidget {
  const WovenPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Woven'),
      ),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: GridView.custom(
          scrollDirection: Axis.vertical,
          gridDelegate: SliverWovenGridDelegate.count(
            crossAxisCount: 4,
            pattern: const [
              WovenGridTile(1),
              WovenGridTile(
                5 / 7,
                crossAxisRatio: 0.9,
                alignment: AlignmentDirectional.centerEnd,
              ),
            ],
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            // tileBottomSpace: 24,
          ),
          childrenDelegate: SliverChildBuilderDelegate(
            (context, index) {
              return IndexedTile(
                index: index,
                child: const Tile(
                    // bottomSpace: 24,
                    ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ShiftedPage extends StatelessWidget {
  const ShiftedPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shifted'),
      ),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: GridView.custom(
          scrollDirection: Axis.vertical,
          gridDelegate: SliverShiftedGridDelegate(
            pattern: const [
              ShiftedGridTile(0.5, 1),
              ShiftedGridTile(0.5, 3 / 4),
              ShiftedGridTile(1.0, 10 / 4),
            ],
            crossAxisSpacing: 96,
            mainAxisSpacing: 48,
            startCrossAxisDirectionReversed: true,
            tileBottomSpace: 24,
          ),
          childrenDelegate: SliverChildBuilderDelegate(
            (context, index) {
              return IndexedTile(
                index: index,
                child: const Tile(
                  bottomSpace: 24,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class QuiltedPage extends StatelessWidget {
  const QuiltedPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quilted'),
      ),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: GridView.custom(
          gridDelegate: SliverQuiltedGridDelegate(
            crossAxisCount: 4,
            crossAxisSpacing: 4,
            mainAxisSpacing: 100,
            pattern: const [
              QuiltedGridTile(2, 2),
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 2),
              QuiltedGridTile(1, 2),
              QuiltedGridTile(2, 2),
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 1),
            ],
          ),
          childrenDelegate: SliverChildBuilderDelegate(
            (context, index) {
              return IndexedTile(
                index: index,
                child: const Tile(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class StaggeredPage extends StatelessWidget {
  const StaggeredPage({
    Key? key,
  }) : super(key: key);

  static const tiles = [
    GridTile(2, 2),
    GridTile(2, 1),
    GridTile(1, 2),
    GridTile(1, 1),
    GridTile(2, 2),
    GridTile(1, 2),
    GridTile(1, 1),
    GridTile(3, 1),
    GridTile(1, 1),
    GridTile(4, 1),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staggered'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: StaggeredGrid.count(
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: [
              ...tiles.mapIndexed((index, tile) {
                return StaggeredGridTile.count(
                  crossAxisCellCount: tile.crossAxisCount,
                  mainAxisCellCount: tile.mainAxisCount,
                  child: IndexedTile(
                    index: index,
                    child: const Tile(),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class MasonryPage extends StatefulWidget {
  const MasonryPage({
    Key? key,
    this.title = 'Flutter Demo Home Page',
  }) : super(key: key);

  final String title;

  @override
  State<MasonryPage> createState() => _MasonryPageState();
}

class _MasonryPageState extends State<MasonryPage> {
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
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Align(
              alignment: Alignment.bottomCenter,
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
          Expanded(
            child: MasonryIndexedTiles(
              crossAxisCount: crossAxisCount,
              children: [
                ...extents.mapIndexed((int index, int extent) {
                  // if (index == 1) {
                  //   return const VaryingSizeOverTime();
                  // }
                  return Tile(extent: extent * 100.0);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MasonryIndexedTiles extends StatelessWidget {
  const MasonryIndexedTiles({
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
            // gridDelegate: SliverMasonryGridDelegateWithFixedCrossAxisCount(
            //   crossAxisCount: crossAxisCount,
            // ),
            gridDelegate: const SliverMasonryGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 100,
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
    this.extent,
    this.bottomSpace,
  }) : super(key: key);

  final double? extent;
  final double? bottomSpace;

  @override
  Widget build(BuildContext context) {
    final child = Container(
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

    if (bottomSpace == null) {
      return child;
    }

    return Column(
      children: [
        Expanded(child: child),
        Container(
          height: bottomSpace,
          color: Colors.green,
        )
      ],
    );
  }
}

class GridTile {
  const GridTile(this.crossAxisCount, this.mainAxisCount);
  final int crossAxisCount;
  final int mainAxisCount;
}
