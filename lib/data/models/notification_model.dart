/// A staff notification as returned by GET /notifications/my.
///
/// For HIGH_RISK chatbot alerts the backend projects extra staff-only context
/// (reason, flaggedPhrases, and — newly — sessionId + triggerExcerpt) so the
/// doctor sees what happened and can open the conversation.
class NotificationModel {
  final String id;
  final String type;
  final String severity;
  final String status; // UNREAD | READ | DONE
  final String title;
  final String message;
  final DateTime createdAt;

  // Staff-only context (null for non-staff projections / non-crisis types).
  final String? reason;
  final List<String> flaggedPhrases;
  final String? sessionId;
  final String? triggerExcerpt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.severity,
    required this.status,
    required this.title,
    required this.message,
    required this.createdAt,
    this.reason,
    this.flaggedPhrases = const [],
    this.sessionId,
    this.triggerExcerpt,
  });

  bool get isHighRisk => type == 'HIGH_RISK';
  bool get isUnread => status == 'UNREAD';
  bool get hasChat => sessionId != null && sessionId!.isNotEmpty;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawFlagged = json['flaggedPhrases'];
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      severity: json['severity']?.toString() ?? 'LOW',
      status: json['status']?.toString() ?? 'UNREAD',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      reason: json['reason']?.toString(),
      flaggedPhrases: rawFlagged is List
          ? rawFlagged.map((e) => e.toString()).toList()
          : const [],
      sessionId: json['sessionId']?.toString(),
      triggerExcerpt: json['triggerExcerpt']?.toString(),
    );
  }

  NotificationModel copyWith({String? status}) {
    return NotificationModel(
      id: id,
      type: type,
      severity: severity,
      status: status ?? this.status,
      title: title,
      message: message,
      createdAt: createdAt,
      reason: reason,
      flaggedPhrases: flaggedPhrases,
      sessionId: sessionId,
      triggerExcerpt: triggerExcerpt,
    );
  }
}
