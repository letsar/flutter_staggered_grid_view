import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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
            crossAxisCount: 4,
            staggeredTiles: tiles,
            children: widgets,
        ),
      )
    );

    expect(tester.getTopLeft(find.text('1')), equals(const Offset(0.0, 0.0)));
    expect(tester.getSize(find.text('1')), equals(const Size(400.0, 400.0)));

    expect(log, equals(<int>[
      0, 1, 2,
      3, 4, 5,
      6, 7, 8,
    ]));
    log.clear();
  });
}
