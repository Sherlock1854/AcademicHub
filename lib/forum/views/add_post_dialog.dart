// lib/views/forum/add_post_dialog.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../services/forum_service.dart';

class AddPostDialog extends StatefulWidget {
  final String topicId;
  const AddPostDialog({Key? key, required this.topicId}) : super(key: key);

  @override
  State<AddPostDialog> createState() => _AddPostDialogState();
}

class _AddPostDialogState extends State<AddPostDialog> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl  = TextEditingController();
  final _picker    = ImagePicker();

  List<XFile> _images = [];
  bool _loading      = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  /// Pick multiple images and append them to [_images].
  Future<void> _pickImages() async {
    try {
      final pics = await _picker.pickMultiImage();
      if (pics != null && pics.isNotEmpty) {
        setState(() {
          for (var pic in pics) {
            // avoid duplicates by path
            if (!_images.any((e) => e.path == pic.path)) {
              _images.add(pic);
            }
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick images: $e')),
      );
    }
  }

  /// Upload each image and return its download URL.
  Future<List<String>> _uploadAllImages() async {
    final user = FirebaseAuth.instance.currentUser!;
    final List<String> urls = [];

    for (var img in _images) {
      final path = 'posts'
          '/${widget.topicId}'
          '/${user.uid}'
          '/${DateTime.now().millisecondsSinceEpoch}_${img.name}';

      final ref = firebase_storage.FirebaseStorage.instance.ref(path);
      await ref.putFile(File(img.path));
      urls.add(await ref.getDownloadURL());
    }

    return urls;
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final body  = _bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to post.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // 1) Upload images (if any)
      final imageUrls = _images.isNotEmpty
          ? await _uploadAllImages()
          : <String>[];

      // 2) Create the post
      await ForumService().addPost(
        topicId:      widget.topicId,
        author:       user.uid,
        title:        title,
        body:         body,
        userImageUrl: user.photoURL ?? '',
        imageUrls:    imageUrls,
      );

      Navigator.of(context).pop();  // close dialog
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Post'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title & Body
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _bodyCtrl,
                decoration: const InputDecoration(labelText: 'Body'),
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              // Pick Images button
              TextButton.icon(
                onPressed: _loading ? null : _pickImages,
                icon: const Icon(Icons.image),
                label: const Text('Add Images'),
              ),

              // Thumbnails
              if (_images.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      return Stack(
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
                              onTap: () => setState(() => _images.removeAt(i)),
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
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text('Post'),
        ),
      ],
    );
  }
}
