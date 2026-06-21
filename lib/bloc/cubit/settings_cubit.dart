import 'package:bahya_website/bloc/states/settings_state.dart';
import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this.repo) : super(const SettingsState());

  final AppRepository repo;
  final WebService web = WebService();

  Future<void> loadData({int page = 1}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final userRes = await web.getUserInfo();
      final logsRes = await repo.getAuditLogs(page: page, pageSize: 10);

      final logs = List<Map<String, dynamic>>.from(
        (logsRes["data"] ?? []).map((e) => Map<String, dynamic>.from(e)),
      );

      final userNamesById = await _loadUserNamesFromLogs(logs);

      final user = userRes["user"] is Map
          ? Map<String, dynamic>.from(userRes["user"])
          : Map<String, dynamic>.from(userRes);

      emit(
        state.copyWith(
          isLoading: false,
          user: user,
          logs: logs,
          userNamesById: userNamesById,
          page: logsRes["page"] ?? page,
          pageSize: logsRes["pageSize"] ?? 10,
          total: logsRes["total"] ?? 0,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<Map<String, String>> _loadUserNamesFromLogs(
    List<Map<String, dynamic>> logs,
  ) async {
    final ids = logs
        .map((e) => e['actorId']?.toString())
        .whereType<String>()
        .where((id) => id.trim().isNotEmpty)
        .toSet();

    final result = <String, String>{};

    for (final id in ids) {
      try {
        final user = await repo.getUserById(id);
        result[id] = user['fullName']?.toString() ?? id;
      } catch (_) {
        result[id] = id;
      }
    }

    return result;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(state.copyWith(isChangingPassword: true, errorMessage: null));

    try {
      await web.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      emit(state.copyWith(isChangingPassword: false, passwordChanged: true));
    } catch (e) {
      emit(
        state.copyWith(
          isChangingPassword: false,
          errorMessage: e.toString(),
          passwordChanged: false,
        ),
      );
    }
  }
}
