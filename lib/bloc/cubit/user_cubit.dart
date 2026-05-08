import 'package:bahya_website/bloc/states/user_state.dart';
import 'package:bahya_website/data/api/models/user_model.dart';
import 'package:bahya_website/data/api/repo/repo.dart';
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
}
