import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

Size _getTileSize(StaggeredTile tile, double cellLength){
  return new Size(tile.crossAxisCellCount * cellLength, tile.mainAxisExtent
      ?? tile.mainAxisCellCount * cellLength);
}

void main() {
  testWidgets('StaggeredGridView - ', (WidgetTester tester) async {
    final MediaQueryData data = new MediaQueryData.fromWindow(ui.window);
    final Size screenSize = data.size;
    const int crossAxisCount = 4;
    double cellLength = screenSize.width / crossAxisCount;


    final List<int> log = <int>[];
    final widgets = new List<Widget>.generate(20, (int i){
      return new Builder(
        builder: (BuildContext context){
          log.add(i);
          return new Container(
            child: new Text('$i'),
          );
        },
      );
    });
    final tiles = const <StaggeredTile>[
      const StaggeredTile.cellCount(2,2),
      const StaggeredTile.cellCount(1,1),
      const StaggeredTile.cellCount(1,2),
      const StaggeredTile.cellCount(1,1),

      const StaggeredTile.cellCount(4,1),

      const StaggeredTile.cellCount(4,2),

      const StaggeredTile.cellCount(1,1),
      const StaggeredTile.cellCount(1,1),
      const StaggeredTile.cellCount(1,1),
      const StaggeredTile.cellCount(1,1),

      const StaggeredTile.cellCount(1,4),
      const StaggeredTile.cellCount(1,3),
      const StaggeredTile.cellCount(1,2),
      const StaggeredTile.cellCount(1,1),

      const StaggeredTile.cellCount(1,1),

      const StaggeredTile.cellCount(1,1),
      const StaggeredTile.cellCount(1,1),

      const StaggeredTile.cellCount(1,1),
      const StaggeredTile.cellCount(1,1),
      const StaggeredTile.cellCount(1,1),
    ];

    await tester.pumpWidget(
      new Directionality(
        textDirection : TextDirection.ltr,
        child: new StaggeredGridView(
            crossAxisSpacing: 0.0,
            mainAxisSpacing: 0.0,
            crossAxisCount: crossAxisCount,
            staggeredTiles: tiles,
            children: widgets,
        ),
      )
    );

    List<Offset> expectedTopLeftNormalizedOffsets = const <Offset>[
      const Offset(0.0, 0.0),
      const Offset(2.0, 0.0),
      const Offset(3.0, 0.0),
      const Offset(2.0, 1.0),

      const Offset(0.0, 2.0),

      const Offset(0.0, 3.0),

      const Offset(0.0, 4.0),
      const Offset(1.0, 4.0),
      const Offset(2.0, 4.0),
      const Offset(3.0, 4.0),

      const Offset(0.0, 5.0),
      const Offset(1.0, 5.0),
      const Offset(2.0, 5.0),
      const Offset(3.0, 5.0),

      const Offset(3.0, 6.0),
      const Offset(2.0, 7.0),
      const Offset(3.0, 7.0),
      const Offset(1.0, 8.0),
      const Offset(2.0, 8.0),
      const Offset(3.0, 8.0),
    ];

    for (var item in log) {
      expect(tester.getTopLeft(find.text('$item')), equals
        (expectedTopLeftNormalizedOffsets[item] * cellLength));
      expect(tester.getSize(find.text('$item')), equals(_getTileSize
        (tiles[item],
          cellLength)));
    }

    expect(log, equals(<int>[
      0, 1, 2,
      3, 4, 5,
    ]));
    log.clear();

    final ScrollableState scrollableState = tester.state(find.byType(Scrollable));
    final ScrollPosition scrollPosition = scrollableState.position;
    scrollPosition.jumpTo(800.0);

    expect(log, isEmpty);
    await tester.pump();

    for (var item in log) {
      expect(tester.getTopLeft(find.text('$item')), equals
        (expectedTopLeftNormalizedOffsets[item] * cellLength  - const Offset
        (0.0, 800.0)));
      expect(tester.getSize(find.text('$item')), equals(_getTileSize
        (tiles[item],
          cellLength)));
    }

    expect(log, equals(<int>[
      6, 7, 8, 9,
      10, 11, 12, 13,
      14, 15, 16
    ]));
    log.clear();

  });
}
