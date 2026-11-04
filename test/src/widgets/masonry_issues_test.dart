import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';

double extentOf(int index) => (index * 37 % 11 + 1) * 40.0;

/// The rects of the visible items, by index.
Map<String, Rect> visibleRects(WidgetTester tester) {
  return {
    for (final element in find.byType(Text).evaluate())
      (element.widget as Text).data!:
          tester.getRect(find.byWidget(element.widget)),
  };
}

void main() {
  // https://github.com/letsar/flutter_staggered_grid_view/issues/340
  testWidgets('shuffling keyed children with findChildIndexCallback',
      (WidgetTester tester) async {
    final random = math.Random(0);
    final data = List.generate(
      200,
      (index) => (id: '$index', height: 100 + random.nextDouble() * 100),
    );
    final controller = ScrollController();
    Widget build() {
      return MaterialApp(
        home: MasonryGridView.custom(
          controller: controller,
          gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          childrenDelegate: SliverChildBuilderDelegate(
            (context, index) => SizedBox(
              key: ValueKey(data[index].id),
              height: data[index].height,
              child: Text(data[index].id),
            ),
            childCount: data.length,
            findChildIndexCallback: (key) {
              final index = data.indexWhere((item) => ValueKey(item.id) == key);
              return index < 0 ? null : index;
            },
          ),
        ),
      );
    }

    await tester.pumpWidget(build());
    for (var i = 0; i < 10; i++) {
      controller.jumpTo(random.nextDouble() * 5000);
      await tester.pump();
      data.shuffle(random);
      await tester.pumpWidget(build());

      final rects = visibleRects(tester).values.toList();
      for (var a = 0; a < rects.length; a++) {
        for (var b = a + 1; b < rects.length; b++) {
          final overlap = rects[a].intersect(rects[b]);
          expect(overlap.width > 0.01 && overlap.height > 0.01, isFalse);
        }
      }
    }
  });

  // https://github.com/letsar/flutter_staggered_grid_view/issues/346
  testWidgets('the scroll position is restored when switching tabs',
      (WidgetTester tester) async {
    Widget grid(String name) {
      return MasonryGridView.count(
        key: PageStorageKey(name),
        crossAxisCount: 2,
        itemCount: 100,
        itemBuilder: (context, index) =>
            SizedBox(height: extentOf(index), child: Text('$name $index')),
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              bottom: const TabBar(tabs: [Tab(text: 'A'), Tab(text: 'B')]),
            ),
            body: TabBarView(children: [grid('a'), grid('b')]),
          ),
        ),
      ),
    );
    final scrollable = find.descendant(
      of: find.byKey(const PageStorageKey('a')),
      matching: find.byType(Scrollable),
    );
    final position = tester.state<ScrollableState>(scrollable).position;
    // The extent is estimated until the end is reached.
    for (var i = 0; i < 5; i++) {
      position.jumpTo(position.maxScrollExtent);
      await tester.pump();
    }
    final offset = position.pixels;
    expect(find.text('a 99'), findsOneWidget);

    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();

    expect(
      tester.state<ScrollableState>(scrollable).position.pixels,
      closeTo(offset, 1),
    );
    expect(find.text('a 99'), findsOneWidget);
  });

  // https://github.com/letsar/flutter_staggered_grid_view/issues/297
  testWidgets('the initial scroll offset is respected',
      (WidgetTester tester) async {
    final controller = ScrollController(initialScrollOffset: 5000);
    await tester.pumpWidget(
      MaterialApp(
        home: MasonryGridView.builder(
          controller: controller,
          gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: 200,
          itemBuilder: (context, index) =>
              SizedBox(height: extentOf(index), child: Text('$index')),
        ),
      ),
    );

    expect(controller.offset, 5000);
    expect(find.text('0'), findsNothing);
  });
}
