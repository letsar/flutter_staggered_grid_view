import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ExampleTests extends StatelessWidget {
  ExampleTests() : products = List.generate(50, (i) => Product('test $i'));

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('random dynamic tile sizes'),
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverStaggeredGrid.countBuilder(
              crossAxisCount: 2,
              staggeredTileBuilder: (_) => const StaggeredTile.fit(1),
              itemBuilder: (context, index) => ProductGridItem(
                products[index],
              ),
              itemCount: products.length,
            ),
          ],
        ));
  }
}

class Leaf extends StatefulWidget {
  const Leaf({Key key, this.child}) : super(key: key);
  final Widget child;
  @override
  _LeafState createState() => _LeafState();
}

class _LeafState extends State<Leaf> {
  bool _keepAlive = false;
  KeepAliveHandle _handle;

  @override
  void deactivate() {
    _handle?.release();
    _handle = null;
    super.deactivate();
  }

  void setKeepAlive(bool value) {
    _keepAlive = value;
    if (_keepAlive) {
      if (_handle == null) {
        _handle = KeepAliveHandle();
        KeepAliveNotification(_handle).dispatch(context);
      }
    } else {
      _handle?.release();
      _handle = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_keepAlive && _handle == null) {
      _handle = KeepAliveHandle();
      KeepAliveNotification(_handle).dispatch(context);
    }
    return widget.child;
  }
}

class Product {
  const Product(this.name);
  final String name;
}

class ProductGridItem extends StatelessWidget {
  const ProductGridItem(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
      color: Colors.blue,
      height: 80,
      child: Center(
        child: Text(product.name),
      ),
    ));
  }
}
