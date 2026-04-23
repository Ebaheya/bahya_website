import 'package:bahya_website/helper/widgets/volunteer_patients_widgets.dart';
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
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFFCEFFE),
      appBar: customAppBar(
        context: context,
        title: "ملء استبيانات المرضى",
        isHomeBar: false,
      ),
      body: Center(
        child: Container(
          width: w * 0.95,
          padding: const EdgeInsets.all(20),
          child: isMobile
              ? Column(
                  children: [
                    PatientsListWidget(
                      selectedPatient: selectedPatient,
                      completedPatients: completedPatients,
                      onSelect: (p) => setState(() => selectedPatient = p),
                    ),
                    const SizedBox(height: 20),
                    Expanded(child: _formContainer()),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _formContainer()),
                    const SizedBox(width: 30),
                    PatientsListWidget(
                      selectedPatient: selectedPatient,
                      completedPatients: completedPatients,
                      onSelect: (p) => setState(() => selectedPatient = p),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _formContainer() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 6),
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
