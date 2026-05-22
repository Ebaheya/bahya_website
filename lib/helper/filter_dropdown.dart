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

  IconData getItemIcon(String item) {
    if (item.contains("تعليمي")) {
      return Icons.school_outlined;
    } else if (item.contains("رحلات")) {
      return Icons.work_outline_rounded;
    } else if (item.contains("الدعم")) {
      return Icons.groups_2_outlined;
    }
    return Icons.grid_view_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(14),
        border: Border.all(color: iconColor, width: 1.3),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,

            isExpanded: true,
            dropdownColor: Colors.white,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(14),

            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF9C27B0),
                size: 22,
              ),
            ),

            hint: Row(
              children: [
                Container(
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.grid_view_rounded,
                    color: Color(0xFF9C27B0),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: customText(
                    text: widget.hint,
                    size: w * 0.036,
                    color: Colors.grey[500],
                    bold: false,
                    isCenter: false,
                    maxLines: 1,
                  ),
                ),
              ],
            ),

            selectedItemBuilder: (context) {
              return widget.items.map((item) {
                return Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C27B0).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        getItemIcon(item),
                        color: const Color(0xFF9C27B0),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: customText(
                        text: item,
                        size: w * 0.036,
                        color: Colors.grey[700],
                        bold: false,
                        isCenter: false,
                        maxLines: 1,
                      ),
                    ),
                  ],
                );
              }).toList();
            },

            items: widget.items.map((item) {
              final isSelected = selectedValue == item;
              return DropdownMenuItem(
                value: item,
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C27B0).withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        getItemIcon(item),
                        color: iconColor,
                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: customText(
                        text: item,
                        size: w * 0.038,
                        color: isSelected ? iconColor : Colors.black87,
                        bold: isSelected,
                        isCenter: false,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: isSelected ? iconColor : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: isSelected ? Colors.white : Colors.transparent,
                        size: 16,
                      ),
                    ),
                  ],
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
      ),
    );
  }
}
