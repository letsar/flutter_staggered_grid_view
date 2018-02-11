import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/src/sliver_staggered_grid.dart';

/// A scrollable 2D array of widgets that can have variable sizes.
class StaggeredGridView extends GridView {
  /// Creates a scrollable 2D array of widgets with variable sizes.
  ///
  /// The [crossAxisCount] is the number of spans in the cross axis.
  /// Typically for a vertical direction, this is the number of columns of
  /// your grid view. Each widget can have a span from 1 to [crossAxisCount].
  /// It must be strictly positive.
  ///
  /// The [staggeredTileBuilder] gives the tile layout for the widget at the
  /// specified index.
  ///
  /// The [itemBuilder] has the same meaning as in [new GridView.builder].
  ///
  /// The [mainAxisSpacing] and [crossAxisSpacing] are the number of pixels
  /// between your widgets. These arguments are 0.0 by default and must be
  /// positives.
  ///
  /// The [mainAxisRatio] is the ratio between the computed cross axis extent
  /// for one span and the main axis extent of your widgets.
  /// For example, by setting a [mainAxisRatio] to 1, the widget for a tile
  /// size of (1, 1.0) will be a square.
  /// If you do not set the [mainAxisRatio] or set it to null, the extent of
  /// the tile size will be the main axis extent of your widget.
  StaggeredGridView.builder({
    Key key,
    Axis scrollDirection: Axis.vertical,
    ScrollController controller,
    bool primary,
    ScrollPhysics physics,
    bool shrinkWrap: false,
    EdgeInsetsGeometry padding,
    double mainAxisSpacing: 0.0,
    double crossAxisSpacing: 0.0,
    @required int crossAxisCount,
    @required IndexedStaggeredTileBuilder staggeredTileBuilder,
    @required IndexedWidgetBuilder itemBuilder,
    double mainAxisRatio,
    int itemCount,
    bool addAutomaticKeepAlives: true,
    bool addRepaintBoundaries: true,
  })
      : assert(crossAxisCount > 0),
        assert(staggeredTileBuilder != null),
        assert(itemBuilder != null),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0.0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0.0),
        super.custom(
            key: key,
            scrollDirection: scrollDirection,
            reverse: false,
            controller: controller,
            primary: primary,
            physics: physics,
            shrinkWrap: shrinkWrap,
            padding: padding,
            gridDelegate: new SliverStaggeredGridDelegate(
              crossAxisCount: crossAxisCount,
              staggeredTileBuilder: staggeredTileBuilder,
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
            ),
            childrenDelegate: new SliverChildBuilderDelegate(
              itemBuilder,
              childCount: itemCount,
              addAutomaticKeepAlives: addAutomaticKeepAlives,
              addRepaintBoundaries: addRepaintBoundaries,
            ));
}
