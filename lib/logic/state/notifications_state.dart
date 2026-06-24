import 'package:bahya_app/data/models/notification_model.dart';

class NotificationsState {
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;
  final List<NotificationModel> notifications;
  // Id currently running a claim/read/done action (to disable its buttons).
  final String? actingId;

  const NotificationsState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.notifications = const [],
    this.actingId,
  });

  int get unreadCount =>
      notifications.where((n) => n.isUnread).length;

  NotificationsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
    List<NotificationModel>? notifications,
    String? actingId,
    bool clearActing = false,
  }) {
    return NotificationsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      notifications: notifications ?? this.notifications,
      actingId: clearActing ? null : (actingId ?? this.actingId),
    );
  }
}
