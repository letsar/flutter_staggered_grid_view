import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/src/layouts/woven.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized()
      as TestWidgetsFlutterBinding;
  testWidgets('Woven Grid control test', (WidgetTester tester) async {
    await binding.setSurfaceSize(const Size(800, 800));
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GridView.custom(
          gridDelegate: SliverWovenGridDelegate.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            pattern: const [
              WovenGridTile(1),
              WovenGridTile(
                5 / 7,
                crossAxisRatio: 0.9,
                alignment: AlignmentDirectional.centerEnd,
              ),
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
      final actualOffset = tester.getTopLeft(find.text('$index'));
      expect(
        actualOffset.dx,
        moreOrLessEquals(topLeft.dx, epsilon: precisionErrorTolerance),
      );
      expect(
        actualOffset.dy,
        moreOrLessEquals(topLeft.dy, epsilon: precisionErrorTolerance),
      );
    }

    const s1 = 396.0;
    const s2 = s1 * 0.9;
    const s3 = s2 * 7 / 5;

    _expectSize(0, const Size(s1, s1));
    _expectSize(1, const Size(s2, s3));
    _expectSize(2, const Size(s2, s3));
    _expectSize(3, const Size(s1, s1));

    _expectTopLeft(0, const Offset(0, (s3 - s1) / 2));
    _expectTopLeft(1, const Offset(s1 + 8 + 0.1 * s1, 0));
    _expectTopLeft(2, const Offset(0, s3 + 8));
    _expectTopLeft(3, const Offset(s1 + 8, s3 + 8 + (s3 - s1) / 2));
  });
}
