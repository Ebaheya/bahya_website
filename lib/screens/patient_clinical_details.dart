import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:excel/excel.dart' hide Border;
import 'package:file_saver/file_saver.dart';
class PatientClinicalDetails extends StatefulWidget {
  final ClinicalPatient patient;

  const PatientClinicalDetails({super.key, required this.patient});

  @override
  State<PatientClinicalDetails> createState() => _PatientClinicalDetailsState();
}

class _PatientClinicalDetailsState extends State<PatientClinicalDetails> {
  int selectedTab = 0;
  bool showEmergencyInfo = false;
Future<void> exportPatientToExcel() async {
    final patient = widget.patient;

    final excel = Excel.createExcel();

    final clinicalSheet = excel['Clinical Data'];
    final assessmentsSheet = excel['Assessments'];

    excel.delete('Sheet1');
   clinicalSheet.appendRow([
      TextCellValue('Patient Name'),
      TextCellValue('File Number'),
      TextCellValue('Age'),
      TextCellValue('Phone'),
      TextCellValue('Emergency Contact Name'),
      TextCellValue('Emergency Contact Phone'),
      TextCellValue('Registration Date'),
      TextCellValue('Comorbidities'),
      TextCellValue('BMI'),
      TextCellValue('Family History'),
      TextCellValue('Menopausal Status'),
      TextCellValue('Diagnosis Date'),
      TextCellValue('Stage At Diagnosis'),
      TextCellValue('Current Disease Status'),
      TextCellValue('Tumor Biology'),
      TextCellValue('Surgery'),
      TextCellValue('Chemotherapy'),
      TextCellValue('Radiotherapy'),
      TextCellValue('Hormonal Therapy'),
      TextCellValue('Targeted Therapy'),
      TextCellValue('Immunotherapy'),
      TextCellValue('Drugs'),
    ]);

    clinicalSheet.appendRow([
      TextCellValue(patient.name),
      TextCellValue(patient.fileNumber),
      TextCellValue(patient.age.toString()),
      TextCellValue(patient.phone),
      TextCellValue(patient.emergencyContactName),
      TextCellValue(patient.emergencyContactPhone),
      TextCellValue(patient.registrationDate),
      TextCellValue(patient.comorbidities),
      TextCellValue(patient.bmi),
      TextCellValue(patient.familyHistory),
      TextCellValue(patient.menopausalStatus),
      TextCellValue(patient.diagnosisDate),
      TextCellValue(patient.stageAtDiagnosis),
      TextCellValue(patient.diseaseStatus),
      TextCellValue(patient.tumorBiology),
      TextCellValue(patient.surgery),
      TextCellValue(patient.chemotherapy),
      TextCellValue(patient.radiotherapy),
      TextCellValue(patient.hormonalTherapy),
      TextCellValue(patient.targetedTherapy),
      TextCellValue(patient.immunotherapy),
      TextCellValue(patient.drugs.join(', ')),
    ]);

    for (final drug in patient.drugs) {
      clinicalSheet.appendRow([TextCellValue(drug)]);
    }

    assessmentsSheet.appendRow([
      TextCellValue('Form Name'),
      TextCellValue('Submit Date'),
      TextCellValue('Total Score'),
      TextCellValue('Question'),
      TextCellValue('Answer'),
      TextCellValue('Answer Score'),
    ]);

    for (final assessment in patient.assessments) {
      final answers = assessment.answers.isEmpty
          ? _demoAnswers
          : assessment.answers;

      for (final answer in answers) {
        assessmentsSheet.appendRow([
          TextCellValue(assessment.formName),
          TextCellValue(assessment.submitDate),
          TextCellValue(assessment.score.toString()),
          TextCellValue(answer.question),
          TextCellValue(answer.answer),
          TextCellValue(answer.score.toString()),
        ]);
      }
    }

    final List<int>? bytes = excel.encode();

    if (bytes == null) return;

    await FileSaver.instance.saveFile(
      name: '${patient.fileNumber}_${patient.name}_clinical_data',
      bytes: Uint8List.fromList(bytes),
      mimeType: MimeType.microsoftExcel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    final w = getScreenWidth(context);

    return Scaffold(
      appBar: customAppBar(
        context: context,
        title: 'معلومات المريض',
        isHomeBar: false,
        widgets: [
          _HeaderButton(
            title: 'تصدير Excel',
            icon: Icons.picture_as_pdf_outlined,
            onTap: exportPatientToExcel,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFDF7FB),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.025,
            vertical: h * 0.03,
          ),
          child: Column(
            children: [
              _PatientHeaderCard(
                patient: widget.patient,
                showEmergencyInfo: showEmergencyInfo,
                onMoreInfoTap: () {
                  setState(() => showEmergencyInfo = !showEmergencyInfo);
                },
              ),
              SizedBox(height: h * 0.025),
              _TabsBar(
                selectedTab: selectedTab,
                onTabChanged: (index) {
                  setState(() => selectedTab = index);
                },
              ),
              SizedBox(height: h * 0.025),
             AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final slideAnimation = Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(animation);

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: child,
                    ),
                  );
                },
                child: selectedTab == 0
                    ? _ClinicalDataTab(
                        key: const ValueKey('clinical_tab'),
                        patient: widget.patient,
                      )
                    : _AssessmentsTab(
                        key: const ValueKey('assessments_tab'),
                        assessments: widget.patient.assessments,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientHeaderCard extends StatelessWidget {
  final ClinicalPatient patient;
  final bool showEmergencyInfo;
  final VoidCallback onMoreInfoTap;

  const _PatientHeaderCard({
    required this.patient,
    required this.showEmergencyInfo,
    required this.onMoreInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.018),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: const Color(0xFFE83E8C),
                  child: customText(
                    text: _initials(patient.name),
                    size: w * 0.02,
                    color: Colors.white,
                    bold: true,
                    isCenter: true,
                  ),
                ),
                const SizedBox(width: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText(
                      text: patient.name,
                      size: w * 0.015,
                      color: const Color(0xFF271648),
                      bold: true,
                      isCenter: false,
                    ),
                    const SizedBox(height: 6),
                    customText(
                      text: 'رقم الملف: ${patient.fileNumber}',
                      size: w * 0.008,
                      color: const Color(0xFF6B667A),
                      bold: true,
                      isCenter: false,
                    ),
                    const SizedBox(height: 6),
                    _SmallBadge(text: _translateStatus(patient.diseaseStatus)),
                  ],
                ),
                Spacer(),
                _HeaderDivider(),
                _HeaderInfoItem(
                  title: 'العمر',
                  value: '${patient.age} سنة',
                  icon: Icons.person_outline,
                ),
                _HeaderDivider(),
                _HeaderInfoItem(
                  title: 'رقم الهاتف',
                  value: patient.phone,
                  icon: Icons.phone_outlined,
                ),
                _HeaderDivider(),
                _HeaderInfoItem(
                  title: 'تاريخ التسجيل',
                  value: patient.registrationDate,
                  icon: Icons.calendar_month_outlined,
                ),
                _HeaderDivider(),
                Spacer(),
                _MoreInfoButton(
                  opened: showEmergencyInfo,
                  onTap: onMoreInfoTap,
                ),
              ],
            ),
            if (showEmergencyInfo) ...[
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF7CFE0)),
                ),
                child: Row(
                  children: [
                    _EmergencyInfoItem(
                      title: 'جهة اتصال الطوارئ',
                      value: patient.emergencyContactName,
                      icon: Icons.contact_emergency_outlined,
                    ),
                    const SizedBox(width: 35),
                    _EmergencyInfoItem(
                      title: 'رقم الطوارئ',
                      value: patient.emergencyContactPhone,
                      icon: Icons.phone_in_talk_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return name.isNotEmpty ? name[0] : 'P';
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'Active treatment':
        return 'تحت علاج نشط';
      case 'Follow-up':
        return 'متابعة دورية';
      case 'Newly diagnosed':
        return 'حديث التشخيص';
      case 'Recurrence':
        return 'انتكاس';
      case 'Metastatic':
        return 'منتشر';
      default:
        return status;
    }
  }
}

class _TabsBar extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  const _TabsBar({required this.selectedTab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabItem(
              title: 'التقييمات',
              icon: Icons.assignment_outlined,
              active: selectedTab == 1,
              onTap: () => onTabChanged(1),
            ),
          ),
          Expanded(
            child: _TabItem(
              title: 'البيانات السريرية',
              icon: Icons.medical_information_outlined,
              active: selectedTab == 0,
              onTap: () => onTabChanged(0),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _TabItem({
    required this.title,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        scale: active ? 1 : 0.96,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          opacity: active ? 1 : 0.55,
          child: Container(
          height: double.infinity,
            decoration: BoxDecoration(
                  color: active
                  ? Colors.pink[200]!.withOpacity(0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: active ? Border.all(color: Colors.pink) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                customText(
                  text: title,
                  size: w * 0.0085,
                  color: const Color(0xFFE83E8C),
                  bold: true,
                ),
                const SizedBox(width: 8),
                Icon(icon, color: const Color(0xFFE83E8C), size: w * 0.013),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClinicalDataTab extends StatelessWidget {
  final ClinicalPatient patient;

  const _ClinicalDataTab({required this.patient , super.key});

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          title: 'البيانات السريرية للمريض',
          subtitle: 'جميع البيانات السريرية المطلوبة للمشروع النفسي الاجتماعي',
        ),
        SizedBox(height: h * 0.02),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _DrugsCard(drugs: patient.drugs)),
            const SizedBox(width: 18),
            Expanded(
              child: _ClinicalCard(
                title: 'العلاج',
                icon: Icons.local_hospital_outlined,
                rows: [
                  _DataRowItem(
                    'الجراحة',
                    patient.surgery,
                    badgeType: BadgeType.success,
                  ),
                  _DataRowItem(
                    'العلاج الكيميائي',
                    patient.chemotherapy,
                    badgeType: BadgeType.warning,
                  ),
                  _DataRowItem(
                    'العلاج الإشعاعي',
                    _yesNo(patient.radiotherapy),
                    badgeType: _badgeByYesNo(patient.radiotherapy),
                  ),
                  _DataRowItem(
                    'العلاج الهرموني',
                    _yesNo(patient.hormonalTherapy),
                    badgeType: _badgeByYesNo(patient.hormonalTherapy),
                  ),
                  _DataRowItem(
                    'العلاج الموجه',
                    _yesNo(patient.targetedTherapy),
                    badgeType: patient.targetedTherapy == 'Yes'
                        ? BadgeType.warning
                        : BadgeType.neutral,
                  ),
                  _DataRowItem(
                    'العلاج المناعي',
                    _yesNo(patient.immunotherapy),
                    badgeType: patient.immunotherapy == 'Yes'
                        ? BadgeType.warning
                        : BadgeType.neutral,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: _ClinicalCard(
                title: 'حالة المرض',
                icon: Icons.monitor_heart_outlined,
                rows: [
                  _DataRowItem('تاريخ التشخيص', patient.diagnosisDate),
                  _DataRowItem('المرحلة عند التشخيص', patient.stageAtDiagnosis),
                  _DataRowItem(
                    'الحالة الحالية للمرض',
                    _translateStatus(patient.diseaseStatus),
                    badgeType: BadgeType.status,
                  ),
                  _DataRowItem(
                    'البيولوجيا الورمية',
                    patient.tumorBiology,
                    badgeType: BadgeType.info,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),

            Expanded(
              child: _ClinicalCard(
                title: 'التقييم الأولي',
                icon: Icons.person_outline,
                rows: [
                  _DataRowItem('الأمراض المصاحبة', patient.comorbidities),
                  _DataRowItem('مؤشر كتلة الجسم BMI', patient.bmi),
                  _DataRowItem('التاريخ العائلي', patient.familyHistory),
                  _DataRowItem('حالة سن اليأس', patient.menopausalStatus),
                ],
              ),
            ),
          ],
        ),
       SizedBox(height: h * 0.1),
        _PrivacyNotice(),
      ],
    );
  }

  BadgeType _badgeByYesNo(String value) {
    return value == 'Yes' ? BadgeType.success : BadgeType.neutral;
  }

  String _yesNo(String value) => value == 'Yes' ? 'نعم' : 'لا';

  String _translateStatus(String status) {
    switch (status) {
      case 'Active treatment':
        return 'تحت علاج نشط';
      case 'Follow-up':
        return 'متابعة دورية';
      case 'Newly diagnosed':
        return 'حديث التشخيص';
      case 'Recurrence':
        return 'انتكاس';
      case 'Metastatic':
        return 'منتشر';
      default:
        return status;
    }
  }
}

class _AssessmentsTab extends StatefulWidget {
  final List<PatientAssessment> assessments;

  const _AssessmentsTab({required this.assessments , super.key});

  @override
  State<_AssessmentsTab> createState() => _AssessmentsTabState();
}

class _AssessmentsTabState extends State<_AssessmentsTab>
    with TickerProviderStateMixin {
  int? openedIndex;

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          customText(
            text: 'قائمة التقييمات التي قام بها المريض',
            size: w * 0.01,
            color: const Color(0xFF271648),
            bold: true,
            isCenter: false,
          ),
          const SizedBox(height: 18),
          ...List.generate(widget.assessments.length, (index) {
            final assessment = widget.assessments[index];
            final bool isOpen = openedIndex == index;

            return Column(
              children: [
                _AssessmentItem(
                  assessment: assessment,
                  isOpen: isOpen,
                  onTap: () {
                    setState(() {
                      openedIndex = isOpen ? null : index;
                    });
                  },
                ),
                ClipRect(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: isOpen
                        ? _AssessmentAnswersWidget(
                            key: ValueKey('answers_$index'),
                            assessment: assessment,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _AssessmentAnswersWidget extends StatefulWidget {
  final PatientAssessment assessment;

  const _AssessmentAnswersWidget({super.key, required this.assessment});

  @override
  State<_AssessmentAnswersWidget> createState() =>
      _AssessmentAnswersWidgetState();
}

class _AssessmentAnswersWidgetState extends State<_AssessmentAnswersWidget> {
  double opacity = 0;
  Offset offset = const Offset(0, -0.04);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        opacity = 1;
        offset = Offset.zero;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      offset: offset,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        opacity: opacity,
        child: _AssessmentAnswersContent(assessment: widget.assessment),
      ),
    );
  }
}

class _AssessmentAnswersContent extends StatelessWidget {
  final PatientAssessment assessment;

  const _AssessmentAnswersContent({required this.assessment});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    final answers = assessment.answers.isEmpty
        ? _demoAnswers
        : assessment.answers;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF7CFE0)),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText(
              text: 'تفاصيل التقييم',
              size: w * 0.01,
              color: const Color(0xFFE83E8C),
              bold: true,
              isCenter: false,
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF7D6E6)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF0F7),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                         SizedBox(width: 20),
                        customText(
                          text: '#',
                          size: w * 0.008,
                          color: const Color(0xFF271648),
                          bold: true,
                        ),
                        Spacer(),
                        customText(
                          text: 'السؤال',
                          size: w * 0.008,
                          color: const Color(0xFF271648),
                          bold: true,
                        ),
                          Spacer(),
                        customText(
                          text: 'الإجابة',
                          size: w * 0.008,
                          color: const Color(0xFF271648),
                          bold: true,
                        ),
                          Spacer(),
                        customText(
                          text: 'الاسكور',
                          size: w * 0.008,
                          color: textColor,
                          bold: true,
                        ),
                        SizedBox(width: 20),
                      ],
                    ),
                  ),
                  ...List.generate(answers.length, (index) {
                    final item = answers[index];
        
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: index.isEven
                            ? Colors.white
                            : const Color(0xFFFFF8FC),
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade100),
                        ),
                      ),
                      child: Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          SizedBox(
                            width: 50,
                            child: customText(
                              text: '${index + 1}',
                              size: w * 0.0075,
                              color: const Color(0xFF271648),
                              bold: true,
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: customText(
                              text: item.question,
                              size: w * 0.0075,
                              color: const Color(0xFF4B445C),
                              bold: true,
                              isCenter: false,
                              maxLines: 2,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: _AnswerBadge(answer: item.answer),
                            ),
                          ),
                          SizedBox(
                            width: 90,
                            child: _ScoreBadge(score: item.score),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssessmentItem extends StatelessWidget {
  final PatientAssessment assessment;
  final bool isOpen;
  final VoidCallback onTap;

  const _AssessmentItem({
    required this.assessment,
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7FC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF7D6E6)),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(
              isOpen
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFFE83E8C),
              size: w * 0.018,
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.assignment_turned_in_outlined,
              color: const Color(0xFFE83E8C),
              size: w * 0.015,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: customText(
                text: assessment.formName,
                size: w * 0.01,
                color: const Color(0xFF271648),
                bold: true,
                isCenter: false,
              ),
            ),
            _AssessmentColumn(
              title: 'تاريخ الإرسال',
              value: assessment.submitDate,
            ),
            const SizedBox(width: 40),
            _AssessmentColumn(
              title: 'الاسكور',
              value: assessment.score.toString(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF1FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFC9DAFF)),
        ),
        child: customText(
          text: score.toString(),
          size: w * 0.007,
          color: const Color(0xFF3066BE),
          bold: true,
          isCenter: true,
        ),
      ),
    );
  }
}

class _AnswerBadge extends StatelessWidget {
  final String answer;

  const _AnswerBadge({required this.answer});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFD98A)),
      ),
      child: customText(
        text: answer,
        size: w * 0.007,
        color: const Color(0xFFE28A00),
        bold: true,
        isCenter: true,
      ),
    );
  }
}

