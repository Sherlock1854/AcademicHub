// lib/views/forum/add_topic_dialog.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/forum_service.dart';

class AddTopicDialog extends StatefulWidget {
  const AddTopicDialog({Key? key}) : super(key: key);

  @override
  State<AddTopicDialog> createState() => _AddTopicDialogState();
}

class _AddTopicDialogState extends State<AddTopicDialog> {
  final TextEditingController _ctrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() {
      _pickedImage = File(file.path);
    });
  }

  Future<void> _submit() async {
    final title = _ctrl.text.trim();
    if (title.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await ForumService().addTopic(
        title: title,
        iconFile: _pickedImage,
      );
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add topic: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return AlertDialog(
      title: const Text('New Topic'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon picker preview
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.grey[200],
              backgroundImage:
              _pickedImage != null ? FileImage(_pickedImage!) : null,
              child: _pickedImage == null
                  ? const Icon(Icons.add_a_photo, color: Colors.grey)
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            decoration: const InputDecoration(hintText: 'Topic title'),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text('Add'),
        ),
      ],
    );
  }
}
