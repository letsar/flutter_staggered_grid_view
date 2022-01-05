import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/src/widgets/aligned_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized()
      as TestWidgetsFlutterBinding;

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

    await binding.setSurfaceSize(const Size(800, 600));
  });

  testWidgets('Should layout children following its direction', (tester) async {
    // Screen size is 800x600 in the test environment.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.count(
          scrollDirection: Axis.vertical,
          crossAxisCount: 4,
          itemBuilder: (contex, index) {
            return Tile(
              index: index,
              height: 200,
            );
          },
          itemCount: 4,
        ),
      ),
    );

    void _expectTopLeft(int index, Offset topLeft) {
      expect(tester.getTopLeft(find.text('$index')), equals(topLeft));
    }

    _expectTopLeft(0, const Offset(0, 0));
    _expectTopLeft(1, const Offset(200, 0));
    _expectTopLeft(2, const Offset(400, 0));
    _expectTopLeft(3, const Offset(600, 0));

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.count(
          scrollDirection: Axis.horizontal,
          crossAxisCount: 4,
          itemBuilder: (contex, index) {
            return Tile(
              index: index,
              width: 200,
            );
          },
          itemCount: 4,
        ),
      ),
    );

    _expectTopLeft(0, const Offset(0, 0));
    _expectTopLeft(1, const Offset(0, 150));
    _expectTopLeft(2, const Offset(0, 300));
    _expectTopLeft(3, const Offset(0, 450));
  });

  testWidgets('Children should be of the maximum size', (tester) async {
    // Screen size is 800x600 in the test environment.
    final verticalTiles = const [
      Tile(index: 0, height: 100),
      Tile(index: 1, height: 200),
      Tile(index: 2, height: 50),
      Tile(index: 3, height: 200),
    ];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.count(
          scrollDirection: Axis.vertical,
          crossAxisCount: 4,
          itemBuilder: (contex, index) {
            return verticalTiles[index];
          },
          itemCount: 4,
        ),
      ),
    );

    void _expectSize(int index, Size size) {
      expect(tester.getSize(find.text('$index')), equals(size));
    }

    for (int i = 0; i < 4; i++) {
      _expectSize(i, const Size(200, 200));
    }

    final horizontalTiles = const [
      Tile(index: 0, width: 100),
      Tile(index: 1, width: 200),
      Tile(index: 2, width: 50),
      Tile(index: 3, width: 200),
    ];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.count(
          scrollDirection: Axis.horizontal,
          crossAxisCount: 4,
          itemBuilder: (contex, index) {
            return horizontalTiles[index];
          },
          itemCount: 4,
        ),
      ),
    );

    for (int i = 0; i < 4; i++) {
      _expectSize(i, const Size(200, 150));
    }
  });

  testWidgets('Should have a gap of the specified size between children',
      (tester) async {
    // Screen size is 800x600 in the test environment.
    final verticalTiles = const [
      Tile(index: 0, height: 100),
      Tile(index: 1, height: 200),
      Tile(index: 2, height: 50),
      Tile(index: 3, height: 200),
    ];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.count(
          scrollDirection: Axis.vertical,
          crossAxisCount: 4,
          crossAxisSpacing: 4,
          itemBuilder: (contex, index) {
            return verticalTiles[index];
          },
          itemCount: 4,
        ),
      ),
    );

    void _expectTopLeft(int index, Offset topLeft) {
      expect(tester.getTopLeft(find.text('$index')), equals(topLeft));
    }

    _expectTopLeft(0, const Offset(0, 0));
    _expectTopLeft(1, const Offset(201, 0));
    _expectTopLeft(2, const Offset(402, 0));
    _expectTopLeft(3, const Offset(603, 0));

    final horizontalTiles = const [
      Tile(index: 0, width: 100),
      Tile(index: 1, width: 200),
      Tile(index: 2, width: 50),
      Tile(index: 3, width: 200),
    ];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.count(
          scrollDirection: Axis.horizontal,
          crossAxisCount: 4,
          crossAxisSpacing: 4,
          itemBuilder: (contex, index) {
            return horizontalTiles[index];
          },
          itemCount: 4,
        ),
      ),
    );

    _expectTopLeft(0, const Offset(0, 0));
    _expectTopLeft(1, const Offset(0, 151));
    _expectTopLeft(2, const Offset(0, 302));
    _expectTopLeft(3, const Offset(0, 453));
  });

  testWidgets(
      'Should divide the available space following the crossAxisCount parameter',
      (tester) async {
    // Screen size is 800x600 in the test environment.
    final verticalTiles = const [
      Tile(index: 0, height: 100),
      Tile(index: 1, height: 200),
    ];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.count(
          scrollDirection: Axis.vertical,
          crossAxisCount: 4,
          itemBuilder: (contex, index) {
            return verticalTiles[index];
          },
          itemCount: 2,
        ),
      ),
    );

    void _expectTopLeft(int index, Offset topLeft) {
      expect(tester.getTopLeft(find.text('$index')), equals(topLeft));
    }

    void _expectSize(int index, Size size) {
      expect(tester.getSize(find.text('$index')), equals(size));
    }

    for (int i = 0; i < 2; i++) {
      _expectSize(i, const Size(200, 200));
    }

    _expectTopLeft(0, const Offset(0, 0));
    _expectTopLeft(1, const Offset(200, 0));

    final horizontalTiles = const [
      Tile(index: 0, width: 100),
      Tile(index: 1, width: 200),
    ];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.count(
          scrollDirection: Axis.horizontal,
          crossAxisCount: 4,
          itemBuilder: (contex, index) {
            return horizontalTiles[index];
          },
          itemCount: 2,
        ),
      ),
    );

    for (int i = 0; i < 2; i++) {
      _expectSize(i, const Size(200, 150));
    }

    _expectTopLeft(0, const Offset(0, 0));
    _expectTopLeft(1, const Offset(0, 150));
  });
}
