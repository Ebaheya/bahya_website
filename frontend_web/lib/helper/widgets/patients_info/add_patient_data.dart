part of '../../../screens/patients_info.dart';

class NewPatientData {
  final String crn;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String dateOfBirth;
  final String gender;
  final String address;
  final String emergencyContactName;
  final String emergencyContactPhone;
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

  const NewPatientData({
    required this.crn,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
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
  });

  Map<String, dynamic> toApiBody(String? Function(String?) toApiValue) {
    final body = <String, dynamic>{
      'crn': crn,
      'fullName': name,
      'email': email,
      'password': password,
      'phone': phone,
      'dateOfBirth': _dateForApi(dateOfBirth),
      'gender': gender,
      'address': address,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'dateOfDiagnosis': _dateForApi(diagnosisDate),
      'diseaseStatus': toApiValue(diseaseStatus),
      'tumorBiology': toApiValue(tumorBiology),
      'surgery': toApiValue(surgery),
      'chemotherapy': toApiValue(chemotherapy),
      'radiotherapy': _yesNoBool(radiotherapy),
      'hormonalTherapy': _yesNoBool(hormonalTherapy),
      'targetedTherapy': _yesNoBool(targetedTherapy),
      'immunotherapy': _yesNoBool(immunotherapy),
    };

    final parsedBmi = double.tryParse(bmi);
    if (parsedBmi != null) body['bmi'] = parsedBmi;

    final stageValue = _stageForApi(stageAtDiagnosis);
    if (stageValue != null) body['stageAtDiagnosis'] = stageValue;

    final menopausalValue = _menopausalForApi(menopausalStatus);
    if (menopausalValue != null) body['menopausalStatus'] = menopausalValue;

    body['medicalHistory'] = {
      if (comorbidities.trim().isNotEmpty)
        'comorbidities': _splitForApi(comorbidities),
      if (familyHistory.trim().isNotEmpty) 'familyHistory': familyHistory,
      if (drugs.isNotEmpty) 'drugs': drugs,
    };

    return body;
  }

  static List<String> _splitForApi(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static bool _yesNoBool(String value) => value == 'Yes';

  static String? _stageForApi(String value) {
    final normalized = value
        .trim()
        .toUpperCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    switch (normalized) {
      case 'STAGE_0':
      case '0':
        return 'STAGE_0';
      case 'STAGE_I':
      case 'I':
      case '1':
      case 'الأولى':
      case 'الاولى':
      case 'الاوله':
        return 'STAGE_I';
      case 'STAGE_II':
      case 'II':
      case '2':
      case 'الثانية':
      case 'التانية':
        return 'STAGE_II';
      case 'STAGE_III':
      case 'III':
      case '3':
      case 'الثالثة':
      case 'التالتة':
        return 'STAGE_III';
      case 'STAGE_IV':
      case 'IV':
      case '4':
      case 'الرابعة':
      case 'الرابعه':
        return 'STAGE_IV';
      default:
        return null;
    }
  }

  static String? _menopausalForApi(String value) {
    final normalized = value
        .trim()
        .toUpperCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    if (normalized.isEmpty) return null;

    switch (normalized) {
      case 'PRE':
      case 'PRE_MENOPAUSAL':
        return 'PRE_MENOPAUSAL';
      case 'PERI':
      case 'PERI_MENOPAUSAL':
        return 'PERI_MENOPAUSAL';
      case 'POST':
      case 'POST_MENOPAUSAL':
        return 'POST_MENOPAUSAL';
      default:
        return null;
    }
  }

  static DateTime? parseDate(String value) {
    final trimmed = value.trim();

    final direct = DateTime.tryParse(trimmed);
    if (direct != null) return direct;

    final slashParts = trimmed.split('/');
    if (slashParts.length == 3) {
      final month = int.tryParse(slashParts[0]);
      final day = int.tryParse(slashParts[1]);
      final year = int.tryParse(slashParts[2]);

      if (month != null && day != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    final dashParts = trimmed.split('-');
    if (dashParts.length == 3) {
      final year = int.tryParse(dashParts[0]);
      final month = int.tryParse(dashParts[1]);
      final day = int.tryParse(dashParts[2]);

      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
    }

    return null;
  }

  static String _dateForApi(String value) {
    final date = parseDate(value);
    if (date == null) return value.trim();

    return _formatDate(date);
  }

  static String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