class _AssessmentColumn extends StatelessWidget {
  final String title;
  final String value;

  const _AssessmentColumn({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);  
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        customText(
          text: title,
          size: w * 0.0075,
          color: const Color(0xFF7A7890),
          bold: true,
          isCenter: false,
        ),
        const SizedBox(height: 5),
        customText(
          text: value,
          size: w * 0.008,
          color: const Color(0xFFE83E8C),
          bold: true,
          isCenter: false,
        ),
      ],
    );
  }
}

class _ClinicalCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_DataRowItem> rows;

  const _ClinicalCard({
    required this.title,
    required this.icon,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 330),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0F7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(icon, color: const Color(0xFFE83E8C) , size: w * 0.015),
                const SizedBox(width: 8),
                customText(
                  text: title,
                  size: w * 0.01,
                  color: const Color(0xFFE83E8C),
                  bold: true,
                  isCenter: false,
                ),
              ],
            ),
          ),
          ...rows.map((row) => _ClinicalRow(row: row)),
        ],
      ),
    );
  }
}

class _ClinicalRow extends StatelessWidget {
  final _DataRowItem row;

  const _ClinicalRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: customText(
              text: row.label,
              size: w * 0.0075,
              color: const Color(0xFF6B667A),
              bold: true,
              isCenter: false,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: row.badgeType == null
                  ? customText(
                      text: row.value,
                      size: w * 0.007,
                      color: const Color(0xFF271648),
                      bold: true,
                      isCenter: false,
                    )
                  : _ValueBadge(text: row.value, type: row.badgeType!),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueBadge extends StatelessWidget {
  final String text;
  final BadgeType type;

  const _ValueBadge({required this.text, required this.type});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    Color bg;
    Color border;
    Color textColor;

    switch (type) {
      case BadgeType.success:
        bg = const Color(0xFFE7F8EE);
        border = const Color(0xFFB7E6C8);
        textColor = const Color(0xFF178A46);
        break;
      case BadgeType.warning:
        bg = const Color(0xFFFFF4DA);
        border = const Color(0xFFFFD98A);
        textColor = const Color(0xFFE28A00);
        break;
      case BadgeType.danger:
        bg = const Color(0xFFFFE9E9);
        border = const Color(0xFFFFB7B7);
        textColor = const Color(0xFFE53935);
        break;
      case BadgeType.info:
        bg = const Color(0xFFEAF1FF);
        border = const Color(0xFFC9DAFF);
        textColor = const Color(0xFF3066BE);
        break;
      case BadgeType.status:
        bg = const Color(0xFFE7F8EE);
        border = const Color(0xFFB7E6C8);
        textColor = const Color(0xFF178A46);
        break;
      case BadgeType.neutral:
        bg = const Color(0xFFF1F1F3);
        border = const Color(0xFFD9D9DE);
        textColor = const Color(0xFF555A66);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: customText(
        text: text,
        size: w * 0.007,
        color: textColor,
        bold: true,
        isCenter: true,
        maxLines: 1,
      ),
    );
  }
}

class _DrugsCard extends StatelessWidget {
  final List<String> drugs;

