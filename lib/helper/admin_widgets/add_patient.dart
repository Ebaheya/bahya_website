import 'package:bahya_website/helper/admin_widgets/filter_dropdown.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
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
              child: CustomFormTextField(
                controller: widget.fullNameController,

                hintText: "Full Name",

                autovalidateMode: AutovalidateMode.onUserInteraction,

                keyboardType: CustomTextFieldType.text,

                labelText: 'Full Name',
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: CustomFormTextField(
                controller: widget.emailController,

                textDirection: TextDirection.ltr,

                hintText: "Email",

                autovalidateMode: AutovalidateMode.onUserInteraction,

                keyboardType: CustomTextFieldType.email,

                labelText: 'Email',
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: CustomFormTextField(
                controller: widget.passwordController,

                hintText: "Password",

                autovalidateMode: AutovalidateMode.onUserInteraction,

                keyboardType: CustomTextFieldType.text,

                labelText: 'Password',
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: CustomFormTextField(
                controller: widget.phoneController,

                hintText: "Phone Number",

                autovalidateMode: AutovalidateMode.onUserInteraction,

                keyboardType: CustomTextFieldType.phone,

                labelText: 'Phone Number',
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: CustomDatePickerField(
                controller: widget.birthDateController,

                labelText: "Birth Date",

                hintText: "mm/dd/yyyy",

                onDateSelected: widget.onDateSelected,
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: FilterDropdown(
              

                borderRadius: BorderRadius.circular(8),

                hint: "Gender",

                items: genders,

                onChanged: widget.onGenderChanged,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        CustomFormTextField(
          controller: widget.addressController,

          hintText: "Address",

          autovalidateMode: AutovalidateMode.onUserInteraction,

          keyboardType: CustomTextFieldType.text,

          labelText: 'Address',

          maxLines: 3,
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: CustomFormTextField(
                controller: widget.emergencyNameController,

                hintText: "Emergency Contact Name",

                autovalidateMode: AutovalidateMode.onUserInteraction,

                keyboardType: CustomTextFieldType.text,

                labelText: 'Emergency Contact Name',
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: CustomFormTextField(
                controller: widget.emergencyPhoneController,

                hintText: "Emergency Contact Phone",

                autovalidateMode: AutovalidateMode.onUserInteraction,

                keyboardType: CustomTextFieldType.phone,

                labelText: 'Emergency Contact Phone',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
