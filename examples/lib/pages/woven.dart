import 'package:examples/common.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class WovenPage extends StatelessWidget {
  const WovenPage({
    Key? key,
  }) : super(key: key);

  static const pattern = [
    WovenGridTile(1),
    WovenGridTile(
      5 / 7,
      crossAxisRatio: 0.9,
      alignment: AlignmentDirectional.centerEnd,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Woven',
      child: GridView.custom(
        gridDelegate: SliverWovenGridDelegate.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          pattern: pattern,
        ),
        childrenDelegate: SliverChildBuilderDelegate(
          (context, index) {
            final tile = pattern[index % pattern.length];
            return ImageTile(
              index: index,
              width: (200 * tile.aspectRatio).ceil(),
              height: 200,
            );
          },
        ),
      ),
    );
  }
}
