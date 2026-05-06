import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/data/api/models/user_model.dart';
import 'package:dio/dio.dart';

class AppRepository {
  WebService webService = WebService();
  Future<UserModel> getUserProfile({required String accessToken}) async {
    try {
      final data = await webService.getUserInfo(accessToken: accessToken);
      return UserModel.fromJson(data['user']);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get user');
    } catch (e) {
      throw Exception('Unexpected error');
    }
  }

  Future<String> getServiceStatus() async {
    try {
      final data = await webService.getServiceStatus();
      return data['status'] ?? 'Unknown';
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get service status');
    } catch (e) {
      throw Exception('Unexpected error');
    }
  }
}
