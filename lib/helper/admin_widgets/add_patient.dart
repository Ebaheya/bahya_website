import 'package:bahya_website/helper/admin_widgets/filter_dropdown.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/widgets/custom_date_picker.dart';
import 'package:flutter/material.dart';

class AddPatientDialog extends StatefulWidget {
  const AddPatientDialog({super.key});

  @override
  State<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<AddPatientDialog> {
  String? selectedGender;
  final List<String> genders = ["Male", "Female"];
  DateTime? selectedDate;
  final TextEditingController dateController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomFormTextField(
                hintText: "Full Name",
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: CustomTextFieldType.text,
                labelText: 'Full Name',
              ),
            ),
            const SizedBox(width: 20),

            Expanded(
              child: CustomFormTextField(
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
                hintText: "Password",
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: CustomTextFieldType.text,
                labelText: 'Password',
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: CustomFormTextField(
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
                controller: dateController,
                labelText: "Birth Date",
                hintText: "mm/dd/yyyy",

                onDateSelected: (date) {
                  selectedDate = date;
                },
              ),
            ),
            const SizedBox(width: 20),

            Expanded(
              child: FilterDropdown(
                borderRadius: BorderRadius.circular(8),
                hint: "Gender",
                items: genders,
                onChanged: (v) {
                  setState(() {
                    selectedGender = v;
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        CustomFormTextField(
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
                hintText: "Emergency Contact Name",
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: CustomTextFieldType.text,
                labelText: 'Emergency Contact Name',
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: CustomFormTextField(
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
