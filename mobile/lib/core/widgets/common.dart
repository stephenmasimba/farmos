import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../utils/formatters.dart';

/// Renders loading / error / data states from an AsyncValue<T>.
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? loading;
  final Widget Function(Object error, StackTrace? stack)? error;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => loading ?? const Center(child: CircularProgressIndicator()),
      error: (e, s) =>
          error != null
              ? error!(e, s)
              : ErrorView(message: e.toString(), onRetry: null),
      data: data,
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(title,
                style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = color ?? AppColors.primary;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: accent, size: 20),
                  ),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 12),
              Text(value,
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(color: accent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(label, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (action != null) action!,
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
            color: fg, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    );
  }

  static (Color, Color) _colors(String status) {
    return switch (status.toLowerCase()) {
      'active' || 'completed' || 'online' || 'approved' => (
          AppColors.statusActive,
          AppColors.statusActiveText
        ),
      'pending' || 'in_progress' || 'planted' => (
          AppColors.statusPending,
          AppColors.statusPendingText
        ),
      'sold' || 'harvested' || 'done' => (
          AppColors.statusDone,
          AppColors.statusDoneText
        ),
      _ => (AppColors.statusInactive, AppColors.statusInactiveText),
    };
  }
}

class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (priority.toLowerCase()) {
      'urgent' => (Icons.priority_high, AppColors.error),
      'high' => (Icons.keyboard_arrow_up, AppColors.warning),
      'medium' => (Icons.remove, AppColors.info),
      _ => (Icons.keyboard_arrow_down, AppColors.onSurfaceVariant),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 2),
        Text(
          priority.toUpperCase(),
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class OfflineDataBanner extends StatelessWidget {
  const OfflineDataBanner({
    super.key,
    this.lastUpdatedAt,
  });

  final DateTime? lastUpdatedAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = _profileFor(lastUpdatedAt);
    final detail = lastUpdatedAt == null
        ? 'Showing cached data stored on this device.'
        : 'Last synced ${Fmt.timeAgo(lastUpdatedAt)} · ${Fmt.dateTime(lastUpdatedAt)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: profile.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: profile.border),
      ),
      child: Row(
        children: [
          Icon(profile.icon, color: profile.foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: profile.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: profile.foreground.withAlpha(20),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              profile.badge,
              style: theme.textTheme.labelSmall?.copyWith(
                color: profile.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _OfflineBannerProfile _profileFor(DateTime? lastUpdatedAt) {
    if (lastUpdatedAt == null) {
      return const _OfflineBannerProfile(
        title: 'Offline data',
        badge: 'UNKNOWN AGE',
        icon: Icons.cloud_off_rounded,
        foreground: AppColors.warning,
        background: Color(0x14C88719),
        border: Color(0x66C88719),
      );
    }

    final age = DateTime.now().difference(lastUpdatedAt);
    if (age.inHours >= 24) {
      return const _OfflineBannerProfile(
        title: 'Stale offline data',
        badge: 'STALE',
        icon: Icons.schedule_rounded,
        foreground: AppColors.error,
        background: Color(0x14D64545),
        border: Color(0x66D64545),
      );
    }

    return const _OfflineBannerProfile(
      title: 'Offline data',
      badge: 'RECENT',
      icon: Icons.cloud_off_rounded,
      foreground: AppColors.warning,
      background: Color(0x14C88719),
      border: Color(0x66C88719),
    );
  }
}

class _OfflineBannerProfile {
  const _OfflineBannerProfile({
    required this.title,
    required this.badge,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.border,
  });

  final String title;
  final String badge;
  final IconData icon;
  final Color foreground;
  final Color background;
  final Color border;
}

class UnsyncedChangesChip extends StatelessWidget {
  const UnsyncedChangesChip({
    super.key,
    required this.count,
    this.onTap,
  });

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.info.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.info.withAlpha(90)),
          ),
          child: Row(
            children: [
              const Icon(Icons.sync_problem_rounded, color: AppColors.info),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$count unsynced change(s) included in this view.',
                  style: const TextStyle(
                    color: AppColors.info,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                const Icon(Icons.open_in_new_rounded,
                    size: 16, color: AppColors.info),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
