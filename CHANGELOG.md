## 0.4.0
### Fixed
* Fixed the BoxHitTestResult exception (https://github.com/letsar/flutter_staggered_grid_view/issues/49) again after flutter v1.7 since flutter has changed the function signature for `hitTestChildren`, check [old](https://github.com/flutter/flutter/blob/953bbe2ccd45461f9cafc7c060cf2297227631d0/packages/flutter/lib/src/rendering/sliver_multi_box_adaptor.dart#L481) and [new](https://github.com/flutter/flutter/blob/b712a172f9694745f50505c93340883493b505e5/packages/flutter/lib/src/rendering/sliver_multi_box_adaptor.dart#L560)

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
