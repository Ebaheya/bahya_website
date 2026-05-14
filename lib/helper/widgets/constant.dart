import 'dart:ui';

import 'package:flutter/material.dart';

Color textColor = const Color(0xFF831843);
List<Color> gradientColors = const [Color(0xFF8A2BE2), Color(0xFFFF69B4)];
Color iconColor = Color(0xFFE91E63);
Color buttonColor = Color(0xFFFF7BB0);
get getScreenWidth =>
    (BuildContext context) => MediaQuery.of(context).size.width;

get getScreenHeight =>
    (BuildContext context) => MediaQuery.of(context).size.height;
