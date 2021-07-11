import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_staggered_grid_view/src/rendering/sliver_staggered_grid.dart';
import 'package:flutter_staggered_grid_view/src/rendering/sliver_variable_size_box_adaptor.dart';
import 'package:flutter_staggered_grid_view/src/widgets/staggered_tile.dart';

/// A base class for sliver that have multiple variable size box children.
///
/// Helps subclasses build their children lazily using a [SliverVariableSizeChildDelegate].
abstract class SliverVariableSizeBoxAdaptorWidget
    extends SliverWithKeepAliveWidget {
  /// Initializes fields for subclasses.
  const SliverVariableSizeBoxAdaptorWidget({
    Key? key,
    required this.delegate,
    this.addAutomaticKeepAlives = true,
    this.forceKeepChildWidget = false
  }) : super(key: key);


  /// A flag for decide children are/aren't kept.
  ///
  /// * if it's true, the children will cached in [_keepAliveBucket].
  final bool addAutomaticKeepAlives;

  /// Clear the [_childWidgets] when it is false(default value).
  ///
  /// * sometimes you refresh whole widget(like called setState/notifyListener() in page),and
  ///   children's status doesn't change(e.g. called loadMore()),so set
  ///   this [forceKeepChildWidget] to true maybe is a goods choice, it will avoid to
  ///   call builder again.
  ///   more details see the doc above the [SliverVariableSizeBoxAdaptorElement._childWidgets]
  final bool forceKeepChildWidget;

  /// The delegate that provides the children for this widget.
  ///
  /// The children are constructed lazily using this widget to avoid creating
  /// more children than are visible through the [Viewport].
  ///
  /// See also:
  ///
  ///  * [SliverChildBuilderDelegate] and [SliverChildListDelegate], which are
  ///    commonly used subclasses of [SliverChildDelegate] that use a builder
  ///    callback and an explicit child list, respectively.
  final SliverChildDelegate delegate;

  @override
  SliverVariableSizeBoxAdaptorElement createElement() =>
      SliverVariableSizeBoxAdaptorElement(this,
          addAutomaticKeepAlives: addAutomaticKeepAlives,forceKeepChildWidget: forceKeepChildWidget);

  @override
  RenderSliverVariableSizeBoxAdaptor createRenderObject(BuildContext context);

  /// Returns an estimate of the max scroll extent for all the children.
  ///
  /// Subclasses should override this function if they have additional
  /// information about their max scroll extent.
  ///
  /// This is used by [SliverMultiBoxAdaptorElement] to implement part of the
  /// [RenderSliverBoxChildManager] API.
  ///
  /// The default implementation defers to [delegate] via its
  /// [SliverChildDelegate.estimateMaxScrollOffset] method.
  double? estimateMaxScrollOffset(
    SliverConstraints constraints,
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  ) {
    assert(lastIndex >= firstIndex);
    return delegate.estimateMaxScrollOffset(
      firstIndex,
      lastIndex,
      leadingScrollOffset,
      trailingScrollOffset,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<SliverChildDelegate>('delegate', delegate),
    );
  }
}

