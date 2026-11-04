import 'package:flutter_staggered_grid_view_example/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class StairedPage extends StatefulWidget {
  const StairedPage({
    super.key,
  });

  // The pattern has two tracks of two tiles, so that the direction of the
  // second one can be seen.
  static const pattern = [
    StairedGridTile(0.5, 1),
    StairedGridTile(0.5, 3 / 4),
    StairedGridTile(0.5, 3 / 4),
    StairedGridTile(0.5, 1),
    StairedGridTile(1.0, 10 / 4),
  ];

  @override
  State<StairedPage> createState() => _StairedPageState();
}

class _StairedPageState extends State<StairedPage> {
  /// Whether the tracks go back and forth.
  bool alternateDirections = true;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Staired',
      actions: [
        IconButton(
          tooltip: alternateDirections
              ? 'Place all the tracks in the same direction'
              : 'Alternate the directions',
          isSelected: !alternateDirections,
          icon: const Icon(Icons.format_list_numbered),
          onPressed: () =>
              setState(() => alternateDirections = !alternateDirections),
        ),
      ],
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: GridView.custom(
          scrollDirection: Axis.vertical,
          gridDelegate: SliverStairedGridDelegate(
            mainAxisSpacing: 24,
            crossAxisSpacing: 48,
            alternateDirections: alternateDirections,
            pattern: StairedPage.pattern,
          ),
          childrenDelegate: SliverChildBuilderDelegate(
            (context, index) {
              final tile =
                  StairedPage.pattern[index % StairedPage.pattern.length];
              return Stack(
                fit: StackFit.expand,
                children: [
                  ImageTile(
                    index: index,
                    width: (tile.aspectRatio * 200).ceil(),
                    height: 200,
                  ),
                  // The index shows the order of the tiles.
                  Align(
                    alignment: Alignment.topLeft,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      child: Text('$index'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
