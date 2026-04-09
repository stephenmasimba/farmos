import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/weather_alert.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';

final _weatherAlertsProvider = FutureProvider.autoDispose<List<WeatherAlert>>((ref) {
  return ref.read(weatherAlertServiceProvider).getActiveAlerts();
});

final _frostAlertsProvider = FutureProvider.autoDispose<List<WeatherAlert>>((ref) {
  return ref.read(weatherAlertServiceProvider).getFrostAlerts();
});

final _rainAlertsProvider = FutureProvider.autoDispose<List<WeatherAlert>>((ref) {
  return ref.read(weatherAlertServiceProvider).getHeavyRainAlerts();
});

class WeatherAlertsScreen extends ConsumerWidget {
  const WeatherAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(_weatherAlertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Alerts'),
      ),
      body: alerts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(
          child: Text('Error: $err'),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green[400]),
                  const SizedBox(height: 16),
                  const Text('No active weather alerts'),
                ],
              ),
            );
          }

          final critical = items.where((a) => a.severity == 'critical').toList();
          final warning = items.where((a) => a.severity == 'warning').toList();
          final info = items.where((a) => a.severity == 'info').toList();

          return ListView(
            children: [
              if (critical.isNotEmpty) ...[
                _buildSection('Critical', critical, Colors.red),
              ],
              if (warning.isNotEmpty) ...[
                _buildSection('Warning', warning, Colors.orange),
              ],
              if (info.isNotEmpty) ...[
                _buildSection('Informational', info, Colors.blue),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<WeatherAlert> alerts, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
        ...alerts.map((alert) => _AlertTile(alert: alert)),
      ],
    );
  }
}

class _AlertTile extends ConsumerWidget {
  const _AlertTile({required this.alert});

  final WeatherAlert alert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconMap = {
      'frost': Icons.ac_unit,
      'heavy_rain': Icons.water_drop,
      'high_wind': Icons.air,
      'heat_wave': Icons.local_fire_department,
      'drought': Icons.water_drop_outlined,
    };

    final colorMap = {
      'critical': Colors.red,
      'warning': Colors.orange,
      'info': Colors.blue,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    iconMap[alert.type] ?? Icons.warning,
                    color: colorMap[alert.severity] ?? Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.type.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          Fmt.dateTime(alert.issuedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!(alert.acknowledged ?? false))
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorMap[alert.severity]?.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'New',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorMap[alert.severity],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(alert.message),
              if (alert.location != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Location: ${alert.location}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
              if (alert.expiresAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Expires: ${Fmt.dateTime(alert.expiresAt!)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: !(alert.acknowledged ?? false)
                      ? () => _acknowledge(ref)
                      : null,
                  child: Text(alert.acknowledged ?? false
                      ? 'Acknowledged'
                      : 'Acknowledge'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _acknowledge(WidgetRef ref) async {
    try {
      await ref
          .read(weatherAlertServiceProvider)
          .acknowledgeAlert(alert.id);
      ref.invalidate(_weatherAlertsProvider);
    } catch (e) {
      _showError('Failed to acknowledge alert');
    }
  }

  void _showError(String message) {
    // Error handling - typically shown via ScaffoldMessenger
  }
}
