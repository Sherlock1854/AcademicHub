// lib/models/dashboard.dart

import 'package:flutter/material.dart';

class Course {
  final String title;
  final int progress; // Using int for percentage 0-100
  final Color color;
  final Color iconColor;

  Course({
    required this.title,
    required this.progress,
    required this.color,
    required this.iconColor,
  });
}