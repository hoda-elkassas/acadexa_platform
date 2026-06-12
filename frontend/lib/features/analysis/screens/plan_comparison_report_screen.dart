import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class PlanComparisonReportScreen extends StatefulWidget {
  const PlanComparisonReportScreen({super.key});

  @override
  State<PlanComparisonReportScreen> createState() => _PlanComparisonReportScreenState();
}

class _PlanComparisonReportScreenState extends State<PlanComparisonReportScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _plans = [];
  String? _planA;
  String? _planB;
  Map<String, dynamic>? _comparison;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final res = await _supabase.from('study_plans').select('id, name, department_id');
      _plans = List<Map<String, dynamic>>.from(res as List);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() { _errorMessage = 'فشل تحميل الخطط: ${e.toString()}'; _isLoading = false; });
    }
  }

  Future<void> _compare() async {
    if (_planA == null || _planB == null) return;
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final planARes = await _supabase.from('study_plans').select('*').eq('id', _planA!).single();
      final planBRes = await _supabase.from('study_plans').select('*').eq('id', _planB!).single();

      final coursesA = await _supabase.from('courses').select('code, credit_hours').eq('plan_id', _planA!);
      final coursesB = await _supabase.from('courses').select('code, credit_hours').eq('plan_id', _planB!);

      final listA = List<Map<String, dynamic>>.from(coursesA as List);
      final listB = List<Map<String, dynamic>>.from(coursesB as List);

      final codesA = listA.map((c) => c['code']?.toString()).toSet();
      final codesB = listB.map((c) => c['code']?.toString()).toSet();

      final common = codesA.intersection(codesB).length;
      final onlyA = codesA.difference(codesB).length;
      final onlyB = codesB.difference(codesA).length;
      final hoursA = listA.fold<int>(0, (sum, c) => sum + (int.tryParse(c['credit_hours']?.toString() ?? '0') ?? 0));
      final hoursB = listB.fold<int>(0, (sum, c) => sum + (int.tryParse(c['credit_hours']?.toString() ?? '0') ?? 0));

      setState(() {
        _comparison = {
          'planA': planARes,
          'planB': planBRes,
          'commonCourses': common,
          'onlyA': onlyA,
          'onlyB': onlyB,
          'totalHoursA': hoursA,
          'totalHoursB': hoursB,
          'totalCoursesA': listA.length,
          'totalCoursesB': listB.length,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _errorMessage = 'فشل المقارنة: ${e.toString()}'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _plans.isEmpty) return const Center(child: AcLoadingState());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('مقارنة الخطط الدراسية', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            Text('مقارنة خطتين دراسيتين', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xl),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brCard, side: const BorderSide(color: AppColors.border)),
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _planA,
                      decoration: const InputDecoration(labelText: 'الخطة الأولى'),
                      items: _plans.map((p) => DropdownMenuItem(value: p['id'] as String, child: Text(p['name']?.toString() ?? ''))).toList(),
                      onChanged: (v) => setState(() => _planA = v),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      value: _planB,
                      decoration: const InputDecoration(labelText: 'الخطة الثانية'),
                      items: _plans.map((p) => DropdownMenuItem(value: p['id'] as String, child: Text(p['name']?.toString() ?? ''))).toList(),
                      onChanged: (v) => setState(() => _planB = v),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AcButton(label: 'مقارنة', onPressed: _compare, isDisabled: _planA == null || _planB == null),
                  ],
                ),
              ),
            ),
            if (_comparison != null) ...[
              const SizedBox(height: AppSpacing.xl),
              Text('نتيجة المقارنة', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.md),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.brCard, side: const BorderSide(color: AppColors.border)),
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(children: [
                    _comparisonRow('إجمالي المقررات', '${_comparison!['totalCoursesA']}', '${_comparison!['totalCoursesB']}'),
                    _comparisonRow('إجمالي الساعات', '${_comparison!['totalHoursA']}', '${_comparison!['totalHoursB']}'),
                    _comparisonRow('مقررات مشتركة', '${_comparison!['commonCourses']}', '${_comparison!['commonCourses']}'),
                    _comparisonRow('مقررات فريدة', '${_comparison!['onlyA']}', '${_comparison!['onlyB']}'),
                  ]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _comparisonRow(String label, String valA, String valB) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(children: [
        Expanded(flex: 2, child: Text(label, style: AppTypography.bodyMedium)),
        Expanded(child: Text(valA, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary600), textAlign: TextAlign.center)),
        Expanded(child: Text(valB, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.secondary700), textAlign: TextAlign.center)),
      ]),
    );
  }
}
