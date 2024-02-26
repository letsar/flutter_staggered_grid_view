import 'package:flutter_staggered_grid_view/src/foundation/masonry_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MasonryCache', () {
    test('length should be 0 after construction', () {
      final cache = MasonryCache();
      expect(cache.capacity, 0);
    });

    test('length should be 32 by default after adding the first element', () {
      final cache = MasonryCache();
      cache.add((start: 0, end: 0, crossAxisIndex: 0));
      expect(cache.capacity, 32);
    });

    test('length should be 64 after inserting the 33th element', () {
      final cache = MasonryCache();
      cache.length = 33;
      cache[32] = (start: 0, end: 0, crossAxisIndex: 0);
      expect(cache.capacity, 64);
    });

    test('skipped entry should be 0', () {
      final cache = MasonryCache();
      cache.length = 33;
      cache[32] = (start: 0, end: 0, crossAxisIndex: 0);
      final entry = cache[0];
      expect(entry.start, 0);
      expect(entry.end, 0);
      expect(entry.crossAxisIndex, 0);
    });

    test('should correcly read element after writing it', () {
      final cache = MasonryCache();
      cache.add((start: 100, end: 200, crossAxisIndex: 1));
      final entry = cache[0];
      expect(entry.start, 100);
      expect(entry.end, 200);
      expect(entry.crossAxisIndex, 1);
    });

    test('data should be correctly copied after the cache expanded', () {
      final cache = MasonryCache();
      cache.length = 4;
      cache[3] = (start: 100, end: 200, crossAxisIndex: 1);
      cache.length = 33;
      cache[32] = (start: 0, end: 0, crossAxisIndex: 0);
      final entry = cache[3];
      expect(entry.start, 100);
      expect(entry.end, 200);
      expect(entry.crossAxisIndex, 1);
    });
  });
}