  const _DrugsCard({required this.drugs});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 330),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0F7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                const Icon(Icons.medication_outlined, color: Color(0xFFE83E8C)),
                const SizedBox(width: 8),
                customText(
                  text: 'الأدوية',
                  size: 16,
                  color: const Color(0xFFE83E8C),
                  bold: true,
                  isCenter: false,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: drugs.map((drug) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 6,
                        color: Color(0xFFE83E8C),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: customText(
                          text: drug,
                          size: 13,
                          color: const Color(0xFF271648),
                          bold: true,
                          isCenter: false,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        customText(
          text: title,
          size: w * 0.015,
          color: const Color(0xFF271648),
          bold: true,
          isCenter: false,
        ),
        const SizedBox(height: 6),
        customText(
          text: subtitle,
          size: w * 0.008,
          color: const Color(0xFF7A7890),
          bold: true,
          isCenter: false,
        ),
      ],
    );
  }
}

class _PrivacyNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF7CFE0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xFFE83E8C)),
          const SizedBox(width: 10),
          customText(
            text:
                'هذه البيانات سرية ومحمية ويتم عرضها للأطباء والمستخدمين المخولين فقط',
            size: 14,
            color: const Color(0xFFE83E8C),
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFFE83E8C)),
              const SizedBox(width: 8),
              customText(
                text: title,
                size: 13,
                color: const Color(0xFFE83E8C),
                bold: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderInfoItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _HeaderInfoItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE83E8C), size: w * 0.02),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            customText(
              text: title,
              size: w * 0.0075,
              color: const Color(0xFF7A7890),
              bold: true,
              isCenter: false,
            ),
            customText(
              text: value,
              size: w * 0.008,
              color: textColor,
              bold: true,
              isCenter: false,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      width: 3,
      height: 45,
      color: Colors.grey.shade200,
    );
  }
}

