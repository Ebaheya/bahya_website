import 'package:bahya_website/bloc/states/user_state.dart';
import 'package:bahya_website/data/api/models/user_model.dart';
import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bloc/bloc.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());
  final List<UserModel> users = [];
  final AppRepository repository = AppRepository();

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
}
