import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common.dart';

Widget sized(double width, Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: width, height: 600, child: child),
    ),
  );
}

void main() {
  // https://github.com/letsar/flutter_staggered_grid_view/issues/362
  for (final width in <double>[0, 2]) {
    testWidgets('StaggeredGrid with spacings larger than its width ($width)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        sized(
          width,
          StaggeredGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: const [
              StaggeredGridTile.count(
                crossAxisCellCount: 1,
                mainAxisCellCount: 1,
                child: Tile(index: 0),
              ),
              StaggeredGridTile.fit(
                crossAxisCellCount: 1,
                child: Tile(index: 1),
              ),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('StaggeredGrid in reverse with tiles fitting their content',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      sized(
        400,
        StaggeredGrid.count(
          crossAxisCount: 2,
          axisDirection: AxisDirection.up,
          children: const [
            StaggeredGridTile.fit(
              crossAxisCellCount: 1,
              child: Tile(index: 0, height: 100),
            ),
            StaggeredGridTile.fit(
              crossAxisCellCount: 1,
              child: Tile(index: 1, height: 50),
            ),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getTopLeft(find.text('0')).dy, 0);
  });

  // https://github.com/letsar/flutter_staggered_grid_view/issues/344
  testWidgets('StaggeredGrid.custom with an exported delegate',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      sized(
        400,
        StaggeredGrid.custom(
          delegate: const StaggeredGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 100,
          ),
          children: const [Tile(index: 0)],
        ),
      ),
    );
    expect(tester.getSize(find.byType(Tile)).width, 100);
  });

  // https://github.com/letsar/flutter_staggered_grid_view/issues/221
  for (final MapEntry(key: name, value: repeatPattern) in {
    'same': QuiltedGridRepeatPattern.same,
    'inverted': QuiltedGridRepeatPattern.inverted,
    'mirrored': QuiltedGridRepeatPattern.mirrored,
  }.entries) {
    testWidgets('Quilted tiles which do not fit in the remaining space ($name)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        sized(
          300,
          GridView.custom(
            gridDelegate: SliverQuiltedGridDelegate(
              crossAxisCount: 3,
              repeatPattern: repeatPattern,
              pattern: const [
                QuiltedGridTile(1, 1),
                QuiltedGridTile(1, 1),
                QuiltedGridTile(2, 2),
              ],
            ),
            childrenDelegate: SliverChildBuilderDelegate(
              (context, index) => Tile(index: index),
              childCount: 30,
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);

      // The 2x2 tile is placed below the two 1x1 tiles.
      expect(
        tester.getRect(find.text('2')),
        const Rect.fromLTWH(0, 100, 200, 200),
      );
    });
  }

  // https://github.com/letsar/flutter_staggered_grid_view/issues/361
  for (final width in <double>[0, 10, 400]) {
    testWidgets('patterned grids with padding ($width)',
        (WidgetTester tester) async {
      for (final delegate in <SliverGridDelegate>[
        SliverStairedGridDelegate(
          pattern: const [
            StairedGridTile(1.0, 10 / 6),
            StairedGridTile(0.5, 1),
            StairedGridTile(0.5, 1),
          ],
        ),
        SliverWovenGridDelegate.count(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          pattern: const [
            WovenGridTile(1),
            WovenGridTile(5 / 7),
          ],
        ),
        SliverQuiltedGridDelegate(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          pattern: const [QuiltedGridTile(1, 1)],
        ),
      ]) {
        await tester.pumpWidget(
          sized(
            width,
            GridView.custom(
              padding: const EdgeInsets.all(10),
              gridDelegate: delegate,
              childrenDelegate: SliverChildBuilderDelegate(
                (context, index) => Tile(index: index),
                childCount: 30,
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull, reason: '$delegate');
      }
    });
  }

  testWidgets(
      'masonry and aligned grids with a max cross axis extent and no '
      'width', (WidgetTester tester) async {
    await tester.pumpWidget(
      sized(
        0,
        MasonryGridView.extent(
          maxCrossAxisExtent: 100,
          itemCount: 10,
          itemBuilder: (context, index) => Tile(index: index, height: 50),
        ),
      ),
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      sized(
        0,
        AlignedGridView.extent(
          maxCrossAxisExtent: 100,
          itemCount: 10,
          itemBuilder: (context, index) => Tile(index: index, height: 50),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
