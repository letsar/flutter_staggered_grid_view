// Differential test of the masonry grid.
//
// Random operations (scrolling, resizing the grid, changing the number of
// columns or the spacings, inserting, removing, moving and resizing children)
// are applied to grids with random configurations (axis, direction, padding,
// cache extent, keep-alive children, unknown child count, extents given by a
// builder). After each operation, every child which is alive is compared to a
// reference placement computed from scratch.
//
// The number of random sequences can be increased with:
// flutter test test/src/widgets/masonry_differential_test.dart \
//   --dart-define=MASONRY_SEEDS=1000
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';

const int seeds = int.fromEnvironment('MASONRY_SEEDS', defaultValue: 24);
const int operationsPerSeed = 40;
const double headerExtent = 100;
const double footerExtent = 300;
const double viewportExtent = 600;
const double tolerance = 1e-4;

/// Counts the states created for each item.
final Map<int, int> createdStates = {};

/// The states which are alive, by item.
final Map<int, _FuzzTileState> liveStates = {};

class Item {
  Item(
    this.id,
    this.ratio,
    this.fixedExtent, {
    required this.keepAlive,
    required this.fullSpan,
  });

  final int id;

  /// Whether the item spans the whole cross axis.
  bool fullSpan;

  /// The extent is `ratio * crossAxisExtent`, unless [fixedExtent] is not null.
  double ratio;
  double? fixedExtent;
  final bool keepAlive;

  double extent(double crossAxisExtent) =>
      fixedExtent ?? ratio * crossAxisExtent;
}

class FuzzTile extends StatefulWidget {
  const FuzzTile({super.key, required this.item, required this.vertical});

  final Item item;
  final bool vertical;

  @override
  State<FuzzTile> createState() => _FuzzTileState();
}

class _FuzzTileState extends State<FuzzTile>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.item.keepAlive;

  @override
  void initState() {
    super.initState();
    createdStates.update(
      widget.item.id,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
    liveStates[widget.item.id] = this;
  }

  @override
  void dispose() {
    if (liveStates[widget.item.id] == this) {
      liveStates.remove(widget.item.id);
    }
    super.dispose();
  }

  /// Rebuilds the tile without rebuilding the grid, like an image which is
  /// loaded.
  void rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final extent = widget.item.extent(
          widget.vertical ? constraints.maxWidth : constraints.maxHeight,
        );
        return widget.vertical
            ? SizedBox(height: extent)
            : SizedBox(width: extent);
      },
    );
  }
}

class Configuration {
  Configuration(math.Random random)
      : vertical = random.nextBool(),
        reverse = random.nextInt(3) == 0,
        rtl = random.nextInt(3) == 0,
        padding = random.nextBool() ? 0 : 10 + random.nextDouble() * 20,
        cacheExtent = const [0.0, 250.0, 3000.0][random.nextInt(3)],
        keepAlive = random.nextBool(),
        unknownChildCount = random.nextInt(3) == 0,
        withExtentBuilder = random.nextBool();

  final bool vertical;
  final bool reverse;
  final bool rtl;
  final double padding;
  final double cacheExtent;
  final bool keepAlive;
  final bool unknownChildCount;
  final bool withExtentBuilder;

  @override
  String toString() => 'vertical: $vertical, reverse: $reverse, rtl: $rtl, '
      'padding: $padding, cacheExtent: $cacheExtent, keepAlive: $keepAlive, '
      'unknownChildCount: $unknownChildCount, '
      'withExtentBuilder: $withExtentBuilder';
}

class Grid {
  Grid(this.random, this.configuration) {
    final count = 20 + random.nextInt(300);
    for (var i = 0; i < count; i++) {
      items.add(newItem());
    }
  }

  final math.Random random;
  final Configuration configuration;
  final List<Item> items = [];
  final ScrollController controller = ScrollController();
  int nextId = 0;
  double width = 400;
  int crossAxisCount = 3;
  double mainAxisSpacing = 4;
  double crossAxisSpacing = 4;

  Item newItem() {
    // Some children have no extent, like images which are not loaded yet.
    final fixedExtent = switch (random.nextInt(4)) {
      0 => 0.0,
      1 => random.nextDouble() * 300,
      _ => null,
    };
    return Item(
      nextId++,
      0.3 + random.nextDouble() * 1.7,
      fixedExtent,
      keepAlive: configuration.keepAlive && random.nextInt(4) == 0,
      fullSpan: random.nextInt(8) == 0,
    );
  }

