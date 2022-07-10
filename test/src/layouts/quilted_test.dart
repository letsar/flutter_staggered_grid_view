import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Quilted Grid same control test', (WidgetTester tester) async {
    await binding.setSurfaceSize(const Size(800, 800));
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GridView.custom(
          gridDelegate: SliverQuiltedGridDelegate(
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            repeatPattern: QuiltedGridRepeatPattern.same,
            pattern: const [
              QuiltedGridTile(2, 2),
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 2),
            ],
          ),
          childrenDelegate: SliverChildBuilderDelegate(
            (context, index) => Tile(index: index),
          ),
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
    _expectSize(0, const Size(s2, s2));
    _expectSize(1, const Size(s1, s1));
    _expectSize(2, const Size(s1, s1));
    _expectSize(3, const Size(s2, s1));
    _expectSize(4, const Size(s2, s2));
    _expectSize(5, const Size(s1, s1));
    _expectSize(6, const Size(s1, s1));
    _expectSize(7, const Size(s2, s1));

    _expectTopLeft(0, const Offset(0, 0));
    _expectTopLeft(1, const Offset(s2 + 4, 0));
    _expectTopLeft(2, const Offset(s3 + 4, 0));
    _expectTopLeft(3, const Offset(s2 + 4, s1 + 4));
    _expectTopLeft(4, const Offset(0, s2 + 4));
    _expectTopLeft(5, const Offset(s2 + 4, s2 + 4));
    _expectTopLeft(6, const Offset(s3 + 4, s2 + 4));
    _expectTopLeft(7, const Offset(s2 + 4, s3 + 4));
  });

  testWidgets('Quilted Grid inverted control test',
      (WidgetTester tester) async {
    await binding.setSurfaceSize(const Size(800, 800));
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GridView.custom(
          gridDelegate: SliverQuiltedGridDelegate(
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            repeatPattern: QuiltedGridRepeatPattern.inverted,
            pattern: const [
              QuiltedGridTile(2, 2),
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 2),
            ],
          ),
          childrenDelegate: SliverChildBuilderDelegate(
            (context, index) => Tile(index: index),
          ),
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
    _expectSize(0, const Size(s2, s2));
    _expectSize(1, const Size(s1, s1));
    _expectSize(2, const Size(s1, s1));
    _expectSize(3, const Size(s2, s1));
    _expectSize(4, const Size(s2, s1));
    _expectSize(5, const Size(s2, s2));
    _expectSize(6, const Size(s1, s1));
    _expectSize(7, const Size(s1, s1));

    _expectTopLeft(0, const Offset(0, 0));
    _expectTopLeft(1, const Offset(s2 + 4, 0));
    _expectTopLeft(2, const Offset(s3 + 4, 0));
    _expectTopLeft(3, const Offset(s2 + 4, s1 + 4));
    _expectTopLeft(4, const Offset(0, s2 + 4));
    _expectTopLeft(5, const Offset(s2 + 4, s2 + 4));
    _expectTopLeft(6, const Offset(0, s3 + 4));
    _expectTopLeft(7, const Offset(s1 + 4, s3 + 4));
  });

  testWidgets('Quilted Grid mirrored control test',
      (WidgetTester tester) async {
    await binding.setSurfaceSize(const Size(800, 800));
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GridView.custom(
          gridDelegate: SliverQuiltedGridDelegate(
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            repeatPattern: QuiltedGridRepeatPattern.mirrored,
            pattern: const [
              QuiltedGridTile(2, 2),
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 2),
            ],
          ),
          childrenDelegate: SliverChildBuilderDelegate(
            (context, index) => Tile(index: index),
          ),
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
    _expectSize(0, const Size(s2, s2));
    _expectSize(1, const Size(s1, s1));
    _expectSize(2, const Size(s1, s1));
    _expectSize(3, const Size(s2, s1));
    _expectSize(4, const Size(s2, s2));
    _expectSize(5, const Size(s2, s1));
    _expectSize(6, const Size(s1, s1));
    _expectSize(7, const Size(s1, s1));

    _expectTopLeft(0, const Offset(0, 0));
    _expectTopLeft(1, const Offset(s2 + 4, 0));
    _expectTopLeft(2, const Offset(s3 + 4, 0));
    _expectTopLeft(3, const Offset(s2 + 4, s1 + 4));
    _expectTopLeft(4, const Offset(0, s2 + 4));
    _expectTopLeft(5, const Offset(s2 + 4, s2 + 4));
    _expectTopLeft(6, const Offset(s2 + 4, s3 + 4));
    _expectTopLeft(7, const Offset(s3 + 4, s3 + 4));
  });

  testWidgets('Quilted Grid different pattern control test',
      (WidgetTester tester) async {
    await binding.setSurfaceSize(const Size(200, 268));
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GridView.custom(
          gridDelegate: SliverQuiltedGridDelegate(
            crossAxisCount: 3,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            repeatPattern: QuiltedGridRepeatPattern.inverted,
            pattern: const [
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 1),
              QuiltedGridTile(2, 2),
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 1),
            ],
          ),
          childrenDelegate: SliverChildBuilderDelegate(
            (context, index) => Tile(index: index),
          ),
        ),
      ),
    );

    void _expectSize(int index, Size size) {
      expect(tester.getSize(find.text('$index')), equals(size));
    }

    void _expectTopLeft(int index, Offset topLeft) {
      expect(tester.getTopLeft(find.text('$index')), equals(topLeft));
    }

    const s1 = 64.0;
    const s2 = 132.0;
    const s3 = 200.0;
    _expectSize(0, const Size(s1, s1));
    _expectSize(1, const Size(s1, s1));
    _expectSize(2, const Size(s1, s1));
    _expectSize(3, const Size(s1, s1));
    _expectSize(4, const Size(s2, s2));
    _expectSize(5, const Size(s1, s1));
    _expectSize(6, const Size(s1, s1));
    _expectSize(7, const Size(s1, s1));
    _expectSize(7, const Size(s1, s1));

    _expectTopLeft(0, const Offset(0, 0));
    _expectTopLeft(1, const Offset(s1 + 4, 0));
    _expectTopLeft(2, const Offset(s2 + 4, 0));
    _expectTopLeft(3, const Offset(0, s1 + 4));
    _expectTopLeft(4, const Offset(s1 + 4, s1 + 4));
    _expectTopLeft(5, const Offset(0, s2 + 4));
    _expectTopLeft(6, const Offset(0, s3 + 4));
    _expectTopLeft(7, const Offset(s1 + 4, s3 + 4));
    _expectTopLeft(8, const Offset(s2 + 4, s3 + 4));
  });

  test('computeMaxScrollOffset should be right', () {
    final delegate = SliverQuiltedGridDelegate(
      crossAxisCount: 4,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      repeatPattern: QuiltedGridRepeatPattern.same,
      pattern: const [
        QuiltedGridTile(2, 2),
        QuiltedGridTile(1, 1),
        QuiltedGridTile(1, 1),
        QuiltedGridTile(1, 2),
      ],
    );

    final layout = delegate.getLayout(
      const SliverConstraints(
        axisDirection: AxisDirection.down,
        cacheOrigin: 0,
        crossAxisDirection: AxisDirection.right,
        crossAxisExtent: 412,
        growthDirection: GrowthDirection.forward,
        scrollOffset: 0,
        overlap: 0,
        viewportMainAxisExtent: 400,
        precedingScrollExtent: 0,
        remainingCacheExtent: 400,
        remainingPaintExtent: 400,
        userScrollDirection: ScrollDirection.idle,
      ),
    );

    expect(layout.computeMaxScrollOffset(12), 620);
    expect(layout.computeMaxScrollOffset(16), 828);
  });
}
