import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/iot.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/providers/sync_providers.dart';
import '../../../core/services/cache_status_service.dart';
import '../../../core/services/iot_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';

final _devicesProvider = FutureProvider.autoDispose<List<IoTDevice>>((ref) {
  return ref.read(iotServiceProvider).getDevices();
});

final _readingsProvider =
    FutureProvider.autoDispose<List<SensorReading>>((ref) {
  return ref.read(iotServiceProvider).getLatestReadings();
});

final _alertsProvider = FutureProvider.autoDispose<List<IoTAlert>>((ref) {
  return ref.read(iotServiceProvider).getAlerts();
});

final _waterQualityProvider =
    FutureProvider.autoDispose<List<WaterQualityLog>>((ref) {
  return ref.read(iotServiceProvider).getWaterQuality();
});

class IoTScreen extends ConsumerStatefulWidget {
  const IoTScreen({super.key});

  @override
  ConsumerState<IoTScreen> createState() => _IoTScreenState();
}

class _IoTScreenState extends ConsumerState<IoTScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alerts = ref.watch(_alertsProvider);
    final pendingChanges =
      ref.watch(pendingModuleChangesProvider('/api/iot'));
    final cacheStatus = latestOfflineStatus(
      ref.watch(cacheStatusServiceProvider),
      const [
        IoTService.devicesStatusKey,
        IoTService.readingsStatusKey,
        IoTService.alertsStatusKey,
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Monitoring'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            const Tab(text: 'Devices'),
            const Tab(text: 'Sensors'),
            Tab(
              child: alerts.whenOrNull(
                    data: (a) => a.isNotEmpty
                        ? Badge(label: Text('${a.length}'), child: const Text('Alerts'))
                        : const Text('Alerts'),
                  ) ??
                  const Text('Alerts'),
            ),
              const Tab(text: 'Water'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (cacheStatus != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: OfflineDataBanner(
                lastUpdatedAt: cacheStatus.lastUpdatedAt,
              ),
            ),
          pendingChanges.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (count) => count > 0
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: UnsyncedChangesChip(
                      count: count,
                      onTap: () => context.push('/sync?module=iot'),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [
                _DevicesTab(),
                _SensorsTab(),
                _AlertsTab(),
                  _WaterQualityTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRegisterDevice(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Register Device'),
      ),
    );
  }

  Future<void> _showRegisterDevice(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _RegisterDeviceSheet(),
    );
    if (result == true) {
      ref.invalidate(_devicesProvider);
    }
  }
}

class _DevicesTab extends ConsumerWidget {
  const _DevicesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(_devicesProvider);

    return devices.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: null),
      data: (list) {
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.sensors_off_rounded,
            title: 'No IoT devices',
            subtitle: 'Register your first device',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(_devicesProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) => _DeviceTile(device: list[i]),
          ),
        );
      },
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({required this.device});

  final IoTDevice device;

  @override
  Widget build(BuildContext context) {
    final isOnline = device.status.toLowerCase() == 'online';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (isOnline ? AppColors.success : AppColors.error)
              .withAlpha(25),
          child: Icon(
            isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
            color: isOnline ? AppColors.success : AppColors.error,
          ),
        ),
        title: Text(device.name),
        subtitle: Text('${device.deviceType} · ${device.location ?? 'Unknown'}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            StatusBadge(status: device.status),
            if (device.lastSeen != null)
              Text(
                Fmt.timeAgo(device.lastSeen),
                style: const TextStyle(
                    color: AppColors.onSurfaceVariant, fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }
}

class _SensorsTab extends ConsumerWidget {
  const _SensorsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readings = ref.watch(_readingsProvider);

    return readings.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: null),
      data: (list) {
        if (list.isEmpty) {
          return const EmptyState(icon: Icons.sensors_rounded, title: 'No readings');
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(_readingsProvider),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (_, i) => _SensorCard(reading: list[i]),
          ),
        );
      },
    );
  }
}

class _SensorCard extends StatelessWidget {
  const _SensorCard({required this.reading});

  final SensorReading reading;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reading.sensorType,
                style:
                    const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
            const Spacer(),
            Text('${reading.value} ${reading.unit}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(Fmt.timeAgo(reading.timestamp),
                style: const TextStyle(
                    fontSize: 10, color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _AlertsTab extends ConsumerWidget {
  const _AlertsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(_alertsProvider);

    return alerts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: null),
      data: (list) {
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.check_circle_rounded,
            title: 'No active alerts',
            subtitle: 'All monitored values are within thresholds',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (_, i) => _AlertTile(alert: list[i]),
        );
      },
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});

  final IoTAlert alert;

  @override
  Widget build(BuildContext context) {
    final color = switch (alert.severity) {
      'critical' => AppColors.error,
      'high' => AppColors.warning,
      'medium' => AppColors.info,
      _ => AppColors.onSurfaceVariant,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.warning_amber_rounded, color: color),
        title: Text(alert.message),
        subtitle: Text('${alert.type} · ${Fmt.timeAgo(alert.timestamp)}'),
        trailing: StatusBadge(status: alert.severity),
      ),
    );
  }
}