class _MoreInfoButton extends StatelessWidget {
  final bool opened;
  final VoidCallback onTap;

  const _MoreInfoButton({required this.opened, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7FC),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0xFFF7CFE0)),
        ),
        child: Row(
          children: [
            Icon(
              opened
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFFE83E8C),
            ),
            const SizedBox(width: 8),
            customText(
              text: 'المزيد من المعلومات',
              size: w * 0.0075,
              color: const Color(0xFFE83E8C),
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyInfoItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _EmergencyInfoItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Icon(icon, color: const Color(0xFFE83E8C)),
        const SizedBox(width: 10),
        customText(
          text: '$title: ',
          size: w * 0.0075,
          color: const Color(0xFF7A7890),
          bold: true,
          isCenter: false,
        ),
        SizedBox(width: 6),
        customText(
          text: value,
          size: w * 0.008,
          color: textColor,
          bold: true,
          isCenter: false,
        ),
      ],
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String text;

  const _SmallBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAF4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: customText(
        text: text,
        size: w * 0.0065,
        color: const Color(0xFFE83E8C),
        bold: true,
      ),
    );
  }
}

enum BadgeType { success, warning, danger, info, status, neutral }

class _DataRowItem {
  final String label;
  final String value;
  final BadgeType? badgeType;

