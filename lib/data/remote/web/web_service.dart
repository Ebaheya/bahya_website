import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

const String baseUrl =  'http://10.0.2.2:3000/api/v1';

class WebService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static const String accessToken = 'PUT_YOUR_PATIENT_TOKEN';

  WebService() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (accessToken.isNotEmpty &&
              accessToken != 'PUT_YOUR_PATIENT_TOKEN_HERE') {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }

          debugPrint('REQUEST: ${options.method} ${options.path}');
          debugPrint('AUTH: ${options.headers['Authorization']}');

          handler.next(options);
        },
      ),
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      debugPrint('GET $path error: ${e.response?.data ?? e.message}');
      throw Exception(e.response?.data ?? 'GET request failed');
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      debugPrint('POST $path error: ${e.response?.data ?? e.message}');
      throw Exception(e.response?.data ?? 'POST request failed');
    }
  }

  Future<List<dynamic>> getMyAssignments() async {
    try {
      final response = await get('/form-assignments/my');
      return response as List<dynamic>;
    } on DioException catch (e) {
      debugPrint(' error: ${e.response?.data ?? e.message}');
      throw Exception(e.response?.data ?? 'POST request failed');
    }
  }

  Future<Map<String, dynamic>> getAssignmentDetails(String assignmentId) async {
    try {
      final response = await get('/form-assignments/$assignmentId');
      debugPrint('Assignment details response: $response');
      return Map<String, dynamic>.from(response);
    } on DioException catch (e) {
      debugPrint(' error: ${e.response?.data ?? e.message}');
      throw Exception(e.response?.data ?? 'POST request failed');
    }
  }

  Future<Map<String, dynamic>> submitAssignment({
    required String assignmentId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await post(
        '/form-assignments/$assignmentId/submit',
        data: body,
      );

      return Map<String, dynamic>.from(response);
    } on DioException catch (e) {
      debugPrint(' error: ${e.response?.data ?? e.message}');
      throw Exception(e.response?.data ?? 'POST request failed');
    }
  }
}
