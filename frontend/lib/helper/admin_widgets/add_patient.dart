import 'package:bahya_website/helper/admin_widgets/filter_dropdown.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/custom_date_picker.dart';
import 'package:flutter/material.dart';

class AddPatientDialog extends StatefulWidget {
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController phoneController;
  final TextEditingController birthDateController;
  final TextEditingController addressController;
  final TextEditingController emergencyNameController;
  final TextEditingController emergencyPhoneController;

  final String? selectedGender;
  final Function(String?) onGenderChanged;
  final Function(DateTime)? onDateSelected;

  const AddPatientDialog({
    super.key,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.phoneController,
    required this.birthDateController,
    required this.addressController,
    required this.emergencyNameController,
    required this.emergencyPhoneController,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.onDateSelected,
  });

  @override
  State<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<AddPatientDialog> {
  final List<String> genders = ["MALE", "FEMALE"];

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
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: modernInputBox(
                icon: Icons.phone_outlined,
                child: CustomFormTextField(
                  controller: widget.phoneController,
                  hintText: "Phone Number",
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: CustomTextFieldType.phone,
                  textDirection: TextDirection.ltr,
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
                icon: Icons.calendar_month_outlined,
                child: CustomDatePickerField(
                  controller: widget.birthDateController,
                  hintText: "Birth Date",
                showCalendarIcon: false,
                initialDate: DateTime.now(),
                  onDateSelected: widget.onDateSelected,
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: modernInputBox(
                icon: Icons.filter_alt_outlined,
                isPurple: true,
                child: FilterDropdown(
                  borderRadius: BorderRadius.circular(16),
                  hint: "Gender",
                  showFilterIcon: false,
                  items: genders,
                  onChanged: widget.onGenderChanged,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        modernInputBox(
          icon: Icons.location_on_outlined,
          child: CustomFormTextField(
            controller: widget.addressController,
            hintText: "Address",
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: CustomTextFieldType.text,
            textDirection: TextDirection.ltr,
            maxLines: 1,
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: modernInputBox(
                icon: Icons.person_outline_rounded,
                child: CustomFormTextField(
                  controller: widget.emergencyNameController,
                  hintText: "Emergency Contact Name",
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: CustomTextFieldType.text,
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: modernInputBox(
                icon: Icons.phone_outlined,
                child: CustomFormTextField(
                  controller: widget.emergencyPhoneController,
                  hintText: "Emergency Contact Phone",
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: CustomTextFieldType.phone,
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget modernInputBox({
    required IconData icon,
    required Widget child,
    bool isPurple = false,
  }) {
    final color = isPurple ? Colors.deepPurple : buttonColor;

    return Container(
      height: 62,
      padding: const EdgeInsets.only(left: 14, right: 14),
      decoration: BoxDecoration(
        color: isPurple ? Colors.deepPurple.withOpacity(0.035) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}
