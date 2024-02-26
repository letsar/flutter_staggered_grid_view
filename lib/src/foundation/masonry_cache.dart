// ignore_for_file: public_member_api_docs

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:meta/meta.dart';

int _cacheEntrySizeInBytes = 4 + 4 + 1;

@internal
class MasonryCache {
  late ByteData _data;
  int _capacity = 0;
  int get capacity => _capacity;

  int _length = 0;
  int get length => _length;
  set length(int value) {
    _ensureCapacity(value);
    _length = value;
  }

  MasonryCacheEntry operator [](int index) {
    if (index >= length) {
      throw RangeError.index(index, this);
    }

    int offset = index * _cacheEntrySizeInBytes;
    return (
      start: _data.getFloat32(offset),
      end: _data.getFloat32(offset + 4),
      crossAxisIndex: _data.getUint8(offset + 8),
    );
  }

  void operator []=(int index, MasonryCacheEntry entry) {
    if (index >= length) {
      throw RangeError.index(index, this);
    }

    int offset = index * _cacheEntrySizeInBytes;
    _data.setFloat32(offset, entry.start);
    _data.setFloat32(offset + 4, entry.end);
    _data.setUint8(offset + 8, entry.crossAxisIndex);
  }

  void add(MasonryCacheEntry entry) {
    final index = length;
    length++;
    this[index] = entry;
  }

  MasonryCacheEntry removeLast() {
    final index = length - 1;
    final entry = this[index];
    length--;
    return entry;
  }

  void _ensureCapacity(int length) {
    if (_capacity >= length) {
      return;
    }

    final newCapacity = math.max(_nextPowerOfTwo(length), 32);
    final newData = ByteData(newCapacity * _cacheEntrySizeInBytes);

    if (_capacity != 0) {
      // We need to copy the old data to the new data.
      final oldSize = _data.lengthInBytes;
      for (int offset = 0; offset < oldSize;) {
        newData.setFloat32(offset, _data.getFloat32(offset));
        offset += 4;
        newData.setFloat32(offset, _data.getFloat32(offset));
        offset += 4;
        newData.setUint8(offset, _data.getUint8(offset));
        offset += 1;
      }
    }

    _capacity = newCapacity;
    _data = newData;
  }

  void clear() {
    _capacity = 0;
  }

  static int _nextPowerOfTwo(int n) {
    n--;
    n |= n >> 1;
    n |= n >> 2;
    n |= n >> 4;
    n |= n >> 8;
    n |= n >> 16;
    return ++n;
  }
}

@internal
typedef MasonryCacheEntry = ({
  double start,
  double end,
  int crossAxisIndex,
});
