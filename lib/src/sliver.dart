import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_staggered_grid_view/src/sliver_staggered_grid.dart';
import 'package:flutter_staggered_grid_view/src/staggered_tile.dart';

/// A sliver that places multiple box children in a two dimensional arrangement.
///
/// [SliverStaggeredGrid] places its children in arbitrary positions determined by
/// [gridDelegate]. Each child is forced to have the size specified by the
/// [gridDelegate].
///
/// The main axis direction of a grid is the direction in which it scrolls; the
/// cross axis direction is the orthogonal direction.
///
/// ## Sample code
///
/// This example, which would be inserted into a [CustomScrollView.slivers]
/// list, shows 8 boxes:
///
/// ```dart
///new SliverStaggeredGrid.count(
///  crossAxisCount: 4,
///  mainAxisSpacing: 4.0,
///  crossAxisSpacing: 4.0,
///  children: const <Widget>[
///    const Text('1'),
///    const Text('2'),
///    const Text('3'),
///    const Text('4'),
///    const Text('5'),
///    const Text('6'),
///    const Text('7'),
///    const Text('8'),
///  ],
///  staggeredTiles: const <StaggeredTile>[
///    const StaggeredTile.count(2, 2),
///    const StaggeredTile.count(2, 1),
///    const StaggeredTile.count(2, 2),
///    const StaggeredTile.count(2, 1),
///    const StaggeredTile.count(2, 2),
///    const StaggeredTile.count(2, 1),
///    const StaggeredTile.count(2, 2),
///    const StaggeredTile.count(2, 1),
///  ],
///)
/// ```
///
/// See also:
///
///  * [SliverList], which places its children in a linear array.
///  * [SliverFixedExtentList], which places its children in a linear
///    array with a fixed extent in the main axis.
///  * [SliverPrototypeExtentList], which is similar to [SliverFixedExtentList]
///    except that it uses a prototype list item instead of a pixel value to define
///    the main axis extent of each item.
class SliverStaggeredGrid extends SliverMultiBoxAdaptorWidget {
  /// Creates a sliver that places multiple box children in a two dimensional
  /// arrangement.
  const SliverStaggeredGrid({
    Key key,
    @required SliverChildDelegate delegate,
    @required this.gridDelegate,
  })
      : super(key: key, delegate: delegate);

  /// Creates a sliver that places multiple box children in a two dimensional
  /// arrangement with a fixed number of tiles in the cross axis.
  ///
  /// Uses a [SliverStaggeredGridDelegateWithFixedCrossAxisCount] as the [gridDelegate],
  /// and a [SliverChildListDelegate] as the [delegate].
  ///
  /// See also:
  ///
  ///  * [new StaggeredGridView.count], the equivalent constructor for [StaggeredGridView] widgets.
  SliverStaggeredGrid.count({
    Key key,
    @required int crossAxisCount,
    double mainAxisSpacing: 0.0,
    double crossAxisSpacing: 0.0,
    List<Widget> children: const <Widget>[],
    List<StaggeredTile> staggeredTiles: const <StaggeredTile>[],
  })
      : gridDelegate = new SliverStaggeredGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileBuilder: (i) => staggeredTiles[i],
          staggeredTileCount: staggeredTiles?.length,
        ),
        super(key: key, delegate: new SliverChildListDelegate(children));

  /// Creates a sliver that places multiple box children in a two dimensional
  /// arrangement with tiles that each have a maximum cross-axis extent.
  ///
  /// Uses a [SliverStaggeredGridDelegateWithMaxCrossAxisExtent] as the [gridDelegate],
  /// and a [SliverChildListDelegate] as the [delegate].
  ///
  /// See also:
  ///
  ///  * [new StaggeredGridView.extent], the equivalent constructor for [StaggeredGridView] widgets.
  SliverStaggeredGrid.extent({
    Key key,
    @required double maxCrossAxisExtent,
    double mainAxisSpacing: 0.0,
    double crossAxisSpacing: 0.0,
    List<Widget> children: const <Widget>[],
    List<StaggeredTile> staggeredTiles: const <StaggeredTile>[],
  })
      : gridDelegate = new SliverStaggeredGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileBuilder: (i) => staggeredTiles[i],
          staggeredTileCount: staggeredTiles?.length,
        ),
        super(key: key, delegate: new SliverChildListDelegate(children));

  /// The delegate that controls the size and position of the children.
  final SliverStaggeredGridDelegate gridDelegate;

  @override
  RenderSliverGrid createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element = context;
    return new RenderSliverGrid(
        childManager: element, gridDelegate: gridDelegate);
  }

  @override
  void updateRenderObject(BuildContext context, RenderSliverGrid renderObject) {
    renderObject.gridDelegate = gridDelegate;
  }

  @override
  double estimateMaxScrollOffset(
    SliverConstraints constraints,
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  ) {
    return super.estimateMaxScrollOffset(
          constraints,
          firstIndex,
          lastIndex,
          leadingScrollOffset,
          trailingScrollOffset,
        ) ??
        gridDelegate
            .getLayout(constraints)
            .computeMaxScrollOffset(delegate.estimatedChildCount);
  }
}