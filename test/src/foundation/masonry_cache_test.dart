import 'package:flutter_staggered_grid_view/src/foundation/masonry_cache.dart';
import 'package:flutter_test/flutter_test.dart';

MasonryCache createCache({int crossAxisCount = 3, double spacing = 0}) {
  return MasonryCache()
    ..reset(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: spacing,
    );
}

void main() {
  group('MasonryCache', () {
    test('places each child in the lane with the smallest end', () {
      final cache = createCache(spacing: 10);
      for (final extent in <double>[100, 50, 80, 20, 40]) {
        cache.add(extent);
      }

      expect([for (var i = 0; i < 5; i++) cache.laneOf(i)], [0, 1, 2, 1, 1]);
      expect(
        [for (var i = 0; i < 5; i++) cache.startOf(i)],
        [0, 0, 0, 60, 90],
      );
      expect(cache.startOf(4) + cache.extentOf(4), 130);
      expect(cache.extent, 130);
    });

    test('chooses the lane with the smallest index on ties', () {
      final cache = createCache();
      for (var i = 0; i < 6; i++) {
        cache.add(100);
      }

      expect(
        [for (var i = 0; i < 6; i++) cache.laneOf(i)],
        [0, 1, 2, 0, 1, 2],
      );
    });

    test('covers an offset when every lane ends after it', () {
      final cache = createCache(spacing: 10);
      cache
        ..add(100)
        ..add(200);
      expect(cache.covers(0), isTrue);
      expect(cache.covers(1), isFalse);

      cache.add(50);
      expect(cache.covers(60), isTrue);
      expect(cache.covers(61), isFalse);
    });

    test('finds the visible children with binary searches', () {
      final cache = createCache();
      // Lanes: 0 => [0, 500], 1 => [0, 100], [100, 200], [200, 300]...
      cache.add(500);
      for (var i = 0; i < 10; i++) {
        cache.add(100);
        cache.add(100);
      }

      // The first child ends at 500.
      expect(cache.firstIndexEndingAtOrAfter(450), 0);
      expect(cache.firstIndexEndingAtOrAfter(500), 0);
      final index = cache.firstIndexEndingAtOrAfter(501);
      expect(index, greaterThan(0));
      expect(cache.startOf(index) + cache.extentOf(index), greaterThan(500));
      expect(cache.startOf(cache.firstIndexStartingAtOrAfter(300)), 300);
      expect(cache.startOf(cache.firstIndexStartingAtOrAfter(300) - 1), 200);
      expect(cache.firstIndexEndingAtOrAfter(10000), cache.length);
      expect(cache.firstIndexStartingAtOrAfter(10000), cache.length);
    });

    test('truncate restores the lanes so that children are placed again', () {
      final reference = createCache(spacing: 4);
      final extents = [for (var i = 0; i < 50; i++) (i * 37 % 11 + 1) * 10.0];
      extents.forEach(reference.add);

      final cache = createCache(spacing: 4);
      extents.forEach(cache.add);
      cache.truncate(17);
      expect(cache.length, 17);
      extents.skip(17).forEach(cache.add);

      for (var i = 0; i < extents.length; i++) {
        expect(cache.startOf(i), reference.startOf(i));
        expect(cache.laneOf(i), reference.laneOf(i));
      }
    });

    test('children with a zero extent at an offset end at this offset', () {
      final cache = createCache();
      cache
        ..add(0)
        ..add(0)
        ..add(0);
      expect(cache.firstIndexEndingAtOrAfter(0), 0);
    });

    test('keeps the exact extents of children placed far away', () {
      final cache = createCache(crossAxisCount: 1);
      cache
        ..add(3e6)
        ..add(100 / 3);
      expect(cache.extentOf(1), 100 / 3);
    });

    test('places a full span child after all the lanes', () {
      final cache = createCache(spacing: 10);
      cache
        ..add(100)
        ..add(50)
        ..add(30, fullSpan: true)
        ..add(20)
        ..add(40);

      // The full span child starts after the longest lane, and all the lanes
      // are aligned after it.
      expect(cache.startOf(2), 110);
      expect(cache.laneOf(2), isNull);
      expect(cache.startOf(3), 150);
      expect(cache.laneOf(3), 0);
      expect(cache.startOf(4), 150);
      expect(cache.laneOf(4), 1);
      expect(cache.firstIndexStartingAtOrAfter(111), 3);
      expect(cache.firstIndexEndingAtOrAfter(141), 3);
    });

    test('truncate restores the lanes after a full span child', () {
      final reference = createCache(spacing: 4);
      final extents = [for (var i = 0; i < 60; i++) (i * 37 % 11 + 1) * 10.0];
      bool fullSpan(int i) => i % 13 == 5;
      for (var i = 0; i < extents.length; i++) {
        reference.add(extents[i], fullSpan: fullSpan(i));
      }

      for (final length in [6, 7, 19, 33]) {
        final cache = createCache(spacing: 4);
        for (var i = 0; i < extents.length; i++) {
          cache.add(extents[i], fullSpan: fullSpan(i));
        }
        cache.truncate(length);
        for (var i = length; i < extents.length; i++) {
          cache.add(extents[i], fullSpan: fullSpan(i));
        }
        for (var i = 0; i < extents.length; i++) {
          expect(cache.startOf(i), reference.startOf(i));
          expect(cache.laneOf(i), reference.laneOf(i));
        }
      }
    });

    test('grows beyond its initial capacity', () {
      final cache = createCache();
      for (var i = 0; i < 1000; i++) {
        cache.add(10);
      }
      expect(cache.length, 1000);
      expect(cache.startOf(999), 3330);
    });

    test('isValidFor detects configuration changes', () {
      final cache = createCache();
      expect(
        cache.isValidFor(
          crossAxisCount: 3,
          mainAxisSpacing: 0,
        ),
        isTrue,
      );
      expect(
        cache.isValidFor(
          crossAxisCount: 2,
          mainAxisSpacing: 0,
        ),
        isFalse,
      );
    });

    test('throws when reading an index which is not cached', () {
      final cache = createCache()..add(10);
      expect(() => cache.startOf(1), throwsRangeError);
    });
  });
}
