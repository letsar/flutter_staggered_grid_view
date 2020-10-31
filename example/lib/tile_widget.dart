import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TileWidget extends StatelessWidget {
  const TileWidget(
      {Key? key, required this.index, this.backgroundColor = Colors.green})
      : super(key: key);

  final int index;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
          child: CircleAvatar(
        backgroundColor: Colors.white,
        child: Text('$index'),
      )),
    );
  }
}
