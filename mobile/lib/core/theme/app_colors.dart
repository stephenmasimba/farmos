// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Primary (Earthy Green – Trust, Growth, Nature) ---
  static const Color primary = Color(0xFF2B6E4F);      // deep farm green
  static const Color primaryLight = Color(0xFF4C9A70); // fresh leaf
  static const Color primaryDark = Color(0xFF1E4A34);  // forest shadow
  static const Color primaryContainer = Color(0xFFE6F4EC);
  static const Color onPrimaryContainer = Color(0xFF0A2F1F);

  // --- Secondary (Warm Amber – Energy, Alerts, Harvest) ---
  static const Color secondary = Color(0xFFE68A2E);
  static const Color secondaryLight = Color(0xFFFFB85E);
  static const Color secondaryDark = Color(0xFFB85C00);
  static const Color secondaryContainer = Color(0xFFFFF0E0);
  static const Color onSecondaryContainer = Color(0xFF4A2A00);

  // --- Tertiary (Tech Blue – Data, IoT, Analytics) ---
  static const Color tertiary = Color(0xFF2C6E9E);
  static const Color tertiaryLight = Color(0xFF5B8FC1);
  static const Color tertiaryDark = Color(0xFF1C4A6E);
  static const Color tertiaryContainer = Color(0xFFE1F0FA);
  static const Color onTertiaryContainer = Color(0xFF06263A);

  // --- Semantic (accessible, high-contrast) ---
  static const Color success = Color(0xFF1E7A44);
  static const Color successLight = Color(0xFFE0F2E9);
  static const Color warning = Color(0xFFE68A2E);
  static const Color warningLight = Color(0xFFFFF0E0);
  static const Color error = Color(0xFFC73A2B);
  static const Color errorLight = Color(0xFFFFEDEB);
  static const Color info = Color(0xFF2C6E9E);
  static const Color infoLight = Color(0xFFE1F0FA);

  // --- Neutral (modern, balanced) ---
  static const Color background = Color(0xFFF9FBF9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F0);
  static const Color surfaceDim = Color(0xFFE6EAE6);
  static const Color onSurface = Color(0xFF1C2A1C);
  static const Color onSurfaceVariant = Color(0xFF5A6E5A);
  static const Color outline = Color(0xFFBCC9BC);
  static const Color divider = Color(0xFFE2E8E2);

  // --- Status chips (accessible & WCAG friendly) ---
  static const Color statusActiveBg = Color(0xFFE0F2E9);
  static const Color statusActiveText = Color(0xFF0F552F);
  static const Color statusPendingBg = Color(0xFFFFF0E0);
  static const Color statusPendingText = Color(0xFFA6590C);
  static const Color statusCompletedBg = Color(0xFFE1F0FA);
  static const Color statusCompletedText = Color(0xFF14476B);
  static const Color statusInactiveBg = Color(0xFFF0F4F0);
  static const Color statusInactiveText = Color(0xFF4A5E4A);

  // --- Chart & data series (distinct, colorblind-friendly) ---
  static const List<Color> chartSeries = [
    Color(0xFF2B6E4F),  // primary green
    Color(0xFFE68A2E),  // amber
    Color(0xFF2C6E9E),  // blue
    Color(0xFF8B5F3C),  // earth brown
    Color(0xFF607D3E),  // olive
    Color(0xFF9C6E8C),  // muted plum
  ];
}