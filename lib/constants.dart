import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFA4FF00); // Lime Green
  static const Color background = Color(0xFFFAFAFA);
  static const Color darkBackground = Color(0xFF121212);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF666666);
  static const Color cardBackground = Colors.white;
  static const Color border = Color(0xFFEEEEEE);
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 1.2,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
    letterSpacing: 1.1,
  );

  static const TextStyle statValue = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: 10,
    color: Colors.white70,
    letterSpacing: 1.5,
  );
}
