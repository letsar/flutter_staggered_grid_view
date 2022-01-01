import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/src/rendering/sliver_simple_grid_delegate.dart';
import 'package:flutter_staggered_grid_view/src/widgets/uniform_track.dart';

/// A sliver that places multiple box children in a two dimensional arrangement.
///
/// [SliverAlignedGrid] places its children in a grid where each track has the
/// main axis extent of the widest child. Each child is stretched to match the
/// track main axis extent.
class SliverAlignedGrid extends StatelessWidget {
  /// Creates a custom [SliverAlignedGrid].
  const SliverAlignedGrid({
    Key? key,
    required this.itemBuilder,
    this.itemCount,
    required this.gridDelegate,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
  }) : super(key: key);

  /// Creates a sliver that places multiple box children in an aligned
  /// arrangement with a fixed number of tiles in the cross axis.
  ///
  /// The [crossAxisCount], [mainAxisSpacing] and [crossAxisSpacing] arguments
  /// must be greater than zero.
  SliverAlignedGrid.count({
    Key? key,
    required NullableIndexedWidgetBuilder itemBuilder,
    int? itemCount,
    required int crossAxisCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
  }) : this(
          key: key,
          itemBuilder: itemBuilder,
          itemCount: itemCount,
          gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
          ),
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
        );

  /// Creates a sliver that places multiple box children in an aligned
  /// arrangement with tiles that each have a maximum cross-axis extent.
  ///
  /// The [maxCrossAxisExtent], [mainAxisSpacing] and [crossAxisSpacing]
  /// arguments must be greater than zero.
  SliverAlignedGrid.extent({
    Key? key,
    required NullableIndexedWidgetBuilder itemBuilder,
    int? itemCount,
    required double maxCrossAxisExtent,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
  }) : this(
          key: key,
          itemBuilder: itemBuilder,
          itemCount: itemCount,
          gridDelegate: SliverSimpleGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxCrossAxisExtent,
          ),
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
        );

  /// {@macro fsgv.global.mainAxisSpacing}
  final double mainAxisSpacing;

  /// {@macro fsgv.global.crossAxisSpacing}
  final double crossAxisSpacing;

  /// {@macro fsgv.global.gridDelegate}
  final SliverSimpleGridDelegate gridDelegate;

  /// Called to build children for the sliver.
  ///
  /// Will be called only for indices greater than or equal to zero and less
  /// than [itemCount] (if [itemCount] is non-null).
  ///
  /// Should return null if asked to build a widget with a greater index than
  /// exists.
  ///
  /// The delegate wraps the children returned by this builder in
  /// [RepaintBoundary] widgets.
  final NullableIndexedWidgetBuilder itemBuilder;

  /// The total number of children this delegate can provide.
  ///
  /// If null, the number of children is determined by the least index for which
  /// [itemBuilder] returns null.
  final int? itemCount;

  /// Whether to wrap each child in an [AutomaticKeepAlive].
  ///
  /// Typically, children in lazy list are wrapped in [AutomaticKeepAlive]
  /// widgets so that children can use [KeepAliveNotification]s to preserve
  /// their state when they would otherwise be garbage collected off-screen.
  ///
  /// This feature (and [addRepaintBoundaries]) must be disabled if the children
  /// are going to manually maintain their [KeepAlive] state. It may also be
  /// more efficient to disable this feature if it is known ahead of time that
  /// none of the children will ever try to keep themselves alive.
  ///
  /// Defaults to true.
  final bool addAutomaticKeepAlives;

  /// Whether to wrap each child in a [RepaintBoundary].
  ///
  /// Typically, children in a scrolling container are wrapped in repaint
  /// boundaries so that they do not need to be repainted as the list scrolls.
  /// If the children are easy to repaint (e.g., solid color blocks or a short
  /// snippet of text), it might be more efficient to not add a repaint boundary
  /// and simply repaint the children during scrolling.
  ///
  /// Defaults to true.
  final bool addRepaintBoundaries;

  @override
  Widget build(BuildContext context) {
    final localItemCount = itemCount;
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = gridDelegate.getCrossAxisCount(
          constraints,
          crossAxisSpacing,
        );
        final listItemCount = localItemCount == null
            ? null
            : ((localItemCount + crossAxisCount - 1) ~/ crossAxisCount) * 2 - 1;
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index.isOdd) {
                return _Gap(mainAxisExtent: mainAxisSpacing);
              }

              final startIndex = (index ~/ 2) * crossAxisCount;
              final children = [
                for (int i = 0; i < crossAxisCount; i++)
                  _buildItem(context, startIndex + i, itemCount),
              ].whereNotNull();

              if (children.isEmpty) {
                return null;
              }

              return UniformTrack(
                direction: constraints.crossAxisDirection,
                division: crossAxisCount,
                spacing: crossAxisSpacing,
                children: [...children],
              );
            },
            childCount: listItemCount,
          ),
        );
      },
    );
  }

  Widget? _buildItem(BuildContext context, int index, int? childCount) {
    if (index < 0 || (childCount != null && index >= childCount)) {
      return null;
    }

    return itemBuilder(context, index);
  }
}

class _Gap extends StatelessWidget {
  const _Gap({
    Key? key,
    required this.mainAxisExtent,
  }) : super(key: key);

  final double mainAxisExtent;

  @override
  Widget build(BuildContext context) {
    final axis = axisDirectionToAxis(Scrollable.of(context)!.axisDirection);
    return axis == Axis.vertical
        ? SizedBox(height: mainAxisExtent)
        : SizedBox(width: mainAxisExtent);
  }
}
