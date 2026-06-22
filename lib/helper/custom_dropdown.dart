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
  required void Function(String?) onChanged,
}) {
  final dropdownItems = items
      .where((item) => item.trim().isNotEmpty)
      .toSet()
      .toList();

  final safeValue = dropdownItems.where((item) => item == value).length == 1
      ? value
      : null;

  final active = safeValue != null;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 220),
    curve: Curves.easeOut,
    padding: EdgeInsets.all(responsiveSize(context, 0.004, min: 4, max: 6)),
    decoration: BoxDecoration(
      color: const Color(0xFFFEFBFD),
      borderRadius: BorderRadius.circular(
        responsiveSize(context, 0.014, min: 16, max: 22),
      ),
      border: Border.all(
        color: active
            ? const Color(0xFFE7549B).withValues(alpha: 0.42)
            : const Color(0xFFE7549B).withValues(alpha: 0.12),
        width: active ? 1.4 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(
            0xFFE7549B,
          ).withValues(alpha: active ? 0.08 : 0.035),
          blurRadius: responsiveSize(context, 0.012, min: 10, max: 18),
          offset: Offset(0, responsiveHeight(context, 0.006, min: 4, max: 8)),
        ),
      ],
    ),
    child: Container(
      height: responsiveHeight(context, 0.055, min: 44, max: 52),
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.010, min: 10, max: 14),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.010, min: 12, max: 16),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isExpanded: true,
          alignment: Alignment.center,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.016, min: 18, max: 22),
          ),
          menuMaxHeight: responsiveHeight(context, 0.42, min: 260, max: 360),
          icon: _CustomDropdownArrow(active: active),
          hint: _CustomDropdownSelectedContent(
            text: localizedText(context, hint),
            icon: icon,
            isHint: true,
          ),
          selectedItemBuilder: (context) {
            return dropdownItems.map((item) {
              return _CustomDropdownSelectedContent(
                text: localizedText(context, item),
                icon: icon,
                isHint: false,
              );
            }).toList();
          },
          items: dropdownItems.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              alignment: Alignment.center,
              child: _CustomDropdownMenuItem(
                text: localizedText(context, item),
                selected: item == safeValue,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    ),
  );
}

class _CustomDropdownArrow extends StatelessWidget {
  final bool active;

  const _CustomDropdownArrow({required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFFE7549B) : const Color(0xFF8A0057);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: responsiveSize(context, 0.022, min: 28, max: 34),
      height: responsiveSize(context, 0.022, min: 28, max: 34),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.008, min: 8, max: 10),
        ),
      ),
      child: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: color,
        size: responsiveSize(context, 0.016, min: 19, max: 22),
      ),
    );
  }
}

class _CustomDropdownSelectedContent extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isHint;

  const _CustomDropdownSelectedContent({
    required this.text,
    required this.icon,
    required this.isHint,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: isHint ? const Color(0xFF7B1FA2) : const Color(0xFFE7549B),
          size: responsiveSize(context, 0.012, min: 16, max: 20),
        ),
        SizedBox(width: responsiveSize(context, 0.008, min: 8, max: 12)),
        Expanded(
          child: customText(
            text: text,
            size: responsiveSize(context, 0.0085, min: 12, max: 15),
            color: isHint ? Colors.grey.shade500 : const Color(0xFF272044),
            bold: !isHint,
            maxLines: 1,
            isCenter: false,
          ),
        ),
      ],
    );
  }
}

class _CustomDropdownMenuItem extends StatelessWidget {
  final String text;
  final bool selected;

  const _CustomDropdownMenuItem({required this.text, required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      height: responsiveHeight(context, 0.058, min: 46, max: 52),
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.011, min: 12, max: 14),
      ),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFE7549B).withValues(alpha: 0.07)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.012, min: 12, max: 14),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: customText(
              text: text,
              size: responsiveSize(context, 0.0085, min: 12, max: 15),
              color: selected
                  ? const Color(0xFFE7549B)
                  : const Color(0xFF272044),
              bold: true,
              maxLines: 1,
              isCenter: false,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: responsiveSize(context, 0.018, min: 22, max: 24),
            height: responsiveSize(context, 0.018, min: 22, max: 24),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFE7549B) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: selected ? Colors.white : Colors.transparent,
              size: responsiveSize(context, 0.011, min: 13, max: 15),
            ),
          ),
        ],
      ),
    );
  }
}
