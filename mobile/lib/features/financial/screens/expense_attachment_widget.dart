import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/expense_attachment.dart';
import '../../../core/models/financial.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_colors.dart';

final _attachmentsProvider = FutureProvider.autoDispose
    .family<List<ExpenseAttachment>, int>((ref, transactionId) {
  return ref.read(fileUploadServiceProvider).listAttachments(transactionId);
});

class ExpenseAttachmentWidget extends ConsumerStatefulWidget {
  const ExpenseAttachmentWidget({
    required this.transaction,
    super.key,
  });

  final Transaction transaction;

  @override
  ConsumerState<ExpenseAttachmentWidget> createState() =>
      _ExpenseAttachmentWidgetState();
}

class _ExpenseAttachmentWidgetState
    extends ConsumerState<ExpenseAttachmentWidget> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final attachments = ref.watch(_attachmentsProvider(widget.transaction.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Receipt Photos',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: const Icon(Icons.add_a_photo),
                onPressed: _isUploading ? null : _uploadPhoto,
              ),
            ],
          ),
        ),
        if (_isUploading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: LinearProgressIndicator(),
          ),
        attachments.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: CircularProgressIndicator(),
          ),
          error: (err, st) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error loading attachments: $err'),
          ),
          data: (items) {
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No receipt photos added',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: const Icon(Icons.image),
                  title: Text(item.fileName),
                  subtitle: item.uploadedAt != null
                      ? Text(Fmt.dateTime(item.uploadedAt!))
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteAttachment(item.id),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Future<void> _uploadPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final file = File(image.path);
      await ref
          .read(fileUploadServiceProvider)
          .uploadReceiptPhoto(widget.transaction.id, file);
      ref.invalidate(_attachmentsProvider(widget.transaction.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt photo uploaded')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteAttachment(int attachmentId) async {
    try {
      await ref
          .read(fileUploadServiceProvider)
          .deleteAttachment(attachmentId);
      ref.invalidate(_attachmentsProvider(widget.transaction.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attachment deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }
}

import 'dart:io';
