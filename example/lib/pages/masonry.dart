import 'dart:math';

import 'package:flutter_staggered_grid_view_example/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MasonryPage extends StatefulWidget {
  const MasonryPage({
    super.key,
  });

  @override
  State<MasonryPage> createState() => _MasonryPageState();
}

class _MasonryPageState extends State<MasonryPage> {
  final rnd = Random();
  late List<int> extents;
  int crossAxisCount = 4;

  /// Whether a banner spanning the whole width is shown every 9 children.
  bool showBanners = false;

  bool isBanner(int index) => showBanners && index % 9 == 0;

  @override
  void initState() {
    super.initState();
    extents = List<int>.generate(10000, (int index) => rnd.nextInt(5) + 1);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Masonry',
      actions: [
        IconButton(
          tooltip: showBanners ? 'Hide banners' : 'Show banners',
          isSelected: showBanners,
          icon: const Icon(Icons.view_agenda_outlined),
          selectedIcon: const Icon(Icons.view_agenda),
          onPressed: () => setState(() => showBanners = !showBanners),
        ),
      ],
      child: MasonryGridView.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        isFullSpan: isBanner,
        itemBuilder: (context, index) {
          if (isBanner(index)) {
            return Container(
              height: 80,
              color: Colors.amber,
              alignment: Alignment.center,
              child: Text(
                'Banner $index',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }
          final height = extents[index] * 100;
          return ImageTile(
            index: index,
            width: 100,
            height: height,
          );
        },
        itemCount: extents.length,
      ),
    );
  }
}
