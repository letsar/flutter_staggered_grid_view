# flutter_staggered_grid_view

A Flutter staggered grid view which supports multiple columns with rows of varying sizes.
![Screenshot](https://github.com/letsar/flutter_staggered_grid_view/blob/master/doc/images/example_01.PNG)

## Features

    * Configurable cross-axis count or max cross-axis extent like the [`GridView`](https://docs.flutter.io/flutter/widgets/GridView-class.html)
    * Tiles can have a fixed main-axis extent, or a multiple of the cell's length.
    * Configurable main-axis and cross-axis margins between tiles.

## Getting started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  flutter_staggered_grid_view: "^0.1.0"
```

For help getting started with Flutter, view the online [documentation](https://flutter.io/).

## Example

![Screenshot](https://github.com/letsar/flutter_staggered_grid_view/blob/master/doc/images/example_02.PNG)

```dart
new StaggeredGridView.countBuilder(
    crossAxisCount: 4,
    itemCount: 8,
    itemBuilder: (BuildContext context, int index) => index >= 8
        ? null
        : new Container(
            color: Colors.green,
            child: new Center(
            child: new CircleAvatar(
                backgroundColor: Colors.white,
                child: new Text('$index'),
            ),
            )),
    staggeredTileBuilder: (int index) => index >= 8
        ? null
        : new StaggeredTile.count(2, index.isEven ? 2 : 1),
    mainAxisSpacing: 4.0,
    crossAxisSpacing: 4.0,
)
```
