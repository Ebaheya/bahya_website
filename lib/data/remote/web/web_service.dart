import 'dart:developer';
import 'dart:convert';

import 'package:bahya_app/data/local/data_secure.dart';
import 'package:bahya_app/route.dart';
import 'package:bahya_app/services/internet_connection_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

const String baseUrl = 'https://api.refk.tech/api/v1';
const String localBaseUrl = 'http://10.5.203.183:3000/api/v1';

class ApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  ApiException({required this.message, this.code, this.statusCode});

  @override
  String toString() => message;
}

class WebService {
  late final Dio dio;
  static bool _isOpeningNoInternet = false;

  void _openNoInternetScreen() {
    if (_isOpeningNoInternet) return;

    final currentRoute = ModalRoute.of(
      navigatorKey.currentContext!,
    )?.settings.name;
    if (currentRoute == '/noInternet') return;

    _isOpeningNoInternet = true;

    navigatorKey.currentState
        ?.pushNamedAndRemoveUntil('/noInternet', (route) => false)
        .then((_) {
          _isOpeningNoInternet = false;
        });
  }

  WebService() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 6),
        receiveTimeout: const Duration(seconds: 8),
        sendTimeout: const Duration(seconds: 6),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    setupInterceptors(dio);
  }

  String _handleDioError(DioException e) {
    final data = e.response?.data;
    final statusCode = e.response?.statusCode;

    if (e.error == 'NO_INTERNET') {
      throw ApiException(
        message: 'لا يوجد اتصال بالإنترنت',
        statusCode: statusCode,
      );
    }

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      throw ApiException(
        message: 'تعذر الوصول للسيرفر، حاول مرة أخرى.',
        statusCode: statusCode,
      );
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      throw ApiException(
        message: 'انتهت مهلة الاتصال، حاول مرة أخرى.',
        statusCode: statusCode,
      );
    }

    if (data is Map<String, dynamic>) {
      final error = data['error'];

      if (error is Map<String, dynamic>) {
        final message = error['message']?.toString();
        final code = error['code']?.toString();

        if (message != null && message.isNotEmpty) {
          throw ApiException(
            message: message,
            code: code,
            statusCode: statusCode,
          );
        }
      }

      final message = data['message']?.toString();

      if (message != null && message.isNotEmpty) {
        throw ApiException(message: message, statusCode: statusCode);
      }
    }

    throw ApiException(
      message: 'حدث خطأ غير متوقع، حاول مرة أخرى.',
      statusCode: statusCode,
    );
  }

  void setupInterceptors(Dio dio) {
    dio.interceptors.clear();

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final hasInternet = await InternetConnectionService.instance
              .hasInternet();

          if (!hasInternet) {
            _openNoInternetScreen();

            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                error: 'NO_INTERNET',
                message: 'لا يوجد اتصال بالإنترنت',
              ),
            );
          }

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
          handler.next(options);
        },
        onError: (DioException e, ErrorInterceptorHandler handler) async {
          if (e.error == 'NO_INTERNET') {
            _openNoInternetScreen();
            return handler.next(e);
          }

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
              return handler.next(e);
            }

            final refreshDio = Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 6),
                receiveTimeout: const Duration(seconds: 8),
                sendTimeout: const Duration(seconds: 6),
                headers: {'Content-Type': 'application/json'},
              ),
            );

            final refreshResponse = await refreshDio.post(
              '/auth/refresh',
              data: {'refreshToken': refreshToken},
            );

            final newAccess = refreshResponse.data['accessToken'];
            final newRefresh = refreshResponse.data['refreshToken'];

            if (newAccess == null || newRefresh == null) {
              return handler.next(e);
            }

            await storage.saveTokens(
              accessToken: newAccess,
              refreshToken: newRefresh,
              role: _roleFromJwt(newAccess?.toString()),
            );

            request.headers['Authorization'] = 'Bearer $newAccess';
            request.extra['retried'] = true;

            final response = await dio.fetch(request);
            return handler.resolve(response);
          } catch (_) {
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

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response<dynamic>> post(String path, {dynamic data}) async {
    try {
      final response = await dio.post(path, data: data);

      debugPrint('SUCCESS => $path');
      debugPrint(response.data.toString());

      return response;
    } on DioException catch (e) {
      debugPrint('DIO ERROR => $path');
      debugPrint('STATUS => ${e.response?.statusCode}');
      debugPrint('DATA => ${e.response?.data}');
      debugPrint('MESSAGE => ${e.message}');

      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response<dynamic>> patch(String path, {dynamic data}) async {
    try {
      return await dio.patch(path, data: data);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response<dynamic>> delete(String path, {dynamic data}) async {
    try {
      return await dio.delete(path, data: data);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await post(
        '/auth/login',
        data: {
          'email': email.trim().toLowerCase(),
          'password': password.trim(),
        },
      );

      final accessToken = response.data['accessToken'];
      final refreshToken = response.data['refreshToken'];
      final role = _roleFromJwt(accessToken?.toString());

      if (accessToken == null || refreshToken == null) {
        throw ApiException(message: 'لم يتم استلام بيانات الدخول بشكل صحيح.');
      }

      await SecureStorageService().saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        role: role,
      );

      authNotifier.login(role: role);

      return role;
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('Unexpected login error: $e');
      throw ApiException(message: 'حدث خطأ أثناء تسجيل الدخول.');
    }
  }

  String? _roleFromJwt(String? token) {
    if (token == null || token.isEmpty) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final json = jsonDecode(payload);

      if (json is Map<String, dynamic>) {
        final role = json['role']?.toString().toUpperCase();
        return role?.isEmpty == true ? null : role;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  }) async {
    await post(
      '/notifications/devices',
      data: {'token': token, 'platform': platform},
    );
  }

  Future<List<dynamic>> getMyNotifications({
    String? status,
    String? severity,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await get(
      '/notifications/my',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (severity != null && severity.isNotEmpty) 'severity': severity,
        'page': page,
        'pageSize': pageSize,
      },
    );

    return _listFromResponse(response.data);
  }

  Future<void> claimNotification(String id) async {
    await patch('/notifications/$id/claim');
  }

  Future<void> markNotificationRead(String id) async {
    await patch('/notifications/$id/read');
  }

  Future<void> markNotificationDone(String id) async {
    await patch('/notifications/$id/done');
  }

  Future<void> unregisterDeviceToken({required String token}) async {
    await delete('/notifications/devices', data: {'token': token});
  }

  Future<void> logout() async {
    try {
      final storage = SecureStorageService();
      final refreshToken = await storage.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        await post('/auth/logout', data: {'refreshToken': refreshToken});
      }

      await logoutAndRedirect();
    } catch (e) {
      log('Logout error: $e');
      await logoutAndRedirect();
    }
  }

  Future<List<dynamic>> getMyAssignments() async {
    try {
      final response = await get('/form-assignments/my');
      return _listFromResponse(response.data);
    } on ApiException catch (e) {
      if (e.statusCode == 403 || e.statusCode == 404) {
        return const [];
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAssignmentDetails(String assignmentId) async {
    final response = await get('/form-assignments/$assignmentId');
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> submitAssignment({
    required String assignmentId,
    required Map<String, dynamic> body,
  }) async {
    final response = await post(
      '/form-assignments/$assignmentId/submit',
      data: body,
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<void> forgetPassword({required String email}) async {
    await post(
      '/auth/forgot-password',
      data: {'email': email.trim().toLowerCase()},
    );
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await post(
      '/auth/reset-password',
      data: {'token': token, 'newPassword': newPassword},
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await patch(
      '/auth/change-password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }

  Future<List<dynamic>> getServiceCategories({bool? isActive}) async {
    final response = await get(
      '/service-categories',
      queryParameters: {if (isActive != null) 'isActive': isActive},
    );
    return _listFromResponse(response.data);
  }

  Future<Map<String, dynamic>> createServiceCategory({
    required String name,
    required String iconKey,
    required String color,
    required String kind,
  }) async {
    final response = await post(
      '/service-categories',
      data: {'name': name, 'kind': kind, 'iconKey': iconKey, 'color': color},
    );
    return _mapFromResponse(response.data);
  }

  Future<Map<String, dynamic>> updateServiceCategory({
    required String categoryId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch('/service-categories/$categoryId', data: data);
    return _mapFromResponse(response.data);
  }

  Future<Map<String, dynamic>> updateServiceCategoryStatus({
    required String categoryId,
    required bool isActive,
  }) async {
    final response = await patch(
      '/service-categories/$categoryId/status',
      data: {'isActive': isActive},
    );
    return _mapFromResponse(response.data);
  }

  Future<List<dynamic>> getServices({
    String? categoryId,
    String? q,
    String? status,
    int page = 1,
    int pageSize = 100,
  }) async {
    final response = await get(
      '/services',
      queryParameters: {
        if (categoryId != null) 'categoryId': categoryId,
        if (q != null && q.isNotEmpty) 'q': q,
        if (status != null) 'status': status,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return _listFromResponse(response.data);
  }

  Future<Map<String, dynamic>> createService(Map<String, dynamic> data) async {
    final response = await post('/services', data: data);
    return _mapFromResponse(response.data);
  }

  Future<Map<String, dynamic>> getServiceDetails(String serviceId) async {
    final response = await get('/services/$serviceId');
    return _mapFromResponse(response.data);
  }

  Future<Map<String, dynamic>> updateService({
    required String serviceId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch('/services/$serviceId', data: data);
    return _mapFromResponse(response.data);
  }

  Future<void> requestService(String serviceId) async {
    await post('/services/$serviceId/requests');
  }

  Future<List<dynamic>> getMyServiceRequests() async {
    final response = await get('/service-requests/my');
    return _listFromResponse(response.data);
  }

  Future<List<dynamic>> getServiceRequests({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await get(
      '/service-requests',
      queryParameters: {
        if (status != null) 'status': status,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return _listFromResponse(response.data);
  }

  Future<Map<String, dynamic>> getServiceRequestsSummary() async {
    final response = await get('/service-requests/summary');
    return _mapFromResponse(response.data);
  }

  Future<void> approveServiceRequest(String requestId) async {
    await patch('/service-requests/$requestId/approve');
  }

  Future<void> rejectServiceRequest(
    String requestId, {
    String? decisionNote,
  }) async {
    await patch(
      '/service-requests/$requestId/reject',
      data: {if (decisionNote != null) 'decisionNote': decisionNote},
    );
  }

  Future<void> cancelServiceRequest(String requestId) async {
    await patch('/service-requests/$requestId/cancel');
  }

  List<dynamic> _listFromResponse(dynamic data) {
    if (data is List<dynamic>) return data;
    if (data is Map<String, dynamic>) {
      const listKeys = [
        'data',
        'items',
        'results',
        'records',
        'rows',
        'docs',
        'services',
        'serviceCategories',
        'categories',
        'requests',
        'assignments',
      ];

      for (final key in listKeys) {
        final value = data[key];
        if (value is List<dynamic>) return value;
        if (value is Map<String, dynamic>) {
          final nested = _listFromResponse(value);
          if (nested.isNotEmpty) return nested;
        }
      }
    }
    return const [];
  }

  Map<String, dynamic> _mapFromResponse(dynamic data) {
    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data['data'] as Map<String, dynamic>);
    }
    return Map<String, dynamic>.from(data as Map);
  }
  
  Future<Map<String, dynamic>> sendChatbotMessage({
    String? sessionId,
    required String message,
  }) async {
    final response = await post(
      '/chatbot/message',
      data: {'sessionId': sessionId, 'message': message},
    );

    return _mapFromResponse(response.data);
  }

  Future<List<dynamic>> getChatbotSessions({
    String? patientId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await get(
      '/chatbot/sessions',
      queryParameters: {
        if (patientId != null && patientId.isNotEmpty) 'patientId': patientId,
        'page': page,
        'pageSize': pageSize,
      },
    );

    return _listFromResponse(response.data);
  }

  Future<List<dynamic>> getChatbotSessionMessages({
    required String sessionId,
    int page = 1,
    int pageSize = 100,
  }) async {
    final response = await get(
      '/chatbot/sessions/$sessionId/messages',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );

    return _listFromResponse(response.data);
  }

Future<Map<String, dynamic>> createReport({
    required String title,
    required String body,
  }) async {
    final response = await post(
      '/reports',
      data: {'title': title.trim(), 'body': body.trim()},
    );

    return _mapFromResponse(response.data);
  }
  
}
