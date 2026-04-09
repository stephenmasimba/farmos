import 'package:equatable/equatable.dart';

class ExpenseAttachment extends Equatable {
  const ExpenseAttachment({
    required this.id,
    required this.transactionId,
    required this.fileUrl,
    required this.fileName,
    this.uploadedAt,
  });

  final int id;
  final int transactionId;
  final String fileUrl;
  final String fileName;
  final DateTime? uploadedAt;

  factory ExpenseAttachment.fromJson(Map<String, dynamic> json) {
    return ExpenseAttachment(
      id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      transactionId: int.tryParse((json['transaction_id'] ?? '0').toString()) ?? 0,
      fileUrl: (json['file_url'] as String?) ?? '',
      fileName: (json['file_name'] as String?) ?? '',
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.tryParse(json['uploaded_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'transaction_id': transactionId,
        'file_url': fileUrl,
        'file_name': fileName,
      };

  @override
  List<Object?> get props => [id, transactionId, fileUrl];
}
