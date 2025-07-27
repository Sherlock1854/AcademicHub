// lib/quizzes/views/quiz_questions_page.dart

import 'package:flutter/material.dart';
import 'package:academichub/bottom_nav.dart';
import 'package:academichub/quizzes/services/quiz_attempt_service.dart';
import '../models/quiz_question.dart';
import '../services/quiz_service.dart';

const Color functionBlue = Color(0xFF006FF9);

class QuizQuestionsPage extends StatefulWidget {
  final String quizId;
  const QuizQuestionsPage({Key? key, required this.quizId}) : super(key: key);

  @override
  State<QuizQuestionsPage> createState() => _QuizQuestionsPageState();
}

class _QuizQuestionsPageState extends State<QuizQuestionsPage> {
  List<QuizQuestion> _questions = [];
  bool _loading = true;
  int _currentIndex = 0;
  final Map<String, int> _answers = {};
  final Map<String, bool> _checked = {};

  @override
  void initState() {
    super.initState();
    QuizService.instance.fetchQuestions(widget.quizId).then((list) {
      setState(() {
        _questions = list;
        _loading = false;
      });
    });
  }

  Future<void> _submitAttempt() async {
    final total = _questions.length;
    int correct = 0;
    for (var q in _questions) {
      if (_answers[q.id] == q.correctIndex) correct++;
    }
    await QuizAttemptService.instance.recordAttempt(
      quizId: widget.quizId,
      score: correct,
      total: total,
      answers: _answers,
    );
    if (!mounted) return;
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quiz Completed'),
        content: Text('You scored $correct out of $total.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    Navigator.of(context).pop(); // pop questions page
    Navigator.of(context).pop(); // pop attempt page
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No questions found.')),
      );
    }

    final q = _questions[_currentIndex];
    final hasChecked = _checked[q.id] == true;
    final isLast = _currentIndex == _questions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Questions', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: functionBlue),
        automaticallyImplyLeading: !hasChecked, // hide back arrow once checked
      ),
      bottomNavigationBar: const AppNavigationBar(selectedIndex: 2, isAdmin: false),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${_currentIndex + 1} of ${_questions.length}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var block in q.blocks) ...[
                      if (block.type == 'text') ...[
                        Text(block.content, style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 12),
                      ] else ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            block.content,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: Colors.grey, height: 200),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ]
                    ],
                    for (int i = 0; i < q.choices.length; i++) ...[
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: hasChecked
                              ? (i == q.correctIndex
                              ? Colors.green.withOpacity(0.3)
                              : (_answers[q.id] == i
                              ? Colors.red.withOpacity(0.3)
                              : null))
                              : null,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: functionBlue),
                        ),
                        child: RadioListTile<int>(
                          title: Text(q.choices[i]),
                          value: i,
                          groupValue: _answers[q.id],
                          activeColor: functionBlue,
                          onChanged: hasChecked
                              ? null
                              : (v) => setState(() {
                            _answers[q.id] = v!;
                          }),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Single button: Check → Next/Submit
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: OutlinedButton(
                onPressed: (!_answers.containsKey(q.id))
                    ? null
                    : () {
                  if (!hasChecked) {
                    setState(() {
                      _checked[q.id] = true;
                    });
                  } else {
                    if (isLast) {
                      _submitAttempt();
                    } else {
                      setState(() {
                        _currentIndex++;
                      });
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: functionBlue,
                  side: const BorderSide(color: functionBlue),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(hasChecked
                    ? (isLast ? 'Submit' : 'Next')
                    : 'Check Answer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
