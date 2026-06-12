import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class WhatIfSimulationScreen extends StatefulWidget {
  const WhatIfSimulationScreen({super.key});

  @override
  State<WhatIfSimulationScreen> createState() => _WhatIfSimulationScreenState();
}

class _WhatIfSimulationScreenState extends State<WhatIfSimulationScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  bool _simulating = false;
  String _errorMessage = '';
  Map<String, dynamic>? _summary;
  List<Map<String, dynamic>> _planCourses = [];

  final _addHoursController = TextEditingController();
  final _newGpaController = TextEditingController();
  int _extraHours = 0;
  double _whatIfGpa = 0.0;
  double? _simulatedGpa;
  int? _simulatedHours;
  bool? _wouldGraduate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _addHoursController.dispose();
    _newGpaController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final userId = _supabase.auth.currentUser?.id ?? '';
      final summaryRes = await _supabase.from('student_full_summary').select().eq('id', userId).maybeSingle();
      setState(() {
        _summary = summaryRes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _errorMessage = 'فشل تحميل البيانات: ${e.toString()}'; _isLoading = false; });
    }
  }

  void _runSimulation() {
    final gpa = double.tryParse((_summary?['calculated_gpa'] ?? _summary?['cumulative_gpa'] ?? '0').toString()) ?? 0.0;
    final completed = int.tryParse(_summary?['total_passed_hours']?.toString() ?? '0') ?? 0;
    final required = int.tryParse(_summary?['total_credit_hours']?.toString() ?? '136') ?? 136;
    final attempted = int.tryParse(_summary?['total_attempted_hours']?.toString() ?? completed.toString()) ?? completed;

    final extraHours = int.tryParse(_addHoursController.text) ?? 0;
    final targetGpa = double.tryParse(_newGpaController.text) ?? 0.0;

    if (extraHours <= 0 || targetGpa <= 0) {
      AcSnackbar.show(context, message: 'الرجاء إدخال قيم صحيحة', type: AcToastType.error);
      return;
    }

    setState(() {
      _simulating = true;
      _extraHours = extraHours;
      _whatIfGpa = targetGpa;
    });

    // Simulate: what if student gets targetGpa in extraHours courses
    final currentTotalPoints = gpa * attempted;
    final newTotalPoints = currentTotalPoints + (targetGpa * extraHours);
    final newAttempted = attempted + extraHours;
    final newGpa = newAttempted > 0 ? newTotalPoints / newAttempted : 0.0;
    final newCompleted = completed + extraHours;

    setState(() {
      _simulatedGpa = double.parse(newGpa.toStringAsFixed(2));
      _simulatedHours = newCompleted;
      _wouldGraduate = newCompleted >= required && newGpa >= 2.0;
      _simulating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: AcLoadingState());
    if (_errorMessage.isNotEmpty) return AcErrorState(title: 'خطأ', message: _errorMessage, onRetry: _loadData);

    final gpa = double.tryParse((_summary?['calculated_gpa'] ?? _summary?['cumulative_gpa'] ?? '0').toString()) ?? 0.0;
    final completed = int.tryParse(_summary?['total_passed_hours']?.toString() ?? '0') ?? 0;
    final required = int.tryParse(_summary?['total_credit_hours']?.toString() ?? '136') ?? 136;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('محاكاة What-If', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            Text('احسب تأثير الدرجات المتوقعة على معدلك', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xl),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brCard, side: const BorderSide(color: AppColors.border)),
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    _statItem('المعدل الحالي', gpa.toStringAsFixed(2), AppColors.primary600),
                    _statItem('الساعات المكتملة', '$completed', AppColors.success500),
                    _statItem('الساعات المطلوبة', '$required', AppColors.warning500),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('سيناريو المحاكاة', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brCard, side: const BorderSide(color: AppColors.border)),
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(children: [
                  AcInputField(
                    controller: _addHoursController,
                    label: 'عدد الساعات الإضافية',
                    hint: 'أدخل عدد الساعات',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AcInputField(
                    controller: _newGpaController,
                    label: 'المعدل المتوقع في هذه الساعات',
                    hint: 'مثال: 3.5',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AcButton(
                    label: 'تشغيل المحاكاة',
                    onPressed: _runSimulation,
                    isLoading: _simulating,
                  ),
                ]),
              ),
            ),
            if (_simulatedGpa != null) ...[
              const SizedBox(height: AppSpacing.xl),
              Text('النتيجة', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.md),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.brCard, side: BorderSide(color: _wouldGraduate! ? AppColors.success200 : AppColors.warning200)),
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      _statItem('المعدل بعد المحاكاة', _simulatedGpa!.toStringAsFixed(2), _simulatedGpa! >= 2.0 ? AppColors.success500 : AppColors.danger500),
                      _statItem('الساعات بعد الإضافة', '$_simulatedHours', AppColors.primary600),
                    ]),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_wouldGraduate! ? Icons.celebration_rounded : Icons.info_rounded, color: _wouldGraduate! ? AppColors.success500 : AppColors.warning500),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _wouldGraduate! ? 'مبروك! أنت مؤهل للتخرج بعد هذه الساعات ✓' : 'بحاجة إلى ساعات إضافية أو معدل أعلى',
                          style: AppTypography.labelLarge.copyWith(color: _wouldGraduate! ? AppColors.success600 : AppColors.warning600, fontWeight: FontWeight.bold),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(children: [
      Text(value, style: AppTypography.h4.copyWith(color: color, fontWeight: FontWeight.bold)),
      const SizedBox(height: AppSpacing.xxs),
      Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
    ]);
  }
}
