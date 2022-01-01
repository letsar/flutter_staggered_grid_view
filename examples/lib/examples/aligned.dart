import 'package:examples/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class AlignedPage extends StatelessWidget {
  const AlignedPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Aligned',
      child: AlignedGridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        itemBuilder: (context, index) {
          return AlignedTile(index: index);
        },
      ),
    );
  }
}

class AlignedTile extends StatefulWidget {
  const AlignedTile({
    Key? key,
    required this.index,
    this.animate = false,
  }) : super(key: key);

  final int index;
  final bool animate;

  @override
  State<AlignedTile> createState() => _AlignedTileState();
}

class _AlignedTileState extends State<AlignedTile>
    with SingleTickerProviderStateMixin {
  Color color = Colors.blue;
  late final controller =
      AnimationController(vsync: this, duration: Duration(seconds: 1));
  late final animation = Tween<double>(begin: 0, end: 6).animate(controller);

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final newColor = color == Colors.blue ? Colors.red : Colors.blue;
        setState(() {
          color = newColor;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        color: color,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Text('Lorem ipsum ' *
                ((widget.index % 7 + 1) * 2 + animation.value.ceil()));
          },
        ),
      ),
    );
  }
}
