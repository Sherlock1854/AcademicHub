// lib/views/forum/add_topic_dialog.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int _currentLength = 0;

  String? _errorText;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      setState(() {
        _currentLength = _ctrl.text.length;
        // clear error once user types
        if (_errorText != null) _errorText = null;
      });
    });
  }

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
      if (_errorText != null) _errorText = null;
    });
  }

  Future<void> _submit() async {
    final title = _ctrl.text.trim();

    if (_pickedImage == null) {
      setState(() => _errorText = 'Please pick an icon for your topic');
      return;
    }
    if (title.isEmpty) {
      setState(() => _errorText = 'Please enter a topic title');
      return;
    }

    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    try {
      await ForumService().addTopic(title: title, iconFile: _pickedImage);
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = 'Failed to add topic: $e';
      });
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Text(
                'New Topic',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Icon picker
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
              const SizedBox(height: 16),

              // Text field
              TextField(
                controller: _ctrl,
                minLines: 1,
                maxLines: 3,
                maxLength: 80,
                inputFormatters: [LengthLimitingTextInputFormatter(80)],
                decoration: InputDecoration(
                  hintText: 'Topic title',
                  filled: true,
                  fillColor: Colors.white,
                  counterText: '',
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),

              // Character counter
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$_currentLength/80',
                  style: TextStyle(
                    fontSize: 12,
                    color: _currentLength > 80
                        ? Colors.red
                        : Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Error banner below counter
              if (_errorText != null)
                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorText!,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed:
                    _isLoading ? null : () => Navigator.of(ctx).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.blue)),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.blue,
                      ),
                    )
                        : const Text('Add',
                        style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
