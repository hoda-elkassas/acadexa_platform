// file: lib/core/theme/app_typography.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTypography {
  // ─── Font families ───────────────────────────────────────────────────
  static const String arabicFont = 'Cairo'; // Arabic RTL primary
  static const String englishFont = 'Inter'; // Latin secondary

  // ─── Font sizes ─────────────────────────────────────────────────────
  static const double fs10 = 10.0;
  static const double fs11 = 11.0;
  static const double fs12 = 12.0;
  static const double fs13 = 13.0;
  static const double fs14 = 14.0;
  static const double fs16 = 16.0;
  static const double fs18 = 18.0;
  static const double fs20 = 20.0;
  static const double fs24 = 24.0;
  static const double fs28 = 28.0;
  static const double fs32 = 32.0;
  static const double fs40 = 40.0;
  static const double fs48 = 48.0;

  // ─── Line heights ────────────────────────────────────────────────────
  static const double lhTight = 1.2;
  static const double lhNormal = 1.5;
  static const double lhRelaxed = 1.75;

  // ─── Letter spacing ──────────────────────────────────────────────────
  static const double lsTight = -0.5;
  static const double lsNormal = 0.0;
  static const double lsWide = 0.5;
  static const double lsWider = 1.0;

  // ─── Text styles ─────────────────────────────────────────────────────

  // Display
  static TextStyle get displayLarge => const TextStyle(
    fontFamily: arabicFont,
    fontSize: fs48,
    fontWeight: FontWeight.w700,
    height: lhTight,
    letterSpacing: lsTight,
    color: AppColors.textPrimary,
  );

  static TextStyle get displayMedium => const TextStyle(
    fontFamily: arabicFont,
    fontSize: fs40,
    fontWeight: FontWeight.w700,
    height: lhTight,
    letterSpacing: lsTight,
    color: AppColors.textPrimary,
  );

  static TextStyle get displaySmall => const TextStyle(
    fontFamily: arabicFont,
    fontSize: fs32,
    fontWeight: FontWeight.w600,
    height: lhTight,
    color: AppColors.textPrimary,
  );

  // Headings
  static TextStyle get h1 => const TextStyle(
    fontFamily: arabicFont,
    fontSize: fs28,
    fontWeight: FontWeight.w700,
    height: lhTight,
    color: AppColors.textPrimary,
  );

  static TextStyle get h2 => const TextStyle(
    fontFamily: arabicFont,
    fontSize: fs24,
    fontWeight: FontWeight.w600,
    height: lhTight,
    color: AppColors.textPrimary,
  );

  static TextStyle get h3 => const TextStyle(
    fontFamily: arabicFont,
    fontSize: fs20,
    fontWeight: FontWeight.w600,
    height: lhNormal,
    color: AppColors.textPrimary,
  );

  static TextStyle get h4 => const TextStyle(
    fontFamily: arabicFont,
    fontSize: fs18,
    fontWeight: FontWeight.w600,
    height: lhNormal,
    color: AppColors.textPrimary,
  );

  static TextStyle get h5 => const TextStyle(
    fontFamily: arabicFont,
    fontSize: fs16,
    fontWeight: FontWeight.w600,
    height: lhNormal,
    color: AppColors.textPrimary,
  );

  // Body
  static TextStyle get bodyLarge => const TextStyle(
    fontFamily: arabicFont,
    fontSize: fs16,
    fontWeight: FontWeight.w400,
    height: lhRelaxed,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontFamily: arabicFont,
    fontSize: fs14,
    fontWeight: FontWeight.w400,
    height: lhRelaxed,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySmall => const TextStyle(
    fontFamily: arabicFont,
    fontSize: fs12,
    fontWeight: FontWeight.w400,
    height: lhRelaxed,
    color: AppColors.textSecondary,
  );

  // Label
  static TextStyle get labelLarge => const TextStyle(
    fontFamily: arabicFont,
    fontSize: fs14,
    fontWeight: FontWeight.w500,
    height: lhNormal,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelMedium => const TextStyle(
    fontFamily: arabicFont,
    fontSize: fs13,
    fontWeight: FontWeight.w500,
    height: lhNormal,
    color: AppColors.textSecondary,
  );

  static TextStyle get labelSmall => const TextStyle(
    fontFamily: arabicFont,
    fontSize: fs12,
    fontWeight: FontWeight.w500,
    height: lhNormal,
    letterSpacing: lsWide,
    color: AppColors.textSecondary,
  );

  // Caption / Overline
  static TextStyle get caption => const TextStyle(
    fontFamily: arabicFont,
    fontSize: fs11,
    fontWeight: FontWeight.w400,
    height: lhNormal,
    color: AppColors.textMuted,
  );

  static TextStyle get overline => const TextStyle(
    fontFamily: arabicFont,
    fontSize: fs10,
    fontWeight: FontWeight.w600,
    height: lhNormal,
    letterSpacing: lsWider,
    color: AppColors.textMuted,
  );

  // Button text
  static TextStyle get buttonLarge => const TextStyle(
    fontFamily: arabicFont,
    fontSize: fs16,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: lsNormal,
    color: AppColors.textOnPrimary,
  );

  static TextStyle get buttonMedium => const TextStyle(
    fontFamily: arabicFont,
    fontSize: fs14,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: AppColors.textOnPrimary,
  );

  static TextStyle get buttonSmall => const TextStyle(
    fontFamily: arabicFont,
    fontSize: fs13,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: AppColors.textOnPrimary,
  );

  // Code / Mono
  static TextStyle get code => const TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: fs13,
    fontWeight: FontWeight.w400,
    height: lhNormal,
    color: AppColors.textPrimary,
  );

  // ─── Material 3 TextTheme ────────────────────────────────────────────
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: h1,
    headlineMedium: h2,
    headlineSmall: h3,
    titleLarge: h4,
    titleMedium: h5,
    titleSmall: labelLarge,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: buttonMedium.copyWith(color: AppColors.textPrimary),
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
