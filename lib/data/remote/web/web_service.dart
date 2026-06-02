import 'dart:developer';

import 'package:bahya_app/data/local/data_secure.dart';
import 'package:bahya_app/route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

const String baseUrl = 'http://10.0.2.2:3000/api/v1';

class WebService {
  late final Dio dio;

  WebService() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    setupInterceptors(dio);
  }

  void setupInterceptors(Dio dio) {
    dio.interceptors.clear();

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final storage = SecureStorageService();

          final publicEndpoints = [
            '/auth/login',
            '/auth/refresh',
            '/auth/forgot-password',
            '/auth/reset-password',
            '/health',
          ];

          final isPublic = publicEndpoints.any(
            (endpoint) => options.path.endsWith(endpoint),
          );

          if (!isPublic) {
            final token = await storage.getAccessToken();

            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          debugPrint('REQUEST: ${options.method} ${options.path}');
          debugPrint('AUTH: ${options.headers['Authorization']}');

          handler.next(options);
        },
        onError: (DioException e, ErrorInterceptorHandler handler) async {
          final storage = SecureStorageService();
          final request = e.requestOptions;

          final publicEndpoints = [
            '/auth/login',
            '/auth/refresh',
            '/auth/forgot-password',
            '/auth/reset-password',
            '/health',
          ];

          final isPublic = publicEndpoints.any(
            (endpoint) => request.path.endsWith(endpoint),
          );

          if (e.response?.statusCode != 401 ||
              request.extra['retried'] == true ||
              isPublic) {
            return handler.next(e);
          }

          try {
            final refreshToken = await storage.getRefreshToken();

            if (refreshToken == null || refreshToken.isEmpty) {
              await logoutAndRedirect();
              return handler.next(e);
            }

            final refreshDio = Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
                headers: {'Content-Type': 'application/json'},
              ),
            );

            final refreshResponse = await refreshDio.post(
              '/auth/refresh',
              data: {'refreshToken': refreshToken},
            );

            if (refreshResponse.statusCode == 200) {
              final newAccess = refreshResponse.data['accessToken'];
              final newRefresh = refreshResponse.data['refreshToken'];

              if (newAccess == null || newRefresh == null) {
                await logoutAndRedirect();
                return handler.next(e);
              }

              await storage.saveTokens(
                accessToken: newAccess,
                refreshToken: newRefresh,
              );

              request.headers['Authorization'] = 'Bearer $newAccess';
              request.extra['retried'] = true;

              final response = await dio.fetch(request);
              return handler.resolve(response);
            }

            await logoutAndRedirect();
            return handler.next(e);
          } catch (refreshError) {
            debugPrint('Refresh Token Error: $refreshError');
            await logoutAndRedirect();
            return handler.next(e);
          }
        },
      ),
    );
  }

  Future<void> logoutAndRedirect() async {
    final storage = SecureStorageService();

    await storage.clearTokens();
    await authNotifier.forceLogout();

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  Future<void> login({required String email, required String password}) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email.trim().toLowerCase(),
          'password': password.trim(),
        },
        options: Options(contentType: Headers.jsonContentType),
      );

      final accessToken = response.data['accessToken'];
      final refreshToken = response.data['refreshToken'];

      if (accessToken == null || refreshToken == null) {
        throw Exception('Invalid tokens received');
      }

      await SecureStorageService().saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      authNotifier.login();

      debugPrint('Login successful');
    } on DioException catch (e) {
      debugPrint('Login Error: ${e.response?.data}');

      final errorMessage =
          e.response?.data?['error']?['message'] ??
          e.response?.data?['message'] ??
          'Login failed';

      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('Unexpected login error: $e');
      throw Exception('Something went wrong');
    }
  }

  Future<void> logout() async {
    try {
      final storage = SecureStorageService();
      final refreshToken = await storage.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        await dio.post('/auth/logout', data: {'refreshToken': refreshToken});
      }

      await logoutAndRedirect();
    } on DioException catch (e) {
      debugPrint('Logout Error: ${e.response?.data ?? e.message}');
      await logoutAndRedirect();
    } catch (e) {
      log('Unexpected logout error: $e');
      await logoutAndRedirect();
    }
  }

  Future<List<dynamic>> getMyAssignments() async {
    final response = await dio.get('/form-assignments/my');
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getAssignmentDetails(String assignmentId) async {
    final response = await dio.get('/form-assignments/$assignmentId');

    debugPrint('Assignment details response: ${response.data}');

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> submitAssignment({
    required String assignmentId,
    required Map<String, dynamic> body,
  }) async {
    final response = await dio.post(
      '/form-assignments/$assignmentId/submit',
      data: body,
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<void> forgetPassword({required String email}) async {
    await dio.post(
      '/auth/forgot-password',
      data: {'email': email.trim().toLowerCase()},
    );

    debugPrint('Forget password request successful');
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await dio.post(
      '/auth/reset-password',
      data: {'token': token, 'newPassword': newPassword},
    );

    debugPrint('Password reset successful');
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await dio.patch(
      '/auth/change-password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );

    debugPrint('Password change successful');
  }
}
