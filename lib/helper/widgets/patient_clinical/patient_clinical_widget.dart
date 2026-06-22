part of '../../../screens/doctor/patient_clinical_details.dart';

bool get _isEnglishLocale =>
    AppLanguageController.localeNotifier.value.languageCode == 'en';

TextDirection get _activeTextDirection =>
    _isEnglishLocale ? TextDirection.ltr : TextDirection.rtl;

CrossAxisAlignment get _activeCrossAxisStart => CrossAxisAlignment.start;

Alignment get _activeCenterStart =>
    _isEnglishLocale ? Alignment.centerLeft : Alignment.centerRight;

Alignment get _activeCenterEnd =>
    _isEnglishLocale ? Alignment.centerRight : Alignment.centerLeft;

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
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Directionality(
        textDirection: _activeTextDirection,
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
                textDirection: _activeTextDirection,
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
                            textDirection: _activeTextDirection,
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
    return Row(
      textDirection: _activeTextDirection,
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
          crossAxisAlignment: _activeCrossAxisStart,
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
    final isMobile = getScreenWidth(context) < 720;

    final tabs = [
      {
        'title': 'البيانات السريرية',
        'icon': Icons.medical_information_outlined,
        'index': 0,
      },
      {'title': 'التقييمات', 'icon': Icons.assignment_outlined, 'index': 1},
      {
        'title': 'مراجعة معلقة',
        'icon': Icons.pending_actions_rounded,
        'index': 2,
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: isMobile
          ? Column(
              children: tabs.map((tab) {
                final index = tab['index'] as int;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _TabItem(
                    title: tab['title'] as String,
                    icon: tab['icon'] as IconData,
                    active: selectedTab == index,
                    onTap: () => onTabChanged(index),
                  ),
                );
              }).toList(),
            )
          : SizedBox(
              height: responsiveHeight(context, 0.07, min: 52, max: 58),
              child: Row(
                textDirection: _activeTextDirection,
                children: tabs.map((tab) {
                  final index = tab['index'] as int;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _TabItem(
                        title: tab['title'] as String,
                        icon: tab['icon'] as IconData,
                        active: selectedTab == index,
                        onTap: () => onTabChanged(index),
                      ),
                    ),
                  );
                }).toList(),
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
              textDirection: _activeTextDirection,
              crossAxisAlignment: _activeCrossAxisStart,
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
      _DataRowItem('BMI', patient.bmi),
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
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: _activeCrossAxisStart,
        children: [
          customText(
            text: 'قائمة التقييمات التي قام بها المريض',
            size: responsiveSize(context, 0.01, min: 16, max: 20),
            color: const Color(0xFF271648),
            bold: true,
            isCenter: false,
          ),
          SizedBox(height: responsiveHeight(context, 0.02, min: 14, max: 18)),
          if (widget.assessments.isEmpty)
            const _EmptyAssessmentsState()
          else
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
