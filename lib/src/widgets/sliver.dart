import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_staggered_grid_view/src/rendering/sliver_staggered_grid.dart';
import 'package:flutter_staggered_grid_view/src/rendering/sliver_variable_size_box_adaptor.dart';
import 'package:flutter_staggered_grid_view/src/widgets/automatic_keep_alive_variable_size_box.dart';
import 'package:flutter_staggered_grid_view/src/widgets/staggered_tile.dart';

/// A delegate that supplies variable size children for slivers.
///
/// Many slivers lazily construct their box children to avoid creating more
/// children than are visible through the [Viewport]. Rather than receiving
/// their children as an explicit [List], they receive their children using a
/// [SliverVariableSizeChildDelegate].
///
/// It's uncommon to subclass [SliverVariableSizeChildDelegate]. Instead, consider using one
/// of the existing subclasses that provide adaptors to builder callbacks or
/// explicit child lists.
///
/// See also:
///
///  * [SliverVariableSizeChildBuilderDelegate], which is a delegate that uses a builder
///    callback to construct the children.
///  * [SliverVariableSizeChildListDelegate], which is a delegate that has an explicit list
///    of children.
abstract class SliverVariableSizeChildDelegate extends SliverChildDelegate {
  const SliverVariableSizeChildDelegate();
}

/// A delegate that supplies variable size children for slivers using a builder callback.
///
/// Many slivers lazily construct their box children to avoid creating more
/// children than are visible through the [Viewport]. This delegate provides
/// children using an [IndexedWidgetBuilder] callback, so that the children do
/// not even have to be built until they are displayed.
///
/// The widgets returned from the builder callback are automatically wrapped in
/// [AutomaticKeepAliveVariableSizeBox] widgets if [addAutomaticKeepAlives] is true (the
/// default) and in [RepaintBoundary] widgets if [addRepaintBoundaries] is true
/// (also the default).
///
/// See also:
///
///  * [SliverVariableSizeChildListDelegate], which is a delegate that has an explicit list
///    of children.
class SliverVariableSizeChildBuilderDelegate extends SliverVariableSizeChildDelegate {
  /// Creates a delegate that supplies children for slivers using the given
  /// builder callback.
  ///
  /// The [builder], [addAutomaticKeepAlives], and [addRepaintBoundaries]
  /// arguments must not be null.
  const SliverVariableSizeChildBuilderDelegate(
    this.builder, {
    this.childCount,
    this.addAutomaticKeepAlives: true,
    this.addRepaintBoundaries: true,
  })  : assert(builder != null),
        assert(addAutomaticKeepAlives != null),
        assert(addRepaintBoundaries != null);

  /// Called to build children for the sliver.
  ///
  /// Will be called only for indices greater than or equal to zero and less
  /// than [childCount] (if [childCount] is non-null).
  ///
  /// Should return null if asked to build a widget with a greater index than
  /// exists.
  ///
  /// The delegate wraps the children returned by this builder in
  /// [RepaintBoundary] widgets.
  final IndexedWidgetBuilder builder;

  /// The total number of children this delegate can provide.
  ///
  /// If null, the number of children is determined by the least index for which
  /// [builder] returns null.
  final int childCount;

  /// Whether to wrap each child in an [AutomaticKeepAliveVariableSizeBox].
  ///
  /// Typically, children in lazy list are wrapped in [AutomaticKeepAliveVariableSizeBox]
  /// widgets so that children can use [KeepAliveNotification]s to preserve
  /// their state when they would otherwise be garbage collected off-screen.
  ///
  /// This feature (and [addRepaintBoundaries]) must be disabled if the children
  /// are going to manually maintain their [KeepAliveVariableSizeBox] state. It may also be
  /// more efficient to disable this feature if it is known ahead of time that
  /// none of the children will ever try to keep themselves alive.
  ///
  /// Defaults to true.
  final bool addAutomaticKeepAlives;

