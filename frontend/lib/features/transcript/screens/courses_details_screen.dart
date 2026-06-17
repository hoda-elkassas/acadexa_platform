import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class CoursesDetailsScreen extends StatefulWidget {
  const CoursesDetailsScreen({super.key});

  @override
  State<CoursesDetailsScreen> createState() => _CoursesDetailsScreenState();
}

class _CoursesDetailsScreenState extends State<CoursesDetailsScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final userId = _supabase.auth.currentUser?.id ?? '';
      final coursesRes = await _supabase.from('student_courses').select().eq('student_id', userId);
      setState(() {
        _courses = List<Map<String, dynamic>>.from(coursesRes as List);
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

    final passed = _courses.where((c) {
      final grade = c['grade_letter']?.toString() ?? '';
      return grade.isNotEmpty && grade != 'F' && grade != 'DN' && grade != 'W';
    }).length;
    final failed = _courses.length - passed;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تفاصيل المقررات', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            Text('جميع المقررات المسجلة والدرجات', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xl),
            Row(children: [
              Expanded(child: AcKpiCard(title: 'إجمالي المقررات', value: '${_courses.length}', icon: const Icon(Icons.menu_book_rounded))),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: AcKpiCard(title: 'مكتمل', value: '$passed', icon: const Icon(Icons.check_circle_rounded))),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: AcKpiCard(title: 'لم يجتاز', value: '$failed', icon: const Icon(Icons.cancel_rounded))),
            ]),
            const SizedBox(height: AppSpacing.lg),
            Text('قائمة المقررات (${_courses.length})', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            if (_courses.isEmpty)
              const AcEmptyState(title: 'لا توجد مقررات', size: AcStateSize.small)
            else
              ..._courses.map((c) {
                final grade = c['grade_letter']?.toString() ?? '-';
                final isPassed = grade.isNotEmpty && grade != 'F' && grade != 'DN' && grade != 'W';
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.brCard, side: const BorderSide(color: AppColors.border)),
                  color: AppColors.surface,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isPassed ? AppColors.success500.withValues(alpha: 0.1) : AppColors.danger500.withValues(alpha: 0.1),
                      child: Icon(isPassed ? Icons.check_rounded : Icons.close_rounded, color: isPassed ? AppColors.success500 : AppColors.danger500, size: 20),
                    ),
                    title: Text('${c['course_code'] ?? ''} - ${c['course_name'] ?? ''}', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text('${c['credit_hours'] ?? 3} ساعات', style: AppTypography.bodySmall),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPassed ? AppColors.success500.withValues(alpha: 0.1) : AppColors.danger500.withValues(alpha: 0.1),
                        borderRadius: AppRadius.brPill,
                      ),
                      child: Text(grade, style: AppTypography.labelMedium.copyWith(color: isPassed ? AppColors.success600 : AppColors.danger500, fontWeight: FontWeight.bold)),
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
