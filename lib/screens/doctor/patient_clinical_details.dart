import 'dart:typed_data';

import 'package:bahya_website/bloc/cubit/patient_assessment_review_cubit.dart';
import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_dropdown.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/animated_home_background.dart';
import 'package:bahya_website/helper/widgets/doctor_page_header.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part '../../helper/widgets/patient_clinical/patient_clinical_widget.dart';
part '../../helper/widgets/patient_clinical/patient_clinical_components.dart';
part '../../helper/widgets/patient_clinical/patient_clinical_models.dart';
part '../../helper/widgets/patient_clinical/patient_clinical_pending_shell.dart';
part '../../helper/widgets/patient_clinical/patient_clinical_pending_card.dart';
part '../../helper/widgets/patient_clinical/patient_clinical_review_answers.dart';
part '../../helper/widgets/patient_clinical/patient_clinical_assessment_details.dart';
part '../../helper/widgets/patient_clinical/patient_clinical_data_cards.dart';
part '../../helper/widgets/patient_clinical/patient_clinical_header_components.dart';

class PatientClinicalDetails extends StatefulWidget {
  final ClinicalPatient patient;

  const PatientClinicalDetails({super.key, required this.patient});

  @override
  State<PatientClinicalDetails> createState() => _PatientClinicalDetailsState();
}

