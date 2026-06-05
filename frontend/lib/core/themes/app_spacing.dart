// file: lib/core/theme/app_spacing.dart
import 'package:flutter/material.dart';

abstract class AppSpacing {
  // ─── Base scale (4px) ───────────────────────────────────────────────
  static const double px0 = 0.0;
  static const double px1 = 1.0;
  static const double px2 = 2.0;
  static const double px4 = 4.0;
  static const double px6 = 6.0;
  static const double px8 = 8.0;
  static const double px10 = 10.0;
  static const double px12 = 12.0;
  static const double px14 = 14.0;
  static const double px16 = 16.0;
  static const double px20 = 20.0;
  static const double px24 = 24.0;
  static const double px28 = 28.0;
  static const double px32 = 32.0;
  static const double px36 = 36.0;
  static const double px40 = 40.0;
  static const double px48 = 48.0;
  static const double px56 = 56.0;
  static const double px64 = 64.0;
  static const double px80 = 80.0;
  static const double px96 = 96.0;

  // ─── Semantic aliases ────────────────────────────────────────────────
  static const double xxs = px4;
  static const double xs = px8;
  static const double sm = px12;
  static const double md = px16;
  static const double lg = px24;
  static const double xl = px32;
  static const double xxl = px48;
  static const double xxxl = px64;

  // ─── Component-specific ──────────────────────────────────────────────
  static const double buttonPaddingH = px24;
  static const double buttonPaddingV = px12;
  static const double buttonPaddingHSm = px16;
  static const double buttonPaddingVSm = px8;
  static const double buttonPaddingHLg = px32;
  static const double buttonPaddingVLg = px16;

  static const double inputPaddingH = px16;
  static const double inputPaddingV = px14;

  static const double cardPadding = px20;
  static const double cardPaddingCompact = px16;
  static const double cardGap = px16;

  static const double sectionGap = px32;
  static const double pageHorizontal = px24;
  static const double pageHorizontalSm = px16;
  static const double pageVertical = px24;

  static const double navRailWidth = 256.0;
  static const double navRailWidthCollapsed = 72.0;
  static const double topBarHeight = 64.0;
  static const double bottomNavHeight = 64.0;

  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 48.0;

  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 56.0;
  static const double avatarXl = 80.0;

  // ─── Convenience EdgeInsets ──────────────────────────────────────────
  static const EdgeInsets insetXxs = EdgeInsets.all(xxs);
  static const EdgeInsets insetXs = EdgeInsets.all(xs);
  static const EdgeInsets insetSm = EdgeInsets.all(sm);
  static const EdgeInsets insetMd = EdgeInsets.all(md);
  static const EdgeInsets insetLg = EdgeInsets.all(lg);
  static const EdgeInsets insetXl = EdgeInsets.all(xl);
  static const EdgeInsets insetCard = EdgeInsets.all(cardPadding);
  static const EdgeInsets insetPage = EdgeInsets.symmetric(
    horizontal: pageHorizontal,
    vertical: pageVertical,
  );
  static const EdgeInsets insetPageSm = EdgeInsets.symmetric(
    horizontal: pageHorizontalSm,
    vertical: pageVertical,
  );

  // ─── SizedBox helpers ────────────────────────────────────────────────
  static const Widget gapXxs = SizedBox(width: xxs, height: xxs);
  static const Widget gapXs = SizedBox(width: xs, height: xs);
  static const Widget gapSm = SizedBox(width: sm, height: sm);
  static const Widget gapMd = SizedBox(width: md, height: md);
  static const Widget gapLg = SizedBox(width: lg, height: lg);
  static const Widget gapXl = SizedBox(width: xl, height: xl);
  static const Widget gapXxl = SizedBox(width: xxl, height: xxl);
  static const Widget gapH4 = SizedBox(height: px4);
  static const Widget gapH8 = SizedBox(height: px8);
  static const Widget gapH12 = SizedBox(height: px12);
  static const Widget gapH16 = SizedBox(height: px16);
  static const Widget gapH24 = SizedBox(height: px24);
  static const Widget gapH32 = SizedBox(height: px32);
  static const Widget gapW4 = SizedBox(width: px4);
  static const Widget gapW8 = SizedBox(width: px8);
  static const Widget gapW12 = SizedBox(width: px12);
  static const Widget gapW16 = SizedBox(width: px16);
}
