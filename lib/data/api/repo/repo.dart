import 'package:bahya_website/data/api/models/form_assignment_model.dart';
import 'package:bahya_website/data/api/models/form_model.dart';
import 'package:bahya_website/data/api/models/options_model.dart';
import 'package:bahya_website/data/api/models/patient_model.dart';
import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/data/api/models/user_model.dart';
import 'package:dio/dio.dart';

class AppRepository {
  WebService webService = WebService();
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

  Future<OptionsResponseModel> getPatientOptions({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await webService.getPatientOptions(
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

  Future<OptionsResponseModel> getVolunteerOptions({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await webService.getVolunteerOptions(
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
}
