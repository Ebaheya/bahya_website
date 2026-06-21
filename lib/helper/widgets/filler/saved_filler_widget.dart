import 'package:bahya_website/bloc/cubit/doctor_cubit.dart';
import 'package:bahya_website/data/api/models/form_model.dart';
import 'package:bahya_website/data/api/models/options_model.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:bahya_website/helper/widgets/filler/form_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'saved_filler_fields.dart';

class DynamicFormFillerWidget extends StatefulWidget {
  final FormModel? form;
  final List<OptionUserModel> patients;
  final OptionUserModel? selectedPatient;
  final bool isSearchingPatients;
  final bool isSubmitting;

  const DynamicFormFillerWidget({
    super.key,
    required this.form,
    required this.patients,
    required this.selectedPatient,
    required this.isSearchingPatients,
    required this.isSubmitting,
  });

  @override
  State<DynamicFormFillerWidget> createState() =>
      _DynamicFormFillerWidgetState();
}

class _DynamicFormFillerWidgetState extends State<DynamicFormFillerWidget> {
  void _updateState(VoidCallback callback) => setState(callback);

  final TextEditingController patientSearchController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  bool get _isMobile => MediaQuery.sizeOf(context).width < 700;

  @override
  void dispose() {
    patientSearchController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DoctorFormsCubit>().state;
    final cubit = context.read<DoctorFormsCubit>();

    final score = cubit.calculateScore();
    final diagnosis = cubit.calculateDiagnosis();
    final patientStatus = cubit.getArabicStatus(state.selectedStatus);

    if (widget.form == null) {
      return Center(
        child: customText(
          text: "اختر نموذجًا لبدء ملء الاستبيان",
          size: responsiveHeight(context, 0.025, min: 16, max: 24),
          bold: true,
          color: const Color(0xFF7A004C),
        ),
      );
    }

    final form = widget.form!;
    final questions = form.currentVersion?.questions ?? [];

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(
          responsiveSize(context, 0.02, min: 10, max: 16),
        ),
        child: Column(
          children: [
            AnimatedPatientHeader(
              form: form,
              score: score,
              diagnosis: diagnosis,
              patientStatus: patientStatus,
            ),
            _gap(24),
            _patientSearch(),
            _gap(24),
            _statusDropdown(),
            _gap(24),
            ...questions.asMap().entries.map((entry) {
              return _questionCard(index: entry.key, question: entry.value);
            }),
            _gap(20),
            _notesField(),
            _gap(30),
            SizedBox(
              width: _isMobile ? double.infinity : 330,
              child: CustomGlowButton(
                isGradient: true,
                textSize: responsiveHeight(context, 0.02, min: 14, max: 18),
                glowColor: const Color(0xFFE40070),
                title: widget.isSubmitting ? "جاري الحفظ..." : "حفظ التقييم",
                onPressed: () {
                  if (widget.isSubmitting) return;

                  context.read<DoctorFormsCubit>().submitManualAssessment(
                    doctorNote: noteController.text.trim(),
                  );
                },
              ),
            ),
            _gap(40),
          ],
        ),
      ),
    );
  }

  Widget _gap(double max) {
    return SizedBox(
      height: responsiveHeight(context, max / 1000, min: max * 0.55, max: max),
    );
  }

  Widget _patientSearch() {
    final state = context.watch<DoctorFormsCubit>().state;

    return Container(
      padding: EdgeInsets.all(responsiveSize(context, 0.02, min: 14, max: 18)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFD),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.022, min: 16, max: 22),
        ),
        border: Border.all(color: const Color(0xFFFFB6D9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              customText(
                text: localizedText(context, 'اختيار المريض'),
                size: responsiveHeight(context, 0.02, min: 14, max: 19),
                bold: true,
                color: const Color(0xFF7A004C),
              ),
              SizedBox(width: responsiveSize(context, 0.01, min: 6, max: 8)),
              Icon(
                Icons.person_search_rounded,
                color: const Color(0xFFE40070),
                size: responsiveSize(context, 0.024, min: 20, max: 24),
              ),
            ],
          ),
          SizedBox(height: responsiveHeight(context, 0.014, min: 10, max: 14)),
          Directionality(
            textDirection: TextDirection.rtl,
            child: CustomFormTextField(
              controller: patientSearchController,
              labelText: localizedText(context, 'اختيار المريض'),
              hintText: localizedText(context, 'ابحث باسم المريض'),
              autovalidateMode: AutovalidateMode.disabled,
              keyboardType: CustomTextFieldType.text,
              onChange: (value) {
                context.read<DoctorFormsCubit>().searchPatients(value);
                setState(() {});
              },
            ),
          ),
          if (state.patientAlreadyFilledMessage != null)
            Padding(
              padding: EdgeInsets.only(
                top: responsiveHeight(context, 0.01, min: 8, max: 10),
              ),
              child: customText(
                text: state.patientAlreadyFilledMessage!,
                size: responsiveHeight(context, 0.016, min: 12, max: 15),
                bold: true,
                color: Colors.red,
              ),
            ),
          SizedBox(height: responsiveHeight(context, 0.012, min: 8, max: 12)),
          if (widget.selectedPatient != null) _selectedPatientCard(),
          if (widget.isSearchingPatients)
            Padding(
              padding: EdgeInsets.all(
                responsiveSize(context, 0.012, min: 8, max: 10),
              ),
              child: const CircularProgressIndicator(),
            ),
          if (widget.patients.isNotEmpty) _patientsList(),
        ],
      ),
    );
  }

  Widget _selectedPatientCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.016, min: 10, max: 14)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F8),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.018, min: 12, max: 16),
        ),
        border: Border.all(color: const Color(0xFFFF8FC5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              context.read<DoctorFormsCubit>().clearSelectedPatient();
              patientSearchController.clear();
            },
            icon: const Icon(Icons.close_rounded, color: Color(0xFFE40070)),
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: customText(
                    text: widget.selectedPatient!.fullName,
                    size: responsiveHeight(context, 0.018, min: 13, max: 17),
                    bold: true,
                    color: const Color(0xFF7A004C),
                  ),
                ),
                SizedBox(width: responsiveSize(context, 0.01, min: 6, max: 8)),
                Icon(
                  Icons.person_rounded,
                  color: const Color(0xFFE40070),
                  size: responsiveSize(context, 0.024, min: 20, max: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _patientsList() {
    return Container(
      margin: EdgeInsets.only(
        top: responsiveHeight(context, 0.01, min: 8, max: 10),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFFD6E9)),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.016, min: 12, max: 14),
        ),
      ),
      child: Column(
        children: widget.patients.map((patient) {
          return ListTile(
            title: Text(
              patient.fullName,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: const Color(0xFF7A004C),
                fontWeight: FontWeight.bold,
                fontSize: responsiveHeight(context, 0.017, min: 13, max: 16),
              ),
            ),
            trailing: const Icon(Icons.person, color: Color(0xFFE40070)),
            onTap: () async {
              await context.read<DoctorFormsCubit>().selectPatient(patient);
              if (!mounted) return;
              patientSearchController.clear();
              setState(() {});
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _statusDropdown() {
    final state = context.watch<DoctorFormsCubit>().state;

    final statuses = [
      {"value": "NORMAL", "label": "طبيعي", "icon": Icons.check_circle_outline},
      {"value": "MILD", "label": "بسيط", "icon": Icons.info_outline},
      {
        "value": "MODERATE",
        "label": "متوسط",
        "icon": Icons.warning_amber_rounded,
      },
      {"value": "SEVERE", "label": "شديد", "icon": Icons.priority_high_rounded},
      {"value": "CRITICAL", "label": "حرج", "icon": Icons.dangerous_outlined},
    ];

    final statusValues = statuses
        .map((item) => item["value"])
        .whereType<String>()
        .toSet();
    final safeSelectedStatus = statusValues.contains(state.selectedStatus)
        ? state.selectedStatus
        : null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: responsiveSize(context, 0.02, min: 14, max: 18),
          vertical: responsiveHeight(context, 0.01, min: 8, max: 10),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6FB),
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.02, min: 16, max: 20),
          ),
          border: Border.all(color: const Color(0xFFFF8FC5)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE40070).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: safeSelectedStatus,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFFE40070),
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.018, min: 14, max: 18),
            ),
            selectedItemBuilder: (context) {
              return statuses.map((item) {
                return Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      customText(
                        text: item["label"] as String,
                        size: responsiveHeight(
                          context,
                          0.018,
                          min: 13,
                          max: 17,
                        ),
                        bold: true,
                        color: const Color(0xFF7A004C),
                      ),
                      SizedBox(
                        width: responsiveSize(context, 0.012, min: 8, max: 10),
                      ),
                      Icon(
                        item["icon"] as IconData,
                        color: const Color(0xFFE40070),
                        size: responsiveSize(context, 0.024, min: 20, max: 22),
                      ),
                    ],
                  ),
                );
              }).toList();
            },
            items: statuses.map((item) {
              return DropdownMenuItem<String>(
                value: item["value"] as String,
                child: _statusItem(item),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;
              context.read<DoctorFormsCubit>().changeStatus(value);
            },
          ),
        ),
      ),
    );
  }

  Widget _statusItem(Map<String, Object> item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        customText(
          text: item["label"] as String,
          size: responsiveHeight(context, 0.018, min: 13, max: 17),
          bold: true,
          color: const Color(0xFF7A004C),
        ),
        SizedBox(width: responsiveSize(context, 0.012, min: 8, max: 10)),
        Icon(
          item["icon"] as IconData,
          color: const Color(0xFFE40070),
          size: responsiveSize(context, 0.024, min: 20, max: 22),
        ),
      ],
    );
  }
}
