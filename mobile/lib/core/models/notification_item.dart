import 'package:equatable/equatable.dart';

class NotificationItem extends Equatable {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.read,
    this.timestamp,
  });

  final int id;
  final String type;
  final String title;
  final String message;
  final bool read;
  final DateTime? timestamp;

  NotificationItem copyWith({
    bool? read,
  }) {
    return NotificationItem(
      id: id,
      type: type,
      title: title,
      message: message,
      read: read ?? this.read,
      timestamp: timestamp,
    );
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      type: (json['type'] as String?) ?? 'info',
      title: (json['title'] as String?) ?? '',
      message: (json['message'] as String?) ?? '',
      read: json['read'] == true,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [id, type, title, message, read, timestamp];
}
