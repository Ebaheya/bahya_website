import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/custom_form_textfield.dart';
import 'package:bahya_app/helper/custom_glow_buttom.dart';
import 'package:bahya_app/helper/widgets/add_category.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    final w = getScreenWidth(context);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: backgroundColor,
      appBar: customAppBar(
        context: context,
        title: "إضافة كاتيجوري جديد",
        subTitle: "اختار الاسم والأيقونة",
        isHome: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.04,
          vertical: h * 0.015,
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              const SizedBox(height: 130),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
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
                      text: "اسم الكاتيجوري",
                      size: w * 0.05,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 14),
                    CustomFormTextField(
                      controller: nameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: CustomTextFieldType.text,
                      hintText: "مثال: صيانة المنزل",
                      suffixIcon: const Icon(
                        Icons.sell_outlined,
                        color: Colors.pink,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.025),

              IconPickerSection(
                icons: listIcons,
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

              AvailableCategoriesSection(
                categories: listOfCategories,
                showAllCategories: showAllCategories,
                w: w,
                h: h,
                onToggleShowAll: () {
                  setState(() => showAllCategories = !showAllCategories);
                },
              ),

              SizedBox(height: h * 0.03),

              CustomGlowButton(
                title: "حفظ الكاتيجوري",
                onPressed: () {},
                isGradient: true,
                width: double.infinity,
                height: h * 0.07,
                borderRadius: 25,
              ),

              SizedBox(height: h * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
