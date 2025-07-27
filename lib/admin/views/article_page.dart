// lib/admin/views/article_page.dart

import 'package:flutter/material.dart';
import '../models/course_content.dart';

const Color functionBlue = Color(0xFF006FF9);

class ArticlePage extends StatefulWidget {
  final CourseContent? existing;
  static const String routeName = '/admin/article';

  const ArticlePage({Key? key, this.existing}) : super(key: key);

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  late final TextEditingController _titleCtl;
  late final TextEditingController _bodyCtl;

  @override
  void initState() {
    super.initState();
    _titleCtl = TextEditingController(text: widget.existing?.title ?? '');
    final initialBody = (widget.existing?.url.startsWith('text:') == true)
        ? widget.existing!.url.substring(5)
        : '';
    _bodyCtl = TextEditingController(text: initialBody);
  }

  void _save() {
    final title = _titleCtl.text.trim();
    final body = _bodyCtl.text.trim();
    if (title.isEmpty || body.isEmpty) return;

    final id = widget.existing?.id ?? UniqueKey().toString();
    final content = CourseContent(
      id: id,
      type: ContentType.article,
      url: 'text:$body',
      title: title,
    );
    Navigator.of(context).pop(content);
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _bodyCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Article' : 'Add Article',
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: functionBlue),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Title field
            TextField(
              controller: _titleCtl,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Body field
            Expanded(
              child: TextField(
                controller: _bodyCtl,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            const SizedBox(height: 16),
            // Save button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _save,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: functionBlue,
                  side: const BorderSide(color: functionBlue),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
