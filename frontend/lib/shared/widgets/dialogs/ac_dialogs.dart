// file: lib/shared/widgets/dialogs/ac_dialogs.dart
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../core/themes/app_shadows.dart';
import '../buttons/ac_button.dart';

// ─── Dialog type enum ────────────────────────────────────────────────────
enum AcDialogType { info, success, warning, danger, ai }

// ─── AcDialog ────────────────────────────────────────────────────────────
class AcDialog extends StatelessWidget {
  const AcDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.type = AcDialogType.info,
    this.confirmLabel,
    this.cancelLabel,
    this.onConfirm,
    this.onCancel,
    this.isConfirmLoading = false,
    this.isDismissible = true,
  });

  final String title;
  final String? message;
  final Widget? content;
  final AcDialogType type;
  final String? confirmLabel;
  final String? cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isConfirmLoading;
  final bool isDismissible;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    String? message,
    Widget? content,
    AcDialogType type = AcDialogType.info,
    String confirmLabel = 'تأكيد',
    String cancelLabel = 'إلغاء',
    bool isConfirmLoading = false,
    bool isDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: isDismissible,
      barrierColor: AppColors.overlayDark,
      builder: (_) => AcDialog(
        title: title,
        message: message,
        content: content,
        type: type,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
        isConfirmLoading: isConfirmLoading,
        isDismissible: isDismissible,
      ),
    );
  }

  Color get _iconBg => switch (type) {
    AcDialogType.info => AppColors.info100,
    AcDialogType.success => AppColors.success100,
    AcDialogType.warning => AppColors.warning100,
    AcDialogType.danger => AppColors.danger100,
    AcDialogType.ai => AppColors.aiPurpleLight,
  };

  Color get _iconColor => switch (type) {
    AcDialogType.info => AppColors.info500,
    AcDialogType.success => AppColors.success600,
    AcDialogType.warning => AppColors.warning600,
    AcDialogType.danger => AppColors.danger500,
    AcDialogType.ai => AppColors.aiPurple,
  };

  IconData get _icon => switch (type) {
    AcDialogType.info => Icons.info_outline_rounded,
    AcDialogType.success => Icons.check_circle_outline_rounded,
    AcDialogType.warning => Icons.warning_amber_rounded,
    AcDialogType.danger => Icons.delete_outline_rounded,
    AcDialogType.ai => Icons.auto_awesome_rounded,
  };

  AcButtonVariant get _confirmVariant => switch (type) {
    AcDialogType.danger => AcButtonVariant.danger,
    AcDialogType.success => AcButtonVariant.success,
    AcDialogType.ai => AcButtonVariant.ai,
    _ => AcButtonVariant.primary,
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _iconBg,
                      borderRadius: AppRadius.brSm,
                    ),
                    child: Icon(_icon, color: _iconColor, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(title, style: AppTypography.h4)),
                  if (isDismissible)
                    IconButton(
                      onPressed: onCancel ?? () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (content != null) ...[
                const SizedBox(height: AppSpacing.md),
                content!,
              ],
              if (confirmLabel != null || cancelLabel != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (cancelLabel != null)
                      AcButton(
                        label: cancelLabel!,
                        onPressed: onCancel,
                        variant: AcButtonVariant.ghost,
                        size: AcButtonSize.medium,
                      ),
                    if (cancelLabel != null && confirmLabel != null)
                      const SizedBox(width: AppSpacing.xs),
                    if (confirmLabel != null)
                      AcButton(
                        label: confirmLabel!,
                        onPressed: onConfirm,
                        variant: _confirmVariant,
                        size: AcButtonSize.medium,
                        isLoading: isConfirmLoading,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── AcFormDialog ────────────────────────────────────────────────────────
class AcFormDialog extends StatelessWidget {
  const AcFormDialog({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.confirmLabel = 'حفظ',
    this.cancelLabel = 'إلغاء',
    this.onConfirm,
    this.onCancel,
    this.isConfirmLoading = false,
    this.maxWidth = 560,
  });

  final String title;
  final Widget child;
  final String? subtitle;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isConfirmLoading;
  final double maxWidth;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    String? subtitle,
    String confirmLabel = 'حفظ',
    String cancelLabel = 'إلغاء',
    VoidCallback? onConfirm,
    bool isConfirmLoading = false,
    double maxWidth = 560,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: AppColors.overlayDark,
      builder: (_) => AcFormDialog(
        title: title,
        subtitle: subtitle,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        onCancel: () => Navigator.of(context).pop(),
        isConfirmLoading: isConfirmLoading,
        maxWidth: maxWidth,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTypography.h4),
                        if (subtitle != null)
                          Text(subtitle!, style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
            // ── Body ────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: child,
              ),
            ),
            // ── Footer ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: const BoxDecoration(
                color: AppColors.neutral50,
                border: Border(top: BorderSide(color: AppColors.border)),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.modal),
                  bottomRight: Radius.circular(AppRadius.modal),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AcButton(
                    label: cancelLabel,
                    onPressed: onCancel,
                    variant: AcButtonVariant.ghost,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  AcButton(
                    label: confirmLabel,
                    onPressed: onConfirm,
                    isLoading: isConfirmLoading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── AcToast ─────────────────────────────────────────────────────────────
enum AcToastType { info, success, warning, error }

class AcToast {
  static void show(
    BuildContext context, {
    required String message,
    AcToastType type = AcToastType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _AcToastWidget(
        message: message,
        type: type,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _AcToastWidget extends StatefulWidget {
  const _AcToastWidget({
    required this.message,
    required this.type,
    this.actionLabel,
    this.onAction,
    required this.duration,
    required this.onDismiss,
  });

  final String message;
  final AcToastType type;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;
  final VoidCallback onDismiss;

  @override
  State<_AcToastWidget> createState() => _AcToastWidgetState();
}

class _AcToastWidgetState extends State<_AcToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slideY;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideY = Tween(
      begin: 40.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();

    Future.delayed(widget.duration, _dismiss);
  }

  void _dismiss() async {
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _bg => switch (widget.type) {
    AcToastType.info => AppColors.neutral900,
    AcToastType.success => AppColors.success700,
    AcToastType.warning => AppColors.warning600,
    AcToastType.error => AppColors.danger600,
  };

  IconData get _icon => switch (widget.type) {
    AcToastType.info => Icons.info_outline_rounded,
    AcToastType.success => Icons.check_circle_outline_rounded,
    AcToastType.warning => Icons.warning_amber_rounded,
    AcToastType.error => Icons.error_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 24,
      right: 24,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _slideY.value),
            child: child,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: AppRadius.brSm,
                boxShadow: AppShadows.lg,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_icon, color: AppColors.neutral0, size: 18),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      widget.message,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.neutral0,
                      ),
                    ),
                  ),
                  if (widget.actionLabel != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    GestureDetector(
                      onTap: () {
                        widget.onAction?.call();
                        _dismiss();
                      },
                      child: Text(
                        widget.actionLabel!,
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary200,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary200,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: AppSpacing.xs),
                  GestureDetector(
                    onTap: _dismiss,
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.neutral0,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── AcBanner ────────────────────────────────────────────────────────────
class AcBanner extends StatelessWidget {
  const AcBanner({
    super.key,
    required this.message,
    this.type = AcToastType.info,
    this.title,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.isDismissible = true,
  });

  final String message;
  final AcToastType type;
  final String? title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  final bool isDismissible;

  Color get _bgColor => switch (type) {
    AcToastType.info => AppColors.info50,
    AcToastType.success => AppColors.success50,
    AcToastType.warning => AppColors.warning50,
    AcToastType.error => AppColors.danger50,
  };

  Color get _borderColor => switch (type) {
    AcToastType.info => AppColors.info500,
    AcToastType.success => AppColors.success500,
    AcToastType.warning => AppColors.warning500,
    AcToastType.error => AppColors.danger500,
  };

  Color get _iconColor => _borderColor;

  IconData get _icon => switch (type) {
    AcToastType.info => Icons.info_outline_rounded,
    AcToastType.success => Icons.check_circle_outline_rounded,
    AcToastType.warning => Icons.warning_amber_rounded,
    AcToastType.error => Icons.error_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: AppRadius.brSm,
        border: Border.all(color: _borderColor.withValues(alpha: 0.4)),
        boxShadow: AppShadows.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: _iconColor, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: AppTypography.labelLarge.copyWith(color: _iconColor),
                  ),
                Text(
                  message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (actionLabel != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  GestureDetector(
                    onTap: onAction,
                    child: Text(
                      actionLabel!,
                      style: AppTypography.labelMedium.copyWith(
                        color: _iconColor,
                        decoration: TextDecoration.underline,
                        decorationColor: _iconColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isDismissible && onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── AcSnackbar helper ───────────────────────────────────────────────────
class AcSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    AcToastType type = AcToastType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final color = switch (type) {
      AcToastType.info => AppColors.neutral800,
      AcToastType.success => AppColors.success700,
      AcToastType.warning => AppColors.warning600,
      AcToastType.error => AppColors.danger600,
    };

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral0),
          ),
          backgroundColor: color,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brSm),
          action: actionLabel != null
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: AppColors.primary200,
                  onPressed: onAction ?? () {},
                )
              : null,
        ),
      );
  }
}
