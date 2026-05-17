import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/widgets/constant.dart';
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
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12),

      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple[300]!, width: 1.5),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          dropdownColor: Colors.white,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(24),
          hint: customText(
            text: widget.hint,
            size: getScreenWidth(context) * 0.04,
            isEnglish: true,
            color: Colors.grey[500],
            bold: false,
          ),
          icon: const Icon(Icons.arrow_drop_down),
          items: widget.items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Align(
                alignment: Alignment.centerRight,
                child: customText(
                  text: item,
                  size: getScreenWidth(context) * 0.04,
                  isEnglish: true,
                ),
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
