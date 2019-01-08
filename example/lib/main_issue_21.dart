import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class DeviceTypeList {
  String deviceTypeName = 'test';
}

class DeviceTypeItem extends StatefulWidget {
  final List<DeviceTypeList> deviceTypes;
  final Function onSelected;

  DeviceTypeItem(this.deviceTypes, this.onSelected);

  @override
  _DeviceTypeItemState createState() => _DeviceTypeItemState();
}

class _DeviceTypeItemState extends State<DeviceTypeItem> {
  int _selectIndex = -1;

  _DeviceTypeItemState();

  _selectDevice(int index) {
    setState(() {
      _selectIndex = index;
    });
//    onSelected(deviceTypes[_selectIndex].deviceTypeName);
  }

  _tmpData() {
    return List.generate(
        10,
        (int index) => GestureDetector(
              child: Container(
                child: Text(widget.deviceTypes[0].deviceTypeName),
                color: _selectIndex == index ? Colors.blue : Colors.brown,
                padding: EdgeInsets.only(top: 4, bottom: 4),
                alignment: Alignment.center,
              ),
              onTap: () => _selectDevice(index),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
//      child: GridView.count(
//        crossAxisCount: 3,
//        children: _tmpData(),
//        shrinkWrap: true,
//      ),

      child: StaggeredGridView.count(
        crossAxisCount: 3,
        children: _tmpData(),
        staggeredTiles: List.generate(10, (int index) => StaggeredTile.fit(1)),
        shrinkWrap: true,
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'StaggeredGridView Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyScreen(),
//     );
//   }
// }

// class MyScreen extends StatefulWidget {
//   @override
//   _MyScreenState createState() => new _MyScreenState();
// }

// class _MyScreenState extends State<MyScreen> {
//   int _count = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GridTest(_count, _count),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.add),
//         onPressed: () {
//           setState(() {
//             _count++;
//           });
//         },
//       ),
//     );
//   }
// }

// class GridTest extends StatelessWidget {
//   GridTest(this.count, this.value);
//   final int count;
//   final int value;

//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         crossAxisSpacing: 2,
//         mainAxisSpacing: 2,
//       ),
//       itemCount: count,
//       itemBuilder: (context, index) {
//         return Container(
//           color: Colors.blue,
//           child: Text('$value'),
//         );
//       },
//     );
//   }
// }

// class StaggeredTest extends StatelessWidget {
//   StaggeredTest(this.count, this.value);
//   final int count;
//   final int value;

//   @override
//   Widget build(BuildContext context) {
//     return StaggeredGridView.countBuilder(
//       itemCount: count,
//       crossAxisCount: 3,
//       crossAxisSpacing: 2,
//       mainAxisSpacing: 2,
//       addAutomaticKeepAlives: false,
//       staggeredTileBuilder: (index) => StaggeredTile.extent(1, 30),
//       itemBuilder: (context, index) {
//         return Container(
//           color: Colors.green,
//           child: Text('$value'),
//         );
//       },
//     );
//   }
// }