  /// Whether to wrap each child in a [RepaintBoundary].
  ///
  /// Typically, children in a scrolling container are wrapped in repaint
  /// boundaries so that they do not need to be repainted as the list scrolls.
  /// If the children are easy to repaint (e.g., solid color blocks or a short
  /// snippet of text), it might be more efficient to not add a repaint boundary
  /// and simply repaint the children during scrolling.
  ///
  /// Defaults to true.
  final bool addRepaintBoundaries;

  @override
  Widget build(BuildContext context, int index) {
    assert(builder != null);
    if (index < 0 || (childCount != null && index >= childCount)) return null;
    Widget child = builder(context, index);
    if (child == null) return null;
    if (addRepaintBoundaries) child = new RepaintBoundary.wrap(child, index);
    if (addAutomaticKeepAlives)
      child = new AutomaticKeepAliveVariableSizeBox(child: child);
    return child;
  }

  @override
  int get estimatedChildCount => childCount;

  @override
  bool shouldRebuild(covariant SliverVariableSizeChildBuilderDelegate oldDelegate) => true;
}

/// A delegate that supplies variable size children for slivers using an explicit list.
///
/// Many slivers lazily construct their box children to avoid creating more
/// children than are visible through the [Viewport]. This delegate provides
/// children using an explicit list, which is convenient but reduces the benefit
/// of building children lazily.
///
/// In general building all the widgets in advance is not efficient. It is
/// better to create a delegate that builds them on demand using
/// [SliverVariableSizeChildBuilderDelegate] or by subclassing [SliverVariableSizeChildDelegate]
/// directly.
///
/// This class is provided for the cases where either the list of children is
/// known well in advance (ideally the children are themselves compile-time
/// constants, for example), and therefore will not be built each time the
/// delegate itself is created, or the list is small, such that it's likely
/// always visible (and thus there is nothing to be gained by building it on
/// demand). For example, the body of a dialog box might fit both of these
/// conditions.
///
/// The widgets in the given [children] list are automatically wrapped in
/// [AutomaticKeepAliveVariableSizeBox] widgets if [addAutomaticKeepAlives] is true (the
/// default) and in [RepaintBoundary] widgets if [addRepaintBoundaries] is true
/// (also the default).
///
/// See also:
///
///  * [SliverVariableSizeChildBuilderDelegate], which is a delegate that uses a builder
///    callback to construct the children.
class SliverVariableSizeChildListDelegate extends SliverVariableSizeChildDelegate {
  /// Creates a delegate that supplies children for slivers using the given
  /// list.
  ///
  /// The [children], [addAutomaticKeepAlives], and [addRepaintBoundaries]
  /// arguments must not be null.
  const SliverVariableSizeChildListDelegate(
    this.children, {
    this.addAutomaticKeepAlives: true,
    this.addRepaintBoundaries: true,
  })  : assert(children != null),
        assert(addAutomaticKeepAlives != null),
        assert(addRepaintBoundaries != null);

  /// Whether to wrap each child in an [AutomaticKeepAliveVariableSizeBox].
  ///
  /// Typically, children in lazy list are wrapped in [AutomaticKeepAliveVariableSizeBox]
  /// widgets so that children can use [KeepAliveNotification]s to preserve
  /// their state when they would otherwise be garbage collected off-screen.
  ///
  /// This feature (and [addRepaintBoundaries]) must be disabled if the children
  /// are going to manually maintain their [KeepAliveVariableSizeBox] state. It may also be
  /// more efficient to disable this feature if it is known ahead of time that
  /// none of the children will ever try to keep themselves alive.
  ///
  /// Defaults to true.
  final bool addAutomaticKeepAlives;

  /// Whether to wrap each child in a [RepaintBoundary].
  ///
  /// Typically, children in a scrolling container are wrapped in repaint
  /// boundaries so that they do not need to be repainted as the list scrolls.
  /// If the children are easy to repaint (e.g., solid color blocks or a short
  /// snippet of text), it might be more efficient to not add a repaint boundary
  /// and simply repaint the children during scrolling.
  ///
  /// Defaults to true.
  final bool addRepaintBoundaries;

