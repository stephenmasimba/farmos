import 'package:equatable/equatable.dart';

class Timesheet extends Equatable {
  const Timesheet({
    required this.id,
    required this.employeeName,
    required this.date,
    required this.hoursWorked,
    required this.taskDescription,
    required this.status,
  });

  final int id;
  final String employeeName;
  final DateTime date;
  final double hoursWorked;
  final String taskDescription;
  final String status;

  bool get isPending => status.toLowerCase() == 'pending';

  factory Timesheet.fromJson(Map<String, dynamic> json) {
    return Timesheet(
      id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      employeeName: (json['employee_name'] as String?) ?? 'Employee',
      date: DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
      hoursWorked:
          double.tryParse((json['hours_worked'] ?? '0').toString()) ?? 0.0,
      taskDescription: (json['task_description'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'Pending',
    );
  }

  @override
  List<Object?> get props =>
      [id, employeeName, date, hoursWorked, taskDescription, status];
}

class TimesheetStats extends Equatable {
  const TimesheetStats({
    required this.totalHours,
    required this.pendingApprovals,
  });

  final double totalHours;
  final int pendingApprovals;

  factory TimesheetStats.fromJson(Map<String, dynamic> json) {
    return TimesheetStats(
      totalHours:
          double.tryParse((json['total_hours'] ?? '0').toString()) ?? 0.0,
      pendingApprovals:
          int.tryParse((json['pending_approvals'] ?? '0').toString()) ?? 0,
    );
  }

  @override
  List<Object?> get props => [totalHours, pendingApprovals];
}
