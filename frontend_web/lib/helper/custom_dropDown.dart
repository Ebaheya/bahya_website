import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

Widget customDropdown({
  required BuildContext context,
  required String? value,
  required String hint,
  required List<String> items,
  required IconData icon,
  required ValueChanged<String?> onChanged,
}) {
  final dropdownItems = items
      .where((item) => item.trim().isNotEmpty)
      .toSet()
      .toList();
  final safeValue = dropdownItems.where((item) => item == value).length == 1
      ? value
      : null;

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
        value: safeValue,
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
                text: localizedText(context, hint),
                size: responsiveSize(context, 0.0075, min: 12, max: 14),
                color: Colors.black38,
                isCenter: true,
                maxLines: 1,
              ),
            ),
          ],
        ),

        selectedItemBuilder: (context) {
          return dropdownItems.map((e) {
            return Center(
              child: customText(
                text: localizedText(context, e),
                size: responsiveSize(context, 0.0075, min: 12, max: 14),
                bold: true,
                color: const Color(0xFF2B2B2B),
                isCenter: true,
                maxLines: 1,
              ),
            );
          }).toList();
        },

        items: dropdownItems.map((e) {
          return DropdownMenuItem<String>(
            alignment: Alignment.center,
            value: e,
            child: Center(
              child: customText(
                text: localizedText(context, e),
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
