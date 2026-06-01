import 'dart:typed_data';

import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';


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
      name: '${patient.fileNumber}_${patient.name}_clinical_data.xlsx',
      bytes: Uint8List.fromList(bytes),
      mimeType: MimeType.microsoftExcel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context: context,
        title: 'معلومات المريض',
        isHomeBar: false,
        widgets: [
          _HeaderButton(
            title: 'تصدير Excel',
            icon: Icons.table_chart_outlined,
            onTap: exportPatientToExcel,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFDF7FB),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.025, min: 16, max: 42),
            vertical: responsiveHeight(context, 0.03, min: 20, max: 40),
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
              SizedBox(
                height: responsiveHeight(context, 0.025, min: 18, max: 28),
              ),
              _TabsBar(
                selectedTab: selectedTab,
                onTabChanged: (index) {
                  setState(() => selectedTab = index);
                },
              ),
              SizedBox(
                height: responsiveHeight(context, 0.025, min: 18, max: 28),
              ),
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
    final isSmall = w < 950;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.018, min: 16, max: 28)),
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
            if (isSmall)
              Column(
                children: [
                  _PatientHeaderIdentity(patient: patient),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 16,
                    runSpacing: 14,
                    alignment: WrapAlignment.center,
                    children: [
                      _HeaderInfoItem(
                        title: 'العمر',
                        value: '${patient.age} سنة',
                        icon: Icons.person_outline,
                      ),
                      _HeaderInfoItem(
                        title: 'رقم الهاتف',
                        value: patient.phone,
                        icon: Icons.phone_outlined,
                      ),
                      _HeaderInfoItem(
                        title: 'تاريخ التسجيل',
                        value: patient.registrationDate,
                        icon: Icons.calendar_month_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _MoreInfoButton(
                    opened: showEmergencyInfo,
                    onTap: onMoreInfoTap,
                  ),
                ],
              )
            else
              Row(
                children: [
                  _PatientHeaderIdentity(patient: patient),
                  const Spacer(),
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
                  const Spacer(),
                  _MoreInfoButton(
                    opened: showEmergencyInfo,
                    onTap: onMoreInfoTap,
                  ),
                ],
              ),
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: showEmergencyInfo
                    ? Padding(
                        padding: const EdgeInsets.only(top: 22),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(
                            responsiveSize(context, 0.012, min: 14, max: 18),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4FA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFF7CFE0)),
                          ),
                          child: Wrap(
                            spacing: 35,
                            runSpacing: 16,
                            alignment: WrapAlignment.start,
                            children: [
                              _EmergencyInfoItem(
                                title: 'جهة اتصال الطوارئ',
                                value: patient.emergencyContactName,
                                icon: Icons.contact_emergency_outlined,
                              ),
                              _EmergencyInfoItem(
                                title: 'رقم الطوارئ',
                                value: patient.emergencyContactPhone,
                                icon: Icons.phone_in_talk_outlined,
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientHeaderIdentity extends StatelessWidget {
  final ClinicalPatient patient;

  const _PatientHeaderIdentity({required this.patient});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: responsiveSize(context, 0.03, min: 34, max: 42),
          backgroundColor: const Color(0xFFE83E8C),
          child: customText(
            text: _initials(patient.name),
            size: responsiveSize(context, 0.02, min: 22, max: 30),
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
              size: responsiveSize(context, 0.015, min: 18, max: 26),
              color: const Color(0xFF271648),
              bold: true,
              isCenter: false,
            ),
            const SizedBox(height: 6),
            customText(
              text: 'رقم الملف: ${patient.fileNumber}',
              size: responsiveSize(context, 0.008, min: 12, max: 15),
              color: const Color(0xFF6B667A),
              bold: true,
              isCenter: false,
            ),
            const SizedBox(height: 6),
            _SmallBadge(text: _translateStatus(patient.diseaseStatus)),
          ],
        ),
      ],
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return name.isNotEmpty ? name[0] : 'P';
  }

  static String _translateStatus(String status) {
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
      height: responsiveHeight(context, 0.07, min: 52, max: 58),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        height: double.infinity,
        decoration: BoxDecoration(
          color: active
              ? Colors.pink[200]!.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: active ? Border.all(color: Colors.pink) : null,
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: active ? 1 : 0.55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              customText(
                text: title,
                size: responsiveSize(context, 0.0085, min: 12, max: 15),
                color: const Color(0xFFE83E8C),
                bold: true,
              ),
              const SizedBox(width: 8),
              Icon(
                icon,
                color: const Color(0xFFE83E8C),
                size: responsiveSize(context, 0.013, min: 16, max: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClinicalDataTab extends StatelessWidget {
  final ClinicalPatient patient;

  const _ClinicalDataTab({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          title: 'البيانات السريرية للمريض',
          subtitle: 'جميع البيانات السريرية المطلوبة للمشروع النفسي الاجتماعي',
        ),
        SizedBox(height: responsiveHeight(context, 0.02, min: 14, max: 24)),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 1150;

            if (isSmall) {
              return Column(
                children: [
                  _DrugsCard(drugs: patient.drugs),
                  const SizedBox(height: 16),
                  _ClinicalCard(
                    title: 'العلاج',
                    icon: Icons.local_hospital_outlined,
                    rows: _treatmentRows(patient),
                  ),
                  const SizedBox(height: 16),
                  _ClinicalCard(
                    title: 'حالة المرض',
                    icon: Icons.monitor_heart_outlined,
                    rows: _diseaseRows(patient),
                  ),
                  const SizedBox(height: 16),
                  _ClinicalCard(
                    title: 'التقييم الأولي',
                    icon: Icons.person_outline,
                    rows: _initialRows(patient),
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _DrugsCard(drugs: patient.drugs)),
                const SizedBox(width: 18),
                Expanded(
                  child: _ClinicalCard(
                    title: 'العلاج',
                    icon: Icons.local_hospital_outlined,
                    rows: _treatmentRows(patient),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: _ClinicalCard(
                    title: 'حالة المرض',
                    icon: Icons.monitor_heart_outlined,
                    rows: _diseaseRows(patient),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: _ClinicalCard(
                    title: 'التقييم الأولي',
                    icon: Icons.person_outline,
                    rows: _initialRows(patient),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  List<_DataRowItem> _initialRows(ClinicalPatient patient) {
    return [
      _DataRowItem('الأمراض المصاحبة', patient.comorbidities),
      _DataRowItem('مؤشر كتلة الجسم BMI', patient.bmi),
      _DataRowItem('التاريخ العائلي', patient.familyHistory),
      _DataRowItem('حالة سن اليأس', patient.menopausalStatus),
    ];
  }

  List<_DataRowItem> _diseaseRows(ClinicalPatient patient) {
    return [
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
    ];
  }

  List<_DataRowItem> _treatmentRows(ClinicalPatient patient) {
    return [
      _DataRowItem('الجراحة', patient.surgery, badgeType: BadgeType.success),
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
    ];
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

  const _AssessmentsTab({super.key, required this.assessments});

  @override
  State<_AssessmentsTab> createState() => _AssessmentsTabState();
}

class _AssessmentsTabState extends State<_AssessmentsTab>
    with TickerProviderStateMixin {
  int? openedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(responsiveSize(context, 0.014, min: 16, max: 22)),
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
            size: responsiveSize(context, 0.01, min: 16, max: 20),
            color: const Color(0xFF271648),
            bold: true,
            isCenter: false,
          ),
          SizedBox(height: responsiveHeight(context, 0.02, min: 14, max: 18)),
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
    final answers = assessment.answers.isEmpty
        ? _demoAnswers
        : assessment.answers;
    final w = getScreenWidth(context);
    final isSmall = w < 850;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: EdgeInsets.all(responsiveSize(context, 0.014, min: 14, max: 18)),
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
              size: responsiveSize(context, 0.01, min: 15, max: 18),
              color: const Color(0xFFE83E8C),
              bold: true,
              isCenter: false,
            ),
            const SizedBox(height: 18),
            if (isSmall)
              Column(
                children: List.generate(answers.length, (index) {
                  final item = answers[index];

                  return _AnswerMobileCard(index: index, item: item);
                }),
              )
            else
              _AnswersTable(answers: answers),
          ],
        ),
      ),
    );
  }
}

class _AnswersTable extends StatelessWidget {
  final List<PatientAnswer> answers;

  const _AnswersTable({required this.answers});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.01, min: 12, max: 14),
              vertical: responsiveHeight(context, 0.014, min: 12, max: 14),
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0F7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                SizedBox(
                  width: responsiveSize(context, 0.035, min: 40, max: 55),
                  child: customText(
                    text: '#',
                    size: responsiveSize(context, 0.008, min: 12, max: 15),
                    color: const Color(0xFF271648),
                    bold: true,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: customText(
                    text: 'السؤال',
                    size: responsiveSize(context, 0.008, min: 12, max: 15),
                    color: const Color(0xFF271648),
                    bold: true,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: customText(
                    text: 'الإجابة',
                    size: responsiveSize(context, 0.008, min: 12, max: 15),
                    color: const Color(0xFF271648),
                    bold: true,
                  ),
                ),
                SizedBox(
                  width: responsiveSize(context, 0.06, min: 80, max: 110),
                  child: customText(
                    text: 'الاسكور',
                    size: responsiveSize(context, 0.008, min: 12, max: 15),
                    color: textColor,
                    bold: true,
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(answers.length, (index) {
            final item = answers[index];

            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsiveSize(context, 0.01, min: 12, max: 14),
                vertical: responsiveHeight(context, 0.014, min: 11, max: 13),
              ),
              decoration: BoxDecoration(
                color: index.isEven ? Colors.white : const Color(0xFFFFF8FC),
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  SizedBox(
                    width: responsiveSize(context, 0.035, min: 40, max: 55),
                    child: customText(
                      text: '${index + 1}',
                      size: responsiveSize(context, 0.0075, min: 12, max: 14),
                      color: const Color(0xFF271648),
                      bold: true,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: customText(
                      text: item.question,
                      size: responsiveSize(context, 0.0075, min: 12, max: 14),
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
                    width: responsiveSize(context, 0.06, min: 80, max: 110),
                    child: _ScoreBadge(score: item.score),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AnswerMobileCard extends StatelessWidget {
  final int index;
  final PatientAnswer item;

  const _AnswerMobileCard({required this.index, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(responsiveSize(context, 0.012, min: 12, max: 16)),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : const Color(0xFFFFF8FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          customText(
            text: '${index + 1}. ${item.question}',
            size: responsiveSize(context, 0.008, min: 12, max: 15),
            color: const Color(0xFF271648),
            bold: true,
            isCenter: false,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              _AnswerBadge(answer: item.answer),
              const SizedBox(width: 10),
              _ScoreBadge(score: item.score),
            ],
          ),
        ],
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
    final isSmall = w < 700;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: EdgeInsets.all(
          responsiveSize(context, 0.012, min: 14, max: 16),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7FC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF7D6E6)),
        ),
        child: isSmall
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(
                        isOpen
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFFE83E8C),
                        size: responsiveSize(context, 0.018, min: 20, max: 28),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.assignment_turned_in_outlined,
                        color: const Color(0xFFE83E8C),
                        size: responsiveSize(context, 0.015, min: 18, max: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: customText(
                          text: assessment.formName,
                          size: responsiveSize(context, 0.01, min: 14, max: 18),
                          color: const Color(0xFF271648),
                          bold: true,
                          isCenter: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      _AssessmentColumn(
                        title: 'تاريخ الإرسال',
                        value: assessment.submitDate,
                      ),
                      const SizedBox(width: 30),
                      _AssessmentColumn(
                        title: 'الاسكور',
                        value: assessment.score.toString(),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFFE83E8C),
                    size: responsiveSize(context, 0.018, min: 20, max: 28),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.assignment_turned_in_outlined,
                    color: const Color(0xFFE83E8C),
                    size: responsiveSize(context, 0.015, min: 18, max: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: customText(
                      text: assessment.formName,
                      size: responsiveSize(context, 0.01, min: 14, max: 18),
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
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsiveSize(context, 0.008, min: 11, max: 13),
          vertical: responsiveHeight(context, 0.007, min: 5, max: 7),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF1FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFC9DAFF)),
        ),
        child: customText(
          text: score.toString(),
          size: responsiveSize(context, 0.007, min: 11, max: 13),
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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.009, min: 12, max: 14),
        vertical: responsiveHeight(context, 0.007, min: 5, max: 7),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFD98A)),
      ),
      child: customText(
        text: answer,
        size: responsiveSize(context, 0.007, min: 11, max: 13),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        customText(
          text: title,
          size: responsiveSize(context, 0.0075, min: 11, max: 14),
          color: const Color(0xFF7A7890),
          bold: true,
          isCenter: false,
        ),
        const SizedBox(height: 5),
        customText(
          text: value,
          size: responsiveSize(context, 0.008, min: 12, max: 15),
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
    return Container(
      constraints: BoxConstraints(
        minHeight: responsiveHeight(context, 0.35, min: 260, max: 330),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.012, min: 14, max: 18),
              vertical: responsiveHeight(context, 0.018, min: 12, max: 16),
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0F7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(
                  icon,
                  color: const Color(0xFFE83E8C),
                  size: responsiveSize(context, 0.015, min: 18, max: 24),
                ),
                const SizedBox(width: 8),
                customText(
                  text: title,
                  size: responsiveSize(context, 0.01, min: 14, max: 18),
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
    final isSmall = w < 700;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.012, min: 14, max: 18),
        vertical: responsiveHeight(context, 0.016, min: 11, max: 14),
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: isSmall
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                customText(
                  text: row.label,
                  size: responsiveSize(context, 0.0075, min: 12, max: 14),
                  color: const Color(0xFF6B667A),
                  bold: true,
                  isCenter: false,
                ),
                const SizedBox(height: 7),
                row.badgeType == null
                    ? customText(
                        text: row.value,
                        size: responsiveSize(context, 0.007, min: 12, max: 14),
                        color: const Color(0xFF271648),
                        bold: true,
                        isCenter: false,
                        maxLines: 2,
                      )
                    : _ValueBadge(text: row.value, type: row.badgeType!),
              ],
            )
          : Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: customText(
                    text: row.label,
                    size: responsiveSize(context, 0.0075, min: 12, max: 14),
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
                            size: responsiveSize(
                              context,
                              0.007,
                              min: 12,
                              max: 14,
                            ),
                            color: const Color(0xFF271648),
                            bold: true,
                            isCenter: false,
                            maxLines: 2,
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
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.008, min: 10, max: 12),
        vertical: responsiveHeight(context, 0.007, min: 5, max: 7),
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: customText(
        text: text,
        size: responsiveSize(context, 0.007, min: 11, max: 13),
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
      constraints: BoxConstraints(
        minHeight: responsiveHeight(context, 0.35, min: 260, max: 330),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.012, min: 14, max: 18),
              vertical: responsiveHeight(context, 0.018, min: 12, max: 16),
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0F7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(
                  Icons.medication_outlined,
                  color: const Color(0xFFE83E8C),
                  size: responsiveSize(context, 0.015, min: 18, max: 24),
                ),
                const SizedBox(width: 8),
                customText(
                  text: 'الأدوية',
                  size: responsiveSize(context, 0.01, min: 14, max: 18),
                  color: const Color(0xFFE83E8C),
                  bold: true,
                  isCenter: false,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(
              responsiveSize(context, 0.012, min: 14, max: 18),
            ),
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
                          size: responsiveSize(
                            context,
                            0.007,
                            min: 12,
                            max: 14,
                          ),
                          color: const Color(0xFF271648),
                          bold: true,
                          isCenter: false,
                          maxLines: 2,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        customText(
          text: title,
          size: responsiveSize(context, 0.015, min: 20, max: 28),
          color: const Color(0xFF271648),
          bold: true,
          isCenter: false,
        ),
        const SizedBox(height: 6),
        customText(
          text: subtitle,
          size: responsiveSize(context, 0.008, min: 12, max: 15),
          color: const Color(0xFF7A7890),
          bold: true,
          isCenter: false,
        ),
      ],
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
          height: responsiveSize(context, 0.026, min: 34, max: 38),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: responsiveSize(context, 0.01, min: 15, max: 18),
                color: const Color(0xFFE83E8C),
              ),
              const SizedBox(width: 8),
              customText(
                text: title,
                size: responsiveSize(context, 0.0085, min: 12, max: 14),
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
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFE83E8C),
          size: responsiveSize(context, 0.02, min: 22, max: 32),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            customText(
              text: title,
              size: responsiveSize(context, 0.0075, min: 11, max: 14),
              color: const Color(0xFF7A7890),
              bold: true,
              isCenter: false,
            ),
            customText(
              text: value,
              size: responsiveSize(context, 0.008, min: 12, max: 15),
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
      margin: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.018, min: 18, max: 28),
      ),
      width: 2,
      height: responsiveHeight(context, 0.05, min: 38, max: 45),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        height: responsiveHeight(context, 0.05, min: 38, max: 42),
        padding: EdgeInsets.symmetric(
          horizontal: responsiveSize(context, 0.012, min: 14, max: 18),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7FC),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0xFFF7CFE0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              opened
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFFE83E8C),
              size: responsiveSize(context, 0.014, min: 18, max: 22),
            ),
            const SizedBox(width: 8),
            customText(
              text: 'المزيد من المعلومات',
              size: responsiveSize(context, 0.0075, min: 12, max: 14),
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
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: const Color(0xFFE83E8C),
          size: responsiveSize(context, 0.014, min: 18, max: 22),
        ),
        const SizedBox(width: 10),
        customText(
          text: '$title: ',
          size: responsiveSize(context, 0.0075, min: 12, max: 14),
          color: const Color(0xFF7A7890),
          bold: true,
          isCenter: false,
        ),
        const SizedBox(width: 6),
        customText(
          text: value,
          size: responsiveSize(context, 0.008, min: 12, max: 15),
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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.008, min: 11, max: 13),
        vertical: responsiveHeight(context, 0.006, min: 4, max: 6),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAF4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: customText(
        text: text,
        size: responsiveSize(context, 0.0065, min: 11, max: 13),
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
