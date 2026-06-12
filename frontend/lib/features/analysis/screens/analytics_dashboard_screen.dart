import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String _errorMessage = '';

  int _totalStudents = 0;
  double _avgGpa = 0.0;
  int _atRiskCount = 0;
  int _totalCourses = 0;
  List<Map<String, dynamic>> _departmentStats = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final studentsRes = await _supabase.from('student_full_summary').select();
      final students = List<Map<String, dynamic>>.from(studentsRes as List);
      _totalStudents = students.length;

      double gpaSum = 0.0;
      int atRisk = 0;
      for (final s in students) {
        final gpa = double.tryParse((s['calculated_gpa'] ?? s['cumulative_gpa'] ?? '0').toString()) ?? 0.0;
        gpaSum += gpa;
        if (gpa < 2.0) atRisk++;
      }
      _avgGpa = _totalStudents > 0 ? gpaSum / _totalStudents : 0.0;
      _atRiskCount = atRisk;

      final coursesRes = await _supabase.from('courses').select('id');
      _totalCourses = (coursesRes as List).length;

      final Map<String, Map<String, dynamic>> deptMap = {};
      for (final s in students) {
        final dName = s['department_name']?.toString() ?? 'غير محدد';
        deptMap.putIfAbsent(dName, () => {'count': 0, 'gpaSum': 0.0});
        deptMap[dName]!['count'] = (deptMap[dName]!['count'] as int) + 1;
        final gpa = double.tryParse((s['calculated_gpa'] ?? s['cumulative_gpa'] ?? '0').toString()) ?? 0.0;
        deptMap[dName]!['gpaSum'] = (deptMap[dName]!['gpaSum'] as double) + gpa;
      }
      _departmentStats = deptMap.entries.map((e) => {
        'name': e.key,
        'count': e.value['count'],
        'avgGpa': (e.value['count'] as int) > 0
            ? (e.value['gpaSum'] as double) / (e.value['count'] as int)
            : 0.0,
      }).toList();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() { _errorMessage = 'فشل تحميل التحليلات: ${e.toString()}'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: AcLoadingState());
    if (_errorMessage.isNotEmpty) return AcErrorState(title: 'خطأ', message: _errorMessage, onRetry: _loadAnalytics);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('لوحة التحليلات', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            Text('إحصائيات ومؤشرات الأداء الأكاديمي', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xl),
            LayoutBuilder(
              builder: (ctx, constraints) {
                final isWide = constraints.maxWidth > 600;
                return GridView.count(
                  crossAxisCount: isWide ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                  childAspectRatio: isWide ? 1.3 : 1.15,
                  children: [
                    AcKpiCard(title: 'إجمالي الطلاب', value: '$_totalStudents', icon: const Icon(Icons.people_rounded)),
                    AcKpiCard(title: 'متوسط المعدل', value: _avgGpa.toStringAsFixed(2), icon: const Icon(Icons.school_rounded)),
                    AcKpiCard(title: 'في خطر أكاديمي', value: '$_atRiskCount', icon: const Icon(Icons.warning_rounded)),
                    AcKpiCard(title: 'المقررات', value: '$_totalCourses', icon: const Icon(Icons.book_rounded)),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('إحصائيات الأقسام', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            if (_departmentStats.isEmpty)
              const AcEmptyState(title: 'لا توجد بيانات أقسام', size: AcStateSize.small)
            else
              ..._departmentStats.map((d) => Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.brCard, side: const BorderSide(color: AppColors.border)),
                color: AppColors.surface,
                child: ListTile(
                  title: Text(d['name'] as String, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${d['count']} طالب', style: AppTypography.bodySmall),
                      const SizedBox(width: AppSpacing.md),
                      AcAcademicChip(label: 'GPA', value: (d['avgGpa'] as double).toStringAsFixed(2), colorByValue: true),
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
