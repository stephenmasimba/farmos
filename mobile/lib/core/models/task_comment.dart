import 'package:equatable/equatable.dart';

class TaskComment extends Equatable {
  const TaskComment({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int taskId;
  final int userId;
  final String userName;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory TaskComment.fromJson(Map<String, dynamic> json) {
    return TaskComment(
      id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      taskId: int.tryParse((json['task_id'] ?? '0').toString()) ?? 0,
      userId: int.tryParse((json['user_id'] ?? '0').toString()) ?? 0,
      userName: (json['user_name'] as String?) ?? 'Unknown',
      content: (json['content'] as String?) ?? '',
      createdAt: DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'task_id': taskId,
        'content': content,
      };

  @override
  List<Object?> get props => [id, taskId, userId, createdAt];
}