class _PatientClinicalDetailsState extends State<PatientClinicalDetails>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pageController;

  int selectedTab = 0;
  bool showEmergencyInfo = false;
  List<PatientAssessment> officialAssessments = [];
  bool isLoadingAssessments = false;
  String? assessmentsError;

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _loadOfficialAssessments();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _animatedItem({required int index, required Widget child}) {
    final animation = CurvedAnimation(
      parent: _pageController,
      curve: Interval(
        (index * 0.11).clamp(0.0, 0.75),
        1,
        curve: Curves.easeOutCubic,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

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
      TextCellValue('Doctor Note'),
      TextCellValue('Question'),
      TextCellValue('Answer'),
      TextCellValue('Answer Score'),
    ]);

    for (final assessment in patient.assessments) {
      final answers =  assessment.answers;

      for (final answer in answers) {
        assessmentsSheet.appendRow([
          TextCellValue(assessment.formName),
          TextCellValue(assessment.submitDate),
          TextCellValue(assessment.score.toString()),
          TextCellValue(
            assessment.doctorNote.isEmpty ? '-' : assessment.doctorNote,
          ),
          TextCellValue(answer.question),
          TextCellValue(answer.answer),
          TextCellValue(answer.score.toString()),
        ]);
      }
    }

    final bytes = excel.encode();
    if (bytes == null) return;

    await FileSaver.instance.saveFile(
      name: '${patient.fileNumber}_${patient.name}_clinical_data.xlsx',
      bytes: Uint8List.fromList(bytes),
      mimeType: MimeType.microsoftExcel,
    );
  }

  Future<void> _loadOfficialAssessments() async {
    setState(() {
      isLoadingAssessments = true;
      assessmentsError = null;
    });

    try {
      final repo = AppRepository();
      final list = await repo.getPatientAssessments(widget.patient.id);

      final detailedList = <Map<String, dynamic>>[];

      for (final item in list) {
        final submission = item['submission'];
        final submissionId =
            item['submissionId']?.toString() ??
            (submission is Map ? submission['id']?.toString() : null);

        if (submissionId == null || submissionId.isEmpty) {
          detailedList.add(item);
          continue;
        }

        try {
          final submissionDetails = await repo.getSubmissionDetails(
            submissionId,
          );

          detailedList.add({
            ...item,
            'submission': {
              if (submission is Map) ...submission,
              ...submissionDetails,
            },
          });
        } catch (e) {
          debugPrint('ASSESSMENT SUBMISSION DETAILS ERROR => $e');
          detailedList.add(item);
        }
      }

      final mapped = detailedList.map(_mapAssessment).toList();

      if (!mounted) return;

      setState(() {
        officialAssessments = mapped;
        isLoadingAssessments = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingAssessments = false;
        assessmentsError = 'حدث خطأ أثناء تحميل التقييمات.';
      });

      debugPrint('OFFICIAL ASSESSMENTS ERROR => $e');
    }
  }

  PatientAssessment _mapAssessment(Map<String, dynamic> json) {
    final submission = json['submission'];
    final assessment = submission is Map ? submission['assessment'] : null;

    return PatientAssessment(
      formName:
          json['templateKey']?.toString() ??
          json['template']?['name']?.toString() ??
          json['form']?['name']?.toString() ??
          'تقييم',
      submitDate:
          json['createdAt']?.toString().split('T').first ??
          json['updatedAt']?.toString().split('T').first ??
          '-',
      score: int.tryParse(json['score']?.toString() ?? '') ?? 0,
      doctorNote: _readDoctorNote(json, assessment),
      answers: _mapAssessmentAnswers(json),
    );
  }

  String _readDoctorNote(Map<String, dynamic> json, dynamic nestedAssessment) {
    final direct = json['doctorNote'];
    if (direct != null && direct.toString().trim().isNotEmpty) {
      return direct.toString().trim();
    }

    if (nestedAssessment is Map) {
      final nested = nestedAssessment['doctorNote'] ?? nestedAssessment['note'];
      if (nested != null && nested.toString().trim().isNotEmpty) {
        return nested.toString().trim();
      }
    }

    final note = json['note'] ?? json['doctor_notes'] ?? json['doctorNotes'];
    if (note != null && note.toString().trim().isNotEmpty) {
      return note.toString().trim();
    }

    return '';
  }

  List<PatientAnswer> _mapAssessmentAnswers(Map<String, dynamic> json) {
    final submission = json['submission'] ?? json['formSubmission'];

    if (submission is! Map) return [];

    final rawAnswers = submission['answers'];
    final formVersion = submission['formVersion'];
    final rawQuestions = formVersion is Map ? formVersion['questions'] : null;

    if (rawAnswers is! List || rawQuestions is! List) return [];

    final questionsById = <String, Map<String, dynamic>>{};

    for (final q in rawQuestions) {
      if (q is Map) {
        final question = Map<String, dynamic>.from(q);
        final id = question['id']?.toString();

        if (id != null && id.isNotEmpty) {
          questionsById[id] = question;
        }
      }
    }

    return rawAnswers.map((raw) {
      if (raw is! Map) {
        return const PatientAnswer(
          question: 'سؤال غير معروف',
          answer: '-',
          score: 0,
        );
      }

      final answerMap = Map<String, dynamic>.from(raw);
      final questionId = answerMap['questionId']?.toString();
      final question = questionId == null ? null : questionsById[questionId];

      if (question == null) {
        return const PatientAnswer(
          question: 'سؤال غير معروف',
          answer: '-',
          score: 0,
        );
      }

      final questionText =
          question['text']?.toString() ??
          question['title']?.toString() ??
          question['label']?.toString() ??
          'سؤال غير معروف';

      final choiceIds =
          (answerMap['choiceIds'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      final choices = question['choices'];

      String answerText = '-';
      int answerScore = 0;

      if (choices is List && choiceIds.isNotEmpty) {
        final selectedChoices = choices.where((choice) {
          if (choice is! Map) return false;
          return choiceIds.contains(choice['id']?.toString());
        }).toList();

        answerText = selectedChoices
            .map((choice) {
              final c = Map<String, dynamic>.from(choice as Map);
              return c['label'] ?? c['text'] ?? c['title'] ?? c['value'] ?? '';
            })
            .where((e) => e.toString().trim().isNotEmpty)
            .join('، ');

        answerScore = selectedChoices.fold<int>(0, (sum, choice) {
          final c = Map<String, dynamic>.from(choice as Map);
          return sum + (int.tryParse(c['score']?.toString() ?? '') ?? 0);
        });
      } else {
        final value =
            answerMap['value'] ??
            answerMap['scaleValue'] ??
            answerMap['answerValue'];

        answerText = value?.toString() ?? '-';
        answerScore = int.tryParse(value?.toString() ?? '') ?? 0;
      }

      return PatientAnswer(
        question: questionText,
        answer: answerText.isEmpty ? '-' : answerText,
        score: answerScore,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = locale.languageCode == 'en';

        return BlocProvider(
          create: (_) =>
              PatientAssessmentReviewCubit(AppRepository())
                ..loadPatientPendingSubmissions(widget.patient.id),
          child: Scaffold(
            backgroundColor: const Color(0xFFFDF7FB),
            body: AnimatedHomeBackground(
              child: Directionality(
                textDirection: isEnglish
                    ? TextDirection.ltr
                    : TextDirection.rtl,
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 700;
                      final horizontalPadding = responsiveSize(
                        context,
                        isMobile ? 0.018 : 0.025,
                        min: isMobile ? 10 : 16,
                        max: isMobile ? 14 : 42,
                      );
                      final verticalPadding = responsiveHeight(
                        context,
                        isMobile ? 0.018 : 0.03,
                        min: isMobile ? 12 : 20,
                        max: isMobile ? 18 : 40,
                      );

                      return SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: verticalPadding,
                        ),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: isMobile ? constraints.maxWidth : 1320,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _animatedItem(
                                  index: 0,
                                  child: animatedPageHeader(
                                    context: context,
                                    title: 'معلومات المريض',
                                    subtitle:
                                        '${widget.patient.name} - ${widget.patient.fileNumber}',
                                    icon: Icons.assignment_ind_rounded,
                                    showBack: true,
                                    onBackTap: () {
                                      if (context.canPop()) {
                                        context.pop();
                                      } else {
                                        context.go('/patient_info');
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: responsiveHeight(
                                    context,
                                    0.022,
                                    min: 16,
                                    max: 26,
                                  ),
                                ),
                                _animatedItem(
                                  index: 1,
                                  child: Center(
                                    child: _ExportExcelCard(
                                      onTap: exportPatientToExcel,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: responsiveHeight(
                                    context,
                                    0.026,
                                    min: 18,
                                    max: 30,
                                  ),
                                ),
                                _animatedItem(
                                  index: 2,
                                  child: _ClinicalModernSection(
                                    title: 'بيانات المريض',
                                    subtitle:
                                        'البيانات الأساسية والطبية الخاصة بالمريض',
                                    icon: Icons.person_search_rounded,
                                    child: _PatientHeaderCard(
                                      patient: widget.patient,
                                      showEmergencyInfo: showEmergencyInfo,
                                      onMoreInfoTap: () {
                                        setState(() {
                                          showEmergencyInfo =
                                              !showEmergencyInfo;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: responsiveHeight(
                                    context,
                                    0.025,
                                    min: 18,
                                    max: 28,
                                  ),
                                ),
                                _animatedItem(
                                  index: 3,
                                  child: _TabsBar(
                                    selectedTab: selectedTab,
                                    onTabChanged: (index) {
                                      setState(() => selectedTab = index);

                                      if (index == 1) {
                                        _loadOfficialAssessments();
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: responsiveHeight(
                                    context,
                                    0.025,
                                    min: 18,
                                    max: 28,
                                  ),
                                ),
                                _animatedItem(
                                  index: 4,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 350),
                                    switchInCurve: Curves.easeOutCubic,
                                    switchOutCurve: Curves.easeInCubic,
                                    layoutBuilder:
                                        (currentChild, previousChildren) {
                                          return Stack(
                                            alignment: Alignment.topCenter,
                                            children: [
                                              ...previousChildren,
                                              if (currentChild != null)
                                                currentChild,
                                            ],
                                          );
                                        },
                                    transitionBuilder: (child, animation) {
                                      final slideAnimation = Tween<Offset>(
                                        begin: Offset(
                                          isEnglish ? 0.04 : -0.04,
                                          0,
                                        ),
                                        end: Offset.zero,
                                      ).animate(animation);

                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: slideAnimation,
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: child,
                                          ),
                                        ),
                                      );
                                    },
                                    child: _ClinicalModernSection(
                                      key: ValueKey(selectedTab),
                                      title: _sectionTitle,
                                      subtitle: _sectionSubtitle,
                                      icon: _sectionIcon,
                                      child: _currentTabContent(),
                                    ),
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
              ),
            ),
          ),
        );
      },
    );
  }

  String get _sectionTitle {
    if (selectedTab == 0) return 'البيانات السريرية';
    if (selectedTab == 1) return 'التقييمات السابقة';
    return 'المراجعات المعلقة';
  }

  String get _sectionSubtitle {
    if (selectedTab == 0) return 'عرض تفاصيل الحالة وخطة العلاج';
    if (selectedTab == 1) return 'متابعة إجابات وتقييمات المريض';
    return 'مراجعة التقييمات التي تحتاج قرار الطبيب';
  }

  IconData get _sectionIcon {
    if (selectedTab == 0) return Icons.medical_information_rounded;
    if (selectedTab == 1) return Icons.fact_check_rounded;
    return Icons.pending_actions_rounded;
  }

  Widget _currentTabContent() {
    if (selectedTab == 0) {
      return _ClinicalDataTab(
        key: const ValueKey('clinical_tab'),
        patient: widget.patient,
      );
    }

    if (selectedTab == 1) {
      if (isLoadingAssessments) {
        return Container(
          key: const ValueKey('assessments_loading'),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 70),
          child: Center(child: customLoading()),
        );
      }

      if (assessmentsError != null) {
        return Container(
          key: const ValueKey('assessments_error'),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF7D6E6)),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFE83E8C),
                size: 42,
              ),
              const SizedBox(height: 12),
              customText(
                text: assessmentsError!,
                size: responsiveSize(context, 0.01, min: 14, max: 18),
                color: const Color(0xFF271648),
                bold: true,
                maxLines: 3,
              ),
            ],
          ),
        );
      }

      return _AssessmentsTab(
        key: const ValueKey('assessments_tab'),
        assessments: officialAssessments,
      );
    }

    return _PendingReviewTab(
      key: const ValueKey('pending_review_tab'),
      patientId: widget.patient.id,
    );
  }
}

class _ExportExcelCard extends StatefulWidget {
  final VoidCallback onTap;

  const _ExportExcelCard({required this.onTap});

  @override
  State<_ExportExcelCard> createState() => _ExportExcelCardState();
}

class _ExportExcelCardState extends State<_ExportExcelCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 700;

    return MouseRegion(
      onEnter: (_) {
        if (!isMobile) setState(() => _hover = true);
      },
      onExit: (_) {
        if (!isMobile) setState(() => _hover = false);
      },
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.020, min: 22, max: 28),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          width: isMobile ? double.infinity : 420,
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.020, min: 18, max: 26),
            vertical: responsiveHeight(context, 0.018, min: 16, max: 22),
          ),
          transform: Matrix4.identity()
            ..translate(0.0, _hover && !isMobile ? -5.0 : 0.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFEFBFD),
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.020, min: 22, max: 28),
            ),
            border: Border.all(
              color: _hover
                  ? const Color(0xFFE7549B).withValues(alpha: 0.45)
                  : const Color(0xFFE7549B).withValues(alpha: 0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF831843,
                ).withValues(alpha: _hover ? 0.16 : 0.09),
                blurRadius: _hover ? 30 : 22,
                offset: Offset(0, _hover ? 14 : 9),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: responsiveSize(context, 0.052, min: 50, max: 62),
                height: responsiveSize(context, 0.052, min: 50, max: 62),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE7549B), Color(0xFF8A2BE2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(
                    responsiveSize(context, 0.016, min: 18, max: 22),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE7549B).withValues(alpha: 0.24),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.table_chart_outlined,
                  color: Colors.white,
                  size: responsiveSize(context, 0.026, min: 26, max: 32),
                ),
              ),
              SizedBox(width: responsiveSize(context, 0.026, min: 12, max: 18)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText(
                      text: 'تصدير Excel',
                      size: responsiveSize(context, 0.038, min: 15, max: 18),
                      color: const Color(0xFF14213D),
                      bold: true,
                      isCenter: false,
                      maxLines: 1,
                    ),
                    SizedBox(
                      height: responsiveHeight(context, 0.006, min: 4, max: 7),
                    ),
                    customText(
                      text: 'تحميل بيانات المريض والتقييمات',
                      size: responsiveSize(context, 0.030, min: 11, max: 13),
                      color: Colors.grey[600],
                      isCenter: false,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.add,
                size: responsiveSize(context, 0.030, min: 30, max: 40),
                color: const Color(0xFFE7549B),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClinicalModernSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _ClinicalModernSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  State<_ClinicalModernSection> createState() => _ClinicalModernSectionState();
}

class _ClinicalModernSectionState extends State<_ClinicalModernSection> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;

    return MouseRegion(
      onEnter: (_) {
        if (!isMobile) setState(() => _hover = true);
      },
      onExit: (_) {
        if (!isMobile) setState(() => _hover = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        width: double.infinity,
        transform: Matrix4.identity()
          ..translate(0.0, _hover && !isMobile ? -4.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.024, min: 26, max: 34),
          ),
          border: Border.all(
            color: _hover
                ? const Color(0xFFE7549B).withValues(alpha: 0.30)
                : Colors.white.withValues(alpha: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF14213D,
              ).withValues(alpha: _hover ? 0.14 : 0.08),
              blurRadius: _hover ? 34 : 24,
              offset: Offset(0, _hover ? 18 : 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.024, min: 26, max: 34),
          ),
          child: Column(
            children: [
              _ClinicalSectionHeader(
                title: widget.title,
                subtitle: widget.subtitle,
                icon: widget.icon,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(
                  responsiveSize(context, 0.018, min: 16, max: 26),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClinicalSectionHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ClinicalSectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  State<_ClinicalSectionHeader> createState() => _ClinicalSectionHeaderState();
}

class _ClinicalSectionHeaderState extends State<_ClinicalSectionHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final value = _animation.value;

        return Container(
          height: isMobile ? 86 : 96,
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.020, min: 18, max: 28),
            vertical: responsiveHeight(context, 0.014, min: 14, max: 18),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Color(0xFFE7549B),
                Color(0xFFC044D8),
                Color(0xFF8A2BE2),
              ],
              begin: Alignment(-1 + value, -1),
              end: Alignment(1 - value, 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: responsiveSize(context, 0.052, min: 46, max: 54),
                height: responsiveSize(context, 0.052, min: 46, max: 54),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(
                    responsiveSize(context, 0.016, min: 15, max: 18),
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: responsiveSize(context, 0.026, min: 24, max: 28),
                ),
              ),
              SizedBox(width: responsiveSize(context, 0.018, min: 12, max: 16)),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText(
                      text: widget.title,
                      size: responsiveSize(context, 0.042, min: 18, max: 20),
                      color: Colors.white,
                      bold: true,
                      isCenter: false,
                      maxLines: isMobile ? 2 : 1,
                    ),
                    SizedBox(
                      height: responsiveHeight(context, 0.005, min: 4, max: 6),
                    ),
                    customText(
                      text: widget.subtitle,
                      size: responsiveSize(context, 0.030, min: 12, max: 13),
                      color: Colors.white.withValues(alpha: 0.78),
                      isCenter: false,
                      maxLines: isMobile ? 2 : 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

