import 'package:flutter/material.dart';

const _defaultColor = Color(0xFF34568B);

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    this.topPadding = 0,
    required this.child,
  });

  final String title;
  final Widget child;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: child,
      ),
    );
  }
}

class Tile extends StatelessWidget {
  const Tile({
    super.key,
    required this.index,
    this.extent,
    this.backgroundColor,
    this.bottomSpace,
  });

  final int index;
  final double? extent;
  final double? bottomSpace;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      color: backgroundColor ?? _defaultColor,
      height: extent,
      child: Center(
        child: CircleAvatar(
          minRadius: 20,
          maxRadius: 20,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          child: Text('$index', style: const TextStyle(fontSize: 20)),
        ),
      ),
    );

    if (bottomSpace == null) {
      return child;
    }

    return Column(
      children: [
        Expanded(child: child),
        Container(
          height: bottomSpace,
          color: Colors.green,
        )
      ],
    );
  }
}

class ImageTile extends StatelessWidget {
  const ImageTile({
    super.key,
    required this.index,
    required this.width,
    required this.height,
  });

  final int index;
  final int width;
  final int height;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://picsum.photos/$width/$height?random=$index',
      width: width.toDouble(),
      height: height.toDouble(),
      fit: BoxFit.cover,
    );
  }
}

class InteractiveTile extends StatefulWidget {
  const InteractiveTile({
    super.key,
    required this.index,
    this.extent,
    this.bottomSpace,
  });

  final int index;
  final double? extent;
  final double? bottomSpace;

  @override
  State<InteractiveTile> createState() => _InteractiveTileState();
}

class _InteractiveTileState extends State<InteractiveTile> {
  Color color = _defaultColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (color == _defaultColor) {
            color = Colors.red;
          } else {
            color = _defaultColor;
          }
        });
      },
      child: Tile(
        index: widget.index,
        extent: widget.extent,
        backgroundColor: color,
        bottomSpace: widget.bottomSpace,
      ),
    );
  }
}

class AnimatedTile extends StatefulWidget {
  const AnimatedTile({
    super.key,
    required this.index,
    this.minExtent,
    this.maxExtent,
    this.backgroundColor,
  });

  final int index;
  final double? minExtent;
  final double? maxExtent;
  final Color? backgroundColor;

  @override
  State<AnimatedTile> createState() => _AnimatedTileState();
}

class _AnimatedTileState extends State<AnimatedTile>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  );

  late final extent = Tween<double>(
    begin: widget.minExtent,
    end: widget.maxExtent,
  ).animate(controller);

  @override
  void initState() {
    super.initState();
    controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: extent,
      builder: (context, child) {
        return Tile(
          index: widget.index,
          extent: extent.value,
          backgroundColor: widget.backgroundColor,
        );
      },
    );
  }
}
