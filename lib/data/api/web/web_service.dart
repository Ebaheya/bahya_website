import 'dart:developer';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/service/Login_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

enum UserRole { ADMIN, DOCTOR, VOLUNTEER, PATIENT, CALL_CENTER }

class WebService {
  final Dio dio = Dio(BaseOptions(baseUrl: baseUrl));

  WebService() {
    setupInterceptors(dio);
  }

  String _apiErrorMessage(Object? data, String fallback) {
    if (data is Map) {
      final message = data['message'] ?? data['error'];
      if (message is List && message.isNotEmpty) {
        return message.map((item) => item.toString()).join('\n');
      }
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    if (data is String && data.trim().isNotEmpty) return data;
    return fallback;
  }

  Map<String, dynamic> _sortPatientsResponseLocally({
    required Map<String, dynamic> responseData,
    String? sortBy,
    String? sortOrder,
  }) {
    if (sortBy == null || sortBy.trim().isEmpty) return responseData;

    final listKey = _findPatientsListKey(responseData);
    if (listKey == null) return responseData;

    final originalList = responseData[listKey];
    if (originalList is! List) return responseData;

    final sortedList = List<dynamic>.from(originalList);
    final descending = _isDescendingSort(sortOrder);

    sortedList.sort((a, b) {
      final aValue = _patientSortValue(a, sortBy);
      final bValue = _patientSortValue(b, sortBy);
      final result = _compareNullableValues(aValue, bValue);
      return descending ? -result : result;
    });

    return Map<String, dynamic>.from(responseData)..[listKey] = sortedList;
  }

  String? _findPatientsListKey(Map<String, dynamic> data) {
    const possibleKeys = [
      'data',
      'items',
      'patients',
      'results',
      'docs',
      'rows',
    ];

    for (final key in possibleKeys) {
      if (data[key] is List) return key;
    }

    return null;
  }

  bool _isDescendingSort(String? sortOrder) {
    final value = sortOrder?.trim().toLowerCase();
    return value == 'desc' ||
        value == 'descending' ||
        value == 'newest' ||
        value == 'latest' ||
        value == 'z_a';
  }

  dynamic _patientSortValue(dynamic patient, String sortBy) {
    if (patient is! Map) return null;

    final normalizedSortBy = sortBy.trim().toLowerCase();

    final candidates = <String>[
      sortBy,
      normalizedSortBy,
      _snakeToCamel(sortBy),
      ..._sortKeyAliases(normalizedSortBy),
    ];

    for (final key in candidates) {
      if (patient.containsKey(key) && patient[key] != null) {
        return patient[key];
      }
    }

    return null;
  }

  List<String> _sortKeyAliases(String sortBy) {
    switch (sortBy) {
      case 'name':
      case 'fullname':
      case 'full_name':
      case 'patientname':
      case 'patient_name':
        return ['fullName', 'name', 'patientName'];
      case 'crn':
      case 'filenumber':
      case 'file_number':
      case 'displaycrn':
      case 'display_crn':
        return ['crn', 'fileNumber', 'displayCrn'];
      case 'age':
        return ['age'];
      case 'createdat':
      case 'created_at':
      case 'registrationdate':
      case 'registration_date':
      case 'date':
        return ['createdAt', 'registrationDate', 'dateOfRegistration'];
      case 'diagnosisdate':
      case 'diagnosis_date':
      case 'dateofdiagnosis':
      case 'date_of_diagnosis':
        return ['dateOfDiagnosis', 'diagnosisDate'];
      case 'diseasestatus':
      case 'disease_status':
        return ['diseaseStatus'];
      case 'tumorbiology':
      case 'tumor_biology':
        return ['tumorBiology'];
      default:
        return const [];
    }
  }

  String _snakeToCamel(String value) {
    final parts = value.split('_');
    if (parts.length <= 1) return value;

    return parts.first +
        parts.skip(1).map((part) {
          if (part.isEmpty) return part;
          return part[0].toUpperCase() + part.substring(1);
        }).join();
  }

  int _compareNullableValues(dynamic a, dynamic b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;

    final aDate = _tryParseDate(a);
    final bDate = _tryParseDate(b);
    if (aDate != null && bDate != null) {
      return aDate.compareTo(bDate);
    }

    final aNumber = _tryParseNumber(a);
    final bNumber = _tryParseNumber(b);
    if (aNumber != null && bNumber != null) {
      return aNumber.compareTo(bNumber);
    }

    return a.toString().toLowerCase().compareTo(b.toString().toLowerCase());
  }

  DateTime? _tryParseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is! String) return null;
    return DateTime.tryParse(value.trim());
  }

  num? _tryParseNumber(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value.trim());
    return null;
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final res = await dio.get('/auth/me');

      return res.data;
    } on DioException catch (e) {
      debugPrint("DioException: ${e.response?.data ?? e.message}");

      throw Exception(e.response?.data ?? 'Failed to get user info');
    }
  }

  Future<Map<String, dynamic>> getServiceStatus() async {
    try {
      final res = await dio.get('/health');

      return res.data;
    } on DioException catch (e) {
      debugPrint("DioException: ${e.response?.data ?? e.message}");

      throw Exception(e.response?.data ?? 'Failed to get service status');
    } catch (e) {
      log("Unexpected error: $e");

      throw Exception('Unexpected error');
    }
  }

  Future<void> createStaff({
    required String email,

    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final res = await dio.post(
        "/auth/register-staff",
        data: {
          "email": email,
          "password": password,
          "fullName": fullName,
          "role": role,
        },
      );
      if (res.statusCode == 201) {
        log("Staff created successfully: ${res.data}");
      } else {
        throw Exception('Failed to create staff');
      }
    } on DioException catch (e) {
      debugPrint("DioException: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data ?? 'Failed to create staff');
    } catch (e) {
      debugPrint("Unexpected error: $e");
      throw Exception('Unexpected error');
    }
  }

  Future<void> createPatient({
    required String fullName,
    required String email,
    required String crn,
    required String password,
    required String phone,
    required String dateOfBirth,
    required String gender,
    required String address,
    required String emergencyContactName,
    required String emergencyContactPhone,
  }) async {
    await createPatientFromBody(
      body: {
        "fullName": fullName,
        "email": email,
        "crn": crn,
        "password": password,
        "phone": phone,
        "dateOfBirth": dateOfBirth,
        "gender": gender,
        "address": address,
        "emergencyContactName": emergencyContactName,
        "emergencyContactPhone": emergencyContactPhone,
      },
    );
  }

  Future<Map<String, dynamic>> createPatientFromBody({
    required Map<String, dynamic> body,
  }) async {
    try {
      final requestBody = Map<String, dynamic>.from(body)
        ..removeWhere((key, value) => value == null);
      final res = await dio.post('/patients', data: requestBody);
      if (res.statusCode == 201) {
        log("Patient created successfully: ${res.data}");
        final data = res.data;
        if (data is Map && data['data'] is Map) {
          return Map<String, dynamic>.from(data['data']);
        }
        return Map<String, dynamic>.from(data);
      }

      throw Exception('Failed to create patient');
    } on DioException catch (e) {
      debugPrint("DioException: ${e.response?.data ?? e.message}");
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to create patient',
        ),
      );
    } catch (e) {
      debugPrint("Unexpected error: $e");
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> getAllUserInfo() async {
    try {
      return await dio.get('/users').then((res) => res.data);
    } on DioException catch (e) {
      debugPrint("DioException: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data ?? 'Failed to get all user info');
    } catch (e) {
      debugPrint("Unexpected error: $e");
      throw Exception('Unexpected error');
    }
  }

  Future<Map<String, dynamic>> getFilteredUserInfo({
    String? nameOrEmail,
    UserRole? role,
    bool? isActive,
  }) async {
    try {
      final res = await dio.get(
        '/users',
        queryParameters: {
          if (nameOrEmail != null && nameOrEmail.isNotEmpty) 'q': nameOrEmail,

          if (role != null) 'role': role.name,

          if (isActive != null) 'isActive': isActive,
        },
      );

      return res.data;
    } on DioException catch (e) {
      debugPrint("DioException: ${e.response?.data ?? e.message}");

      throw Exception(e.response?.data ?? 'Failed to get filtered user info');
    } catch (e) {
      debugPrint("Unexpected error: $e");

      throw Exception('Unexpected error');
    }
  }

  Future<void> forgetPassword({required String email}) async {
    try {
      final res = await dio.post(
        '/auth/forgot-password',
        data: {"email": email},
      );
      if (res.statusCode == 200) {
        debugPrint("Forget password request successful: ${res.data}");
      } else {
        throw Exception('Failed to forget password');
      }
    } on DioException catch (e) {
      debugPrint("DioException: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data ?? 'Failed to forget password');
    } catch (e) {
      debugPrint("Unexpected error: $e");
      throw Exception('Unexpected error');
    }
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final res = await dio.post(
        '/auth/reset-password',
        data: {"token": token, "newPassword": newPassword},
      );
      if (res.statusCode == 200) {
        debugPrint("Password reset successful");
      } else {
        throw Exception('Failed to reset password');
      }
    } on DioException catch (e) {
      debugPrint("DioException: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data ?? 'Failed to reset password');
    } catch (e) {
      debugPrint("Unexpected error: $e");
      throw Exception('Unexpected error');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final res = await dio.patch(
        '/auth/change-password',
        data: {"currentPassword": currentPassword, "newPassword": newPassword},
      );
      if (res.statusCode == 200) {
        debugPrint("Password change successful");
        return;
      }
      if (res.statusCode == 401) {
        throw Exception('Current password is incorrect');
      } else {
        throw Exception('Failed to change password');
      }
    } on DioException catch (e) {
      debugPrint("DioException: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data ?? 'Failed to change password');
    } catch (e) {
      debugPrint("Unexpected error: $e");
      throw Exception('Unexpected error');
    }
  }

  Future<void> createForm({required Map<String, dynamic> body}) async {
    try {
      final res = await dio.post('/forms', data: body);

      if (res.statusCode == 201 || res.statusCode == 200) {
        log("Form created successfully: ${res.data}");
        return;
      }

      throw Exception('Failed to create form');
    } on DioException catch (e) {
      debugPrint("DioException: ${e.response?.data ?? e.message}");
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to create form',
        ),
      );
    } catch (e) {
      debugPrint("Unexpected error: $e");
      throw Exception('Unexpected error');
    }
  }

  Future<Map<String, dynamic>> getForms() async {
    try {
      return await dio.get('/forms').then((res) => res.data);
    } on DioException catch (e) {
      debugPrint("DioException: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data ?? 'Failed to get all user info');
    } catch (e) {
      debugPrint("Unexpected error: $e");
      throw Exception('Unexpected error');
    }
  }

  Future<void> publishFormVersion({required String formId}) async {
    try {
      await dio.post('/forms/$formId/publish-version');
    } on DioException catch (e) {
      debugPrint(
        "Publish version DioException: ${e.response?.data ?? e.message}",
      );
      throw Exception(e.response?.data ?? 'Failed to publish form version');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<void> publishForm({
    required String formId,
    required Map<String, dynamic> body,
  }) async {
    try {
      await dio.post('/forms/$formId/publish', data: body);
    } on DioException catch (e) {
      debugPrint("Publish DioException: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data ?? 'Failed to publish form');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> getPatient({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await dio.get(
      '/patients/options',
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'q': search.trim(),
        'page': page,
        'pageSize': pageSize,
      },
    );

    return response.data;
  }

  Future<Map<String, dynamic>> getPatients({
    String? search,
    String? diseaseStatus,
    String? tumorBiology,
    String? surgery,
    String? chemotherapy,
    bool? radiotherapy,
    bool? hormonalTherapy,
    bool? targetedTherapy,
    bool? immunotherapy,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dio.get(
        '/patients',
        queryParameters: {
          if (search != null && search.trim().isNotEmpty) 'q': search.trim(),
          if (diseaseStatus != null) 'diseaseStatus': diseaseStatus,
          if (tumorBiology != null) 'tumorBiology': tumorBiology,
          if (surgery != null) 'surgery': surgery,
          if (chemotherapy != null) 'chemotherapy': chemotherapy,
          if (radiotherapy != null) 'radiotherapy': radiotherapy,
          if (hormonalTherapy != null) 'hormonalTherapy': hormonalTherapy,
          if (targetedTherapy != null) 'targetedTherapy': targetedTherapy,
          if (immunotherapy != null) 'immunotherapy': immunotherapy,
          'page': page,
          'pageSize': pageSize,
        },
      );

      final data = Map<String, dynamic>.from(response.data);

      return _sortPatientsResponseLocally(
        responseData: data,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
    } on DioException catch (e) {
      debugPrint("Patients DioException: ${e.response?.data ?? e.message}");
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to get patients',
        ),
      );
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> getVolunteer({
    String? search,
    int page = 1,
    int pageSize = 5,
  }) async {
    try {
      final response = await dio.get(
        '/volunteers',
        queryParameters: {
          if (search != null && search.trim().isNotEmpty) 'q': search.trim(),
          'page': page,
          'pageSize': pageSize,
        },
      );

      return response.data;
    } on DioException catch (e) {
      debugPrint("Publish DioException: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data ?? 'Failed to publish form');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> getFormAssignments({
    required String formId,
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final response = await dio.get(
        '/forms/$formId/assignments',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );

      return response.data;
    } on DioException catch (e) {
      debugPrint("Publish DioException: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data ?? 'Failed to publish form');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> getPatientById(String patientId) async {
    try {
      final response = await dio.get('/patients/$patientId');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      debugPrint(
        "Patient detail DioException: ${e.response?.data ?? e.message}",
      );
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to get patient',
        ),
      );
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> getFormById(String formId) async {
    try {
      final response = await dio.get('/forms/$formId');
      return response.data;
    } on DioException catch (e) {
      debugPrint("Get form DioException: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data ?? 'Failed to get form');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> updateForm({
    required String formId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await dio.put('/forms/$formId', data: body);
      return response.data;
    } on DioException catch (e) {
      debugPrint("Update form DioException: ${e.response?.data ?? e.message}");
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to update form',
        ),
      );
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> createAssessment({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await dio.post('/assessments', data: body);
      return response.data;
    } on DioException catch (e) {
      debugPrint(
        "Create assessment DioException: ${e.response?.data ?? e.message}",
      );
      throw Exception(e.response?.data ?? 'Failed to create assessment');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<dynamic> getPendingSubmissions() async {
    try {
      final response = await dio.get('/assessments/submissions/pending');
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to get pending submissions',
        ),
      );
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> getSubmissionById(String submissionId) async {
    try {
      final response = await dio.get('/assessments/submissions/$submissionId');
      return response.data;
    } on DioException catch (e) {
      debugPrint("Submission DioException: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data ?? 'Failed to get submission');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<dynamic> getPatientAssessments(String patientId) async {
    try {
      final response = await dio.get('/assessments/patient/$patientId');
      return response.data;
    } on DioException catch (e) {
      debugPrint(
        "Patient assessments DioException: ${e.response?.data ?? e.message}",
      );
      throw Exception(e.response?.data ?? 'Failed to get patient assessments');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> getAssessmentById(String assessmentId) async {
    try {
      final response = await dio.get('/assessments/$assessmentId');
      return response.data;
    } on DioException catch (e) {
      debugPrint("Assessment DioException: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data ?? 'Failed to get assessment');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<void> deleteForm({required String formId}) async {
    try {
      await dio.delete('/forms/$formId');
    } on DioException catch (e) {
      debugPrint("Delete Form DioException: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data ?? 'Failed to delete form');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<void> changeFormStatus({
    required String formId,
    required bool isActive,
  }) async {
    await dio.patch('/forms/$formId/status', data: {"isActive": isActive});
  }

Future<List<Map<String, dynamic>>> getMyFormAssignments() async {
    try {
      final response = await dio.get('/form-assignments/my');

      final data = response.data;

      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      debugPrint(
        "My assignments DioException: ${e.response?.data ?? e.message}",
      );
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to get assignments',
        ),
      );
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> getFormAssignmentById(
    String assignmentId,
  ) async {
    try {
      final response = await dio.get('/form-assignments/$assignmentId');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      debugPrint(
        "Assignment detail DioException: ${e.response?.data ?? e.message}",
      );
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to get assignment',
        ),
      );
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> submitFormAssignment({
    required String assignmentId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await dio.post(
        '/form-assignments/$assignmentId/submit',
        data: body,
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      debugPrint(
        "Submit assignment DioException: ${e.response?.data ?? e.message}",
      );
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to submit assignment',
        ),
      );
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<dynamic> getSubmissionDetails(String submissionId) async {
    try {
      final response = await dio.get('/assessments/submissions/$submissionId');
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to get submission details',
        ),
      );
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<dynamic> createOfficialAssessment({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await dio.post('/assessments', data: body);
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to create official assessment',
        ),
      );
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

}
