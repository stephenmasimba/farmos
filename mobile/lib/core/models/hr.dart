import 'package:equatable/equatable.dart';

class HrSop extends Equatable {
  const HrSop({
    required this.id,
    required this.title,
    required this.role,
    required this.content,
  });

  final int id;
  final String title;
  final String role;
  final String content;

  factory HrSop.fromJson(Map<String, dynamic> json) {
    return HrSop(
      id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      title: (json['title'] as String?) ?? '',
      role: (json['role'] as String?) ?? '',
      content: (json['content'] as String?) ?? '',
    );
  }

  @override
  List<Object?> get props => [id, title, role, content];
}

class HrTask extends Equatable {
  const HrTask({
    required this.id,
    required this.title,
    this.assignedTo,
    this.dueDate,
    required this.status,
  });

  final int id;
  final String title;
  final int? assignedTo;
  final DateTime? dueDate;
  final String status;

  factory HrTask.fromJson(Map<String, dynamic> json) {
    return HrTask(
      id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      title: (json['title'] as String?) ?? '',
      assignedTo: int.tryParse((json['assigned_to'] ?? '').toString()),
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'].toString())
          : null,
      status: (json['status'] as String?) ?? 'pending',
    );
  }

  @override
  List<Object?> get props => [id, title, assignedTo, dueDate, status];
}

class HrSchedule extends Equatable {
  const HrSchedule({
    required this.id,
    required this.userId,
    required this.role,
    this.startTime,
    this.endTime,
  });

  final int id;
  final int userId;
  final String role;
  final DateTime? startTime;
  final DateTime? endTime;

  factory HrSchedule.fromJson(Map<String, dynamic> json) {
    return HrSchedule(
      id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      userId: int.tryParse((json['user_id'] ?? '0').toString()) ?? 0,
      role: (json['role'] as String?) ?? '',
      startTime: json['start_time'] != null
          ? DateTime.tryParse(json['start_time'].toString())
          : null,
      endTime: json['end_time'] != null
          ? DateTime.tryParse(json['end_time'].toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [id, userId, role, startTime, endTime];
}

class HrSopExecution extends Equatable {
  const HrSopExecution({
    required this.sopId,
    required this.status,
    this.notes,
    this.executedAt,
  });

  final int sopId;
  final String status;
  final String? notes;
  final DateTime? executedAt;

  factory HrSopExecution.fromJson(Map<String, dynamic> json) {
    return HrSopExecution(
      sopId: int.tryParse((json['sop_id'] ?? '0').toString()) ?? 0,
      status: (json['status'] as String?) ?? '',
      notes: json['notes'] as String?,
      executedAt: json['executed_at'] != null
          ? DateTime.tryParse(json['executed_at'].toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [sopId, status, notes, executedAt];
}
