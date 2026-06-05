// file: frontend\lib\core\themes\app_gradients.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppGradients {
  // ─── Brand primary ────────────────────────────────────────────────
  static const LinearGradient primaryHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
  );

  static const LinearGradient primaryVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
  );

  static const LinearGradient primaryDiagonal = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [AppColors.primary400, AppColors.secondary700],
  );

  // ─── Splash background ────────────────────────────────────────────
  static const LinearGradient splash = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
    colors: [Color(0xFFF0FDFF), Color(0xFFE0F7FA), Color(0xFFE8F4FD)],
  );

  // ─── Card overlay (bottom fade) ──────────────────────────────────
  static const LinearGradient cardOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 1.0],
    colors: [Color(0x00000000), Color(0x40000000)],
  );

  // ─── AI gradient ─────────────────────────────────────────────────
  static const LinearGradient ai = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF00BCD4)],
  );

  static const LinearGradient aiSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5F3FF), Color(0xFFE0F7FA)],
  );

  // ─── Success ─────────────────────────────────────────────────────
  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
  );

  // ─── Warning ─────────────────────────────────────────────────────
  static const LinearGradient warning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  // ─── Danger ──────────────────────────────────────────────────────
  static const LinearGradient danger = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );

  // ─── Surface shimmer (skeleton loading) ──────────────────────────
  static const LinearGradient shimmer = LinearGradient(
    begin: Alignment(-2, 0),
    end: Alignment(2, 0),
    colors: [Color(0xFFEEEEEE), Color(0xFFF5F5F5), Color(0xFFEEEEEE)],
    stops: [0.0, 0.5, 1.0],
  );

  // ─── Radial glow ─────────────────────────────────────────────────
  static const RadialGradient primaryRadial = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.2,
    colors: [Color(0x1A00BCD4), Color(0x0000BCD4)],
  );

  // ─── Nav sidebar overlay ─────────────────────────────────────────
  static const LinearGradient sidebarBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFAFBFC), Color(0xFFF6F8FA)],
  );

  // ─── KPI card backgrounds ────────────────────────────────────────
  static const LinearGradient kpiPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
  );

  static const LinearGradient kpiSecondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
  );

  static const LinearGradient kpiSuccess = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF22C55E), Color(0xFF15803D)],
  );

  static const LinearGradient kpiWarning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFB45309)],
  );
}
