// file: lib/features/advisor/screens/at_risk_students_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../students/screens/student_details_screen.dart';

class AtRiskStudentsScreen extends StatefulWidget {
  const AtRiskStudentsScreen({super.key});

  @override
  State<AtRiskStudentsScreen> createState() => _AtRiskStudentsScreenState();
}

class _AtRiskStudentsScreenState extends State<AtRiskStudentsScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _atRiskStudents = [];

  @override
  void initState() {
    super.initState();
    _loadAtRiskStudents();
  }

  Future<void> _loadAtRiskStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final res = await _supabase.from('student_full_summary').select();
      final allStudents = List<Map<String, dynamic>>.from(res as List);

      // Filter: GPA < 2.0 or has critical standing
      _atRiskStudents = allStudents.where((s) {
        final gpaVal = s['calculated_gpa'] ?? s['cumulative_gpa'];
        final gpa = double.tryParse(gpaVal?.toString() ?? '') ?? 0.0;
        return gpa < 2.0 && gpa > 0;
      }).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل تحميل الطلاب المتعثرين: ${e.toString()}';
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
        title: 'خطأ تحميل الطلاب',
        message: _errorMessage,
        onRetry: _loadAtRiskStudents,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الطلاب الخاضعين للمتابعة الأكاديمية العاجلة',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'يتم عرض الطلاب الذين يقل معدلهم التراكمي عن 2.00 (حالة الإنذار الأكاديمي).',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: _atRiskStudents.isEmpty
                  ? const Center(
                      child: AcEmptyState(
                        title: 'لا يوجد طلاب متعثرين حالياً',
                        message: 'جميع طلابك المقيدين في حالة أكاديمية ممتازة.',
                        icon: Icon(Icons.check_circle_outline_rounded, color: AppColors.success500, size: 48),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _atRiskStudents.length,
                      itemBuilder: (context, index) {
                        final student = _atRiskStudents[index];
                        final gpaVal = student['calculated_gpa'] ?? student['cumulative_gpa'];
                        final gpa = double.tryParse(gpaVal?.toString() ?? '') ?? 0.0;

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.brCard,
                            side: BorderSide(color: AppColors.danger200),
                          ),
                          color: AppColors.danger500.withValues(alpha: 0.02),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.danger500.withValues(alpha: 0.1),
                                  child: Text(
                                    (student['name']?.toString() ?? 'U').substring(0, 1).toUpperCase(),
                                    style: AppTypography.labelLarge.copyWith(
                                      color: AppColors.danger600,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student['name']?.toString() ?? '',
                                        style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'البرنامج: ${student['program_name'] ?? student['department_name'] ?? "-"}',
                                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'المعدل: ${gpa.toStringAsFixed(2)}',
                                      style: AppTypography.labelLarge.copyWith(
                                        color: AppColors.danger600,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    AcButton(
                                      label: 'إرشاد الطالب',
                                      variant: AcButtonVariant.danger,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => StudentDetailsScreen(studentSummary: student),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
