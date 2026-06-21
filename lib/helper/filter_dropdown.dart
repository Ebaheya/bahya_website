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
    if (item == "Pending") return Icons.watch_later_outlined;
    if (item == "Investigating") return Icons.manage_search_rounded;
    if (item == "Completed") return Icons.check_circle_outline_rounded;

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
    if (item == "Pending") return Colors.purple;
    if (item == "Investigating") return Colors.blue;
    if (item == "Completed") return Colors.green;

    return buttonColor;
  }

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final isMobile = w < 650;
    final dropdownItems = widget.items
        .where((item) => item.trim().isNotEmpty)
        .toSet()
        .toList();
    final safeSelectedValue =
        dropdownItems.where((item) => item == selectedValue).length == 1
        ? selectedValue
        : null;

    final currentText = safeSelectedValue ?? widget.hint;
    final currentColor = getItemColor(safeSelectedValue ?? "All");

    return MouseRegion(
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: isHover ? 1.01 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: responsiveHeight(context, 0.06, min: 46, max: 54),
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.011, min: 12, max: 14),
          ),
          decoration: BoxDecoration(
            color: isHover ? const Color(0xFFFFF3FA) : Colors.white,
            borderRadius:
                widget.borderRadius ??
                BorderRadius.circular(
                  responsiveSize(context, 0.014, min: 14, max: 18),
                ),
            border: Border.all(
              color: isHover
                  ? buttonColor.withValues(alpha: 0.45)
                  : Colors.grey.withValues(alpha: 0.16),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isHover ? 0.07 : 0.035),
                blurRadius: responsiveSize(
                  context,
                  isHover ? 0.014 : 0.01,
                  min: 10,
                  max: 18,
                ),
                offset: Offset(
                  0,
                  responsiveHeight(
                    context,
                    isHover ? 0.009 : 0.005,
                    min: 4,
                    max: 8,
                  ),
                ),
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
                menuWidth: isMobile
                    ? (w * 0.78).clamp(240.0, 330.0)
                    : (w * 0.16).clamp(180.0, 260.0),
                value: safeSelectedValue,
                isExpanded: true,
                dropdownColor: Colors.white,
                borderRadius:
                    widget.borderRadius ??
                    BorderRadius.circular(
                      responsiveSize(context, 0.016, min: 18, max: 22),
                    ),
                menuMaxHeight: responsiveHeight(
                  context,
                  0.42,
                  min: 260,
                  max: 360,
                ),
                icon: _DropdownArrow(color: currentColor),
                hint: _DropdownSelectedContent(
                  text: currentText,
                  color: currentColor,
                  icon: Icons.filter_alt_outlined,
                  showIcon: widget.showFilterIcon != false,
                  showDefaultIcon: false,
                ),
                selectedItemBuilder: (context) {
                  return dropdownItems.map((item) {
                    final color = getItemColor(item);

                    return _DropdownSelectedContent(
                      text: item,
                      color: color,
                      icon: getItemIcon(item),
                      showIcon: widget.showDefaultIcon,
                      showDefaultIcon: widget.showDefaultIcon,
                    );
                  }).toList();
                },
                items: dropdownItems.map((item) {
                  final isSelected = safeSelectedValue == item;
                  final color = getItemColor(item);

                  return DropdownMenuItem(
                    value: item,
                    child: _DropdownMenuItemContent(
                      item: item,
                      color: color,
                      icon: getItemIcon(item),
                      isSelected: isSelected,
                      showDefaultIcon: widget.showDefaultIcon,
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
      ),
    );
  }
}

class _DropdownArrow extends StatelessWidget {
  final Color color;

  const _DropdownArrow({required this.color});

  @override
  Widget build(BuildContext context) {
    final size = responsiveSize(context, 0.024, min: 28, max: 32);

    return Container(
      width: size,
      height: size,
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

class _DropdownSelectedContent extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  final bool showIcon;
  final bool showDefaultIcon;

  const _DropdownSelectedContent({
    required this.text,
    required this.color,
    required this.icon,
    required this.showIcon,
    required this.showDefaultIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showIcon)
          Icon(
            icon,
            color: showDefaultIcon ? color : buttonColor,
            size: responsiveSize(context, 0.012, min: 16, max: 20),
          ),
        if (showIcon)
          SizedBox(width: responsiveSize(context, 0.008, min: 8, max: 12)),
        Expanded(
          child: customText(
            text: text,
            size: responsiveSize(context, 0.0085, min: 12, max: 15),
            color: const Color(0xFF272044),
            bold: true,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

class _DropdownMenuItemContent extends StatelessWidget {
  final String item;
  final Color color;
  final IconData icon;
  final bool isSelected;
  final bool showDefaultIcon;

  const _DropdownMenuItemContent({
    required this.item,
    required this.color,
    required this.icon,
    required this.isSelected,
    required this.showDefaultIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: responsiveHeight(context, 0.058, min: 46, max: 52),
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.011, min: 12, max: 14),
      ),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.012, min: 12, max: 14),
        ),
      ),
      child: Row(
        children: [
          if (showDefaultIcon)
            Container(
              width: responsiveSize(context, 0.03, min: 32, max: 36),
              height: responsiveSize(context, 0.03, min: 32, max: 36),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(
                  responsiveSize(context, 0.01, min: 10, max: 12),
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: responsiveSize(context, 0.012, min: 16, max: 20),
              ),
            ),
          if (showDefaultIcon)
            SizedBox(width: responsiveSize(context, 0.008, min: 8, max: 12)),
          Expanded(
            child: customText(
              text: item,
              size: responsiveSize(context, 0.0085, min: 12, max: 15),
              color: isSelected ? color : const Color(0xFF272044),
              bold: true,
              isEnglish: true,
              maxLines: 1,
              isCenter: false,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: responsiveSize(context, 0.018, min: 22, max: 24),
            height: responsiveSize(context, 0.018, min: 22, max: 24),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: isSelected ? Colors.white : Colors.transparent,
              size: responsiveSize(context, 0.011, min: 13, max: 15),
            ),
          ),
        ],
      ),
    );
  }
}
