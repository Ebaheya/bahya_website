import 'dart:developer';

import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/custom_form_textfield.dart';
import 'package:bahya_app/helper/custom_glow_buttom.dart';
import 'package:bahya_app/helper/widgets/admin/add_category_widgets.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/custom_app_bar.dart';
import 'package:bahya_app/helper/massage_dialog.dart';
import 'package:bahya_app/helper/heart_pull_refresh.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:bahya_app/logic/cubit/service_admin_cubit.dart';
import 'package:bahya_app/logic/state/service_admin_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateCategoryScreen extends StatefulWidget {
  const CreateCategoryScreen({super.key});

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final TextEditingController nameController = TextEditingController();

  int selectedIcon = 0;
  int selectedColor = 0;

  bool showAllIcons = false;
  bool showAllColors = false;
  bool showAllCategories = false;

  String selectedKind = 'OTHER';

  final List<Map<String, dynamic>> kindOptions = const [
    {'label': 'أخرى', 'value': 'OTHER', 'icon': Icons.category_outlined},
    {'label': 'رحلة', 'value': 'TRIP', 'icon': Icons.directions_bus_rounded},
  ];

  String _colorToHex(Color color) {
    final value = color.value.toRadixString(16).padLeft(8, '0');
    return '#${value.substring(2).toUpperCase()}';
  }

  String _iconKeyForIndex(int index) {
    return categoryIconOptions[index]['key'] as String;
  }

  Future<void> _saveCategory() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      customDialog(
        context: context,
        title: 'خطأ',
        message: 'يرجى إدخال اسم الفئة.',
        isError: true,
      );
      return;
    }

    await context.read<ServiceAdminCubit>().createCategory(
      name: name,
      kind: selectedKind,
      iconKey: _iconKeyForIndex(selectedIcon),
      color: _colorToHex(listColors[selectedColor]),
    );

    if (!mounted) return;

    final state = context.read<ServiceAdminCubit>().state;

    customDialog(
      context: context,
      title: state.error == null ? 'تم الحفظ' : 'خطأ',
      message: state.error ?? 'تم حفظ الفئة بنجاح.',
      isSuccess: state.error == null,
      isError: state.error != null,
    );

    log(
      'Created category => name: $name, kind: $selectedKind, iconKey: ${_iconKeyForIndex(selectedIcon)}, color: ${_colorToHex(listColors[selectedColor])}',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    final w = getScreenWidth(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: HeartPullRefreshScrollView(
        onRefresh: () async {
          await context.read<ServiceAdminCubit>().loadDashboard();
        },
        slivers: [
          SliverToBoxAdapter(
            child: Directionality(
              textDirection: context.appTextDirection,
              child: Column(
                children: [
                  customAppBar(
                    context: context,
                    title: 'إضافة فئة جديدة',
                    subTitle: 'اختار الاسم والنوع والأيقونة',
                    isHome: false,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.04,
                      vertical: h * 0.015,
                    ),
                    child: Column(
                      children: [

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.04),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText(
                      text: 'اسم الفئة',
                      size: w * 0.05,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 14),
                    CustomFormTextField(
                      controller: nameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: CustomTextFieldType.text,
                      hintText: 'مثال: دعم نفسي',
                      suffixIcon: const Icon(
                        Icons.sell_outlined,
                        color: Colors.pink,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.025),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.04),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText(
                      text: 'نوع الفئة',
                      size: w * 0.05,
                      color: Colors.black,
                      bold: true,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: kindOptions.map((kind) {
                        final isSelected = selectedKind == kind['value'];

                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedKind = kind['value'] as String;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              padding: EdgeInsets.symmetric(
                                vertical: h * 0.018,
                                horizontal: w * 0.02,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.pink.withOpacity(0.12)
                                    : Colors.grey.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.pink
                                      : Colors.grey.withOpacity(0.2),
                                  width: isSelected ? 1.4 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    kind['icon'] as IconData,
                                    color: isSelected
                                        ? Colors.pink
                                        : Colors.grey.shade600,
                                    size: w * 0.075,
                                  ),
                                  SizedBox(height: h * 0.008),
                                  customText(
                                    text: kind['label'] as String,
                                    size: w * 0.035,
                                    color: isSelected
                                        ? Colors.pink
                                        : Colors.grey.shade700,
                                    bold: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (selectedKind == 'TRIP') ...[
                      const SizedBox(height: 12),
                      customText(
                        text:
                            'ملاحظة: نوع الرحلة سيطلب بيانات إضافية عند إنشاء الخدمة مثل مكان التجمع ووقت التحرك وتاريخ الرجوع.',
                        size: w * 0.032,
                        color: Colors.grey.shade700,
                        maxLines: 3,
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: h * 0.025),

              IconPickerSection(
                icons: categoryIconOptions
                    .map((e) => e['icon'] as IconData)
                    .toList(),
                colors: listColors,
                selectedIcon: selectedIcon,
                selectedColor: selectedColor,
                showAllIcons: showAllIcons,
                width: w,
                onIconSelected: (index) {
                  setState(() => selectedIcon = index);
                },
                onToggleShowAll: () {
                  setState(() => showAllIcons = !showAllIcons);
                },
              ),

              SizedBox(height: h * 0.025),

              ColorPickerSection(
                colors: listColors,
                selectedColor: selectedColor,
                showAllColors: showAllColors,
                width: w,
                onColorSelected: (index) {
                  setState(() => selectedColor = index);
                },
                onToggleShowAll: () {
                  setState(() => showAllColors = !showAllColors);
                },
              ),

              SizedBox(height: h * 0.025),

              BlocBuilder<ServiceAdminCubit, ServiceAdminState>(
                builder: (context, state) {
                  return AvailableCategoriesSection(
                    categories: state.categories,
                    showAllCategories: showAllCategories,
                    w: w,
                    h: h,
                    onToggleShowAll: () {
                      setState(() => showAllCategories = !showAllCategories);
                    },
                  );
                },
              ),

              SizedBox(height: h * 0.03),

              BlocBuilder<ServiceAdminCubit, ServiceAdminState>(
                builder: (context, state) {
                  return CustomGlowButton(
                    title: state.isSaving ? 'جاري الحفظ...' : 'حفظ الفئة',
                    onPressed: state.isSaving ? () {} : _saveCategory,
                    isGradient: true,
                    width: double.infinity,
                    height: h * 0.07,
                    borderRadius: 25,
                  );
                },
              ),

                        SizedBox(height: h * 0.03),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
