import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/screens/admin/add_category.dart';
import 'package:flutter/material.dart';

Widget showAllButton({
  required String text,
  required VoidCallback onTap,
  required double width,
}) {
  return Align(
    alignment: Alignment.centerLeft,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Color(0xFFF6E8F8),
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
  final List<IconData> icons;
  final List<Color> colors;
  final int selectedIcon;
  final int selectedColor;
  final bool showAllIcons;
  final ValueChanged<int> onIconSelected;
  final VoidCallback onToggleShowAll;
  final double width;

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

  @override
  Widget build(BuildContext context) {
    final visibleIcons = showAllIcons ? icons : icons.take(8).toList();

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
          customText(
            text: "اختار الأيقونة",
            size: width * 0.05,
            color: Colors.black,
          ),
          const SizedBox(height: 12),
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            child: GridView.builder(
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
          ),
          const SizedBox(height: 14),
          showAllButton(
            text: showAllIcons ? "عرض أقل" : "عرض الكل",
            onTap: onToggleShowAll,
            width: width,
          ),
        ],
      ),
    );
  }
}

class ColorPickerSection extends StatelessWidget {
  final List<Color> colors;
  final int selectedColor;
  final bool showAllColors;
  final ValueChanged<int> onColorSelected;
  final VoidCallback onToggleShowAll;
  final double width;

  const ColorPickerSection({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.showAllColors,
    required this.onColorSelected,
    required this.onToggleShowAll,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final visibleColors = showAllColors ? colors : colors.take(8).toList();

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
          customText(
            text: "اختار لون الأيقونة",
            size: width * 0.05,
            color: Colors.black,
          ),
          const SizedBox(height: 16),
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            child: GridView.builder(
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
          ),
          const SizedBox(height: 8),
          showAllButton(
            text: showAllColors ? "عرض أقل" : "عرض الكل",
            onTap: onToggleShowAll,
            width: width,
          ),
        ],
      ),
    );
  }
}

class AvailableCategoriesSection extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final bool showAllCategories;
  final VoidCallback onToggleShowAll;
  final double w;
  final double h;
  const AvailableCategoriesSection({
    super.key,
    required this.categories,
    required this.showAllCategories,
    required this.onToggleShowAll,
    required this.w,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    final visibleCategories = showAllCategories
        ? categories
        : categories.take(6).toList();
    return Container(
      padding: EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black12.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              customText(
                text: "الكاتيجوريز المتاحة",
                size: w * 0.05,
                color: Colors.black,
              ),
              showAllButton(
                text: showAllCategories ? "عرض أقل" : "عرض الكل",
                onTap: onToggleShowAll,
                width: w,
              ),
            ],
          ),

          SizedBox(height: h * 0.02),

          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            child: GridView.builder(
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

                return GestureDetector(
                  onTap: () {
                    showCategoryServicesSheet(
                      context: context,
                      categoryTitle: item['title'],
                      categoryIcon: item['icon'],
                      categoryColor: item['color'],
                      services: [
                        {
                          "title": "محو أمية مستوى ثالث",
                          "location": "الرياض - حي العليا",
                          "seats": "20 مقعد",
                          "date": "20-10-2026",
                          "time": "AM 10:00",
                          "isTravel": false,
                          "isSupport": false,
                        },
                        {
                          "title": "رحلة دعم للمرضى",
                          "location": "جدة - مركز الرحمة",
                          "seats": "10 مقاعد",
                          "date": "22-10-2026",
                          "time": "PM 02:00",
                          "isTravel": false,
                          "isSupport": true,
                        },
                        {
                          "title": "رحلة مواصلات مجانية",
                          "location": "الدمام - المحطة الرئيسية",
                          "seats": "14 مقعد",
                          "date": "24-10-2026",
                          "time": "PM 06:00",
                          "isTravel": true,
                          "isSupport": false,
                        },
                      ],
                      w: w,
                      h: h,
                    );
                  },
                  child: Container(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: item['color'].withOpacity(0.12),
                          child: Icon(
                            item['icon'],
                            color: item['color'],
                            size: 20,
                          ),
                        ),
                        Expanded(
                          child: customText(
                            text: item['title'],
                            size: w * 0.033,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void showCategoryServicesSheet({
  required BuildContext context,
  required String categoryTitle,
  required IconData categoryIcon,
  required Color categoryColor,
  required List<Map<String, dynamic>> services,
  required double w,
  required double h,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              padding: EdgeInsets.all(w * 0.045),
              decoration: const BoxDecoration(
                color: Color(0xFFFDF7FC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Container(
                    width: w * 0.14,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  SizedBox(height: h * 0.02),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: categoryColor.withOpacity(0.13),
                        child: Icon(
                          categoryIcon,
                          color: categoryColor,
                          size: w * 0.075,
                        ),
                      ),
                      SizedBox(width: 5),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          customText(
                            text: categoryTitle,
                            size: w * 0.052,
                            color: Colors.black,
                          ),
                          customText(
                            text: "${services.length} خدمات متاحة",
                            size: w * 0.033,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 15),

                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];

                        return registeredServiceTile(
                          w: w,
                          h: h,
                          title: service["title"],
                          location: service["location"],
                          seats: service["seats"],
                          date: service["date"],
                          time: service["time"],
                          isTravel: service["isTravel"],
                          isSupport: service["isSupport"],
                          onMoreTap: () {},
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
