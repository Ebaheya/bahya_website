import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

Widget customDropdown({
  required BuildContext context,
  required String? value,
  required String hint,
  required List<String> items,
  required IconData icon,
  required ValueChanged<String?> onChanged,
}) {

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFF2C9E0)),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        borderRadius: BorderRadius.circular(16),
        dropdownColor: Colors.white,
        hint: Row(
          children: [
            Icon(icon, color: const Color(0xFF7B1FA2), size: 22),
           Spacer(),
            customText(text: hint, size: responsiveSize(context, 0.0075, min: 12, max: 14), color: Colors.black38),
          ],
        ),
        selectedItemBuilder: (context) {
          return items.map((e) {
            return Center(
              child: customText(
                text: e,
                size: responsiveSize(context, 0.0075, min: 12, max: 14),
                bold: true,
                color: const Color(0xFF2B2B2B),
              ),
            );
          }).toList();
        },
        items: items.map((e) {
          return DropdownMenuItem<String>(
            alignment: Alignment.centerRight,
            value: e,
            child: customText(
              text: e,
              size: responsiveSize(context, 0.0075, min: 12, max: 14),
              color: const Color(0xFF2B2B2B),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}