class _RegisterDeviceSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_RegisterDeviceSheet> createState() => _RegisterDeviceSheetState();
}

class _RegisterDeviceSheetState extends ConsumerState<_RegisterDeviceSheet> {
  final _form = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _typeCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(iotServiceProvider).registerDevice({
        'name': _nameCtrl.text.trim(),
        'device_type': _typeCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'status': 'online',
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
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Device Name *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _typeCtrl,
              decoration: const InputDecoration(labelText: 'Device Type *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Register Device'),
            ),
          ],
        ),
      ),
    );
  }
}

  class _WaterQualityTab extends ConsumerWidget {
    const _WaterQualityTab();

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final logs = ref.watch(_waterQualityProvider);

      return Scaffold(
        body: logs.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorView(message: e.toString(), onRetry: null),
          data: (list) {
            if (list.isEmpty) {
              return const EmptyState(
                icon: Icons.water_drop_outlined,
                title: 'No water quality logs',
                subtitle: 'Add a log to track pH, oxygen & turbidity',
              );
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(_waterQualityProvider),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) => _WaterQualityTile(log: list[i]),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'wq_fab',
          onPressed: () async {
            final ok = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              builder: (_) => _AddWaterQualitySheet(),
            );
            if (ok == true) ref.invalidate(_waterQualityProvider);
          },
          icon: const Icon(Icons.add),
          label: const Text('Log Sample'),
        ),
      );
    }
  }

  class _WaterQualityTile extends StatelessWidget {
    const _WaterQualityTile({required this.log});

    final WaterQualityLog log;

    Color get _phColor {
      if (log.ph < 6.5 || log.ph > 8.5) return AppColors.error;
      if (log.ph < 7.0 || log.ph > 8.0) return AppColors.warning;
      return AppColors.success;
    }

    @override
    Widget build(BuildContext context) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(log.source,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(log.date,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _MetricChip(
                    label: 'pH ${log.ph.toStringAsFixed(1)}',
                    color: _phColor,
                  ),
                  const SizedBox(width: 8),
                  _MetricChip(
                    label: 'O₂ ${log.dissolvedOxygen.toStringAsFixed(1)}',
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  _MetricChip(
                    label: 'Turb ${log.turbidity.toStringAsFixed(1)}',
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
              ),
              if (log.notes != null && log.notes!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(log.notes!,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ],
          ),
        ),
      );
    }
  }

  class _MetricChip extends StatelessWidget {
    const _MetricChip({required this.label, required this.color});

    final String label;
    final Color color;

    @override
    Widget build(BuildContext context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      );
    }
  }

  class _AddWaterQualitySheet extends ConsumerStatefulWidget {
    @override
    ConsumerState<_AddWaterQualitySheet> createState() =>
        _AddWaterQualitySheetState();
  }

  class _AddWaterQualitySheetState
      extends ConsumerState<_AddWaterQualitySheet> {
    final _form = GlobalKey<FormState>();
    final _sourceCtrl = TextEditingController();
    final _phCtrl = TextEditingController();
    final _oxygenCtrl = TextEditingController();
    final _turbidityCtrl = TextEditingController();
    final _notesCtrl = TextEditingController();
    bool _loading = false;

    @override
    void dispose() {
      _sourceCtrl.dispose();
      _phCtrl.dispose();
      _oxygenCtrl.dispose();
      _turbidityCtrl.dispose();
      _notesCtrl.dispose();
      super.dispose();
    }

    Future<void> _submit() async {
      if (!_form.currentState!.validate()) return;
      setState(() => _loading = true);
      try {
        await ref.read(iotServiceProvider).addWaterQuality({
          'date': DateTime.now().toIso8601String().substring(0, 10),
          'source': _sourceCtrl.text.trim(),
          'ph': double.parse(_phCtrl.text.trim()),
          'dissolved_oxygen': double.parse(_oxygenCtrl.text.trim()),
          'turbidity': double.parse(_turbidityCtrl.text.trim()),
          if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
        });
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(e.toString()),
                backgroundColor: AppColors.error),
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
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Log Water Sample',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sourceCtrl,
                decoration: const InputDecoration(
                    labelText: 'Source (e.g. Pond, Well) *'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _phCtrl,
                    decoration: const InputDecoration(labelText: 'pH *'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) =>
                        double.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _oxygenCtrl,
                    decoration: const InputDecoration(labelText: 'O₂ (mg/L) *'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) =>
                        double.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _turbidityCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Turbidity *'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) =>
                        double.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                ),
              ]),
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
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Save Sample'),
              ),
            ],
          ),
        ),
      );
    }
  }
