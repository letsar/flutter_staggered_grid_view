import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common.dart';

double extentOf(int index) => (index * 37 % 11 + 1) * 40.0;

Widget grid({
  required ScrollController controller,
  int crossAxisCount = 3,
  int itemCount = 200,
  double Function(int index) extent = extentOf,
}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: CustomScrollView(
      controller: controller,
      slivers: [
        SliverMasonryGrid.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childCount: itemCount,
          itemBuilder: (context, index) => Tile(
            key: ValueKey(index),
            index: index,
            height: extent(index),
          ),
        ),
      ],
    ),
  );
}

/// Records the position of each visible tile in the scrollable content.
void recordPositions(
  WidgetTester tester,
  ScrollController controller,
  Map<int, Offset> positions,
) {
  for (final element in find.byType(Tile).evaluate()) {
    final tile = element.widget as Tile;
    final box = element.renderObject as RenderBox;
    final position =
        box.localToGlobal(Offset.zero) + Offset(0, controller.offset);
    final previous = positions[tile.index];
    if (previous != null) {
      expect(position, previous, reason: 'Tile ${tile.index} moved');
    }
    positions[tile.index] = position;
  }
}

void main() {
  testWidgets('children do not move when scrolling down and up',
      (WidgetTester tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(grid(controller: controller));

    final positions = <int, Offset>{};
    for (var i = 0; i < 30; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pump();
      recordPositions(tester, controller, positions);
    }
    for (var i = 0; i < 30; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
      await tester.pump();
      recordPositions(tester, controller, positions);
    }
    expect(controller.offset, 0);
    expect(positions.length, greaterThan(50));
  });

  testWidgets('jumping to the end and back keeps positions',
      (WidgetTester tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(grid(controller: controller));

    final positions = <int, Offset>{};
    recordPositions(tester, controller, positions);

    // The extent is estimated until the end is reached, so we may need several
    // jumps to reach the actual end.
    for (var i = 0; i < 5; i++) {
      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pump();
    }
    expect(controller.offset, controller.position.maxScrollExtent);
    expect(find.text('199'), findsOneWidget);
    recordPositions(tester, controller, positions);

    controller.jumpTo(controller.position.maxScrollExtent / 2);
    await tester.pump();
    recordPositions(tester, controller, positions);

    controller.jumpTo(0);
    await tester.pump();
    recordPositions(tester, controller, positions);
    expect(find.text('0'), findsOneWidget);
  });

  // https://github.com/letsar/flutter_staggered_grid_view/issues/338
  testWidgets('multiple grids in a CustomScrollView scroll continuously',
      (WidgetTester tester) async {
    final controller = ScrollController();
    Widget buildGrid(int count) {
      return SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childCount: count,
        itemBuilder: (context, index) => Tile(
          index: index,
          height: extentOf(index),
        ),
      );
    }

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          controller: controller,
          slivers: [
            buildGrid(60),
            const SliverToBoxAdapter(child: SizedBox(height: 500)),
            buildGrid(60),
            const SliverToBoxAdapter(child: SizedBox(height: 500)),
            buildGrid(60),
          ],
        ),
      ),
    );

    double previousOffset = controller.offset;
    while (controller.offset < controller.position.maxScrollExtent) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pump();
      expect(controller.offset, greaterThan(previousOffset));
      previousOffset = controller.offset;
    }

    controller.jumpTo(0);
    await tester.pump();
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    expect(controller.offset, controller.position.maxScrollExtent);
    expect(controller.offset, greaterThan(0));
  });

  // https://github.com/letsar/flutter_staggered_grid_view/issues/105
  testWidgets('changing crossAxisCount keeps the first visible child in place',
      (WidgetTester tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(grid(controller: controller));

    controller.jumpTo(3000);
    await tester.pump();
    final first = (find.byType(Tile).evaluate().first.widget as Tile).index;
    final top = tester.getTopLeft(find.byKey(ValueKey(first))).dy;

    await tester.pumpWidget(grid(controller: controller, crossAxisCount: 2));
    expect(tester.getTopLeft(find.byKey(ValueKey(first))).dy, top);
    expect(tester.getSize(find.byKey(ValueKey(first))).width, 398);

    // Every child is still reachable.
    controller.jumpTo(0);
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('children above the viewport can change their extent',
      (WidgetTester tester) async {
    final controller = ScrollController();
    final extents = <int, double>{};
    double extent(int index) => extents[index] ?? extentOf(index);

    await tester.pumpWidget(grid(controller: controller, extent: extent));
    controller.jumpTo(2000);
    await tester.pump();

    // The first children are taller, all the visible children are placed
    // differently.
    for (var i = 0; i < 5; i++) {
      extents[i] = 1000;
    }
    await tester.pumpWidget(grid(controller: controller, extent: extent));
    while (controller.offset > 0) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
      await tester.pump();
    }
    expect(tester.getTopLeft(find.byKey(const ValueKey(0))).dy, 0);
    expect(tester.getSize(find.byKey(const ValueKey(0))).height, 1000);

    // Going down again uses the new extents.
    final positions = <int, Offset>{};
    for (var i = 0; i < 10; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pump();
      recordPositions(tester, controller, positions);
    }
    for (var i = 0; i < 10; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
      await tester.pump();
      recordPositions(tester, controller, positions);
    }
  });

  testWidgets('removing children shrinks the scroll extent',
      (WidgetTester tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(grid(controller: controller));
    for (var i = 0; i < 5; i++) {
      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pump();
    }
    final maxScrollExtent = controller.position.maxScrollExtent;

    controller.jumpTo(0);
    await tester.pump();
    await tester.pumpWidget(grid(controller: controller, itemCount: 20));
    expect(controller.position.maxScrollExtent, lessThan(maxScrollExtent));

    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    expect(find.text('19'), findsOneWidget);
  });

  // Children without size until their content is loaded, like images.
  for (final spacing in <double>[0, 8]) {
    testWidgets(
        'children with a zero extent are built and can grow '
        '(mainAxisSpacing: $spacing)', (WidgetTester tester) async {
      var height = 0.0;
      Widget build() => Directionality(
            textDirection: TextDirection.ltr,
            child: MasonryGridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: spacing,
              itemCount: 100,
              itemBuilder: (context, index) => Tile(
                key: ValueKey(index),
                index: index,
                height: height,
              ),
            ),
          );

      await tester.pumpWidget(build());
      // Children with a zero extent are considered offstage by the finders.
      for (var i = 0; i < 3; i++) {
        expect(find.byKey(ValueKey(i), skipOffstage: false), findsOneWidget);
      }

      height = 100;
      await tester.pumpWidget(build());
      for (var i = 0; i < 12; i++) {
        expect(tester.getSize(find.byKey(ValueKey(i))).height, 100);
      }
    });
  }

  testWidgets('a correction cannot scroll before the start of the grid',
      (WidgetTester tester) async {
    final controller = ScrollController();
    Widget build(int crossAxisCount) => Directionality(
          textDirection: TextDirection.ltr,
          child: CustomScrollView(
            controller: controller,
            slivers: [
              SliverMasonryGrid.count(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 300,
                childCount: 20,
                itemBuilder: (context, index) =>
                    Tile(index: index, height: 100),
              ),
            ],
          ),
        );

    await tester.pumpWidget(build(1));
    controller.jumpTo(390);
    await tester.pump();

    await tester.pumpWidget(build(4));
    expect(controller.offset, greaterThanOrEqualTo(0));
  });

  testWidgets('an empty grid has no extent', (WidgetTester tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(grid(controller: controller, itemCount: 0));
    expect(controller.position.maxScrollExtent, 0);
  });
}
