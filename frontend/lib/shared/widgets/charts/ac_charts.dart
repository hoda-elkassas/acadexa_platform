// file: lib/shared/widgets/charts/ac_charts.dart
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../states/ac_states.dart';
import '../cards/ac_card.dart';

// ─── Chart data models ────────────────────────────────────────────────────
class AcChartPoint {
  const AcChartPoint({required this.x, required this.y, this.label});
  final double x;
  final double y;
  final String? label;
}

class AcChartSeries {
  const AcChartSeries({required this.label, required this.points, this.color});
  final String label;
  final List<AcChartPoint> points;
  final Color? color;
}

class AcPieSlice {
  const AcPieSlice({required this.label, required this.value, this.color});
  final String label;
  final double value;
  final Color? color;
}

class AcHeatmapCell {
  const AcHeatmapCell({
    required this.row,
    required this.col,
    required this.value,
    this.label,
  });
  final int row;
  final int col;
  final double value; // normalized 0.0-1.0
  final String? label;
}

// ─── AcLineChart ──────────────────────────────────────────────────────────
class AcLineChart extends StatelessWidget {
  const AcLineChart({
    super.key,
    required this.series,
    this.title,
    this.xAxisLabel,
    this.yAxisLabel,
    this.height = 260,
    this.isLoading = false,
    this.isEmpty = false,
    this.showLegend = true,
    this.showGrid = true,
    this.onPointTap,
  });

  final List<AcChartSeries> series;
  final String? title;
  final String? xAxisLabel;
  final String? yAxisLabel;
  final double height;
  final bool isLoading;
  final bool isEmpty;
  final bool showLegend;
  final bool showGrid;
  final void Function(AcChartSeries series, AcChartPoint point)? onPointTap;

  @override
  Widget build(BuildContext context) {
    return _AcChartShell(
      title: title,
      height: height,
      isLoading: isLoading,
      isEmpty: isEmpty,
      legend: showLegend ? _buildLegend() : null,
      child: CustomPaint(
        painter: _LineChartPainter(series: series, showGrid: showGrid),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xxs,
      children: series.asMap().entries.map((e) {
        final color =
            e.value.color ??
            AppColors.chartPalette[e.key % AppColors.chartPalette.length];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 3,
              decoration: BoxDecoration(
                color: color,
                borderRadius: AppRadius.brPill,
              ),
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(e.value.label, style: AppTypography.caption),
          ],
        );
      }).toList(),
    );
  }
}

// ─── _LineChartPainter ────────────────────────────────────────────────────
class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.series, required this.showGrid});

  final List<AcChartSeries> series;
  final bool showGrid;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;

    final allPoints = series.expand((s) => s.points);
    if (allPoints.isEmpty) return;

    final minX = allPoints.map((p) => p.x).reduce((a, b) => a < b ? a : b);
    final maxX = allPoints.map((p) => p.x).reduce((a, b) => a > b ? a : b);
    final minY = allPoints.map((p) => p.y).reduce((a, b) => a < b ? a : b);
    final maxY = allPoints.map((p) => p.y).reduce((a, b) => a > b ? a : b);
    final rangeX = (maxX - minX).abs() < 0.0001 ? 1.0 : maxX - minX;
    final rangeY = (maxY - minY).abs() < 0.0001 ? 1.0 : maxY - minY;

    const padL = 40.0, padR = 16.0, padT = 12.0, padB = 32.0;
    final w = size.width - padL - padR;
    final h = size.height - padT - padB;

    Offset toOffset(double x, double y) => Offset(
      padL + ((x - minX) / rangeX) * w,
      padT + h - ((y - minY) / rangeY) * h,
    );

    // Grid
    if (showGrid) {
      final gridPaint = Paint()
        ..color = AppColors.border
        ..strokeWidth = 1;
      for (int i = 0; i <= 4; i++) {
        final dy = padT + (i / 4) * h;
        canvas.drawLine(Offset(padL, dy), Offset(padL + w, dy), gridPaint);
      }
    }

    // Lines + fill
    for (int si = 0; si < series.length; si++) {
      final s = series[si];
      if (s.points.isEmpty) continue;
      final color =
          s.color ?? AppColors.chartPalette[si % AppColors.chartPalette.length];

      final path = Path();
      final fill = Path();

      for (int i = 0; i < s.points.length; i++) {
        final off = toOffset(s.points[i].x, s.points[i].y);
        if (i == 0) {
          path.moveTo(off.dx, off.dy);
          fill.moveTo(off.dx, padT + h);
          fill.lineTo(off.dx, off.dy);
        } else {
          path.lineTo(off.dx, off.dy);
          fill.lineTo(off.dx, off.dy);
        }
      }

      // Close fill
      final last = toOffset(s.points.last.x, s.points.last.y);
      fill.lineTo(last.dx, padT + h);
      fill.close();

      canvas.drawPath(
        fill,
        Paint()
          ..color = color.withValues(alpha: 0.08)
          ..style = PaintingStyle.fill,
      );

      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      // Dots
      for (final p in s.points) {
        final off = toOffset(p.x, p.y);
        canvas.drawCircle(off, 4, Paint()..color = AppColors.surface);
        canvas.drawCircle(off, 3, Paint()..color = color);
      }
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) =>
      old.series != series || old.showGrid != showGrid;
}

