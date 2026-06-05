// file: frontend\lib\core\themes\app_radius.dart
import 'package:flutter/material.dart';

abstract class AppRadius {
  // ─── Raw values ────────────────────────────────────────────────────
  static const double r0 = 0.0;
  static const double r2 = 2.0;
  static const double r4 = 4.0;
  static const double r6 = 6.0;
  static const double r8 = 8.0;
  static const double r10 = 10.0;
  static const double r12 = 12.0;
  static const double r14 = 14.0;
  static const double r16 = 16.0;
  static const double r20 = 20.0;
  static const double r24 = 24.0;
  static const double r32 = 32.0;
  static const double r999 = 999.0; // pill

  // ─── Semantic aliases ──────────────────────────────────────────────
  static const double none = r0;
  static const double xs = r4;
  static const double sm = r8;
  static const double md = r12;
  static const double lg = r16;
  static const double xl = r20;
  static const double xxl = r24;
  static const double pill = r999;
  static const double circle = r999;

  // ─── Component-specific ───────────────────────────────────────────
  static const double button = r10;
  static const double buttonSm = r8;
  static const double buttonLg = r12;
  static const double input = r10;
  static const double card = r16;
  static const double cardSm = r12;
  static const double modal = r20;
  static const double chip = r8;
  static const double avatar = r999;
  static const double badge = r999;
  static const double tooltip = r6;
  static const double dropdown = r12;
  static const double drawer = r0;
  static const double bottomSheet = r24;
  static const double snackbar = r12;

  // ─── BorderRadius helpers ─────────────────────────────────────────
  static const BorderRadius brNone = BorderRadius.all(Radius.circular(none));
  static const BorderRadius brXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius brXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius brButton = BorderRadius.all(
    Radius.circular(button),
  );
  static const BorderRadius brInput = BorderRadius.all(Radius.circular(input));
  static const BorderRadius brDropdown = BorderRadius.all(
    Radius.circular(dropdown),
  );
  static const BorderRadius brCard = BorderRadius.all(Radius.circular(card));
  static const BorderRadius brModal = BorderRadius.all(Radius.circular(modal));

  static const BorderRadius brBottomSheet = BorderRadius.only(
    topLeft: Radius.circular(bottomSheet),
    topRight: Radius.circular(bottomSheet),
  );

  // ─── RoundedRectangleBorder helpers ──────────────────────────────
  static RoundedRectangleBorder get shapeCard =>
      const RoundedRectangleBorder(borderRadius: brCard);

  static RoundedRectangleBorder get shapeButton =>
      const RoundedRectangleBorder(borderRadius: brButton);

  static RoundedRectangleBorder get shapeModal =>
      const RoundedRectangleBorder(borderRadius: brModal);
}
