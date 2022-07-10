import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/src/widgets/aligned_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Empty AlignedGridView', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.count(
          dragStartBehavior: DragStartBehavior.down,
          crossAxisCount: 4,
          itemBuilder: (contex, index) => const SizedBox(),
          itemCount: 0,
        ),
      ),
    );
  });

  testWidgets('Should  only layout the number of requested items',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.count(
          dragStartBehavior: DragStartBehavior.down,
          crossAxisCount: 4,
          itemBuilder: (contex, index) {
            return Tile(
              index: index,
              height: 100,
            );
          },
          itemCount: 4,
        ),
      ),
    );

    expect(find.text('0'), findsOneWidget);
    expect(find.text('4'), findsNothing);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.count(
          dragStartBehavior: DragStartBehavior.down,
          crossAxisCount: 4,
          itemBuilder: (contex, index) {
            return Tile(
              index: index,
              height: 100,
            );
          },
          itemCount: 5,
        ),
      ),
    );

    expect(find.text('0'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('5'), findsNothing);
  });

  testWidgets('AlignedGridView.count control test',
      (WidgetTester tester) async {
    // Screen size is 800x600 in the test environment.
    final itemCount = 12;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.count(
          cacheExtent: 0,
          dragStartBehavior: DragStartBehavior.down,
          crossAxisCount: 4,
          itemBuilder: (context, index) {
            return Tile(
              index: index,
              height: ((index % 5) + 1) * 100,
            );
          },
          itemCount: itemCount,
        ),
      ),
    );

    void _expectSize(int index, Size size) {
      expect(tester.getSize(find.text('$index')), equals(size));
    }

    void _expectTopLeft(int index, Offset topLeft) {
      expect(tester.getTopLeft(find.text('$index')), equals(topLeft));
    }

    _expectSize(0, const Size(200, 400));
    _expectSize(1, const Size(200, 400));
    _expectSize(2, const Size(200, 400));
    _expectSize(3, const Size(200, 400));
    _expectSize(4, const Size(200, 500));
    _expectSize(5, const Size(200, 500));
    _expectSize(6, const Size(200, 500));
    _expectSize(7, const Size(200, 500));

    _expectTopLeft(0, const Offset(0, 0));
    _expectTopLeft(1, const Offset(200, 0));
    _expectTopLeft(2, const Offset(400, 0));
    _expectTopLeft(3, const Offset(600, 0));
    _expectTopLeft(4, const Offset(0, 400));
    _expectTopLeft(5, const Offset(200, 400));
    _expectTopLeft(6, const Offset(400, 400));
    _expectTopLeft(7, const Offset(600, 400));
  });

  testWidgets('AlignedGridView.extent control test',
      (WidgetTester tester) async {
    // Screen size is 800x600 in the test environment.
    final itemCount = 12;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.extent(
          cacheExtent: 0,
          dragStartBehavior: DragStartBehavior.down,
          maxCrossAxisExtent: 200,
          itemBuilder: (context, index) {
            return Tile(
              index: index,
              height: ((index % 5) + 1) * 100,
            );
          },
          itemCount: itemCount,
        ),
      ),
    );

    void _expectSize(int index, Size size) {
      expect(tester.getSize(find.text('$index')), equals(size));
    }

    void _expectTopLeft(int index, Offset topLeft) {
      expect(tester.getTopLeft(find.text('$index')), equals(topLeft));
    }

    _expectSize(0, const Size(200, 400));
    _expectSize(1, const Size(200, 400));
    _expectSize(2, const Size(200, 400));
    _expectSize(3, const Size(200, 400));
    _expectSize(4, const Size(200, 500));
    _expectSize(5, const Size(200, 500));
    _expectSize(6, const Size(200, 500));
    _expectSize(7, const Size(200, 500));

    _expectTopLeft(0, const Offset(0, 0));
    _expectTopLeft(1, const Offset(200, 0));
    _expectTopLeft(2, const Offset(400, 0));
    _expectTopLeft(3, const Offset(600, 0));
    _expectTopLeft(4, const Offset(0, 400));
    _expectTopLeft(5, const Offset(200, 400));
    _expectTopLeft(6, const Offset(400, 400));
    _expectTopLeft(7, const Offset(600, 400));

    // Change orientation to portrait.
    await binding.setSurfaceSize(const Size(600, 800));
    await tester.pump();

    _expectSize(0, const Size(200, 300));
    _expectSize(1, const Size(200, 300));
    _expectSize(2, const Size(200, 300));
    _expectSize(3, const Size(200, 500));
    _expectSize(4, const Size(200, 500));
    _expectSize(5, const Size(200, 500));

    _expectTopLeft(0, const Offset(0, 0));
    _expectTopLeft(1, const Offset(200, 0));
    _expectTopLeft(2, const Offset(400, 0));
    _expectTopLeft(3, const Offset(0, 300));
    _expectTopLeft(4, const Offset(200, 300));
    _expectTopLeft(5, const Offset(400, 300));

    expect(find.text('6'), findsNothing);
    expect(find.text('7'), findsNothing);
  });
}
