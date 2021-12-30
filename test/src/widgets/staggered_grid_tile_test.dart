import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/src/widgets/staggered_grid.dart';
import 'package:flutter_staggered_grid_view/src/widgets/staggered_grid_tile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common.dart';

void main() {
  testWidgets('StaggeredGridTile.extent control test',
      (WidgetTester tester) async {
    // Screen size is 800x600 in the test environment.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: StaggeredGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: const [
            StaggeredGridTile.extent(
              crossAxisCellCount: 2,
              mainAxisExtent: 200,
              child: Tile(index: 0),
            ),
            StaggeredGridTile.extent(
              crossAxisCellCount: 2,
              mainAxisExtent: 100,
              child: Tile(index: 1),
            ),
            StaggeredGridTile.extent(
              crossAxisCellCount: 1,
              mainAxisExtent: 100,
              child: Tile(index: 2),
            ),
            StaggeredGridTile.extent(
              crossAxisCellCount: 1,
              mainAxisExtent: 100,
              child: Tile(index: 3),
            ),
            StaggeredGridTile.extent(
              crossAxisCellCount: 4,
              mainAxisExtent: 200,
              child: Tile(index: 4),
            ),
          ],
        ),
      ),
    );

    void _expectSize(int index, Size size) {
      expect(tester.getSize(find.text('$index')), equals(size));
    }

    void _expectTopLeft(int index, Offset topLeft) {
      expect(tester.getTopLeft(find.text('$index')), equals(topLeft));
    }

    const s1 = 197.0;
    const s2 = 398.0;
    const s3 = 599.0;
    const s4 = 800.0;
    _expectSize(0, const Size(s2, 200));
    _expectSize(1, const Size(s2, 100));
    _expectSize(2, const Size(s1, 100));
    _expectSize(3, const Size(s1, 100));
    _expectSize(4, const Size(s4, 200));

    _expectTopLeft(0, const Offset(0, 0));
    _expectTopLeft(1, const Offset(s2 + 4, 0));
    _expectTopLeft(2, const Offset(s2 + 4, 104));
    _expectTopLeft(3, const Offset(s3 + 4, 104));
    _expectTopLeft(4, const Offset(0, 208));
  });

  testWidgets('StaggeredGridTile.fit control test',
      (WidgetTester tester) async {
    // Screen size is 800x600 in the test environment.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: StaggeredGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: const [
            StaggeredGridTile.fit(
              crossAxisCellCount: 2,
              child: SizedBox(
                height: 200,
                child: Tile(index: 0),
              ),
            ),
            StaggeredGridTile.fit(
              crossAxisCellCount: 2,
              child: SizedBox(
                height: 100,
                child: Tile(index: 1),
              ),
            ),
            StaggeredGridTile.fit(
              crossAxisCellCount: 1,
              child: SizedBox(
                height: 100,
                child: Tile(index: 2),
              ),
            ),
            StaggeredGridTile.fit(
              crossAxisCellCount: 1,
              child: SizedBox(
                height: 100,
                child: Tile(index: 3),
              ),
            ),
            StaggeredGridTile.fit(
              crossAxisCellCount: 4,
              child: SizedBox(
                height: 200,
                child: Tile(index: 4),
              ),
            ),
          ],
        ),
      ),
    );

    void _expectSize(int index, Size size) {
      expect(tester.getSize(find.text('$index')), equals(size));
    }

    void _expectTopLeft(int index, Offset topLeft) {
      expect(tester.getTopLeft(find.text('$index')), equals(topLeft));
    }

    const s1 = 197.0;
    const s2 = 398.0;
    const s3 = 599.0;
    const s4 = 800.0;
    _expectSize(0, const Size(s2, 200));
    _expectSize(1, const Size(s2, 100));
    _expectSize(2, const Size(s1, 100));
    _expectSize(3, const Size(s1, 100));
    _expectSize(4, const Size(s4, 200));

    _expectTopLeft(0, const Offset(0, 0));
    _expectTopLeft(1, const Offset(s2 + 4, 0));
    _expectTopLeft(2, const Offset(s2 + 4, 104));
    _expectTopLeft(3, const Offset(s3 + 4, 104));
    _expectTopLeft(4, const Offset(0, 208));
  });
}
