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