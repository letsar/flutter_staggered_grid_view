import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/src/widgets/masonry_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Empty MasonryGridView', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MasonryGridView.count(
          dragStartBehavior: DragStartBehavior.down,
          crossAxisCount: 4,
          itemBuilder: (contex, index) => const SizedBox(),
          itemCount: 0,
        ),
      ),
    );
  });

  testWidgets('MasonryGridView.count control test',
      (WidgetTester tester) async {
    // Screen size is 800x600 in the test environment.
    final List<String> log = <String>[];
    final itemCount = 12;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MasonryGridView.count(
          cacheExtent: 0,
          dragStartBehavior: DragStartBehavior.down,
          crossAxisCount: 4,
          itemBuilder: (context, index) {
            return Tile(
              key: ValueKey(index),
              index: index,
              height: ((index % 4) + 1) * 100,
              onTap: () => log.add('$index'),
            );
          },
          itemCount: itemCount,
        ),
      ),
    );

    for (var i = 0; i < itemCount; i++) {
      final double h = ((i % 4) + 1) * 100;
      expect(tester.getSize(find.byKey(ValueKey(i))), equals(Size(200.0, h)));
    }

    for (int i = 0; i < 10; ++i) {
      await tester.tap(find.byKey((ValueKey(i))));
      expect(log, equals(<String>['$i']));
      log.clear();
    }

    expect(find.text('12'), findsNothing);

    await tester.drag(find.text('5'), const Offset(0.0, -200.0));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsNothing);
    expect(find.text('4'), findsNothing);
  });

  testWidgets('MasonryGridView.extent control test',
      (WidgetTester tester) async {
    // Screen size is 800x600 in the test environment.
    final List<String> log = <String>[];
    final itemCount = 12;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MasonryGridView.extent(
          cacheExtent: 0,
          dragStartBehavior: DragStartBehavior.down,
          maxCrossAxisExtent: 200,
          itemBuilder: (context, index) {
            return Tile(
              key: ValueKey(index),
              index: index,
              height: ((index % 4) + 1) * 100,
              onTap: () => log.add('$index'),
            );
          },
          itemCount: itemCount,
        ),
      ),
    );

    for (var i = 0; i < itemCount; i++) {
      final double h = ((i % 4) + 1) * 100;
      expect(tester.getSize(find.byKey(ValueKey(i))), equals(Size(200.0, h)));
    }

    for (int i = 0; i < 10; ++i) {
      await tester.tap(find.byKey((ValueKey(i))));
      expect(log, equals(<String>['$i']));
      log.clear();
    }

    expect(find.text('12'), findsNothing);

    await tester.drag(find.text('5'), const Offset(0.0, -200.0));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsNothing);
    expect(find.text('4'), findsNothing);

    // Item 2 is the first visible item, it starts at 0 and is 300px tall.
    expect(tester.getTopLeft(find.byKey(const ValueKey(2))).dy, -200);

    // Change orientation to portrait.
    await binding.setSurfaceSize(const Size(600, 800));
    await tester.pump();

    // The first visible item did not move, and the others are placed in 3
    // columns.
    expect(tester.getTopLeft(find.byKey(const ValueKey(2))).dy, -200);
    for (var i = 2; i < 12; i++) {
      final double h = ((i % 4) + 1) * 100;
      expect(tester.getSize(find.byKey(ValueKey(i))), equals(Size(200.0, h)));
    }

    for (int i = 3; i < 11; ++i) {
      await tester.tap(find.byKey((ValueKey(i))));
      expect(log, equals(<String>['$i']));
      log.clear();
    }

    await tester.drag(find.text('5'), const Offset(0.0, -200.0));
    await tester.pump();

    expect(find.text('0'), findsNothing);

    await binding.setSurfaceSize(null);
  });

  // https://github.com/letsar/flutter_staggered_grid_view/issues/301
  testWidgets('itemBuilder can return null to end the grid',
      (WidgetTester tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MasonryGridView.count(
          controller: controller,
          crossAxisCount: 2,
          itemBuilder: (context, index) => index < 30
              ? Tile(index: index, height: ((index % 4) + 1) * 100)
              : null,
        ),
      ),
    );

    // The number of children is unknown until the end is reached.
    controller.jumpTo(100000);
    await tester.pump();
    expect(controller.position.maxScrollExtent.isFinite, isTrue);
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    expect(find.text('29'), findsOneWidget);
    expect(find.text('30'), findsNothing);
  });
}
