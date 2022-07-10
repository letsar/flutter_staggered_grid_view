import 'package:flutter/widgets.dart';
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
}
