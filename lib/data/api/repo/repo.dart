import 'package:bahya_website/data/api/models/form_assignment_model.dart';
import 'package:bahya_website/data/api/models/form_model.dart';
import 'package:bahya_website/data/api/models/options_model.dart';
import 'package:bahya_website/data/api/models/patient_model.dart';
import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/data/api/models/user_model.dart';
import 'package:dio/dio.dart';

class AppRepository {
  WebService webService = WebService();

  String _readableError(Object error, String fallback) {
    final text = error.toString().replaceFirst('Exception: ', '').trim();
    if (text.isEmpty) return fallback;
    if (text.startsWith('Unexpected error : Exception: ')) {
      return text.replaceFirst('Unexpected error : Exception: ', '');
    }
    return text;
  }

  Future<UserModel> getUserProfile({required String accessToken}) async {
    try {
      final data = await webService.getUserInfo();
      return UserModel.fromJson(data['user']);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get user');
    } catch (e) {
      throw Exception('Unexpected error');
    }
  }

  Future<String> getServiceStatus() async {
    try {
      final data = await webService.getServiceStatus();
      return data['status'] ?? 'Unknown';
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get service status');
    } catch (e) {
      throw Exception('Unexpected error');
    }
  }

  Future<List<UserModel>> getAllUserInfo() async {
    try {
      final data = await webService.getAllUserInfo();
      return (data['data'] as List).map((e) => UserModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get user');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<List<UserModel>> getFilteredUserInfo({
    String? nameOrEmail,
    UserRole? role,
    bool? isActive,
  }) async {
    try {
      final data = await webService.getFilteredUserInfo(
        nameOrEmail: nameOrEmail,
        role: role,
        isActive: isActive,
      );
      return (data['data'] as List).map((e) => UserModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get user');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<void> createForm({
    required String formName,
    required List<Map<String, dynamic>> questions,
    required List<Map<String, dynamic>> diagnoses,
  }) async {
    try {
      final body = {
        "key": formName.trim().toUpperCase().replaceAll(' ', '_'),
        "name": formName,
        "scoringType": "SUM",
        "interpretationMode": "RANGE",
        "questions": questions,
        "scoreRanges": diagnoses,
      };

      await webService.createForm(body: body);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get user');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<FormsResponseModel> getForms() async {
    try {
      final response = await webService.getForms();

      return FormsResponseModel.fromJson(response);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get user');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<void> publishForm({
    required String formId,
    required Map<String, dynamic> body,
  }) async {
    try {
      await webService.publishForm(formId: formId, body: body);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get user');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<void> publishFormVersion({required String formId}) async {
    try {
      await webService.publishFormVersion(formId: formId);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get user');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<OptionsResponseModel> getPatient({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await webService.getPatient(
        search: search,
        page: page,
        pageSize: pageSize,
      );

      return OptionsResponseModel.fromJson(response);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get user');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<PatientsResponseModel> getPatients({
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
      final response = await webService.getPatients(
        search: search,
        diseaseStatus: diseaseStatus,
        tumorBiology: tumorBiology,
        surgery: surgery,
        chemotherapy: chemotherapy,
        radiotherapy: radiotherapy,
        hormonalTherapy: hormonalTherapy,
        targetedTherapy: targetedTherapy,
        immunotherapy: immunotherapy,
        sortBy: sortBy,
        sortOrder: sortOrder,
        page: page,
        pageSize: pageSize,
      );

      return PatientsResponseModel.fromJson(
        response,
      ).sorted(sortBy: sortBy, sortOrder: sortOrder);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get patients');
    } catch (e) {
      throw Exception(_readableError(e, 'Failed to get patients'));
    }
  }

  Future<PatientModel> createPatient({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await webService.createPatientFromBody(body: body);
      return PatientModel.fromJson(response);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to create patient');
    } catch (e) {
      throw Exception(_readableError(e, 'Failed to create patient'));
    }
  }

  Future<OptionsResponseModel> getVolunteer({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await webService.getVolunteer(
        search: search,
        page: page,
        pageSize: pageSize,
      );

      return OptionsResponseModel.fromJson(response);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get user');
    } catch (e) {
      throw Exception(_readableError(e, 'Failed to get patient'));
    }
  }

  Future<FormAssignmentsResponse> getFormAssignments({
    required String formId,
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final json = await webService.getFormAssignments(
        formId: formId,
        page: page,
        pageSize: pageSize,
      );

      return FormAssignmentsResponse.fromJson(json);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get user');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<PatientModel> getPatientById(String patientId) async {
    try {
      final json = await webService.getPatientById(patientId);
      return PatientModel.fromJson(json);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get user');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<PatientModel> getPatientDetails(String patientId) async {
    try {
      final json = await webService.getPatientById(patientId);
      return PatientModel.fromJson(json);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get patient details');
    } catch (e) {
      throw Exception(_readableError(e, 'Failed to get patient details'));
    }
  }

  Future<FormModel> getFormById(String formId) async {
    try {
      final json = await webService.getFormById(formId);
      return FormModel.fromJson(json);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get form');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<FormModel> updateForm({
    required String formId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final json = await webService.updateForm(formId: formId, body: body);

      return FormModel.fromJson(json);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to update form');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> createAssessment({
    required Map<String, dynamic> body,
  }) async {
    try {
      final json = await webService.createAssessment(body: body);
      return Map<String, dynamic>.from(json);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to create assessment');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPendingSubmissions() async {
    try {
      final json = await webService.getPendingSubmissions();

      return (json['data'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get pending submissions');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> getSubmissionById(String submissionId) async {
    try {
      final json = await webService.getSubmissionById(submissionId);
      return Map<String, dynamic>.from(json);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get submission');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPatientAssessments(
    String patientId,
  ) async {
    try {
      final json = await webService.getPatientAssessments(patientId);

      if (json is List) {
        return json.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      return (json['data'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get patient assessments');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> getAssessmentById(String assessmentId) async {
    try {
      final json = await webService.getAssessmentById(assessmentId);
      return Map<String, dynamic>.from(json);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get assessment');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> getFormByIdRaw(String formId) async {
    return await webService.getFormById(formId);
  }

  Future<void> updateFormRaw({
    required String formId,
    required Map<String, dynamic> body,
  }) async {
    await webService.updateForm(formId: formId, body: body);
  }

  Future<void> deleteForm({required String formId}) async {
    await webService.deleteForm(formId: formId);
  }
}
