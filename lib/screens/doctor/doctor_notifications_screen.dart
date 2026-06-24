import 'package:bahya_app/data/models/notification_model.dart';
import 'package:bahya_app/helper/custom_app_bar.dart';
import 'package:bahya_app/helper/custom_loading.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:bahya_app/logic/cubit/notifications_cubit.dart';
import 'package:bahya_app/logic/state/notifications_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Doctor/Admin feed of care-team alerts from GET /notifications/my.
/// HIGH_RISK chatbot alerts show the patient's triggering excerpt + flagged
/// phrases and open the real conversation transcript.
class DoctorNotificationsScreen extends StatelessWidget {
  const DoctorNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context: context,
        title: context.tr('التنبيهات'),
        subTitle: context.tr('الحالات عالية الخطورة المحوّلة من المساعد الذكي'),
        isHome: false,
      ),
      body: SafeArea(
        child: BlocConsumer<NotificationsCubit, NotificationsState>(
          listener: (context, state) {
            if (state.errorMessage != null &&
                state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr('تعذّر تنفيذ العملية'))),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return Center(child: customLoading());
            }
            if (state.notifications.isEmpty) {
              return _EmptyOrError(
                isError: state.errorMessage != null,
                onRetry: () => context.read<NotificationsCubit>().load(),
              );
            }
            return RefreshIndicator(
              onRefresh: () => context.read<NotificationsCubit>().refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.notifications.length,
                itemBuilder: (context, i) => _AlertCard(
                  notification: state.notifications[i],
                  acting: state.actingId == state.notifications[i].id,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final NotificationModel notification;
  final bool acting;

  const _AlertCard({required this.notification, required this.acting});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotificationsCubit>();
    final color = _severityColor(notification.severity);
    final isDone = notification.status == 'DONE';

    return Opacity(
      opacity: isDone ? 0.6 : 1,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: notification.isUnread
                ? color.withValues(alpha: 0.6)
                : Colors.black12,
            width: notification.isUnread ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _severityBadge(notification.severity, color),
                  const Spacer(),
                  Text(
                    _timeAgo(context, notification.createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notification.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (notification.triggerExcerpt != null &&
                  notification.triggerExcerpt!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '"${notification.triggerExcerpt!}"',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
              if (notification.flaggedPhrases.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: notification.flaggedPhrases
                      .map(
                        (p) => Chip(
                          label: Text(p, style: const TextStyle(fontSize: 11)),
                          backgroundColor: color.withValues(alpha: 0.1),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  if (notification.hasChat)
                    TextButton.icon(
                      onPressed: () {
                        if (notification.isUnread) {
                          cubit.markRead(notification.id);
                        }
                        Navigator.pushNamed(
                          context,
                          '/chatTranscript',
                          arguments: notification.sessionId,
                        );
                      },
                      icon: const Icon(Icons.forum_outlined, size: 18),
                      label: Text(context.tr('فتح المحادثة')),
                    ),
                  const Spacer(),
                  if (acting)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (!isDone)
                    TextButton(
                      onPressed: () => cubit.markDone(notification.id),
                      child: Text(context.tr('تمت المعالجة')),
                    )
                  else
                    Text(
                      context.tr('تمت'),
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _severityBadge(String severity, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          severity,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
}

class _EmptyOrError extends StatelessWidget {
  final bool isError;
  final VoidCallback onRetry;

  const _EmptyOrError({required this.isError, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(
          child: Column(
            children: [
              Icon(
                isError ? Icons.cloud_off : Icons.notifications_none,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                isError
                    ? context.tr('تعذّر تحميل التنبيهات')
                    : context.tr('لا توجد تنبيهات حالياً'),
              ),
              if (isError) ...[
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onRetry,
                  child: Text(context.tr('إعادة المحاولة')),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

Color _severityColor(String severity) {
  switch (severity.toUpperCase()) {
    case 'CRITICAL':
      return Colors.red;
    case 'HIGH':
      return Colors.deepOrange;
    case 'MEDIUM':
      return Colors.orange;
    default:
      return Colors.green;
  }
}

String _timeAgo(BuildContext context, DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inMinutes < 1) return context.tr('الآن');
  if (diff.inHours < 1) return '${diff.inMinutes} ${context.tr('دقيقة')}';
  if (diff.inDays < 1) return '${diff.inHours} ${context.tr('ساعة')}';
  return '${diff.inDays} ${context.tr('يوم')}';
}
