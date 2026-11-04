import 'dart:math' as math;

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

/// Counts the states created for each id.
final Map<int, int> createdStates = {};

class StatefulTile extends StatefulWidget {
  const StatefulTile({super.key, required this.id, this.grow = false});

  final int id;

  /// Whether the tile grows from 0 to 100 with an animation.
  final bool grow;

  @override
  State<StatefulTile> createState() => _StatefulTileState();
}

class _StatefulTileState extends State<StatefulTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  )..forward();

  @override
  void initState() {
    super.initState();
    createdStates.update(widget.id, (count) => count + 1, ifAbsent: () => 1);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => SizedBox(
        height: widget.grow ? 100 * controller.value : extentOf(widget.id),
        child: Text('${widget.id}', textDirection: TextDirection.ltr),
      ),
    );
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

  group('keyed children moved', () {
    Widget keyed(ScrollController controller, List<int> ids) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: MasonryGridView.custom(
          controller: controller,
          gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          childrenDelegate: SliverChildBuilderDelegate(
            (context, index) => Tile(
              key: ValueKey(ids[index]),
              index: ids[index],
              height: extentOf(ids[index]),
            ),
            childCount: ids.length,
            findChildIndexCallback: (key) {
              final index = ids.indexOf((key as ValueKey<int>).value);
              return index < 0 ? null : index;
            },
          ),
        ),
      );
    }

    testWidgets('insert at the start', (WidgetTester tester) async {
      final controller = ScrollController();
      var ids = List.generate(100, (index) => index);
      await tester.pumpWidget(keyed(controller, ids));
      controller.jumpTo(800);
      await tester.pump();

      for (var i = 0; i < 5; i++) {
        ids = [1000 + i, ...ids];
        await tester.pumpWidget(keyed(controller, ids));
      }
      expect(find.byType(Tile), findsWidgets);
    });

    testWidgets('move a visible child far down', (WidgetTester tester) async {
      final controller = ScrollController();
      final ids = List.generate(100, (index) => index);
      await tester.pumpWidget(keyed(controller, ids));

      ids
        ..remove(2)
        ..insert(60, 2);
      await tester.pumpWidget(keyed(controller, ids));
      expect(find.text('${ids[2]}'), findsOneWidget);
      expect(find.text('2'), findsNothing);
    });

    testWidgets('move a visible child to the start',
        (WidgetTester tester) async {
      final controller = ScrollController();
      final ids = List.generate(100, (index) => index);
      await tester.pumpWidget(keyed(controller, ids));

      ids
        ..remove(8)
        ..insert(0, 8);
      await tester.pumpWidget(keyed(controller, ids));
      expect(tester.getTopLeft(find.byKey(const ValueKey(8))), Offset.zero);
    });
  });

  for (final offset in <double>[0, 50, 300]) {
    testWidgets(
        'a child growing before the viewport keeps its state '
        '(offset: $offset)', (WidgetTester tester) async {
      createdStates.clear();
      final controller = ScrollController();
      Widget build({required bool inserted}) => Directionality(
            textDirection: TextDirection.ltr,
            child: MasonryGridView.count(
              controller: controller,
              crossAxisCount: 2,
              itemCount: inserted ? 101 : 100,
              itemBuilder: (context, index) {
                if (inserted && index == 0) {
                  return const StatefulTile(id: -1, grow: true);
                }
                return Tile(
                  index: index,
                  height: extentOf(inserted ? index - 1 : index),
                );
              },
            ),
          );

      await tester.pumpWidget(build(inserted: false));
      controller.jumpTo(offset);
      await tester.pump();
      await tester.pumpWidget(build(inserted: true));
      await tester.pumpAndSettle();

      // The child is not built at all if it is before the cache area.
      expect(createdStates[-1] ?? 0, lessThanOrEqualTo(1));
      expect(createdStates.containsKey(-1), offset < 300);
    });
  }

  testWidgets('inserting a keyed child keeps the state of the others',
      (WidgetTester tester) async {
    createdStates.clear();
    final ids = List.generate(100, (index) => index);
    Widget build() => Directionality(
          textDirection: TextDirection.ltr,
          child: MasonryGridView.custom(
            gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            childrenDelegate: SliverChildBuilderDelegate(
              (context, index) => StatefulTile(
                key: ValueKey(ids[index]),
                id: ids[index],
              ),
              childCount: ids.length,
              findChildIndexCallback: (key) {
                final index = ids.indexOf((key as ValueKey<int>).value);
                return index < 0 ? null : index;
              },
            ),
          ),
        );

    await tester.pumpWidget(build());
    ids.insert(5, 1000);
    await tester.pumpWidget(build());

    expect(createdStates[1000], 1);
    expect(createdStates.values.every((count) => count == 1), isTrue);
  });

  group('changing the width', () {
    Widget build(
      ScrollController controller,
      double width, {
      required bool aspectRatio,
      Key? key,
    }) {
      return Directionality(
        key: key,
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            height: 600,
            child: MasonryGridView.count(
              controller: controller,
              crossAxisCount: 3,
              itemCount: 2000,
              itemBuilder: (context, index) => aspectRatio
                  ? AspectRatio(
                      key: ValueKey(index),
                      aspectRatio: 0.5 + index % 4 / 4,
                      child: StatefulTile(id: index),
                    )
                  : StatefulTile(key: ValueKey(index), id: index),
            ),
          ),
        ),
      );
    }

    for (final aspectRatio in [false, true]) {
      testWidgets(
          'keeps the state of the visible children '
          '(aspectRatio: $aspectRatio)', (WidgetTester tester) async {
        final controller = ScrollController();
        await tester
            .pumpWidget(build(controller, 400, aspectRatio: aspectRatio));
        controller.jumpTo(20000);
        await tester.pump();

        createdStates.clear();
        for (var width = 401.0; width <= 410; width++) {
          await tester.pumpWidget(
            build(controller, width, aspectRatio: aspectRatio),
          );
        }
        expect(createdStates.values.where((count) => count > 1), isEmpty);
      });
    }

    testWidgets('children are placed like in a new grid after scrolling back',
        (WidgetTester tester) async {
      final controller = ScrollController();
      await tester.pumpWidget(build(controller, 400, aspectRatio: true));
      controller.jumpTo(5000);
      await tester.pump();
      await tester.pumpWidget(build(controller, 500, aspectRatio: true));

      // The placements before the viewport are checked when scrolling back.
      while (controller.offset > 0) {
        controller.jumpTo(math.max(0, controller.offset - 300));
        await tester.pump();
      }

      Future<List<Map<int, Rect>>> rectsAtOffsets() async {
        final result = <Map<int, Rect>>[];
        for (final offset in <double>[0, 1000, 3000]) {
          controller.jumpTo(offset);
          await tester.pump();
          result.add({
            for (final element in find.byType(StatefulTile).evaluate())
              (element.widget as StatefulTile).id:
                  tester.getRect(find.byWidget(element.widget)),
          });
        }
        return result;
      }

      final afterResize = await rectsAtOffsets();
      await tester.pumpWidget(
        build(controller, 500, aspectRatio: true, key: UniqueKey()),
      );
      expect(await rectsAtOffsets(), afterResize);
    });
  });

  for (final cacheExtent in <double>[0, 250]) {
    testWidgets(
        'scrolling back after a width change keeps the state of the '
        'visible children (cacheExtent: $cacheExtent)',
        (WidgetTester tester) async {
      createdStates.clear();
      final controller = ScrollController();
      Widget build(double width) => Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                height: 600,
                child: MasonryGridView.count(
                  controller: controller,
                  // ignore: deprecated_member_use
                  cacheExtent: cacheExtent,
                  crossAxisCount: 3,
                  itemCount: 400,
                  itemBuilder: (context, index) => AspectRatio(
                    key: ValueKey(index),
                    aspectRatio: 1 / (0.5 + (index * 37 % 11) / 7),
                    child: StatefulTile(id: index),
                  ),
                ),
              ),
            ),
          );
      Set<int> visible() => {
            for (final element in find.byType(StatefulTile).evaluate())
              (element.widget as StatefulTile).id,
          };

      await tester.pumpWidget(build(400));
      for (double offset = 0; offset <= 8000; offset += 300) {
        controller.jumpTo(offset);
        await tester.pump();
      }
      await tester.pumpWidget(build(430));

      while (controller.offset > 0) {
        final before = visible();
        final states = Map.of(createdStates);
        controller.jumpTo(math.max(0, controller.offset - 40));
        await tester.pump();
        for (final id in visible().intersection(before)) {
          expect(createdStates[id], states[id], reason: 'state of $id');
        }
      }
    });
  }

  testWidgets('jumping far does not build placed children which are not needed',
      (WidgetTester tester) async {
    final controller = ScrollController();
    final built = <int>{};
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          controller: controller,
          slivers: [
            SliverMasonryGrid.count(
              crossAxisCount: 3,
              childCount: 100000,
              itemBuilder: (context, index) {
                built.add(index);
                return Tile(
                  key: ValueKey(index),
                  index: index,
                  height: extentOf(index),
                );
              },
            ),
          ],
        ),
      ),
    );
    // The placements of the children are cached up to 50000.
    for (double offset = 0; offset < 50000; offset += 500) {
      controller.jumpTo(offset);
      await tester.pump();
    }
    final placed = built.reduce(math.max);
    controller.jumpTo(0);
    await tester.pump();

    built.clear();
    controller.jumpTo(60000);
    await tester.pump();
    final alive = {
      for (final element in find.byType(Tile, skipOffstage: false).evaluate())
        (element.widget as Tile).index,
    };
    // The children after the placed ones are built to be measured.
    expect(
      built.where((index) => index <= placed).toSet().difference(alive),
      isEmpty,
    );
  });

  testWidgets('a crossAxisSpacing larger than the width is not an error',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 10,
            child: MasonryGridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              itemCount: 10,
              itemBuilder: (context, index) => Tile(index: index, height: 50),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('an empty grid has no extent', (WidgetTester tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(grid(controller: controller, itemCount: 0));
    expect(controller.position.maxScrollExtent, 0);
  });

  testWidgets('jumping forward only builds the children which are needed',
      (WidgetTester tester) async {
    final controller = ScrollController();
    final built = <int>{};
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          controller: controller,
          slivers: [
            SliverMasonryGrid.count(
              crossAxisCount: 3,
              childCount: 1000,
              itemBuilder: (context, index) {
                built.add(index);
                return Tile(
                  key: ValueKey(index),
                  index: index,
                  height: extentOf(index),
                );
              },
            ),
          ],
        ),
      ),
    );
    // The placements of the children are cached up to 20000.
    for (double offset = 0; offset < 20000; offset += 500) {
      controller.jumpTo(offset);
      await tester.pump();
    }
    controller.jumpTo(0);
    await tester.pump();

    for (var i = 0; i < 10; i++) {
      built.clear();
      controller.jumpTo(controller.offset + 1500);
      await tester.pump();
      final alive = {
        for (final element in find.byType(Tile, skipOffstage: false).evaluate())
          (element.widget as Tile).index,
      };
      expect(built.difference(alive), isEmpty);
    }
  });
}
