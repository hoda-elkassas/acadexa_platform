// file: lib/features/transcript/screens/plan_compliance_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class PlanComplianceScreen extends StatefulWidget {
  const PlanComplianceScreen({super.key});

  @override
  State<PlanComplianceScreen> createState() => _PlanComplianceScreenState();
}

class _PlanComplianceScreenState extends State<PlanComplianceScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  Map<String, dynamic>? _summary;
  List<Map<String, dynamic>> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id ?? '';
      final summaryRes = await _supabase.from('student_full_summary').select().eq('id', userId).maybeSingle();
      final coursesRes = await _supabase.from('student_courses').select().eq('student_id', userId);

      setState(() {
        _summary = summaryRes;
        _courses = List<Map<String, dynamic>>.from(coursesRes as List);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: AcLoadingState());
    }

    final completed = int.tryParse(_summary?['total_passed_hours']?.toString() ?? '0') ?? 0;
    final required = int.tryParse(_summary?['total_credit_hours']?.toString() ?? '136') ?? 136;
    final progress = required > 0 ? completed / required : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مطابقة الخطة الدراسية',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'مقارنة المقررات المسجلة والمكتملة مع متطلبات الخطة الدراسية.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Progress indicator
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('نسبة الإنجاز', style: AppTypography.labelLarge),
                        Text(
                          '${(progress * 100).toStringAsFixed(1)}%',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.primary600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor: AppColors.neutral100,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 0.75 ? AppColors.success500 : AppColors.primary500,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '$completed من $required ساعة مكتملة',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Courses list
            Text(
              'المقررات المسجلة (${_courses.length})',
              style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_courses.isEmpty)
              const AcEmptyState(
                title: 'لا توجد مقررات',
                message: 'لم يتم تسجيل أي مقررات بعد.',
              )
            else
              ...List.generate(_courses.length, (i) {
                final c = _courses[i];
                final grade = c['grade_letter']?.toString() ?? '-';
                final passed = grade != '-' && grade != 'F' && grade != 'DN';

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.brCard,
                    side: BorderSide(color: AppColors.border),
                  ),
                  color: AppColors.surface,
                  child: ListTile(
                    leading: Icon(
                      passed ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                      color: passed ? AppColors.success500 : AppColors.neutral300,
                    ),
                    title: Text(
                      '${c['course_code'] ?? ''} - ${c['course_name'] ?? ''}',
                      style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${c['credit_hours'] ?? 3} ساعات',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: passed
                            ? AppColors.success500.withValues(alpha: 0.1)
                            : AppColors.neutral100,
                        borderRadius: AppRadius.brPill,
                      ),
                      child: Text(
                        grade,
                        style: AppTypography.labelMedium.copyWith(
                          color: passed ? AppColors.success600 : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
