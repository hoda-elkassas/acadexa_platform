import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class PerformanceAnalysisScreen extends StatefulWidget {
  const PerformanceAnalysisScreen({super.key});

  @override
  State<PerformanceAnalysisScreen> createState() => _PerformanceAnalysisScreenState();
}

class _PerformanceAnalysisScreenState extends State<PerformanceAnalysisScreen> {
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
      final summaryRes = await _supabase.from('student_full_summary').select().eq('id', userId).maybeSingle();
      final semRes = await _supabase.from('student_semesters').select().eq('student_id', userId).order('semester_number');
      setState(() {
        _summary = summaryRes;
        _semesters = List<Map<String, dynamic>>.from(semRes as List);
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
    final gpAs = _semesters.map((s) => double.tryParse((s['semester_gpa'] ?? '0').toString()) ?? 0.0).toList();
    final trend = gpAs.isEmpty ? 'ثابت' : (gpAs.last > gpAs.first ? 'تصاعدي' : (gpAs.last < gpAs.first ? 'تنازلي' : 'ثابت'));
    final best = gpAs.isEmpty ? 0.0 : gpAs.reduce((a, b) => a > b ? a : b);
    final worst = gpAs.isEmpty ? 0.0 : gpAs.reduce((a, b) => a < b ? a : b);

    final trendSeries = [
      AcChartSeries(
        label: 'المعدل الفصلي',
        color: AppColors.primary500,
        points: gpAs.asMap().entries.map((e) => AcChartPoint(x: e.key.toDouble(), y: e.value)).toList(),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تحليل الأداء', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            Text('تحليل إحصائي للأداء الأكاديمي', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xl),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brCard, side: const BorderSide(color: AppColors.border)),
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    _statItem('الاتجاه', trend, trend == 'تصاعدي' ? AppColors.success500 : (trend == 'تنازلي' ? AppColors.danger500 : AppColors.warning500)),
                    _statItem('أعلى معدل', best.toStringAsFixed(2), AppColors.success500),
                    _statItem('أدنى معدل', worst.toStringAsFixed(2), AppColors.danger500),
                  ]),
                  const SizedBox(height: AppSpacing.md),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    _statItem('التراكمي', gpa.toStringAsFixed(2), AppColors.primary600),
                    _statItem('عدد الفصول', '${_semesters.length}', AppColors.secondary700),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('منحنى الأداء', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brCard, side: const BorderSide(color: AppColors.border)),
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: AcLineChart(series: trendSeries, height: 220, isEmpty: gpAs.isEmpty, showLegend: false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(children: [
      Text(value, style: AppTypography.h4.copyWith(color: color, fontWeight: FontWeight.bold)),
      const SizedBox(height: AppSpacing.xxs),
      Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
    ]);
  }
}
