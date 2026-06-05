// file: lib/shared/widgets/buttons/ac_button.dart
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../core/themes/app_gradients.dart';
import '../../../core/themes/app_shadows.dart';

// ─── Button Size enum ──────────────────────────────────────────────────────
enum AcButtonSize { small, medium, large }

// ─── Button Variant enum ───────────────────────────────────────────────────
enum AcButtonVariant { primary, secondary, ghost, danger, success, warning, ai }

// ─── AcButton ─────────────────────────────────────────────────────────────
class AcButton extends StatefulWidget {
  const AcButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AcButtonVariant.primary,
    this.size = AcButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.useGradient = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AcButtonVariant variant;
  final AcButtonSize size;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool isLoading;
  final bool isDisabled;
  final bool isFullWidth;
  final bool useGradient;

  @override
  State<AcButton> createState() => _AcButtonState();
}

class _AcButtonState extends State<AcButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isInteractive => !widget.isDisabled && !widget.isLoading;

  EdgeInsets get _padding => switch (widget.size) {
    AcButtonSize.small => const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    AcButtonSize.medium => const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 12,
    ),
    AcButtonSize.large => const EdgeInsets.symmetric(
      horizontal: 32,
      vertical: 16,
    ),
  };

  double get _minHeight => switch (widget.size) {
    AcButtonSize.small => 34,
    AcButtonSize.medium => 44,
    AcButtonSize.large => 52,
  };

  TextStyle get _textStyle => switch (widget.size) {
    AcButtonSize.small => AppTypography.buttonSmall,
    AcButtonSize.medium => AppTypography.buttonMedium,
    AcButtonSize.large => AppTypography.buttonLarge,
  };

  double get _spinnerSize => switch (widget.size) {
    AcButtonSize.small => 14,
    AcButtonSize.medium => 16,
    AcButtonSize.large => 18,
  };

  Color get _bgColor => switch (widget.variant) {
    AcButtonVariant.primary => AppColors.primary500,
    AcButtonVariant.secondary => AppColors.neutral100,
    AcButtonVariant.ghost => Colors.transparent,
    AcButtonVariant.danger => AppColors.danger500,
    AcButtonVariant.success => AppColors.success500,
    AcButtonVariant.warning => AppColors.warning500,
    AcButtonVariant.ai => AppColors.aiPurple,
  };

  Color get _fgColor => switch (widget.variant) {
    AcButtonVariant.primary => AppColors.neutral0,
    AcButtonVariant.secondary => AppColors.textPrimary,
    AcButtonVariant.ghost => AppColors.primary500,
    AcButtonVariant.danger => AppColors.neutral0,
    AcButtonVariant.success => AppColors.neutral0,
    AcButtonVariant.warning => AppColors.neutral0,
    AcButtonVariant.ai => AppColors.neutral0,
  };

  Border? get _border => switch (widget.variant) {
    AcButtonVariant.secondary => Border.all(
      color: AppColors.border,
      width: 1.5,
    ),
    AcButtonVariant.ghost => Border.all(color: AppColors.border, width: 1.5),
    _ => null,
  };

  Gradient? get _gradient {
    if (!widget.useGradient) return null;
    return switch (widget.variant) {
      AcButtonVariant.primary => AppGradients.primaryHorizontal,
      AcButtonVariant.ai => AppGradients.ai,
      AcButtonVariant.danger => AppGradients.danger,
      AcButtonVariant.success => AppGradients.success,
      _ => null,
    };
  }

  List<BoxShadow> get _shadow => switch (widget.variant) {
    AcButtonVariant.primary when widget.useGradient => AppShadows.primaryGlow,
    AcButtonVariant.ai => AppShadows.aiGlow,
    _ => AppShadows.sm,
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      enabled: _isInteractive,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: GestureDetector(
          onTapDown: _isInteractive ? (_) => _controller.forward() : null,
          onTapUp: _isInteractive ? (_) => _controller.reverse() : null,
          onTapCancel: _isInteractive ? () => _controller.reverse() : null,
          onTap: _isInteractive ? widget.onPressed : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: BoxConstraints(minHeight: _minHeight),
            width: widget.isFullWidth ? double.infinity : null,
            padding: _padding,
            decoration: BoxDecoration(
              color: _gradient == null
                  ? (widget.isDisabled ? AppColors.neutral200 : _bgColor)
                  : null,
              gradient: widget.isDisabled ? null : _gradient,
              borderRadius: AppRadius.brButton,
              border: widget.isDisabled
                  ? Border.all(color: AppColors.neutral300)
                  : _border,
              boxShadow: widget.isDisabled || widget.isLoading ? null : _shadow,
            ),
            child: Row(
              mainAxisSize: widget.isFullWidth
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading) ...[
                  SizedBox(
                    width: _spinnerSize,
                    height: _spinnerSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.isDisabled
                          ? AppColors.textDisabled
                          : _fgColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ] else if (widget.leadingIcon != null) ...[
                  IconTheme(
                    data: IconThemeData(
                      size: _spinnerSize + 2,
                      color: widget.isDisabled
                          ? AppColors.textDisabled
                          : _fgColor,
                    ),
                    child: widget.leadingIcon!,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(
                  widget.label,
                  style: _textStyle.copyWith(
                    color: widget.isDisabled
                        ? AppColors.textDisabled
                        : _fgColor,
                  ),
                ),
                if (widget.trailingIcon != null && !widget.isLoading) ...[
                  const SizedBox(width: AppSpacing.xs),
                  IconTheme(
                    data: IconThemeData(
                      size: _spinnerSize + 2,
                      color: widget.isDisabled
                          ? AppColors.textDisabled
                          : _fgColor,
                    ),
                    child: widget.trailingIcon!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── AcIconButton ─────────────────────────────────────────────────────────
class AcIconButton extends StatelessWidget {
  const AcIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.variant = AcButtonVariant.ghost,
    this.size = AcButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.badge,
    this.badgeColor,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final AcButtonVariant variant;
  final AcButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final String? badge;
  final Color? badgeColor;

  double get _btnSize => switch (size) {
    AcButtonSize.small => 32,
    AcButtonSize.medium => 40,
    AcButtonSize.large => 48,
  };

  double get _iconSize => switch (size) {
    AcButtonSize.small => 16,
    AcButtonSize.medium => 20,
    AcButtonSize.large => 24,
  };

  Color get _bgColor => switch (variant) {
    AcButtonVariant.primary => AppColors.primary50,
    AcButtonVariant.secondary => AppColors.neutral100,
    AcButtonVariant.ghost => Colors.transparent,
    AcButtonVariant.danger => AppColors.danger50,
    AcButtonVariant.success => AppColors.success50,
    AcButtonVariant.warning => AppColors.warning50,
    AcButtonVariant.ai => AppColors.aiPurpleLight,
  };

  Color get _fgColor => switch (variant) {
    AcButtonVariant.primary => AppColors.primary500,
    AcButtonVariant.secondary => AppColors.textSecondary,
    AcButtonVariant.ghost => AppColors.textSecondary,
    AcButtonVariant.danger => AppColors.danger500,
    AcButtonVariant.success => AppColors.success500,
    AcButtonVariant.warning => AppColors.warning500,
    AcButtonVariant.ai => AppColors.aiPurple,
  };

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: _btnSize,
      height: _btnSize,
      decoration: BoxDecoration(
        color: isDisabled ? AppColors.neutral100 : _bgColor,
        borderRadius: AppRadius.brSm,
      ),
      child: Center(
        child: isLoading
            ? SizedBox(
                width: _iconSize,
                height: _iconSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _fgColor,
                ),
              )
            : IconTheme(
                data: IconThemeData(
                  size: _iconSize,
                  color: isDisabled ? AppColors.textDisabled : _fgColor,
                ),
                child: icon,
              ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    // Badge with Stack (works on all Flutter versions)
    if (badge != null && badge!.isNotEmpty) {
      button = Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: button,
            onPressed: isDisabled ? null : onPressed,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: badgeColor ?? AppColors.danger500,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                badge!.length > 2 ? '99+' : badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    } else {
      button = IconButton(
        icon: button,
        onPressed: isDisabled ? null : onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      );
    }

    return Semantics(button: true, enabled: !isDisabled, child: button);
  }
}

// ─── AcFab ────────────────────────────────────────────────────────────────
class AcFab extends StatelessWidget {
  const AcFab({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.isLoading = false,
    this.variant = AcButtonVariant.primary,
  });

  final Widget icon;
  final VoidCallback onPressed;
  final String? label;
  final bool isLoading;
  final AcButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final bg = switch (variant) {
      AcButtonVariant.primary => AppColors.primary500,
      AcButtonVariant.ai => AppColors.aiPurple,
      AcButtonVariant.success => AppColors.success500,
      AcButtonVariant.danger => AppColors.danger500,
      _ => AppColors.primary500,
    };

    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: isLoading ? null : onPressed,
        backgroundColor: bg,
        foregroundColor: AppColors.neutral0,
        elevation: 4,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : icon,
        label: Text(label!, style: AppTypography.buttonMedium),
      );
    }

    return FloatingActionButton(
      onPressed: isLoading ? null : onPressed,
      backgroundColor: bg,
      foregroundColor: AppColors.neutral0,
      elevation: 4,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : icon,
    );
  }
}
