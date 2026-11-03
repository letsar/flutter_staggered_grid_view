## 0.8.0-dev.1
### Added
* `mainAxisExtentBuilder` on `MasonryGridView` and `SliverMasonryGrid` to place the children without building them when their extents are known.
* `RenderSliverMasonryGrid.itemCount`, the exact number of children set by `SliverMasonryGrid`, to forget the placement of removed children.
### Changed
* Bump minimal Flutter version to 3.16.0
* `RenderSliverMasonryGrid` keeps the placement of every child laid out once, instead of guessing the placement of the previous children when scrolling back.
* Reaching a child far in a masonry grid lays out all the children before it once (like `ListView`), unless `mainAxisExtentBuilder` is provided.
* When the width of a masonry grid changes without changing its `crossAxisCount`, the visible children keep their state. The placement of the previous children is checked again when scrolling back, so they can move while the first visible child stays in place. With `mainAxisExtentBuilder`, every child is placed again right away.
* Changing the `crossAxisCount` or the `mainAxisSpacing` of a masonry grid places every child again, and the children are built again (like before).
* `SliverMasonryGrid` replaces the children moved with keys, like `SliverList`, so that inserting a child keeps the state of the others.
### Removed
* `SliverMasonryGridParentData.lastMainAxisExtent`.
### Fixed
* Scrolling issues with multiple `SliverMasonryGrid` in a `CustomScrollView` (https://github.com/letsar/flutter_staggered_grid_view/issues/338, https://github.com/letsar/flutter_staggered_grid_view/issues/335, https://github.com/letsar/flutter_staggered_grid_view/issues/299, https://github.com/letsar/flutter_staggered_grid_view/issues/286, https://github.com/letsar/flutter_staggered_grid_view/issues/265)
* Jumps and children changing columns when scrolling back in a masonry grid (https://github.com/letsar/flutter_staggered_grid_view/issues/244, https://github.com/letsar/flutter_staggered_grid_view/issues/330, https://github.com/letsar/flutter_staggered_grid_view/issues/356)
* `estimatedMaxScrollOffset >= endScrollOffset - leadingScrollOffset` assertion (https://github.com/letsar/flutter_staggered_grid_view/issues/313)
* Changing the `crossAxisCount` of a masonry grid keeps the first visible child in place (https://github.com/letsar/flutter_staggered_grid_view/issues/105)
* Negative child width in a masonry grid when the `crossAxisSpacing` is larger than the available space.

## 0.7.0
### Changed
* Bump minimal Flutter version to 3.7.0
### Fixed
* Warning with Scrollable.of

## 0.6.2
### Fixed
* Issue with Quilted layout algorithm. (https://github.com/letsar/flutter_staggered_grid_view/issues/232)

## 0.6.1
### Fixed
* Issue when childCount is 0 with Quilted layout.

## 0.6.0
### Added
* SliverAlignedGrid and AlignedGridView widgets.
### Changed
* Renamed SliverMasonryGridDelegate to SliverSimpleGridDelegate.

## 0.5.1
### Added
* StaggeredTile.fit constructor.

## 0.5.0
### Changed
* Stable release 

## 0.5.0-dev.8
### Changed
* Make the `childCount` parameter of `SliverMasonryGrid` constructors, nullable and not required.

## 0.5.0-dev.7
### Fixed
* Remove position issue with staired pattern.

## 0.5.0-dev.6
### Fixed
* Remove extra space on fixed woven grid.

## 0.5.0-dev.5
### Fixed
* Remove extra space on fixed quilted grid (#216).

## 0.5.0-dev.4
### Fixed
* Issue with Woven pattern layout flow in second run.

## 0.5.0-dev.3
### Fixed
* Issue with Woven pattern and text direction.

## 0.5.0-dev.2
### Fixed
* Issue with Quilted pattern.

## 0.5.0-dev.1
### Changed
* Complete rewriting of the package.
It comes now with 5 differents grid layouts (Staggered, Masonry, Quilted, Woven, Staired).

## 0.4.1
### Changed
* Add option to disable keepAlives

## 0.4.0
### Changed
* Stable null safety version

## 0.4.0-nullsafety.3
### Fixed
* LateInitializationError: Local `firstIndex` has not been initialized. (https://github.com/letsar/flutter_staggered_grid_view/issues/151)

## 0.4.0-nullsafety.2
### Added
* Support for state restoration

## 0.4.0-nullsafety.1
### Added
* Null Safety Support

## 0.3.4
### Fixed
* KeepAliveBucket logic, should improve performances

## 0.3.3
### Added
* Support for state restoration.

## 0.3.2
### Fixed
* Flutter version dependency.

## 0.3.1
### Fixed
* Static analysis issues.

## 0.3.0
### Fixed
* Upgrade to AndroidX and fixes the BoxHitTestResult exception (https://github.com/letsar/flutter_staggered_grid_view/issues/49)

## 0.2.7
### Fixed
* Better fix for the bug where items are built only once.

## 0.2.6
### Fixed
* Fix a bug where items are built only once.

## 0.2.5
### Changed
* Use the new SliverWithKeepAliveWidget.

## 0.2.4
### Fixed
* Dart 2.1 mixin support.

## 0.2.3
### Fixed
* Fix the rtl support (https://github.com/letsar/flutter_staggered_grid_view/issues/17).

## 0.2.2
* Add Dart 2 support.

## 0.2.1
* Fix #10 `StatefulWidget.createState must return a subtype of State<AutomaticKeepAliveVariableSizeBox>`.

## 0.2.0
* Add a way to let the tile's content to define the tile's extent in the main axis.
* Add `fit` constructor to `StaggeredTile`.

## 0.1.4
* Add `countBuilder` and `extendBuilder` constructors to `SliverStaggeredGrid`

## 0.1.3
* Remove Flutter SDK constraint

## 0.1.2
* Remove update Flutter SDK constraint

## 0.1.1
* Fix images in readme
* Add dynamic resizing demo

## 0.1.0
* Initial Open Source release