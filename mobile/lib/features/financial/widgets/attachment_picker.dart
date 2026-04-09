import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AttachmentPicker extends StatefulWidget {
  const AttachmentPicker({
    super.key,
    required this.onImagePicked,
  });

  final ValueChanged<File?> onImagePicked;

  @override
  State<AttachmentPicker> createState() => _AttachmentPickerState();
}

class _AttachmentPickerState extends State<AttachmentPicker> {
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      final file = File(picked.path);
      setState(() => _image = file);
      widget.onImagePicked(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.camera_alt_rounded),
          label: const Text('Take Receipt Photo'),
        ),
        if (_image != null) ...[
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Receipt saved', overflow: TextOverflow.ellipsis),
          ),
        ],
      ],
    );
  }
}
