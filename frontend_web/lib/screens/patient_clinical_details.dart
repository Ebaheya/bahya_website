import 'dart:typed_data';

import 'package:bahya_website/bloc/cubit/patient_assessment_review_cubit.dart';
import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_dropDown.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part '../helper/widgets/patient_clinical/patient_clinical_widget.dart';
part '../helper/widgets/patient_clinical/patient_clinical_components.dart';

class PatientClinicalDetails extends StatefulWidget {
  final ClinicalPatient patient;

  const PatientClinicalDetails({super.key, required this.patient});

  @override
  State<PatientClinicalDetails> createState() => _PatientClinicalDetailsState();
}

class _PatientClinicalDetailsState extends State<PatientClinicalDetails> {
  int selectedTab = 0;
  bool showEmergencyInfo = false;
  List<PatientAssessment> officialAssessments = [];
  bool isLoadingAssessments = false;
  String? assessmentsError;
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
  void initState() {
    super.initState();
    _loadOfficialAssessments();
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

      debugPrint('OFFICIAL ASSESSMENTS DETAILED => $detailedList');
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
      answers: _mapAssessmentAnswers(json),
    );
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
          create: (_) => PatientAssessmentReviewCubit(AppRepository())
            ..loadPatientPendingSubmissions(widget.patient.id),
          child: Scaffold(
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
            body: Directionality(
              textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
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
                              _PatientHeaderCard(
                                patient: widget.patient,
                                showEmergencyInfo: showEmergencyInfo,
                                onMoreInfoTap: () {
                                  setState(() {
                                    showEmergencyInfo = !showEmergencyInfo;
                                  });
                                },
                              ),
                              SizedBox(
                                height: responsiveHeight(
                                  context,
                                  0.025,
                                  min: 18,
                                  max: 28,
                                ),
                              ),
                              _TabsBar(
                                selectedTab: selectedTab,
                                onTabChanged: (index) {
                                  setState(() => selectedTab = index);

                                  if (index == 1) {
                                    _loadOfficialAssessments();
                                  }
                                },
                              ),
                              SizedBox(
                                height: responsiveHeight(
                                  context,
                                  0.025,
                                  min: 18,
                                  max: 28,
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 350),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                layoutBuilder: (currentChild, previousChildren) {
                                  return Stack(
                                    alignment: Alignment.topCenter,
                                    children: [
                                      ...previousChildren,
                                      if (currentChild != null) currentChild,
                                    ],
                                  );
                                },
                                transitionBuilder: (child, animation) {
                                  final slideAnimation = Tween<Offset>(
                                    begin: Offset(isEnglish ? 0.04 : -0.04, 0),
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
                                child: _currentTabContent(),
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
        );
      },
    );
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
enum BadgeType { success, warning, danger, info, status, neutral }

class _DataRowItem {
  final String label;
  final String value;
  final BadgeType? badgeType;

  _DataRowItem(this.label, this.value, {this.badgeType});
}

class ClinicalPatient {
  final String id;
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
    required this.id,
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