/// An element that lazily builds children for a [SliverVariableSizeBoxAdaptorWidget].
///
/// Implements [RenderSliverVariableSizeBoxChildManager], which lets this element manage
/// the children of subclasses of [RenderSliverVariableSizeBoxAdaptor].
class SliverVariableSizeBoxAdaptorElement extends RenderObjectElement
    implements RenderSliverVariableSizeBoxChildManager {
  /// Creates an element that lazily builds children for the given widget.
  SliverVariableSizeBoxAdaptorElement(
      SliverVariableSizeBoxAdaptorWidget widget , {this.addAutomaticKeepAlives = true, this.forceKeepChildWidget = false})
      : super(widget);

  /// A flag for decide children are/aren't kept.
  ///
  /// * if it's true, the children will cached in [_keepAliveBucket].
  final bool addAutomaticKeepAlives;

  /// Clear the [_childWidgets] when it is false(default value).
  ///
  /// * sometimes you refresh whole widget(like called setState/notifyListener() in page),and
  ///   children's status doesn't change(e.g. called loadMore()),so set
  ///   this [forceKeepChildWidget] to true maybe is a goods choice, it will avoid to
  ///   call builder again.
  ///   more details see the doc above the [_childWidgets]
  final bool forceKeepChildWidget;

  @override
  SliverVariableSizeBoxAdaptorWidget get widget =>
      super.widget as SliverVariableSizeBoxAdaptorWidget;

  @override
  RenderSliverVariableSizeBoxAdaptor get renderObject =>
      super.renderObject as RenderSliverVariableSizeBoxAdaptor;

  @override
  void update(covariant SliverVariableSizeBoxAdaptorWidget newWidget) {
    final SliverVariableSizeBoxAdaptorWidget oldWidget = widget;
    super.update(newWidget);
    final SliverChildDelegate newDelegate = newWidget.delegate;
    final SliverChildDelegate oldDelegate = oldWidget.delegate;
    if (newDelegate != oldDelegate &&
        (newDelegate.runtimeType != oldDelegate.runtimeType ||
            newDelegate.shouldRebuild(oldDelegate))) {
      performRebuild();
    }
  }

  // We inflate widgets at two different times:
  //  1. When we ourselves are told to rebuild (see performRebuild).
  //  2. When our render object needs a child (see createChild).
  // In both cases, we cache the results of calling into our delegate to get the widget,
  // so that if we do case 2 later, we don't call the builder again.
  // Any time we do case 1, though, we reset the cache.

  final Map<int, Widget?> _childWidgets = HashMap<int, Widget?>();
  final SplayTreeMap<int, Element> _childElements =
      SplayTreeMap<int, Element>();

  @override
  void performRebuild() {
    if(! forceKeepChildWidget) {
      _childWidgets.clear();// Reset the cache, as described above.
    }
    super.performRebuild();
    assert(_currentlyUpdatingChildIndex == null);
    try {
      late final int firstIndex;
      late final int lastIndex;
      if (_childElements.isEmpty) {
        firstIndex = 0;
        lastIndex = 0;
      } else if (_didUnderflow) {
        firstIndex = _childElements.firstKey()!;
        lastIndex = _childElements.lastKey()! + 1;
      } else {
        firstIndex = _childElements.firstKey()!;
        lastIndex = _childElements.lastKey()!;
      }

      for (int index = firstIndex; index <= lastIndex; ++index) {
        _currentlyUpdatingChildIndex = index;
        final Element? newChild =
            updateChild(_childElements[index], _build(index), index);
        if (newChild != null) {
          _childElements[index] = newChild;
        } else {
          _childElements.remove(index);
        }
      }
    } finally {
      _currentlyUpdatingChildIndex = null;
    }
  }

  Widget? _build(int index) {
    if(forceKeepChildWidget && _childWidgets[index] != null) {
      return _childWidgets[index];
    }
    return _childWidgets.putIfAbsent(
        index, () => widget.delegate.build(this, index));
  }

  @override
  void createChild(int index) {
    assert(_currentlyUpdatingChildIndex == null);
    owner!.buildScope(this, () {
      Element? newChild;
      try {
        _currentlyUpdatingChildIndex = index;
        newChild = updateChild(_childElements[index], _build(index), index);
      } finally {
        _currentlyUpdatingChildIndex = null;
      }
      if (newChild != null) {
        _childElements[index] = newChild;
      } else {
        _childElements.remove(index);
      }
    });
  }

  @override
  Element? updateChild(Element? child, Widget? newWidget, dynamic newSlot) {
    final oldParentData = child?.renderObject?.parentData
        as SliverVariableSizeBoxAdaptorParentData?;
    final Element? newChild = super.updateChild(child, newWidget, newSlot);
    final newParentData = newChild?.renderObject?.parentData
        as SliverVariableSizeBoxAdaptorParentData?;

    // set keepAlive to true in order to populate the cache
    if (addAutomaticKeepAlives && newParentData != null) {
      newParentData.keepAlive = true;
    }

    // Preserve the old layoutOffset if the renderObject was swapped out.
    if (oldParentData != newParentData &&
        oldParentData != null &&
        newParentData != null) {
      newParentData.layoutOffset = oldParentData.layoutOffset;
    }

    return newChild;
  }

  @override
  void forgetChild(Element child) {
    assert(child.slot != null);
    assert(_childElements.containsKey(child.slot));
    _childElements.remove(child.slot);
    super.forgetChild(child);
  }

  @override
  void removeChild(RenderBox child) {
    final int index = renderObject.indexOf(child);
    assert(_currentlyUpdatingChildIndex == null);
    assert(index >= 0);
    owner!.buildScope(this, () {
      assert(_childElements.containsKey(index));
      try {
        _currentlyUpdatingChildIndex = index;
        final Element? result = updateChild(_childElements[index], null, index);
        assert(result == null);
      } finally {
        _currentlyUpdatingChildIndex = null;
      }
      _childElements.remove(index);
      assert(!_childElements.containsKey(index));
    });
  }

  double? _extrapolateMaxScrollOffset(
    int? firstIndex,
    int? lastIndex,
    double? leadingScrollOffset,
    double? trailingScrollOffset,
  ) {
    final int? childCount = widget.delegate.estimatedChildCount;
    if (childCount == null) {
      return double.infinity;
    }
    if (lastIndex == childCount - 1) {
      return trailingScrollOffset;
    }
    final int reifiedCount = lastIndex! - firstIndex! + 1;
    final double averageExtent =
        (trailingScrollOffset! - leadingScrollOffset!) / reifiedCount;
    final int remainingCount = childCount - lastIndex - 1;
    return trailingScrollOffset + averageExtent * remainingCount;
  }

  @override
  double estimateMaxScrollOffset(
    SliverConstraints constraints, {
    int? firstIndex,
    int? lastIndex,
    double? leadingScrollOffset,
    double? trailingScrollOffset,
  }) {
    return widget.estimateMaxScrollOffset(
          constraints,
          firstIndex!,
          lastIndex!,
          leadingScrollOffset!,
          trailingScrollOffset!,
        ) ??
        _extrapolateMaxScrollOffset(
          firstIndex,
          lastIndex,
          leadingScrollOffset,
          trailingScrollOffset,
        )!;
  }

  @override
  int get childCount => widget.delegate.estimatedChildCount ?? 0;

  @override
  void didStartLayout() {
    assert(debugAssertChildListLocked());
  }

  @override
  void didFinishLayout() {
    assert(debugAssertChildListLocked());
    final int firstIndex = _childElements.firstKey() ?? 0;
    final int lastIndex = _childElements.lastKey() ?? 0;
    widget.delegate.didFinishLayout(firstIndex, lastIndex);
  }

  int? _currentlyUpdatingChildIndex;

  @override
  bool debugAssertChildListLocked() {
    assert(_currentlyUpdatingChildIndex == null);
    return true;
  }

  @override
  void didAdoptChild(RenderBox child) {
    assert(_currentlyUpdatingChildIndex != null);
    final childParentData =
        child.parentData! as SliverVariableSizeBoxAdaptorParentData;
    childParentData.index = _currentlyUpdatingChildIndex;
  }

  bool _didUnderflow = false;

  @override
  void setDidUnderflow(bool value) {
    _didUnderflow = value;
  }

  @override
  void insertRenderObjectChild(covariant RenderBox child, int slot) {
    assert(_currentlyUpdatingChildIndex == slot);
    assert(renderObject.debugValidateChild(child));
    renderObject[_currentlyUpdatingChildIndex!] = child;
    assert(() {
      final childParentData =
          child.parentData! as SliverVariableSizeBoxAdaptorParentData;
      assert(slot == childParentData.index);
      return true;
    }());
  }

  @override
  void moveRenderObjectChild(
    covariant RenderObject child,
    covariant Object? oldSlot,
    covariant Object? newSlot,
  ) {
    assert(false);
  }

  @override
  void removeRenderObjectChild(
    covariant RenderObject child,
    covariant Object? slot,
  ) {
    assert(_currentlyUpdatingChildIndex != null);
    renderObject.remove(_currentlyUpdatingChildIndex!);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    // The toList() is to make a copy so that the underlying list can be modified by
    // the visitor:
    _childElements.values.toList().forEach(visitor);
  }

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    _childElements.values.where((Element child) {
      final parentData =
          child.renderObject!.parentData as SliverMultiBoxAdaptorParentData?;
      late double itemExtent;
      switch (renderObject.constraints.axis) {
        case Axis.horizontal:
          itemExtent = child.renderObject!.paintBounds.width;
          break;
        case Axis.vertical:
          itemExtent = child.renderObject!.paintBounds.height;
          break;
      }

      return parentData!.layoutOffset! <
              renderObject.constraints.scrollOffset +
                  renderObject.constraints.remainingPaintExtent &&
          parentData.layoutOffset! + itemExtent >
              renderObject.constraints.scrollOffset;
    }).forEach(visitor);
  }
}

