import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF10141C);
  static const Color surfaceSecondary = Color(0xFF171E29);
  static const Color surface = Color(0xFF202B3A);
  static const Color border = Color(0xFF2E3B4E);
  static const Color accent = Color(0xFF55C7E8);
  static const Color onAccent = Color(0xFF06222B);
  static const Color textPrimary = Color(0xFFF4F7FB);
  static const Color textSecondary = Color(0xFFA8B3C4);
  static const Color success = Color(0xFF55C99A);
  static const Color warning = Color(0xFFF2C66D);
  static const Color error = Color(0xFFFF7379);

  // Versões translúcidas (evitam withOpacity/withValues, que variam por versão).
  static const Color accentSoft = Color(0x3355C7E8);
  static const Color successSoft = Color(0x3355C99A);
  static const Color warningSoft = Color(0x33F2C66D);
  static const Color errorSoft = Color(0x33FF7379);
}

class AppText {
  AppText._();

  static const TextStyle screenTitle = TextStyle(
      fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary);
  static const TextStyle title = TextStyle(
      fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary);
  static const TextStyle section = TextStyle(
      fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const TextStyle cardTitle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      height: 1.25,
      color: AppColors.textPrimary);
  static const TextStyle body =
      TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary);
  static const TextStyle secondary =
      TextStyle(fontSize: 13, color: AppColors.textSecondary);
  static const TextStyle caption =
      TextStyle(fontSize: 12, color: AppColors.textSecondary);
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        onPrimary: AppColors.onAccent,
        secondary: AppColors.accent,
        surface: AppColors.surfaceSecondary,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: AppColors.accent),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          minimumSize: const Size(48, 48),
          shape: shape,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(48, 48),
          shape: shape,
          side: const BorderSide(color: AppColors.border),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          minimumSize: const Size(48, 48),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.surfaceSecondary,
        indicatorColor: AppColors.accentSoft,
        height: 68,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
