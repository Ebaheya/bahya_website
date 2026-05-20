import 'package:flutter/material.dart';

class CustomSearchBarWithFilter extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onSearchTap;

  const CustomSearchBarWithFilter({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.onFilterTap,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFFC1D9), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onSearchTap,
              child: Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEF5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFFEA4C89),
                  size: 24,
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: w * 0.035,
                    fontFamily: 'ArabicCustomFont',
                  ),
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: w * 0.038,
                  fontFamily: 'ArabicCustomFont',
                ),
              ),
            ),

            const SizedBox(width: 10),

            GestureDetector(
              onTap: onFilterTap,
              child: Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEF5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.filter_alt_outlined,
                  color: Color(0xFFEA4C89),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