/// A sliver that places multiple box children in a two dimensional arrangement.
///
/// [SliverStaggeredGrid] places its children in arbitrary positions determined by
/// [gridDelegate]. Each child is forced to have the size specified by the
/// [gridDelegate].
///
/// The main axis direction of a grid is the direction in which it scrolls; the
/// cross axis direction is the orthogonal direction.
///
/// ## Sample code
///
/// This example, which would be inserted into a [CustomScrollView.slivers]
/// list, shows 8 boxes:
///
/// ```dart
///SliverStaggeredGrid.count(
///  crossAxisCount: 4,
///  mainAxisSpacing: 4.0,
///  crossAxisSpacing: 4.0,
///  children: const <Widget>[
///    const Text('1'),
///    const Text('2'),
///    const Text('3'),
///    const Text('4'),
///    const Text('5'),
///    const Text('6'),
///    const Text('7'),
///    const Text('8'),
///  ],
///  staggeredTiles: const <StaggeredTile>[
///    const StaggeredTile.count(2, 2),
///    const StaggeredTile.count(2, 1),
///    const StaggeredTile.count(2, 2),
///    const StaggeredTile.count(2, 1),
///    const StaggeredTile.count(2, 2),
///    const StaggeredTile.count(2, 1),
///    const StaggeredTile.count(2, 2),
///    const StaggeredTile.count(2, 1),
///  ],
///)
/// ```
///
/// See also:
///
///  * [SliverList], which places its children in a linear array.
///  * [SliverFixedExtentList], which places its children in a linear
///    array with a fixed extent in the main axis.
///  * [SliverPrototypeExtentList], which is similar to [SliverFixedExtentList]
///    except that it uses a prototype list item instead of a pixel value to define
///    the main axis extent of each item.
class SliverStaggeredGrid extends SliverVariableSizeBoxAdaptorWidget {
  /// Creates a sliver that places multiple box children in a two dimensional
  /// arrangement.
  const SliverStaggeredGrid({
    Key? key,
    required SliverChildDelegate delegate,
    required this.gridDelegate,
    bool addAutomaticKeepAlives = true,
    bool forceKeepChildWidget = false,
    this.keepBucketSize = 30
  }) : super(key: key, delegate: delegate,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            forceKeepChildWidget: forceKeepChildWidget);


