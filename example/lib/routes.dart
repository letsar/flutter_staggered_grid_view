import 'package:example/home.dart';
import 'package:flutter/material.dart';

const String homeRoute = '/';

const String staggeredGridViewCountRoute = 'staggered_grid_view_count';
const String staggeredGridViewExtentRoute = 'staggered_grid_view_extent';

const String spannableGridViewCountRoute = 'spannable_grid_view_count';
const String spannableGridViewExtentRoute = 'spannable_grid_view_extent';

Map<String, WidgetBuilder> routes = <String, WidgetBuilder> {
  homeRoute : (BuildContext context) => new Home(),
};