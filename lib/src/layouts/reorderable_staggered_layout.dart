import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/src/widgets/staggered_grid.dart';
import 'package:flutter_staggered_grid_view/src/widgets/staggered_grid_tile.dart';

/// Callback for when reordering is complete.
typedef ReorderCallback = void Function(int oldIndex, int newIndex);

/// Callback when feedback is being built.
typedef IndexedFeedBackWidgetBuilder = Widget Function(
  BuildContext context,
  int index,
  Widget child,
);

/// A list whose items the user can interactively reorder by dragging.
///
/// This class is appropriate for views with a small number of
/// children because constructing the [List] requires doing work for every
/// child that could possibly be displayed in the list view instead of just
/// those children that are actually visible.
///
/// All [children] must have a key.
///
class ReorderableStaggeredLayout extends StatefulWidget {
  /// Creates a reorderable list.
  ReorderableStaggeredLayout({
    Key? key,
    this.header,
    required this.children,
    required this.onReorder,
    this.scrollController,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.crossAxisCount = 3,
    this.reverse = false,
    this.longPressToDrag = true,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.feedBackWidgetBuilder,
  }) : super(key: key);

  /// A non-reorderable header widget to show before the list.
  ///
  /// If null, no header will appear before the list.
  final Widget? header;

  /// The widgets to display.
  final List<StaggeredGridTile> children;

  /// The [Axis] along which the list scrolls.
  ///
  /// List [children] can only drag along this [Axis].
  final Axis scrollDirection;

  /// Creates a [ScrollPosition] to manage and determine which portion
  /// of the content is visible in the scroll view.
  ///
  /// This can be used in many ways, such as setting an initial scroll offset,
  /// (via [ScrollController.initialScrollOffset]), reading the current scroll position
  /// (via [ScrollController.offset]), or changing it (via [ScrollController.jumpTo] or
  /// [ScrollController.animateTo]).
  final ScrollController? scrollController;

  /// The amount of space by which to inset the [children].
  final EdgeInsets? padding;

  /// Whether the scroll view scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the scroll view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the scroll view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// Called when a list child is dropped into a new position to shuffle the
  /// underlying list.
  ///
  /// This [ReorderableStaggeredLayout] calls [onReorder] after a list child is dropped
  /// into a new position.
  final ReorderCallback onReorder;

  /// Used when we are building a GridView
  final int crossAxisCount;

  /// Used when we are building a GridView
  final bool longPressToDrag;

  /// Used when we are building a GridView
  final double mainAxisSpacing;

  /// Used when we are building a GridView
  final double crossAxisSpacing;

  /// Feedback widget
  final IndexedFeedBackWidgetBuilder? feedBackWidgetBuilder;

  @override
  _ReorderableStaggeredLayoutState createState() => _ReorderableStaggeredLayoutState();
}

/// This top-level state manages an Overlay that contains the list and
/// also any Draggables it creates.
///
/// _ReorderableListContent manages the list itself and reorder operations.
///
/// The Overlay doesn't properly keep state by building new overlay entries,
/// and so we cache a single OverlayEntry for use as the list layer.
/// That overlay entry then builds a _ReorderableListContent which may
/// insert Draggables into the Overlay above itself.
class _ReorderableStaggeredLayoutState extends State<ReorderableStaggeredLayout> {
  @override
  Widget build(BuildContext context) {
    return Overlay(
      key: GlobalKey(debugLabel: '$ReorderableStaggeredLayout overlay'),
      initialEntries: <OverlayEntry>[
        OverlayEntry(
          opaque: true,
          builder: (BuildContext context) {
            return _ReorderableListContent(
              header: widget.header,
              children: widget.children,
              scrollController: widget.scrollController,
              scrollDirection: widget.scrollDirection,
              onReorder: widget.onReorder,
              padding: widget.padding,
              reverse: widget.reverse,
              crossAxisCount: widget.crossAxisCount,
              longPressToDrag: widget.longPressToDrag,
              mainAxisSpacing: widget.mainAxisSpacing,
              crossAxisSpacing: widget.crossAxisSpacing,
              feedBackWidgetBuilder: widget.feedBackWidgetBuilder,
            );
          },
        )
      ],
    );
  }
}

/// This widget is responsible for the inside of the Overlay in the
/// ReorderableItemsView.
class _ReorderableListContent extends StatefulWidget {
  const _ReorderableListContent({
    required this.header,
    required this.children,
    required this.scrollController,
    required this.scrollDirection,
    required this.padding,
    required this.onReorder,
    required this.reverse,
    required this.crossAxisCount,
    required this.longPressToDrag,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.feedBackWidgetBuilder,
  });

