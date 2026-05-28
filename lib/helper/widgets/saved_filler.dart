import 'package:bahya_website/bloc/cubit/doctor_cubit.dart';
import 'package:bahya_website/data/api/models/form_model.dart';
import 'package:bahya_website/data/api/models/options_model.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SavedFormsWidget extends StatelessWidget {
  final List<FormModel> forms;
  final String selectedFormId;
  final Function(String id) onSelect;

  const SavedFormsWidget({
    super.key,
    required this.forms,
    required this.selectedFormId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    final w = getScreenWidth(context);

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                customText(
                  text: "النماذج المحفوظة",
                  size: h * 0.025,
                  bold: true,
                  color: const Color(0xFF7A004C),
                  isCenter: false,
                ),
                SizedBox(width: w * 0.01),
                const Icon(Icons.folder_open, color: Color(0xFF7A004C), size: 28),
              ],
            ),
            const SizedBox(height: 25),
            if (forms.isEmpty)
              customText(
                text: "لا توجد نماذج",
                size: h * 0.02,
                color: Colors.grey,
                bold: true,
              )
            else
              ...forms.map((form) {
                final bool active = selectedFormId == form.id;
      
                return GestureDetector(
                  onTap: () => onSelect(form.id),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: active
                            ? const LinearGradient(
                                colors: [Color(0xFFFF80C5), Color(0xFFC38CFF)],
                              )
                            : null,
                        color: active ? null : const Color(0xFFF8ECF7),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFFE40070,
                                  ).withOpacity(0.18),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.description_rounded,
                            color: active
                                ? Colors.white
                                : const Color(0xFF7A004C),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: customText(
                              text: form.name,
                              size: h * 0.018,
                              bold: true,
                              color: active
                                  ? Colors.white
                                  : const Color(0xFF7A004C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

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
  final TextEditingController patientSearchController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void dispose() {
    patientSearchController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    final state = context.watch<DoctorFormsCubit>().state;
    final cubit = context.read<DoctorFormsCubit>();
final score = cubit.calculateScore();
    final diagnosis = cubit.calculateDiagnosis();
    final patientStatus = cubit.getArabicStatus(state.selectedStatus);
    if (widget.form == null) {
      return Center(
        child: customText(
          text: "اختر نموذجًا لبدء ملء الاستبيان",
          size: h * 0.025,
          bold: true,
          color: const Color(0xFF7A004C),
        ),
      );
    }

    final form = widget.form!;
    final questions = form.currentVersion?.questions ?? [];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
        _header(
              form: form,
              score: score,
              diagnosis: diagnosis,
              patientStatus: patientStatus,
            ),
            const SizedBox(height: 24),
            _patientSearch(),
            const SizedBox(height: 24),
            _statusDropdown(),
            const SizedBox(height: 24),
            ...questions.asMap().entries.map((entry) {
              return _questionCard(index: entry.key, question: entry.value);
            }),
            const SizedBox(height: 20),
            _notesField(),
            const SizedBox(height: 30),
            SizedBox(
              width: 330,
              child: CustomGlowButton(
                title: widget.isSubmitting ? "جاري الحفظ..." : "حفظ التقييم",
                onPressed: () {
                  if (widget.isSubmitting) return;
        
                  context.read<DoctorFormsCubit>().submitManualAssessment(
                    doctorNote: noteController.text.trim(),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _header({
    required FormModel form,
    required int score,
    required String diagnosis,
    required String patientStatus,
  }) {
    final h = getScreenHeight(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF6FB), Color(0xFFFFEAF5)],
        ),
        border: Border.all(color: const Color(0xFFFFB6D9)),
      ),
      child: Column(
        children: [
          customText(
            text: form.name,
            size: h * 0.035,
            bold: true,
            color: const Color(0xFF7A004C),
          ),
          const SizedBox(height: 8),
          customText(
            text: "اختر المريض ثم املأ الإجابات يدويًا",
            size: h * 0.02,
            color: const Color(0xFFE40070),
            bold: true,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            alignment: WrapAlignment.center,
            children: [
              _smallInfoCard(
                title: "التشخيص",
                value: diagnosis,
                icon: Icons.medical_information_rounded,
              ),
              _smallInfoCard(
                title: "الاسكور",
                value: score.toString(),
                icon: Icons.analytics_rounded,
              ),
              _smallInfoCard(
                title: "حالة المريض",
                value: patientStatus,
                icon: Icons.health_and_safety_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE40070).withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFE40070), size: 22),
          const SizedBox(width: 8),
          Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF7A004C),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF7A00C4),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _patientSearch() {
    final h = getScreenHeight(context);
    final state = context.watch<DoctorFormsCubit>().state;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFD),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFB6D9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              customText(
                text: "اختيار المريض",
                size: h * 0.02,
                bold: true,
                color: const Color(0xFF7A004C),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.person_search_rounded, color: Color(0xFFE40070)),
            ],
          ),
          const SizedBox(height: 14),
          Directionality(
            textDirection: TextDirection.rtl,
            child: CustomFormTextField(
              controller: patientSearchController,
              labelText: "اختيار المريض",
              hintText: "ابحث باسم المريض",
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
              padding: const EdgeInsets.only(top: 10),
              child: customText(
                text: state.patientAlreadyFilledMessage!,
                size: h * 0.016,
                bold: true,
                color: Colors.red,
              ),
            ),
          const SizedBox(height: 12),
          if (widget.selectedPatient != null) _selectedPatientCard(h),
          if (widget.isSearchingPatients)
            const Padding(
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(),
            ),
          if (widget.patients.isNotEmpty) _patientsList(),
        ],
      ),
    );
  }

  Widget _selectedPatientCard(double h) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F8),
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              customText(
                text: widget.selectedPatient!.fullName,
                size: h * 0.018,
                bold: true,
                color: const Color(0xFF7A004C),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.person_rounded, color: Color(0xFFE40070)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _patientsList() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFFD6E9)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: widget.patients.map((patient) {
          return ListTile(
            title: Text(
              patient.fullName,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: Color(0xFF7A004C),
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(Icons.person, color: Color(0xFFE40070)),
            onTap: () async {
              await context.read<DoctorFormsCubit>().selectPatient(patient);
              patientSearchController.clear();
              setState(() {});
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _statusDropdown() {
    final h = getScreenHeight(context);
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6FB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFF8FC5)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE40070).withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: state.selectedStatus,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFFE40070),
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(18),
            selectedItemBuilder: (context) {
              return statuses.map((item) {
                return Row(
                  children: [
                    Icon(
                      item["icon"] as IconData,
                      color: const Color(0xFFE40070),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    customText(
                      text: item["label"] as String,
                      size: h * 0.018,
                      bold: true,
                      color: const Color(0xFF7A004C),
                    ),
                  ],
                );
              }).toList();
            },
            items: statuses.map((item) {
              return DropdownMenuItem<String>(
                value: item["value"] as String,
                child: Row(
                  children: [
                    Icon(
                      item["icon"] as IconData,
                      color: const Color(0xFFE40070),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    customText(
                      text: item["label"] as String,
                      size: h * 0.018,
                      bold: true,
                      color: const Color(0xFF7A004C),
                    ),
                  ],
                ),
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

  Widget _questionCard({required int index, required dynamic question}) {
    final h = getScreenHeight(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6FB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFD6E9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE40070).withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          customText(
            text: "السؤال ${index + 1}: ${question.text ?? ""}",
            size: h * 0.02,
            bold: true,
            color: const Color(0xFF7A004C),
          ),
          const SizedBox(height: 18),
          if (question.type == "SCALE")
            _scaleQuestion(question)
          else
            ..._choiceQuestion(question),
        ],
      ),
    );
  }

  Widget _scaleQuestion(dynamic question) {
    final cubit = context.read<DoctorFormsCubit>();

    final min = question.scaleMin ?? 0;
    final max = question.scaleMax ?? 10;
    final current = cubit.getScaleAnswer(question.id) ?? min;

    return Column(
      children: [
        Slider(
          value: current.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          activeColor: const Color(0xFFE40070),
          inactiveColor: const Color(0xFFFFC7DF),
          label: current.toString(),
          onChanged: (value) {
            final score = value.round();

            cubit.setScaleAnswer(
              questionId: question.id,
              value: score,
              score: score,
            );
            setState(() {});
          },
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEAF5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            current.toString(),
            style: const TextStyle(
              color: Color(0xFF7A004C),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _choiceQuestion(dynamic question) {
    final h = getScreenHeight(context);
    final cubit = context.read<DoctorFormsCubit>();

    return (question.choices ?? []).map<Widget>((choice) {
      final selected = cubit.isChoiceSelected(
        questionId: question.id,
        choiceId: choice.id,
      );

      final score = choice.score ?? choice.value ?? 0;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFEAF5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFE40070) : const Color(0xFFFFD6E9),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF4E8FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: customText(
                text: "$score نقطة",
                size: h * 0.014,
                bold: true,
                color: const Color(0xFF7A00C4),
              ),
            ),
            const Spacer(),
            question.type == "MULTI_SELECT"
                ? Checkbox(
                    value: selected,
                    activeColor: const Color(0xFF7A004C),
                    onChanged: (_) {
                      cubit.toggleMultiChoiceAnswer(
                        questionId: question.id,
                        choiceId: choice.id,
                        score: score,
                      );
                      setState(() {});
                    },
                  )
                : Radio<String>(
                    value: choice.id,
                    groupValue: cubit.getSingleChoiceAnswer(question.id),
                    activeColor: const Color(0xFF7A004C),
                    onChanged: (_) {
                      cubit.setSingleChoiceAnswer(
                        questionId: question.id,
                        choiceId: choice.id,
                        score: score,
                      );
                      setState(() {});
                    },
                  ),
            const SizedBox(width: 6),
            customText(
              text: choice.label ?? "",
              size: h * 0.018,
              bold: selected,
              color: const Color(0xFF7A004C),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _notesField() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomFormTextField(
        controller: noteController,
        labelText: "ملاحظات الطبيب",
        hintText: "اكتب ملاحظات اختيارية",
        autovalidateMode: AutovalidateMode.disabled,
        keyboardType: CustomTextFieldType.text,
      ),
    );
  }
}
