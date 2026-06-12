import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class AcademicSummaryScreen extends StatefulWidget {
  const AcademicSummaryScreen({super.key});

  @override
  State<AcademicSummaryScreen> createState() => _AcademicSummaryScreenState();
}

class _AcademicSummaryScreenState extends State<AcademicSummaryScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _summary;
  List<Map<String, dynamic>> _semesters = [];

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
      setState(() { _errorMessage = 'فشل تحميل الملخص: ${e.toString()}'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: AcLoadingState());
    if (_errorMessage.isNotEmpty) return AcErrorState(title: 'خطأ', message: _errorMessage, onRetry: _loadData);

    final gpa = double.tryParse((_summary?['calculated_gpa'] ?? _summary?['cumulative_gpa'] ?? '0').toString()) ?? 0.0;
    final completed = int.tryParse(_summary?['total_passed_hours']?.toString() ?? '0') ?? 0;
    final required = int.tryParse(_summary?['total_credit_hours']?.toString() ?? '136') ?? 136;
    final name = _summary?['full_name']?.toString() ?? '-';
    final code = _summary?['student_code']?.toString() ?? '-';
    final dept = _summary?['department_name']?.toString() ?? '-';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الملخص الأكاديمي', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.xl),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brCard, side: const BorderSide(color: AppColors.border)),
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(children: [
                  Row(children: [
                    Expanded(child: _infoTile('الاسم', name)),
                    Expanded(child: _infoTile('الكود', code)),
                  ]),
                  const SizedBox(height: AppSpacing.md),
                  Row(children: [
                    Expanded(child: _infoTile('القسم', dept)),
                    Expanded(child: _infoTile('المستوى', _summary?['study_level']?.toString() ?? '-')),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            LayoutBuilder(
              builder: (ctx, constraints) {
                final isWide = constraints.maxWidth > 600;
                return GridView.count(
                  crossAxisCount: isWide ? 3 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                  childAspectRatio: isWide ? 1.5 : 1.2,
                  children: [
                    AcKpiCard(title: 'المعدل التراكمي', value: gpa.toStringAsFixed(2), icon: const Icon(Icons.school_rounded)),
                    AcKpiCard(title: 'الساعات المكتملة', value: '$completed', icon: const Icon(Icons.check_circle_rounded)),
                    AcKpiCard(title: 'الساعات المتبقية', value: '${required - completed}', icon: const Icon(Icons.pending_rounded)),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('الفصول الدراسية', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
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
                  subtitle: Text('السنة: ${s['academic_year'] ?? '-'}', style: AppTypography.bodySmall),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(double.tryParse((s['semester_gpa'] ?? '0').toString())?.toStringAsFixed(2) ?? '-', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary600)),
                      Text('GPA', style: AppTypography.caption),
                    ],
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
      const SizedBox(height: AppSpacing.xxs),
      Text(value, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
    ]);
  }
}
