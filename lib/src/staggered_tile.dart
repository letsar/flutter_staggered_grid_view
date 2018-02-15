/// Holds the dimensions of a tile in an [StaggeredGridView].
///
/// A [StaggeredTile] always overlaps an exact number of cells in the cross
/// axis of an [StaggeredGridView].
/// The main axis extent can either be a number of pixels or a number of
/// cells to overlap.
class StaggeredTile {
  /// Creates a [StaggeredTile] with the given [crossAxisCellCount] and
  /// [aspectRatio].
  ///
  /// The main axis extent of this tile will be the length of
  /// [aspectRatio] cells (inner spacings included).
  const StaggeredTile.ratio(this.crossAxisCellCount, this.aspectRatio)
      : assert(crossAxisCellCount != null && crossAxisCellCount >= 0),
        assert(aspectRatio != null && aspectRatio >= 0),
        mainAxisExtent = null;

  /// Creates a [StaggeredTile] with the given [crossAxisCellCount] and
  /// [mainAxisExtent].
  ///
  /// This tile will have a fixed main axis extent.
  const StaggeredTile.extent(this.crossAxisCellCount, this.mainAxisExtent)
      : assert(crossAxisCellCount != null && crossAxisCellCount >= 0),
        assert(mainAxisExtent != null && mainAxisExtent >= 0),
        aspectRatio = null;

  /// The number of cells occupied in the cross axis.
  final int crossAxisCellCount;

  /// The ratio of the cross-axis to the main-axis extent.
  final num aspectRatio;

  /// The number of pixels occupied in the main axis.
  final double mainAxisExtent;
}
