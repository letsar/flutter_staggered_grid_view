import 'package:examples/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

const _aspectRatios = <double>[
  0.5,
  1.5,
  1,
  1.8,
  0.4,
  0.7,
  0.9,
  1.1,
  1.7,
  2,
  2.1
];

class JustifiedPage extends StatelessWidget {
  const JustifiedPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Justified',
      child: JustifiedGridView.builder(
        itemBuilder: (context, index) {
          return ImageTile(
            index: index,
            height: 200,
            width:
                ((_aspectRatios[index % _aspectRatios.length]) * 100).toInt(),
          );
        },
        itemCount: 500,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        trackMainAxisExtent: 200,
        aspectRatioGetter: (index) {
          return _aspectRatios[index % _aspectRatios.length];
        },
      ),
    );
  }
}
