// file: frontend\lib\core\themes\app_shadows.dart
import 'package:flutter/material.dart';

abstract class AppShadows {
  // ─── Shadow primitives ────────────────────────────────────────────
  static const Color _shadowColor = Color(0x0F000000);
  static const Color _shadowMd = Color(0x14000000);
  static const Color _shadowLg = Color(0x1A000000);
  static const Color _shadowXl = Color(0x26000000);

  // ─── None ─────────────────────────────────────────────────────────
  static const List<BoxShadow> none = [];

  // ─── xs ───────────────────────────────────────────────────────────
  static const List<BoxShadow> xs = [
    BoxShadow(color: _shadowColor, blurRadius: 2, offset: Offset(0, 1)),
  ];

  // ─── sm ───────────────────────────────────────────────────────────
  static const List<BoxShadow> sm = [
    BoxShadow(color: _shadowColor, blurRadius: 4, offset: Offset(0, 1)),
    BoxShadow(color: _shadowColor, blurRadius: 2, offset: Offset(0, 1)),
  ];

  // ─── md ───────────────────────────────────────────────────────────
  static const List<BoxShadow> md = [
    BoxShadow(
      color: _shadowMd,
      blurRadius: 6,
      spreadRadius: -2,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: _shadowColor,
      blurRadius: 4,
      spreadRadius: -1,
      offset: Offset(0, 2),
    ),
  ];

  // ─── lg ───────────────────────────────────────────────────────────
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: _shadowLg,
      blurRadius: 15,
      spreadRadius: -3,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: _shadowMd,
      blurRadius: 6,
      spreadRadius: -4,
      offset: Offset(0, 2),
    ),
  ];

  // ─── xl ───────────────────────────────────────────────────────────
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: _shadowXl,
      blurRadius: 25,
      spreadRadius: -5,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: _shadowMd,
      blurRadius: 10,
      spreadRadius: -6,
      offset: Offset(0, 4),
    ),
  ];

  // ─── 2xl ──────────────────────────────────────────────────────────
  static const List<BoxShadow> xxl = [
    BoxShadow(
      color: _shadowXl,
      blurRadius: 50,
      spreadRadius: -12,
      offset: Offset(0, 25),
    ),
  ];

  // ─── Brand / primary glow ─────────────────────────────────────────
  static const List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: Color(0x3300BCD4),
      blurRadius: 20,
      spreadRadius: -2,
      offset: Offset(0, 4),
    ),
  ];

  // ─── AI glow (purple) ─────────────────────────────────────────────
  static const List<BoxShadow> aiGlow = [
    BoxShadow(
      color: Color(0x337C3AED),
      blurRadius: 24,
      spreadRadius: -4,
      offset: Offset(0, 8),
    ),
  ];

  // ─── Floating panel (sidebar, dropdown) ──────────────────────────
  static const List<BoxShadow> panel = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 32,
      spreadRadius: -8,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 6,
      spreadRadius: -1,
      offset: Offset(0, 2),
    ),
  ];

  // ─── Modal ────────────────────────────────────────────────────────
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 64,
      spreadRadius: -16,
      offset: Offset(0, 24),
    ),
  ];

  // ─── Inner shadow (input focused) ────────────────────────────────
  static List<BoxShadow> inputFocused = [
    const BoxShadow(
      color: Color(0x2600BCD4),
      blurRadius: 0,
      spreadRadius: 3,
      offset: Offset(0, 0),
    ),
  ];
}