// ─── AcBarChart ───────────────────────────────────────────────────────────
class AcBarChart extends StatelessWidget {
  const AcBarChart({
    super.key,
    required this.series,
    this.title,
    this.height = 260,
    this.isLoading = false,
    this.isEmpty = false,
    this.isHorizontal = false,
    this.showValues = false,
    this.showLegend = true,
    this.barRadius = AppRadius.xs,
    this.groupSpacing = 4.0,
  });

  final List<AcChartSeries> series;
  final String? title;
  final double height;
  final bool isLoading;
  final bool isEmpty;
  final bool isHorizontal;
  final bool showValues;
  final bool showLegend;
  final double barRadius;
  final double groupSpacing;

  @override
  Widget build(BuildContext context) {
    return _AcChartShell(
      title: title,
      height: height,
      isLoading: isLoading,
      isEmpty: isEmpty,
      child: CustomPaint(
        painter: _BarChartPainter(
          series: series,
          isHorizontal: isHorizontal,
          barRadius: barRadius,
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.series,
    required this.isHorizontal,
    required this.barRadius,
  });

  final List<AcChartSeries> series;
  final bool isHorizontal;
  final double barRadius;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;
    final allValues = series.expand((s) => s.points.map((p) => p.y));
    if (allValues.isEmpty) return;

    final maxY = allValues.reduce((a, b) => a > b ? a : b);
    if (maxY == 0) return;

    const padL = 40.0, padR = 16.0, padT = 12.0, padB = 32.0;
    final drawW = size.width - padL - padR;
    final drawH = size.height - padT - padB;

    final totalGroups = series.first.points.length;
    final seriesCount = series.length;
    final groupW = drawW / totalGroups;
    final barW = (groupW - 8) / seriesCount;

    for (int si = 0; si < series.length; si++) {
      final s = series[si];
      final color =
          s.color ?? AppColors.chartPalette[si % AppColors.chartPalette.length];

      for (int pi = 0; pi < s.points.length; pi++) {
        final value = s.points[pi].y;
        final barH = (value / maxY) * drawH;
        final left = padL + pi * groupW + si * barW + 4;
        final top = padT + drawH - barH;

        final rrect = RRect.fromRectAndCorners(
          Rect.fromLTWH(left, top, barW - 2, barH),
          topLeft: Radius.circular(barRadius),
          topRight: Radius.circular(barRadius),
        );
        canvas.drawRRect(rrect, Paint()..color = color);
      }
    }

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final dy = padT + (i / 4) * drawH;
      canvas.drawLine(Offset(padL, dy), Offset(padL + drawW, dy), gridPaint);
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => true;
}

// ─── AcDonutChart ─────────────────────────────────────────────────────────
class AcDonutChart extends StatelessWidget {
  const AcDonutChart({
    super.key,
    required this.slices,
    this.title,
    this.centerLabel,
    this.centerValue,
    this.size = 200,
    this.thickness = 32,
    this.isLoading = false,
    this.isEmpty = false,
    this.showLegend = true,
  });

  final List<AcPieSlice> slices;
  final String? title;
  final String? centerLabel;
  final String? centerValue;
  final double size;
  final double thickness;
  final bool isLoading;
  final bool isEmpty;
  final bool showLegend;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(height: size, child: const AcLoadingState());
    }

    if (isEmpty || slices.isEmpty) {
      return SizedBox(
        height: size,
        child: const AcEmptyState(title: 'لا توجد بيانات'),
      );
    }

    return Column(
      children: [
        if (title != null) ...[
          Text(title!, style: AppTypography.h5),
          const SizedBox(height: AppSpacing.md),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(size, size),
                    painter: _DonutPainter(
                      slices: slices,
                      thickness: thickness,
                    ),
                  ),
                  if (centerLabel != null || centerValue != null)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (centerValue != null)
                          Text(centerValue!, style: AppTypography.h3),
                        if (centerLabel != null)
                          Text(centerLabel!, style: AppTypography.caption),
                      ],
                    ),
                ],
              ),
            ),
            if (showLegend) ...[
              const SizedBox(width: AppSpacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: slices.asMap().entries.map((e) {
                  final color =
                      e.value.color ??
                      AppColors.chartPalette[e.key %
                          AppColors.chartPalette.length];
                  final total = slices.fold(0.0, (s, sl) => s + sl.value);
                  final pct = total > 0
                      ? (e.value.value / total * 100).round()
                      : 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xxs,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: AppRadius.brXs,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(e.value.label, style: AppTypography.bodySmall),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '$pct%',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.slices, required this.thickness});

  final List<AcPieSlice> slices;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold(0.0, (s, sl) => s + sl.value);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 4;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -3.14159 / 2;

    for (int i = 0; i < slices.length; i++) {
      final sweep = (slices[i].value / total) * 2 * 3.14159;
      final color =
          slices[i].color ??
          AppColors.chartPalette[i % AppColors.chartPalette.length];

      canvas.drawArc(
        rect,
        startAngle,
        sweep - 0.02,
        false,
        Paint()
          ..color = color
          ..strokeWidth = thickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.butt,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => true;
}

// ─── AcProgressChart ──────────────────────────────────────────────────────
class AcProgressChart extends StatelessWidget {
  const AcProgressChart({
    super.key,
    required this.label,
    required this.value, // 0.0 - 1.0
    this.subtitle,
    this.displayValue,
    this.color,
    this.height = 8,
    this.showValue = true,
  });

  final String label;
  final double value;
  final String? subtitle;
  final String? displayValue;
  final Color? color;
  final double height;
  final bool showValue;

  Color get _barColor {
    final c = color;
    if (c != null) return c;
    if (value >= 0.8) return AppColors.success500;
    if (value >= 0.5) return AppColors.warning500;
    return AppColors.danger500;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.labelMedium),
                if (subtitle != null)
                  Text(subtitle!, style: AppTypography.caption),
              ],
            ),
            if (showValue)
              Text(
                displayValue ?? '${(value * 100).round()}%',
                style: AppTypography.labelLarge.copyWith(
                  color: _barColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: AppRadius.brPill,
          child: Stack(
            children: [
              Container(
                height: height,
                width: double.infinity,
                color: AppColors.neutral200,
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                height: height,
                width: double.infinity,
                child: FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0),
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(color: _barColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── AcHeatmap ────────────────────────────────────────────────────────────
class AcHeatmap extends StatelessWidget {
  const AcHeatmap({
    super.key,
    required this.cells,
    required this.rowCount,
    required this.colCount,
    this.rowLabels,
    this.colLabels,
    this.title,
    this.colorStart = AppColors.primary100,
    this.colorEnd = AppColors.primary700,
    this.cellSize = 32,
    this.isLoading = false,
    this.onCellTap,
  });

  final List<AcHeatmapCell> cells;
  final int rowCount;
  final int colCount;
  final List<String>? rowLabels;
  final List<String>? colLabels;
  final String? title;
  final Color colorStart;
  final Color colorEnd;
  final double cellSize;
  final bool isLoading;
  final void Function(AcHeatmapCell cell)? onCellTap;

  Color _cellColor(double v) {
    return Color.lerp(colorStart, colorEnd, v) ?? colorStart;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const AcLoadingState();

    final map = <String, AcHeatmapCell>{};
    for (final c in cells) {
      map['${c.row}_${c.col}'] = c;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title!, style: AppTypography.h5),
          const SizedBox(height: AppSpacing.md),
        ],
        if (colLabels != null)
          Row(
            children: [
              if (rowLabels != null) const SizedBox(width: 64),
              ...List.generate(
                colCount,
                (ci) => SizedBox(
                  width: cellSize,
                  child: Text(
                    ci < colLabels!.length ? colLabels![ci] : '',
                    style: AppTypography.caption,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: AppSpacing.xxs),
        ...List.generate(rowCount, (ri) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              children: [
                if (rowLabels != null)
                  SizedBox(
                    width: 64,
                    child: Text(
                      ri < rowLabels!.length ? rowLabels![ri] : '',
                      style: AppTypography.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ...List.generate(colCount, (ci) {
                  final cell = map['${ri}_$ci'];
                  final value = cell?.value ?? 0.0;
                  return GestureDetector(
                    onTap: cell != null ? () => onCellTap?.call(cell) : null,
                    child: Tooltip(
                      message: cell?.label ?? '${(value * 100).round()}%',
                      child: Container(
                        width: cellSize,
                        height: cellSize,
                        margin: const EdgeInsets.only(left: 2),
                        decoration: BoxDecoration(
                          color: _cellColor(value),
                          borderRadius: AppRadius.brXs,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ─── AcKpiWidget ──────────────────────────────────────────────────────────
class AcKpiWidget extends StatelessWidget {
  const AcKpiWidget({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.trend,
    this.trendLabel,
    this.color,
    this.isLoading = false,
    this.onTap,
  });

  final String label;
  final String value;
  final String? unit;
  final double? trend; // positive / negative
  final String? trendLabel;
  final Color? color;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const AcKpiCardSkeleton();

    final c = color ?? AppColors.primary500;
    final isPositive = (trend ?? 0) >= 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.insetCard,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.brCard,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: AppTypography.displaySmall.copyWith(color: c),
                ),
                if (unit != null) ...[
                  const SizedBox(width: AppSpacing.xxs),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Text(
                      unit!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (trend != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Row(
                children: [
                  Icon(
                    isPositive
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 12,
                    color: isPositive
                        ? AppColors.success600
                        : AppColors.danger500,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${trend!.abs().toStringAsFixed(1)}%'
                    '${trendLabel != null ? " $trendLabel" : ""}',
                    style: AppTypography.caption.copyWith(
                      color: isPositive
                          ? AppColors.success600
                          : AppColors.danger500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── _AcChartShell (internal wrapper) ────────────────────────────────────
class _AcChartShell extends StatelessWidget {
  const _AcChartShell({
    required this.child,
    this.title,
    required this.height,
    required this.isLoading,
    required this.isEmpty,
    this.legend,
  });

  final Widget child;
  final String? title;
  final double height;
  final bool isLoading;
  final bool isEmpty;
  final Widget? legend;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title!, style: AppTypography.h5),
          const SizedBox(height: AppSpacing.sm),
        ],
        SizedBox(
          height: height,
          child: isLoading
              ? const AcLoadingState()
              : isEmpty
              ? const AcEmptyState(title: 'لا توجد بيانات')
              : child,
        ),
        if (legend != null) ...[const SizedBox(height: AppSpacing.sm), legend!],
      ],
    );
  }
}
