import 'dart:async';
import 'dart:developer';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/data/local/data_secure.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

final dio = Dio(BaseOptions(baseUrl: baseUrl));

void initDio() {
  setupInterceptors(dio);
}

Future<void> login({required String email, required String password}) async {
  try {
    final response = await dio.post(
      '$baseUrl/auth/login',
      // "email": "admin@clinic.local",
      // "password": "ChangeMe!123",
      data: {"email": email, "password": password},
      options: Options(contentType: 'application/json'),
    );
    log('Login successful: ${response.data}');
    await SecureStorageService().saveTokens(
      accessToken: response.data['accessToken'],
      refreshToken: response.data['refreshToken'],
    );
  } on DioException catch (e) {
    throw Exception(e.response?.data ?? "Login failed");
  } catch (e) {
    log('Unexpected error: $e');
    throw Exception('Something went wrong');
  }
}

Future<void> logout({required String refreshToken}) async {
  try {
    final response = await dio.post(
      '$baseUrl/auth/logout',
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
        // Public endpoints
        final publicEndpoints = ['/auth/login', '/auth/refresh', '/health'];

        final isPublic = publicEndpoints.any(
          (endpoint) => options.path.contains(endpoint),
        );

        if (!isPublic) {
          final storage = SecureStorageService();
          final token = await storage.getAccessToken();

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }

        handler.next(options);
      },

      onError: (DioException e, handler) async {
        final storage = SecureStorageService();

        if (e.response?.statusCode == 401 &&
            e.requestOptions.extra['retried'] != true) {
          try {
            final refreshToken = await storage.getRefreshToken();

            final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));

            final refreshResponse = await refreshDio.post(
              '/auth/refresh',
              data: {"refreshToken": refreshToken},
            );

            // Refresh success
            if (refreshResponse.statusCode == 200) {
              final newAccess = refreshResponse.data['accessToken'];

              final newRefresh = refreshResponse.data['refreshToken'];

              await storage.saveTokens(
                accessToken: newAccess,
                refreshToken: newRefresh,
              );

              final request = e.requestOptions;

              request.headers['Authorization'] = 'Bearer $newAccess';

              request.extra['retried'] = true;

              final response = await dio.fetch(request);

              return handler.resolve(response);
            }
          } catch (refreshError) {
            await storage.clearTokens();

            debugPrint('Refresh Token Error: $refreshError');
          }
        }

        handler.next(e);
      },
    ),
  );
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
