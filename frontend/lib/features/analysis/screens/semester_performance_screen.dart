import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class SemesterPerformanceScreen extends StatefulWidget {
  const SemesterPerformanceScreen({super.key});

  @override
  State<SemesterPerformanceScreen> createState() => _SemesterPerformanceScreenState();
}

class _SemesterPerformanceScreenState extends State<SemesterPerformanceScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _semesters = [];
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final userId = _supabase.auth.currentUser?.id ?? '';
      final summary = await _supabase.from('student_full_summary').select().eq('id', userId).maybeSingle();
      final sems = await _supabase.from('student_semesters').select().eq('student_id', userId).order('semester_number');

      setState(() {
        _summary = summary;
        _semesters = List<Map<String, dynamic>>.from(sems as List);
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _errorMessage = 'فشل تحميل البيانات: ${e.toString()}'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: AcLoadingState());
    if (_errorMessage.isNotEmpty) return AcErrorState(title: 'خطأ', message: _errorMessage, onRetry: _loadData);

    final gpa = double.tryParse((_summary?['calculated_gpa'] ?? _summary?['cumulative_gpa'] ?? '0').toString()) ?? 0.0;

    final trendSeries = [
      AcChartSeries(
        label: 'المعدل الفصلي',
        color: AppColors.primary500,
        points: _semesters.asMap().entries.map((e) =>
          AcChartPoint(
            x: e.key.toDouble(),
            y: double.tryParse((e.value['semester_gpa'] ?? '0').toString()) ?? 0.0,
          ),
        ).toList(),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الأداء الفصلي', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            Text('تحليل الأداء عبر الفصول الدراسية', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xl),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brCard, side: const BorderSide(color: AppColors.border)),
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(children: [
                      Text('المعدل التراكمي', style: AppTypography.bodySmall),
                      const SizedBox(height: AppSpacing.xs),
                      Text(gpa.toStringAsFixed(2), style: AppTypography.h3.copyWith(color: AppColors.primary600, fontWeight: FontWeight.bold)),
                    ]),
                    Column(children: [
                      Text('عدد الفصول', style: AppTypography.bodySmall),
                      const SizedBox(height: AppSpacing.xs),
                      Text('${_semesters.length}', style: AppTypography.h3.copyWith(color: AppColors.primary600, fontWeight: FontWeight.bold)),
                    ]),
                    Column(children: [
                      Text('أعلى معدل فصلي', style: AppTypography.bodySmall),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _semesters.isEmpty ? '-' : _semesters.map((s) => double.tryParse((s['semester_gpa'] ?? '0').toString()) ?? 0.0).reduce((a, b) => a > b ? a : b).toStringAsFixed(2),
                        style: AppTypography.h3.copyWith(color: AppColors.success500, fontWeight: FontWeight.bold),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('اتجاه المعدل', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brCard, side: const BorderSide(color: AppColors.border)),
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: AcLineChart(series: trendSeries, height: 220, isEmpty: _semesters.isEmpty, showLegend: false),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('تفاصيل الفصول', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            if (_semesters.isEmpty)
              const AcEmptyState(title: 'لا توجد فصول', size: AcStateSize.small)
            else
              ..._semesters.map((s) => Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.brCard, side: const BorderSide(color: AppColors.border)),
                color: AppColors.surface,
                child: ListTile(
                  title: Text('الفصل ${s['semester_number']}', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text(s['academic_year']?.toString() ?? '', style: AppTypography.bodySmall),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('المعدل:', style: AppTypography.bodySmall),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        double.tryParse((s['semester_gpa'] ?? '0').toString())?.toStringAsFixed(2) ?? '-',
                        style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary600),
                      ),
                    ],
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }
}
