// file: lib/shared/widgets/chips/ac_chips.dart
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';

// ─── Chip size enum ───────────────────────────────────────────────────────
enum AcChipSize { small, medium }

// ─── AcStatusChip ─────────────────────────────────────────────────────────
enum AcStatusType {
  active,
  inactive,
  pending,
  warning,
  danger,
  info,
  ai,
  success,
}

class AcStatusChip extends StatelessWidget {
  const AcStatusChip({
    super.key,
    required this.label,
    required this.status,
    this.size = AcChipSize.small,
    this.showDot = true,
  });

  final String label;
  final AcStatusType status;
  final AcChipSize size;
  final bool showDot;

  Color get _bg => switch (status) {
    AcStatusType.active => AppColors.success50,
    AcStatusType.inactive => AppColors.neutral100,
    AcStatusType.pending => AppColors.warning50,
    AcStatusType.warning => AppColors.warning100,
    AcStatusType.danger => AppColors.danger50,
    AcStatusType.info => AppColors.info50,
    AcStatusType.ai => AppColors.aiPurpleLight,
    AcStatusType.success => AppColors.success50,
  };

  Color get _fg => switch (status) {
    AcStatusType.active => AppColors.success700,
    AcStatusType.inactive => AppColors.textSecondary,
    AcStatusType.pending => AppColors.warning700,
    AcStatusType.warning => AppColors.warning700,
    AcStatusType.danger => AppColors.danger700,
    AcStatusType.info => AppColors.info700,
    AcStatusType.ai => AppColors.aiPurple,
    AcStatusType.success => AppColors.success700,
  };

  @override
  Widget build(BuildContext context) {
    final hPad = size == AcChipSize.small ? AppSpacing.xs : AppSpacing.sm;
    final vPad = size == AcChipSize.small ? AppSpacing.xxs : AppSpacing.xs;
    final style = size == AcChipSize.small
        ? AppTypography.caption
        : AppTypography.labelSmall;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(color: _bg, borderRadius: AppRadius.brPill),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: _fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            label,
            style: style.copyWith(color: _fg, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ─── AcFilterChip ─────────────────────────────────────────────────────────
class AcFilterChip extends StatelessWidget {
  const AcFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.size = AcChipSize.medium,
    this.leadingIcon,
    this.count,
  });

  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final AcChipSize size;
  final Widget? leadingIcon;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      child: InkWell(
        onTap: () => onSelected(!isSelected),
        borderRadius: AppRadius.brPill,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: size == AcChipSize.small
                ? AppSpacing.xs
                : AppSpacing.sm,
            vertical: size == AcChipSize.small ? AppSpacing.xxs : AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary500 : AppColors.surface,
            borderRadius: AppRadius.brPill,
            border: Border.all(
              color: isSelected ? AppColors.primary500 : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                IconTheme(
                  data: IconThemeData(
                    size: 14,
                    color: isSelected
                        ? AppColors.neutral0
                        : AppColors.textSecondary,
                  ),
                  child: leadingIcon!,
                ),
                const SizedBox(width: AppSpacing.xxs),
              ],
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected
                      ? AppColors.neutral0
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: AppSpacing.xxs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.overlayLight
                        : AppColors.neutral200,
                    borderRadius: AppRadius.brPill,
                  ),
                  child: Text(
                    '$count',
                    style: AppTypography.caption.copyWith(
                      color: isSelected
                          ? AppColors.neutral0
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── AcAcademicChip ───────────────────────────────────────────────────────
/// For course grades, credit hours, GPA display
class AcAcademicChip extends StatelessWidget {
  const AcAcademicChip({
    super.key,
    required this.label,
    this.value,
    this.colorByValue = false,
    this.maxValue = 4.0,
  });

  final String label;
  final String? value;
  final bool colorByValue;
  final double maxValue;

  Color get _color {
    if (!colorByValue || value == null) return AppColors.primary500;
    final d = double.tryParse(value!) ?? 0;
    final ratio = d / maxValue;
    if (ratio >= 0.85) return AppColors.success600;
    if (ratio >= 0.65) return AppColors.warning600;
    return AppColors.danger500;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: AppRadius.brXs,
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (value != null) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
              width: 1,
              height: 10,
              color: AppColors.border,
            ),
            Text(
              value!,
              style: AppTypography.caption.copyWith(
                color: _color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── AcAiRecommendationChip ───────────────────────────────────────────────
class AcAiRecommendationChip extends StatelessWidget {
  const AcAiRecommendationChip({
    super.key,
    required this.label,
    this.confidence,
    this.onTap,
  });

  final String label;
  final double? confidence; // 0.0 - 1.0
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: AppColors.aiPurpleLight,
          borderRadius: AppRadius.brPill,
          border: Border.all(color: AppColors.aiPurple.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              size: 12,
              color: AppColors.aiPurple,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.aiPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (confidence != null) ...[
              const SizedBox(width: AppSpacing.xxs),
              Text(
                '${(confidence! * 100).round()}%',
                style: AppTypography.caption.copyWith(
                  color: AppColors.aiPurple.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── AcTag ────────────────────────────────────────────────────────────────
class AcTag extends StatelessWidget {
  const AcTag({super.key, required this.label, this.color, this.onRemove});

  final String label;
  final Color? color;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.neutral500;
    return Container(
      padding: EdgeInsets.only(
        right: AppSpacing.xs,
        left: onRemove != null ? AppSpacing.xxs : AppSpacing.xs,
        top: AppSpacing.xxs,
        bottom: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: AppRadius.brXs,
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: c,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 2),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close_rounded, size: 12, color: c),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── AcRiskBadge ──────────────────────────────────────────────────────────
enum AcRiskLevel { low, medium, high, critical }

class AcRiskBadge extends StatelessWidget {
  const AcRiskBadge({super.key, required this.level, this.showLabel = true});

  final AcRiskLevel level;
  final bool showLabel;

  String get _label => switch (level) {
    AcRiskLevel.low => 'منخفض',
    AcRiskLevel.medium => 'متوسط',
    AcRiskLevel.high => 'عالي',
    AcRiskLevel.critical => 'حرج',
  };

  Color get _color => switch (level) {
    AcRiskLevel.low => AppColors.success600,
    AcRiskLevel.medium => AppColors.warning600,
    AcRiskLevel.high => AppColors.danger500,
    AcRiskLevel.critical => AppColors.danger700,
  };

  Color get _bg => switch (level) {
    AcRiskLevel.low => AppColors.success50,
    AcRiskLevel.medium => AppColors.warning50,
    AcRiskLevel.high => AppColors.danger50,
    AcRiskLevel.critical => AppColors.danger100,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? AppSpacing.xs : AppSpacing.xxs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(color: _bg, borderRadius: AppRadius.brPill),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          if (showLabel) ...[
            const SizedBox(width: AppSpacing.xxs),
            Text(
              _label,
              style: AppTypography.caption.copyWith(
                color: _color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
