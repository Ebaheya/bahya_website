import 'package:bahya_website/helper/filter_dropdown.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:bahya_website/helper/admin_widgets/custom_date_picker.dart';
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
  final TextEditingController crnController;
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
    required this.crnController,
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
    final isMobile = getScreenWidth(context) < 650;

    return Column(
      children: [
        modernInputBox(
          context: context,
          icon: Icons.badge_outlined,
          child: CustomFormTextField(
            controller: widget.crnController,
            hintText: localizedText(context, 'CRN'),
            bordered: false,
           
            keyboardType: CustomTextFieldType.text,
            textDirection: TextDirection.ltr,
          ),
        ),
        SizedBox(height: responsiveHeight(context, 0.022, min: 16, max: 22)),
        _ResponsiveFieldRow(
          isMobile: isMobile,
          children: [
            modernInputBox(
              context: context,
              icon: Icons.person_outline_rounded,
              child: CustomFormTextField(
                controller: widget.fullNameController,
                hintText: localizedText(context, 'Full Name'),
                bordered: false,
               
                keyboardType: CustomTextFieldType.text,
                textDirection: TextDirection.ltr,
              ),
            ),
            modernInputBox(
              context: context,
              icon: Icons.email_outlined,
              child: CustomFormTextField(
                controller: widget.emailController,
                hintText: localizedText(context, 'Email'),
                bordered: false,
               
                keyboardType: CustomTextFieldType.email,
                textDirection: TextDirection.ltr,
              ),
            ),
          ],
        ),

        _ResponsiveFieldRow(
          isMobile: isMobile,
          children: [
            modernInputBox(
              context: context,
              icon: Icons.lock_outline_rounded,
              child: CustomFormTextField(
                controller: widget.passwordController,
                hintText: localizedText(context, 'Password'),
                bordered: false,
               
                keyboardType: CustomTextFieldType.password,
                obscureText: true,
                textDirection: TextDirection.ltr,
              ),
            ),
            modernInputBox(
              context: context,
              icon: Icons.phone_outlined,
              child: CustomFormTextField(
                bordered: false,
                controller: widget.phoneController,
                hintText: localizedText(context, 'Phone Number'),
               
                keyboardType: CustomTextFieldType.phone,
                textDirection: TextDirection.ltr,
              ),
            ),
          ],
        ),

        _ResponsiveFieldRow(
          isMobile: isMobile,
          children: [
            modernInputBox(
              context: context,
              icon: Icons.calendar_month_outlined,
              child: CustomDatePickerField(
                controller: widget.birthDateController,
                hintText: localizedText(context, 'Birth Date'),
                showCalendarIcon: false,
                initialDate: DateTime.now().subtract(Duration(days: 365 * 20)),
                onDateSelected: widget.onDateSelected,
              ),
            ),
            modernInputBox(
              context: context,
              icon: Icons.filter_alt_outlined,
              isPurple: true,
              child: FilterDropdown(
                borderRadius: BorderRadius.circular(
                  responsiveSize(context, 0.012, min: 14, max: 16),
                ),
                hint: widget.selectedGender ?? "Gender",
                showFilterIcon: false,
                items: genders,
                onChanged: widget.onGenderChanged,
              ),
            ),
          ],
        ),

        Padding(
          padding: EdgeInsets.only(
            bottom: responsiveHeight(context, 0.022, min: 16, max: 22),
          ),
          child: modernInputBox(
            context: context,
            icon: Icons.location_on_outlined,
            child: CustomFormTextField(
              controller: widget.addressController,
              hintText: localizedText(context, 'Address'),
              bordered: false,
             
              keyboardType: CustomTextFieldType.text,
              textDirection: TextDirection.ltr,
              maxLines: 1,
            ),
          ),
        ),

        _ResponsiveFieldRow(
          isMobile: isMobile,
          addBottomSpace: false,
          children: [
            modernInputBox(
              context: context,
              icon: Icons.person_outline_rounded,
              child: CustomFormTextField(
                controller: widget.emergencyNameController,
                hintText: localizedText(context, 'Emergency Contact Name'),
               
                keyboardType: CustomTextFieldType.text,
                textDirection: TextDirection.ltr,
                bordered: false,
              ),
            ),
            modernInputBox(
              context: context,
              icon: Icons.phone_outlined,
              child: CustomFormTextField(
                bordered: false,
                controller: widget.emergencyPhoneController,
                hintText: localizedText(context, 'Emergency Contact Phone'),
               
                keyboardType: CustomTextFieldType.phone,
                textDirection: TextDirection.ltr,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget modernInputBox({
    required BuildContext context,
    required IconData icon,
    required Widget child,
    bool isPurple = false,
  }) {
    final color = isPurple ? Colors.deepPurple : buttonColor;

    return Container(
      height: responsiveHeight(context, 0.072, min: 54, max: 62),
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.011, min: 12, max: 14),
      ),
      decoration: BoxDecoration(
        color: isPurple
            ? Colors.deepPurple.withValues(alpha: 0.035)
            : Colors.white,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.014, min: 15, max: 18),
        ),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
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
              color: color.withValues(alpha: 0.10),
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
