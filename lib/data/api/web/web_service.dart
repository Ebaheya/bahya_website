import 'dart:developer';

import 'package:bahya_website/helper/strings.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class WebService {
  final Dio dio = Dio();
  Future<Map<String, dynamic>> getUserInfo({
    required String accessToken,
  }) async {
    final res = await dio.get(
      '$baseUrl/auth/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return res.data;
  }

  Future<Map<String, dynamic>> getServiceStatus() async {
    try {
      final res = await dio.get('$baseUrl/health');
      return res.data;
    } on DioException catch (e) {
      debugPrint(
        "DioException: ${e.response?.data ?? e.message}",
      );
      throw Exception(e.response?.data ?? 'Failed to get service status');
    } catch (e) {
      log("Unexpected error: $e");
      throw Exception('Unexpected error');
    }
  }
}
