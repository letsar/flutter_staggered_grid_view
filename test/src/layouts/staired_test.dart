import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/src/layouts/staired.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized()
      as TestWidgetsFlutterBinding;
  testWidgets('Staired Grid control test', (WidgetTester tester) async {
    await binding.setSurfaceSize(const Size(800, 800));
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GridView.custom(
          gridDelegate: SliverStairedGridDelegate(
            crossAxisSpacing: 48,
            mainAxisSpacing: 24,
            startCrossAxisDirectionReversed: true,
            pattern: const [
              StairedGridTile(0.5, 1),
              StairedGridTile(0.5, 3 / 4),
              StairedGridTile(1.0, 10 / 4),
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

    const s1 = 376.0;

    _expectSize(0, const Size(s1, s1));
    _expectSize(1, const Size(s1, s1 / (3 / 4)));
    _expectSize(2, const Size(704, 704 / (10 / 4)));

    _expectTopLeft(0, const Offset(s1 + 48, 0));
    _expectTopLeft(1, const Offset(0, 24));
    _expectTopLeft(2, const Offset(48, s1 / (3 / 4) + 48));
  });
}
