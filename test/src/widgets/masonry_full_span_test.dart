import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common.dart';

Widget grid({
  int crossAxisCount = 2,
  int itemCount = 20,
  required MasonryFullSpanPredicate isFullSpan,
  MasonryMainAxisExtentBuilder? mainAxisExtentBuilder,
  double Function(int index)? extentOf,
  TextDirection textDirection = TextDirection.ltr,
  bool reverse = false,
  ScrollController? controller,
}) {
  return Directionality(
    textDirection: textDirection,
    child: MasonryGridView.count(
      controller: controller,
      reverse: reverse,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      itemCount: itemCount,
      isFullSpan: isFullSpan,
      mainAxisExtentBuilder: mainAxisExtentBuilder,
      itemBuilder: (context, index) => Tile(
        key: ValueKey(index),
        index: index,
        height: extentOf?.call(index) ?? (index % 3 + 1) * 50.0,
      ),
    ),
  );
}

Rect rectOf(WidgetTester tester, int index) {
  return tester.getRect(find.byKey(ValueKey(index)));
}

void main() {
  testWidgets('a full span child is placed below all the columns',
      (WidgetTester tester) async {
    // Items 0 (50) and 1 (100) are in the two columns, item 2 spans both.
    await tester.pumpWidget(grid(isFullSpan: (index) => index == 2));

    expect(rectOf(tester, 2), const Rect.fromLTWH(0, 104, 800, 150));

    // The columns are aligned after it.
    expect(rectOf(tester, 3), const Rect.fromLTWH(0, 258, 398, 50));
    expect(rectOf(tester, 4), const Rect.fromLTWH(402, 258, 398, 100));
  });

  testWidgets('a full span child spans the whole width in right-to-left',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      grid(
        isFullSpan: (index) => index == 2,
        textDirection: TextDirection.rtl,
      ),
    );

    expect(rectOf(tester, 2), const Rect.fromLTWH(0, 104, 800, 150));
    expect(rectOf(tester, 3), const Rect.fromLTWH(402, 258, 398, 50));
  });

  testWidgets('mainAxisExtentBuilder receives the whole cross axis extent',
      (WidgetTester tester) async {
    final crossAxisExtents = <int, double>{};
    await tester.pumpWidget(
      grid(
        itemCount: 5,
        isFullSpan: (index) => index == 2,
        mainAxisExtentBuilder: (index, crossAxisExtent) {
          crossAxisExtents[index] = crossAxisExtent;
          return crossAxisExtent / 4;
        },
      ),
    );

    expect(crossAxisExtents[1], 398);
    expect(crossAxisExtents[2], 800);
    expect(rectOf(tester, 2), const Rect.fromLTWH(0, 103.5, 800, 200));
  });

  testWidgets('changing which children span the whole cross axis',
      (WidgetTester tester) async {
    await tester.pumpWidget(grid(isFullSpan: {2}.contains));
    expect(rectOf(tester, 2).width, 800);

    // A new function makes the grid check the children again.
    await tester.pumpWidget(grid(isFullSpan: {3}.contains));

    expect(rectOf(tester, 2).width, 398);
    expect(rectOf(tester, 3).width, 800);
    expect(
      rectOf(tester, 3).top,
      greaterThanOrEqualTo(rectOf(tester, 2).bottom + 4),
    );
  });

  testWidgets('scrolling back keeps the full span children in place',
      (WidgetTester tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(
      grid(
        controller: controller,
        itemCount: 300,
        crossAxisCount: 3,
        isFullSpan: (index) => index % 10 == 7,
      ),
    );

    final positions = <int, Rect>{};
    void check() {
      for (final element in find.byType(Tile).evaluate()) {
        final index = (element.widget as Tile).index;
        final rect = tester
            .getRect(find.byWidget(element.widget))
            .shift(Offset(0, controller.offset));
        expect(positions.putIfAbsent(index, () => rect), rect);
      }
    }

    for (var i = 0; i < 20; i++) {
      controller.jumpTo(controller.offset + 500);
      await tester.pump();
      check();
    }
    while (controller.offset > 0) {
      controller.jumpTo((controller.offset - 700).clamp(0, double.infinity));
      await tester.pump();
      check();
    }
  });

  testWidgets('isFullSpan is not called after the last child',
      (WidgetTester tester) async {
    final headers = [true, false, false, true, false];
    await tester.pumpWidget(
      grid(itemCount: headers.length, isFullSpan: (index) => headers[index]),
    );

    expect(rectOf(tester, 3).width, 800);
    expect(rectOf(tester, 4).width, 398);
  });
}
