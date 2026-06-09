// file: lib/features/reports/screens/reports_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class ReportsDashboardScreen extends StatefulWidget {
  const ReportsDashboardScreen({super.key});

  @override
  State<ReportsDashboardScreen> createState() => _ReportsDashboardScreenState();
}

class _ReportsDashboardScreenState extends State<ReportsDashboardScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String _errorMessage = '';

  int _totalStudents = 0;
  double _avgGpa = 0.0;
  int _atRiskCount = 0;
  int _excellentCount = 0;

  List<AcPieSlice> _statusSlices = [];
  List<AcChartSeries> _gpaTrendSeries = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final res = await _supabase.from('student_full_summary').select();
      final students = List<Map<String, dynamic>>.from(res as List);

      _totalStudents = students.length;

      double gpaSum = 0.0;
      int gpaCount = 0;
      int risk = 0;
      int excellent = 0;
      int good = 0;

      for (final s in students) {
        final gpaVal = s['calculated_gpa'] ?? s['cumulative_gpa'];
        final gpa = double.tryParse(gpaVal?.toString() ?? '') ?? 0.0;
        if (gpa > 0) {
          gpaSum += gpa;
          gpaCount++;
          if (gpa < 2.0) {
            risk++;
          } else if (gpa >= 3.5) {
            excellent++;
          } else if (gpa >= 3.0) {
            excellent++; // Good / Excellent
          } else {
            good++;
          }
        }
      }

      _avgGpa = gpaCount > 0 ? (gpaSum / gpaCount) : 0.0;
      _atRiskCount = risk;
      _excellentCount = excellent;

      // Slice data for status breakdown
      _statusSlices = [
        AcPieSlice(
          label: 'متفوق (>= 3.5)',
          value: _excellentCount.toDouble(),
          color: AppColors.success500,
        ),
        AcPieSlice(
          label: 'جيد جداً / جيد (2.0 - 3.5)',
          value: good.toDouble(),
          color: AppColors.primary500,
        ),
        AcPieSlice(
          label: 'متعثر (< 2.0)',
          value: _atRiskCount.toDouble(),
          color: AppColors.danger500,
        ),
      ];

      // GPA Trend mock series for showcase
      _gpaTrendSeries = [
        const AcChartSeries(
          label: 'متوسط دفعة 2024',
          points: [
            AcChartPoint(x: 1, y: 2.8, label: 'الفصل 1'),
            AcChartPoint(x: 2, y: 2.9, label: 'الفصل 2'),
            AcChartPoint(x: 3, y: 3.1, label: 'الفصل 3'),
            AcChartPoint(x: 4, y: 3.2, label: 'الفصل 4'),
          ],
          color: AppColors.primary500,
        ),
        const AcChartSeries(
          label: 'متوسط دفعة 2025',
          points: [
            AcChartPoint(x: 1, y: 2.6, label: 'الفصل 1'),
            AcChartPoint(x: 2, y: 2.75, label: 'الفصل 2'),
            AcChartPoint(x: 3, y: 2.9, label: 'الفصل 3'),
            AcChartPoint(x: 4, y: 3.05, label: 'الفصل 4'),
          ],
          color: AppColors.secondary500,
        ),
      ];

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل تحميل بيانات التقارير: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: AcLoadingState());
    }

    if (_errorMessage.isNotEmpty) {
      return AcErrorState(
        title: 'خطأ في جلب الإحصاءات',
        message: _errorMessage,
        onRetry: _loadStats,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── KPI Widgets Row ──────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: AcKpiWidget(
                  label: 'إجمالي الطلاب المقيدين',
                  value: '$_totalStudents',
                  unit: 'طالب',
                  trend: 4.8,
                  trendLabel: 'نمو هذا الفصل',
                  color: AppColors.primary500,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AcKpiWidget(
                  label: 'متوسط المعدل التراكمي',
                  value: _avgGpa.toStringAsFixed(2),
                  unit: 'GPA',
                  trend: 1.2,
                  trendLabel: 'مقارنة بالفصل الماضي',
                  color: AppColors.success500,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AcKpiWidget(
                  label: 'الطلاب المتعثرين',
                  value: '$_atRiskCount',
                  unit: 'طالب',
                  trend: -12.5,
                  trendLabel: 'انخفاض في نسبة الخطر',
                  color: AppColors.danger500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ─── Charts Row ──────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GPA Trend Line Chart
              Expanded(
                flex: 3,
                child: Card(
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.brCard,
                    side: BorderSide(color: AppColors.border),
                  ),
                  color: AppColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تطور متوسط المعدل التراكمي حسب الدفعات والفصول الدراسية',
                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AcLineChart(
                          series: _gpaTrendSeries,
                          height: 250,
                          xAxisLabel: 'الفصل الدراسي',
                          yAxisLabel: 'المعدل التراكمي',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),

              // Student performance status Pie Chart
              Expanded(
                flex: 2,
                child: Card(
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.brCard,
                    side: BorderSide(color: AppColors.border),
                  ),
                  color: AppColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'توزيع الأداء الأكاديمي للطلاب',
                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AcDonutChart(
                          slices: _statusSlices,
                          size: 160,
                          thickness: 24,
                          centerLabel: 'إجمالي الحالات',
                          centerValue: '$_totalStudents',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ─── Program Performance summary ─────────────────────────────
          Card(
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.brCard,
              side: BorderSide(color: AppColors.border),
            ),
            color: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'معدلات النجاح والإنجاز الأكاديمي حسب البرامج',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const AcProgressChart(
                    label: 'برنامج بكالوريوس علوم الحاسب',
                    value: 0.88,
                    subtitle: 'معدل اجتياز المقررات التخصصية',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const AcProgressChart(
                    label: 'برنامج بكالوريوس تقنية المعلومات',
                    value: 0.82,
                    subtitle: 'معدل اجتياز المقررات التخصصية',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const AcProgressChart(
                    label: 'برنامج بكالوريوس نظم المعلومات',
                    value: 0.74,
                    subtitle: 'معدل اجتياز المقررات التخصصية',
                    color: AppColors.warning500,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
