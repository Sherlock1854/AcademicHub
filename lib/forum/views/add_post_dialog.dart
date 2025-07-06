// lib/views/forum/add_post_dialog.dart

import 'package:flutter/material.dart';
import '../services/forum_service.dart';

class AddPostDialog extends StatefulWidget {
  final String topicId;
  const AddPostDialog({super.key, required this.topicId});

  @override
  State<AddPostDialog> createState() => _AddPostDialogState();
}

class _AddPostDialogState extends State<AddPostDialog> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl  = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final body  = _bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) return;

    setState(() => _loading = true);
    try {
      await ForumService().addPost(
        topicId: widget.topicId,
        author: 'CurrentUser', // replace with your auth user
        title: title,
        body: body,
      );
      Navigator.of(context).pop();  // close on success
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return AlertDialog(
      title: const Text('New Post'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _bodyCtrl,
            decoration: const InputDecoration(labelText: 'Body'),
            maxLines: 4,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Post'),
        ),
      ],
    );
  }
}
