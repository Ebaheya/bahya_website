import 'package:bahya_app/data/remote/repo/repo.dart';
import 'package:bloc/bloc.dart';

import '../state/notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final AppRepository repository;

  NotificationsCubit({required this.repository})
      : super(const NotificationsState());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final items = await repository.getMyNotifications();
      emit(state.copyWith(isLoading: false, notifications: items));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> refresh() async {
    emit(state.copyWith(isRefreshing: true, clearError: true));
    try {
      final items = await repository.getMyNotifications();
      emit(state.copyWith(isRefreshing: false, notifications: items));
    } catch (e) {
      emit(state.copyWith(isRefreshing: false, errorMessage: e.toString()));
    }
  }

  Future<void> claim(String id) => _act(id, 'READ', repository.claimNotification);

  Future<void> markRead(String id) =>
      _act(id, 'READ', repository.markNotificationRead);

  Future<void> markDone(String id) =>
      _act(id, 'DONE', repository.markNotificationDone);

  // Optimistically flip the local status, call the backend, roll back on error.
  Future<void> _act(
    String id,
    String nextStatus,
    Future<void> Function(String) action,
  ) async {
    if (state.actingId != null) return;
    final previous = state.notifications;
    emit(
      state.copyWith(
        actingId: id,
        clearError: true,
        notifications: previous
            .map((n) => n.id == id ? n.copyWith(status: nextStatus) : n)
            .toList(),
      ),
    );
    try {
      await action(id);
      emit(state.copyWith(clearActing: true));
    } catch (e) {
      emit(
        state.copyWith(
          clearActing: true,
          notifications: previous,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
