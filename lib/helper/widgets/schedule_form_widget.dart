import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget scheduleLabel({required BuildContext context, required String title}) {
  final h = getScreenHeight(context);

  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Color(0xFFE5007D),
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 8),
      customText(
        text: title,
        size: h * 0.022,
        bold: true,
        color: const Color(0xFF2B2B2B),
      ),
    ],
  );
}

Widget scheduleDropdown({
  required BuildContext context,
  required String? value,
  required String hint,
  required List<String> items,
  required IconData icon,
  required ValueChanged<String?> onChanged,
}) {
  final h = getScreenHeight(context);

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
            const SizedBox(width: 10),
            customText(text: hint, size: h * 0.018, color: Colors.black38),
          ],
        ),
        selectedItemBuilder: (context) {
          return items.map((e) {
            return Center(
              child: customText(
                text: e,
                size: h * 0.019,
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
              size: h * 0.019,
              color: const Color(0xFF2B2B2B),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

Widget schedulePickerField({
  required BuildContext context,
  required String text,
  required IconData icon,
  required VoidCallback onTap,
}) {
  final h = getScreenHeight(context);

  return InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: onTap,
    child: Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2C9E0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7B1FA2)),
          const Spacer(),
          customText(text: text, size: h * 0.018, color: Colors.black45),
        ],
      ),
    ),
  );
}

Widget scheduleSingleLineInput({
  required BuildContext context,
  required TextEditingController controller,
  required String hint,
  required IconData icon,
}) {
  final w = getScreenWidth(context);
  final h = getScreenHeight(context);
  return Container(
    height: h * 0.045,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFF2C9E0)),
    ),
    child: Center(
      child: CustomFormTextField(
        bordered: false,
        isRequired: false,
        showInlineError: false,
        autovalidateMode: AutovalidateMode.disabled,
        keyboardType: CustomTextFieldType.number,
        controller: controller,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.purple, size: w * 0.013),
      ),
    ),
  );
}

Widget scheduleCodeInputSection({
  required BuildContext context,
  required String title,
  bool showAddButton = true,
  required String hint,
  required TextEditingController controller,
  required List<String> codes,
  required VoidCallback onAdd,
  required void Function(String code) onRemove,
}) {
  final h = getScreenHeight(context);
  final w = getScreenWidth(context);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      scheduleLabel(context: context, title: title),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: scheduleSingleLineInput(
              context: context,
              controller: controller,
              hint: hint,
              icon: Icons.badge_outlined,
            ),
          ),
          const SizedBox(width: 16),
if (showAddButton) ...[
            const SizedBox(width: 16),
            CustomGlowButton(
              title: "إضافة",
              onPressed: onAdd,
              icon: Icons.add_rounded,
              textColor: Colors.white,
              backgroundColor: Colors.pinkAccent,
              glowColor: Colors.pinkAccent.withOpacity(0.6),
              width: w * 0.2,
            ),
          ],
        ],
      ),
      if (codes.isNotEmpty) ...[
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: codes.map((code) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFBCD4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  customText(
                    text: code,
                    size: h * 0.017,
                    bold: true,
                    color: const Color(0xFF7B1FA2),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => onRemove(code),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFFE5007D),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    ],
  );
}
