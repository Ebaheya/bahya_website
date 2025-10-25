import 'package:flutter/material.dart';

// double getScreenWidth(BuildContext context) {
//   return MediaQuery.of(context).size.width;
// }
// double getScreenHeight(BuildContext context) {
//   return MediaQuery.of(context).size.height;
// }
get getScreenWidth =>
    (BuildContext context) => MediaQuery.of(context).size.width;

get getScreenHeight =>
    (BuildContext context) => MediaQuery.of(context).size.height;

Color? backgroundColor = Colors.grey[200];
Color? salesBackgroundColor = Colors.deepPurple;
