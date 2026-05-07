import 'package:bahya_website/helper/admin_widgets/filter_dropdown.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:flutter/material.dart';

class AddStaffDialog extends StatefulWidget {
  const AddStaffDialog({super.key});
  @override
  State<AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends State<AddStaffDialog> {
  final List<String> roles = [
    "Admin",
    "Doctor",
    "Volunteer",
  ];
  String? selectedRole;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomFormTextField(
                hintText: "Full Name",
                autovalidateMode:
                    AutovalidateMode.onUserInteraction,
                keyboardType: CustomTextFieldType.text,
                labelText: 'Full Name',
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: CustomFormTextField(
                hintText: "Email",
                autovalidateMode:
                    AutovalidateMode.onUserInteraction,
                keyboardType: CustomTextFieldType.email,
                labelText: 'Email',
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: CustomFormTextField(
                hintText: "Password",
                autovalidateMode:
                    AutovalidateMode.onUserInteraction,
                keyboardType: CustomTextFieldType.text,
                labelText: 'Password',
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: FilterDropdown(
                borderRadius: BorderRadius.circular(8),
                hint: "Select Role",
                items: roles,
                onChanged: (v) {
                  setState(() {
                    selectedRole = v;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}