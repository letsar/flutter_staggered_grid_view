// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/src/widgets/sliver.dart';

/// Allows subtrees to request to be kept alive in lazy lists.
///
/// This widget is like [KeepAliveVariableSizeBox] but instead of being explicitly configured,
/// it listens to [KeepAliveNotification] messages from the [child] and other
/// descendants.
///
/// The subtree is kept alive whenever there is one or more descendant that has
/// sent a [KeepAliveNotification] and not yet triggered its
/// [KeepAliveNotification.handle].
///
/// To send these notifications, consider using [AutomaticKeepAliveClientMixin].
class AutomaticKeepAliveVariableSizeBox extends StatefulWidget {
  /// Creates a widget that listens to [KeepAliveNotification]s and maintains a
  /// [KeepAliveVariableSizeBox] widget appropriately.
  const AutomaticKeepAliveVariableSizeBox({
    Key key,
    this.child,
  }) : super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  @override
  _AutomaticKeepAliveState createState() => new _AutomaticKeepAliveState();
}

class _AutomaticKeepAliveState extends State<AutomaticKeepAlive> {
  Map<Listenable, VoidCallback> _handles;
  Widget _child;
  bool _keepingAlive = false;

  @override
  void initState() {
    super.initState();
    _updateChild();
  }

  @override
  void didUpdateWidget(AutomaticKeepAlive oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateChild();
  }

