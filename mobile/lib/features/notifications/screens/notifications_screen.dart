import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/notification_item.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';

final _notificationsProvider =
    FutureProvider.autoDispose<List<NotificationItem>>((ref) {
  return ref.read(notificationsServiceProvider).list();
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final canView = user?.hasAnyPermission(const [
          'tasks.read',
          'reports.read',
          'users.view',
        ]) ??
        false;

    if (!canView) {
      return const Scaffold(
        appBar: AppBar(title: Text('Notifications')),
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: 'Access denied',
          subtitle: 'Your account does not have permission to view notifications.',
        ),
      );
    }

    final notifications = ref.watch(_notificationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Mark all read',
            onPressed: () async {
              try {
                await ref.read(notificationsServiceProvider).markAllRead();
                ref.invalidate(_notificationsProvider);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: notifications.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(_notificationsProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No notifications yet',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(_notificationsProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final item = list[i];
                return _NotificationTile(
                  item: item,
                  onMarkRead: item.read
                      ? null
                      : () async {
                          try {
                            await ref
                                .read(notificationsServiceProvider)
                                .markRead(item.id);
                            ref.invalidate(_notificationsProvider);
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    this.onMarkRead,
  });

  final NotificationItem item;
  final VoidCallback? onMarkRead;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: item.read ? null : const Color(0xFFF4F8FF),
      child: ListTile(
        leading: Icon(
          _iconFor(item.type),
          color: item.read ? AppColors.onSurfaceVariant : AppColors.primary,
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontWeight: item.read ? FontWeight.w500 : FontWeight.w700,
          ),
        ),
        subtitle: Text(item.message),
        trailing: item.read
            ? const Icon(Icons.done_rounded, color: AppColors.success)
            : IconButton(
                icon: const Icon(Icons.mark_email_read_rounded),
                tooltip: 'Mark as read',
                onPressed: onMarkRead,
              ),
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type.toLowerCase()) {
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'success':
        return Icons.check_circle_rounded;
      case 'error':
        return Icons.error_outline_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}
