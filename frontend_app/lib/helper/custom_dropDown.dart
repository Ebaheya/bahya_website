import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
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
    height: responsiveHeight(context, 0.065, min: 48, max: 58),
    padding: EdgeInsets.symmetric(
      horizontal: responsiveSize(context, 0.012, min: 14, max: 18),
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(
        responsiveSize(context, 0.014, min: 14, max: 16),
      ),
      border: Border.all(color: const Color(0xFFF2C9E0)),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        alignment: Alignment.center,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.014, min: 14, max: 16),
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.black54,
        ),

        hint: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                icon,
                color: const Color(0xFF7B1FA2),
                size: responsiveSize(context, 0.014, min: 18, max: 22),
              ),
            ),
            Center(
              child: customText(
                text: hint,
                size: responsiveSize(context, 0.0075, min: 12, max: 14),
                color: Colors.black38,
                isCenter: true,
                maxLines: 1,
              ),
            ),
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
                isCenter: true,
                maxLines: 1,
              ),
            );
          }).toList();
        },

        items: items.map((e) {
          return DropdownMenuItem<String>(
            alignment: Alignment.center,
            value: e,
            child: Center(
              child: customText(
                text: e,
                size: responsiveSize(context, 0.0075, min: 12, max: 14),
                color: const Color(0xFF2B2B2B),
                isCenter: true,
              ),
            ),
          );
        }).toList(),

        onChanged: onChanged,
      ),
    ),
  );
}
