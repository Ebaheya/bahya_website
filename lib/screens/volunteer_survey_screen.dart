import 'package:bahya_website/helper/widgets/volunteer/patients_list.dart';
import 'package:bahya_website/helper/widgets/volunteer/volunteer_patients_widgets.dart';
import 'package:flutter/material.dart';
import '../helper/base.dart';
import '../helper/strings.dart';

class VolunteerPatientsScreen extends StatefulWidget {
  const VolunteerPatientsScreen({super.key});

  @override
  State<VolunteerPatientsScreen> createState() =>
      _VolunteerPatientsScreenState();
}

class _VolunteerPatientsScreenState extends State<VolunteerPatientsScreen> {
  String selectedPatient = "أسماء محمد";
  Set<String> completedPatients = {};

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    final isMobile = w < 700;
    final isTablet = w >= 700 && w < 1100;

    final pagePadding = responsiveSize(
      context,
      isMobile ? 0.018 : 0.025,
      min: isMobile ? 8 : 10,
      max: isMobile ? 14 : 24,
    );

    final gap = responsiveSize(
      context,
      isMobile ? 0.018 : 0.024,
      min: isMobile ? 10 : 12,
      max: isMobile ? 16 : 30,
    );

    final formPadding = responsiveSize(
      context,
      isMobile ? 0.018 : 0.03,
      min: isMobile ? 10 : 14,
      max: isMobile ? 16 : 30,
    );

    final radius = responsiveSize(
      context,
      isMobile ? 0.045 : 0.026,
      min: isMobile ? 18 : 18,
      max: isMobile ? 22 : 26,
    );

    final patientsHeight = responsiveHeight(
      context,
      isMobile ? 0.34 : 0.70,
      min: isMobile ? 400 : 500,
      max: isMobile ? 600 : h,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFCEFFE),
      appBar: customAppBar(
        context: context,
        title: "ملء استبيانات المرضى",
        isHomeBar: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SizedBox(
                width: isMobile ? w : w * 0.95,
                height: constraints.maxHeight,
                child: Padding(
                  padding: EdgeInsets.all(pagePadding),
                  child: isMobile
                      ? Column(
                          children: [
                            SizedBox(
                              height: patientsHeight,
                              child: PatientsListWidget(
                                selectedPatient: selectedPatient,
                                completedPatients: completedPatients,

                                onSelect: (p) {
                                  setState(() => selectedPatient = p);
                                },
                              ),
                            ),
                            SizedBox(height: gap),
                            Expanded(
                              child: _formContainer(
                                padding: formPadding,
                                radius: radius,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: isTablet ? 2 : 3,
                              child: _formContainer(
                                padding: formPadding,
                                radius: radius,
                              ),
                            ),
                            SizedBox(width: gap),
                            SizedBox(
                              width: isTablet ? w * 0.32 : w * 0.24,
                              height: constraints.maxHeight,
                              child: PatientsListWidget(
                                selectedPatient: selectedPatient,
                                completedPatients: completedPatients,
                           
                                onSelect: (p) {
                                  setState(() => selectedPatient = p);
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _formContainer({required double padding, required double radius}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A004C).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: VolunteerSurveyWidget(
        formData: anxietyForm,
        onSave: () {
          setState(() {
            completedPatients.add(selectedPatient);
          });
        },
      ),
    );
  }
}
