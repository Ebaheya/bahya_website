import 'dart:async';
import 'dart:developer';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/data/local/data_secure.dart';
import 'package:bahya_website/route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

final dio = Dio(BaseOptions(baseUrl: baseUrl));

void initDio() {
  setupInterceptors(dio);
}

Future<void> login({required String email, required String password}) async {
  try {
    final response = await dio.post(
      '/auth/login',

      data: {"email": email.trim().toLowerCase(), "password": password.trim()},

      options: Options(contentType: Headers.jsonContentType),
    );

    debugPrint('Login successful');

    final accessToken = response.data['accessToken'];

    final refreshToken = response.data['refreshToken'];

    if (accessToken == null || refreshToken == null) {
      throw Exception('Invalid tokens received');
    }

    await SecureStorageService().saveTokens(
      accessToken: accessToken,

      refreshToken: refreshToken,
    );
  } on DioException catch (e) {
    debugPrint('Login Error: ${e.response?.data}');

    final errorMessage =
        e.response?.data?['error']?['message'] ??
        e.response?.data?['message'] ??
        'Login failed';

    throw Exception(errorMessage);
  } catch (e) {
    debugPrint('Unexpected error: $e');

    throw Exception('Something went wrong');
  }
}

Future<void> logout({required String refreshToken}) async {
  try {
    final response = await dio.post(
      '/auth/logout',
      data: {"refreshToken": refreshToken},
    );
    if (response.statusCode == 204 || response.statusCode == 200) {
      await SecureStorageService().clearTokens();
    } else {
      throw Exception("Logout failed");
    }
  } on DioException catch (e) {
    throw Exception(e.response?.data ?? 'Logout failed');
  } catch (e) {
    log('Unexpected error: $e');
    throw Exception('Something went wrong');
  }
}

// Future<Response> safeRequest(
//   Future<Response> Function(String? token) request,
// ) async {
//   final storage = SecureStorageService();
//   String? accessToken = await storage.getAccessToken();

//   try {
//     return await request(accessToken);
//   } on DioException catch (e) {
//     if (e.response?.statusCode == 401) {
//       try {
//         final refreshToken = await storage.getRefreshToken();

//         final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));

//         final refreshResponse = await refreshDio.post(
//           '$baseUrl/auth/refresh',
//           data: {"refreshToken": refreshToken},
//         );

//         if (refreshResponse.statusCode == 200) {
//           final newAccess = refreshResponse.data['accessToken'];
//           final newRefresh = refreshResponse.data['refreshToken'];

//           await storage.saveTokens(
//             accessToken: newAccess,
//             refreshToken: newRefresh,
//           );

//           return await request(newAccess);
//         } else {
//           throw Exception("Refresh failed");
//         }
//       } catch (_) {
//         await storage.clearTokens();
//         rethrow;
//       }
//     }
//     rethrow;
//   }
// }

void setupInterceptors(Dio dio) {
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

          final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));

          final refreshResponse = await refreshDio.post(
            '/auth/refresh',
            data: {"refreshToken": refreshToken},
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

  AppRouter.router.go('/login');
  
}
// final response = await safeRequest((token) {
//   return dio.get(
//     '/profile',
//     options: Options(
//       headers: {
//         'Authorization': 'Bearer $token',
//       },
//     ),
//   );
// });
