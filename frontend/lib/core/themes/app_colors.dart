// file: frontend\lib\core\themes\app_colors.dart
import 'package:flutter/material.dart';

abstract class AppColors {
  // ─── Primary (Teal-Blue gradient brand) ────────────────────────────
  static const Color primary50 = Color(0xFFE0F7FA);
  static const Color primary100 = Color(0xFFB2EBF2);
  static const Color primary200 = Color(0xFF80DEEA);
  static const Color primary300 = Color(0xFF4DD0E1);
  static const Color primary400 = Color(0xFF26C6DA);
  static const Color primary500 = Color(0xFF00BCD4); // main
  static const Color primary600 = Color(0xFF0097A7);
  static const Color primary700 = Color(0xFF00838F);
  static const Color primary800 = Color(0xFF006064);
  static const Color primary900 = Color(0xFF004D51);

  // ─── Secondary (Deep Blue) ─────────────────────────────────────────
  static const Color secondary50 = Color(0xFFE3F2FD);
  static const Color secondary100 = Color(0xFFBBDEFB);
  static const Color secondary200 = Color(0xFF90CAF9);
  static const Color secondary300 = Color(0xFF64B5F6);
  static const Color secondary400 = Color(0xFF42A5F5);
  static const Color secondary500 = Color(0xFF2196F3);
  static const Color secondary600 = Color(0xFF1E88E5);
  static const Color secondary700 = Color(0xFF1565C0); // main
  static const Color secondary800 = Color(0xFF0D47A1);
  static const Color secondary900 = Color(0xFF0A3570);

  // ─── Neutral (Gray) ────────────────────────────────────────────────
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFF8F9FA);
  static const Color neutral100 = Color(0xFFF1F3F5);
  static const Color neutral200 = Color(0xFFE9ECEF);
  static const Color neutral300 = Color(0xFFDEE2E6);
  static const Color neutral400 = Color(0xFFCED4DA);
  static const Color neutral500 = Color(0xFFADB5BD);
  static const Color neutral600 = Color(0xFF6C757D);
  static const Color neutral700 = Color(0xFF495057);
  static const Color neutral800 = Color(0xFF343A40);
  static const Color neutral900 = Color(0xFF212529);

  // ─── Success ────────────────────────────────────────────────────────
  static const Color success50 = Color(0xFFF0FDF4);
  static const Color success100 = Color(0xFFDCFCE7);
  static const Color success200 = Color(0xFFBBF7D0);
  static const Color success500 = Color(0xFF22C55E);
  static const Color success600 = Color(0xFF16A34A);
  static const Color success700 = Color(0xFF15803D);

  // ─── Warning ────────────────────────────────────────────────────────
  static const Color warning50 = Color(0xFFFFFBEB);
  static const Color warning100 = Color(0xFFFEF3C7);
  static const Color warning200 = Color(0xFFFDE68A);
  static const Color warning500 = Color(0xFFF59E0B);
  static const Color warning600 = Color(0xFFD97706);
  static const Color warning700 = Color(0xFFB45309);

  // ─── Danger ─────────────────────────────────────────────────────────
  static const Color danger50 = Color(0xFFFFF1F2);
  static const Color danger100 = Color(0xFFFFE4E6);
  static const Color danger200 = Color(0xFFFECDD3);
  static const Color danger500 = Color(0xFFEF4444);
  static const Color danger600 = Color(0xFFDC2626);
  static const Color danger700 = Color(0xFFB91C1C);

  // ─── Info ────────────────────────────────────────────────────────────
  static const Color info50 = Color(0xFFEFF6FF);
  static const Color info100 = Color(0xFFDBEAFE);
  static const Color info500 = Color(0xFF3B82F6);
  static const Color info700 = Color(0xFF1D4ED8);

  // ─── Semantic aliases ────────────────────────────────────────────────
  static const Color background = Color(0xFFF6F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceRaised = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderFocus = Color(0xFF00BCD4);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── AI / Brand special ──────────────────────────────────────────────
  static const Color aiPurple = Color(0xFF7C3AED);
  static const Color aiPurpleLight = Color(0xFFF5F3FF);
  static const Color aiGlow = Color(0xFF8B5CF6);

  // ─── Chart palette ───────────────────────────────────────────────────
  static const List<Color> chartPalette = [
    Color(0xFF00BCD4),
    Color(0xFF1565C0),
    Color(0xFF22C55E),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF7C3AED),
    Color(0xFF0EA5E9),
    Color(0xFFEC4899),
  ];

  // ─── Overlay ─────────────────────────────────────────────────────────
  static const Color overlayDark = Color(0x80000000);
  static const Color overlayLight = Color(0x40FFFFFF);

  // ─── Gradient stops (used by AppGradients) ──────────────────────────
  static const Color gradientStart = Color(0xFF00BCD4);
  static const Color gradientMid = Color(0xFF1976D2);
  static const Color gradientEnd = Color(0xFF1565C0);
}

// ─── Spec Design Tokens ──────────────────────────────────────────────
const kPrimaryBlue     = Color(0xFF0D47A1); // أزرق غامق — الـ primary actions
const kPrimaryTeal     = Color(0xFF1B8FA6); // تيل — gradient ثاني / accents
const kDarkNavy        = Color(0xFF0D3B5E); // نيفي — headers / AppBar
const kMediumTeal      = Color(0xFF5BA4AF); // تيل متوسط — secondary elements
const kLightBlue       = Color(0xFFADD8E6); // فاتح — backgrounds / hints
const kScaffoldBg      = Color(0xFFF5F9FA); // خلفية الشاشات (off-white مع صبغة تيل)
const kTextDark        = Color(0xFF0D1B2A); // النصوص الأساسية
const kTextMedium      = Color(0xFF546E7A); // النصوص الثانوية / labels
const kTextLight       = Color(0xFF90A4AE); // placeholder / hints
const kDivider         = Color(0xFFCFD8DC); // فواصل وحدود خفيفة
const kWhite           = Color(0xFFFFFFFF);
const kError           = Color(0xFFD32F2F); // خطأ
const kSuccess         = Color(0xFF2E7D32); // نجاح
const kWarning         = Color(0xFFF57C00); // تحذير

const kPrimaryGradient = LinearGradient(
  colors: [Color(0xFF0D47A1), Color(0xFF1B8FA6)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

