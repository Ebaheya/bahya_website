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
    required String password,
    required String phone,
    required String dateOfBirth,
    required String gender,
    required String address,
    required String emergencyContactName,
    required String emergencyContactPhone,
  }) async {
    try {
      final res = await dio.post(
        '/patients',
        data: {
          "fullName": fullName,
          "email": email,
          "password": password,
          "phone": phone,
          "dateOfBirth": dateOfBirth,
          "gender": gender,
          "address": address,
          "emergencyContactName": emergencyContactName,
          "emergencyContactPhone": emergencyContactPhone,
          "medicalHistory": {
            "allergies": ["penicillin"],
          },
        },
      );
      if (res.statusCode == 201) {
        log("Patient created successfully: ${res.data}");
      } else {
        throw Exception('Failed to create patient');
      }
    } on DioException catch (e) {
      debugPrint("DioException: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data ?? 'Failed to create patient');
    } catch (e) {
      debugPrint("Unexpected error: $e");
      throw Exception('Unexpected error');
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
}
