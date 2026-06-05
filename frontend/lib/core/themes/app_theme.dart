// file: lib/core/themes/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  // ─── Light Theme ───────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: AppTypography.arabicFont,
    textTheme: AppTypography.textTheme,

    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary500,
      onPrimary: AppColors.neutral0,
      primaryContainer: AppColors.primary100,
      onPrimaryContainer: AppColors.primary900,
      secondary: AppColors.secondary700,
      onSecondary: AppColors.neutral0,
      secondaryContainer: AppColors.secondary100,
      onSecondaryContainer: AppColors.secondary900,
      tertiary: AppColors.aiPurple,
      onTertiary: AppColors.neutral0,
      tertiaryContainer: AppColors.aiPurpleLight,
      onTertiaryContainer: Color(0xFF3B0764),
      error: AppColors.danger500,
      onError: AppColors.neutral0,
      errorContainer: AppColors.danger100,
      onErrorContainer: AppColors.danger700,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest:
          AppColors.neutral100, //  changed from surfaceVariant
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.neutral200,
      shadow: Color(0x1A000000),
      scrim: Color(0x80000000),
      inverseSurface: AppColors.neutral900,
      onInverseSurface: AppColors.neutral50,
      inversePrimary: AppColors.primary200,
    ),

    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.surface,
    cardColor: AppColors.surface,
    dividerColor: AppColors.border,
    disabledColor: AppColors.textDisabled,
    hintColor: AppColors.textMuted,
    splashColor: AppColors.primary100,
    highlightColor: AppColors.primary50,

    // ─── AppBar ────────────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: const Color(0x0A000000),
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: AppTypography.h4,
      toolbarHeight: AppSpacing.topBarHeight,
      shape: const Border(
        bottom: BorderSide(color: AppColors.border, width: 1),
      ),
    ),

    // ─── Card ──────────────────────────────────────────────────────
    cardTheme: const CardThemeData(
      //  changed from CardTheme
      elevation: 0,
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.brCard,
        side: BorderSide(color: AppColors.border, width: 1),
      ),
      margin: EdgeInsets.all(0),
      clipBehavior: Clip.antiAlias,
    ),

    // ─── Elevated Button ───────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary500,
        foregroundColor: AppColors.neutral0,
        disabledBackgroundColor: AppColors.neutral200,
        disabledForegroundColor: AppColors.textDisabled,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brButton),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingH,
          vertical: AppSpacing.buttonPaddingV,
        ),
        minimumSize: const Size(120, 44),
        textStyle: AppTypography.buttonMedium,
        animationDuration: const Duration(milliseconds: 150),
      ),
    ),

    // ─── Outlined Button ───────────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary500,
        disabledForegroundColor: AppColors.textDisabled,
        side: const BorderSide(color: AppColors.border, width: 1.5),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brButton),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingH,
          vertical: AppSpacing.buttonPaddingV,
        ),
        minimumSize: const Size(120, 44),
        textStyle: AppTypography.buttonMedium.copyWith(
          color: AppColors.primary500,
        ),
      ),
    ),

    // ─── Text Button ───────────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary500,
        disabledForegroundColor: AppColors.textDisabled,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brButton),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHSm,
          vertical: AppSpacing.buttonPaddingVSm,
        ),
        minimumSize: const Size(64, 36),
        textStyle: AppTypography.buttonMedium.copyWith(
          color: AppColors.primary500,
        ),
      ),
    ),

    // ─── FilledButton ──────────────────────────────────────────────
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary500,
        foregroundColor: AppColors.neutral0,
        disabledBackgroundColor: AppColors.neutral200,
        disabledForegroundColor: AppColors.textDisabled,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brButton),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingH,
          vertical: AppSpacing.buttonPaddingV,
        ),
        minimumSize: const Size(120, 44),
      ),
    ),

    // ─── Input Decoration ──────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hoverColor: AppColors.neutral50,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.inputPaddingH,
        vertical: AppSpacing.inputPaddingV,
      ),
      border: const OutlineInputBorder(
        borderRadius: AppRadius.brInput,
        borderSide: BorderSide(color: AppColors.border, width: 1.5),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: AppRadius.brInput,
        borderSide: BorderSide(color: AppColors.border, width: 1.5),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: AppRadius.brInput,
        borderSide: BorderSide(color: AppColors.primary500, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: AppRadius.brInput,
        borderSide: BorderSide(color: AppColors.danger500, width: 1.5),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: AppRadius.brInput,
        borderSide: BorderSide(color: AppColors.danger500, width: 2),
      ),
      disabledBorder: const OutlineInputBorder(
        borderRadius: AppRadius.brInput,
        borderSide: BorderSide(color: AppColors.neutral200, width: 1.5),
      ),
      labelStyle: AppTypography.labelMedium,
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
      errorStyle: AppTypography.bodySmall.copyWith(color: AppColors.danger500),
      helperStyle: AppTypography.bodySmall,
      prefixIconColor: AppColors.textMuted,
      suffixIconColor: AppColors.textMuted,
      isDense: false,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    ),

    // ─── Chip ──────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.neutral100,
      selectedColor: AppColors.primary100,
      disabledColor: AppColors.neutral100,
      secondarySelectedColor: AppColors.primary100,
      labelStyle: AppTypography.labelMedium,
      secondaryLabelStyle: AppTypography.labelMedium.copyWith(
        color: AppColors.primary600,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.brMd,
        side: BorderSide(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      elevation: 0,
    ),

    // ─── Dialog ────────────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      //  changed from DialogTheme
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.brModal),
      titleTextStyle: AppTypography.h3,
      contentTextStyle: AppTypography.bodyMedium,
    ),

    // ─── BottomSheet ───────────────────────────────────────────────
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.brBottomSheet),
      showDragHandle: true,
      dragHandleColor: AppColors.neutral300,
    ),

    // ─── SnackBar ──────────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.neutral900,
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.neutral0,
      ),
      actionTextColor: AppColors.primary300,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.brSm),
      elevation: 4,
    ),

    // ─── NavigationRail ────────────────────────────────────────────
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: AppColors.surface,
      elevation: 0,
      selectedLabelTextStyle: AppTypography.labelMedium.copyWith(
        color: AppColors.primary500,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: AppTypography.labelMedium,
      selectedIconTheme: const IconThemeData(color: AppColors.primary500),
      unselectedIconTheme: const IconThemeData(color: AppColors.textSecondary),
      indicatorColor: AppColors.primary50,
      indicatorShape: const RoundedRectangleBorder(borderRadius: AppRadius.brSm),
      useIndicator: true,
      minWidth: 72,
      minExtendedWidth: 256,
    ),

    // ─── NavigationBar ─────────────────────────────────────────────
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: AppSpacing.bottomNavHeight,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTypography.labelSmall.copyWith(color: AppColors.primary500);
        }
        return AppTypography.labelSmall;
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary500, size: 24);
        }
        return const IconThemeData(color: AppColors.textSecondary, size: 24);
      }),
      indicatorColor: AppColors.primary50,
      indicatorShape: const RoundedRectangleBorder(borderRadius: AppRadius.brPill),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      shadowColor: Colors.transparent,
    ),

    // ─── Divider ───────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),

    // ─── ListTile ──────────────────────────────────────────────────
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      titleTextStyle: AppTypography.bodyMedium,
      subtitleTextStyle: AppTypography.bodySmall,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.brSm),
      selectedColor: AppColors.primary500,
      selectedTileColor: AppColors.primary50,
    ),

    // ─── PopupMenu ─────────────────────────────────────────────────
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.surface,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.brMd,
        side: BorderSide(color: AppColors.border),
      ),
      textStyle: AppTypography.bodyMedium,
      surfaceTintColor: Colors.transparent,
    ),

    // ─── Tooltip ───────────────────────────────────────────────────
    tooltipTheme: TooltipThemeData(
      decoration: const BoxDecoration(
        color: AppColors.neutral800,
        borderRadius: AppRadius.brXs,
      ),
      textStyle: AppTypography.bodySmall.copyWith(color: AppColors.neutral0),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
    ),

    // ─── Tab Bar ───────────────────────────────────────────────────
    tabBarTheme: TabBarThemeData(
      //  changed from TabBarTheme
      labelColor: AppColors.primary500,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: AppTypography.labelLarge.copyWith(
        color: AppColors.primary500,
      ),
      unselectedLabelStyle: AppTypography.labelLarge,
      indicatorColor: AppColors.primary500,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: AppColors.border,
    ),

    // ─── Switch ────────────────────────────────────────────────────
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.neutral0;
        return AppColors.neutral400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary500;
        return AppColors.neutral200;
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),

    // ─── Checkbox ──────────────────────────────────────────────────
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary500;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(AppColors.neutral0),
      side: const BorderSide(color: AppColors.border, width: 1.5),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.brXs),
    ),

    // ─── Radio ─────────────────────────────────────────────────────
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary500;
        return AppColors.textSecondary;
      }),
    ),

    // ─── Progress Indicator ────────────────────────────────────────
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary500,
      linearTrackColor: AppColors.neutral200,
      circularTrackColor: AppColors.neutral200,
      linearMinHeight: 4,
    ),

    // ─── Floating Action Button ────────────────────────────────────
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary500,
      foregroundColor: AppColors.neutral0,
      elevation: 4,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
      extendedTextStyle: AppTypography.buttonMedium,
    ),

    // ─── DataTable ─────────────────────────────────────────────────
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStateProperty.all(AppColors.neutral50),
      dataRowColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) return AppColors.neutral50;
        if (states.contains(WidgetState.selected)) return AppColors.primary50;
        return AppColors.surface;
      }),
      headingTextStyle: AppTypography.labelLarge.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
      dataTextStyle: AppTypography.bodyMedium,
      dividerThickness: 1,
      columnSpacing: AppSpacing.lg,
      horizontalMargin: AppSpacing.md,
      headingRowHeight: 48,
      dataRowMinHeight: 52,
      dataRowMaxHeight: 72,
    ),

    // ─── Icon ──────────────────────────────────────────────────────
    iconTheme: const IconThemeData(
      color: AppColors.textSecondary,
      size: AppSpacing.iconLg,
    ),

    // ─── Badge ─────────────────────────────────────────────────────
    badgeTheme: BadgeThemeData(
      backgroundColor: AppColors.danger500,
      textColor: AppColors.neutral0,
      textStyle: AppTypography.caption.copyWith(
        color: AppColors.neutral0,
        fontWeight: FontWeight.w600,
      ),
      smallSize: 8,
      largeSize: 18,
    ),
  );
}
