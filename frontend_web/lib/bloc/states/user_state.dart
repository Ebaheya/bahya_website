import 'package:bahya_website/data/api/models/user_model.dart';

sealed class UserState {}

final class UserInitial extends UserState {}

final class UserLoading extends UserState {}

final class UserLoaded extends UserState {
  final List<UserModel> users;
  UserLoaded({required this.users});
}

final class UserFilteredLoaded extends UserState {
  final List<UserModel> users;
  UserFilteredLoaded({required this.users});
}

final class UserError extends UserState {
  final String message;
  UserError({required this.message});
}
