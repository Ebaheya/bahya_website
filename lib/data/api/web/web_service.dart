import 'dart:developer';

import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/service/Login_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class WebService {
  final Dio dio = Dio(BaseOptions(baseUrl: baseUrl));

  WebService() {
    setupInterceptors(dio);
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
}
