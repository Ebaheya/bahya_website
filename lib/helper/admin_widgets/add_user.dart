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

  final List<String> roles = ["DOCTOR", "THERAPIST", "ADMIN"];

  String selectedRole = "DOCTOR";

  final List<String> genders = ["Male", "Female"];

  String selectedGender = "Male";

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
            //////////////////////////////////////////////////////
            /// Header
            //////////////////////////////////////////////////////
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

            //////////////////////////////////////////////////////
            /// Content
            //////////////////////////////////////////////////////
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //////////////////////////////////////////////////
                    /// Toggle Tabs
                    //////////////////////////////////////////////////
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

                    //////////////////////////////////////////////////
                    /// Elegant Animation
                    //////////////////////////////////////////////////
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
                            ? const AddStaffDialog(key: ValueKey('staff'))
                            : const AddPatientDialog(key: ValueKey('patient')),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Divider(color: Colors.grey.shade300),

                    const SizedBox(height: 20),

                    //////////////////////////////////////////////////
                    /// Buttons
                    //////////////////////////////////////////////////
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

                            onPressed: () {
                              // Handle Add User
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
