import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/src/rendering/staggered_grid.dart';
import 'package:flutter_staggered_grid_view/src/widgets/staggered_grid.dart';
import 'package:flutter_staggered_grid_view/src/widgets/staggered_grid_tile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Empty StaggeredGrid', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: StaggeredGrid.count(
          crossAxisCount: 4,
        ),
      ),
    );
  });

  testWidgets('StaggeredGrid.count control test', (WidgetTester tester) async {
    // Screen size is 800x600 in the test environment.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: StaggeredGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: const [
            StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 2,
              child: Tile(index: 0),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 1,
              child: Tile(index: 1),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Tile(index: 2),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Tile(index: 3),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 4,
              mainAxisCellCount: 2,
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
    _expectSize(0, const Size(s2, s2));
    _expectSize(1, const Size(s2, s1));
    _expectSize(2, const Size(s1, s1));
    _expectSize(3, const Size(s1, s1));
    _expectSize(4, const Size(s4, s2));

    _expectTopLeft(0, const Offset(0, 0));
    _expectTopLeft(1, const Offset(s2 + 4, 0));
    _expectTopLeft(2, const Offset(s2 + 4, s1 + 4));
    _expectTopLeft(3, const Offset(s3 + 4, s1 + 4));
    _expectTopLeft(4, const Offset(0, s2 + 4));
  });

  testWidgets('StaggeredGrid.extent control test', (WidgetTester tester) async {
    // Screen size is 800x600 in the test environment.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: StaggeredGrid.extent(
          maxCrossAxisExtent: 197,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: const [
            StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 2,
              child: Tile(index: 0),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 1,
              child: Tile(index: 1),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Tile(index: 2),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Tile(index: 3),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 4,
              mainAxisCellCount: 2,
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
    _expectSize(0, const Size(s2, s2));
    _expectSize(1, const Size(s2, s1));
    _expectSize(2, const Size(s1, s1));
    _expectSize(3, const Size(s1, s1));
    _expectSize(4, const Size(s4, s2));

    _expectTopLeft(0, const Offset(0, 0));
    _expectTopLeft(1, const Offset(s2 + 4, 0));
    _expectTopLeft(2, const Offset(s2 + 4, s1 + 4));
    _expectTopLeft(3, const Offset(s3 + 4, s1 + 4));
    _expectTopLeft(4, const Offset(0, s2 + 4));

    // Change orientation to portrait.
    await binding.setSurfaceSize(const Size(599, 800));
    await tester.pump();

    _expectSize(0, const Size(s2, s2));
    _expectSize(1, const Size(s2, s1));
    _expectSize(2, const Size(s1, s1));
    _expectSize(3, const Size(s1, s1));
    _expectSize(4, const Size(s3, s2)); // The crossAxisCellCount is reduced.

    // New layout:
    // 002
    // 003
    // 11
    // 444
    // 444
    _expectTopLeft(0, const Offset(0.0, 0.0));
    _expectTopLeft(1, const Offset(0, s2 + 4));
    _expectTopLeft(2, const Offset(s2 + 4, 0));
    _expectTopLeft(3, const Offset(s2 + 4, s1 + 4));
    _expectTopLeft(4, const Offset(0, s3 + 4));
  });

  // https://github.com/letsar/flutter_staggered_grid_view/issues/308
  testWidgets('tiles fitting an AspectRatio have this aspect ratio',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 400,
            child: StaggeredGrid.count(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: const [
                StaggeredGridTile.fit(
                  crossAxisCellCount: 1,
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: Tile(index: 0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final size = tester.getSize(find.byType(Tile));
    expect(size.width / size.height, closeTo(9 / 16, 1e-9));
  });

  // https://github.com/letsar/flutter_staggered_grid_view/issues/284
  group('placement', () {
    Widget build(
      StaggeredGridPlacement placement, {
      TextDirection textDirection = TextDirection.ltr,
      AxisDirection? axisDirection,
    }) {
      return Directionality(
        textDirection: textDirection,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 400,
            child: StaggeredGrid.count(
              crossAxisCount: 4,
              placement: placement,
              axisDirection: axisDirection,
              children: const [
                StaggeredGridTile.count(
                  crossAxisCellCount: 3,
                  mainAxisCellCount: 1,
                  child: Tile(index: 0),
                ),
                StaggeredGridTile.count(
                  crossAxisCellCount: 2,
                  mainAxisCellCount: 1,
                  child: Tile(index: 1),
                ),
                StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: Tile(index: 2),
                ),
                StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 2,
                  child: Tile(index: 3),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Offset topLeftOf(WidgetTester tester, int index) {
      return tester.getTopLeft(find.text('$index'));
    }

    testWidgets('dense fills the holes', (WidgetTester tester) async {
      await tester.pumpWidget(build(StaggeredGridPlacement.dense));

      expect(topLeftOf(tester, 0), Offset.zero);
      expect(topLeftOf(tester, 1), const Offset(0, 100));
      // The tile 2 fills the hole after the tile 0.
      expect(topLeftOf(tester, 2), const Offset(300, 0));
      expect(topLeftOf(tester, 3), const Offset(200, 100));
    });

    testWidgets('sparse keeps the order', (WidgetTester tester) async {
      await tester.pumpWidget(build(StaggeredGridPlacement.sparse));

      expect(topLeftOf(tester, 0), Offset.zero);
      expect(topLeftOf(tester, 1), const Offset(0, 100));
      expect(topLeftOf(tester, 2), const Offset(200, 100));
      expect(topLeftOf(tester, 3), const Offset(300, 100));
      expect(tester.getSize(find.byType(StaggeredGrid)), const Size(400, 300));
    });

    testWidgets('sparse keeps the order of random tiles without overlaps',
        (WidgetTester tester) async {
      for (var seed = 0; seed < 50; seed++) {
        final random = math.Random(seed);
        final crossAxisCount = 1 + random.nextInt(6);
        final count = 1 + random.nextInt(30);
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 600,
                child: StaggeredGrid.count(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  placement: StaggeredGridPlacement.sparse,
                  children: [
                    for (var i = 0; i < count; i++)
                      StaggeredGridTile.count(
                        crossAxisCellCount: 1 + random.nextInt(crossAxisCount),
                        mainAxisCellCount: 1 + random.nextInt(3),
                        child: Tile(index: i),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );

        final rects = [
          for (var i = 0; i < count; i++) tester.getRect(find.text('$i')),
        ];
        for (var i = 0; i < count; i++) {
          for (var j = i + 1; j < count; j++) {
            final overlap = rects[i].intersect(rects[j]);
            expect(
              overlap.width > 0.01 && overlap.height > 0.01,
              isFalse,
              reason: 'seed $seed: $i overlaps $j',
            );
          }
          if (i > 0) {
            final previous = rects[i - 1];
            final rect = rects[i];
            final isAfter = rect.top > previous.top + 0.01 ||
                ((rect.top - previous.top).abs() <= 0.01 &&
                    rect.left >= previous.right - 0.01);
            expect(isAfter, isTrue, reason: 'seed $seed: $i before ${i - 1}');
          }
        }
      }
    });

    testWidgets('sparse in right-to-left', (WidgetTester tester) async {
      await tester.pumpWidget(
        build(
          StaggeredGridPlacement.sparse,
          textDirection: TextDirection.rtl,
        ),
      );

      expect(topLeftOf(tester, 0), const Offset(100, 0));
      expect(topLeftOf(tester, 2), const Offset(100, 100));
      expect(topLeftOf(tester, 3), const Offset(0, 100));
    });

    testWidgets('sparse with a reversed axis direction',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        build(
          StaggeredGridPlacement.sparse,
          axisDirection: AxisDirection.up,
        ),
      );

      // The grid is 300 high, the first track is at the bottom.
      expect(topLeftOf(tester, 0), const Offset(0, 200));
      expect(topLeftOf(tester, 2), const Offset(200, 100));
      expect(topLeftOf(tester, 3), const Offset(300, 0));
    });
  });
}
