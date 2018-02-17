import 'package:example/home.dart';
import 'package:example/spannable_count_extent_page.dart';
import 'package:example/spannable_count_ratio_page.dart';
import 'package:example/spannable_extent_extent_page.dart';
import 'package:example/spannable_extent_ratio_page.dart';
import 'package:example/staggered_count_extent_page.dart';
import 'package:example/staggered_count_ratio_page.dart';
import 'package:example/staggered_extent_extent_page.dart';
import 'package:example/staggered_extent_ratio_page.dart';
import 'package:flutter/material.dart';

const String homeRoute = '/';

const String staggeredCountRatioRoute = 'staggered_count_ratio';
const String staggeredExtentRatioRoute = 'staggered_extent_ratio';
const String staggeredCountExtentRoute = 'staggered_count_extent';
const String staggeredExtentExtentRoute = 'staggered_extent_extent';

const String spannableCountRatioRoute = 'spannable_count_ratio';
const String spannableExtentRatioRoute = 'spannable_extent_ratio';
const String spannableCountExtentRoute = 'spannable_count_extent';
const String spannableExtentExtentRoute = 'spannable_extent_extent';

Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  homeRoute: (BuildContext context) => new Home(),
  staggeredCountRatioRoute: (BuildContext context) =>
      new StaggeredCountRatioPage(),
  staggeredExtentRatioRoute: (BuildContext context) =>
      new StaggeredExtentRatioPage(),
  staggeredCountExtentRoute: (BuildContext context) =>
      new StaggeredCountExtentPage(),
  staggeredExtentExtentRoute: (BuildContext context) =>
      new StaggeredExtentExtentPage(),
  spannableCountRatioRoute: (BuildContext context) =>
      new SpannableCountRatioPage(),
  spannableExtentRatioRoute: (BuildContext context) =>
      new SpannableExtentRatioPage(),
  spannableCountExtentRoute: (BuildContext context) =>
      new SpannableCountExtentPage(),
  spannableExtentExtentRoute: (BuildContext context) =>
      new SpannableExtentExtentPage(),
};