  _DataRowItem(this.label, this.value, {this.badgeType});
}

class ClinicalPatient {
  final String fileNumber;
  final String name;
  final int age;
  final String phone;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String registrationDate;

  final String comorbidities;
  final String bmi;
  final String familyHistory;
  final String menopausalStatus;

  final String diagnosisDate;
  final String stageAtDiagnosis;
  final String diseaseStatus;
  final String tumorBiology;

  final String surgery;
  final String chemotherapy;
  final String radiotherapy;
  final String hormonalTherapy;
  final String targetedTherapy;
  final String immunotherapy;

  final List<String> drugs;
  final List<PatientAssessment> assessments;

  ClinicalPatient({
    required this.fileNumber,
    required this.name,
    required this.age,
    required this.phone,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.registrationDate,
    required this.comorbidities,
    required this.bmi,
    required this.familyHistory,
    required this.menopausalStatus,
    required this.diagnosisDate,
    required this.stageAtDiagnosis,
    required this.diseaseStatus,
    required this.tumorBiology,
    required this.surgery,
    required this.chemotherapy,
    required this.radiotherapy,
    required this.hormonalTherapy,
    required this.targetedTherapy,
    required this.immunotherapy,
    required this.drugs,
    required this.assessments,
  });
}

class PatientAssessment {
  final String formName;
  final String submitDate;
  final int score;
  final List<PatientAnswer> answers;

