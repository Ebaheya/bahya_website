import 'dart:developer';

import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/helper/admin_widgets/add_patient.dart';
import 'package:bahya_website/helper/admin_widgets/add_staff_dialog.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
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

  WebService webService = WebService();

  String? selectedRole;

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

  String? selectedGender;

  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final width = getScreenWidth(context);

    final height = getScreenHeight(context);

    return Dialog(
      backgroundColor: Colors.transparent,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),

        curve: Curves.easeInOut,

        width: width * 0.5,

        constraints: BoxConstraints(maxHeight: height * 0.9),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(20),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            pageHeader(
              width: getScreenWidth(context),

              title: "Add New User",

              widgets: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Divider(color: Colors.grey.shade300),

            const SizedBox(height: 20),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),

                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,

                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isStaff = true;
                                });
                              },

                              child: animatedTab(
                                title: "Staff",

                                active: isStaff,
                              ),
                            ),
                          ),

                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isStaff = false;
                                });
                              },

                              child: animatedTab(
                                title: "Patient",

                                active: !isStaff,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

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

                            child: child,
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

                    const SizedBox(height: 30),

                    Divider(color: Colors.grey.shade300),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: CustomGlowButton(
                            title: "Cancel",

                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: CustomGlowButton(
                            textColor: textColor,

                            isGradient: true,

                            title: isStaff ? "Create Staff" : "Create Patient",

                            onPressed: () async {
                              if (isStaff) {
                                try {
                                  await webService.createStaff(
                                    email: emailController.text,

                                    password: passwordController.text,

                                    fullName: fullNameController.text,

                                    role: selectedRole!,
                                  );

                                  debugPrint("Staff created successfully");
                                  Navigator.pop(context);
                                } catch (e) {
                                  debugPrint("Error creating staff: $e");
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

                                    emergencyContactName:
                                        emergencyNameController.text,

                                    emergencyContactPhone:
                                        emergencyPhoneController.text,
                                  );
                                  debugPrint("Patient created successfully");
                                  Navigator.pop(context);
                                } catch (e) {
                                  debugPrint("Error creating patient: $e");
                                }
                              }
                            },
                          ),
                        ),
                      ],
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

  Widget animatedTab({required String title, required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),

      curve: Curves.easeInOut,

      padding: const EdgeInsets.symmetric(vertical: 14),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),

        gradient: active ? LinearGradient(colors: gradientColors) : null,
      ),

      child: Center(
        child: customText(
          text: title,

          size: getScreenWidth(context) * 0.01,

          color: active ? Colors.white : textColor,
        ),
      ),
    );
  }
}
