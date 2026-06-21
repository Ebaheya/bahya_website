import 'dart:ui';

import 'package:flutter/material.dart';

Color textColor = const Color(0xFF831843);
List<Color> gradientColors = const [Color(0xFF8A2BE2), Color(0xFFFF69B4)];
Color iconColor = Color(0xFFE91E63);
Color buttonColor = Color(0xFFFF7BB0);
Color? backgroundColor = const Color(0xFFFFF7FD);
Color? salesBackgroundColor = Colors.deepPurple;
get getScreenWidth =>
    (BuildContext context) => MediaQuery.of(context).size.width;

get getScreenHeight =>
    (BuildContext context) => MediaQuery.of(context).size.height;

double responsiveSize(
  BuildContext context,
  double factor, {
  double min = 10,
  double max = 24,
}) {
  final width = getScreenWidth(context);
  return (width * factor).clamp(min, max);
}

double responsiveHeight(
  BuildContext context,
  double factor, {
  double min = 8,
  double max = 80,
}) {
  final height = getScreenHeight(context);
  return (height * factor).clamp(min, max);
}
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

final List<Map<String, dynamic>> categoryIconOptions = [
  {'key': 'shopping_bag', 'icon': Icons.shopping_bag_outlined},
  {'key': 'bus', 'icon': Icons.directions_bus_rounded},
  {'key': 'support', 'icon': Icons.groups_rounded},
  {'key': 'home', 'icon': Icons.home_outlined},
  {'key': 'fitness', 'icon': Icons.fitness_center_rounded},
  {'key': 'heart', 'icon': Icons.favorite_border_rounded},
  {'key': 'school', 'icon': Icons.school_outlined},
  {'key': 'restaurant', 'icon': Icons.restaurant_rounded},
  {'key': 'more', 'icon': Icons.more_horiz_rounded},
  {'key': 'gaming', 'icon': Icons.sports_esports_rounded},
  {'key': 'trip', 'icon': Icons.beach_access_rounded},
  {'key': 'business', 'icon': Icons.business_center_outlined},
  {'key': 'laundry', 'icon': Icons.local_laundry_service_outlined},
  {'key': 'pets', 'icon': Icons.pets_rounded},
  {'key': 'cleaning', 'icon': Icons.cleaning_services_rounded},
  {'key': 'medical', 'icon': Icons.medical_services_outlined},
  {'key': 'tools', 'icon': Icons.build_rounded},
  {'key': 'child', 'icon': Icons.child_care_rounded},
];

Color colorFromHex(String hex) {
  final value = hex.replaceAll('#', '');
  final parsed = int.tryParse('FF$value', radix: 16);
  return Color(parsed ?? 0xFFE7549B);
}

IconData iconFromKey(String key) {
  switch (key) {
    case 'shopping_bag':
      return Icons.shopping_bag_outlined;
    case 'bus':
      return Icons.directions_bus_rounded;
    case 'support':
      return Icons.groups_rounded;
    case 'home':
      return Icons.home_outlined;
    case 'fitness':
      return Icons.fitness_center_rounded;
    case 'heart':
      return Icons.favorite_border_rounded;
    case 'school':
      return Icons.school_outlined;
    case 'restaurant':
      return Icons.restaurant_rounded;
    case 'more':
      return Icons.more_horiz_rounded;
    case 'gaming':
      return Icons.sports_esports_rounded;
    case 'trip':
      return Icons.beach_access_rounded;
    case 'business':
      return Icons.business_center_outlined;
    case 'laundry':
      return Icons.local_laundry_service_outlined;
    case 'pets':
      return Icons.pets_rounded;
    case 'cleaning':
      return Icons.cleaning_services_rounded;
    case 'medical':
      return Icons.medical_services_outlined;
    case 'tools':
      return Icons.build_rounded;
    case 'child':
      return Icons.child_care_rounded;
    default:
      return Icons.category_outlined;
  }
}
