import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class FilterDropdown extends StatefulWidget {
  final String hint;
  final List<String> items;
  final Function(String) onChanged;
  final BorderRadius? borderRadius;

  const FilterDropdown({
    super.key,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.borderRadius,
  });

  @override
  State<FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: widget.borderRadius ?? BorderRadius.circular(24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          dropdownColor: Colors.white,
          mouseCursor: SystemMouseCursors.click,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(24),
          hint: customText(
            text: widget.hint,
            size: getScreenWidth(context) * 0.008,
            isEnglish: true,
          ),
          icon: const Icon(Icons.arrow_drop_down),
          items: widget.items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: customText(
                text: item,
                size: getScreenWidth(context) * 0.008,
                isEnglish: true,
              ),
            );
          }).toList(),

          onChanged: (value) {
            setState(() {
              selectedValue = value;
            });
            widget.onChanged(value!);
          },
        ),
      ),
    );
  }
}
