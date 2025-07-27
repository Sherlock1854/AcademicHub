// lib/quizzes/views/quiz_questions_page.dart

import 'package:flutter/material.dart';
import 'package:academichub/bottom_nav.dart';
import 'package:academichub/quizzes/services/quiz_attempt_service.dart';
import '../models/quiz_question.dart';
import '../services/quiz_service.dart';

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
  final Map<String,int> _answers = {};

  @override
  void initState() {
    super.initState();
    QuizService.instance
        .fetchQuestions(widget.quizId)
        .then((list) => setState(() {
      _questions = list;
      _loading = false;
    }));
  }

  Future<void> _submitAttempt() async {
    final total   = _questions.length;
    int correct   = 0;
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

    // 1) show the “completed” dialog
    await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Quiz Completed'),
        content: Text('You scored $correct out of $total.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    // 2) pop *this* QuizQuestionsPage …
    Navigator.of(context).pop();
    // 3) … then pop the intermediate QuizAttemptPage too, landing you back on your quizzes list.
    Navigator.of(context).pop();
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

    final q    = _questions[_currentIndex];
    final last = _currentIndex == _questions.length - 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Questions')),
      bottomNavigationBar: const AppNavigationBar(selectedIndex: 2, isAdmin: false),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
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
                    for (var b in q.blocks) ...[
                      if (b.type == 'text') ...[
                        Text(b.content, style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 12),
                      ] else ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            b.content,
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
                    for (var i = 0; i < q.choices.length; i++)
                      RadioListTile<int>(
                        title: Text(q.choices[i]),
                        value: i,
                        groupValue: _answers[q.id],
                        onChanged: (v) => setState(() => _answers[q.id] = v!),
                      ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                if (_currentIndex > 0)
                  TextButton(
                    onPressed: () => setState(() => _currentIndex--),
                    child: const Text('Back'),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _answers.containsKey(q.id)
                      ? () {
                    if (last) {
                      _submitAttempt();
                    } else {
                      setState(() => _currentIndex++);
                    }
                  }
                      : null,
                  child: Text(last ? 'Submit' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
