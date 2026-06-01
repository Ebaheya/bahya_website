import 'package:bahya_website/helper/admin_widgets/filter_dropdown.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class AddStaffDialog extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController fullNameController;
  final Function(String) onChanged;

  const AddStaffDialog({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.fullNameController,
    required this.onChanged,
  });

  @override
  State<AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends State<AddStaffDialog> {
  final List<String> roles = ["ADMIN", "DOCTOR", "VOLUNTEER", "CALL_CENTER"];

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;

    return Column(
      children: [
        _ResponsiveFieldRow(
          isMobile: isMobile,
          children: [
            modernStaffInputBox(
              context: context,
              icon: Icons.person_outline_rounded,
              child: CustomFormTextField(
                controller: widget.fullNameController,
                hintText: "Full Name",
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: CustomTextFieldType.text,
                textDirection: TextDirection.ltr,
                isRequired: true,
              ),
            ),
            modernStaffInputBox(
              context: context,
              icon: Icons.email_outlined,
              child: CustomFormTextField(
                controller: widget.emailController,
                hintText: "Email",
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: CustomTextFieldType.email,
                textDirection: TextDirection.ltr,
                isRequired: true,
              ),
            ),
          ],
        ),
        _ResponsiveFieldRow(
          isMobile: isMobile,
          addBottomSpace: false,
          children: [
            modernStaffInputBox(
              context: context,
              icon: Icons.lock_outline_rounded,
              child: CustomFormTextField(
                controller: widget.passwordController,
                hintText: "Password",
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: CustomTextFieldType.password,
                obscureText: true,
                textDirection: TextDirection.ltr,
                isRequired: true,
              ),
            ),
            modernStaffInputBox(
              context: context,
              icon: Icons.badge_outlined,
              isPurple: true,
              child: FilterDropdown(
                showFilterIcon: false,
                borderRadius: BorderRadius.circular(
                  responsiveSize(context, 0.012, min: 14, max: 16),
                ),
                hint: "Select Role",
                items: roles,
                onChanged: widget.onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Widget modernStaffInputBox({
  required BuildContext context,
  required IconData icon,
  required Widget child,
  bool isPurple = false,
}) {
  final color = isPurple ? Colors.deepPurple : buttonColor;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 220),
    curve: Curves.easeOutCubic,
    height: responsiveHeight(context, 0.072, min: 54, max: 62),
    padding: EdgeInsets.symmetric(
      horizontal: responsiveSize(context, 0.011, min: 12, max: 14),
    ),
    decoration: BoxDecoration(
      color: isPurple ? Colors.deepPurple.withOpacity(0.035) : Colors.white,
      borderRadius: BorderRadius.circular(
        responsiveSize(context, 0.014, min: 15, max: 18),
      ),
      border: Border.all(color: Colors.grey.withOpacity(0.14)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.035),
          blurRadius: responsiveSize(context, 0.012, min: 10, max: 14),
          offset: Offset(0, responsiveHeight(context, 0.008, min: 5, max: 7)),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: responsiveSize(context, 0.034, min: 36, max: 42),
          height: responsiveSize(context, 0.034, min: 36, max: 42),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.01, min: 11, max: 13),
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: responsiveSize(context, 0.017, min: 19, max: 22),
          ),
        ),
        SizedBox(width: responsiveSize(context, 0.01, min: 10, max: 12)),
        Expanded(child: child),
      ],
    ),
  );
}

class _ResponsiveFieldRow extends StatelessWidget {
  final bool isMobile;
  final List<Widget> children;
  final bool addBottomSpace;

  const _ResponsiveFieldRow({
    required this.isMobile,
    required this.children,
    this.addBottomSpace = true,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = responsiveHeight(context, 0.022, min: 16, max: 22);

    final content = isMobile
        ? Column(
            children: [
              children[0],
              SizedBox(height: spacing),
              children[1],
            ],
          )
        : Row(
            children: [
              Expanded(child: children[0]),
              SizedBox(width: responsiveSize(context, 0.018, min: 16, max: 24)),
              Expanded(child: children[1]),
            ],
          );

    return Padding(
      padding: EdgeInsets.only(bottom: addBottomSpace ? spacing : 0),
      child: content,
    );
  }
}
