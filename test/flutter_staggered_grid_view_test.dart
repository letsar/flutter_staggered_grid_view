import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test/test.dart' hide expect;

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

Size _getTileSize(StaggeredTile tile, double cellLength) {
  return Size(
    tile.crossAxisCellCount * cellLength,
    tile.mainAxisExtent ?? tile.mainAxisCellCount! * cellLength,
  );
}

void main() {
  testWidgets('StaggeredGridView - tile layout and scroll - ltr',
      (WidgetTester tester) async {
    /// Screen size: 800x600 by default.
    const Size screenSize = Size(800, 600);
    const int crossAxisCount = 4;
    final cellLength = screenSize.width / crossAxisCount;

    final List<int> log = <int>[];
    final widgets = List<Widget>.generate(20, (int i) {
      return Builder(
        builder: (BuildContext context) {
          log.add(i);
          return SizedBox(
            child: Text('$i'),
          );
        },
      );
    });
    const tiles = <StaggeredTile>[
      StaggeredTile.count(2, 2),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 2),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(4, 1),
      StaggeredTile.count(4, 2),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 4),
      StaggeredTile.count(1, 3),
      StaggeredTile.count(1, 2),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 1),
    ];

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: StaggeredGridView.count(
        crossAxisCount: crossAxisCount,
        staggeredTiles: tiles,
        children: widgets,
      ),
    ));

    const List<Offset> expectedTopLeftNormalizedOffsets = <Offset>[
      Offset(0, 0),
      Offset(2, 0),
      Offset(3, 0),
      Offset(2, 1),
      Offset(0, 2),
      Offset(0, 3),
      Offset(0, 5),
      Offset(1, 5),
      Offset(2, 5),
      Offset(3, 5),
      Offset(0, 6),
      Offset(1, 6),
      Offset(2, 6),
      Offset(3, 6),
      Offset(3, 7),
      Offset(2, 8),
      Offset(3, 8),
      Offset(1, 9),
      Offset(2, 9),
      Offset(3, 9),
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
    scrollPosition.jumpTo(1000);

    expect(log, isEmpty);
    await tester.pump();

    for (final item in log) {
      final finder = find.text('$item');
      if (finder.evaluate().isNotEmpty) {
        expect(
            tester.getTopLeft(find.text('$item')),
            equals(expectedTopLeftNormalizedOffsets[item] * cellLength -
                const Offset(0, 1000)));
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
    const Size screenSize = Size(800, 600);
    const int crossAxisCount = 4;
    final cellLength = screenSize.width / crossAxisCount;

    final List<int> log = <int>[];
    final widgets = List<Widget>.generate(20, (int i) {
      return Builder(
        builder: (BuildContext context) {
          log.add(i);
          return SizedBox(
            child: Text('$i'),
          );
        },
      );
    });
    const tiles = <StaggeredTile>[
      StaggeredTile.count(2, 2),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 2),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(4, 1),
      StaggeredTile.count(4, 2),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 4),
      StaggeredTile.count(1, 3),
      StaggeredTile.count(1, 2),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 1),
    ];

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.rtl,
      child: StaggeredGridView.count(
        crossAxisCount: crossAxisCount,
        staggeredTiles: tiles,
        children: widgets,
      ),
    ));

    const List<Offset> expectedTopRightNormalizedOffsets = <Offset>[
      Offset(4, 0),
      Offset(2, 0),
      Offset(1, 0),
      Offset(2, 1),
      Offset(4, 2),
      Offset(4, 3),
      Offset(4, 5),
      Offset(3, 5),
      Offset(2, 5),
      Offset(1, 5),
      Offset(4, 6),
      Offset(3, 6),
      Offset(2, 6),
      Offset(1, 6),
      Offset(1, 7),
      Offset(2, 8),
      Offset(1, 8),
      Offset(3, 9),
      Offset(2, 9),
      Offset(1, 9),
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
    scrollPosition.jumpTo(1000);

    expect(log, isEmpty);
    await tester.pump();

    for (final item in log) {
      final finder = find.text('$item');
      if (finder.evaluate().isNotEmpty) {
        expect(
            tester.getTopRight(find.text('$item')),
            equals(expectedTopRightNormalizedOffsets[item] * cellLength -
                const Offset(0, 1000)));
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
          return SizedBox(
            child: Text('$i'),
          );
        },
      );
    });

    const tiles = <StaggeredTile>[
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 1),
      StaggeredTile.count(1, 1),
    ];

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: StaggeredGridView.extent(
        maxCrossAxisExtent: 200,
        staggeredTiles: tiles,
        children: widgets,
      ),
    ));

    expect(tester.getTopLeft(find.text('0')), equals(const Offset(0, 0)));
    expect(tester.getTopLeft(find.text('1')), equals(const Offset(200, 0)));
    expect(tester.getTopLeft(find.text('2')), equals(const Offset(400, 0)));
    expect(tester.getTopLeft(find.text('3')), equals(const Offset(600, 0)));

    for (final item in log) {
      expect(tester.getSize(find.text('$item')), equals(const Size(200, 200)));
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
    final initialSize = tester.binding.renderView.configuration.size;
    tester.binding.renderView.configuration =
        TestViewConfiguration(size: initialSize.flipped);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: StaggeredGridView.extent(
        maxCrossAxisExtent: 200,
        staggeredTiles: tiles,
        children: widgets,
      ),
    ));

    expect(tester.getTopLeft(find.text('0')), equals(const Offset(0, 0)));
    expect(tester.getTopLeft(find.text('1')), equals(const Offset(200, 0)));
    expect(tester.getTopLeft(find.text('2')), equals(const Offset(400, 0)));
    expect(tester.getTopLeft(find.text('3')), equals(const Offset(0, 200)));
  });
}
