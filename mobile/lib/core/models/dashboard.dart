import 'package:equatable/equatable.dart';

class DashboardOverview extends Equatable {
  const DashboardOverview({
    required this.totalAnimals,
    required this.totalTasks,
    required this.pendingTasks,
    required this.lowStockItems,
    required this.totalRevenue,
    required this.totalExpenses,
    this.activeAlerts,
  });

  final int totalAnimals;
  final int totalTasks;
  final int pendingTasks;
  final int lowStockItems;
  final double totalRevenue;
  final double totalExpenses;
  final int? activeAlerts;

  double get netProfit => totalRevenue - totalExpenses;

  factory DashboardOverview.fromJson(Map<String, dynamic> j) =>
      DashboardOverview(
        totalAnimals: _parseInt(
            j['total_animals'] ?? j['livestock_count'] ?? j['animals']),
        totalTasks: _parseInt(j['total_tasks'] ?? j['tasks']),
        pendingTasks: _parseInt(j['pending_tasks']),
        lowStockItems: _parseInt(j['low_stock_items'] ?? j['low_stock_count']),
        totalRevenue:
            _parseDouble(j['total_revenue'] ?? j['revenue'] ?? j['income']),
        totalExpenses: _parseDouble(j['total_expenses'] ?? j['expenses']),
        activeAlerts: _parseInt(j['active_alerts'] ?? j['alerts']),
      );

  @override
  List<Object?> get props =>
      [totalAnimals, totalTasks, totalRevenue, totalExpenses];
}

class DashboardAlert extends Equatable {
  const DashboardAlert({
    required this.id,
    required this.type,
    required this.message,
    required this.severity,
    this.createdAt,
    this.read,
  });

  final int id;
  final String type;
  final String message;
  final String severity; // info | warning | error | critical
  final DateTime? createdAt;
  final bool? read;

  factory DashboardAlert.fromJson(Map<String, dynamic> j) => DashboardAlert(
        id: j['id'] as int,
        type: j['type'] as String? ?? '',
        message: j['message'] as String? ?? '',
        severity: j['severity'] as String? ?? 'info',
        createdAt: _parseDate(j['created_at']),
        read: j['read'] as bool?,
      );

  @override
  List<Object?> get props => [id, type, severity];
}

class TimelineItem extends Equatable {
  const TimelineItem({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    this.userId,
    this.userName,
  });

  final int id;
  final String type;
  final String description;
  final DateTime timestamp;
  final int? userId;
  final String? userName;

  factory TimelineItem.fromJson(Map<String, dynamic> j) => TimelineItem(
        id: j['id'] as int,
        type: j['type'] as String? ?? '',
        description: j['description'] as String? ?? '',
        timestamp: _parseDate(j['timestamp'] ?? j['created_at']) ?? DateTime.now(),
        userId: j['user_id'] as int?,
        userName: j['user_name'] as String?,
      );

  @override
  List<Object?> get props => [id, type, timestamp];
}

int _parseInt(dynamic v) => v == null ? 0 : int.tryParse(v.toString()) ?? 0;

double _parseDouble(dynamic v) =>
    v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;

DateTime? _parseDate(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString());
