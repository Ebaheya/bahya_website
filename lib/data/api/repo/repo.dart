import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/data/api/models/user_model.dart';
import 'package:dio/dio.dart';

class AppRepository {
  Future<UserModel> getUserProfile({required String accessToken}) async {
    try {
      final data = await getUserInfo(accessToken: accessToken);
      return UserModel.fromJson(data['user']);
      
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get user');
    } catch (e) {
      throw Exception('Unexpected error');
    }
  }
}
