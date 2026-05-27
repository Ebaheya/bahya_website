class PatientModel {
  final String id;
  final String userId;
  final String phone;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final Map<String, dynamic>? medicalHistory;
  final Map<String, dynamic>? socialStatus;
  final Map<String, dynamic>? financials;
  final String? createdAt;
  final String? updatedAt;
  final String fullName;
  final String email;
  final String role;
  final bool isActive;

  PatientModel({
    required this.id,
    required this.userId,
    required this.phone,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.medicalHistory,
    this.socialStatus,
    this.financials,
    this.createdAt,
    this.updatedAt,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isActive,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      phone: json['phone'] ?? '',
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      address: json['address'],
      emergencyContactName: json['emergencyContactName'],
      emergencyContactPhone: json['emergencyContactPhone'],
      medicalHistory: json['medicalHistory'] == null
          ? null
          : Map<String, dynamic>.from(json['medicalHistory']),
      socialStatus: json['socialStatus'] == null
          ? null
          : Map<String, dynamic>.from(json['socialStatus']),
      financials: json['financials'] == null
          ? null
          : Map<String, dynamic>.from(json['financials']),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }
}
