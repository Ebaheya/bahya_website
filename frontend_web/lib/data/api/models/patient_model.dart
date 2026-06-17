class PatientsResponseModel {
  final List<PatientModel> data;
  final int page;
  final int pageSize;
  final int total;

  const PatientsResponseModel({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  factory PatientsResponseModel.fromJson(Map<String, dynamic> json) {
    return PatientsResponseModel(
      data: (json['data'] as List? ?? [])
          .map((e) => PatientModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      page: _asInt(json['page'], fallback: 1),
      pageSize: _asInt(json['pageSize'], fallback: 20),
      total: _asInt(json['total']),
    );
  }

  PatientsResponseModel sorted({String? sortBy, String? sortOrder}) {
    if (sortBy == null || data.length < 2) return this;

    final sortedData = [...data];
    final descending = sortOrder?.toLowerCase() != 'asc';

    int compareString(String a, String b) {
      return descending ? b.compareTo(a) : a.compareTo(b);
    }

    int compareInt(int a, int b) {
      return descending ? b.compareTo(a) : a.compareTo(b);
    }

    int compareDate(String? a, String? b) {
      final first = DateTime.tryParse(a ?? '') ?? DateTime(1900);
      final second = DateTime.tryParse(b ?? '') ?? DateTime(1900);
      return descending ? second.compareTo(first) : first.compareTo(second);
    }

    switch (sortBy) {
      case 'fullName':
        sortedData.sort((a, b) => compareString(a.fullName, b.fullName));
        break;
      case 'age':
        sortedData.sort((a, b) => compareInt(a.age, b.age));
        break;
      case 'dateOfBirth':
        sortedData.sort((a, b) => compareDate(a.dateOfBirth, b.dateOfBirth));
        break;
      case 'createdAt':
      default:
        sortedData.sort((a, b) => compareDate(a.createdAt, b.createdAt));
        break;
    }

    return PatientsResponseModel(
      data: sortedData,
      page: page,
      pageSize: pageSize,
      total: total,
    );
  }
}

class PatientModel {
  final String id;
  final String userId;
  final String crn;
  final String fullName;
  final String email;
  final String role;
  final bool isActive;
  final String phone;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final Map<String, dynamic>? medicalHistory;
  final Map<String, dynamic>? socialStatus;
  final Map<String, dynamic>? financials;
  final double? bmi;
  final String? menopausalStatus;
  final String? dateOfDiagnosis;
  final String? stageAtDiagnosis;
  final String? diseaseStatus;
  final String? tumorBiology;
  final String? surgery;
  final String? chemotherapy;
  final bool? radiotherapy;
  final bool? hormonalTherapy;
  final bool? targetedTherapy;
  final bool? immunotherapy;
  final List<PatientLatestAssessmentModel> latestAssessments;
  final String? createdAt;
  final String? updatedAt;

  const PatientModel({
    required this.id,
    required this.userId,
    required this.crn,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isActive,
    required this.phone,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.medicalHistory,
    this.socialStatus,
    this.financials,
    this.bmi,
    this.menopausalStatus,
    this.dateOfDiagnosis,
    this.stageAtDiagnosis,
    this.diseaseStatus,
    this.tumorBiology,
    this.surgery,
    this.chemotherapy,
    this.radiotherapy,
    this.hormonalTherapy,
    this.targetedTherapy,
    this.immunotherapy,
    this.latestAssessments = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      crn: json['crn']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      isActive: json['isActive'] == true,
      phone: json['phone']?.toString() ?? '',
      dateOfBirth: json['dateOfBirth']?.toString(),
      gender: json['gender']?.toString(),
      address: json['address']?.toString(),
      emergencyContactName: json['emergencyContactName']?.toString(),
      emergencyContactPhone: json['emergencyContactPhone']?.toString(),
      medicalHistory: _asMap(json['medicalHistory']),
      socialStatus: _asMap(json['socialStatus']),
      financials: _asMap(json['financials']),
      bmi: _asDouble(json['bmi']),
      menopausalStatus: json['menopausalStatus']?.toString(),
      dateOfDiagnosis: json['dateOfDiagnosis']?.toString(),
      stageAtDiagnosis: json['stageAtDiagnosis']?.toString(),
      diseaseStatus: json['diseaseStatus']?.toString(),
      tumorBiology: json['tumorBiology']?.toString(),
      surgery: json['surgery']?.toString(),
      chemotherapy: json['chemotherapy']?.toString(),
      radiotherapy: _asBool(json['radiotherapy']),
      hormonalTherapy: _asBool(json['hormonalTherapy']),
      targetedTherapy: _asBool(json['targetedTherapy']),
      immunotherapy: _asBool(json['immunotherapy']),
      latestAssessments: (json['latestAssessments'] as List? ?? [])
          .map(
            (e) => PatientLatestAssessmentModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  String get displayCrn => crn.isEmpty ? id : crn;
  String get displayRegistrationDate => _formatDate(createdAt);
  String get displayDateOfDiagnosis => _formatDate(dateOfDiagnosis);
  String get displayDateOfBirth => _formatDate(dateOfBirth);

  int get age {
    final raw = dateOfBirth;
    if (raw == null || raw.isEmpty) return 0;
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return 0;
    final today = DateTime.now();
    var value = today.year - parsed.year;
    final hadBirthday =
        today.month > parsed.month ||
        (today.month == parsed.month && today.day >= parsed.day);
    if (!hadBirthday) value--;
    return value < 0 ? 0 : value;
  }

  List<String> get comorbidities {
    return _asStringList(medicalHistory?['comorbidities']);
  }

  List<String> get drugs {
    return _asStringList(medicalHistory?['drugs']);
  }

  String get familyHistory {
    return medicalHistory?['familyHistory']?.toString() ?? '';
  }
}

class PatientLatestAssessmentModel {
  final String id;
  final String templateKey;
  final int score;
  final String status;
  final String createdAt;

  const PatientLatestAssessmentModel({
    required this.id,
    required this.templateKey,
    required this.score,
    required this.status,
    required this.createdAt,
  });

  factory PatientLatestAssessmentModel.fromJson(Map<String, dynamic> json) {
    return PatientLatestAssessmentModel(
      id: json['id']?.toString() ?? '',
      templateKey: json['templateKey']?.toString() ?? '',
      score: _asInt(json['score']),
      status: json['status']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value.toString().toLowerCase();
  if (normalized == 'true') return true;
  if (normalized == 'false') return false;
  return null;
}

List<String> _asStringList(dynamic value) {
  if (value is List) return value.map((e) => e.toString()).toList();
  if (value == null) return const [];
  return [value.toString()];
}

String _formatDate(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  final month = parsed.month.toString().padLeft(2, '0');
  final day = parsed.day.toString().padLeft(2, '0');
  return '${parsed.year} - $month - $day';
}

String formatPatientDate(String? raw) => _formatDate(raw);

String readablePatientValue(String? value) {
  switch (value) {
    case 'NEWLY_DIAGNOSED':
      return 'Newly diagnosed';
    case 'ACTIVE_TREATMENT':
      return 'Active treatment';
    case 'FOLLOW_UP':
      return 'Follow-up';
    case 'RECURRENCE':
      return 'Recurrence';
    case 'METASTATIC':
      return 'Metastatic';
    case 'LUMINAL_A':
      return 'Luminal A';
    case 'LUMINAL_B':
      return 'Luminal B';
    case 'HER2_ENRICHED':
      return 'HER2-enriched';
    case 'TNBC':
      return 'TNBC';
    case 'TRIPLE_NEGATIVE':
      return 'Triple negative';
    case 'NONE':
      return 'None';
    case 'BREAST_CONSERVATIVE':
      return 'Breast Conservative surgery';
    case 'BREAST_CONSERVATIVE_SURGERY':
      return 'Breast Conservative surgery';
    case 'MASTECTOMY':
      return 'Mastectomy';
    case 'NO':
      return 'No';
    case 'NEOADJUVANT':
      return 'Neoadjuvant';
    case 'ADJUVANT':
      return 'Adjuvant';
    case 'PALLIATIVE':
      return 'Palliative';
    case 'METASTATIC_CHEMOTHERAPY':
      return 'Metastatic';
    case 'PRE_MENOPAUSAL':
      return 'Pre-menopausal';
    case 'PERI_MENOPAUSAL':
      return 'Peri-menopausal';
    case 'POST_MENOPAUSAL':
      return 'Post-menopausal';
    case 'FEMALE':
      return 'Female';
    case 'MALE':
      return 'Male';
    case 'OTHER':
      return 'Other';
    case 'ACTIVE':
      return 'Active';
    case 'INACTIVE':
      return 'Inactive';
    case 'PENDING':
      return 'Pending';
    case 'COMPLETED':
      return 'Completed';
    case 'STAGE_0':
      return 'Stage 0';
    case 'STAGE_I':
      return 'Stage I';
    case 'STAGE_II':
      return 'Stage II';
    case 'STAGE_III':
      return 'Stage III';
    case 'STAGE_IV':
      return 'Stage IV';
    default:
      return value ?? '';
  }
}
