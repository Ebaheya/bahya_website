class PatientProfileModel {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String role;
  final String crn;
  final String phone;
  final String dateOfBirth;
  final bool isActive;

  const PatientProfileModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.crn,
    required this.phone,
    required this.dateOfBirth,
    required this.isActive,
  });

  factory PatientProfileModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['user'])
        : json;

    final patient = json['patient'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['patient'])
        : json;

    return PatientProfileModel(
      id: (patient['id'] ?? user['id'] ?? '').toString(),
      userId: (patient['userId'] ?? user['id'] ?? '').toString(),
      fullName: (patient['fullName'] ?? user['fullName'] ?? user['name'] ?? '')
          .toString(),
      email: (patient['email'] ?? user['email'] ?? '').toString(),
      role: (user['role'] ?? patient['role'] ?? '').toString(),
      crn: (patient['crn'] ?? patient['medicalNumber'] ?? '').toString(),
      phone: (patient['phone'] ?? '').toString(),
      dateOfBirth: (patient['dateOfBirth'] ?? '').toString(),
      isActive: user['isActive'] == true || patient['isActive'] == true,
    );
  }

  int? get age {
    if (dateOfBirth.trim().isEmpty) return null;

    try {
      final birthDate = DateTime.parse(dateOfBirth);
      final now = DateTime.now();

      int value = now.year - birthDate.year;

      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        value--;
      }

      return value;
    } catch (_) {
      return null;
    }
  }
}
