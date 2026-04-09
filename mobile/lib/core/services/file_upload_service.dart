import 'dart:io';
import 'dart:convert';

import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/expense_attachment.dart';

class FileUploadService {
  FileUploadService(this._client);

  final ApiClient _client;

  static const _maxSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
  static const _mimeByExt = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
  };

  Future<ExpenseAttachment> uploadReceiptPhoto(
    int transactionId,
    File imageFile,
  ) async {
    final bytes = await imageFile.readAsBytes();

    if (bytes.length > _maxSizeBytes) {
      throw const ApiException(message: 'File too large (max 5 MB)');
    }

    final fileName = imageFile.path.split(RegExp(r'[\\/]')).last;
    final ext = fileName.split('.').last.toLowerCase();
    if (!_allowedExtensions.contains(ext)) {
      throw const ApiException(message: 'Unsupported file type');
    }
    final mimeType = _mimeByExt[ext] ?? 'image/jpeg';

    final result = await _client.post(
      '${ApiEndpoints.financialRecords}/$transactionId/attachments',
      data: {
        'file_data': base64Encode(bytes),
        'file_name': fileName,
        'mime_type': mimeType,
      },
    );

    return ExpenseAttachment.fromJson(result);
  }

  Future<List<ExpenseAttachment>> listAttachments(int transactionId) async {
    final data = await _client.getList(
      '${ApiEndpoints.financialRecords}/$transactionId/attachments',
    );
    return data.map((e) => ExpenseAttachment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> deleteAttachment(int attachmentId) async {
    await _client.delete(
      '${ApiEndpoints.financialRecords}/attachments/$attachmentId',
    );
  }

}

