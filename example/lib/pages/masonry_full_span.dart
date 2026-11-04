import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_staggered_grid_view_example/common.dart';

/// A masonry grid with a header, and a banner every 9 children, spanning the
/// whole width.
class MasonryFullSpanPage extends StatefulWidget {
  const MasonryFullSpanPage({
    super.key,
  });

  @override
  State<MasonryFullSpanPage> createState() => _MasonryFullSpanPageState();
}

class _MasonryFullSpanPageState extends State<MasonryFullSpanPage> {
  int crossAxisCount = 2;

  bool isBanner(int index) => index % 9 == 0;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Masonry full span',
      actions: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: crossAxisCount > 1
              ? () => setState(() => crossAxisCount--)
              : null,
        ),
        Center(child: Text('$crossAxisCount')),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => setState(() => crossAxisCount++),
        ),
      ],
      child: MasonryGridView.count(
        padding: const EdgeInsets.all(8),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: 300,
        isFullSpan: isBanner,
        itemBuilder: (context, index) {
          if (isBanner(index)) {
            return Container(
              height: 72,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                index == 0 ? 'Header' : 'Banner $index',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }
          return Tile(index: index, extent: 80.0 + (index * 37 % 7) * 30);
        },
      ),
    );
  }
}
