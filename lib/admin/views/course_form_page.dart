// lib/admin/views/course_form_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/course.dart';
import '../models/course_section.dart';
import '../models/course_content.dart';
import '../services/admin_service.dart';
import 'article_page.dart';

class CourseFormPage extends StatefulWidget {
  final Course? editCourse;
  const CourseFormPage({Key? key, this.editCourse}) : super(key: key);

  @override
  _CourseFormPageState createState() => _CourseFormPageState();
}

class _CourseFormPageState extends State<CourseFormPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Step 1 controllers
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  String? _category;
  File? _thumbFile;
  String? _thumbUrl;

  // Step 2
  final _picker = ImagePicker();
  List<CourseSection> _sections = [];

  @override
  void initState() {
    super.initState();
    if (widget.editCourse != null) {
      final c = widget.editCourse!;
      _titleCtrl = TextEditingController(text: c.title);
      _descCtrl = TextEditingController(text: c.description);
      _category = c.category;
      _thumbUrl = c.thumbnailUrl;
      _sections =
          c.sections.map((s) => CourseSection.fromMap(s.id, s.toMap())).toList();
    } else {
      _titleCtrl = TextEditingController();
      _descCtrl = TextEditingController();
      _sections = [];
    }
  }

  Future<void> _pickThumb() async {
    final img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _thumbFile = File(img.path));
  }

  void _next() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep = 1);
      }
    } else {
      _save();
    }
  }

  void _back() {
    if (_currentStep == 0) {
      Navigator.pop(context);
    } else {
      setState(() => _currentStep--);
    }
  }

  Future<void> _save() async {
    final course = Course(
      id: widget.editCourse?.id ?? '',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category!,
      thumbnailUrl: _thumbUrl,
      sections: _sections,
    );
    final svc = AdminService.instance;
    if (widget.editCourse != null) {
      await svc.updateCourse(course, thumbnailFile: _thumbFile);
    } else {
      await svc.createCourse(course, thumbnailFile: _thumbFile);
    }
    Navigator.pop(context);
  }

  Future<void> _onAddContent(CourseSection sec, [int? editIndex]) async {
    ContentType? type = editIndex != null
        ? sec.contents[editIndex].type
        : await showDialog<ContentType>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Choose Content Type'),
        children: ContentType.values.map((t) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, t),
            child: Text(t.name.capitalize()),
          );
        }).toList(),
      ),
    );
    if (type == null) return;

    if (type == ContentType.article) {
      final existing = editIndex != null ? sec.contents[editIndex] : null;
      final updated = await Navigator.push<CourseContent?>(
        context,
        MaterialPageRoute(
          builder: (_) => ArticlePage(existing: existing),
        ),
      );
      if (updated != null) {
        setState(() {
          if (editIndex == null) sec.contents.add(updated);
          else sec.contents[editIndex] = updated;
        });
      }
    } else {
      await _showVideoDialog(sec, editIndex);
    }
  }

  Future<void> _showVideoDialog(CourseSection sec, int? editIndex) async {
    final existing = editIndex != null ? sec.contents[editIndex] : null;
    final titleCtl = TextEditingController(text: existing?.title);
    final urlCtl = TextEditingController(
        text: existing?.type == ContentType.video ? existing!.url : '');
    File? pickedVideo;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          editIndex == null ? 'Add Video Content' : 'Edit Video',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: titleCtl,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: urlCtl,
            decoration: const InputDecoration(labelText: 'Video URL'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Video'),
            onPressed: () async {
              final vid = await _picker.pickVideo(source: ImageSource.gallery);
              if (vid != null) setState(() => pickedVideo = File(vid.path));
            },
          ),
          if (pickedVideo != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child:
              Text('Selected: ${pickedVideo!.path.split('/').last}'),
            ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleCtl.text.trim();
              final url = pickedVideo != null
                  ? 'upload://${pickedVideo!.path}'
                  : urlCtl.text.trim();
              if (title.isEmpty || url.isEmpty) return;

              final item = CourseContent(
                id: existing?.id ?? UniqueKey().toString(),
                type: ContentType.video,
                url: url,
                title: title,
              );
              setState(() {
                if (editIndex == null) sec.contents.add(item);
                else sec.contents[editIndex] = item;
              });
              Navigator.pop(ctx);
            },
            child: Text(editIndex == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Widget _step1() => Form(
    key: _formKey,
    child: Column(children: [
      DropdownButtonFormField<String>(
        value: _category,
        decoration: const InputDecoration(labelText: 'Category'),
        items: ['Science', 'Math', 'History', 'Literature']
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        onChanged: (v) => setState(() => _category = v),
        validator: (v) => v == null ? 'Required' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _titleCtrl,
        decoration: const InputDecoration(labelText: 'Course Title'),
        validator: (v) => v!.isEmpty ? 'Required' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _descCtrl,
        decoration: const InputDecoration(labelText: 'Description'),
        maxLines: 3,
      ),
      const SizedBox(height: 8),
      const Divider(),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: _pickThumb,
        child: _thumbFile != null
            ? Image.file(_thumbFile!, height: 100)
            : (_thumbUrl != null
            ? Image.network(_thumbUrl!, height: 100)
            : Container(
          height: 100,
          color: Colors.grey[200],
          child:
          const Center(child: Text('Select Thumbnail')),
        )),
      ),
    ]),
  );

  Widget _step2() => Column(children: [
    for (var sec in _sections)
      Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(children: [
            Row(children: [
              Expanded(
                child: TextFormField(
                  initialValue: sec.title,
                  decoration:
                  const InputDecoration(labelText: 'Section Title'),
                  onChanged: (v) => sec.title = v,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => setState(() => _sections.remove(sec)),
              ),
            ]),
            for (int i = 0; i < sec.contents.length; i++)
              ListTile(
                leading: Icon(_iconFor(sec.contents[i].type)),
                title: Text(sec.contents[i].title),
                subtitle: Text(
                  sec.contents[i].type == ContentType.article &&
                      sec.contents[i].url.startsWith('text:')
                      ? sec.contents[i].url.substring(5)
                      : sec.contents[i].url,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (v) {
                    if (v == 'edit') _onAddContent(sec, i);
                    if (v == 'up') _moveUp(sec, i);
                    if (v == 'down') _moveDown(sec, i);
                    if (v == 'delete') _removeContent(sec, i);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'up', child: Text('Move Up')),
                    PopupMenuItem(value: 'down', child: Text('Move Down')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                onPressed: () => _onAddContent(sec),
                icon: const Icon(Icons.add),
                label: const Text('Add Content'),
              ),
            ),
          ]),
        ),
      ),
    OutlinedButton.icon(
      onPressed: () => setState(
            () => _sections.add(CourseSection.empty(UniqueKey().toString())),
      ),
      icon: const Icon(Icons.add),
      label: const Text('Add Section'),
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editCourse == null ? 'Add Course' : 'Edit Course'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _next,
        onStepCancel: _back,
        controlsBuilder: (context, details) {
          final isLast = _currentStep == 1;
          final btnLabel = isLast
              ? (widget.editCourse != null ? 'Save' : 'Create')
              : 'Continue';
          return Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: details.onStepCancel,
                    style: OutlinedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(btnLabel),
                  ),
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Basic Info'),
            content: _step1(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Sections'),
            content: _step2(),
            isActive: _currentStep >= 1,
          ),
        ],
      ),
    );
  }

  void _moveUp(CourseSection sec, int i) {
    if (i == 0) return;
    setState(() {
      final l = sec.contents;
      final tmp = l[i - 1];
      l[i - 1] = l[i];
      l[i] = tmp;
    });
  }

  void _moveDown(CourseSection sec, int i) {
    if (i >= sec.contents.length - 1) return;
    setState(() {
      final l = sec.contents;
      final tmp = l[i + 1];
      l[i + 1] = l[i];
      l[i] = tmp;
    });
  }

  void _removeContent(CourseSection sec, int i) {
    setState(() => sec.contents.removeAt(i));
  }

  IconData _iconFor(ContentType t) =>
      t == ContentType.video ? Icons.videocam : Icons.article;
}

// String extension for capitalization
extension StringExt on String {
  String capitalize() =>
      isEmpty ? '' : this[0].toUpperCase() + substring(1);
}
