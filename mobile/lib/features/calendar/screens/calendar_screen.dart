import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/livestock.dart';
import '../../../core/models/task.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';

final _calendarEventsProvider =
    FutureProvider.autoDispose<List<CalendarEvent>>((ref) async {
  final taskService = ref.read(taskServiceProvider);
  final livestockService = ref.read(livestockServiceProvider);

  final tasks = await taskService.getAll(perPage: 100);
  final livestock = await livestockService.getAll(perPage: 50);

  final events = <CalendarEvent>[];

  for (final t in tasks) {
    if (t.dueDate == null) continue;
    events.add(
      CalendarEvent(
        id: 'task-${t.id}',
        date: t.dueDate!,
        title: t.title,
        subtitle: t.description ?? 'Task due',
        type: CalendarEventType.task,
        status: t.status,
      ),
    );
  }

  for (final batch in livestock) {
    if (batch.expectedHarvestDate != null) {
      events.add(
        CalendarEvent(
          id: 'harvest-${batch.id}',
          date: batch.expectedHarvestDate!,
          title: 'Harvest: ${batch.batchCode}',
          subtitle: '${batch.animalType} · ${batch.breed}',
          type: CalendarEventType.harvest,
          status: batch.status,
        ),
      );
    }

    final batchEvents = await livestockService.getEvents(batch.id);
    for (final e in batchEvents) {
      events.add(
        CalendarEvent(
          id: 'event-${e.id}',
          date: e.eventDate,
          title: _titleForEvent(e),
          subtitle: e.description ?? batch.batchCode,
          type: CalendarEventType.livestock,
          status: e.eventType,
        ),
      );
    }
  }

  events.sort((a, b) => a.date.compareTo(b.date));
  return events;
});

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(_calendarEventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Farm Calendar')),
      body: events.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(_calendarEventsProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.calendar_month_rounded,
              title: 'No scheduled events',
              subtitle: 'Task due dates and livestock events appear here.',
            );
          }

          final grouped = _groupByDay(list);
          final days = grouped.keys.toList()..sort();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_calendarEventsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: days.length,
              itemBuilder: (_, i) {
                final day = days[i];
                final dayEvents = grouped[day]!;
                return _DaySection(day: day, events: dayEvents);
              },
            ),
          );
        },
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({required this.day, required this.events});

  final DateTime day;
  final List<CalendarEvent> events;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                Fmt.date(day),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${events.length}',
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...events.map((e) => _EventCard(event: e)),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (event.type) {
      CalendarEventType.task => (Icons.task_alt_rounded, AppColors.info, 'TASK'),
      CalendarEventType.livestock =>
        (Icons.pets_rounded, AppColors.primary, 'LIVESTOCK'),
      CalendarEventType.harvest =>
        (Icons.agriculture_rounded, AppColors.success, 'HARVEST'),
    };

    final isPastDue = event.date.isBefore(DateTime.now()) &&
        event.type == CalendarEventType.task &&
        (event.status != 'completed');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(30),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(event.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(
          '${Fmt.time(event.date)} · ${event.subtitle}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: isPastDue ? AppColors.error : AppColors.onSurfaceVariant,
            fontWeight: isPastDue ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

enum CalendarEventType { task, livestock, harvest }

class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.status,
  });

  final String id;
  final DateTime date;
  final String title;
  final String subtitle;
  final CalendarEventType type;
  final String status;
}

String _titleForEvent(LivestockEvent e) {
  final type = e.eventType.trim();
  if (type.isEmpty) return 'Livestock Event';
  return '${type[0].toUpperCase()}${type.substring(1)}';
}

Map<DateTime, List<CalendarEvent>> _groupByDay(List<CalendarEvent> events) {
  final map = <DateTime, List<CalendarEvent>>{};
  for (final e in events) {
    final day = DateTime(e.date.year, e.date.month, e.date.day);
    map.putIfAbsent(day, () => []);
    map[day]!.add(e);
  }
  return map;
}
