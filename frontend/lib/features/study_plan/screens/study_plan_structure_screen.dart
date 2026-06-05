// file: lib/features/study_plan/screens/study_plan_structure_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/curriculum_strings.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../data/models/plan_structure_model.dart';
import '../../../data/models/study_plan_model.dart';
import '../cubit/plan_structure_cubit.dart';

class StudyPlanStructureScreen extends StatefulWidget {
  const StudyPlanStructureScreen({super.key, required this.plan});

  final StudyPlanModel plan;

  @override
  State<StudyPlanStructureScreen> createState() => _StudyPlanStructureScreenState();
}

class _StudyPlanStructureScreenState extends State<StudyPlanStructureScreen> {
  late final PlanStructureCubit _cubit;
  final List<PlanStructureModel> _localEntries = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<PlanStructureCubit>();
    _cubit.load(widget.plan.id!);
  }

  void _initializeLocalEntries(List<PlanStructureModel> dbEntries) {
    if (_isInitialized) return;
    _localEntries.clear();
    _localEntries.addAll(dbEntries);
    // If empty, pre-populate standard 8 levels
    if (_localEntries.isEmpty) {
      for (int i = 1; i <= 8; i++) {
        _localEntries.add(PlanStructureModel(
          planId: widget.plan.id!,
          level: i,
          term: i % 2 == 1 ? 'fall' : 'spring',
          prescribedHours: 15,
          minHours: 12,
          maxHours: 20,
        ));
      }
    }
    _isInitialized = true;
  }

  void _addNewLevel() {
    setState(() {
      final nextLevel = _localEntries.isEmpty ? 1 : _localEntries.last.level + 1;
      _localEntries.add(PlanStructureModel(
        planId: widget.plan.id!,
        level: nextLevel,
        term: nextLevel % 2 == 1 ? 'fall' : 'spring',
        prescribedHours: 15,
        minHours: 12,
        maxHours: 20,
      ));
    });
  }

  void _removeLevel(int index) {
    setState(() {
      _localEntries.removeAt(index);
    });
  }

  void _saveAll() {
    _cubit.bulkSave(_localEntries);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text('هيكل مستويات الخطة - ${widget.plan.name}'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
            child: AcButton(
              label: 'إضافة مستوى دراسي',
              variant: AcButtonVariant.secondary,
              leadingIcon: const Icon(Icons.add_rounded),
              onPressed: _addNewLevel,
            ),
          ),
        ],
      ),
      body: BlocConsumer<PlanStructureCubit, PlanStructureState>(
        listener: (context, state) {
          if (state is PlanStructureSaved) {
            AcSnackbar.show(
              context,
              message: 'تم حفظ هيكل المستويات والحدود الأكاديمية بنجاح',
              type: AcToastType.success,
            );
          } else if (state is PlanStructureError) {
            AcSnackbar.show(
              context,
              message: state.message,
              type: AcToastType.error,
            );
          }
        },
        builder: (context, state) {
          if (state is PlanStructureLoading && !_isInitialized) {
            return const Center(child: AcLoadingState());
          }

          if (state is PlanStructureLoaded) {
            _initializeLocalEntries(state.entries);
          }

          if (_localEntries.isEmpty) {
            return AcEmptyState(
              title: 'لا يوجد هيكل مستويات',
              message: 'ابدأ بتهيئة مستويات الخطة وحدود الساعات المعتمدة لكل مستوى',
              icon: const Icon(Icons.layers_rounded),
              actionLabel: 'تهيئة الخطة الافتراضية (8 مستويات)',
              onAction: () {
                setState(() {
                  _initializeLocalEntries([]);
                });
              },
            );
          }

          return Column(
            children: [
              // Info Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                color: AppColors.primary50,
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.primary700),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'قم بتحديد الساعات المقترحة والحدود الدنيا والعليا المسموحة للتسجيل لكل فصل/مستوى دراسي.',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.primary700),
                      ),
                    ),
                  ],
                ),
              ),

              // Levels List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: _localEntries.length,
                  itemBuilder: (context, index) {
                    final entry = _localEntries[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.brCard,
                        side: BorderSide(color: AppColors.border),
                      ),
                      color: AppColors.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Level Circle Indicator
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primary500.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${entry.level}',
                                style: AppTypography.h3.copyWith(color: AppColors.primary500),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),

                            // Term Dropdown
                            Expanded(
                              flex: 2,
                              child: AcDropdownField<String>(
                                label: 'الفصل الدراسي الرئيسي',
                                value: entry.term,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _localEntries[index] = entry.copyWith(term: val);
                                    });
                                  }
                                },
                                items: const [
                                  DropdownMenuItem(value: 'fall', child: Text('فصل الخريف')),
                                  DropdownMenuItem(value: 'spring', child: Text('فصل الربيع')),
                                  DropdownMenuItem(value: 'summer', child: Text('فصل صيفي')),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),

                            // Prescribed Hours
                            Expanded(
                              child: _buildCellTextField(
                                label: 'الساعات المقترحة',
                                value: '${entry.prescribedHours}',
                                onChanged: (val) {
                                  final num = int.tryParse(val) ?? 0;
                                  _localEntries[index] = entry.copyWith(prescribedHours: num);
                                },
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),

                            // Min Hours
                            Expanded(
                              child: _buildCellTextField(
                                label: 'الحد الأدنى للتسجيل',
                                value: '${entry.minHours}',
                                onChanged: (val) {
                                  final num = int.tryParse(val) ?? 12;
                                  _localEntries[index] = entry.copyWith(minHours: num);
                                },
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),

                            // Max Hours
                            Expanded(
                              child: _buildCellTextField(
                                label: 'الحد الأقصى للتسجيل',
                                value: '${entry.maxHours}',
                                onChanged: (val) {
                                  final num = int.tryParse(val) ?? 20;
                                  _localEntries[index] = entry.copyWith(maxHours: num);
                                },
                              ),
                            ),

                            // Remove Button
                            const SizedBox(width: AppSpacing.md),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger500),
                              tooltip: 'حذف المستوى',
                              onPressed: () => _removeLevel(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Save Action Footer bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AcButton(
                      label: 'حفظ التغييرات بالكامل',
                      variant: AcButtonVariant.primary,
                      leadingIcon: state is PlanStructureSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.save_rounded),
                      onPressed: state is PlanStructureSaving ? null : _saveAll,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCellTextField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return AcTextField(
      controller: TextEditingController(text: value),
      label: label,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }
}