  double get stride =>
      (width - 2 * configuration.padding + crossAxisSpacing) / crossAxisCount;

  double get childCrossAxisExtent => math.max(0, stride - crossAxisSpacing);

  Widget build() {
    final vertical = configuration.vertical;
    Widget spacer(double extent) =>
        vertical ? SizedBox(height: extent) : SizedBox(width: extent);

    return Directionality(
      textDirection: configuration.rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: vertical ? width : viewportExtent,
          height: vertical ? viewportExtent : width,
          child: CustomScrollView(
            controller: controller,
            scrollDirection: vertical ? Axis.vertical : Axis.horizontal,
            reverse: configuration.reverse,
            // ignore: deprecated_member_use
            cacheExtent: configuration.cacheExtent,
            slivers: [
              SliverToBoxAdapter(child: spacer(headerExtent)),
              SliverPadding(
                padding: EdgeInsets.all(configuration.padding),
                sliver: SliverMasonryGrid(
                  gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                  ),
                  mainAxisSpacing: mainAxisSpacing,
                  crossAxisSpacing: crossAxisSpacing,
                  isFullSpan: (index) =>
                      index < items.length && items[index].fullSpan,
                  mainAxisExtentBuilder: configuration.withExtentBuilder
                      ? (index, crossAxisExtent) => index < items.length
                          ? items[index].extent(crossAxisExtent)
                          : null
                      : null,
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => index < items.length
                        ? FuzzTile(
                            key: ValueKey(items[index].id),
                            item: items[index],
                            vertical: vertical,
                          )
                        : null,
                    childCount:
                        configuration.unknownChildCount ? null : items.length,
                    findChildIndexCallback: (key) {
                      final id = (key as ValueKey<int>).value;
                      final index = items.indexWhere((item) => item.id == id);
                      return index < 0 ? null : index;
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(child: spacer(footerExtent)),
            ],
          ),
        ),
      ),
    );
  }

  /// The placement of every item, computed from scratch, in the coordinates of
  /// the grid: left is the cross axis offset, top is the main axis offset.
  Map<int, Rect> reference() {
    final laneEnds = List<double>.filled(crossAxisCount, 0);
    final result = <int, Rect>{};
    final gridCrossAxisExtent = width - 2 * configuration.padding;
    for (final item in items) {
      if (item.fullSpan) {
        final start = laneEnds.reduce(math.max);
        final extent = item.extent(gridCrossAxisExtent);
        result[item.id] = Rect.fromLTWH(0, start, gridCrossAxisExtent, extent);
        laneEnds.fillRange(0, crossAxisCount, start + extent + mainAxisSpacing);
        continue;
      }
      var lane = 0;
      for (var i = 1; i < crossAxisCount; i++) {
        if (laneEnds[i] < laneEnds[lane]) {
          lane = i;
        }
      }
      final extent = item.extent(childCrossAxisExtent);
      result[item.id] = Rect.fromLTWH(
        lane * stride,
        laneEnds[lane],
        childCrossAxisExtent,
        extent,
      );
      laneEnds[lane] += extent + mainAxisSpacing;
    }
    return result;
  }

  /// Every child which is alive (including the ones in the cache extent but
  /// not the kept alive ones), in the coordinates of the grid.
  Map<int, Rect> liveTiles(WidgetTester tester) {
    final sliver = tester.renderObject<RenderSliverMasonryGrid>(
      find.byType(SliverMasonryGrid, skipOffstage: false),
    );
    final result = <int, Rect>{};
    for (final element
        in find.byType(FuzzTile, skipOffstage: false).evaluate()) {
      RenderObject? renderObject = element.renderObject;
      while (renderObject != null && renderObject.parent != sliver) {
        renderObject = renderObject.parent;
      }
      if (renderObject == null ||
          (renderObject.parentData! as SliverMultiBoxAdaptorParentData)
              .keptAlive) {
        continue;
      }

      final box = renderObject as RenderBox;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      final vertical = configuration.vertical;
      final mainAxisStart = vertical ? rect.top : rect.left;
      final mainAxisEnd = vertical ? rect.bottom : rect.right;
      final reversed = vertical
          ? configuration.reverse
          : configuration.reverse != configuration.rtl;
      final offset = controller.offset - headerExtent - configuration.padding;
      final mainAxisOffset = reversed
          ? viewportExtent - mainAxisEnd + offset
          : mainAxisStart + offset;
      final crossAxisOffset = vertical && configuration.rtl
          ? width - rect.right - configuration.padding
          : (vertical ? rect.left : rect.top) - configuration.padding;

      result[(element.widget as FuzzTile).item.id] = Rect.fromLTWH(
        crossAxisOffset,
        mainAxisOffset,
        vertical ? rect.width : rect.height,
        mainAxisEnd - mainAxisStart,
      );
    }
    return result;
  }
}