  /// Creates a sliver that places multiple box children in a two dimensional
  /// arrangement with a fixed number of tiles in the cross axis.
  ///
  /// Uses a [SliverStaggeredGridDelegateWithFixedCrossAxisCount] as the [gridDelegate],
  /// and a [SliverVariableSizeChildListDelegate] as the [delegate].
  ///
  /// See also:
  ///
  ///  * [StaggeredGridView.count], the equivalent constructor for [StaggeredGridView] widgets.
  SliverStaggeredGrid.count({
    Key? key,
    required int crossAxisCount,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    List<Widget> children = const <Widget>[],
    List<StaggeredTile> staggeredTiles = const <StaggeredTile>[],
    bool addAutomaticKeepAlives = true,
    bool forceKeepChildWidget = false,
    this.keepBucketSize = 30
  })  : gridDelegate = SliverStaggeredGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileBuilder: (i) => staggeredTiles[i],
          staggeredTileCount: staggeredTiles.length,
        ),
        super(
          key: key,
          delegate: SliverChildListDelegate(
            children,
          ),
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          forceKeepChildWidget: forceKeepChildWidget
        );

  /// Creates a sliver that builds multiple box children in a two dimensional
  /// arrangement with a fixed number of tiles in the cross axis.
  ///
  /// This constructor is appropriate for grid views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// Uses a [SliverStaggeredGridDelegateWithFixedCrossAxisCount] as the
  /// [gridDelegate], and a [SliverVariableSizeChildBuilderDelegate] as the [delegate].
  ///
  /// See also:
  ///
  ///  * [StaggeredGridView.countBuilder], the equivalent constructor for
  ///  [StaggeredGridView] widgets.
  SliverStaggeredGrid.countBuilder({
    Key? key,
    required int crossAxisCount,
    required IndexedStaggeredTileBuilder staggeredTileBuilder,
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    bool addAutomaticKeepAlives = true,
    bool forceKeepChildWidget = false,
    this.keepBucketSize = 30
  })  : gridDelegate = SliverStaggeredGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileBuilder: staggeredTileBuilder,
          staggeredTileCount: itemCount,
        ),
        super(
          key: key,
          delegate: SliverChildBuilderDelegate(
            itemBuilder,
            childCount: itemCount,
          ),
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          forceKeepChildWidget: forceKeepChildWidget
        );

  /// Creates a sliver that places multiple box children in a two dimensional
  /// arrangement with tiles that each have a maximum cross-axis extent.
  ///
  /// Uses a [SliverStaggeredGridDelegateWithMaxCrossAxisExtent] as the [gridDelegate],
  /// and a [SliverVariableSizeChildListDelegate] as the [delegate].
  ///
  /// See also:
  ///
  ///  * [StaggeredGridView.extent], the equivalent constructor for [StaggeredGridView] widgets.
  SliverStaggeredGrid.extent({
    Key? key,
    required double maxCrossAxisExtent,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    List<Widget> children = const <Widget>[],
    List<StaggeredTile> staggeredTiles = const <StaggeredTile>[],
    bool addAutomaticKeepAlives = true,
    bool forceKeepChildWidget = false,
    this.keepBucketSize = 30
  })  : gridDelegate = SliverStaggeredGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileBuilder: (i) => staggeredTiles[i],
          staggeredTileCount: staggeredTiles.length,
        ),
        super(
          key: key,
          delegate: SliverChildListDelegate(
            children,
          ),
        addAutomaticKeepAlives: addAutomaticKeepAlives,
          forceKeepChildWidget: forceKeepChildWidget
        );

  /// Creates a sliver that builds multiple box children in a two dimensional
  /// arrangement with tiles that each have a maximum cross-axis extent.
  ///
  /// This constructor is appropriate for grid views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// Uses a [SliverStaggeredGridDelegateWithMaxCrossAxisExtent] as the
  /// [gridDelegate], and a [SliverVariableSizeChildBuilderDelegate] as the [delegate].
  ///
  /// See also:
  ///
  ///  * [StaggeredGridView.extentBuilder], the equivalent constructor for
  ///  [StaggeredGridView] widgets.
  SliverStaggeredGrid.extentBuilder({
    Key? key,
    required double maxCrossAxisExtent,
    required IndexedStaggeredTileBuilder staggeredTileBuilder,
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    bool addAutomaticKeepAlives = true,
    bool forceKeepChildWidget = false,
    this.keepBucketSize = 30
  })  : gridDelegate = SliverStaggeredGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileBuilder: staggeredTileBuilder,
          staggeredTileCount: itemCount,
        ),
        super(
          key: key,
          delegate: SliverChildBuilderDelegate(
            itemBuilder,
            childCount: itemCount,
          ),
        addAutomaticKeepAlives: addAutomaticKeepAlives,
          forceKeepChildWidget: forceKeepChildWidget
        );

  /// The delegate that controls the size and position of the children.
  final SliverStaggeredGridDelegate gridDelegate;

  /// The size of [_keepAliveBucket]
  /// * We will keep some invisible nodes in [_keepAliveBucket].
  ///
  /// * More details see [RenderSliverVariableSizeBoxAdaptor].
  ///
  /// * if [addAutomaticKeepAlives] is false, the [_keepAliveBucket] will never work.
  final int keepBucketSize;

  @override
  RenderSliverStaggeredGrid createRenderObject(BuildContext context) {
    final element = context as SliverVariableSizeBoxAdaptorElement;
    return RenderSliverStaggeredGrid(
        childManager: element, gridDelegate: gridDelegate, keepBucketSize: keepBucketSize);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderSliverStaggeredGrid renderObject) {
    renderObject.gridDelegate = gridDelegate;
  }
}
