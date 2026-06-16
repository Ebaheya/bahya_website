part of '../../../screens/patient_clinical_details.dart';

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

  const _TabsBar({
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 720;

    final tabs = [
      {
        'title': 'البيانات السريرية',
        'icon': Icons.medical_information_outlined,
        'index': 0,
      },
      {
        'title': 'التقييمات',
        'icon': Icons.assignment_outlined,
        'index': 1,
      },
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

class _PendingReviewTab extends StatelessWidget {
  const _PendingReviewTab({super.key, required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      PatientAssessmentReviewCubit,
      PatientAssessmentReviewState
    >(
      listener: (context, state) {
        if (state.error != null) {
          customDialog(
            context: context,
            title: 'خطأ',
            message: state.error!,
            isError: true,
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return _PendingReviewShell(
            child: SizedBox(
              height: responsiveHeight(context, 0.32, min: 240, max: 380),
              child: Center(child: customLoading()),
            ),
          );
        }

        if (state.submissions.isEmpty) {
          return const _PendingReviewEmpty();
        }

        return _PendingReviewShell(
          child: Column(
            crossAxisAlignment: _activeCrossAxisStart,
            children: [
              Row(
                textDirection: _activeTextDirection,
                children: [
                  Container(
                    width: responsiveSize(context, 0.044, min: 44, max: 58),
                    height: responsiveSize(context, 0.044, min: 44, max: 58),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE5F1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.pending_actions_rounded,
                      color: Color(0xFFE83E8C),
                    ),
                  ),
                  SizedBox(
                    width: responsiveSize(context, 0.012, min: 10, max: 16),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: _activeCrossAxisStart,
                      children: [
                        customText(
                          text: 'التقييمات المعلقة للمراجعة',
                          size: responsiveSize(
                            context,
                            0.014,
                            min: 18,
                            max: 24,
                          ),
                          color: const Color(0xFF271648),
                          bold: true,
                          isCenter: false,
                        ),
                        const SizedBox(height: 5),
                        customText(
                          text: 'راجع الأسئلة والإجابات ثم اعتمدها كتقييم رسمي',
                          size: responsiveSize(
                            context,
                            0.0085,
                            min: 12,
                            max: 15,
                          ),
                          color: const Color(0xFF7A7890),
                          bold: true,
                          isCenter: false,
                        ),
                      ],
                    ),
                  ),
                  _PendingCountBadge(count: state.submissions.length),
                ],
              ),
              SizedBox(
                height: responsiveHeight(context, 0.024, min: 18, max: 26),
              ),
              ...state.submissions.map(
                (submission) => _PendingSubmissionCard(
                  patientId: patientId,
                  submission: submission,
                  isSaving: state.isSaving,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PendingReviewShell extends StatelessWidget {
  const _PendingReviewShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.02, min: 16, max: 30)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF7D6E6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE83E8C).withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PendingCountBadge extends StatelessWidget {
  const _PendingCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.012, min: 10, max: 14),
        vertical: responsiveHeight(context, 0.007, min: 6, max: 8),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE5F1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: customText(
        text: '$count معلق',
        size: responsiveSize(context, 0.008, min: 12, max: 14),
        color: const Color(0xFFE83E8C),
        bold: true,
      ),
    );
  }
}

class _PendingReviewEmpty extends StatelessWidget {
  const _PendingReviewEmpty();

  @override
  Widget build(BuildContext context) {
    return _PendingReviewShell(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: responsiveHeight(context, 0.04, min: 28, max: 48),
        ),
        child: Column(
          children: [
            Container(
              width: responsiveSize(context, 0.075, min: 64, max: 90),
              height: responsiveSize(context, 0.075, min: 64, max: 90),
              decoration: const BoxDecoration(
                color: Color(0xFFFFE5F1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fact_check_outlined,
                color: const Color(0xFFE83E8C),
                size: responsiveSize(context, 0.04, min: 34, max: 50),
              ),
            ),
            SizedBox(height: responsiveHeight(context, 0.02, min: 14, max: 22)),
            customText(
              text: 'لا توجد تقييمات معلقة للمراجعة',
              size: responsiveSize(context, 0.013, min: 17, max: 23),
              color: const Color(0xFF271648),
              bold: true,
            ),
            const SizedBox(height: 8),
            customText(
              text:
                  'أي استبيان يتم إرساله من المريض أو المتطوع سيظهر هنا قبل اعتماده كتقييم رسمي.',
              size: responsiveSize(context, 0.009, min: 13, max: 16),
              color: const Color(0xFF7A7890),
              bold: true,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingSubmissionCard extends StatefulWidget {
  const _PendingSubmissionCard({
    required this.patientId,
    required this.submission,
    required this.isSaving,
  });

  final String patientId;
  final Map<String, dynamic> submission;
  final bool isSaving;

  @override
  State<_PendingSubmissionCard> createState() => _PendingSubmissionCardState();
}

class _PendingSubmissionCardState extends State<_PendingSubmissionCard> {
  String status = 'MODERATE';
  bool isOpen = true;
  final TextEditingController noteController = TextEditingController();

  final Map<String, String> statusLabels = const {
    'NORMAL': 'طبيعي',
    'MILD': 'بسيط',
    'MODERATE': 'متوسط',
    'SEVERE': 'شديد',
    'CRITICAL': 'حرج',
  };
String get diagnosis {
    final value =
        widget.submission['diagnosis'] ??
        widget.submission['statusLabel'] ??
        widget.submission['interpretation'] ??
        widget.submission['severity'];

    if (value is Map) {
      return value['label']?.toString() ??
          value['name']?.toString() ??
          value['status']?.toString() ??
          '-';
    }

    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }

    return statusLabels[status] ?? status;
  }
  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  String get formName {
    final assignment = widget.submission['assignment'];
    final template = assignment is Map ? assignment['template'] : null;

    if (template is Map && template['name'] != null) {
      return template['name'].toString();
    }

    final templateMap = widget.submission['template'];
    if (templateMap is Map && templateMap['name'] != null) {
      return templateMap['name'].toString();
    }

    return 'استبيان';
  }

  String get fillerName {
    final submittedBy = widget.submission['submittedBy'];

    if (submittedBy is Map) {
      final name =
          submittedBy['fullName'] ??
          submittedBy['name'] ??
          submittedBy['email'];
      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString();
      }
    }

    return 'غير معروف';
  }

  String get totalScore {
    final value =
        widget.submission['totalScore'] ??
        widget.submission['score'] ??
        widget.submission['total'];
    return value == null ? '-' : value.toString();
  }

  String get submitDate {
    final value =
        widget.submission['submittedAt'] ??
        widget.submission['createdAt'] ??
        widget.submission['updatedAt'];
    return value == null ? '-' : value.toString().split('T').first;
  }

  List<_ReviewAnswerItem> get answers {
    return _ReviewAnswerItem.fromSubmission(widget.submission);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 780;

    return Container(
      margin: EdgeInsets.only(
        bottom: responsiveHeight(context, 0.018, min: 14, max: 22),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => isOpen = !isOpen),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Padding(
              padding: EdgeInsets.all(
                responsiveSize(context, 0.016, min: 14, max: 20),
              ),
              child: isMobile ? _mobileHeader() : _desktopHeader(),
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: isOpen
                  ? _detailsContent(isMobile)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

 Widget _desktopHeader() {
    return Row(
      textDirection: _activeTextDirection,
      children: [
        _submissionIcon(),
        SizedBox(width: responsiveSize(context, 0.014, min: 10, max: 16)),
        Expanded(child: _titleBlock()),
        _InfoBadge(title: 'Score', value: totalScore),
        const SizedBox(width: 10),
        _InfoBadge(title: 'التشخيص', value: diagnosis),
        const SizedBox(width: 10),
        _InfoBadge(title: 'Date', value: submitDate),
        const SizedBox(width: 10),
        Icon(
          isOpen
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded,
          color: const Color(0xFFE83E8C),
        ),
      ],
    );
  }

  Widget _mobileHeader() {
    return Column(
      crossAxisAlignment: _activeCrossAxisStart,
      children: [
        Row(
          textDirection: _activeTextDirection,
          children: [
            _submissionIcon(),
            SizedBox(width: responsiveSize(context, 0.014, min: 10, max: 16)),
            Expanded(child: _titleBlock()),
            Icon(
              isOpen
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFFE83E8C),
            ),
          ],
        ),
        SizedBox(height: responsiveHeight(context, 0.014, min: 10, max: 14)),
        Wrap(
          textDirection: _activeTextDirection,
          spacing: 10,
          runSpacing: 10,
          children: [
            _InfoBadge(title: 'Score', value: totalScore),
            _InfoBadge(title: 'التشخيص', value: diagnosis),
            _InfoBadge(title: 'Date', value: submitDate),
          ],
        ),
      ],
    );
  }

  Widget _submissionIcon() {
    return Container(
      width: responsiveSize(context, 0.048, min: 48, max: 60),
      height: responsiveSize(context, 0.048, min: 48, max: 60),
      decoration: const BoxDecoration(
        color: Color(0xFFFFE5F1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.assignment_turned_in_outlined,
        color: Color(0xFFE83E8C),
      ),
    );
  }

  Widget _titleBlock() {
    return Column(
      crossAxisAlignment: _activeCrossAxisStart,
      children: [
        customText(
          text: formName,
          size: responsiveSize(context, 0.012, min: 16, max: 21),
          color: const Color(0xFF271648),
          bold: true,
          isCenter: false,
          maxLines: 1,
        ),
        const SizedBox(height: 5),
        customText(
          text: 'تم الإرسال بواسطة: $fillerName',
          size: responsiveSize(context, 0.0085, min: 12, max: 15),
          color: const Color(0xFF7A7890),
          bold: true,
          isCenter: false,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _detailsContent(bool isMobile) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        responsiveSize(context, 0.016, min: 14, max: 20),
        0,
        responsiveSize(context, 0.016, min: 14, max: 20),
        responsiveSize(context, 0.016, min: 14, max: 20),
      ),
      child: Column(
        crossAxisAlignment: _activeCrossAxisStart,
        children: [
          const Divider(color: Color(0xFFF7D6E6)),
          SizedBox(height: responsiveHeight(context, 0.012, min: 8, max: 12)),
          customText(
            text: 'إجابات الاستبيان',
            size: responsiveSize(context, 0.011, min: 16, max: 20),
            color: const Color(0xFFE83E8C),
            bold: true,
            isCenter: false,
          ),
          SizedBox(height: responsiveHeight(context, 0.016, min: 12, max: 18)),
          if (answers.isEmpty)
            _emptyAnswers()
          else if (isMobile)
            Column(
              children: List.generate(
                answers.length,
                (index) =>
                    _ReviewAnswerMobileCard(index: index, item: answers[index]),
              ),
            )
          else
            _ReviewAnswersTable(answers: answers),
          SizedBox(height: responsiveHeight(context, 0.022, min: 16, max: 24)),
          _doctorReviewForm(isMobile),
        ],
      ),
    );
  }

  Widget _emptyAnswers() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.018, min: 16, max: 22)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: customText(
        text: 'لا توجد إجابات ظاهرة في هذا الـ submission.',
        size: responsiveSize(context, 0.009, min: 13, max: 16),
        color: Colors.grey,
        bold: true,
      ),
    );
  }

  Widget _doctorReviewForm(bool isMobile) {
    final statusItems = statusLabels.keys.toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.016, min: 14, max: 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: Column(
        crossAxisAlignment: _activeCrossAxisStart,
        children: [
          customText(
            text: 'مراجعة الدكتور',
            size: responsiveSize(context, 0.011, min: 15, max: 19),
            color: const Color(0xFF271648),
            bold: true,
            isCenter: false,
          ),
          SizedBox(height: responsiveHeight(context, 0.018, min: 12, max: 18)),
          isMobile
              ? Column(
                  children: [
                    _statusDropDown(statusItems),
                    SizedBox(
                      height: responsiveHeight(
                        context,
                        0.014,
                        min: 10,
                        max: 14,
                      ),
                    ),
                    _noteField(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _noteField()),
                    SizedBox(
                      width: responsiveSize(context, 0.014, min: 10, max: 18),
                    ),
                    SizedBox(width: 240, child: _statusDropDown(statusItems)),
                  ],
                ),
          SizedBox(height: responsiveHeight(context, 0.018, min: 14, max: 20)),
          Align(
            alignment: _activeCenterEnd,
            child: SizedBox(
              width: isMobile ? double.infinity : 280,
              child: ElevatedButton.icon(
                onPressed: widget.isSaving ? null : _approve,
                icon: const Icon(Icons.verified_rounded),
                label: Text(
                  widget.isSaving ? 'جاري الاعتماد...' : 'اعتماد كتقييم رسمي',
                  style: const TextStyle(
                    fontFamily: 'ArabicCustomFont',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE83E8C),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: responsiveHeight(
                      context,
                      0.016,
                      min: 13,
                      max: 18,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusDropDown(List<String> statusItems) {
    return customDropdown(
      context: context,
      value: status,
      hint: 'اختر التشخيص / الشدة',
      items: statusItems,
      icon: Icons.health_and_safety_outlined,
      onChanged: (value) {
        if (value != null) {
          setState(() => status = value);
        }
      },
    );
  }

  Widget _noteField() {
    return TextField(
      controller: noteController,
      maxLines: 3,
      textDirection: _activeTextDirection,
      decoration: InputDecoration(
        hintText: 'ملاحظات الدكتور...',
        hintStyle: const TextStyle(fontFamily: 'ArabicCustomFont'),
        filled: true,
        fillColor: const Color(0xFFFFFAFD),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF7D6E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE83E8C)),
        ),
      ),
      style: const TextStyle(fontFamily: 'ArabicCustomFont'),
    );
  }

  Future<void> _approve() async {
    final success = await context
        .read<PatientAssessmentReviewCubit>()
        .approveSubmission(
          patientId: widget.patientId,
          submission: widget.submission,
          status: status,
          doctorNote: noteController.text,
        );

    if (!mounted) return;

    if (success) {
      customDialog(
        context: context,
        title: 'تم الاعتماد',
        message: 'تم تحويل الاستبيان إلى تقييم رسمي.',
        isSuccess: true,
      );
    }
  }
}

class _ReviewAnswersTable extends StatelessWidget {
  const _ReviewAnswersTable({required this.answers});

  final List<_ReviewAnswerItem> answers;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.012, min: 12, max: 16),
              vertical: responsiveHeight(context, 0.014, min: 12, max: 15),
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0F7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              textDirection: _activeTextDirection,
              children: [
                SizedBox(
                  width: 50,
                  child: customText(text: '#', size: 13, bold: true),
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
                  width: 90,
                  child: customText(
                    text: 'الاسكور',
                    size: responsiveSize(context, 0.008, min: 12, max: 15),
                    color: const Color(0xFF271648),
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
                horizontal: responsiveSize(context, 0.012, min: 12, max: 16),
                vertical: responsiveHeight(context, 0.014, min: 12, max: 15),
              ),
              decoration: BoxDecoration(
                color: index.isEven ? Colors.white : const Color(0xFFFFFAFD),
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                textDirection: _activeTextDirection,
                children: [
                  SizedBox(
                    width: 50,
                    child: customText(
                      text: '${index + 1}',
                      size: 13,
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
                      maxLines: 3,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: _activeCenterStart,
                      child: _AnswerBadge(answer: item.answer),
                    ),
                  ),
                  SizedBox(width: 90, child: _ScoreBadge(score: item.score)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ReviewAnswerMobileCard extends StatelessWidget {
  const _ReviewAnswerMobileCard({required this.index, required this.item});

  final int index;
  final _ReviewAnswerItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        bottom: responsiveHeight(context, 0.012, min: 10, max: 14),
      ),
      padding: EdgeInsets.all(responsiveSize(context, 0.014, min: 12, max: 16)),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : const Color(0xFFFFFAFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: Column(
        crossAxisAlignment: _activeCrossAxisStart,
        children: [
          customText(
            text: '${index + 1}. ${item.question}',
            size: responsiveSize(context, 0.0085, min: 13, max: 16),
            color: const Color(0xFF271648),
            bold: true,
            isCenter: false,
            maxLines: 4,
          ),
          const SizedBox(height: 12),
          Wrap(
            textDirection: _activeTextDirection,
            spacing: 10,
            runSpacing: 10,
            children: [
              _AnswerBadge(answer: item.answer),
              _ScoreBadge(score: item.score),
              if (item.type.isNotEmpty)
                _AnswerBadge(
                  answer: item.type == 'SCALE' ? 'Scale' : item.type,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewAnswerItem {
  const _ReviewAnswerItem({
    required this.question,
    required this.answer,
    required this.score,
    required this.type,
  });

  final String question;
  final String answer;
  final int score;
  final String type;

static List<_ReviewAnswerItem> fromSubmission(
    Map<String, dynamic> submission,
  ) {
    final dynamic rawAnswers =
        submission['answers'] ??
        submission['response'] ??
        submission['responses'] ??
        submission['items'];

    if (rawAnswers is! List) return [];

    final questions = _extractQuestions(submission);

    return rawAnswers.map<_ReviewAnswerItem>((raw) {
      if (raw is! Map) {
        return const _ReviewAnswerItem(
          question: 'سؤال غير معروف',
          answer: '-',
          score: 0,
          type: '',
        );
      }

      final answerMap = Map<String, dynamic>.from(raw);
      final questionId = answerMap['questionId']?.toString();

      final questionMap = questionId == null ? null : questions[questionId];

      final questionText = questionMap == null
          ? _readQuestion(answerMap)
          : _readQuestion(questionMap);

      final type = questionMap == null
          ? _readType(answerMap)
          : _readType(questionMap);

      final answerText = questionMap == null
          ? _readAnswer(answerMap, type)
          : _readAnswerFromQuestion(answerMap, questionMap, type);

      final score = questionMap == null
          ? _readScore(answerMap)
          : _readScoreFromQuestion(answerMap, questionMap, type);

      return _ReviewAnswerItem(
        question: questionText,
        answer: answerText,
        score: score,
        type: type,
      );
    }).toList();
  }

  static Map<String, Map<String, dynamic>> _extractQuestions(
    Map<String, dynamic> submission,
  ) {
    final questionsById = <String, Map<String, dynamic>>{};

    final formVersion = submission['formVersion'];
    final dynamic rawQuestions = formVersion is Map
        ? formVersion['questions']
        : null;

    if (rawQuestions is List) {
      for (final rawQuestion in rawQuestions) {
        if (rawQuestion is Map) {
          final question = Map<String, dynamic>.from(rawQuestion);
          final id = question['id']?.toString();

          if (id != null && id.isNotEmpty) {
            questionsById[id] = question;
          }
        }
      }
    }

    return questionsById;
  }

  static String _readAnswerFromQuestion(
    Map<String, dynamic> answerMap,
    Map<String, dynamic> questionMap,
    String type,
  ) {
    if (type == 'SCALE') {
      final value =
          answerMap['value'] ??
          answerMap['scaleValue'] ??
          answerMap['answerValue'] ??
          answerMap['numericValue'];

      return value == null ? '-' : value.toString();
    }

    final choiceIds = _extractChoiceIds(answerMap);

    if (choiceIds.isEmpty) {
      return _readAnswer(answerMap, type);
    }

    final choices = questionMap['choices'];

    if (choices is! List) return '-';

    final labels = <String>[];

    for (final choice in choices) {
      if (choice is! Map) continue;

      final choiceId = choice['id']?.toString();

      if (choiceId != null && choiceIds.contains(choiceId)) {
        final label =
            choice['label'] ??
            choice['text'] ??
            choice['title'] ??
            choice['value'];

        if (label != null && label.toString().trim().isNotEmpty) {
          labels.add(label.toString());
        }
      }
    }

    return labels.isEmpty ? '-' : labels.join('، ');
  }

  static int _readScoreFromQuestion(
    Map<String, dynamic> answerMap,
    Map<String, dynamic> questionMap,
    String type,
  ) {
    if (type == 'SCALE') {
      final value =
          answerMap['value'] ??
          answerMap['scaleValue'] ??
          answerMap['answerValue'] ??
          answerMap['numericValue'];

      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    final choiceIds = _extractChoiceIds(answerMap);

    if (choiceIds.isEmpty) {
      return _readScore(answerMap);
    }

    final choices = questionMap['choices'];

    if (choices is! List) return 0;

    int total = 0;

    for (final choice in choices) {
      if (choice is! Map) continue;

      final choiceId = choice['id']?.toString();

      if (choiceId != null && choiceIds.contains(choiceId)) {
        final score = choice['score'];
        total += int.tryParse(score?.toString() ?? '') ?? 0;
      }
    }

    return total;
  }

  static List<String> _extractChoiceIds(Map<String, dynamic> answerMap) {
    final dynamic rawChoiceIds =
        answerMap['choiceIds'] ??
        answerMap['selectedChoiceIds'] ??
        answerMap['choices'];

    if (rawChoiceIds is List) {
      return rawChoiceIds.map((e) => e.toString()).toList();
    }

    final dynamic singleChoiceId =
        answerMap['choiceId'] ?? answerMap['selectedChoiceId'];

    if (singleChoiceId != null && singleChoiceId.toString().trim().isNotEmpty) {
      return [singleChoiceId.toString()];
    }

    return [];
  }

static String _readQuestion(Map<String, dynamic> map) {
    final direct =
        map['questionText'] ??
        map['questionTitle'] ??
        map['text'] ??
        map['title'] ??
        map['label'];

    if (direct != null && direct.toString().trim().isNotEmpty) {
      return direct.toString();
    }

    final question = map['question'];
    if (question is Map) {
      final text =
          question['text'] ??
          question['title'] ??
          question['label'] ??
          question['body'] ??
          question['questionText'];

      if (text != null && text.toString().trim().isNotEmpty) {
        return text.toString();
      }
    }

    final item = map['item'];
    if (item is Map) {
      final text = item['text'] ?? item['title'] ?? item['label'];
      if (text != null && text.toString().trim().isNotEmpty) {
        return text.toString();
      }
    }

    return 'سؤال غير معروف';
  }

  static String _readType(Map<String, dynamic> map) {
    final type = map['type'] ?? map['questionType'];

    if (type != null && type.toString().trim().isNotEmpty) {
      return type.toString().toUpperCase();
    }

    final question = map['question'];
    if (question is Map && question['type'] != null) {
      return question['type'].toString().toUpperCase();
    }

    if (map.containsKey('value') || map.containsKey('scaleValue')) {
      return 'SCALE';
    }

    return '';
  }

static String _readAnswer(Map<String, dynamic> map, String type) {
    if (type == 'SCALE') {
      final value =
          map['value'] ??
          map['scaleValue'] ??
          map['answerValue'] ??
          map['numericValue'];

      return value == null ? '-' : value.toString();
    }

    final answerText =
        map['answerText'] ??
        map['answerLabel'] ??
        map['label'] ??
        map['answer'] ??
        map['value'];

    if (answerText != null && answerText.toString().trim().isNotEmpty) {
      return answerText.toString();
    }

    final choice = map['choice'] ?? map['selectedChoice'];
    if (choice is Map) {
      final label =
          choice['label'] ??
          choice['text'] ??
          choice['title'] ??
          choice['value'];

      if (label != null && label.toString().trim().isNotEmpty) {
        return label.toString();
      }
    }

    final choices =
        map['choices'] ?? map['selectedChoices'] ?? map['choiceIds'];
    if (choices is List && choices.isNotEmpty) {
      return choices
          .map((choice) {
            if (choice is Map) {
              return choice['label'] ??
                  choice['text'] ??
                  choice['title'] ??
                  choice['value'] ??
                  '';
            }

            return choice.toString();
          })
          .where((e) => e.toString().trim().isNotEmpty)
          .join('، ');
    }

    return '-';
  }

  static int _readScore(Map<String, dynamic> map) {
    final directScore = map['score'] ?? map['answerScore'];
    final parsedDirect = int.tryParse(directScore?.toString() ?? '');
    if (parsedDirect != null) return parsedDirect;

    final choice = map['choice'];
    if (choice is Map) {
      final parsed = int.tryParse(choice['score']?.toString() ?? '');
      if (parsed != null) return parsed;
    }

    final choices = map['choices'];
    if (choices is List) {
      int total = 0;
      for (final choice in choices) {
        if (choice is Map) {
          total += int.tryParse(choice['score']?.toString() ?? '') ?? 0;
        }
      }
      return total;
    }

    final selectedChoices = map['selectedChoices'];
    if (selectedChoices is List) {
      int total = 0;
      for (final choice in selectedChoices) {
        if (choice is Map) {
          total += int.tryParse(choice['score']?.toString() ?? '') ?? 0;
        }
      }
      return total;
    }

    final value = map['value'] ?? map['scaleValue'];
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.012, min: 10, max: 14),
        vertical: responsiveHeight(context, 0.007, min: 5, max: 8),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE5F1),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0xFFFFC6DE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: _activeTextDirection,
        children: [
          customText(
            text: '$title: ',
            size: responsiveSize(context, 0.008, min: 11, max: 13),
            color: const Color(0xFFE83E8C),
            bold: true,
          ),
          customText(
            text: value,
            size: responsiveSize(context, 0.008, min: 11, max: 13),
            color: const Color(0xFF271648),
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _AssessmentAnswersContent extends StatelessWidget {
  const _AssessmentAnswersContent({required this.assessment});

  final PatientAssessment assessment;

  @override
  Widget build(BuildContext context) {
final answers = assessment.answers;

    final isSmall = getScreenWidth(context) < 850;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: EdgeInsets.all(responsiveSize(context, 0.014, min: 14, max: 18)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF7CFE0)),
      ),
      child: Directionality(
        textDirection: _activeTextDirection,
        child: Column(
          crossAxisAlignment: _activeCrossAxisStart,
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
                  return _AnswerMobileCard(index: index, item: answers[index]);
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

String getAnswerText(
  Map<String, dynamic> answer,
  Map<String, dynamic> question,
) {
  final choiceIds =
      (answer['choiceIds'] as List?)?.map((e) => e.toString()).toList() ?? [];

  final choices =
      (question['choices'] as List?)?.cast<Map<String, dynamic>>() ?? [];

  final labels = choices
      .where((c) => choiceIds.contains(c['id']))
      .map((c) => c['label'].toString())
      .toList();

  return labels.isEmpty ? '-' : labels.join(', ');
}

int getAnswerScore(Map<String, dynamic> answer, Map<String, dynamic> question) {
  final choiceIds =
      (answer['choiceIds'] as List?)?.map((e) => e.toString()).toList() ?? [];

  final choices =
      (question['choices'] as List?)?.cast<Map<String, dynamic>>() ?? [];

  return choices
      .where((c) => choiceIds.contains(c['id']))
      .fold<int>(0, (sum, c) => sum + ((c['score'] as num?)?.toInt() ?? 0));
}
