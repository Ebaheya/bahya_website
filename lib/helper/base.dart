import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Widget arabicText({
  required String text,
  required double size,
  Color? color,
  bool bold = true,
}) {
  return Center(
    child: Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontFamily: 'CustomArabic',
        color: color,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
      textDirection: TextDirection.rtl,
    ),
  );
}

String webProxy(String url) =>
    'https://images.weserv.nl/?url=${Uri.encodeComponent(url)}'; // CORS OK
Widget netImg(String url) {
  final proxied = kIsWeb ? webProxy(url) : url;
  return Image.network(
    proxied,
    width: 50,
    height: 50,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => Image.asset(
      'assets/images/placeholder.png',
      width: 50,
      height: 50,
      fit: BoxFit.cover,
    ),
  );
}
