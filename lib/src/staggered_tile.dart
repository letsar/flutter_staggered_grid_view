/// Holds the dimensions of a tile in an [StaggeredGridView].
///
/// A [StaggeredTile] always overlaps an exact number of cells in the cross
/// axis of an [StaggeredGridView].
/// The main axis extent can either be a number of pixels or a number of
/// cells to overlap.
class StaggeredTile {
  /// Creates a [StaggeredTile] with the given [crossAxisCellCount] and
  /// [mainAxisCellCount].
  ///
  /// The main axis extent of this tile will be the length of
  /// [mainAxisCellCount] cells (inner spacings included).
  const StaggeredTile.count(this.crossAxisCellCount, this.mainAxisCellCount)
      : mainAxisExtent = null,
        assert(crossAxisCellCount != null && crossAxisCellCount >= 0),
        assert(mainAxisCellCount != null && mainAxisCellCount >= 0);

  /// Creates a [StaggeredTile] with the given [crossAxisCellCount] and
  /// [mainAxisExtent].
  ///
  /// This tile will have a fixed main axis extent.
  const StaggeredTile.extent(this.crossAxisCellCount, this.mainAxisExtent)
      : mainAxisCellCount = null,
        assert(crossAxisCellCount != null && crossAxisCellCount >= 0),
        assert(mainAxisExtent != null && mainAxisExtent >= 0);

  /// The number of cells occupied in the cross axis.
  final int crossAxisCellCount;

  /// The number of cells occupied in the main axis.
  final int mainAxisCellCount;

  /// The number of pixels occupied in the main axis.
  final double mainAxisExtent;
}
