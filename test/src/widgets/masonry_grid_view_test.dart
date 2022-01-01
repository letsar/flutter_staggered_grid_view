import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/src/widgets/masonry_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized()
      as TestWidgetsFlutterBinding;

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

    // Change orientation to portrait.
    await binding.setSurfaceSize(const Size(600, 800));
    await tester.pump();

    for (var i = 0; i < 10; i++) {
      final double h = ((i % 4) + 1) * 100;
      expect(tester.getSize(find.byKey(ValueKey(i))), equals(Size(200.0, h)));
    }

    for (int i = 0; i < 10; ++i) {
      await tester.tap(find.byKey((ValueKey(i))));
      expect(log, equals(<String>['$i']));
      log.clear();
    }

    expect(find.text('11'), findsNothing);

    await tester.drag(find.text('5'), const Offset(0.0, -200.0));
    await tester.pump();

    expect(find.text('0'), findsNothing);
  });
}
