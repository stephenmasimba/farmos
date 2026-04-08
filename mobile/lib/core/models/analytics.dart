import 'package:equatable/equatable.dart';

class AnalyticsDashboard extends Equatable {
  const AnalyticsDashboard({
    required this.activeTasks,
    required this.criticalAlerts,
    required this.dailyRevenue,
  });

  final int activeTasks;
  final int criticalAlerts;
  final List<int> dailyRevenue;

  int get totalRevenue => dailyRevenue.fold(0, (a, b) => a + b);

  factory AnalyticsDashboard.fromJson(Map<String, dynamic> j) =>
      AnalyticsDashboard(
        activeTasks: _parseInt(j['active_tasks']),
        criticalAlerts: _parseInt(j['critical_alerts']),
        dailyRevenue: ((j['daily_revenue'] as List<dynamic>?) ?? [])
            .map(_parseInt)
            .toList(),
      );

  @override
  List<Object?> get props => [activeTasks, criticalAlerts, dailyRevenue];
}

int _parseInt(dynamic v) => v == null ? 0 : int.tryParse(v.toString()) ?? 0;
