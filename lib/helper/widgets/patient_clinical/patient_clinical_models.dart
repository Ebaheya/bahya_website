part of '../../../screens/doctor/patient_clinical_details.dart';

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
  final String doctorNote;
  final List<PatientAnswer> answers;

  PatientAssessment({
    required this.formName,
    required this.submitDate,
    required this.score,
    this.doctorNote = '',
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
