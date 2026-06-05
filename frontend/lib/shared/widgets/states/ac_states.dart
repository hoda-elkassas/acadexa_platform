// file: lib/shared/widgets/states/ac_states.dart
import 'package:flutter/material.dart';
import '../../../core/themes/app_shadows.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../core/themes/app_gradients.dart';
import '../buttons/ac_button.dart';

// ─── AcLoadingState ───────────────────────────────────────────────────────
class AcLoadingState extends StatelessWidget {
  const AcLoadingState({
    super.key,
    this.message,
    this.size = AcStateSize.medium,
  });

  final String? message;
  final AcStateSize size;

  @override
  Widget build(BuildContext context) {
    final spinnerSize = switch (size) {
      AcStateSize.small => 24.0,
      AcStateSize.medium => 40.0,
      AcStateSize.large => 56.0,
    };

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: spinnerSize,
            height: spinnerSize,
            child: CircularProgressIndicator(
              strokeWidth: size == AcStateSize.small ? 2 : 3,
              color: AppColors.primary500,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── AcEmptyState ─────────────────────────────────────────────────────────
class AcEmptyState extends StatelessWidget {
  const AcEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.size = AcStateSize.medium,
  });

  final String title;
  final String? message;
  final Widget? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final AcStateSize size;

  @override
  Widget build(BuildContext context) {
    final iconSize = switch (size) {
      AcStateSize.small => 40.0,
      AcStateSize.medium => 64.0,
      AcStateSize.large => 88.0,
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: const BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: AppRadius.brMd,
              ),
              child: Center(
                child: IconTheme(
                  data: IconThemeData(
                    size: iconSize * 0.5,
                    color: AppColors.textMuted,
                  ),
                  child: icon ?? const Icon(Icons.inbox_outlined),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: switch (size) {
                AcStateSize.small => AppTypography.labelLarge,
                AcStateSize.medium => AppTypography.h5,
                AcStateSize.large => AppTypography.h4,
              },
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                message!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AcButton(
                label: actionLabel!,
                onPressed: onAction,
                size: AcButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── AcErrorState ─────────────────────────────────────────────────────────
class AcErrorState extends StatelessWidget {
  const AcErrorState({
    super.key,
    required this.title,
    this.message,
    this.errorCode,
    this.onRetry,
    this.onGoHome,
    this.onReport,
    this.size = AcStateSize.medium,
  });

  final String title;
  final String? message;
  final String? errorCode;
  final VoidCallback? onRetry;
  final VoidCallback? onGoHome;
  final VoidCallback? onReport;
  final AcStateSize size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.danger50,
                borderRadius: AppRadius.brXl,
              ),
              child: const Center(
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: AppColors.danger500,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: AppTypography.h4, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                message!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (errorCode != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'كود الخطأ: $errorCode',
                style: AppTypography.caption,
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null || onGoHome != null) ...[
              const SizedBox(height: AppSpacing.lg),
              if (onRetry != null)
                AcButton(
                  label: 'إعادة المحاولة',
                  onPressed: onRetry,
                  leadingIcon: const Icon(Icons.refresh_rounded),
                  isFullWidth: true,
                ),
              if (onGoHome != null) ...[
                const SizedBox(height: AppSpacing.xs),
                AcButton(
                  label: 'العودة للرئيسية',
                  onPressed: onGoHome,
                  variant: AcButtonVariant.ghost,
                  isFullWidth: true,
                ),
              ],
              if (onReport != null) ...[
                const SizedBox(height: AppSpacing.xs),
                TextButton(
                  onPressed: onReport,
                  child: Text(
                    'الإبلاغ عن المشكلة',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ─── AcSuccessState ───────────────────────────────────────────────────────
class AcSuccessState extends StatefulWidget {
  const AcSuccessState({
    super.key,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  State<AcSuccessState> createState() => _AcSuccessStateState();
}

class _AcSuccessStateState extends State<AcSuccessState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    gradient: AppGradients.success,
                    borderRadius: AppRadius.brXl,
                    boxShadow: AppShadows.primaryGlow,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      size: 44,
                      color: AppColors.neutral0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.title,
                style: AppTypography.h3,
                textAlign: TextAlign.center,
              ),
              if (widget.message != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.message!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (widget.actionLabel != null) ...[
                const SizedBox(height: AppSpacing.lg),
                AcButton(
                  label: widget.actionLabel!,
                  onPressed: widget.onAction,
                  isFullWidth: true,
                ),
              ],
              if (widget.secondaryActionLabel != null) ...[
                const SizedBox(height: AppSpacing.xs),
                AcButton(
                  label: widget.secondaryActionLabel!,
                  onPressed: widget.onSecondaryAction,
                  variant: AcButtonVariant.ghost,
                  isFullWidth: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── AcStateSize enum ─────────────────────────────────────────────────────
enum AcStateSize { small, medium, large }

// ─── AcPageLoader ─────────────────────────────────────────────────────────
class AcPageLoader extends StatefulWidget {
  const AcPageLoader({
    super.key,
    this.message,
    this.showCancelAfterMs = 5000,
    this.onCancel,
    this.progress,
  });

  final String? message;
  final int showCancelAfterMs;
  final VoidCallback? onCancel;
  final double? progress; // null = indeterminate, 0.0-1.0 = determinate

  @override
  State<AcPageLoader> createState() => _AcPageLoaderState();
}

class _AcPageLoaderState extends State<AcPageLoader>
    with TickerProviderStateMixin {
  late final AnimationController _dotCtrl;
  bool _showCancel = false;

  @override
  void initState() {
    super.initState();
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    if (widget.onCancel != null) {
      Future.delayed(Duration(milliseconds: widget.showCancelAfterMs), () {
        if (mounted) setState(() => _showCancel = true);
      });
    }
  }

  @override
  void dispose() {
    _dotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          if (widget.progress != null)
            LinearProgressIndicator(
              value: widget.progress,
              backgroundColor: AppColors.neutral200,
              color: AppColors.primary500,
              minHeight: 3,
            ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        gradient: AppGradients.primaryDiagonal,
                        borderRadius: AppRadius.brMd,
                        boxShadow: AppShadows.primaryGlow,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.neutral0,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AnimatedBuilder(
                      animation: _dotCtrl,
                      builder: (context, child) {
                        final dots = '.' * ((_dotCtrl.value * 3).floor() + 1);
                        return Text(
                          '${widget.message ?? "جاري التحميل"}$dots',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    ),
                    if (_showCancel) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'يبدو أن العملية تستغرق وقتاً أطول من المعتاد',
                        style: AppTypography.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AcButton(
                        label: 'إلغاء',
                        onPressed: widget.onCancel,
                        variant: AcButtonVariant.ghost,
                        size: AcButtonSize.small,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── AcAiProcessingScreen ─────────────────────────────────────────────────
class AcAiProcessingScreen extends StatefulWidget {
  const AcAiProcessingScreen({
    super.key,
    this.message = 'جاري تحليل البيانات بالذكاء الاصطناعي',
    this.steps = const [],
    this.currentStep = 0,
  });

  final String message;
  final List<String> steps;
  final int currentStep;

  @override
  State<AcAiProcessingScreen> createState() => _AcAiProcessingScreenState();
}

class _AcAiProcessingScreenState extends State<AcAiProcessingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulse = Tween(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _pulse,
              child: Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  gradient: AppGradients.ai,
                  borderRadius: AppRadius.brXl,
                  boxShadow: AppShadows.aiGlow,
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 40,
                    color: AppColors.neutral0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              widget.message,
              style: AppTypography.h5,
              textAlign: TextAlign.center,
            ),
            if (widget.steps.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              ...widget.steps.asMap().entries.map((e) {
                final done = e.key < widget.currentStep;
                final active = e.key == widget.currentStep;
                final pending = e.key > widget.currentStep;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: done
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.success500,
                                size: 20,
                              )
                            : active
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.aiPurple,
                                ),
                              )
                            : const Icon(
                                Icons.radio_button_unchecked,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        e.value,
                        style: AppTypography.bodyMedium.copyWith(
                          color: pending
                              ? AppColors.textMuted
                              : active
                              ? AppColors.aiPurple
                              : AppColors.textPrimary,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── AcSkeletonLoader ─────────────────────────────────────────────────────
class AcSkeletonBox extends StatefulWidget {
  const AcSkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
    this.isCircle = false,
  });

  final double? width;
  final double height;
  final double? borderRadius;
  final bool isCircle;

  @override
  State<AcSkeletonBox> createState() => _AcSkeletonBoxState();
}

class _AcSkeletonBoxState extends State<AcSkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pos;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _pos = Tween(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.isCircle
        ? widget.height / 2
        : (widget.borderRadius ?? AppRadius.xs);

    return AnimatedBuilder(
      animation: _pos,
      builder: (context, child) => Container(
        width: widget.isCircle ? widget.height : widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment(_pos.value - 1, 0),
            end: Alignment(_pos.value + 1, 0),
            colors: const [
              Color(0xFFE8EAED),
              Color(0xFFF5F5F5),
              Color(0xFFE8EAED),
            ],
          ),
        ),
      ),
    );
  }
}

class AcListSkeleton extends StatelessWidget {
  const AcListSkeleton({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xs,
            horizontal: AppSpacing.md,
          ),
          child: Row(
            children: [
              const AcSkeletonBox(height: 40, isCircle: true),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AcSkeletonBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 14,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AcSkeletonBox(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
