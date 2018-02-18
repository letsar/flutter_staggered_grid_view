import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

StaggeredTile getIndexedStaggeredTile(int index, List<StaggeredTile> tiles){
  if (index < 0 || index >= tiles.length)
    return null;
  else
    return tiles[index];
}