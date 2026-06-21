import 'package:bahya_website/bloc/states/user_state.dart';
import 'package:bahya_website/data/api/models/user_model.dart';
import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bloc/bloc.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  final List<UserModel> users = [];
  final AppRepository repository = AppRepository();
  final WebService web = WebService();

  Future<List<UserModel>> getAllUserInfo() async {
    emit(UserLoading());
    try {
      final data = await repository.getAllUserInfo();
      users.clear();
      users.addAll(data);
      emit(UserLoaded(users: users));
      return data;
    } catch (e) {
      emit(UserError(message: e.toString()));
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<List<UserModel>> getFilteredUserInfo({
    String? nameOrEmail,
    UserRole? role,
    bool? isActive,
  }) async {
    emit(UserLoading());
    try {
      final data = await repository.getFilteredUserInfo(
        nameOrEmail: nameOrEmail,
        role: role,
        isActive: isActive,
      );
      users.clear();
      users.addAll(data);
      emit(UserFilteredLoaded(users: users));
      return data;
    } catch (e) {
      emit(UserError(message: e.toString()));
      throw Exception('Failed to fetch filtered users: $e');
    }
  }

  Future<void> updateUserName({
    required String userId,
    required String fullName,
  }) async {
    try {
      await web.updateUser(userId: userId, fullName: fullName);
      await getAllUserInfo();
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> changeStatus({
    required String userId,
    required bool isActive,
  }) async {
    try {
      await web.changeUserStatus(userId: userId, isActive: isActive);
      await getAllUserInfo();
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> sendResetLink({required String userId}) async {
    try {
      await web.triggerUserReset(userId: userId);
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }
}
