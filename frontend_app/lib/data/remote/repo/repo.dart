import 'package:bahya_app/data/models/patient_forms_models.dart';
import 'package:bahya_app/data/models/service_models.dart';
import 'package:bahya_app/data/remote/web/web_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AppRepository {
  final WebService webService;

  AppRepository({WebService? webService})
    : webService = webService ?? WebService();

  Future<List<MyAssignmentModel>> getMyAssignments() async {
    try {
      final json = await webService.getMyAssignments();

      return json
          .map((e) => MyAssignmentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      debugPrint(' error: ${e.response?.data ?? e.message}');
      throw Exception(e.response?.data ?? 'POST request failed');
    }
  }

  Future<AssignmentDetailsModel> getAssignmentDetails(
    String assignmentId,
  ) async {
    try {
      final json = await webService.getAssignmentDetails(assignmentId);

      return AssignmentDetailsModel.fromJson(json);
    } on DioException catch (e) {
      debugPrint(' error: ${e.response?.data ?? e.message}');
      throw Exception(e.response?.data ?? 'POST request failed');
    }
  }

  Future<SubmitFormResponseModel> submitAssignment({
    required String assignmentId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final json = await webService.submitAssignment(
        assignmentId: assignmentId,
        body: body,
      );
      debugPrint('Submit assignment response: $json');
      return SubmitFormResponseModel.fromJson(json);
    } on DioException catch (e) {
      debugPrint(' error: ${e.response?.data ?? e.message}');
      throw Exception(e.response?.data ?? 'POST request failed');
    }
  }

  Future<List<ServiceCategoryModel>> getServiceCategories({
    bool? isActive,
  }) async {
    final json = await webService.getServiceCategories(
      isActive: isActive,
    );

    return json
        .map(
          (e) => ServiceCategoryModel.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
  }

  Future<ServiceCategoryModel> createServiceCategory({
    required String name,
    required String iconKey,
    required String color,
    required String kind,
  }) async {
    final json = await webService.createServiceCategory(
      kind: kind,
      name: name,
      iconKey: iconKey,
      color: color,
    );

    return ServiceCategoryModel.fromJson(json);
  }

  Future<ServiceCategoryModel> updateServiceCategory({
    required String categoryId,
    required Map<String, dynamic> data,
  }) async {
    final json = await webService.updateServiceCategory(
      categoryId: categoryId,
      data: data,
    );
    return ServiceCategoryModel.fromJson(json);
  }

  Future<ServiceCategoryModel> updateServiceCategoryStatus({
    required String categoryId,
    required bool isActive,
  }) async {
    final json = await webService.updateServiceCategoryStatus(
      categoryId: categoryId,
      isActive: isActive,
    );
    return ServiceCategoryModel.fromJson(json);
  }

  Future<List<PatientServiceModel>> getServices({
    String? categoryId,
    String? q,
    String? status,
    int page = 1,
    int pageSize = 100,
  }) async {
    final json = await webService.getServices(
      categoryId: categoryId,
      q: q,
      status: status,
      page: page,
      pageSize: pageSize,
    );

    return json
        .map((e) => PatientServiceModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<PatientServiceModel> createService(Map<String, dynamic> data) async {
    final json = await webService.createService(data);
    return PatientServiceModel.fromJson(json);
  }

  Future<PatientServiceModel> getServiceDetails(String serviceId) async {
    final json = await webService.getServiceDetails(serviceId);
    return PatientServiceModel.fromJson(json);
  }

  Future<PatientServiceModel> updateService({
    required String serviceId,
    required Map<String, dynamic> data,
  }) async {
    final json = await webService.updateService(
      serviceId: serviceId,
      data: data,
    );
    return PatientServiceModel.fromJson(json);
  }

  Future<void> requestService(String serviceId) {
    return webService.requestService(serviceId);
  }

  Future<List<ServiceRequestModel>> getMyServiceRequests() async {
    final json = await webService.getMyServiceRequests();
    return json
        .map((e) => ServiceRequestModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<ServiceRequestModel>> getServiceRequests({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final json = await webService.getServiceRequests(
      status: status,
      page: page,
      pageSize: pageSize,
    );
    return json
        .map((e) => ServiceRequestModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Map<String, dynamic>> getServiceRequestsSummary() {
    return webService.getServiceRequestsSummary();
  }

  Future<void> approveServiceRequest(String requestId) {
    return webService.approveServiceRequest(requestId);
  }

  Future<void> rejectServiceRequest(String requestId, {String? decisionNote}) {
    return webService.rejectServiceRequest(
      requestId,
      decisionNote: decisionNote,
    );
  }

  Future<void> cancelServiceRequest(String requestId) {
    return webService.cancelServiceRequest(requestId);
  }
}
