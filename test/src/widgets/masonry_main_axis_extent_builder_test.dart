import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common.dart';

double extentOf(int index) => (index * 37 % 11 + 1) * 40.0;

Widget grid({
  required ScrollController controller,
  int crossAxisCount = 3,
  int? itemCount = 200,
  MasonryMainAxisExtentBuilder? mainAxisExtentBuilder,
  double? tileHeight,
  void Function(int index)? onBuild,
}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MasonryGridView.count(
      controller: controller,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      itemCount: itemCount,
      mainAxisExtentBuilder: mainAxisExtentBuilder,
      itemBuilder: (context, index) {
        onBuild?.call(index);
        return Tile(
          key: ValueKey(index),
          index: index,
          height: tileHeight ?? extentOf(index),
        );
      },
    ),
  );
}

Map<int, Rect> visibleRects(WidgetTester tester) {
  return {
    for (final element in find.byType(Tile).evaluate())
      (element.widget as Tile).index:
          tester.getRect(find.byWidget(element.widget)),
  };
}

void main() {
  testWidgets('places children like when they are measured',
      (WidgetTester tester) async {
    final controller = ScrollController();
    final measured = <Map<int, Rect>>[];
    final computed = <Map<int, Rect>>[];
    for (final (builder, rects) in [
      (null, measured),
      ((int index, double _) => extentOf(index), computed),
    ]) {
      await tester.pumpWidget(
        grid(controller: controller, mainAxisExtentBuilder: builder),
      );
      for (final offset in <double>[0, 1500, 6000, 300]) {
        controller.jumpTo(offset);
        await tester.pump();
        rects.add(visibleRects(tester));
      }
      await tester.pumpWidget(const SizedBox());
    }

    expect(computed, measured);
  });

  testWidgets('jumping far only builds the visible children',
      (WidgetTester tester) async {
    final controller = ScrollController();
    final built = <int>{};
    await tester.pumpWidget(
      grid(
        controller: controller,
        itemCount: 10000,
        mainAxisExtentBuilder: (index, _) => extentOf(index),
        onBuild: built.add,
      ),
    );
    built.clear();

    controller.jumpTo(500000);
    await tester.pump();

    expect(built.length, lessThan(60));
    expect(built.reduce((a, b) => a < b ? a : b), greaterThan(6000));
  });

  testWidgets('the scroll extent is exact from the start',
      (WidgetTester tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(
      grid(
        controller: controller,
        mainAxisExtentBuilder: (index, _) => extentOf(index),
      ),
    );
    final maxScrollExtent = controller.position.maxScrollExtent;

    controller.jumpTo(maxScrollExtent);
    await tester.pump();
    expect(controller.position.maxScrollExtent, maxScrollExtent);
    expect(find.text('199'), findsOneWidget);
  });

  testWidgets('children are forced to the returned extent',
      (WidgetTester tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(
      grid(
        controller: controller,
        tileHeight: 10,
        mainAxisExtentBuilder: (index, crossAxisExtent) => crossAxisExtent / 2,
      ),
    );

    // (800 - 2 * 4) / 3 = 264.
    expect(tester.getSize(find.byKey(const ValueKey(0))), const Size(264, 132));
  });

  testWidgets('null means there are no more children',
      (WidgetTester tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(
      grid(
        controller: controller,
        itemCount: null,
        mainAxisExtentBuilder: (index, _) =>
            index < 50 ? extentOf(index) : null,
      ),
    );

    // The number of children is unknown until the end is reached.
    controller.jumpTo(100000);
    await tester.pump();
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    expect(controller.offset, controller.position.maxScrollExtent);
    expect(controller.offset, greaterThan(0));
    expect(find.text('49'), findsOneWidget);
    expect(find.text('50'), findsNothing);
  });

  testWidgets('extents larger than the child count are ignored',
      (WidgetTester tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(
      grid(
        controller: controller,
        itemCount: 30,
        mainAxisExtentBuilder: (index, _) => extentOf(index),
      ),
    );

    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    expect(find.text('29'), findsOneWidget);
  });

  testWidgets('new extents are used when children are laid out again',
      (WidgetTester tester) async {
    final controller = ScrollController();
    var factor = 1.0;
    Widget build() => grid(
          controller: controller,
          mainAxisExtentBuilder: (index, _) => extentOf(index) * factor,
        );

    await tester.pumpWidget(build());
    factor = 2;
    await tester.pumpWidget(build());

    expect(tester.getSize(find.byKey(const ValueKey(0))).height, 80);
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    controller.jumpTo(0);
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('changing crossAxisCount does not build hidden children',
      (WidgetTester tester) async {
    final controller = ScrollController();
    final built = <int>{};
    Widget build(int crossAxisCount) => grid(
          controller: controller,
          crossAxisCount: crossAxisCount,
          itemCount: 10000,
          mainAxisExtentBuilder: (index, _) => extentOf(index),
          onBuild: built.add,
        );

    await tester.pumpWidget(build(3));
    controller.jumpTo(300000);
    await tester.pump();
    final anchor = (find.byType(Tile).evaluate().first.widget as Tile).index;
    final top = tester.getTopLeft(find.byKey(ValueKey(anchor))).dy;
    built.clear();

    await tester.pumpWidget(build(2));
    expect(tester.getTopLeft(find.byKey(ValueKey(anchor))).dy, top);
    expect(built.length, lessThan(60));
  });
}
