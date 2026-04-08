import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF2D7A4F);
  static const Color primaryLight = Color(0xFF4CAF70);
  static const Color primaryDark = Color(0xFF1B5E35);
  static const Color secondary = Color(0xFFF5A623);
  static const Color secondaryLight = Color(0xFFFFCC55);
  static const Color secondaryDark = Color(0xFFBF7D00);

  // Semantic
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1976D2);

  // Neutral
  static const Color background = Color(0xFFF8F9F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F2);
  static const Color onSurface = Color(0xFF1C1C1E);
  static const Color onSurfaceVariant = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);

  // Status chips
  static const Color statusActive = Color(0xFFDCFCE7);
  static const Color statusActiveText = Color(0xFF166534);
  static const Color statusPending = Color(0xFFFEF3C7);
  static const Color statusPendingText = Color(0xFF92400E);
  static const Color statusDone = Color(0xFFEDE9FE);
  static const Color statusDoneText = Color(0xFF5B21B6);
  static const Color statusInactive = Color(0xFFF3F4F6);
  static const Color statusInactiveText = Color(0xFF4B5563);

  // Live chart series
  static const List<Color> chartSeries = [
    Color(0xFF2D7A4F),
    Color(0xFFF5A623),
    Color(0xFF1976D2),
    Color(0xFFD32F2F),
    Color(0xFF7B1FA2),
    Color(0xFF00838F),
  ];
}