  final Widget? header;
  final List<StaggeredGridTile> children;
  final ScrollController? scrollController;
  final Axis scrollDirection;
  final EdgeInsets? padding;
  final ReorderCallback onReorder;
  final bool reverse;
  final int crossAxisCount;
  final bool longPressToDrag;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final IndexedFeedBackWidgetBuilder? feedBackWidgetBuilder;

  @override
  _ReorderableListContentState createState() => _ReorderableListContentState();
}

class _ReorderableListContentState extends State<_ReorderableListContent>
    with TickerProviderStateMixin<_ReorderableListContent> {
  /// The extent along the widget.scrollDirection axis to allow a child to
  /// drop into when the user reorders list children.
  ///
  /// This value is used when the extents haven't yet been calculated from
  /// the currently dragging widget, such as when it first builds.
  static const double _defaultDropAreaExtent = 100.0;

  /// The additional margin to place around a computed drop area.
  static const double _dropAreaMargin = 8.0;

  /// How long an animation to reorder an element in the list takes.
  static const Duration _reorderAnimationDuration = Duration(milliseconds: 200);

  /// How long an animation to scroll to an off-screen element in the
  /// list takes.
  static const Duration _scrollAnimationDuration = Duration(milliseconds: 200);

  /// Controls scrolls and measures scroll progress.
  ScrollController? _scrollController;

  /// This controls the entrance of the dragging widget into a new place.
  late AnimationController _entranceController;

  /// This controls the 'ghost' of the dragging widget, which is left behind
  /// where the widget used to be.
  late AnimationController _ghostController;

  /// The member of children currently being dragged.
  ///
  /// Null if no drag is underway.
  Widget? _dragging;

  /// The last computed size of the feedback widget being dragged.
  Size? _draggingFeedbackSize;

  /// The location that the dragging widget occupied before it started to drag.
  int _dragStartIndex = 0;

  /// The index that the dragging widget most recently left.
  /// This is used to show an animation of the widget's position.
  int _ghostIndex = 0;

  /// The index that the dragging widget currently occupies.
  int _currentIndex = 0;

  /// The widget to move the dragging widget too after the current index.
  int _nextIndex = 0;

  /// Whether or not we are currently scrolling this view to show a widget.
  bool _scrolling = false;

  double get _dropAreaExtent {
    if (_draggingFeedbackSize == null) {
      return _defaultDropAreaExtent;
    }
    double dropAreaWithoutMargin;
    switch (widget.scrollDirection) {
      case Axis.horizontal:
        dropAreaWithoutMargin = _draggingFeedbackSize!.width;
        break;
      case Axis.vertical:
      default:
        dropAreaWithoutMargin = _draggingFeedbackSize!.height;
        break;
    }
    return dropAreaWithoutMargin + _dropAreaMargin;
  }

  @override
  void initState() {
    super.initState();
    _entranceController =
        AnimationController(vsync: this, duration: _reorderAnimationDuration);
    _ghostController =
        AnimationController(vsync: this, duration: _reorderAnimationDuration);
    _entranceController.addStatusListener(_onEntranceStatusChanged);
  }

  @override
  void didChangeDependencies() {
    _scrollController = widget.scrollController ??
        PrimaryScrollController.of(context) ??
        ScrollController();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _ghostController.dispose();
    super.dispose();
  }

  /// Animates the droppable space from _currentIndex to _nextIndex.
  void _requestAnimationToNextIndex() {
    if (_entranceController.isCompleted) {
      _ghostIndex = _currentIndex;
      if (_nextIndex == _currentIndex) {
        return;
      }
      _currentIndex = _nextIndex;
      _ghostController.reverse(from: 1.0);
      _entranceController.forward(from: 0.0);
    }
  }

  /// Requests animation to the latest next index if it changes during an animation.
  void _onEntranceStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(_requestAnimationToNextIndex);
    }
  }

  /// Scrolls to a target context if that context is not on the screen.
  void _scrollTo(BuildContext context) {
    if (_scrolling) return;
    final RenderObject contextObject = context.findRenderObject()!;
    final RenderAbstractViewport viewport =
        RenderAbstractViewport.of(contextObject)!;
    // If and only if the current scroll offset falls in-between the offsets
    // necessary to reveal the selected context at the top or bottom of the
    // screen, then it is already on-screen.
    final double margin = _dropAreaExtent;
    final double scrollOffset = _scrollController!.offset;
    final double topOffset = max(
      _scrollController!.position.minScrollExtent,
      viewport.getOffsetToReveal(contextObject, 0.0).offset - margin,
    );
    final double bottomOffset = min(
      _scrollController!.position.maxScrollExtent,
      viewport.getOffsetToReveal(contextObject, 1.0).offset + margin,
    );
    final bool onScreen =
        scrollOffset <= topOffset && scrollOffset >= bottomOffset;

    // If the context is off screen, then we request a scroll to make it visible.
    if (!onScreen) {
      _scrolling = true;
      _scrollController!.position
          .animateTo(
        scrollOffset < bottomOffset ? bottomOffset : topOffset,
        duration: _scrollAnimationDuration,
        curve: Curves.easeInOut,
      )
          .then((void value) {
        setState(() {
          _scrolling = false;
        });
      });
    }
  }

  /// Wraps children in Row or Column, so that the children flow in
  /// the widget's scrollDirection.
  Widget _buildContainerForScrollDirection({required List<Widget> children}) {
    if (widget.header != null) {
      if (children[1] is StaggeredGridTile)
        return StaggeredGrid.count(
          crossAxisCount: widget.crossAxisCount,
          children: children,
          mainAxisSpacing: widget.mainAxisSpacing,
          crossAxisSpacing: widget.crossAxisSpacing,
        );
    } else {
      if (children.first is StaggeredGridTile)
        return StaggeredGrid.count(
          crossAxisCount: widget.crossAxisCount,
          children: children,
          mainAxisSpacing: widget.mainAxisSpacing,
          crossAxisSpacing: widget.crossAxisSpacing,
        );
    }

    switch (widget.scrollDirection) {
      case Axis.horizontal:
        return Row(children: children);
      case Axis.vertical:
      default:
        return Column(children: children);
    }
  }

  /// Wraps one of the widget's children in a DragTarget and Draggable.
  /// Handles up the logic for dragging and reordering items in the list.
  StaggeredGridTile _wrap(
      StaggeredGridTile toWrap,
    int index,
    BoxConstraints constraints,
  ) {
    if (toWrap.disableDrag) {
      return toWrap;
    }
    final GlobalObjectKey keyIndexGlobalKey = GlobalObjectKey(toWrap);
    // We pass the toWrapWithGlobalKey into the Draggable so that when a list
    // item gets dragged, the accessibility framework can preserve the selected
    // state of the dragging item.

    // Starts dragging toWrap.
    void onDragStarted() {
      setState(() {
        _dragging = toWrap;
        _dragStartIndex = index;
        _ghostIndex = index;
        _currentIndex = index;
        _entranceController.value = 1.0;
        _draggingFeedbackSize = keyIndexGlobalKey.currentContext!.size;
      });
    }

    /// Places the value from startIndex one space before the element at endIndex.
    void reorder(int startIndex, int endIndex) {
      setState(() {
        if (startIndex != endIndex && endIndex < widget.children.length)
          widget.onReorder(startIndex, endIndex);
        _ghostController.reverse(from: 0.1);
        _entranceController.reverse(from: 0.1);
        _dragging = null;
      });
    }

    /// Drops toWrap into the last position it was hovering over.
    void onDragEnded() {
      reorder(_dragStartIndex, _currentIndex);
    }

    Widget wrapWithSemantics() {
      // First, determine which semantics actions apply.
      final Map<CustomSemanticsAction, VoidCallback> semanticsActions =
          <CustomSemanticsAction, VoidCallback>{};

      // Create the appropriate semantics actions.
      void moveToStart() => reorder(index, 0);
      void moveToEnd() => reorder(index, widget.children.length);
      void moveBefore() => reorder(index, index - 1);
      // To move after, we go to index+2 because we are moving it to the space
      // before index+2, which is after the space at index+1.
      void moveAfter() => reorder(index, index + 2);

      final MaterialLocalizations localizations =
          MaterialLocalizations.of(context);

      // If the item can move to before its current position in the list.
      if (index > 0) {
        semanticsActions[CustomSemanticsAction(
          label: localizations.reorderItemToStart,
        )] = moveToStart;
        String reorderItemBefore = localizations.reorderItemUp;
        if (widget.scrollDirection == Axis.horizontal) {
          reorderItemBefore = Directionality.of(context) == TextDirection.ltr
              ? localizations.reorderItemLeft
              : localizations.reorderItemRight;
        }
        semanticsActions[CustomSemanticsAction(label: reorderItemBefore)] =
            moveBefore;
      }

      // If the item can move to after its current position in the list.
      if (index < widget.children.length - 1) {
        String reorderItemAfter = localizations.reorderItemDown;
        if (widget.scrollDirection == Axis.horizontal) {
          reorderItemAfter = Directionality.of(context) == TextDirection.ltr
              ? localizations.reorderItemRight
              : localizations.reorderItemLeft;
        }
        semanticsActions[CustomSemanticsAction(label: reorderItemAfter)] =
            moveAfter;
        semanticsActions[
                CustomSemanticsAction(label: localizations.reorderItemToEnd)] =
            moveToEnd;
      }

      // We pass toWrap with a GlobalKey into the Draggable so that when a list
      // item gets dragged, the accessibility framework can preserve the selected
      // state of the dragging item.
      //
      // We also apply the relevant custom accessibility actions for moving the item
      // up, down, to the start, and to the end of the list.
      return KeyedSubtree(
        key: keyIndexGlobalKey,
        child: MergeSemantics(
          child: Semantics(
            customSemanticsActions: semanticsActions,
            child: (toWrap is StaggeredGridTile) ? toWrap.child : toWrap,
          ),
        ),
      );
    }

    Widget buildDragTarget(
      BuildContext context,
      List<Widget?> acceptedCandidates,
      List<dynamic> rejectedCandidates,
    ) {
      final Widget toWrapWithSemantics = wrapWithSemantics();

      double mainAxisExtent = 0.0;
      double crossAxisExtent = 0.0;

      BoxConstraints newConstraints = constraints;

      if (widget.children.first is StaggeredGridTile &&
          _dragging == null &&
          index < widget.children.length) {
        final StaggeredGridTile tile =
            widget.children[index] as StaggeredGridTile;

        final double usableCrossAxisExtent = constraints.biggest.width;
        final double cellExtent = usableCrossAxisExtent / widget.crossAxisCount;
        final num mainAxisCellCount = tile.mainAxisCellCount ?? 1.0;

        mainAxisExtent = tile.mainAxisExtent ??
            (mainAxisCellCount * cellExtent) + (mainAxisCellCount - 1);

        crossAxisExtent = cellExtent * tile.crossAxisCellCount;

        newConstraints = constraints.copyWith(
          minWidth: crossAxisExtent,
          maxWidth: crossAxisExtent,
          minHeight: mainAxisExtent,
          maxHeight: mainAxisExtent,
        );
      } else {
        newConstraints = constraints.copyWith(
          minWidth: 0.0,
          maxWidth: constraints.maxWidth,
          minHeight: 0.0,
          maxHeight: constraints.maxHeight,
        );
      }

      // We build the draggable inside of a layout builder so that we can
      // constrain the size of the feedback dragging widget.
      Widget child = widget.longPressToDrag
          ? LongPressDraggable<Widget>(
              maxSimultaneousDrags: 1,
              axis: null,
              data: toWrap,
              ignoringFeedbackSemantics: false,
              feedback: widget.feedBackWidgetBuilder != null
                  ? widget.feedBackWidgetBuilder!(
                      context,
                      index,
                      toWrapWithSemantics,
                    )
                  : Container(
                      alignment: Alignment.topLeft,
                      // These constraints will limit the cross axis of the drawn widget.
                      constraints: newConstraints,
                      color: Colors.transparent,
                      child: Material(
                        elevation: 6.0,
                        child: toWrapWithSemantics,
                      ),
                    ),
              child:
                  _dragging == toWrap ? const SizedBox() : toWrapWithSemantics,
              childWhenDragging: const SizedBox(),
              onDragStarted: onDragStarted,
              dragAnchorStrategy: childDragAnchorStrategy,
              // When the drag ends inside a DragTarget widget, the drag
              // succeeds, and we reorder the widget into position appropriately.
              onDragCompleted: onDragEnded,
              // When the drag does not end inside a DragTarget widget, the
              // drag fails, but we still reorder the widget to the last position it
              // had been dragged to.
              onDraggableCanceled: (Velocity velocity, Offset offset) {
                onDragEnded();
              },
            )
          : Draggable<Widget>(
              maxSimultaneousDrags: 1,
              axis: null,
              data: toWrap,
              ignoringFeedbackSemantics: false,
              feedback: widget.feedBackWidgetBuilder != null
                  ? widget.feedBackWidgetBuilder!(
                      context,
                      index,
                      toWrapWithSemantics,
                    )
                  : Container(
                      alignment: Alignment.topLeft,
                      // These constraints will limit the cross axis of the drawn widget.
                      constraints: newConstraints,
                      child: Material(
                        elevation: 6.0,
                        color: Colors.transparent,
                        child: toWrapWithSemantics,
                      ),
                    ),
              child:
                  _dragging == toWrap ? const SizedBox() : toWrapWithSemantics,
              childWhenDragging: const SizedBox(),
              onDragStarted: onDragStarted,
              dragAnchorStrategy: childDragAnchorStrategy,
              // When the drag ends inside a DragTarget widget, the drag
              // succeeds, and we reorder the widget into position appropriately.
              onDragCompleted: onDragEnded,
              // When the drag does not end inside a DragTarget widget, the
              // drag fails, but we still reorder the widget to the last position it
              // had been dragged to.
              onDraggableCanceled: (Velocity velocity, Offset offset) {
                onDragEnded();
              },
            );

      // The target for dropping at the end of the list doesn't need to be
      // draggable.
      if (index >= widget.children.length) {
        child = toWrap;
      }

      // Determine the size of the drop area to show under the dragging widget.
      Widget spacing;
      switch (widget.scrollDirection) {
        case Axis.horizontal:
          spacing = SizedBox(width: _dropAreaExtent);
          break;
        case Axis.vertical:
        default:
          spacing = SizedBox(height: _dropAreaExtent);
          break;
      }

      // We open up a space under where the dragging widget currently is to
      // show it can be dropped.
      if (_currentIndex == index &&
          _dragging != null &&
          widget.children.first is! StaggeredGridTile) {
        return _buildContainerForScrollDirection(
          children: <Widget>[
            SizeTransition(
              sizeFactor: _entranceController,
              axis: widget.scrollDirection,
              child: spacing,
            ),
            child,
          ],
        );
      }
      // We close up the space under where the dragging widget previously was
      // with the ghostController animation.
      if (_ghostIndex == index &&
          _dragging != null &&
          widget.children.first is! StaggeredGridTile) {
        return _buildContainerForScrollDirection(
          children: <Widget>[
            SizeTransition(
              sizeFactor: _ghostController,
              axis: widget.scrollDirection,
              child: spacing,
            ),
            child,
          ],
        );
      }

      if (_ghostIndex == index &&
          _dragging != null &&
          widget.children.first is StaggeredGridTile) {
        return Opacity(
          opacity: .5,
          child: child,
        );
      }
      return child;
    }

    Widget target = Builder(
      builder: (BuildContext context) {
        return DragTarget<Widget>(
          builder: buildDragTarget,
          onWillAccept: (Widget? toAccept) {
            setState(() {
              _nextIndex = index;
              _requestAnimationToNextIndex();
            });
            _scrollTo(context);
            // If the target is not the original starting point, then we will accept the drop.
            return _dragging == toAccept && toAccept != toWrap;
          },
          onAccept: (Widget accepted) {},
          onLeave: (Object? leaving) {},
        );
      },
    );

    // We wrap the drag target in a Builder so that we can scroll to its specific context.

    if (toWrap is StaggeredGridTile && toWrap.mainAxisCellCount != null) {
      return StaggeredGridTile.count(
        crossAxisCellCount: toWrap.crossAxisCellCount,
        mainAxisCellCount: toWrap.mainAxisCellCount!,
        child: target,
      );
    } else if (toWrap is StaggeredGridTile && toWrap.mainAxisExtent != null) {
      return StaggeredGridTile.extent(
        crossAxisCellCount: toWrap.crossAxisCellCount,
        mainAxisExtent: toWrap.mainAxisExtent!,
        child: target,
      );
    } else {
      return StaggeredGridTile.fit(
        crossAxisCellCount:
            (toWrap is StaggeredGridTile) ? toWrap.crossAxisCellCount : 1,
        child: target,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    // We use the layout builder to constrain the cross-axis size of dragging child widgets.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const Key endWidgetKey = Key('DraggableList - End Widget');
        Widget finalDropArea;
        switch (widget.scrollDirection) {
          case Axis.horizontal:
            finalDropArea = SizedBox(
              key: endWidgetKey,
              width: _defaultDropAreaExtent,
              height: constraints.maxHeight,
            );
            break;
          case Axis.vertical:
          default:
            finalDropArea = SizedBox(
              key: endWidgetKey,
              height: _defaultDropAreaExtent,
              width: constraints.maxWidth,
            );
            break;
        }
        return SingleChildScrollView(
          scrollDirection: widget.scrollDirection,
          padding: widget.padding,
          controller: _scrollController,
          reverse: widget.reverse,
          child: _buildContainerForScrollDirection(
            children: <Widget>[
              // if (widget.reverse)
              //   _wrap(finalDropArea, widget.children.length, constraints),
              if (widget.header != null) widget.header!,
              for (int i = 0; i < widget.children.length; i += 1)
                _wrap(widget.children[i], i, constraints),
              // if (!widget.reverse)
              //   _wrap(finalDropArea, widget.children.length, constraints),
            ],
          ),
        );
      },
    );
  }
}
