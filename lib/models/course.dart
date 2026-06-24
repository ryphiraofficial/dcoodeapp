import 'package:flutter/material.dart';

class Course {
  final String title;
  final String track;
  final String description;
  final String overview;
  final List<String> technologies;
  final List<SyllabusMonth> syllabus;
  final List<String> whoIsThisFor;
  final String duration; // e.g., "1, 3, 6 Months"
  final String cohort; // e.g., "Dcoode"
  final IconData icon;
  final Color accentColor;

  const Course({
    required this.title,
    required this.track,
    required this.description,
    required this.overview,
    required this.technologies,
    required this.syllabus,
    required this.whoIsThisFor,
    required this.duration,
    required this.cohort,
    required this.icon,
    required this.accentColor,
  });
}

class SyllabusMonth {
  final String month;
  final String title;
  final String description;
  final List<String> points;

  const SyllabusMonth({
    required this.month,
    required this.title,
    required this.description,
    required this.points,
  });
}
