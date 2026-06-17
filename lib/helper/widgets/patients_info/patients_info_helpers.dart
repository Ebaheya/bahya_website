part of '../../../screens/patients_info.dart';

int activePatientFiltersCount(
  String? selectedDiseaseStatus,
  String? selectedTumorBiology,
  String? selectedSurgery,
  String? selectedChemotherapy,
  String? selectedRadiotherapy,
  String? selectedHormonalTherapy,
  String? selectedTargetedTherapy,
  String? selectedImmunotherapy,
) {
  int count = 0;
  if (selectedDiseaseStatus != null) count++;
  if (selectedTumorBiology != null) count++;
  if (selectedSurgery != null) count++;
  if (selectedChemotherapy != null) count++;
  if (selectedRadiotherapy != null) count++;
  if (selectedHormonalTherapy != null) count++;
  if (selectedTargetedTherapy != null) count++;
  if (selectedImmunotherapy != null) count++;
  return count;
}

ClinicalPatient buildClinicalPatient(PatientModel patient) {
  return ClinicalPatient(
    id: patient.id,
    fileNumber: patient.displayCrn,
    name: patient.fullName,
    age: patient.age,
    phone: patient.phone,
    emergencyContactName: patient.emergencyContactName ?? '',
    emergencyContactPhone: patient.emergencyContactPhone ?? '',
    registrationDate: patient.displayRegistrationDate,
    comorbidities: patient.comorbidities.join(', '),
    bmi: patient.bmi?.toString() ?? '',
    familyHistory: patient.familyHistory,
    menopausalStatus: readablePatientValue(patient.menopausalStatus),
    diagnosisDate: patient.displayDateOfDiagnosis,
    stageAtDiagnosis: readablePatientValue(patient.stageAtDiagnosis),
    diseaseStatus: readablePatientValue(patient.diseaseStatus),
    tumorBiology: readablePatientValue(patient.tumorBiology),
    surgery: readablePatientValue(patient.surgery),
    chemotherapy: readablePatientValue(patient.chemotherapy),
    radiotherapy: _yesNoFromBool(patient.radiotherapy),
    hormonalTherapy: _yesNoFromBool(patient.hormonalTherapy),
    targetedTherapy: _yesNoFromBool(patient.targetedTherapy),
    immunotherapy: _yesNoFromBool(patient.immunotherapy),
    drugs: patient.drugs,
    assessments: patient.latestAssessments
        .map(
          (assessment) => PatientAssessment(
            formName: assessment.templateKey,
            submitDate: formatPatientDate(assessment.createdAt),
            score: assessment.score,
          ),
        )
        .toList(),
  );
}

bool? _yesNoToBool(String? value) {
  if (value == 'Yes') return true;
  if (value == 'No') return false;
  return null;
}

String _yesNoFromBool(bool? value) {
  if (value == null) return '';
  return value ? 'Yes' : 'No';
}

String? _toPatientApiValue(String? value) {
  switch (value) {
    case 'Newly diagnosed':
      return 'NEWLY_DIAGNOSED';
    case 'Active treatment':
      return 'ACTIVE_TREATMENT';
    case 'Follow-up':
      return 'FOLLOW_UP';
    case 'Recurrence':
      return 'RECURRENCE';
    case 'Metastatic':
      return 'METASTATIC';
    case 'Luminal A':
      return 'LUMINAL_A';
    case 'Luminal B':
      return 'LUMINAL_B';
    case 'HER2-enriched':
      return 'HER2_ENRICHED';
    case 'TNBC':
      return 'TNBC';
    case 'None':
      return 'NONE';
    case 'Breast Conservative surgery':
      return 'BREAST_CONSERVATIVE';
    case 'Mastectomy':
      return 'MASTECTOMY';
    case 'No':
      return 'NO';
    case 'Neoadjuvant':
      return 'NEOADJUVANT';
    case 'Adjuvant':
      return 'ADJUVANT';
    default:
      return value;
  }
}

int _gridCount(double w) {
  if (w >= 1350) return 3;
  if (w >= 900) return 2;
  return 1;
}

double _gridExtent(BuildContext context) {
  final w = getScreenWidth(context);

  if (w >= 1350) {
    return responsiveHeight(context, 0.47, min: 420, max: 480);
  }

  if (w >= 900) {
    return responsiveHeight(context, 0.47, min: 400, max: 470);
  }

  return responsiveHeight(context, 0.56, min: 470, max: 560);
}
