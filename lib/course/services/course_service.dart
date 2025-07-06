import 'package:flutter/material.dart';

class CourseModel {
  final String title;
  final String subtitle;
  final String instructor;
  final String imageUrl;

  CourseModel({
    required this.title,
    required this.subtitle,
    required this.instructor,
    required this.imageUrl,
  });
}

class CourseService {
  static final CourseService _instance = CourseService._internal();

  factory CourseService() => _instance;

  CourseService._internal();

  final List<CourseModel> _joinedCourses = [];

  List<CourseModel> getJoinedCourses() => List.unmodifiable(_joinedCourses);

  void joinCourse(CourseModel course) {
    if (!_joinedCourses.any((c) => c.title == course.title)) {
      _joinedCourses.add(course);
      debugPrint('Joined course: ${course.title}');
    } else {
      debugPrint('Course already joined: ${course.title}');
    }
  }

  void clearCourses() {
    _joinedCourses.clear();
  }
}
