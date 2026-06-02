import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class AddUserTabs extends StatelessWidget {
  final bool isStaff;
  final VoidCallback onStaffTap;
  final VoidCallback onPatientTap;

  const AddUserTabs({
    super.key,
    required this.isStaff,
    required this.onStaffTap,
    required this.onPatientTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(responsiveSize(context, 0.006, min: 5, max: 7)),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.014, min: 14, max: 18),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onStaffTap,
              child: AddUserAnimatedTab(title: "Staff", active: isStaff),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onPatientTap,
              child: AddUserAnimatedTab(title: "Patient", active: !isStaff),
            ),
          ),
        ],
      ),
    );
  }
}

class AddUserAnimatedTab extends StatelessWidget {
  final String title;
  final bool active;

  const AddUserAnimatedTab({
    super.key,
    required this.title,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(
        vertical: responsiveHeight(context, 0.018, min: 12, max: 15),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.012, min: 12, max: 16),
        ),
        gradient: active ? LinearGradient(colors: gradientColors) : null,
        boxShadow: active
            ? [
                BoxShadow(
                  color: buttonColor.withOpacity(0.18),
                  blurRadius: responsiveSize(context, 0.012, min: 10, max: 16),
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Center(
        child: customText(
          text: title,
          size: responsiveSize(context, 0.01, min: 13, max: 16),
          color: active ? Colors.white : textColor,
          bold: true,
          isEnglish: true,
        ),
      ),
    );
  }
}

class AddUserActions extends StatelessWidget {
  final bool isStaff;
  final VoidCallback onCancel;
  final VoidCallback onCreate;

  const AddUserActions({
    super.key,
    required this.isStaff,
    required this.onCancel,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;

    if (isMobile) {
      return Column(
        children: [
          CustomGlowButton(
            textColor: textColor,
            isGradient: true,
            title: isStaff ? "Create Staff" : "Create Patient",
            onPressed: onCreate,
            width: double.infinity,
            height: responsiveHeight(context, 0.055, min: 44, max: 52),
            textSize: responsiveSize(context, 0.009, min: 13, max: 16),
          ),
          SizedBox(height: responsiveHeight(context, 0.014, min: 10, max: 14)),
          CustomGlowButton(
            title: "Cancel",
            onPressed: onCancel,
            width: double.infinity,
            height: responsiveHeight(context, 0.055, min: 44, max: 52),
            textSize: responsiveSize(context, 0.009, min: 13, max: 16),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: CustomGlowButton(
            title: "Cancel",
            onPressed: onCancel,
            height: responsiveHeight(context, 0.055, min: 44, max: 52),
            textSize: responsiveSize(context, 0.009, min: 13, max: 16),
          ),
        ),
        SizedBox(width: responsiveSize(context, 0.016, min: 16, max: 22)),
        Expanded(
          child: CustomGlowButton(
            
            isGradient: true,
            title: isStaff ? "Create Staff" : "Create Patient",
            onPressed: onCreate,
            height: responsiveHeight(context, 0.055, min: 44, max: 52),
            textSize: responsiveSize(context, 0.009, min: 13, max: 16),
          ),
        ),
      ],
    );
  }
}
