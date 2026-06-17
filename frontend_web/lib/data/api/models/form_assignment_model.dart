class FormAssignmentModel {
  final String id;
  final String target;
  final String status;
  final String? publishAt;
  final AssignmentPatientModel? patient;
  final AssignmentVolunteerModel? volunteer;
  final AssignmentFormVersionModel? formVersion;

  FormAssignmentModel({
    required this.id,
    required this.target,
    required this.status,
    this.publishAt,
    this.patient,
    this.volunteer,
    this.formVersion,
  });

  factory FormAssignmentModel.fromJson(Map<String, dynamic> json) {
    return FormAssignmentModel(
      id: json['id'] ?? '',
      target: json['target'] ?? '',
      status: json['status'] ?? '',
      publishAt: json['publishAt'],
      patient: json['patient'] == null
          ? null
          : AssignmentPatientModel.fromJson(json['patient']),
      volunteer: json['volunteer'] == null
          ? null
          : AssignmentVolunteerModel.fromJson(json['volunteer']),
      formVersion: json['formVersion'] == null
          ? null
          : AssignmentFormVersionModel.fromJson(json['formVersion']),
    );
  }
}

class AssignmentPatientModel {
  final String id;
  final String? userId;
  final String? fullName;

  AssignmentPatientModel({required this.id, this.userId, this.fullName});

  factory AssignmentPatientModel.fromJson(Map<String, dynamic> json) {
    return AssignmentPatientModel(
      id: json['id'] ?? '',
      userId: json['userId'],
      fullName: json['fullName'] ?? json['name'],
    );
  }
}

class AssignmentVolunteerModel {
  final String id;
  final String? fullName;

  AssignmentVolunteerModel({required this.id, this.fullName});

  factory AssignmentVolunteerModel.fromJson(Map<String, dynamic> json) {
    return AssignmentVolunteerModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? json['name'],
    );
  }
}

class AssignmentFormVersionModel {
  final String id;
  final int version;

  AssignmentFormVersionModel({required this.id, required this.version});

  factory AssignmentFormVersionModel.fromJson(Map<String, dynamic> json) {
    return AssignmentFormVersionModel(
      id: json['id'] ?? '',
      version: json['version'] ?? 0,
    );
  }
}

class FormAssignmentsResponse {
  final List<FormAssignmentModel> data;
  final int total;
  final int page;
  final int pageSize;

  FormAssignmentsResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory FormAssignmentsResponse.fromJson(Map<String, dynamic> json) {
    return FormAssignmentsResponse(
      data: (json['data'] as List? ?? [])
          .map((e) => FormAssignmentModel.fromJson(e))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
    );
  }
}
