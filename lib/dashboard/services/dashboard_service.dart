// lib/services/dashboard_service.dart

import 'package:flutter/material.dart';
import '../models/dashboard.dart';

class CourseService {
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
}