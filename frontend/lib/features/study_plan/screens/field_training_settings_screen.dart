// file: lib/features/study_plan/screens/field_training_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/curriculum_strings.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../data/models/field_training_rules_model.dart';
import '../cubit/field_training_cubit.dart';

class FieldTrainingSettingsScreen extends StatefulWidget {
  const FieldTrainingSettingsScreen({super.key, required this.plan});

  final dynamic plan; // StudyPlanModel

  @override
  State<FieldTrainingSettingsScreen> createState() => _FieldTrainingSettingsScreenState();
}

class _FieldTrainingSettingsScreenState extends State<FieldTrainingSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final FieldTrainingCubit _cubit;

  late final TextEditingController _levelsController;
  late final TextEditingController _hoursController;
  
  // Weights
  late final TextEditingController _externalWeightController;
  late final TextEditingController _internalWeightController;
  late final TextEditingController _remoteWeightController;
  late final TextEditingController _examWeightController;

  bool _allowShift12 = false;
  bool _allowShift34 = false;
  bool _mandatory = true;

  bool _isInitialized = false;
  FieldTrainingRulesModel? _originalRules;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<FieldTrainingCubit>();
    _cubit.load(widget.plan.id!);

    _levelsController = TextEditingController();
    _hoursController = TextEditingController();
    _externalWeightController = TextEditingController();
    _internalWeightController = TextEditingController();
    _remoteWeightController = TextEditingController();
    _examWeightController = TextEditingController();
  }

  @override
  void dispose() {
    _levelsController.dispose();
    _hoursController.dispose();
    _externalWeightController.dispose();
    _internalWeightController.dispose();
    _remoteWeightController.dispose();
    _examWeightController.dispose();
    super.dispose();
  }

  void _initializeFields(FieldTrainingRulesModel? rules) {
    if (_isInitialized) return;
    _originalRules = rules;

    final r = rules ?? FieldTrainingRulesModel(planId: widget.plan.id!);
    _levelsController.text = (r.trainingLevels ?? 4).toString();
    _hoursController.text = (r.hoursPerLevel ?? 2).toString();
    
    _externalWeightController.text = (r.externalSupervisorWeight ?? 20.0).toStringAsFixed(0);
    _internalWeightController.text = (r.internalSupervisorWeight ?? 20.0).toStringAsFixed(0);
    _remoteWeightController.text = (r.remoteSupervisorWeight ?? 20.0).toStringAsFixed(0);
    _examWeightController.text = (r.finalExamWeight ?? 40.0).toStringAsFixed(0);

    _allowShift12 = r.allowShiftLevel1_2 ?? false;
    _allowShift34 = r.allowShiftLevel3_4 ?? false;
    _mandatory = r.mandatoryForGraduation ?? true;

    _isInitialized = true;
  }

  double get _totalWeight {
    final ext = double.tryParse(_externalWeightController.text) ?? 0.0;
    final intl = double.tryParse(_internalWeightController.text) ?? 0.0;
    final rem = double.tryParse(_remoteWeightController.text) ?? 0.0;
    final exam = double.tryParse(_examWeightController.text) ?? 0.0;
    return ext + intl + rem + exam;
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    if (_totalWeight != 100.0) {
      AcSnackbar.show(
        context,
        message: 'يجب أن يكون مجموع أوزان التقييمات مساوياً لـ 100% (المجموع الحالي: $_totalWeight%)',
        type: AcToastType.error,
      );
      return;
    }

    final updated = FieldTrainingRulesModel(
      id: _originalRules?.id,
      planId: widget.plan.id!,
      trainingLevels: int.tryParse(_levelsController.text),
      hoursPerLevel: int.tryParse(_hoursController.text),
      externalSupervisorWeight: double.tryParse(_externalWeightController.text),
      internalSupervisorWeight: double.tryParse(_internalWeightController.text),
      remoteSupervisorWeight: double.tryParse(_remoteWeightController.text),
      finalExamWeight: double.tryParse(_examWeightController.text),
      allowShiftLevel1_2: _allowShift12,
      allowShiftLevel3_4: _allowShift34,
      mandatoryForGraduation: _mandatory,
    );

    _cubit.save(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text('إعدادات التدريب العملي والميداني - ${widget.plan.name}'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
            child: BlocBuilder<FieldTrainingCubit, FieldTrainingState>(
              builder: (context, state) {
                return AcButton(
                  label: 'حفظ الإعدادات',
                  variant: AcButtonVariant.primary,
                  leadingIcon: state is FieldTrainingSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  onPressed: state is FieldTrainingSaving ? null : _onSave,
                );
              },
            ),
          ),
        ],
      ),
      body: BlocConsumer<FieldTrainingCubit, FieldTrainingState>(
        listener: (context, state) {
          if (state is FieldTrainingSaved) {
            AcSnackbar.show(
              context,
              message: 'تم حفظ إعدادات التدريب الميداني بنجاح',
              type: AcToastType.success,
            );
          } else if (state is FieldTrainingError) {
            AcSnackbar.show(
              context,
              message: state.message,
              type: AcToastType.error,
            );
          }
        },
        builder: (context, state) {
          if (state is FieldTrainingLoading && !_isInitialized) {
            return const Center(child: AcLoadingState());
          }

          if (state is FieldTrainingLoaded) {
            _initializeFields(state.rules);
          }

          final total = _totalWeight;
          final isWeightValid = total == 100.0;

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Column 1: Levels & Shift Policies
                  Expanded(
                    child: Column(
                      children: [
                        _buildSectionHeader('المستويات وفترات التدريب'),
                        const SizedBox(height: AppSpacing.md),
                        AcCard(
                          child: Column(
                            children: [
                              AcTextField(
                                controller: _levelsController,
                                label: 'عدد مستويات التدريب المطلوبة',
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || int.tryParse(v) == null ? 'رقم غير صحيح' : null,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AcTextField(
                                controller: _hoursController,
                                label: 'ساعات التدريب لكل مستوى',
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || int.tryParse(v) == null ? 'رقم غير صحيح' : null,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              SwitchListTile(
                                title: const Text('إلزامي للتخرج'),
                                subtitle: const Text('لا يستطيع الطالب التخرج بدون إنهاء كافة مستويات التدريب'),
                                value: _mandatory,
                                activeColor: AppColors.primary500,
                                onChanged: (val) => setState(() => _mandatory = val),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _buildSectionHeader('سياسة توزيع فترات التدريب'),
                        const SizedBox(height: AppSpacing.md),
                        AcCard(
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: const Text('السماح بترحيل تدريب المستوى 1 و 2'),
                                subtitle: const Text('تمكين الطالب من تأجيل تدريب المستويات الأولى للفصول اللاحقة'),
                                value: _allowShift12,
                                activeColor: AppColors.primary500,
                                onChanged: (val) => setState(() => _allowShift12 = val),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              SwitchListTile(
                                title: const Text('السماح بترحيل تدريب المستوى 3 و 4'),
                                subtitle: const Text('تمكين الطالب من ترحيل تدريب السنوات الأخيرة لتزامنها مع التخرج'),
                                value: _allowShift34,
                                activeColor: AppColors.primary500,
                                onChanged: (val) => setState(() => _allowShift34 = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xl),

                  // Column 2: Grades and Weight Allocations
                  Expanded(
                    child: Column(
                      children: [
                        _buildSectionHeader('توزيع نسب تقييم التدريب الميداني'),
                        const SizedBox(height: AppSpacing.md),
                        AcCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Total visual weight indicator
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: isWeightValid ? AppColors.success50 : AppColors.danger50,
                                  borderRadius: AppRadius.brSm,
                                  border: Border.all(color: isWeightValid ? AppColors.success200 : AppColors.danger200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isWeightValid ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                                      color: isWeightValid ? AppColors.success700 : AppColors.danger700,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Text(
                                        isWeightValid
                                            ? 'مجموع الأوزان متطابق تماماً (100%)'
                                            : 'مجموع الأوزان يجب أن يكون 100% (المجموع الحالي: ${total.toStringAsFixed(0)}%)',
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: isWeightValid ? AppColors.success700 : AppColors.danger700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              AcTextField(
                                controller: _externalWeightController,
                                label: 'وزن تقييم المشرف الخارجي (جهة التدريب) %',
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AcTextField(
                                controller: _internalWeightController,
                                label: 'وزن تقييم المشرف الداخلي (الأكاديمي) %',
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AcTextField(
                                controller: _remoteWeightController,
                                label: 'وزن تقييم التقارير المرفوعة والمنصة %',
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AcTextField(
                                controller: _examWeightController,
                                label: 'وزن الامتحان النهائي/المناقشة %',
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary500,
            borderRadius: AppRadius.brPill,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
