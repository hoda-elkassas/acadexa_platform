import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class GraduationReportsScreen extends StatefulWidget {
  const GraduationReportsScreen({super.key});

  @override
  State<GraduationReportsScreen> createState() => _GraduationReportsScreenState();
}

class _GraduationReportsScreenState extends State<GraduationReportsScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _students = [];
  String _filter = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final res = await _supabase.from('student_full_summary').select();
      _students = List<Map<String, dynamic>>.from(res as List);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() { _errorMessage = 'فشل تحميل البيانات: ${e.toString()}'; _isLoading = false; });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'الكل') return _students;
    if (_filter == 'مؤهل') {
      return _students.where((s) {
        final gpa = double.tryParse((s['calculated_gpa'] ?? s['cumulative_gpa'] ?? '0').toString()) ?? 0.0;
        return gpa >= 2.0;
      }).toList();
    }
    return _students.where((s) {
      final gpa = double.tryParse((s['calculated_gpa'] ?? s['cumulative_gpa'] ?? '0').toString()) ?? 0.0;
      return gpa < 2.0;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: AcLoadingState());
    if (_errorMessage.isNotEmpty) return AcErrorState(title: 'خطأ', message: _errorMessage, onRetry: _loadData);

    final filtered = _filtered;
    final eligible = _students.where((s) => (double.tryParse((s['calculated_gpa'] ?? s['cumulative_gpa'] ?? '0').toString()) ?? 0.0) >= 2.0).length;
    final atRisk = _students.length - eligible;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تقارير التخرج', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            Text('تحليل جاهزية الطلاب للتخرج', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xl),
            LayoutBuilder(
              builder: (ctx, constraints) {
                final isWide = constraints.maxWidth > 600;
                return GridView.count(
                  crossAxisCount: isWide ? 3 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                  childAspectRatio: isWide ? 1.3 : 1.15,
                  children: [
                    AcKpiCard(title: 'إجمالي الطلاب', value: '${_students.length}', icon: const Icon(Icons.people_rounded)),
                    AcKpiCard(title: 'مؤهل للتخرج', value: '$eligible', icon: const Icon(Icons.check_circle_rounded)),
                    AcKpiCard(title: 'بحاجة لمتابعة', value: '$atRisk', icon: const Icon(Icons.warning_rounded)),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                _buildFilterChip('الكل'),
                const SizedBox(width: AppSpacing.sm),
                _buildFilterChip('مؤهل'),
                const SizedBox(width: AppSpacing.sm),
                _buildFilterChip('بحاجة لمتابعة'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text('قائمة الطلاب (${filtered.length})', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            if (filtered.isEmpty)
              const AcEmptyState(title: 'لا يوجد طلاب', size: AcStateSize.small)
            else
              ...filtered.map((s) {
                final gpa = double.tryParse((s['calculated_gpa'] ?? s['cumulative_gpa'] ?? '0').toString()) ?? 0.0;
                final ready = gpa >= 2.0;
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.brCard, side: const BorderSide(color: AppColors.border)),
                  color: AppColors.surface,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: ready ? AppColors.success500.withValues(alpha: 0.1) : AppColors.danger500.withValues(alpha: 0.1),
                      child: Icon(ready ? Icons.check_rounded : Icons.close_rounded, color: ready ? AppColors.success500 : AppColors.danger500),
                    ),
                    title: Text(s['full_name']?.toString() ?? '-', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text('${s['department_name'] ?? '-'} | ${s['student_code'] ?? '-'}', style: AppTypography.bodySmall),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(gpa.toStringAsFixed(2), style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold, color: ready ? AppColors.success500 : AppColors.danger500)),
                        Text('GPA', style: AppTypography.caption),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final selected = _filter == label;
    return GestureDetector(
      onTap: () => setState(() => _filter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary500 : Colors.transparent,
          borderRadius: AppRadius.brPill,
          border: Border.all(color: selected ? AppColors.primary500 : AppColors.border),
        ),
        child: Text(label, style: AppTypography.labelSmall.copyWith(color: selected ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}
