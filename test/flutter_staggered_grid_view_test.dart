import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test/test.dart' hide expect;

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

Size _getTileSize(StaggeredTile tile, double cellLength) {
  return Size(tile.crossAxisCellCount * cellLength,
      tile.mainAxisExtent ?? tile.mainAxisCellCount * cellLength);
}

void main() {
  testWidgets('StaggeredGridView - tile layout and scroll - ltr',
      (WidgetTester tester) async {
    /// Screen size: 800x600 by default.
    const Size screenSize = const Size(800.0, 600.0);
    const int crossAxisCount = 4;
    double cellLength = screenSize.width / crossAxisCount;

    final List<int> log = <int>[];
    final widgets = List<Widget>.generate(20, (int i) {
      return Builder(
        builder: (BuildContext context) {
          log.add(i);
          return Container(
            child: Text('$i'),
          );
        },
      );
    });
    final tiles = const <StaggeredTile>[
      const StaggeredTile.count(2, 2),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 2),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(4, 1),
      const StaggeredTile.count(4, 2),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 4),
      const StaggeredTile.count(1, 3),
      const StaggeredTile.count(1, 2),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 1),
    ];

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: StaggeredGridView.count(
        crossAxisSpacing: 0.0,
        mainAxisSpacing: 0.0,
        crossAxisCount: crossAxisCount,
        staggeredTiles: tiles,
        children: widgets,
      ),
    ));

    List<Offset> expectedTopLeftNormalizedOffsets = const <Offset>[
      const Offset(0.0, 0.0),
      const Offset(2.0, 0.0),
      const Offset(3.0, 0.0),
      const Offset(2.0, 1.0),
      const Offset(0.0, 2.0),
      const Offset(0.0, 3.0),
      const Offset(0.0, 5.0),
      const Offset(1.0, 5.0),
      const Offset(2.0, 5.0),
      const Offset(3.0, 5.0),
      const Offset(0.0, 6.0),
      const Offset(1.0, 6.0),
      const Offset(2.0, 6.0),
      const Offset(3.0, 6.0),
      const Offset(3.0, 7.0),
      const Offset(2.0, 8.0),
      const Offset(3.0, 8.0),
      const Offset(1.0, 9.0),
      const Offset(2.0, 9.0),
      const Offset(3.0, 9.0),
    ];

    for (int i = 0; i < 5; i++) {
      expect(tester.getTopLeft(find.text('$i')),
          equals(expectedTopLeftNormalizedOffsets[i] * cellLength));
      expect(tester.getSize(find.text('$i')),
          equals(_getTileSize(tiles[i], cellLength)));
    }

    expect(
        log,
        equals(<int>[
          0,
          1,
          2,
          3,
          4,
          5,
        ]));
    log.clear();

    final ScrollableState scrollableState =
        tester.state(find.byType(Scrollable));
    final ScrollPosition scrollPosition = scrollableState.position;
    scrollPosition.jumpTo(1000.0);

    expect(log, isEmpty);
    await tester.pump();

    for (var item in log) {
      var finder = find.text('$item');
      if (finder.evaluate().isNotEmpty) {
        expect(
            tester.getTopLeft(find.text('$item')),
            equals(expectedTopLeftNormalizedOffsets[item] * cellLength -
                const Offset(0.0, 1000.0)));
        expect(tester.getSize(find.text('$item')),
            equals(_getTileSize(tiles[item], cellLength)));
      }
    }

    expect(
        log, equals(<int>[6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]));
    log.clear();
  });

  testWidgets('StaggeredGridView - tile layout and scroll - rtl',
      (WidgetTester tester) async {
    /// Screen size: 800x600 by default.
    const Size screenSize = const Size(800.0, 600.0);
    const int crossAxisCount = 4;
    double cellLength = screenSize.width / crossAxisCount;

    final List<int> log = <int>[];
    final widgets = List<Widget>.generate(20, (int i) {
      return Builder(
        builder: (BuildContext context) {
          log.add(i);
          return Container(
            child: Text('$i'),
          );
        },
      );
    });
    final tiles = const <StaggeredTile>[
      const StaggeredTile.count(2, 2),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 2),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(4, 1),
      const StaggeredTile.count(4, 2),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 4),
      const StaggeredTile.count(1, 3),
      const StaggeredTile.count(1, 2),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 1),
    ];

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.rtl,
      child: StaggeredGridView.count(
        crossAxisSpacing: 0.0,
        mainAxisSpacing: 0.0,
        crossAxisCount: crossAxisCount,
        staggeredTiles: tiles,
        children: widgets,
      ),
    ));

    List<Offset> expectedTopRightNormalizedOffsets = const <Offset>[
      const Offset(4.0, 0.0),
      const Offset(2.0, 0.0),
      const Offset(1.0, 0.0),
      const Offset(2.0, 1.0),
      const Offset(4.0, 2.0),
      const Offset(4.0, 3.0),
      const Offset(4.0, 5.0),
      const Offset(3.0, 5.0),
      const Offset(2.0, 5.0),
      const Offset(1.0, 5.0),
      const Offset(4.0, 6.0),
      const Offset(3.0, 6.0),
      const Offset(2.0, 6.0),
      const Offset(1.0, 6.0),
      const Offset(1.0, 7.0),
      const Offset(2.0, 8.0),
      const Offset(1.0, 8.0),
      const Offset(3.0, 9.0),
      const Offset(2.0, 9.0),
      const Offset(1.0, 9.0),
    ];

    for (int i = 0; i < 5; i++) {
      expect(tester.getTopRight(find.text('$i')),
          equals(expectedTopRightNormalizedOffsets[i] * cellLength));
      expect(tester.getSize(find.text('$i')),
          equals(_getTileSize(tiles[i], cellLength)));
    }

    expect(
        log,
        equals(<int>[
          0,
          1,
          2,
          3,
          4,
          5,
        ]));
    log.clear();

    final ScrollableState scrollableState =
        tester.state(find.byType(Scrollable));
    final ScrollPosition scrollPosition = scrollableState.position;
    scrollPosition.jumpTo(1000.0);

    expect(log, isEmpty);
    await tester.pump();

    for (var item in log) {
      var finder = find.text('$item');
      if (finder.evaluate().isNotEmpty) {
        expect(
            tester.getTopRight(find.text('$item')),
            equals(expectedTopRightNormalizedOffsets[item] * cellLength -
                const Offset(0.0, 1000.0)));
        expect(tester.getSize(find.text('$item')),
            equals(_getTileSize(tiles[item], cellLength)));
      }
    }

    expect(
        log, equals(<int>[6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]));
    log.clear();
  });

  testWidgets('StaggeredGridView.extent - rotate', (WidgetTester tester) async {
    final List<int> log = <int>[];

    final widgets = List<Widget>.generate(4, (int i) {
      return Builder(
        builder: (BuildContext context) {
          log.add(i);
          return Container(
            child: Text('$i'),
          );
        },
      );
    });

    final tiles = const <StaggeredTile>[
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 1),
      const StaggeredTile.count(1, 1),
    ];

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: StaggeredGridView.extent(
        crossAxisSpacing: 0.0,
        mainAxisSpacing: 0.0,
        maxCrossAxisExtent: 200.0,
        staggeredTiles: tiles,
        children: widgets,
      ),
    ));

    expect(tester.getTopLeft(find.text('0')), equals(const Offset(0.0, 0.0)));
    expect(tester.getTopLeft(find.text('1')), equals(const Offset(200.0, 0.0)));
    expect(tester.getTopLeft(find.text('2')), equals(const Offset(400.0, 0.0)));
    expect(tester.getTopLeft(find.text('3')), equals(const Offset(600.0, 0.0)));

    for (var item in log) {
      expect(
          tester.getSize(find.text('$item')), equals(const Size(200.0, 200.0)));
    }

    expect(
        log,
        equals(<int>[
          0,
          1,
          2,
          3,
        ]));

    log.clear();

    // Simulate a screen rotation.
    Size initialSize = tester.binding.renderView.configuration.size;
    tester.binding.renderView.configuration =
        TestViewConfiguration(size: initialSize.flipped);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: StaggeredGridView.extent(
        crossAxisSpacing: 0.0,
        mainAxisSpacing: 0.0,
        maxCrossAxisExtent: 200.0,
        staggeredTiles: tiles,
        children: widgets,
      ),
    ));

    expect(tester.getTopLeft(find.text('0')), equals(const Offset(0.0, 0.0)));
    expect(tester.getTopLeft(find.text('1')), equals(const Offset(200.0, 0.0)));
    expect(tester.getTopLeft(find.text('2')), equals(const Offset(400.0, 0.0)));
    expect(tester.getTopLeft(find.text('3')), equals(const Offset(0.0, 200.0)));
  });
}
