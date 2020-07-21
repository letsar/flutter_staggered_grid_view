import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StaggeredGridView Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<SimpleBloc>(
        bloc: SimpleBloc(),
        child: MyScreen(),
      ),
    );
  }
}

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<int>(
        stream: BlocProvider.of<SimpleBloc>(context).counter,
        initialData: 0,
        builder: (context, snapshot) =>
            StaggeredTest(snapshot.data, snapshot.data),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: BlocProvider.of<SimpleBloc>(context).increment,
      ),
    );
  }
}

class GridTest extends StatelessWidget {
  GridTest(this.count, this.value);
  final int count;
  final int value;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.blue,
          child: Text('$value'),
        );
      },
    );
  }
}

class StaggeredTest extends StatelessWidget {
  StaggeredTest(this.count, this.value);
  final int count;
  final int value;

  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
      itemCount: count,
      crossAxisCount: 3,
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
      addAutomaticKeepAlives: false,
      staggeredTileBuilder: (index) => StaggeredTile.extent(1, 30),
      itemBuilder: (context, index) {
        return Container(
          color: Colors.green,
          child: Text('$value'),
        );
      },
    );
  }
}

abstract class Disposable {
  void dispose();
}

class SimpleBloc implements Disposable {
  SimpleBloc._(this._counterController)
      : counter = _counterController.stream.asBroadcastStream() {
    _counter = 0;
  }

  factory SimpleBloc() {
    return SimpleBloc._(StreamController<int>());
  }

  final StreamController<int> _counterController;
  final Stream<int> counter;
  int _counter;

  void dispose() {
    _counterController.close();
  }

  void increment() {
    _counter++;
    _counterController.sink.add(_counter);
  }
}

class BlocProvider<T extends Disposable> extends StatefulWidget {
  BlocProvider({
    Key key,
    @required this.child,
    @required this.bloc,
  }) : super(key: key);

  final T bloc;
  final Widget child;

  @override
  _BlocProviderState<T> createState() => _BlocProviderState<T>();

  static T of<T extends Disposable>(BuildContext context) {
    BlocProvider<T> provider =
        context.findAncestorWidgetOfExactType<BlocProvider<T>>();
    return provider.bloc;
  }
}

class _BlocProviderState<T> extends State<BlocProvider<Disposable>> {
  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
