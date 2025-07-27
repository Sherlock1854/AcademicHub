// lib/services/dashboard_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/dashboard.dart';        // <-- your Course model
import 'package:academichub/quizzes/models/quiz_attempt.dart';     // <-- the QuizAttempt.fromDoc factory

class DashboardService {
  /// Simulates fetching enrolled courses from an API.
  Future<List<Course>> fetchEnrolledCourses() async {
    // Wait for 2 seconds to simulate a network request.
    await Future.delayed(const Duration(seconds: 2));

    // Return a hardcoded list of courses.
    // In a real app, this would come from a network call.
    return [
      Course(
        title: "Advanced Quantum Mechanics",
        progress: 75,
        color: const Color(0xFFE3F2FD),
        iconColor: Colors.blue,
      ),
      Course(
        title: "Modern Art History",
        progress: 50,
        color: const Color(0xFFE3F2FD),
        iconColor: Colors.blue,
      ),
      Course(
        title: "Neuroscience and Behavior",
        progress: 30,
        color: const Color(0xFFE3F2FD),
        iconColor: Colors.blue,
      ),
    ];
  }

  /// Fetches the quiz attempts that *this* user has done.
  /// Assumes you have a `quizAttempts` collection where each document
  /// has at least: userId, quizId, timestamp, score, total, answers.
  Future<List<QuizAttempt>> fetchUserAttempts(String userId) async {
    final query = FirebaseFirestore.instance
        .collection('quizAttempts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true);

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => QuizAttempt.fromDoc(doc))
        .toList(growable: false);
  }
}