  /// The widgets to display.
  final List<Widget> children;

  @override
  Widget build(BuildContext context, int index) {
    assert(children != null);
    if (index < 0 || index >= children.length) return null;
    Widget child = children[index];
    assert(child != null);
    if (addRepaintBoundaries) child = new RepaintBoundary.wrap(child, index);
    if (addAutomaticKeepAlives)
      child = new AutomaticKeepAliveVariableSizeBox(child: child);
    return child;
  }

  @override
  int get estimatedChildCount => children.length;

  @override
  bool shouldRebuild(covariant SliverVariableSizeChildListDelegate oldDelegate) {
    return children != oldDelegate.children;
  }
}

/// A base class for sliver that have multiple variable size box children.
///
/// Helps subclasses build their children lazily using a [SliverVariableSizeChildDelegate].
abstract class SliverVariableSizeBoxAdaptorWidget extends RenderObjectWidget {
  /// Initializes fields for subclasses.
  const SliverVariableSizeBoxAdaptorWidget({
    Key key,
    @required this.delegate,
  })  : assert(delegate != null),
        super(key: key);

  /// The delegate that provides the children for this widget.
  ///
  /// The children are constructed lazily using this widget to avoid creating
  /// more children than are visible through the [Viewport].
  ///
  /// See also:
  ///
  ///  * [SliverVariableSizeChildBuilderDelegate] and [SliverVariableSizeChildListDelegate], which are
  ///    commonly used subclasses of [SliverVariableSizeChildDelegate] that use a builder
  ///    callback and an explicit child list, respectively.
  final SliverVariableSizeChildDelegate delegate;

  @override
  SliverVariableSizeBoxAdaptorElement createElement() =>
      new SliverVariableSizeBoxAdaptorElement(this);

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
  /// [SliverVariableSizeChildDelegate.estimateMaxScrollOffset] method.
  double estimateMaxScrollOffset(
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
        new DiagnosticsProperty<SliverVariableSizeChildDelegate>('delegate', delegate));
  }
}

