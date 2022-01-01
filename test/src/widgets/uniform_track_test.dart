import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/src/widgets/uniform_track.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common.dart';

void main() {
  testWidgets('Should layout children following its direction', (tester) async {
    // Screen size is 800x600 in the test environment.
    await tester.pumpWidget(
      Align(
        alignment: Alignment.topLeft,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: UniformTrack(
            division: 4,
            direction: AxisDirection.right,
            children: const [
              Tile(index: 0, height: 100),
              Tile(index: 1, height: 200),
              Tile(index: 2, height: 50),
              Tile(index: 3, height: 200),
            ],
          ),
        ),
      ),
    );

    void _expectTopLeft(int index, Offset topLeft) {
      expect(tester.getTopLeft(find.text('$index')), equals(topLeft));
    }

    _expectTopLeft(0, const Offset(0, 0));
    _expectTopLeft(1, const Offset(200, 0));
    _expectTopLeft(2, const Offset(400, 0));
    _expectTopLeft(3, const Offset(600, 0));

    await tester.pumpWidget(
      Align(
        alignment: Alignment.topLeft,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: UniformTrack(
            division: 4,
            direction: AxisDirection.down,
            children: const [
              Tile(index: 0, width: 100),
              Tile(index: 1, width: 200),
              Tile(index: 2, width: 50),
              Tile(index: 3, width: 200),
            ],
          ),
        ),
      ),
    );

    _expectTopLeft(0, const Offset(0, 0));
    _expectTopLeft(1, const Offset(0, 150));
    _expectTopLeft(2, const Offset(0, 300));
    _expectTopLeft(3, const Offset(0, 450));
  });

  testWidgets('Children should be of the maximum size', (tester) async {
    // Screen size is 800x600 in the test environment.
    await tester.pumpWidget(
      Align(
        alignment: Alignment.topLeft,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: UniformTrack(
            division: 4,
            direction: AxisDirection.right,
            children: const [
              Tile(index: 0, height: 100),
              Tile(index: 1, height: 200),
              Tile(index: 2, height: 50),
              Tile(index: 3, height: 200),
            ],
          ),
        ),
      ),
    );

    void _expectSize(int index, Size size) {
      expect(tester.getSize(find.text('$index')), equals(size));
    }

    for (int i = 0; i < 4; i++) {
      _expectSize(i, const Size(200, 200));
    }

    await tester.pumpWidget(
      Align(
        alignment: Alignment.topLeft,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: UniformTrack(
            division: 4,
            direction: AxisDirection.down,
            children: const [
              Tile(index: 0, width: 100),
              Tile(index: 1, width: 200),
              Tile(index: 2, width: 50),
              Tile(index: 3, width: 200),
            ],
          ),
        ),
      ),
    );

    for (int i = 0; i < 4; i++) {
      _expectSize(i, const Size(200, 150));
    }
  });

  testWidgets('Should have a gap of the specified size between children',
      (tester) async {
    // Screen size is 800x600 in the test environment.
    await tester.pumpWidget(
      Align(
        alignment: Alignment.topLeft,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: UniformTrack(
            division: 4,
            spacing: 4,
            direction: AxisDirection.right,
            children: const [
              Tile(index: 0, height: 100),
              Tile(index: 1, height: 200),
              Tile(index: 2, height: 50),
              Tile(index: 3, height: 200),
            ],
          ),
        ),
      ),
    );

    void _expectTopLeft(int index, Offset topLeft) {
      expect(tester.getTopLeft(find.text('$index')), equals(topLeft));
    }

    _expectTopLeft(0, const Offset(0, 0));
    _expectTopLeft(1, const Offset(201, 0));
    _expectTopLeft(2, const Offset(402, 0));
    _expectTopLeft(3, const Offset(603, 0));

    await tester.pumpWidget(
      Align(
        alignment: Alignment.topLeft,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: UniformTrack(
            division: 4,
            spacing: 4,
            direction: AxisDirection.down,
            children: const [
              Tile(index: 0, width: 100),
              Tile(index: 1, width: 200),
              Tile(index: 2, width: 50),
              Tile(index: 3, width: 200),
            ],
          ),
        ),
      ),
    );

    _expectTopLeft(0, const Offset(0, 0));
    _expectTopLeft(1, const Offset(0, 151));
    _expectTopLeft(2, const Offset(0, 302));
    _expectTopLeft(3, const Offset(0, 453));
  });

  testWidgets(
      'Should divide the available space following the division parameter',
      (tester) async {
    // Screen size is 800x600 in the test environment.
    await tester.pumpWidget(
      Align(
        alignment: Alignment.topLeft,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: UniformTrack(
            division: 4,
            direction: AxisDirection.right,
            children: const [
              Tile(index: 0, height: 100),
              Tile(index: 1, height: 200),
            ],
          ),
        ),
      ),
    );

    void _expectTopLeft(int index, Offset topLeft) {
      expect(tester.getTopLeft(find.text('$index')), equals(topLeft));
    }

    void _expectSize(int index, Size size) {
      expect(tester.getSize(find.text('$index')), equals(size));
    }

    for (int i = 0; i < 2; i++) {
      _expectSize(i, const Size(200, 200));
    }

    _expectTopLeft(0, const Offset(0, 0));
    _expectTopLeft(1, const Offset(200, 0));

    await tester.pumpWidget(
      Align(
        alignment: Alignment.topLeft,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: UniformTrack(
            division: 4,
            direction: AxisDirection.down,
            children: const [
              Tile(index: 0, width: 100),
              Tile(index: 1, width: 200),
            ],
          ),
        ),
      ),
    );

    for (int i = 0; i < 2; i++) {
      _expectSize(i, const Size(200, 150));
    }

    _expectTopLeft(0, const Offset(0, 0));
    _expectTopLeft(1, const Offset(0, 150));
  });
}
