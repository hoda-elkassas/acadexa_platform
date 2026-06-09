// file: lib/features/transcript/screens/graduation_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class GraduationTrackingScreen extends StatefulWidget {
  const GraduationTrackingScreen({super.key});

  @override
  State<GraduationTrackingScreen> createState() => _GraduationTrackingScreenState();
}

class _GraduationTrackingScreenState extends State<GraduationTrackingScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id ?? '';
      final res = await _supabase.from('student_full_summary').select().eq('id', userId).maybeSingle();
      setState(() {
        _summary = res;
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

    final gpa = double.tryParse(_summary?['calculated_gpa']?.toString() ?? '') ?? 0.0;
    final completed = int.tryParse(_summary?['total_passed_hours']?.toString() ?? '0') ?? 0;
    final required = int.tryParse(_summary?['total_credit_hours']?.toString() ?? '136') ?? 136;
    final remaining = required - completed;
    final progress = required > 0 ? completed / required : 0.0;

    final requirements = [
      {
        'label': 'الحد الأدنى للمعدل التراكمي (2.00)',
        'met': gpa >= 2.0,
        'value': gpa.toStringAsFixed(2),
      },
      {
        'label': 'إكمال جميع الساعات المطلوبة ($required ساعة)',
        'met': completed >= required,
        'value': '$completed / $required',
      },
      {
        'label': 'اجتياز مقرر التدريب الميداني',
        'met': true,
        'value': 'مكتمل',
      },
      {
        'label': 'اجتياز مشروع التخرج',
        'met': false,
        'value': 'قيد التسجيل',
      },
      {
        'label': 'عدم وجود مقررات راسب بها (F)',
        'met': true,
        'value': 'لا يوجد',
      },
    ];

    final metCount = requirements.where((r) => r['met'] == true).length;
    final totalReqs = requirements.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'متابعة متطلبات التخرج',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'تتبع تقدمك نحو استيفاء جميع شروط التخرج.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Graduation readiness
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                side: BorderSide(
                  color: metCount == totalReqs
                      ? AppColors.success500.withValues(alpha: 0.5)
                      : AppColors.warning500.withValues(alpha: 0.5),
                ),
              ),
              color: metCount == totalReqs
                  ? AppColors.success500.withValues(alpha: 0.05)
                  : AppColors.warning500.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    Icon(
                      metCount == totalReqs
                          ? Icons.celebration_rounded
                          : Icons.hourglass_bottom_rounded,
                      size: 48,
                      color: metCount == totalReqs
                          ? AppColors.success500
                          : AppColors.warning500,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      metCount == totalReqs
                          ? 'تهانينا! أنت مؤهل للتخرج 🎓'
                          : 'لم تكتمل متطلبات التخرج بعد',
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '$metCount من $totalReqs متطلبات مستوفاة',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    if (remaining > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'متبقي $remaining ساعة للتخرج',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.primary600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Requirements checklist
            Text(
              'قائمة متطلبات التخرج',
              style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            ...requirements.map((req) {
              final met = req['met'] as bool;
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
                    met ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: met ? AppColors.success500 : AppColors.danger500,
                  ),
                  title: Text(
                    req['label'] as String,
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: met ? TextDecoration.lineThrough : null,
                      color: met ? AppColors.textSecondary : AppColors.textPrimary,
                    ),
                  ),
                  trailing: Text(
                    req['value'] as String,
                    style: AppTypography.labelMedium.copyWith(
                      color: met ? AppColors.success600 : AppColors.warning600,
                      fontWeight: FontWeight.bold,
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
