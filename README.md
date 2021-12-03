[![Pub][pub_badge]][pub] [![BuyMeACoffee][buy_me_a_coffee_badge]][buy_me_a_coffee]


# flutter_staggered_grid_view
Provides a collection of Flutter grids layouts.

## Getting started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  flutter_staggered_grid_view: <latest_version>
```

In your library add the following import:

```dart
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
```

For help getting started with Flutter, view the online [documentation][flutter_documentation].

## Layouts

This package contains various grid layouts. In the following section, you'll discover each one of them.
The explanation of the layout will always considered a top-to-bottom and left-to-right directions to simplify the description. However it is possible to change these directions in the code.

### **Staggered**
![Staggered Grid Layout](/docs/images/staggered.png)

This layout is intended for a small number of items.

#### **Grid properties**
- Evenly divided in *n* columns
- Small number of items
- Not scrollable

#### **Tile properties**
- Must occupy 1 to *n* columns

#### **Placement algorithm**
- Top-most and then left-most

#### **Example**
```dart
```

### **Masonry**
![Masonry Grid Layout](/docs/images/masonry.png)

This layout facilitates the browsing of uncropped peer content. Container heights are sized based on the widget size.

#### **Grid properties**
- Evenly divided in *n* columns

#### **Tile properties**
- Must occupy 1 column only

#### **Placement algorithm**
- Top-most and then left-most

### **Quilted**
![Quilted Grid Layout](/docs/images/quilted.png)

This layout emphasizes certain items over others in a collection. It creates hierarchy using varied container sizes and ratios.

#### **Grid properties**
- Evenly divided in *n* columns
- The height of each row is equal to the width of each column
- A pattern defines the size of the tiles and different mode of repetition are possible

#### **Tile properties**
- Must occupy 1 to *n* columns
- Must occupy 1 or more entire rows

#### **Placement algorithm**
- Top-most and then left-most

### **Woven**
![Woven Grid Layout](/docs/images/woven.png)

This layout facilitates the browsing of peer content. The items are displayed in containers of varying ratios to create a rhythmic layout.

#### **Grid properties**
- Evenly divided in *n* columns
- The height the rows is the maximum height of the tiles
- A pattern defines the size of the tiles
- The size of the tiles follows the pattern in a 'z' sequence.

#### **Tile properties**
- The height is defined by an `aspectRatio` (width/height)
- The width is defined by a `crossAxisRatio` (width/column's width) between 0 (exclusive) and 1 (inclusive)
- Each tile can define how it is aligned within the available space

#### **Placement algorithm**
- Top-most and then left-most


### **Staired**
![Staired Grid Layout](/docs/images/staired.png)

This layout uses alternating container sizes and ratios to create a rhythmic effect. It's another kind of woven grid layout.

#### **Grid properties**
- A pattern defines the size of the tiles
- Each tile is shifted from the previous one by a margin in both axis
- The placement follows a 'z' sequence

#### **Tile properties**
- The height is defined by an `aspectRatio` (width/height)
- The width is defined by a `crossAxisRatio` (width/available horizontal space) between 0 (exclusive) and 1 (inclusive)

#### **Placement algorithm**
- In a 'z' sequence

## Sponsoring

I'm working on my packages on my free-time, but I don't have as much time as I would. If this package or any other package I created is helping you, please consider to sponsor me so that I can take time to read the issues, fix bugs, merge pull requests and add features to these packages.

## Contributions

Feel free to contribute to this project.

If you find a bug or want a feature, but don't know how to fix/implement it, please fill an [issue][issue].  
If you fixed a bug or implemented a feature, please send a [pull request][pr].

<!-- Links -->
[github_action_badge]: https://github.com/letsar/flutter_staggered_grid_view/workflows/Build/badge.svg
[github_action]: https://github.com/letsar/flutter_staggered_grid_view/actions
[pub_badge]: https://img.shields.io/pub/v/flutter_staggered_grid_view.svg
[pub]: https://pub.dartlang.org/packages/flutter_staggered_grid_view
[codecov]: https://codecov.io/gh/letsar/flutter_staggered_grid_view
[codecov_badge]: https://codecov.io/gh/letsar/flutter_staggered_grid_view/branch/main/graph/badge.svg
[buy_me_a_coffee]: https://www.buymeacoffee.com/romainrastel
[buy_me_a_coffee_badge]: https://img.buymeacoffee.com/button-api/?text=Donate&emoji=&slug=romainrastel&button_colour=29b6f6&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=FFDD00
[issue]: https://github.com/letsar/flutter_staggered_grid_view/issues
[pr]: https://github.com/letsar/flutter_staggered_grid_view/pulls
[flutter_documentation]: https://docs.flutter.dev/