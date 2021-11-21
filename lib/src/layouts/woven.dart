// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

// class SliverWovenGridDelegate extends SliverGridDelegate {
//   const SliverWovenGridDelegate({
//     required this.crossAxisCount,
//     this.mainAxisSpacing = 24,
//     this.crossAxisSpacing = 24,
//     this.titleHeight = 28,
//   })  : assert(crossAxisCount > 0),
//         assert(mainAxisSpacing > 0),
//         assert(crossAxisSpacing > 0),
//         assert(titleHeight > 0);

//   /// {@macro fsgv.global.crossAxisCount}
//   final int crossAxisCount;

//   /// {@macro fsgv.global.mainAxisSpacing}
//   final double mainAxisSpacing;

//   /// {@macro fsgv.global.crossAxisSpacing}
//   final double crossAxisSpacing;

//   /// {@template fsgv.woven.titleHeight}
//   /// The number of logical pixels of the title part.
//   /// {@endtemplate}
//   final double titleHeight;

//   @override
//   _SliverWovenGridLayout getLayout(SliverConstraints constraints) {
//     // TODO: implement getLayout
//     throw UnimplementedError();
//   }

//   @override
//   bool shouldRelayout(SliverWovenGridDelegate oldDelegate) {
//     // TODO: implement shouldRelayout
//     throw UnimplementedError();
//   }
// }

// class _SliverWovenGridLayout extends SliverGridLayout {
//   const _SliverWovenGridLayout({
//     required this.titleHeight,
//   });

//   /// {@macro fsgv.global.crossAxisCount}
//   final int crossAxisCount;

//   /// The number of pixels from the leading edge of one tile to the leading edge
//   /// of the next tile in the main axis.
//   final double mainAxisStride;

//   /// The number of pixels from the leading edge of one tile to the leading edge
//   /// of the next tile in the cross axis.
//   final double crossAxisStride;

//   /// The number of pixels from the leading edge of one tile to the trailing
//   /// edge of the same tile in the cross axis.
//   final double crossAxisExtent;

//   /// Whether the children should be placed in the opposite order of increasing
//   /// coordinates in the cross axis.
//   ///
//   /// For example, if the cross axis is horizontal, the children are placed from
//   /// left to right when [reverseCrossAxis] is false and from right to left when
//   /// [reverseCrossAxis] is true.
//   ///
//   /// Typically set to the return value of [axisDirectionIsReversed] applied to
//   /// the [SliverConstraints.crossAxisDirection].
//   final bool reverseCrossAxis;

//   final double oddChildRatio;
//   final double evenChildRatio;

//   /// {@macro fsgv.woven.titleHeight}
//   final double titleHeight;

//   @override
//   double computeMaxScrollOffset(int childCount) {
//     // TODO: implement computeMaxScrollOffset
//     throw UnimplementedError();
//   }

//   double _getOffsetFromStartInCrossAxis(double crossAxisStart) {
//     if (reverseCrossAxis)
//       return crossAxisCount * crossAxisStride -
//           crossAxisStart -
//           maxChildCrossAxisExtent -
//           (crossAxisStride - maxChildCrossAxisExtent);
//     return crossAxisStart;
//   }

//   @override
//   SliverGridGeometry getGeometryForChildIndex(int index) {
//     final double crossAxisStart = (index % crossAxisCount) * crossAxisStride;

//     if (index.isOdd) {
//       return SliverGridGeometry(
//         scrollOffset: (index ~/ crossAxisCount) * mainAxisStride,
//         crossAxisOffset: _getOffsetFromStartInCrossAxis(crossAxisStart),
//         mainAxisExtent: maxChildMainAxisExtent,
//         crossAxisExtent: maxChildCrossAxisExtent,
//       );
//     } else {
//       return SliverGridGeometry(
//         scrollOffset: (index ~/ crossAxisCount) * mainAxisStride,
//         crossAxisOffset: _getOffsetFromStartInCrossAxis(crossAxisStart),
//         mainAxisExtent: maxChildMainAxisExtent,
//         crossAxisExtent: maxChildCrossAxisExtent,
//       );
//     }
//   }

//   @override
//   int getMaxChildIndexForScrollOffset(double scrollOffset) {
//     // TODO: implement getMaxChildIndexForScrollOffset
//     throw UnimplementedError();
//   }

//   @override
//   int getMinChildIndexForScrollOffset(double scrollOffset) {
//     // TODO: implement getMinChildIndexForScrollOffset
//     throw UnimplementedError();
//   }
// }
