import 'dart:developer';

import 'package:bahya_website/helper/strings.dart';
import 'package:dio/dio.dart';

final Dio dio = Dio();
Future<Map<String, dynamic>> getUserInfo({required String accessToken}) async {
  final res = await dio.get(
    '$baseUrl/auth/me',
    options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
  );
  log('User info response: ${res.data}');
  return res.data;
}
