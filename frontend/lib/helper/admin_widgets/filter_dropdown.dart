import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class FilterDropdown extends StatefulWidget {
  final String hint;
  final List<String> items;
  final Function(String) onChanged;
  final BorderRadius? borderRadius;
final bool? showFilterIcon;
final bool showDefaultIcon;
  const FilterDropdown({
    super.key,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.showFilterIcon,
    this.borderRadius,
    this.showDefaultIcon = false,
  });

  @override
  State<FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  String? selectedValue;
  bool isHover = false;

  IconData getItemIcon(String item) {
    if (item == "All") return Icons.grid_view_rounded;
    if (item == "ADMIN") return Icons.security_rounded;
    if (item == "DOCTOR") return Icons.medical_services_outlined;
    if (item == "VOLUNTEER") return Icons.volunteer_activism_outlined;
    if (item == "PATIENT") return Icons.person_outline_rounded;
    if (item == "CALL_CENTER") return Icons.headset_mic_outlined;
    if (item == "Active") return Icons.check_circle_outline_rounded;
    if (item == "Inactive") return Icons.cancel_outlined;

    return Icons.filter_alt_outlined;
  }

  Color getItemColor(String item) {
    if (item == "ADMIN") return Colors.blueGrey;
    if (item == "DOCTOR") return Colors.deepPurple;
    if (item == "VOLUNTEER") return Colors.blue;
    if (item == "PATIENT") return Colors.pink;
    if (item == "CALL_CENTER") return Colors.orange;
    if (item == "Active") return Colors.green;
    if (item == "Inactive") return Colors.red;

    return buttonColor;
  }

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    final currentText = selectedValue ?? widget.hint;
    final currentColor = getItemColor(selectedValue ?? "All");

    return MouseRegion(
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isHover ? const Color(0xFFFFF3FA) : Colors.white,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(18),
          border: Border.all(
            color: isHover
                ? buttonColor.withOpacity(0.45)
                : Colors.grey.withOpacity(0.16),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isHover ? 0.07 : 0.035),
              blurRadius: isHover ? 18 : 10,
              offset: Offset(0, isHover ? 8 : 4),
            ),
          ],
        ),

        child: Theme(
          data: Theme.of(context).copyWith(
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
          ),

          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              menuWidth: w * 0.135,
              value: selectedValue,
              isExpanded: true,
              dropdownColor: Colors.white,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(22),
              menuMaxHeight: 360,

              icon: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: currentColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: currentColor,
                  size: 22,
                ),
              ),

              hint: Row(
                children: [
                  if (widget.showFilterIcon != false)
                    Icon(
                      Icons.filter_alt_outlined,
                      color: buttonColor,
                      size: w * 0.012,
                    ),

                  SizedBox(width: w * 0.008),

                  Expanded(
                    child: customText(
                      text: currentText,
                      size: w * 0.0085,
                      color: const Color(0xFF272044),
                      bold: true,
                      isEnglish: true,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),

              selectedItemBuilder: (context) {
                return widget.items.map((item) {
                  final color = getItemColor(item);

                  return Row(
                    children: [
                     widget.showDefaultIcon ?Icon(getItemIcon(item), color: color, size: w * 0.012): SizedBox.shrink() ,

                      SizedBox(width: w * 0.008),

                      Expanded(
                        child: customText(
                          text: item,
                          size: w * 0.0085,
                          color: const Color(0xFF272044),
                          bold: true,
                          isEnglish: true,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },

              items: widget.items.map((item) {
                final isSelected = selectedValue == item;
                final color = getItemColor(item);

                return DropdownMenuItem(
                  value: item,

                  child: Container(
                    width: double.infinity,
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 14),

                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: Row(
                      children: [
                        widget.showDefaultIcon ?
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            getItemIcon(item),
                            color: color,
                            size: w * 0.012,
                          ),
                        ) : SizedBox.shrink(),

                        SizedBox(width: w * 0.008),

                        Expanded(
                          child: customText(
                            text: item,
                            size: w * 0.0085,
                            color: isSelected ? color : const Color(0xFF272044),
                            bold: true,
                            isEnglish: true,
                            maxLines: 1,
                          ),
                        ),

                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isSelected ? color : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            size: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),

              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedValue = value;
                });

                widget.onChanged(value);
              },
            ),
          ),
        ),
      ),
    );
  }
}
