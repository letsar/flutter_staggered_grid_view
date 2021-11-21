abstract class GridTile {
  const GridTile._({
    required this.crossAxisCellCount,
  });

  const factory GridTile.extent({
    required int crossAxisCellCount,
    required double mainAxisExtent,
  }) = _MainAxisExtentGridTile;

  const factory GridTile.count({
    required int crossAxisCellCount,
    required num mainAxisCellCount,
  }) = _MainAxisCellCountGridTile;

  final int crossAxisCellCount;

  double computeMainExtent(double crossAxisExtent);
}

class _MainAxisCellCountGridTile extends GridTile {
  const _MainAxisCellCountGridTile({
    required int crossAxisCellCount,
    required this.mainAxisCellCount,
  }) : super._(crossAxisCellCount: crossAxisCellCount);

  final num mainAxisCellCount;

  @override
  double computeMainExtent(double crossAxisExtent) {
    return crossAxisExtent * mainAxisCellCount;
  }
}

class _MainAxisExtentGridTile extends GridTile {
  const _MainAxisExtentGridTile({
    required int crossAxisCellCount,
    required this.mainAxisExtent,
  }) : super._(crossAxisCellCount: crossAxisCellCount);

  final double mainAxisExtent;

  @override
  double computeMainExtent(double crossAxisExtent) {
    return mainAxisExtent;
  }
}