  void _updateChild() {
    _child = new NotificationListener<KeepAliveNotification>(
      onNotification: _addClient,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    if (_handles != null) {
      for (Listenable handle in _handles.keys)
        handle.removeListener(_handles[handle]);
    }
    super.dispose();
  }

  bool _addClient(KeepAliveNotification notification) {
    final Listenable handle = notification.handle;
    _handles ??= <Listenable, VoidCallback>{};
    assert(!_handles.containsKey(handle));
    _handles[handle] = _createCallback(handle);
    handle.addListener(_handles[handle]);
    if (!_keepingAlive) {
      _keepingAlive = true;
      final ParentDataElement<SliverVariableSizeBoxAdaptorWidget> childElement =
          _getChildElement();
      if (childElement != null) {
        // If the child already exists, update it synchronously.
        _updateParentDataOfChild(childElement);
      } else {
        // If the child doesn't exist yet, we got called during the very first
        // build of this subtree. Wait until the end of the frame to update
        // the child when the child is guaranteed to be present.
        SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
          final ParentDataElement<SliverVariableSizeBoxAdaptorWidget>
              childElement = _getChildElement();
          assert(childElement != null);
          _updateParentDataOfChild(childElement);
        });
      }
    }
    return false;
  }

  /// Get the [Element] for the only [KeepAliveVariableSizeBox] child.
  ///
  /// While this widget is guaranteed to have a child, this may return null if
  /// the first build of that child has not completed yet.
  ParentDataElement<SliverVariableSizeBoxAdaptorWidget> _getChildElement() {
    final Element element = context;
    Element childElement;
    // We use Element.visitChildren rather than context.visitChildElements
    // because we might be called during build, and context.visitChildElements
    // verifies that it is not called during build. Element.visitChildren does
    // not, instead it assumes that the caller will be careful. (See the
    // documentation for these methods for more details.)
    //
    // Here we know it's safe (with the exception outlined below) because we
    // just received a notification, which we wouldn't be able to do if we
    // hadn't built our child and its child -- our build method always builds
    // the same subtree and it always includes the node we're looking for
    // (KeepAliveVariableSizeBox) as the parent of the node that reports the notifications
    // (NotificationListener).
    //
    // If we are called during the first build of this subtree the links to the
    // children will not be hooked up yet. In that case this method returns
    // null despite the fact that we will have a child after the build
    // completes. It's the caller's responsibility to deal with this case.
    //
    // (We're only going down one level, to get our direct child.)
    element.visitChildren((Element child) {
      childElement = child;
    });
    assert(childElement == null ||
        childElement is ParentDataElement<SliverVariableSizeBoxAdaptorWidget>);
    return childElement;
  }

  void _updateParentDataOfChild(
      ParentDataElement<SliverVariableSizeBoxAdaptorWidget> childElement) {
    childElement.applyWidgetOutOfTurn(build(context));
  }

  VoidCallback _createCallback(Listenable handle) {
    return () {
      assert(() {
        if (!mounted) {
          throw new FlutterError(
              'AutomaticKeepAliveVariableSizeBox handle triggered after AutomaticKeepAlive was disposed.'
              'Widgets should always trigger their KeepAliveNotification handle when they are '
              'deactivated, so that they (or their handle) do not send spurious events later '
              'when they are no longer in the tree.');
        }
        return true;
      }());
      _handles.remove(handle);
      if (_handles.isEmpty) {
        if (SchedulerBinding.instance.schedulerPhase.index <
            SchedulerPhase.persistentCallbacks.index) {
          // Build/layout haven't started yet so let's just schedule this for
          // the next frame.
          setState(() {
            _keepingAlive = false;
          });
        } else {
          // We were probably notified by a descendant when they were yanked out
          // of our subtree somehow. We're probably in the middle of build or
          // layout, so there's really nothing we can do to clean up this mess
          // short of just scheduling another build to do the cleanup. This is
          // very unfortunate, and means (for instance) that garbage collection
          // of these resources won't happen for another 16ms.
          //
          // The problem is there's really no way for us to distinguish these
          // cases:
          //
          //  * We haven't built yet (or missed out chance to build), but
          //    someone above us notified our descendant and our descendant is
          //    disconnecting from us. If we could mark ourselves dirty we would
          //    be able to clean everything this frame. (This is a pretty
          //    unlikely scenario in practice. Usually things change before
          //    build/layout, not during build/layout.)
          //
          //  * Our child changed, and as our old child went away, it notified
          //    us. We can't setState, since we _just_ built. We can't apply the
          //    parent data information to our child because we don't _have_ a
          //    child at this instant. We really want to be able to change our
          //    mind about how we built, so we can give the KeepAliveVariableSizeBox widget a
          //    new value, but it's too late.
          //
          //  * A deep descendant in another build scope just got yanked, and in
          //    the process notified us. We could apply new parent data
          //    information, but it may or may not get applied this frame,
          //    depending on whether said child is in the same layout scope.
          //
          //  * A descendant is being moved from one position under us to
          //    another position under us. They just notified us of the removal,
          //    at some point in the future they will notify us of the addition.
          //    We don't want to do anything. (This is why we check that
          //    _handles is still empty below.)
          //
          //  * We're being notified in the paint phase, or even in a post-frame
          //    callback. Either way it is far too late for us to make our
          //    parent lay out again this frame, so the garbage won't get
          //    collected this frame.
          //
          //  * We are being torn out of the tree ourselves, as is our
          //    descendant, and it notified us while it was being deactivated.
          //    We don't need to do anything, but we don't know yet because we
          //    haven't been deactivated yet. (This is why we check mounted
          //    below before calling setState.)
          //
          // Long story short, we have to schedule a new frame and request a
          // frame there, but this is generally a bad practice, and you should
          // avoid it if possible.
          _keepingAlive = false;
          scheduleMicrotask(() {
            if (mounted && _handles.isEmpty) {
              // If mounted is false, we went away as well, so there's nothing to do.
              // If _handles is no longer empty, then another client (or the same
              // client in a new place) registered itself before we had a chance to
              // turn off keep-alive, so again there's nothing to do.
              setState(() {
                assert(!_keepingAlive);
              });
            }
          });
        }
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    assert(_child != null);
    return new KeepAliveVariableSizeBox(
      keepAlive: _keepingAlive,
      child: _child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(new FlagProperty('_keepingAlive',
        value: _keepingAlive, ifTrue: 'keeping subtree alive'));
    description.add(new DiagnosticsProperty<Map<Listenable, VoidCallback>>(
      'handles',
      _handles,
      description: _handles != null
          ? '${_handles.length} active client${ _handles.length == 1 ? "" : "s" }'
          : null,
      ifNull: 'no notifications ever received',
    ));
  }
}
