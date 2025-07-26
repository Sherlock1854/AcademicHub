// lib/views/forum/add_post_dialog.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/services.dart';

import '../services/forum_service.dart';

class AddPostDialog extends StatefulWidget {
  final String topicId;
  const AddPostDialog({Key? key, required this.topicId}) : super(key: key);

  @override
  State<AddPostDialog> createState() => _AddPostDialogState();
}

class _AddPostDialogState extends State<AddPostDialog> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _picker = ImagePicker();

  List<XFile> _images = [];
  bool _loading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _titleCtrl.addListener(_validate);
    _bodyCtrl.addListener(_validate);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    return _titleCtrl.text.trim().isNotEmpty &&
        (_bodyCtrl.text.trim().isNotEmpty || _images.isNotEmpty);
  }

  void _validate() => setState(() => _errorText = null);

  Future<void> _pickImages() async {
    try {
      final pics = await _picker.pickMultiImage();
      if (pics != null && pics.isNotEmpty) {
        setState(() {
          for (var pic in pics) {
            if (!_images.any((e) => e.path == pic.path)) {
              _images.add(pic);
            }
          }
          _errorText = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick images: $e')),
      );
    }
  }

  Future<List<String>> _uploadAllImages() async {
    final user = FirebaseAuth.instance.currentUser!;
    final List<String> urls = [];
    for (var img in _images) {
      final path =
          'posts/${widget.topicId}/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_${img.name}';
      final ref = firebase_storage.FirebaseStorage.instance.ref(path);
      await ref.putFile(File(img.path));
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      setState(() {
        _errorText = 'Please enter a title and at least a body or image.';
      });
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to post.')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      final imageUrls =
      _images.isNotEmpty ? await _uploadAllImages() : <String>[];

      await ForumService().addPost(
        topicId: widget.topicId,
        author: user.uid,
        title: _titleCtrl.text.trim(),
        body: _bodyCtrl.text.trim(),
        userImageUrl: user.photoURL ?? '',
        imageUrls: imageUrls,
      );

      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Allow the dialog to move above the keyboard
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      backgroundColor: Colors.white,
      child: Padding(
        padding: viewInsets, // <— shift up for keyboard
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 360,
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'New Post',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Make inputs + thumbnails scrollable/flexible
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Title field
                        TextField(
                          controller: _titleCtrl,
                          minLines: 1,
                          maxLines: 3,
                          maxLength: 80,
                          inputFormatters: [LengthLimitingTextInputFormatter(80)],
                          decoration: InputDecoration(
                            hintText: 'Title',
                            filled: true,
                            fillColor: Colors.white,
                            counterText: null,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              const BorderSide(color: Colors.blue, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Body field
                        TextField(
                          controller: _bodyCtrl,
                          minLines: 1,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Body',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              const BorderSide(color: Colors.blue, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Add Images button
                        OutlinedButton.icon(
                          onPressed: _loading ? null : _pickImages,
                          icon: const Icon(Icons.image, color: Colors.blue),
                          label: const Text('Add Images',
                              style: TextStyle(color: Colors.blue)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.blue),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Thumbnails
                        if (_images.isNotEmpty) ...[
                          SizedBox(
                            height: 80,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _images.length,
                              separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                              itemBuilder: (_, i) => Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_images[i].path),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _images.removeAt(i)),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(2),
                                        child: const Icon(Icons.close,
                                            size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Inline error
                        if (_errorText != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _errorText!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed:
                      _loading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child:
                      const Text('Cancel', style: TextStyle(color: Colors.blue)),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: _loading || !_canSubmit ? null : _submit,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blue),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: _loading
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blue,
                        ),
                      )
                          : const Text('Post',
                          style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
