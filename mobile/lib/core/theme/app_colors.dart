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
  static const Color onErrorContainer = Color(0xFF7F1C10);
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
  static const Color darkBackground = Color(0xFF121812);
  static const Color darkSurface = Color(0xFF1E2A1E);
  static const Color darkSurfaceVariant = Color(0xFF2A382A);
  static const Color darkOnSurfaceVariant = Color(0xFFB0C4B0);
  static const Color darkOutline = Color(0xFF5A6E5A);
  static const Color darkInputFill = Color(0xFF2A382A);
  static const Color darkAppBar = Color(0xFF121812);
  static const Color darkNavigationBar = Color(0xFF1E2A1E);

  // --- Status chips (accessible & WCAG friendly) ---
  static const Color statusActiveBg = Color(0xFFE0F2E9);
  static const Color statusActiveText = Color(0xFF0F552F);
  static const Color statusPendingBg = Color(0xFFFFF0E0);
  static const Color statusPendingText = Color(0xFFA6590C);
  static const Color statusCompletedBg = Color(0xFFE1F0FA);
  static const Color statusCompletedText = Color(0xFF14476B);
  static const Color statusInactiveBg = Color(0xFFF0F4F0);
  static const Color statusInactiveText = Color(0xFF4A5E4A);
  static const Color statusActiveBgDark = Color(0xFF123023);
  static const Color statusActiveTextDark = Color(0xFFBFEFD6);
  static const Color statusPendingBgDark = Color(0xFF3A2A16);
  static const Color statusPendingTextDark = Color(0xFFFFD7A8);
  static const Color statusCompletedBgDark = Color(0xFF0F2F45);
  static const Color statusCompletedTextDark = Color(0xFFB8DDF6);
  static const Color statusInactiveBgDark = Color(0xFF243024);
  static const Color statusInactiveTextDark = Color(0xFFCFD9CF);

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

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.statusActiveBg,
    required this.statusActiveText,
    required this.statusPendingBg,
    required this.statusPendingText,
    required this.statusCompletedBg,
    required this.statusCompletedText,
    required this.statusInactiveBg,
    required this.statusInactiveText,
    required this.chartSeries,
  });

  final Color statusActiveBg;
  final Color statusActiveText;
  final Color statusPendingBg;
  final Color statusPendingText;
  final Color statusCompletedBg;
  final Color statusCompletedText;
  final Color statusInactiveBg;
  final Color statusInactiveText;
  final List<Color> chartSeries;

  static const AppThemeColors lightMode = AppThemeColors(
    statusActiveBg: AppColors.statusActiveBg,
    statusActiveText: AppColors.statusActiveText,
    statusPendingBg: AppColors.statusPendingBg,
    statusPendingText: AppColors.statusPendingText,
    statusCompletedBg: AppColors.statusCompletedBg,
    statusCompletedText: AppColors.statusCompletedText,
    statusInactiveBg: AppColors.statusInactiveBg,
    statusInactiveText: AppColors.statusInactiveText,
    chartSeries: AppColors.chartSeries,
  );

  static const AppThemeColors darkMode = AppThemeColors(
    statusActiveBg: AppColors.statusActiveBgDark,
    statusActiveText: AppColors.statusActiveTextDark,
    statusPendingBg: AppColors.statusPendingBgDark,
    statusPendingText: AppColors.statusPendingTextDark,
    statusCompletedBg: AppColors.statusCompletedBgDark,
    statusCompletedText: AppColors.statusCompletedTextDark,
    statusInactiveBg: AppColors.statusInactiveBgDark,
    statusInactiveText: AppColors.statusInactiveTextDark,
    chartSeries: AppColors.chartSeries,
  );

  @override
  AppThemeColors copyWith({
    Color? statusActiveBg,
    Color? statusActiveText,
    Color? statusPendingBg,
    Color? statusPendingText,
    Color? statusCompletedBg,
    Color? statusCompletedText,
    Color? statusInactiveBg,
    Color? statusInactiveText,
    List<Color>? chartSeries,
  }) {
    return AppThemeColors(
      statusActiveBg: statusActiveBg ?? this.statusActiveBg,
      statusActiveText: statusActiveText ?? this.statusActiveText,
      statusPendingBg: statusPendingBg ?? this.statusPendingBg,
      statusPendingText: statusPendingText ?? this.statusPendingText,
      statusCompletedBg: statusCompletedBg ?? this.statusCompletedBg,
      statusCompletedText: statusCompletedText ?? this.statusCompletedText,
      statusInactiveBg: statusInactiveBg ?? this.statusInactiveBg,
      statusInactiveText: statusInactiveText ?? this.statusInactiveText,
      chartSeries: chartSeries ?? this.chartSeries,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      statusActiveBg: Color.lerp(statusActiveBg, other.statusActiveBg, t)!,
      statusActiveText: Color.lerp(statusActiveText, other.statusActiveText, t)!,
      statusPendingBg: Color.lerp(statusPendingBg, other.statusPendingBg, t)!,
      statusPendingText: Color.lerp(statusPendingText, other.statusPendingText, t)!,
      statusCompletedBg: Color.lerp(statusCompletedBg, other.statusCompletedBg, t)!,
      statusCompletedText: Color.lerp(statusCompletedText, other.statusCompletedText, t)!,
      statusInactiveBg: Color.lerp(statusInactiveBg, other.statusInactiveBg, t)!,
      statusInactiveText: Color.lerp(statusInactiveText, other.statusInactiveText, t)!,
      chartSeries: List<Color>.generate(
        chartSeries.length,
        (index) {
          final a = chartSeries[index];
          final b = index < other.chartSeries.length ? other.chartSeries[index] : a;
          return Color.lerp(a, b, t) ?? a;
        },
      ),
    );
  }
}
