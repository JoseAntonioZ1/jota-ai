import 'package:flutter/material.dart';

/// Design tokens definidos en docs/05_UX_UI_DESIGN.md, seccion 3.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF2E5AAC);
  static const emergency = Color(0xFFC62828);
  static const background = Color(0xFFFFFFFF);
  static const error = Color(0xFFB3261E);
}

class AppDimens {
  AppDimens._();

  static const double minTouchTarget = 48.0;
  static const double spacingBetweenTargets = 8.0;
  static const double screenPadding = 24.0;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        error: AppColors.error,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 18), // font.body (NFR-10)
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // font.title
        labelLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600), // font.button
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppDimens.minTouchTarget),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
