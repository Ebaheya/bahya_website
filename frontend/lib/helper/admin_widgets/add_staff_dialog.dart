import 'package:bahya_website/helper/admin_widgets/filter_dropdown.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: modernInputBox(
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
            ),
            const SizedBox(width: 24),
            Expanded(
              child: modernInputBox(
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
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: modernInputBox(
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
            ),
            const SizedBox(width: 24),
            Expanded(
              child: modernInputBox(
                icon: Icons.badge_outlined,
                child: FilterDropdown(
                  showFilterIcon: false,
                  borderRadius: BorderRadius.circular(16),
                  hint: "Select Role",
                  items: roles,
                  onChanged: widget.onChanged,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

 
}
