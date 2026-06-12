// file: lib/features/expert_system/screens/plan_simulation_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final _supabase = Supabase.instance.client;

  bool _isLoading = true;
  String _errorMessage = '';
  double _currentGpa = 0.0;
  int _completedHours = 0;
  int _totalRequiredHours = 136;

  int _selectedHours = 15;
  double _targetGpa = 3.0;
  bool _showResults = false;
  double _targetSemesterGpa = 0.0;
  double _expectedCumulativeGpa = 0.0;
  int _remainingSemesters = 0;

  final List<Map<String, dynamic>> _simulatedCourses = [];

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final res = await _supabase
            .from('student_full_summary')
            .select('calculated_gpa, total_passed_hours, total_credit_hours')
            .eq('id', user.id)
            .single();

        if (mounted) {
          setState(() {
            _currentGpa = double.tryParse((res['calculated_gpa'] ?? '0').toString()) ?? 0.0;
            _completedHours = int.tryParse((res['total_passed_hours'] ?? '0').toString()) ?? 0;
            _totalRequiredHours = int.tryParse((res['total_credit_hours'] ?? '136').toString()) ?? 136;
            _targetGpa = _currentGpa > 0 ? _currentGpa : 3.0;
          });
        }
      }
    } catch (e) {
      // Keep defaults on error
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  void _runSimulation() {
    final double currentTotalPoints = _currentGpa * _completedHours;
    final int newTotalHours = _completedHours + _selectedHours;
    
    // Maximum possible GPA if student gets 4.0 this semester
    final double maxPossibleGpa = (currentTotalPoints + (4.0 * _selectedHours)) / newTotalHours;
    
    if (_targetGpa > maxPossibleGpa) {
      _targetSemesterGpa = 4.0;
      _expectedCumulativeGpa = maxPossibleGpa;
    } else {
      _targetSemesterGpa = ((_targetGpa * newTotalHours) - currentTotalPoints) / _selectedHours;
      if (_targetSemesterGpa < 1.0) _targetSemesterGpa = 1.0;
      _expectedCumulativeGpa = _targetGpa;
    }

    final remainingHours = _totalRequiredHours - newTotalHours;
    _remainingSemesters = remainingHours <= 0 ? 0 : (remainingHours / 15.0).ceil();

    // Generate courses dynamically based on _selectedHours
    final int courseCount = (_selectedHours / 3).round();
    _simulatedCourses.clear();
    
    // Distribute targetSemesterGpa into grades
    final gradesMap = [
      {'letter': 'A', 'points': 4.0},
      {'letter': 'A-', 'points': 3.75},
      {'letter': 'B+', 'points': 3.5},
      {'letter': 'B', 'points': 3.0},
      {'letter': 'C+', 'points': 2.5},
      {'letter': 'C', 'points': 2.0},
      {'letter': 'D', 'points': 1.0},
      {'letter': 'F', 'points': 0.0},
    ];

    // Find the closest grade for targetSemesterGpa
    final closestGrade = gradesMap.firstWhere(
      (g) => (g['points'] as double) <= _targetSemesterGpa,
      orElse: () => gradesMap.last,
    );

    final subjects = [
      {'code': 'CS401', 'name': 'نظم التشغيل'},
      {'code': 'CS445', 'name': 'الذكاء الاصطناعي'},
      {'code': 'CS480', 'name': 'أمن المعلومات'},
      {'code': 'MATH301', 'name': 'الإحصاء التطبيقي'},
      {'code': 'CS499', 'name': 'مشروع التخرج'},
      {'code': 'CS330', 'name': 'قواعد البيانات ٢'},
      {'code': 'CS412', 'name': 'هندسة البرمجيات ٢'},
    ];

    for (int i = 0; i < courseCount; i++) {
      final subj = subjects[i % subjects.length];
      _simulatedCourses.add({
        'code': subj['code'],
        'name': subj['name'],
        'hours': 3,
        'expectedGrade': closestGrade['letter'],
      });
    }

    setState(() {
      _showResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadStudentData, child: const Text('إعادة المحاولة')),
          ],
        ),
      );
    }
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
                      min: _currentGpa > 0 ? _currentGpa : 1.0,
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
                      _targetSemesterGpa >= 4.0 ? 'أقصى معدل ممكن (مطلوب 4.00)' : 'مطلوب فصلي: ${_targetSemesterGpa.toStringAsFixed(2)}',
                      _expectedCumulativeGpa.toStringAsFixed(2),
                      Icons.trending_up_rounded,
                      AppColors.success500,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildResultCard(
                      'ساعات مكتملة',
                      '${_completedHours + _selectedHours}/$_totalRequiredHours',
                      Icons.school_rounded,
                      AppColors.primary500,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildResultCard(
                      'فصول متبقية للتخرج',
                      '$_remainingSemesters',
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
