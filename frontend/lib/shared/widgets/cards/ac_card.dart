// file: lib/shared/widgets/cards/ac_card.dart
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../core/themes/app_shadows.dart';

// ─── AcCard (base) ────────────────────────────────────────────────────────
class AcCard extends StatefulWidget {
  const AcCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.elevation = AcCardElevation.flat,
    this.hasBorder = true,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final AcCardElevation elevation;
  final bool hasBorder;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;

  @override
  State<AcCard> createState() => _AcCardState();
}

enum AcCardElevation { flat, raised, floating }

class _AcCardState extends State<AcCard> with SingleTickerProviderStateMixin {
  bool _hovered = false;

  List<BoxShadow> get _shadow {
    if (_hovered && widget.onTap != null) return AppShadows.lg;
    return switch (widget.elevation) {
      AcCardElevation.flat => AppShadows.none,
      AcCardElevation.raised => AppShadows.sm,
      AcCardElevation.floating => AppShadows.md,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.surface,
          borderRadius: widget.borderRadius ?? AppRadius.brCard,
          border: widget.hasBorder
              ? Border.all(
                  color:
                      widget.borderColor ??
                      (_hovered && widget.onTap != null
                          ? AppColors.primary300
                          : AppColors.border),
                  width: 1,
                )
              : null,
          boxShadow: _shadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: widget.borderRadius ?? AppRadius.brCard,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: widget.borderRadius ?? AppRadius.brCard,
            splashColor: AppColors.primary50,
            hoverColor: Colors.transparent,
            child: Padding(
              padding: widget.padding ?? AppSpacing.insetCard,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── AcKpiCard ────────────────────────────────────────────────────────────
class AcKpiCard extends StatelessWidget {
  const AcKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.trend,
    this.trendIsPositive,
    this.gradient,
    this.onTap,
    this.isLoading = false,
  });

  final String title;
  final String value;
  final Widget icon;
  final String? subtitle;
  final String? trend;
  final bool? trendIsPositive;
  final LinearGradient? gradient;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const AcKpiCardSkeleton();

    final useGradient = gradient != null;
    final textColor = useGradient ? AppColors.neutral0 : AppColors.textPrimary;
    final subtextColor = useGradient
        ? AppColors.neutral0.withValues(alpha: 0.8)
        : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.insetCard,
        decoration: BoxDecoration(
          gradient: gradient,
          color: useGradient ? null : AppColors.surface,
          borderRadius: AppRadius.brCard,
          border: useGradient ? null : Border.all(color: AppColors.border),
          boxShadow: useGradient ? AppShadows.primaryGlow : AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: useGradient
                        ? AppColors.overlayLight
                        : AppColors.primary50,
                    borderRadius: AppRadius.brSm,
                  ),
                  child: Center(
                    child: IconTheme(
                      data: IconThemeData(
                        size: 20,
                        color: useGradient
                            ? AppColors.neutral0
                            : AppColors.primary500,
                      ),
                      child: icon,
                    ),
                  ),
                ),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: useGradient
                          ? AppColors.overlayLight
                          : (trendIsPositive == true
                                ? AppColors.success50
                                : AppColors.danger50),
                      borderRadius: AppRadius.brPill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trendIsPositive == true
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 12,
                          color: useGradient
                              ? AppColors.neutral0
                              : (trendIsPositive == true
                                    ? AppColors.success600
                                    : AppColors.danger500),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          trend!,
                          style: AppTypography.caption.copyWith(
                            color: useGradient
                                ? AppColors.neutral0
                                : (trendIsPositive == true
                                      ? AppColors.success600
                                      : AppColors.danger500),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(value, style: AppTypography.h2.copyWith(color: textColor)),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              title,
              style: AppTypography.labelMedium.copyWith(color: subtextColor),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle!,
                style: AppTypography.caption.copyWith(
                  color: subtextColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── AcKpiCardSkeleton ───────────────────────────────────────────────────
class AcKpiCardSkeleton extends StatefulWidget {
  const AcKpiCardSkeleton({super.key});

  @override
  State<AcKpiCardSkeleton> createState() => _AcKpiCardSkeletonState();
}

class _AcKpiCardSkeletonState extends State<AcKpiCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _shimmer = Tween(begin: -2.0, end: 2.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, child) => Container(
        padding: AppSpacing.insetCard,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.brCard,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _shimmerBox(40, 40, borderRadius: AppRadius.brSm.topLeft.x),
                _shimmerBox(60, 22, borderRadius: 20),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _shimmerBox(double.infinity, 28),
            const SizedBox(height: AppSpacing.xs),
            _shimmerBox(120, 14),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(double w, double h, {double borderRadius = 8}) {
    return Container(
      width: w == double.infinity ? null : w,
      height: h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(_shimmer.value - 1, 0),
          end: Alignment(_shimmer.value + 1, 0),
          colors: const [
            Color(0xFFEEEEEE),
            Color(0xFFF8F8F8),
            Color(0xFFEEEEEE),
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// ─── AcInfoCard ───────────────────────────────────────────────────────────
class AcInfoCard extends StatelessWidget {
  const AcInfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.children = const [],
    this.onTap,
    this.badge,
    this.badgeColor,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget> children;
  final VoidCallback? onTap;
  final String? badge;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return AcCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(title, style: AppTypography.h5)),
                        if (badge != null) ...[
                          const SizedBox(width: AppSpacing.xs),
                          _Badge(label: badge!, color: badgeColor),
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        subtitle!,
                        style: AppTypography.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.xs),
                trailing!,
              ],
            ],
          ),
          if (children.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            ...children,
          ],
        ],
      ),
    );
  }
}

// ─── AcSectionCard ────────────────────────────────────────────────────────
class AcSectionCard extends StatelessWidget {
  const AcSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.padding,
    this.isLoading = false,
  });

  final String title;
  final Widget child;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsets? padding;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AcCard(
      padding: padding ?? AppSpacing.insetCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.h5),
                  if (subtitle != null)
                    Text(subtitle!, style: AppTypography.bodySmall),
                ],
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (isLoading) const _SectionLoader() else child,
        ],
      ),
    );
  }
}

class _SectionLoader extends StatelessWidget {
  const _SectionLoader();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 120,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary500,
        ),
      ),
    );
  }
}

// ─── _Badge ───────────────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  const _Badge({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary500;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: AppRadius.brPill,
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: c,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