/// An element that lazily builds children for a [SliverVariableSizeBoxAdaptorWidget].
///
/// Implements [RenderSliverVariableSizeBoxChildManager], which lets this element manage
/// the children of subclasses of [RenderSliverVariableSizeBoxAdaptor].
class SliverVariableSizeBoxAdaptorElement extends RenderObjectElement
    implements RenderSliverVariableSizeBoxChildManager {
  /// Creates an element that lazily builds children for the given widget.
  SliverVariableSizeBoxAdaptorElement(SliverVariableSizeBoxAdaptorWidget widget)
      : super(widget);

  @override
  SliverVariableSizeBoxAdaptorWidget get widget => super.widget;

  @override
  RenderSliverVariableSizeBoxAdaptor get renderObject => super.renderObject;

  @override
  void update(covariant SliverVariableSizeBoxAdaptorWidget newWidget) {
    final SliverVariableSizeBoxAdaptorWidget oldWidget = widget;
    super.update(newWidget);
    final SliverVariableSizeChildDelegate newDelegate = newWidget.delegate;
    final SliverVariableSizeChildDelegate oldDelegate = oldWidget.delegate;
    if (newDelegate != oldDelegate &&
        (newDelegate.runtimeType != oldDelegate.runtimeType ||
            newDelegate.shouldRebuild(oldDelegate))) performRebuild();
  }

  // We inflate widgets at two different times:
  //  1. When we ourselves are told to rebuild (see performRebuild).
  //  2. When our render object needs a new child (see createChild).
  // In both cases, we cache the results of calling into our delegate to get the widget,
  // so that if we do case 2 later, we don't call the builder again.
  // Any time we do case 1, though, we reset the cache.

  final Map<int, Widget> _childWidgets = new HashMap<int, Widget>();
  final SplayTreeMap<int, Element> _childElements =
      new SplayTreeMap<int, Element>();

  @override
  void performRebuild() {
    _childWidgets.clear(); // Reset the cache, as described above.
    super.performRebuild();
    assert(_currentlyUpdatingChildIndex == null);
    try {
      int firstIndex = _childElements.firstKey();
      int lastIndex = _childElements.lastKey();
      if (_childElements.isEmpty) {
        firstIndex = 0;
        lastIndex = 0;
      } else if (_didUnderflow) {
        lastIndex += 1;
      }
      for (int index = firstIndex; index <= lastIndex; ++index) {
        _currentlyUpdatingChildIndex = index;
        final Element newChild =
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

  Widget _build(int index) {
    return _childWidgets.putIfAbsent(
        index, () => widget.delegate.build(this, index));
  }

  @override
  void createChild(int index) {
    assert(_currentlyUpdatingChildIndex == null);
    owner.buildScope(this, () {
      Element newChild;
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
  Element updateChild(Element child, Widget newWidget, dynamic newSlot) {
    final SliverVariableSizeBoxAdaptorParentData oldParentData =
        child?.renderObject?.parentData;
    final Element newChild = super.updateChild(child, newWidget, newSlot);
    final SliverVariableSizeBoxAdaptorParentData newParentData =
        newChild?.renderObject?.parentData;

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
    assert(child != null);
    assert(child.slot != null);
    assert(_childElements.containsKey(child.slot));
    _childElements.remove(child.slot);
  }

  @override
  void removeChild(RenderBox child) {
    final int index = renderObject.indexOf(child);
    assert(_currentlyUpdatingChildIndex == null);
    assert(index >= 0);
    owner.buildScope(this, () {
      assert(_childElements.containsKey(index));
      try {
        _currentlyUpdatingChildIndex = index;
        final Element result = updateChild(_childElements[index], null, index);
        assert(result == null);
      } finally {
        _currentlyUpdatingChildIndex = null;
      }
      _childElements.remove(index);
      assert(!_childElements.containsKey(index));
    });
  }

  double _extrapolateMaxScrollOffset(
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  ) {
    final int childCount = this.childCount;
    if (childCount == null) return double.infinity;
    if (lastIndex == childCount - 1) return trailingScrollOffset;
    final int reifiedCount = lastIndex - firstIndex + 1;
    final double averageExtent =
        (trailingScrollOffset - leadingScrollOffset) / reifiedCount;
    final int remainingCount = childCount - lastIndex - 1;
    return trailingScrollOffset + averageExtent * remainingCount;
  }

  @override
  double estimateMaxScrollOffset(
    SliverConstraints constraints, {
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  }) {
    return widget.estimateMaxScrollOffset(
          constraints,
          firstIndex,
          lastIndex,
          leadingScrollOffset,
          trailingScrollOffset,
        ) ??
        _extrapolateMaxScrollOffset(
          firstIndex,
          lastIndex,
          leadingScrollOffset,
          trailingScrollOffset,
        );
  }

  @override
  int get childCount => widget.delegate.estimatedChildCount;

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

  int _currentlyUpdatingChildIndex;

  @override
  bool debugAssertChildListLocked() {
    assert(_currentlyUpdatingChildIndex == null);
    return true;
  }

  @override
  void didAdoptChild(RenderBox child) {
    assert(_currentlyUpdatingChildIndex != null);
    final SliverVariableSizeBoxAdaptorParentData childParentData =
        child.parentData;
    childParentData.index = _currentlyUpdatingChildIndex;
  }

  bool _didUnderflow = false;

  @override
  void setDidUnderflow(bool value) {
    _didUnderflow = value;
  }

  @override
  void insertChildRenderObject(covariant RenderObject child, int slot) {
    assert(slot != null);
    assert(_currentlyUpdatingChildIndex == slot);
    assert(renderObject.debugValidateChild(child));
    renderObject[_currentlyUpdatingChildIndex] = child;
    assert(() {
      final SliverVariableSizeBoxAdaptorParentData childParentData =
          child.parentData;
      assert(slot == childParentData.index);
      return true;
    }());
  }

  @override
  void moveChildRenderObject(covariant RenderObject child, int slot) {
    // TODO(ianh): At some point we should be better about noticing when a
    // particular LocalKey changes slot, and handle moving the nodes around.
    assert(false);
  }

  @override
  void removeChildRenderObject(covariant RenderObject child) {
    assert(_currentlyUpdatingChildIndex != null);
    renderObject.remove(_currentlyUpdatingChildIndex);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    // The toList() is to make a copy so that the underlying list can be modified by
    // the visitor:
    assert(!_childElements.values.any((Element child) => child == null));
    _childElements.values.toList().forEach(visitor);
  }

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    _childElements.values.where((Element child) {
      final SliverMultiBoxAdaptorParentData parentData =
          child.renderObject.parentData;
      double itemExtent;
      switch (renderObject.constraints.axis) {
        case Axis.horizontal:
          itemExtent = child.renderObject.paintBounds.width;
          break;
        case Axis.vertical:
          itemExtent = child.renderObject.paintBounds.height;
          break;
      }

      return parentData.layoutOffset <
              renderObject.constraints.scrollOffset +
                  renderObject.constraints.remainingPaintExtent &&
          parentData.layoutOffset + itemExtent >
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
///new SliverStaggeredGrid.count(
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
    Key key,
    @required SliverVariableSizeChildDelegate delegate,
    @required this.gridDelegate,
  }) : super(key: key, delegate: delegate);

  /// Creates a sliver that places multiple box children in a two dimensional
  /// arrangement with a fixed number of tiles in the cross axis.
  ///
  /// Uses a [SliverStaggeredGridDelegateWithFixedCrossAxisCount] as the [gridDelegate],
  /// and a [SliverVariableSizeChildListDelegate] as the [delegate].
  ///
  /// See also:
  ///
  ///  * [new StaggeredGridView.count], the equivalent constructor for [StaggeredGridView] widgets.
  SliverStaggeredGrid.count({
    Key key,
    @required int crossAxisCount,
    double mainAxisSpacing: 0.0,
    double crossAxisSpacing: 0.0,
    List<Widget> children: const <Widget>[],
    List<StaggeredTile> staggeredTiles: const <StaggeredTile>[],
  })  : gridDelegate = new SliverStaggeredGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileBuilder: (i) => staggeredTiles[i],
          staggeredTileCount: staggeredTiles?.length,
        ),
        super(
            key: key,
            delegate: new SliverVariableSizeChildListDelegate(children,
                addAutomaticKeepAlives: true));

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
  ///  * [new StaggeredGridView.countBuilder], the equivalent constructor for
  ///  [StaggeredGridView] widgets.
  SliverStaggeredGrid.countBuilder({
    Key key,
    @required int crossAxisCount,
    @required IndexedStaggeredTileBuilder staggeredTileBuilder,
    @required IndexedWidgetBuilder itemBuilder,
    @required int itemCount,
    double mainAxisSpacing: 0.0,
    double crossAxisSpacing: 0.0,
  })  : gridDelegate = new SliverStaggeredGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileBuilder: staggeredTileBuilder,
          staggeredTileCount: itemCount,
        ),
        super(
          key: key,
          delegate: SliverVariableSizeChildBuilderDelegate(
            itemBuilder,
            childCount: itemCount,
            addAutomaticKeepAlives: true,
            addRepaintBoundaries: true,
          ),
        );

  /// Creates a sliver that places multiple box children in a two dimensional
  /// arrangement with tiles that each have a maximum cross-axis extent.
  ///
  /// Uses a [SliverStaggeredGridDelegateWithMaxCrossAxisExtent] as the [gridDelegate],
  /// and a [SliverVariableSizeChildListDelegate] as the [delegate].
  ///
  /// See also:
  ///
  ///  * [new StaggeredGridView.extent], the equivalent constructor for [StaggeredGridView] widgets.
  SliverStaggeredGrid.extent({
    Key key,
    @required double maxCrossAxisExtent,
    double mainAxisSpacing: 0.0,
    double crossAxisSpacing: 0.0,
    List<Widget> children: const <Widget>[],
    List<StaggeredTile> staggeredTiles: const <StaggeredTile>[],
  })  : gridDelegate = new SliverStaggeredGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileBuilder: (i) => staggeredTiles[i],
          staggeredTileCount: staggeredTiles?.length,
        ),
        super(
            key: key,
            delegate: new SliverVariableSizeChildListDelegate(children,
                addAutomaticKeepAlives: true));

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
  ///  * [new StaggeredGridView.extentBuilder], the equivalent constructor for
  ///  [StaggeredGridView] widgets.
  SliverStaggeredGrid.extentBuilder({
    Key key,
    @required double maxCrossAxisExtent,
    @required IndexedStaggeredTileBuilder staggeredTileBuilder,
    @required IndexedWidgetBuilder itemBuilder,
    @required int itemCount,
    double mainAxisSpacing: 0.0,
    double crossAxisSpacing: 0.0,
  })  : gridDelegate = new SliverStaggeredGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileBuilder: staggeredTileBuilder,
          staggeredTileCount: itemCount,
        ),
        super(
          key: key,
          delegate: SliverVariableSizeChildBuilderDelegate(
            itemBuilder,
            childCount: itemCount,
            addAutomaticKeepAlives: true,
            addRepaintBoundaries: true,
          ),
        );

  /// The delegate that controls the size and position of the children.
  final SliverStaggeredGridDelegate gridDelegate;

  @override
  RenderSliverStaggeredGrid createRenderObject(BuildContext context) {
    final SliverVariableSizeBoxAdaptorElement element = context;
    return new RenderSliverStaggeredGrid(
        childManager: element, gridDelegate: gridDelegate);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderSliverStaggeredGrid renderObject) {
    renderObject.gridDelegate = gridDelegate;
  }

  @override
  double estimateMaxScrollOffset(
    SliverConstraints constraints,
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  ) {
    return super.estimateMaxScrollOffset(
      constraints,
      firstIndex,
      lastIndex,
      leadingScrollOffset,
      trailingScrollOffset,
    );
  }
}

/// Mark a child as needing to stay alive even when it's in a lazy list that
/// would otherwise remove it.
///
/// This widget is for use in [SliverVariableSizeBoxAdaptorWidget]s, such as
/// [SliverStaggeredGrid].
class KeepAliveVariableSizeBox
    extends ParentDataWidget<SliverVariableSizeBoxAdaptorWidget> {
  /// Marks a child as needing to remain alive.
  ///
  /// The [child] and [keepAlive] arguments must not be null.
  const KeepAliveVariableSizeBox({
    Key key,
    @required this.keepAlive,
    @required Widget child,
  })  : assert(child != null),
        assert(keepAlive != null),
        super(key: key, child: child);

  /// Whether to keep the child alive.
  ///
  /// If this is false, it is as if this widget was omitted.
  final bool keepAlive;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is SliverVariableSizeBoxAdaptorParentData);
    final SliverVariableSizeBoxAdaptorParentData parentData =
        renderObject.parentData;
    if (parentData.keepAlive != keepAlive) {
      parentData.keepAlive = keepAlive;
      final AbstractNode targetParent = renderObject.parent;
      if (targetParent is RenderObject && !keepAlive)
        targetParent
            .markNeedsLayout(); // No need to redo layout if it became true.
    }
  }

  // We only return true if [keepAlive] is true, because turning _off_ keep
  // alive requires a layout to do the garbage collection (but turning it on
  // requires nothing, since by definition the widget is already alive and won't
  // go away _unless_ we do a layout).
  @override
  bool debugCanApplyOutOfTurn() => keepAlive;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(new DiagnosticsProperty<bool>('keepAlive', keepAlive));
  }
}
