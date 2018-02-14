import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

Size _getTileSize(StaggeredTile tile, double cellLength){
  return new Size(tile.crossAxisCellCount * cellLength, tile.mainAxisExtent
      ?? tile.mainAxisCellCount * cellLength);
}

void main() {
  testWidgets('StaggeredGridView - ', (WidgetTester tester) async {
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
      const StaggeredTile.count(2,2),
      const StaggeredTile.count(1,1),
      const StaggeredTile.count(1,2),
      const StaggeredTile.count(1,1),

      const StaggeredTile.count(4,1),

      const StaggeredTile.count(4,2),

      const StaggeredTile.count(1,1),
      const StaggeredTile.count(1,1),
      const StaggeredTile.count(1,1),
      const StaggeredTile.count(1,1),

      const StaggeredTile.count(1,4),
      const StaggeredTile.count(1,3),
      const StaggeredTile.count(1,2),
      const StaggeredTile.count(1,1),

      const StaggeredTile.count(1,1),

      const StaggeredTile.count(1,1),
      const StaggeredTile.count(1,1),

      const StaggeredTile.count(1,1),
      const StaggeredTile.count(1,1),
      const StaggeredTile.count(1,1),
    ];

    await tester.pumpWidget(
      new Directionality(
        textDirection : TextDirection.ltr,
        child: new StaggeredGridView.count(
            crossAxisSpacing: 0.0,
            mainAxisSpacing: 0.0,
            crossAxisCount: 4,
            staggeredTiles: tiles,
            children: widgets,
        ),
      )
    );

    const double cellLength = 200.0;

    expect(tester.getTopLeft(find.text('0')), equals(const Offset(0.0, 0.0)));
    expect(tester.getTopLeft(find.text('1')), equals(const Offset(400.0, 0.0)));
    expect(tester.getTopLeft(find.text('2')), equals(const Offset(600.0, 0.0)));
    expect(tester.getTopLeft(find.text('3')), equals(const Offset(400.0, 200.0)));

    expect(tester.getTopLeft(find.text('4')), equals(const Offset(0.0, 400.0)));
    expect(tester.getTopLeft(find.text('5')), equals(const Offset(0.0, 600.0)));

    for (var i = 0; i < 6; ++i) {
      expect(tester.getSize(find.text('$i')), equals(_getTileSize(tiles[i],
          cellLength)));
    }

    expect(log, equals(<int>[
      0, 1, 2,
      3, 4, 5,
    ]));
    log.clear();

    final ScrollableState scrollableState = tester.state(find.byType(Scrollable));
    final ScrollPosition scrollPosition = scrollableState.position;
    scrollPosition.jumpTo(1000.0);

    expect(log, isEmpty);
    await tester.pump();

    expect(log, equals(<int>[
      6, 7, 8, 9,
      10, 11, 12, 13,
      14, 15, 16
    ]));
    log.clear();

  });
}
