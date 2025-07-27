import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/quiz.dart';
import '../models/quiz_question.dart';
import '../models/question_block.dart';
import '../services/quiz_service.dart';

class QuizEditorPage extends StatefulWidget {
  final String? courseId;
  final Quiz? existing;

  const QuizEditorPage({Key? key, this.courseId, this.existing})
      : super(key: key);

  @override
  State<QuizEditorPage> createState() => _QuizEditorPageState();
}

class _QuizEditorPageState extends State<QuizEditorPage> {
  final _titleCtrl = TextEditingController();
  String? _coverUrl;
  bool _uploadingCover = false;

  final List<QuizQuestion> _questions = [];
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _titleCtrl.text = widget.existing!.title;
      _coverUrl = widget.existing!.coverUrl;
      _loadQuestions();
    }
  }

  Future<void> _loadQuestions() async {
    final loaded =
    await QuizService.instance.fetchQuestions(widget.existing!.id);
    setState(() => _questions.addAll(loaded));
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _uploadingCover = true);
    final file = File(picked.path);
    final ref = FirebaseStorage.instance
        .ref('quiz_covers/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    setState(() {
      _coverUrl = url;
      _uploadingCover = false;
    });
  }

  Future<void> _submitQuiz() async {
    if (!_formKey.currentState!.validate() || _questions.isEmpty) return;

    setState(() => _loading = true);

    late final String quizId;
    if (widget.existing != null) {
      quizId = widget.existing!.id;
      await QuizService.instance.updateQuiz(
        quizId,
        title: _titleCtrl.text,
        coverUrl: _coverUrl,
      );
      await QuizService.instance.clearQuestions(quizId);
    } else {
      quizId = await QuizService.instance.addQuiz(
        courseId: widget.courseId,
        title: _titleCtrl.text,
        coverUrl: _coverUrl,
      );
    }

    for (final q in _questions) {
      await QuizService.instance.addQuestion(quizId, q);
    }

    if (mounted) Navigator.pop(context, true);
  }

  Future<QuizQuestion?> _addQuestionDialog(
      BuildContext context, {
        QuizQuestion? existing,
      }) {
    final aCtrl = TextEditingController(text: existing?.choices[0] ?? '');
    final bCtrl = TextEditingController(text: existing?.choices[1] ?? '');
    final cCtrl = TextEditingController(text: existing?.choices[2] ?? '');
    final dCtrl = TextEditingController(text: existing?.choices[3] ?? '');

    final textCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    final List<String> imageUrls = [];

    int selectedAnswer = existing?.correctIndex ?? 0;
    bool useImageMode = false;

    if (existing != null) {
      for (final block in existing.blocks) {
        if (block.type == 'image') {
          imageUrls.add(block.content);
          useImageMode = true;
        } else if (block.type == 'text') {
          if (useImageMode) {
            descriptionCtrl.text = block.content;
          } else {
            textCtrl.text = block.content;
          }
        }
      }
    }

    Future<void> _pickImage(StateSetter setState) async {
      final picker = ImagePicker();
      final img = await picker.pickImage(source: ImageSource.gallery);
      if (img != null) {
        final ref = FirebaseStorage.instance
            .ref('question_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(File(img.path));
        final url = await ref.getDownloadURL();
        setState(() => imageUrls.add(url));
      }
    }

    return showDialog<QuizQuestion>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing != null ? "Edit Question" : "Add Question"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<bool>(
                  value: useImageMode,
                  decoration:
                  const InputDecoration(labelText: 'Question Type'),
                  items: const [
                    DropdownMenuItem(value: false, child: Text("Text Only")),
                    DropdownMenuItem(
                        value: true, child: Text("Image + Description")),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => useImageMode = v);
                  },
                ),
                const SizedBox(height: 12),

                if (useImageMode) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final url in imageUrls)
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Image.network(url,
                                height: 100, width: 100, fit: BoxFit.cover),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () =>
                                  setState(() => imageUrls.remove(url)),
                            ),
                          ],
                        ),
                      GestureDetector(
                        onTap: () => _pickImage(setState),
                        child: Container(
                          height: 100,
                          width: 100,
                          color: Colors.grey[300],
                          child: const Icon(Icons.add_a_photo),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                      controller: descriptionCtrl,
                      decoration:
                      const InputDecoration(labelText: 'Description')),
                ] else ...[
                  TextField(
                    controller: textCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Question'),
                  ),
                ],

                const Divider(height: 24),

                TextField(
                    controller: aCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Choice A')),
                TextField(
                    controller: bCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Choice B')),
                TextField(
                    controller: cCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Choice C')),
                TextField(
                    controller: dCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Choice D')),

                DropdownButtonFormField<int>(
                  value: selectedAnswer,
                  decoration:
                  const InputDecoration(labelText: 'Correct Answer'),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('A')),
                    DropdownMenuItem(value: 1, child: Text('B')),
                    DropdownMenuItem(value: 2, child: Text('C')),
                    DropdownMenuItem(value: 3, child: Text('D')),
                  ],
                  onChanged: (v) => selectedAnswer = v ?? 0,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                final blocks = <QuestionBlock>[];
                if (useImageMode) {
                  for (final url in imageUrls) {
                    blocks
                        .add(QuestionBlock(type: 'image', content: url));
                  }
                  if (descriptionCtrl.text.isNotEmpty) {
                    blocks.add(QuestionBlock(
                        type: 'text', content: descriptionCtrl.text));
                  }
                } else {
                  if (textCtrl.text.isNotEmpty) {
                    blocks
                        .add(QuestionBlock(type: 'text', content: textCtrl.text));
                  }
                }
                if (blocks.isEmpty) return;

                final q = QuizQuestion(
                  id: existing?.id ?? '',
                  blocks: blocks,
                  choices: [
                    aCtrl.text,
                    bCtrl.text,
                    cCtrl.text,
                    dCtrl.text
                  ],
                  correctIndex: selectedAnswer,
                );
                Navigator.pop(context, q);
              },
              child: Text(existing != null ? "Update" : "Add"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: Text(widget.existing != null ? "Edit Quiz" : "Create Quiz")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // — Quiz Cover label —
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quiz Cover',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // — Cover picker —
              GestureDetector(
                onTap: _uploadingCover ? null : _pickCoverImage,
                child: _uploadingCover
                    ? const SizedBox(
                    height: 120,
                    child:
                    Center(child: CircularProgressIndicator()))
                    : _coverUrl != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _coverUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
                    : Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius:
                    BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.photo_library,
                        size: 32),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // — Title —
              TextFormField(
                controller: _titleCtrl,
                decoration:
                const InputDecoration(labelText: 'Quiz Title'),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Title required' : null,
              ),

              const SizedBox(height: 16),
              // — Add Question Button —
              ElevatedButton.icon(
                onPressed: () async {
                  final newQ = await _addQuestionDialog(context);
                  if (newQ != null) {
                    setState(() => _questions.add(newQ));
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Question"),
              ),
              const SizedBox(height: 8),

              // — Questions List —
              Expanded(
                child: ListView.builder(
                  itemCount: _questions.length,
                  itemBuilder: (_, i) {
                    final q = _questions[i];
                    return ListTile(
                      title: Text("Question ${i + 1}"),
                      subtitle: Text(
                          "Correct: ${String.fromCharCode(65 + q.correctIndex)}"),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            final updated =
                            await _addQuestionDialog(context,
                                existing: q);
                            if (updated != null) {
                              setState(() => _questions[i] = updated);
                            }
                          } else if (value == 'delete') {
                            setState(() => _questions.removeAt(i));
                          } else if (value == 'up' && i > 0) {
                            setState(() {
                              final tmp = _questions[i - 1];
                              _questions[i - 1] = _questions[i];
                              _questions[i] = tmp;
                            });
                          } else if (value == 'down' &&
                              i < _questions.length - 1) {
                            setState(() {
                              final tmp = _questions[i + 1];
                              _questions[i + 1] = _questions[i];
                              _questions[i] = tmp;
                            });
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                              value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(
                              value: 'delete', child: Text('Delete')),
                          if (i > 0)
                            const PopupMenuItem(
                                value: 'up', child: Text('Move Up')),
                          if (i < _questions.length - 1)
                            const PopupMenuItem(
                                value: 'down',
                                child: Text('Move Down')),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // — Submit —
              ElevatedButton(
                onPressed: _submitQuiz,
                child: Text(widget.existing != null
                    ? "Update Quiz"
                    : "Create Quiz"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
