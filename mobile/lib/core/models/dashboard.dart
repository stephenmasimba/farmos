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

// ---- Farm Health ----

class FarmHealthMetrics extends Equatable {
  const FarmHealthMetrics({
    required this.overallScore,
    required this.status,
    required this.livestockHealth,
    required this.inventoryHealth,
    required this.taskCompletionRate,
    required this.profitMargin,
  });

  final double overallScore;
  final String status; // excellent | good | fair | needs_attention
  final double livestockHealth;
  final double inventoryHealth;
  final double taskCompletionRate;
  final double profitMargin;

  factory FarmHealthMetrics.fromJson(Map<String, dynamic> j) {
    final scores = j['scores'] as Map<String, dynamic>? ?? {};
    return FarmHealthMetrics(
      overallScore: _parseDouble(j['overall_health_score']),
      status: j['status'] as String? ?? 'unknown',
      livestockHealth: _parseDouble(scores['livestock_health']),
      inventoryHealth: _parseDouble(scores['inventory_health']),
      taskCompletionRate: _parseDouble(scores['task_completion_rate']),
      profitMargin: _parseDouble(scores['profit_margin']),
    );
  }

  @override
  List<Object?> get props => [overallScore, status];
}

// ---- Farm Forecast ----

class FarmForecast extends Equatable {
  const FarmForecast({
    required this.inventoryCritical,
    required this.inventoryWarning,
    required this.inventoryAdequate,
    required this.monthlyTrend,
    required this.predictedIncome,
    required this.predictedExpense,
    required this.predictedProfit,
  });

  final int inventoryCritical;
  final int inventoryWarning;
  final int inventoryAdequate;
  final List<FinancialForecastMonth> monthlyTrend;
  final double predictedIncome;
  final double predictedExpense;
  final double predictedProfit;

  factory FarmForecast.fromJson(Map<String, dynamic> j) {
    final inv = j['inventory_forecast'] as Map<String, dynamic>? ?? {};
    final fin = j['financial_forecast'] as Map<String, dynamic>? ?? {};
    final predicted =
        fin['predicted_next_month'] as Map<String, dynamic>? ?? {};
    final trend = (fin['trend'] as List<dynamic>?) ?? [];
    return FarmForecast(
      inventoryCritical: _parseInt(inv['critical']),
      inventoryWarning: _parseInt(inv['warning']),
      inventoryAdequate: _parseInt(inv['adequate']),
      monthlyTrend: trend
          .map((e) =>
              FinancialForecastMonth.fromJson(e as Map<String, dynamic>))
          .toList(),
      predictedIncome: _parseDouble(predicted['income']),
      predictedExpense: _parseDouble(predicted['expense']),
      predictedProfit: _parseDouble(predicted['profit']),
    );
  }

  @override
  List<Object?> get props => [inventoryCritical, predictedProfit];
}

class FinancialForecastMonth extends Equatable {
  const FinancialForecastMonth({
    required this.month,
    required this.income,
    required this.expense,
  });

  final String month;
  final double income;
  final double expense;

  double get profit => income - expense;

  factory FinancialForecastMonth.fromJson(Map<String, dynamic> j) =>
      FinancialForecastMonth(
        month: j['month'] as String? ?? '',
        income: _parseDouble(j['income']),
        expense: _parseDouble(j['expense']),
      );

  @override
  List<Object?> get props => [month];
}