bool sameRect(Rect a, Rect b) {
  return (a.left - b.left).abs() < tolerance &&
      (a.top - b.top).abs() < tolerance &&
      (a.width - b.width).abs() < tolerance &&
      (a.height - b.height).abs() < tolerance;
}

void main() {
  for (var seed = 0; seed < seeds; seed++) {
    testWidgets('random operations (seed: $seed)', (tester) async {
      createdStates.clear();
      liveStates.clear();
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final random = math.Random(seed);
      final configuration = Configuration(random);
      final grid = Grid(random, configuration);
      final controller = grid.controller;
      final log = <String>['$configuration'];
      String context() => 'seed $seed:\n${log.join('\n')}';

      // The states of the kept alive children, once seen.
      final keptAliveStates = <int, int>{};

      // Whether some cached placements may be outdated. The grid only checks
      // them again when the children are laid out.
      var outdated = false;

      await tester.pumpWidget(grid.build());

      // Whether a jump did not reach its target.
      var clamped = false;
      Future<void> jumpTo(double offset) async {
        controller.jumpTo(offset);
        await tester.pump();
        if ((controller.offset - offset).abs() > tolerance) {
          clamped = true;
        }
      }

      double maxScrollExtent() {
        final extent = controller.position.maxScrollExtent;
        return extent.isFinite ? extent : controller.offset + 3000;
      }

      /// Lays out every child, so that all the cached placements are checked,
      /// and goes back to the current offset.
      Future<void> refresh() async {
        final target = controller.offset;
        await jumpTo(0);
        while (controller.offset < maxScrollExtent()) {
          await jumpTo(
            math.min(maxScrollExtent(), controller.offset + viewportExtent / 2),
          );
        }
        await jumpTo(math.min(target, maxScrollExtent()));
      }

      for (var step = 0; step < operationsPerSeed; step++) {
        final before = grid.liveTiles(tester).keys.toSet();
        final statesBefore = Map.of(createdStates);
        final offsetBefore = controller.offset;
        var keepsStates = true;
        var checkExtent = false;
        // Whether the operation changes the children.
        var changesData = false;
        clamped = false;

        switch (random.nextInt(13)) {
          case 0:
          case 1:
            final offset = random.nextDouble() * maxScrollExtent();
            log.add('jump to $offset');
            await jumpTo(offset);
          case 2:
            final delta = (random.nextDouble() - 0.5) * 2 * viewportExtent;
            final offset =
                (controller.offset + delta).clamp(0.0, maxScrollExtent());
            log.add('scroll to $offset');
            await jumpTo(offset);
          case 3:
            log.add('jump to the end');
            // The extent is estimated until the end is reached.
            for (var i = 0; i < 5; i++) {
              await jumpTo(maxScrollExtent());
            }
            keepsStates = false;
            checkExtent = !configuration.unknownChildCount;
          case 4:
            grid.width = 150 + random.nextDouble() * 650;
            log.add('width ${grid.width}');
            await tester.pumpWidget(grid.build());
            outdated = outdated || !configuration.withExtentBuilder;
          case 5:
            grid.crossAxisCount = 1 + random.nextInt(6);
            log.add('crossAxisCount ${grid.crossAxisCount}');
            await tester.pumpWidget(grid.build());
            keepsStates = false;
          case 6:
            final index = random.nextInt(grid.items.length + 1);
            log.add('insert at $index');
            changesData = true;
            grid.items.insert(index, grid.newItem());
            await tester.pumpWidget(grid.build());
            outdated = true;
          case 7:
            if (grid.items.length < 2) {
              break;
            }
            final index = random.nextInt(grid.items.length);
            log.add('remove at $index');
            changesData = true;
            grid.items.removeAt(index);
            await tester.pumpWidget(grid.build());
            outdated = true;
          case 8:
            if (grid.items.isEmpty) {
              break;
            }
            final item = grid.items.removeAt(random.nextInt(grid.items.length));
            final index = random.nextInt(grid.items.length + 1);
            log.add('move ${item.id} to $index');
            changesData = true;
            grid.items.insert(index, item);
            await tester.pumpWidget(grid.build());
            outdated = true;
          case 9:
            if (configuration.withExtentBuilder || grid.items.isEmpty) {
              break;
            }
            final item = grid.items[random.nextInt(grid.items.length)];
            item.fixedExtent =
                random.nextBool() ? null : random.nextDouble() * 300;
            item.ratio = 0.3 + random.nextDouble() * 1.7;
            final state = liveStates[item.id];
            log.add('resize ${item.id} (alive: ${state != null})');
            changesData = true;
            state?.rebuild();
            await tester.pump();
            outdated = true;
          case 10:
            grid.mainAxisSpacing = random.nextDouble() * 10;
            log.add('mainAxisSpacing ${grid.mainAxisSpacing}');
            await tester.pumpWidget(grid.build());
            keepsStates = false;
          case 11:
            grid.crossAxisSpacing = random.nextDouble() * 10;
            log.add('crossAxisSpacing ${grid.crossAxisSpacing}');
            await tester.pumpWidget(grid.build());
            outdated = outdated || !configuration.withExtentBuilder;
          case 12:
            if (grid.items.isEmpty) {
              break;
            }
            final item = grid.items[random.nextInt(grid.items.length)];
            item.fullSpan = !item.fullSpan;
            log.add('fullSpan ${item.id}: ${item.fullSpan}');
            changesData = true;
            await tester.pumpWidget(grid.build());
            outdated = true;
        }

        expect(tester.takeException(), isNull, reason: context());

        // When the content becomes shorter than the scroll offset, there is
        // nothing to show until the scroll position is corrected, and the
        // children are released (like in a SliverList).
        if (offsetBefore > maxScrollExtent() + tolerance || clamped) {
          keepsStates = false;
        }
        // It's the same when the data changes before the viewport: the scroll
        // offset correction which keeps the first visible child in place can
        // go after the end, and the viewport corrects it again.
        if (changesData &&
            controller.offset != offsetBefore &&
            (controller.offset - maxScrollExtent()).abs() < tolerance) {
          keepsStates = false;
        }

        // The children which stay alive keep their state.
        final after = grid.liveTiles(tester);
        if (keepsStates) {
          for (final id in before.intersection(after.keys.toSet())) {
            expect(
              createdStates[id],
              statesBefore[id],
              reason: 'state of $id recreated, ${context()}',
            );
          }
        }

        // The kept alive children are never created again.
        for (final item in grid.items.where((item) => item.keepAlive)) {
          final count = keptAliveStates[item.id];
          if (count != null) {
            expect(
              createdStates[item.id],
              count,
              reason: 'kept alive ${item.id} recreated, ${context()}',
            );
          }
        }
        for (final id in after.keys) {
          if (grid.items.firstWhere((item) => item.id == id).keepAlive) {
            keptAliveStates[id] ??= createdStates[id]!;
          }
        }

        // The children never overlap and have the expected size.
        final reference = grid.reference();
        final rects = after.entries.toList();
        for (var i = 0; i < rects.length; i++) {
          final rect = rects[i].value;
          final expected = reference[rects[i].key]!;
          expect(rect.width, closeTo(expected.width, tolerance));
          expect(
            rect.height,
            closeTo(expected.height, tolerance),
            reason: 'extent of ${rects[i].key}, ${context()}',
          );
          for (var j = i + 1; j < rects.length; j++) {
            final overlap = rect.intersect(rects[j].value);
            expect(
              overlap.width > tolerance && overlap.height > tolerance,
              isFalse,
              reason: '${rects[i].key} overlaps ${rects[j].key}, '
                  '${context()}',
            );
          }
        }

        if (outdated) {
          await refresh();
          outdated = false;
        }

        if (checkExtent) {
          final gridExtent = reference.values.fold<double>(
            0,
            (extent, rect) => math.max(extent, rect.bottom),
          );
          expect(
            maxScrollExtent(),
            closeTo(
              math.max(
                0,
                headerExtent +
                    2 * configuration.padding +
                    gridExtent +
                    footerExtent -
                    viewportExtent,
              ),
              tolerance,
            ),
            reason: context(),
          );
        }

        // The children are placed like in a grid created from scratch.
        for (final entry in grid.liveTiles(tester).entries) {
          expect(
            sameRect(entry.value, reference[entry.key]!),
            isTrue,
            reason: '${entry.key} is at ${entry.value} instead of '
                '${reference[entry.key]}, ${context()}',
          );
        }
      }
    });
  }
}
