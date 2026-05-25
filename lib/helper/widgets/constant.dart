import 'dart:ui';

import 'package:flutter/material.dart';

Color textColor = const Color(0xFF831843);
List<Color> gradientColors = const [Color(0xFF8A2BE2), Color(0xFFFF69B4)];
Color iconColor = Color(0xFFE91E63);
Color buttonColor = Color(0xFFFF7BB0);
Color? backgroundColor = Colors.grey[200];
Color? salesBackgroundColor = Colors.deepPurple;
get getScreenWidth =>
    (BuildContext context) => MediaQuery.of(context).size.width;

get getScreenHeight =>
    (BuildContext context) => MediaQuery.of(context).size.height;
final List<IconData> listIcons = [
  Icons.home_outlined,
  Icons.groups_rounded,
  Icons.directions_car_filled_outlined,
  Icons.shopping_bag_outlined,
  Icons.restaurant_outlined,
  Icons.school_outlined,
  Icons.favorite_border,
  Icons.fitness_center,
  Icons.work_outline_rounded,
  Icons.flight_takeoff_rounded,
  Icons.sports_esports_outlined,
  Icons.more_horiz_rounded,
  Icons.local_hospital_outlined,
  Icons.cleaning_services_outlined,
  Icons.pets_outlined,
  Icons.local_laundry_service_outlined,
  Icons.child_care_outlined,
  Icons.build_outlined,
];

final List<Color> listColors = [
  Color(0xFFFF4FA3),
  Color(0xFF9333EA),
  Color(0xFF3B82F6),
  Color(0xFF14B8A6),
  Color(0xFF6CCB4F),
  Color(0xFFFF9800),
  Color(0xFFFF5C8A),
  Color(0xFFE91E63),
  Color(0xFF9C27B0),
  Color(0xFF673AB7),
  Color(0xFF2196F3),
  Color(0xFF00BCD4),
  Color(0xFF009688),
  Color(0xFF4CAF50),
  Color(0xFF8BC34A),
  Color(0xFFFFC107),
  Color(0xFFFF5722),
  Color(0xFF795548),
  Color(0xFF607D8B),
  Color(0xFF000000),
];

final List<Map<String, dynamic>> listOfCategories = [
  {
    "title": "صيانة المنزل",
    "icon": Icons.home_outlined,
    "color": Color(0xFFFF4FA3),
  },
  {
    "title": "العائلة",
    "icon": Icons.groups_rounded,
    "color": Color(0xFF9333EA),
  },
  {
    "title": "المواصلات",
    "icon": Icons.directions_car_filled_outlined,
    "color": Color(0xFF3B82F6),
  },
  {
    "title": "التسوق",
    "icon": Icons.shopping_bag_outlined,
    "color": Color(0xFF6CCB4F),
  },
  {
    "title": "المطاعم",
    "icon": Icons.restaurant_outlined,
    "color": Color(0xFFFF9800),
  },
  {
    "title": "التعليم",
    "icon": Icons.school_outlined,
    "color": Color(0xFF9333EA),
  },
  {"title": "الصحة", "icon": Icons.favorite_border, "color": Color(0xFFFF5C8A)},
  {
    "title": "الرياضة",
    "icon": Icons.fitness_center,
    "color": Color(0xFF14B8A6),
  },
  {
    "title": "السفر",
    "icon": Icons.flight_takeoff_rounded,
    "color": Color(0xFF9C27B0),
  },
  {
    "title": "العمل",
    "icon": Icons.work_outline_rounded,
    "color": Color(0xFF3B82F6),
  },
];