  PatientAssessment({
    required this.formName,
    required this.submitDate,
    required this.score,
    this.answers = const [],
  });
}

class PatientAnswer {
  final String question;
  final String answer;
  final int score;

  const PatientAnswer({
    required this.question,
    required this.answer,
    required this.score,
  });
}

const List<PatientAnswer> _demoAnswers = [
  PatientAnswer(
    question: 'قلة الاهتمام أو المتعة في القيام بالأنشطة',
    answer: 'عدة أيام',
    score: 1,
  ),
  PatientAnswer(
    question: 'الشعور بالحزن أو الاكتئاب',
    answer: 'أكثر من نصف الأيام',
    score: 2,
  ),
  PatientAnswer(
    question: 'صعوبة في النوم أو الاستمرار في النوم أو النوم أكثر من المعتاد',
    answer: 'عدة أيام',
    score: 1,
  ),
  PatientAnswer(
    question: 'الشعور بالتعب أو قلة الطاقة',
    answer: 'أكثر من نصف الأيام',
    score: 2,
  ),
  PatientAnswer(
    question: 'ضعف الشهية أو الإفراط في تناول الطعام',
    answer: 'أبداً',
    score: 0,
  ),
  PatientAnswer(
    question: 'الشعور بالفشل أو خيبة الأمل تجاه الذات',
    answer: 'أكثر من نصف الأيام',
    score: 2,
  ),
  PatientAnswer(
    question: 'صعوبة في التركيز على الأشياء',
    answer: 'عدة أيام',
    score: 1,
  ),
  PatientAnswer(
    question: 'بطء في الحركة أو التحدث أو العكس',
    answer: 'أبداً',
    score: 0,
  ),
  PatientAnswer(
    question: 'التفكير في أن الحياة لن تكون أفضل أو أذية النفس',
    answer: 'أبداً',
    score: 0,
  ),
];

