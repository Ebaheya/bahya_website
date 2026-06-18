import 'package:bahya_app/data/models/service_models.dart';
import 'package:bahya_app/helper/base.dart';
import 'package:flutter/material.dart';

Widget showAllButton({
  required String text,
  required VoidCallback onTap,
  required double width,
}) {
  return Align(
    alignment: AlignmentDirectional.centerEnd,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF6E8F8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: customText(
          text: text,
          size: width * 0.035,
          color: const Color(0xFFB24ACF),
        ),
      ),
    ),
  );
}

class IconPickerSection extends StatelessWidget {
  const IconPickerSection({
    super.key,
    required this.icons,
    required this.colors,
    required this.selectedIcon,
    required this.selectedColor,
    required this.showAllIcons,
    required this.onIconSelected,
    required this.onToggleShowAll,
    required this.width,
  });

  final List<IconData> icons;
  final List<Color> colors;
  final int selectedIcon;
  final int selectedColor;
  final bool showAllIcons;
  final ValueChanged<int> onIconSelected;
  final VoidCallback onToggleShowAll;
  final double width;

  @override
  Widget build(BuildContext context) {
    final visibleIcons = showAllIcons ? icons : icons.take(8).toList();

    return _PickerCard(
      title: 'اختار الأيقونة',
      width: width,
      child: Column(
        children: [
          GridView.builder(
            padding: EdgeInsets.zero,
            itemCount: visibleIcons.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              final realIndex = icons.indexOf(visibleIcons[index]);
              final isSelected = selectedIcon == realIndex;

              return GestureDetector(
                onTap: () => onIconSelected(realIndex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? colors[selectedColor]
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    visibleIcons[index],
                    size: width * 0.07,
                    color: isSelected
                        ? colors[selectedColor]
                        : Colors.grey.shade400,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          showAllButton(
            text: showAllIcons ? 'عرض أقل' : 'عرض الكل',
            onTap: onToggleShowAll,
            width: width,
          ),
        ],
      ),
    );
  }
}

class ColorPickerSection extends StatelessWidget {
  const ColorPickerSection({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.showAllColors,
    required this.onColorSelected,
    required this.onToggleShowAll,
    required this.width,
  });

  final List<Color> colors;
  final int selectedColor;
  final bool showAllColors;
  final ValueChanged<int> onColorSelected;
  final VoidCallback onToggleShowAll;
  final double width;

  @override
  Widget build(BuildContext context) {
    final visibleColors = showAllColors ? colors : colors.take(8).toList();

    return _PickerCard(
      title: 'اختار لون الأيقونة',
      width: width,
      child: Column(
        children: [
          GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            itemCount: visibleColors.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
            ),
            itemBuilder: (context, index) {
              final realIndex = colors.indexOf(visibleColors[index]);
              final isSelected = selectedColor == realIndex;

              return Center(
                child: GestureDetector(
                  onTap: () => onColorSelected(realIndex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: visibleColors[index],
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: visibleColors[index].withOpacity(0.35),
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: width * 0.06,
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
          showAllButton(
            text: showAllColors ? 'عرض أقل' : 'عرض الكل',
            onTap: onToggleShowAll,
            width: width,
          ),
        ],
      ),
    );
  }
}

class AvailableCategoriesSection extends StatelessWidget {
  const AvailableCategoriesSection({
    super.key,
    required this.categories,
    required this.showAllCategories,
    required this.onToggleShowAll,
    required this.w,
    required this.h,
  });

  final List<ServiceCategoryModel> categories;
  final bool showAllCategories;
  final VoidCallback onToggleShowAll;
  final double w;
  final double h;

  @override
  Widget build(BuildContext context) {
    final visibleCategories = showAllCategories
        ? categories
        : categories.take(6).toList();

    return _PickerCard(
      title: 'الكاتيجوريز المتاحة',
      width: w,
      trailing: showAllButton(
        text: showAllCategories ? 'عرض أقل' : 'عرض الكل',
        onTap: onToggleShowAll,
        width: w,
      ),
      child: visibleCategories.isEmpty
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: h * 0.025),
              child: customText(
                text: 'لا توجد فئات متاحة حالياً',
                size: w * 0.035,
                color: Colors.grey,
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.zero,
              itemCount: visibleCategories.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final item = visibleCategories[index];
                final itemColor = _colorFromHex(item.color);

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: itemColor.withOpacity(0.12),
                        child: Icon(
                          _iconFromKey(item.iconKey),
                          color: itemColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: customText(
                          text: item.name,
                          size: w * 0.033,
                          color: Colors.black,
                          maxLines: 1,
                          isCenter: false,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _PickerCard extends StatelessWidget {
  const _PickerCard({
    required this.title,
    required this.width,
    required this.child,
    this.trailing,
  });

  final String title;
  final double width;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black12.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: customText(
                  text: title,
                  size: width * 0.05,
                  color: Colors.black,
                  isCenter: false,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

IconData _iconFromKey(String key) {
  switch (key) {
    case 'shopping_bag':
      return Icons.shopping_bag_outlined;
    case 'bus':
      return Icons.directions_bus_rounded;
    case 'support':
      return Icons.groups_rounded;
    case 'home':
      return Icons.home_outlined;

    case 'fitness':
      return Icons.fitness_center_rounded;
    case 'heart':
      return Icons.favorite_border_rounded;
    case 'school':
      return Icons.school_outlined;
    case 'restaurant':
      return Icons.restaurant_rounded;

    case 'more':
      return Icons.more_horiz_rounded;
    case 'gaming':
      return Icons.sports_esports_rounded;
    case 'trip':
      return Icons.beach_access_rounded;
    case 'business':
      return Icons.business_center_outlined;

    case 'laundry':
      return Icons.local_laundry_service_outlined;
    case 'pets':
      return Icons.pets_rounded;
    case 'cleaning':
      return Icons.cleaning_services_rounded;
    case 'medical':
      return Icons.medical_services_outlined;

    case 'tools':
      return Icons.build_rounded;
    case 'child':
      return Icons.child_care_rounded;

    default:
      return Icons.category_outlined;
  }
}

Color _colorFromHex(String hex) {
  final value = hex.replaceAll('#', '');
  final parsed = int.tryParse('FF$value', radix: 16);
  return Color(parsed ?? 0xFFE7549B);
}
