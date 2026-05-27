import 'package:bahya_app/data/models/patient_forms_models.dart';
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
}
