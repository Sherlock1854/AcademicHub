// lib/views/forum/add_topic_dialog.dart
import 'package:flutter/material.dart';
import '../services/forum_service.dart';

class AddTopicDialog extends StatefulWidget {
  const AddTopicDialog({super.key});
  @override
  State<AddTopicDialog> createState() => _AddTopicDialogState();
}

class _AddTopicDialogState extends State<AddTopicDialog> {
  final _ctrl = TextEditingController();
  bool _isLoading = false;

  // For simplicity, we'll hardcode a single icon.
  // You could extend this to let the user pick from a list.
  final int _chosenIconCodePoint = Icons.forum_outlined.codePoint;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _ctrl.text.trim();
    if (title.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await ForumService().addTopic(
        title: title,
        iconCodePoint: _chosenIconCodePoint,
      );
      Navigator.of(context).pop(); // close dialog on success
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
      content: TextField(
        controller: _ctrl,
        decoration: const InputDecoration(hintText: 'Topic title'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading ? const SizedBox(width:16, height:16, child: CircularProgressIndicator(strokeWidth:2)) : const Text('Add'),
        ),
      ],
    );
  }
}
