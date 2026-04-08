import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/weather.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';

final _currentWeatherProvider =
    FutureProvider.autoDispose<CurrentWeather>((ref) {
  return ref.read(weatherServiceProvider).getCurrent();
});

final _weatherHistoryProvider =
    FutureProvider.autoDispose<List<WeatherLog>>((ref) {
  return ref.read(weatherServiceProvider).getHistory(limit: 30);
});

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(_currentWeatherProvider);
    final history = ref.watch(_weatherHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Weather & Irrigation')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddObservation(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Log Weather'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_currentWeatherProvider);
          ref.invalidate(_weatherHistoryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            current.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorView(message: e.toString(), onRetry: null),
              data: (w) => _CurrentCard(weather: w),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Temperature Trend'),
            const SizedBox(height: 12),
            history.when(
              loading: () => const SizedBox(
                  height: 180, child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SizedBox.shrink(),
              data: (list) {
                if (list.isEmpty) return const SizedBox.shrink();
                final points = list.take(14).toList().reversed.toList();
                return SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: points
                              .asMap()
                              .entries
                              .where((e) => e.value.temperatureC != null)
                              .map((e) => FlSpot(
                                    e.key.toDouble(),
                                    e.value.temperatureC!,
                                  ))
                              .toList(),
                          isCurved: true,
                          color: AppColors.info,
                          barWidth: 3,
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.info.withAlpha(40),
                          ),
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                      titlesData: const FlTitlesData(
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        drawHorizontalLine: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) =>
                            const FlLine(color: AppColors.divider, strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Recent Logs'),
            const SizedBox(height: 8),
            history.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => ErrorView(message: e.toString(), onRetry: null),
              data: (list) {
                if (list.isEmpty) {
                  return const EmptyState(
                    icon: Icons.cloud_outlined,
                    title: 'No weather logs yet',
                  );
                }
                return Column(
                  children: list.take(10).map((w) => _LogTile(log: w)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddObservation(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddObservationSheet(),
    );
    if (result == true) {
      ref.invalidate(_currentWeatherProvider);
      ref.invalidate(_weatherHistoryProvider);
    }
  }
}

class _CurrentCard extends StatelessWidget {
  const _CurrentCard({required this.weather});

  final CurrentWeather weather;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Current Conditions',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                if (weather.forecastedAt != null)
                  Text(
                    Fmt.timeAgo(weather.forecastedAt),
                    style: const TextStyle(
                        color: AppColors.onSurfaceVariant, fontSize: 11),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _Metric(
                        'Temp', Fmt.temp(weather.temperatureC), Icons.thermostat)),
                Expanded(
                    child: _Metric('Humidity',
                        '${weather.humidityPercent.toStringAsFixed(0)}%', Icons.water_drop)),
                Expanded(
                    child: _Metric('Wind', Fmt.windSpeed(weather.windSpeedKph),
                        Icons.air_rounded)),
                Expanded(
                    child: _Metric('Rain', Fmt.rainfall(weather.rainfallMm),
                        Icons.grain_rounded)),
              ],
            ),
            const SizedBox(height: 8),
            Text(weather.conditions,
                style:
                    const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.info),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        Text(label,
            style: const TextStyle(
                color: AppColors.onSurfaceVariant, fontSize: 10)),
      ],
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.log});

  final WeatherLog log;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.cloud_outlined),
        title: Text('${Fmt.temp(log.temperatureC)} · ${log.conditions ?? '—'}'),
        subtitle: Text(
            'Humidity ${log.humidityPercent?.toStringAsFixed(0) ?? '—'}% · Rain ${Fmt.rainfall(log.rainfallMm)}'),
        trailing: Text(Fmt.date(log.logDate),
            style: const TextStyle(
                color: AppColors.onSurfaceVariant, fontSize: 11)),
      ),
    );
  }
}

class _AddObservationSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddObservationSheet> createState() => _AddObservationSheetState();
}

class _AddObservationSheetState extends ConsumerState<_AddObservationSheet> {
  final _form = GlobalKey<FormState>();
  final _tempCtrl = TextEditingController();
  final _humidityCtrl = TextEditingController();
  final _rainCtrl = TextEditingController();
  final _windCtrl = TextEditingController();
  final _conditionsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _tempCtrl.dispose();
    _humidityCtrl.dispose();
    _rainCtrl.dispose();
    _windCtrl.dispose();
    _conditionsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(weatherServiceProvider).addObservation({
        'temperature_c': double.tryParse(_tempCtrl.text.trim()),
        'humidity_percent': double.tryParse(_humidityCtrl.text.trim()),
        'rainfall_mm': double.tryParse(_rainCtrl.text.trim()),
        'wind_speed_kph': double.tryParse(_windCtrl.text.trim()),
        'conditions': _conditionsCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Observation',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _tempCtrl,
                    decoration: const InputDecoration(labelText: 'Temp (°C)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _humidityCtrl,
                    decoration: const InputDecoration(labelText: 'Humidity (%)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _rainCtrl,
                    decoration: const InputDecoration(labelText: 'Rain (mm)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _windCtrl,
                    decoration: const InputDecoration(labelText: 'Wind (km/h)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              TextFormField(
                controller: _conditionsCtrl,
                decoration: const InputDecoration(labelText: 'Conditions'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Save Observation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
