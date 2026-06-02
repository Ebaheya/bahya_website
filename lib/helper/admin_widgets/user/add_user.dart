import 'dart:developer';

import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/helper/admin_widgets/user/add_patient.dart';
import 'package:bahya_website/helper/admin_widgets/user/add_staff_dialog.dart';
import 'package:bahya_website/helper/admin_widgets/user/add_user_widgets.dart';
import 'package:bahya_website/helper/admin_widgets/page_header.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog>
    with TickerProviderStateMixin {
  bool isStaff = true;

  final WebService webService = WebService();

  String? selectedRole;
  String? selectedGender;
  DateTime? selectedDate;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();

  final TextEditingController patientFullNameController =
      TextEditingController();
  final TextEditingController patientEmailController = TextEditingController();
  final TextEditingController patientPasswordController =
      TextEditingController();
  final TextEditingController patientPhoneController = TextEditingController();
  final TextEditingController patientBirthDateController =
      TextEditingController();
  final TextEditingController patientAddressController =
      TextEditingController();
  final TextEditingController emergencyNameController = TextEditingController();
  final TextEditingController emergencyPhoneController =
      TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();

    patientFullNameController.dispose();
    patientEmailController.dispose();
    patientPasswordController.dispose();
    patientPhoneController.dispose();
    patientBirthDateController.dispose();
    patientAddressController.dispose();
    emergencyNameController.dispose();
    emergencyPhoneController.dispose();

    super.dispose();
  }

  Future<void> createUser() async {
    if (isStaff) {
      try {
        await webService.createStaff(
          email: emailController.text,
          password: passwordController.text,
          fullName: fullNameController.text,
          role: selectedRole!,
        );

        if (!mounted) return;

        customDialog(
          context: context,
          title: "Done",
          message: "Staff created successfully",
          onClose: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
      } catch (e) {
        if (!mounted) return;

        customDialog(
          context: context,
          title: "Error",
          message: "Failed to create staff: $e",
          onClose: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
      }
    } else {
      try {
        await webService.createPatient(
          fullName: patientFullNameController.text,
          email: patientEmailController.text,
          password: patientPasswordController.text,
          phone: patientPhoneController.text,
          dateOfBirth:
              "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
          gender: selectedGender ?? '',
          address: patientAddressController.text,
          emergencyContactName: emergencyNameController.text,
          emergencyContactPhone: emergencyPhoneController.text,
        );

        if (!mounted) return;

        customDialog(
          context: context,
          title: "Done",
          message: "Patient created successfully",
          onClose: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
      } catch (e) {
        if (!mounted) return;

        customDialog(
          context: context,
          title: "Error",
          message: "Failed to create patient: $e",
          onClose: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = getScreenWidth(context);
    final height = getScreenHeight(context);
    final isMobile = width < 650;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.02, min: 12, max: 40),
        vertical: responsiveHeight(context, 0.025, min: 14, max: 30),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        width: isMobile ? width * 0.94 : (width * 0.5).clamp(520.0, 760.0),
        constraints: BoxConstraints(maxHeight: height * 0.92),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.018, min: 18, max: 24),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            pageHeader(
              context: context,
              icon: Icons.add_rounded,
              title: "Add New User",
              widgets: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: responsiveSize(context, 0.016, min: 20, max: 26),
                  ),
                ),
              ],
            ),

            SizedBox(height: responsiveHeight(context, 0.012, min: 8, max: 12)),

            Divider(color: Colors.grey.shade300, height: 1),

            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(
                  responsiveSize(context, 0.014, min: 14, max: 20),
                ),
                child: Column(
                  children: [
                    AddUserTabs(
                      isStaff: isStaff,
                      onStaffTap: () {
                        setState(() {
                          isStaff = true;
                        });
                      },
                      onPatientTap: () {
                        setState(() {
                          isStaff = false;
                        });
                      },
                    ),

                    SizedBox(
                      height: responsiveHeight(
                        context,
                        0.024,
                        min: 16,
                        max: 24,
                      ),
                    ),

                    AnimatedSize(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.03),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: isStaff
                            ? AddStaffDialog(
                                key: const ValueKey('staff'),
                                emailController: emailController,
                                passwordController: passwordController,
                                fullNameController: fullNameController,
                                onChanged: (v) {
                                  setState(() {
                                    selectedRole = v;
                                  });

                                  log("Selected role: $v");
                                },
                              )
                            : AddPatientDialog(
                                key: const ValueKey('patient'),
                                fullNameController: patientFullNameController,
                                emailController: patientEmailController,
                                passwordController: patientPasswordController,
                                phoneController: patientPhoneController,
                                birthDateController: patientBirthDateController,
                                addressController: patientAddressController,
                                emergencyNameController:
                                    emergencyNameController,
                                emergencyPhoneController:
                                    emergencyPhoneController,
                                selectedGender: selectedGender,
                                onGenderChanged: (v) {
                                  setState(() {
                                    selectedGender = v;
                                  });
                                },
                                onDateSelected: (date) {
                                  selectedDate = date;
                                },
                              ),
                      ),
                    ),

                    SizedBox(
                      height: responsiveHeight(context, 0.02, min: 14, max: 20),
                    ),

                    Divider(color: Colors.grey.shade300),

                    SizedBox(
                      height: responsiveHeight(
                        context,
                        0.018,
                        min: 12,
                        max: 18,
                      ),
                    ),

                    AddUserActions(
                      isStaff: isStaff,
                      onCancel: () => Navigator.pop(context),
                      onCreate: createUser,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
