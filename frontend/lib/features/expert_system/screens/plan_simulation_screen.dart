// file: lib/features/expert_system/screens/plan_simulation_screen.dart
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class PlanSimulationScreen extends StatefulWidget {
  const PlanSimulationScreen({super.key});

  @override
  State<PlanSimulationScreen> createState() => _PlanSimulationScreenState();
}

class _PlanSimulationScreenState extends State<PlanSimulationScreen> {
  int _selectedHours = 15;
  double _targetGpa = 3.0;
  bool _showResults = false;

  final List<Map<String, dynamic>> _simulatedCourses = [
    {'code': 'CS401', 'name': 'نظم التشغيل', 'hours': 3, 'expectedGrade': 'B+'},
    {'code': 'CS445', 'name': 'الذكاء الاصطناعي', 'hours': 3, 'expectedGrade': 'A-'},
    {'code': 'CS480', 'name': 'أمن المعلومات', 'hours': 3, 'expectedGrade': 'B'},
    {'code': 'MATH301', 'name': 'الإحصاء التطبيقي', 'hours': 3, 'expectedGrade': 'A'},
    {'code': 'CS499', 'name': 'مشروع التخرج', 'hours': 3, 'expectedGrade': 'A-'},
  ];

  void _runSimulation() {
    setState(() => _showResults = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'محاكاة الخطة الدراسية',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'قم بتجربة سيناريوهات مختلفة لتسجيل المقررات ومعرفة تأثيرها على معدلك التراكمي.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Simulation Controls ─────────────────────
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
                      'إعدادات المحاكاة',
                      style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Hours slider
                    Row(
                      children: [
                        Text('عدد الساعات:', style: AppTypography.bodyMedium),
                        const Spacer(),
                        Text(
                          '$_selectedHours ساعة',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.primary600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _selectedHours.toDouble(),
                      min: 9,
                      max: 21,
                      divisions: 12,
                      activeColor: AppColors.primary500,
                      onChanged: (v) => setState(() => _selectedHours = v.toInt()),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Target GPA slider
                    Row(
                      children: [
                        Text('المعدل المستهدف:', style: AppTypography.bodyMedium),
                        const Spacer(),
                        Text(
                          _targetGpa.toStringAsFixed(2),
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.success600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _targetGpa,
                      min: 1.0,
                      max: 4.0,
                      divisions: 30,
                      activeColor: AppColors.success500,
                      onChanged: (v) => setState(() => _targetGpa = v),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    SizedBox(
                      width: double.infinity,
                      child: AcButton(
                        label: 'تشغيل المحاكاة',
                        variant: AcButtonVariant.primary,
                        onPressed: _runSimulation,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Results ─────────────────────────────────
            if (_showResults) ...[
              // Summary KPIs
              Row(
                children: [
                  Expanded(
                    child: _buildResultCard(
                      'المعدل المتوقع',
                      '3.52',
                      Icons.trending_up_rounded,
                      AppColors.success500,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildResultCard(
                      'ساعات مكتملة',
                      '${100 + _selectedHours}/136',
                      Icons.school_rounded,
                      AppColors.primary500,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildResultCard(
                      'فصول متبقية',
                      '2',
                      Icons.calendar_today_rounded,
                      AppColors.warning500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Course table
              Text(
                'المقررات المقترحة للفصل',
                style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              ...List.generate(_simulatedCourses.length, (i) {
                final c = _simulatedCourses[i];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.brCard,
                    side: BorderSide(color: AppColors.border),
                  ),
                  color: AppColors.surface,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary500.withValues(alpha: 0.1),
                      child: Text(
                        '${i + 1}',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.primary600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      '${c['code']} - ${c['name']}',
                      style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${c['hours']} ساعات معتمدة',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success500.withValues(alpha: 0.1),
                        borderRadius: AppRadius.brPill,
                      ),
                      child: Text(
                        c['expectedGrade'],
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.success600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      color: color.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTypography.titleMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
