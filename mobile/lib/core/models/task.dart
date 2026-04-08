import 'package:equatable/equatable.dart';

class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    this.description,
    this.assignedTo,
    this.assigneeName,
    this.dueDate,
    this.createdBy,
    this.createdAt,
  });

  final int id;
  final String title;
  final String status; // pending | in_progress | completed | cancelled
  final String priority; // low | medium | high | urgent
  final String? description;
  final int? assignedTo;
  final String? assigneeName;
  final DateTime? dueDate;
  final int? createdBy;
  final DateTime? createdAt;

  bool get isOverdue =>
      dueDate != null &&
      dueDate!.isBefore(DateTime.now()) &&
      status != 'completed' &&
      status != 'cancelled';

  factory Task.fromJson(Map<String, dynamic> j) => Task(
        id: j['id'] as int,
        title: j['title'] as String? ?? '',
        status: j['status'] as String? ?? 'pending',
        priority: j['priority'] as String? ?? 'medium',
        description: j['description'] as String?,
        assignedTo: j['assigned_to'] as int?,
        assigneeName: j['assignee_name'] as String?,
        dueDate: _parseDate(j['due_date']),
        createdBy: j['created_by'] as int?,
        createdAt: _parseDate(j['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'status': status,
        'priority': priority,
        if (description != null) 'description': description,
        if (assignedTo != null) 'assigned_to': assignedTo,
        if (dueDate != null) 'due_date': dueDate!.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, title, status, priority];
}

class TaskStats extends Equatable {
  const TaskStats({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.completed,
    required this.overdue,
  });

  final int total;
  final int pending;
  final int inProgress;
  final int completed;
  final int overdue;

  factory TaskStats.fromJson(Map<String, dynamic> j) => TaskStats(
        total: _parseInt(j['total']),
        pending: _parseInt(j['pending']),
        inProgress: _parseInt(j['in_progress']),
        completed: _parseInt(j['completed']),
        overdue: _parseInt(j['overdue']),
      );

  @override
  List<Object?> get props => [total, pending, completed, overdue];
}

int _parseInt(dynamic v) => v == null ? 0 : int.tryParse(v.toString()) ?? 0;
DateTime? _parseDate(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString());
