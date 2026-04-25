import 'dart:developer';
import 'package:bahya_website/helper/strings.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Dio dio = Dio();

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
    saveTokens(
      accessToken: response.data['accessToken'],
      refreshToken: response.data['refreshToken'],
    );
    log('Refresh Token : ${response.data['refreshToken']}');
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
      await clearTokens();
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

Future<void> saveTokens({
  required String accessToken,
  required String refreshToken,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    log('Tokens saved successfully');
  } catch (e) {
    log('Error saving tokens: $e');
  }
}

Future<void> clearTokens() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
  } catch (e) {
    log('Error clearing tokens: $e');
  }
}
