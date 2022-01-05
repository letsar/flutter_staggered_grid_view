import 'package:examples/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class NewAlignedPage extends StatelessWidget {
  const NewAlignedPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Aligned',
      child: CustomScrollView(
        cacheExtent: 0,
        slivers: [
          SliverNewAlignedGrid(
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Tile(
                  index: index,
                  extent: (index % 7 + 1) * 30,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
