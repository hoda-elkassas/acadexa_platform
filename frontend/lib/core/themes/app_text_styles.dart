// file: lib/core/themes/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

const String kFontFamily = 'Cairo';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get display => GoogleFonts.cairo(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: kTextDark,
  );

  static TextStyle get title => GoogleFonts.cairo(
    fontSize: 22,
    fontWeight: FontWeight.w600, // SemiBold
    color: kTextDark,
  );

  static TextStyle get body => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: kTextDark,
  );

  static TextStyle get caption => GoogleFonts.cairo(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: kTextMedium,
  );

  static TextStyle get button => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: kWhite,
  );
}
