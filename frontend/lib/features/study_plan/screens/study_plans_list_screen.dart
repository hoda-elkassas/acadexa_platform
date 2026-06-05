// file: lib/features/study_plan/screens/study_plans_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/curriculum_strings.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../data/models/study_plan_model.dart';
import '../cubit/study_plan_cubit.dart';

class StudyPlansListScreen extends StatefulWidget {
  const StudyPlansListScreen({super.key});

  @override
  State<StudyPlansListScreen> createState() => _StudyPlansListScreenState();
}

class _StudyPlansListScreenState extends State<StudyPlansListScreen> {
  final _searchController = TextEditingController();
  String _selectedStatus = '';
  late final StudyPlanCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<StudyPlanCubit>();
    _cubit.loadPlans(page: 1);
    _cubit.subscribeToChanges();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String val) {
    _cubit.loadPlans(page: 1, searchQuery: val);
  }

  void _onStatusChanged(String? val) {
    setState(() => _selectedStatus = val ?? '');
    _cubit.loadPlans(page: 1, status: _selectedStatus);
  }

  void _showCopyPlanDialog(StudyPlanModel plan) {
    final nameController = TextEditingController(text: '${plan.name} - نسخة');
    final yearController = TextEditingController(text: (plan.academicYear + 1).toString());

    AcFormDialog.show(
      context,
      title: CurriculumStrings.copyPlan,
      subtitle: plan.name,
      confirmLabel: CurriculumStrings.copyPlan,
      onConfirm: () {
        final newName = nameController.text.trim();
        final newYear = int.tryParse(yearController.text.trim()) ?? plan.academicYear;
        if (newName.isNotEmpty) {
          Navigator.of(context).pop();
          _cubit.copyPlan(
            sourcePlanId: plan.id!,
            newName: newName,
            newAcademicYear: newYear,
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AcTextField(
            controller: nameController,
            label: CurriculumStrings.planName,
            hint: CurriculumStrings.planName,
          ),
          const SizedBox(height: AppSpacing.md),
          AcTextField(
            controller: yearController,
            label: CurriculumStrings.academicYear,
            hint: CurriculumStrings.academicYear,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  void _confirmDelete(StudyPlanModel plan) {
    AcDialog.show(
      context,
      title: CurriculumStrings.confirmDelete,
      message: CurriculumStrings.deleteConfirmMessage,
      type: AcDialogType.danger,
      confirmLabel: CurriculumStrings.delete,
      cancelLabel: CurriculumStrings.cancel,
    ).then((confirmed) {
      if (confirmed == true) {
        _cubit.deletePlan(plan.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text(CurriculumStrings.studyPlans),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
            child: AcButton(
              label: CurriculumStrings.addStudyPlan,
              variant: AcButtonVariant.primary,
              leadingIcon: const Icon(Icons.add_rounded),
              onPressed: () {
                Navigator.pushNamed(context, '/curriculum/study-plans/add');
              },
            ),
          ),
        ],
      ),
      body: BlocListener<StudyPlanCubit, StudyPlanState>(
        listener: (context, state) {
          if (state is StudyPlanSaved) {
            AcSnackbar.show(
              context,
              message: CurriculumStrings.savedSuccessfully,
              type: AcToastType.success,
            );
          } else if (state is StudyPlanDeleted) {
            AcSnackbar.show(
              context,
              message: CurriculumStrings.deletedSuccessfully,
              type: AcToastType.success,
            );
          } else if (state is StudyPlanError) {
            AcSnackbar.show(
              context,
              message: state.message,
              type: AcToastType.error,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Filters & Search ──────────────────────────────────────────
              Card(
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.brCard,
                  side: BorderSide(color: AppColors.border),
                ),
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: AcSearchField(
                          controller: _searchController,
                          hint: CurriculumStrings.search,
                          onChanged: _onSearch,
                          onClear: () {
                            _searchController.clear();
                            _onSearch('');
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      SizedBox(
                        width: 200,
                        child: AcDropdownField<String>(
                          label: CurriculumStrings.status,
                          value: _selectedStatus,
                          onChanged: _onStatusChanged,
                          items: const [
                            DropdownMenuItem(value: '', child: Text('الكل')),
                            DropdownMenuItem(value: 'draft', child: Text(CurriculumStrings.statusDraft)),
                            DropdownMenuItem(value: 'active', child: Text(CurriculumStrings.statusActive)),
                            DropdownMenuItem(value: 'archived', child: Text(CurriculumStrings.statusArchived)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ─── Table List ────────────────────────────────────────────────
              Expanded(
                child: BlocBuilder<StudyPlanCubit, StudyPlanState>(
                  builder: (context, state) {
                    if (state is StudyPlanLoading) {
                      return const Center(child: AcLoadingState());
                    }

                    if (state is StudyPlanError && state is! StudyPlanLoaded) {
                      return AcErrorState(
                        title: CurriculumStrings.errorOccurred,
                        message: state.message,
                        onRetry: () => _cubit.loadPlans(),
                      );
                    }

                    List<StudyPlanModel> plans = [];
                    int totalCount = 0;
                    int currentPage = 1;
                    int totalPages = 1;

                    if (state is StudyPlanLoaded) {
                      plans = state.plans;
                      totalCount = state.totalCount;
                      currentPage = state.currentPage;
                      totalPages = state.totalPages;
                    }

                    if (plans.isEmpty) {
                      return AcEmptyState(
                        title: CurriculumStrings.noData,
                        message: 'لا توجد خطط دراسية مطابقة للبحث',
                        icon: const Icon(Icons.description_outlined),
                        actionLabel: CurriculumStrings.addStudyPlan,
                        onAction: () {
                          Navigator.pushNamed(context, '/curriculum/study-plans/add');
                        },
                      );
                    }

                    return AcTableWithPagination<StudyPlanModel>(
                      currentPage: currentPage,
                      totalPages: totalPages,
                      totalItems: totalCount,
                      onPageChanged: (page) => _cubit.changePage(page),
                      columns: [
                        AcTableColumn(
                          key: 'name',
                          label: CurriculumStrings.planName,
                          cellBuilder: (plan, _) => Text(
                            plan.name,
                            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                          ),
                          flex: 2,
                        ),
                        AcTableColumn(
                          key: 'year',
                          label: CurriculumStrings.academicYear,
                          cellBuilder: (plan, _) => Text('${plan.academicYear} / ${plan.academicYear + 1}'),
                        ),
                        AcTableColumn(
                          key: 'program',
                          label: CurriculumStrings.program,
                          cellBuilder: (plan, _) => Text(plan.programName ?? '-'),
                        ),
                        AcTableColumn(
                          key: 'version',
                          label: CurriculumStrings.version,
                          cellBuilder: (plan, _) => Text('v${plan.version}'),
                        ),
                        AcTableColumn(
                          key: 'status',
                          label: CurriculumStrings.status,
                          cellBuilder: (plan, _) {
                            final (label, color) = switch (plan.status) {
                              'draft' => (CurriculumStrings.statusDraft, AppColors.warning500),
                              'active' => (CurriculumStrings.statusActive, AppColors.success500),
                              'archived' => (CurriculumStrings.statusArchived, AppColors.textDisabled),
                              _ => (plan.status, AppColors.textPrimary)
                            };
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: AppRadius.brPill,
                              ),
                              child: Text(
                                label,
                                style: AppTypography.bodySmall.copyWith(color: color, fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                        AcTableColumn(
                          key: 'actions',
                          label: 'الإجراءات',
                          cellBuilder: (plan, _) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AcIconButton(
                                icon: const Icon(Icons.edit_rounded),
                                tooltip: CurriculumStrings.edit,
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/curriculum/study-plans/edit',
                                    arguments: plan,
                                  );
                                },
                              ),
                              AcIconButton(
                                icon: const Icon(Icons.copy_all_rounded),
                                tooltip: CurriculumStrings.copyPlan,
                                onPressed: () => _showCopyPlanDialog(plan),
                              ),
                              AcIconButton(
                                icon: const Icon(Icons.settings_outlined),
                                tooltip: 'إدارة التفاصيل',
                                onPressed: () => _showPlanActionsBottomSheet(context, plan),
                              ),
                              AcIconButton(
                                icon: const Icon(Icons.delete_outline_rounded),
                                tooltip: CurriculumStrings.delete,
                                variant: AcButtonVariant.danger,
                                onPressed: () => _confirmDelete(plan),
                              ),
                            ],
                          ),
                          width: 200,
                        ),
                      ],
                      rows: plans,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlanActionsBottomSheet(BuildContext context, StudyPlanModel plan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.modal)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.name, style: AppTypography.h4),
            const SizedBox(height: AppSpacing.sm),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.view_module_rounded, color: AppColors.primary500),
              title: const Text(CurriculumStrings.planStructure),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/curriculum/study-plans/structure', arguments: plan);
              },
            ),
            ListTile(
              leading: const Icon(Icons.book_rounded, color: AppColors.primary500),
              title: const Text(CurriculumStrings.courses),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/curriculum/study-plans/courses', arguments: plan);
              },
            ),
            ListTile(
              leading: const Icon(Icons.alt_route_rounded, color: AppColors.primary500),
              title: const Text(CurriculumStrings.prerequisites),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/curriculum/study-plans/prerequisites', arguments: plan);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_work_rounded, color: AppColors.primary500),
              title: const Text(CurriculumStrings.electiveGroups),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/curriculum/study-plans/elective-groups', arguments: plan);
              },
            ),
            ListTile(
              leading: const Icon(Icons.rule_rounded, color: AppColors.primary500),
              title: const Text(CurriculumStrings.academicLoadRules),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/curriculum/study-plans/rules/academic-load', arguments: plan);
              },
            ),
            ListTile(
              leading: const Icon(Icons.workspace_premium_rounded, color: AppColors.primary500),
              title: const Text(CurriculumStrings.gradingScale),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/curriculum/study-plans/rules/grading', arguments: plan);
              },
            ),
            ListTile(
              leading: const Icon(Icons.business_center_rounded, color: AppColors.primary500),
              title: const Text(CurriculumStrings.fieldTraining),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/curriculum/study-plans/rules/field-training', arguments: plan);
              },
            ),
          ],
        ),
      ),
    );
  }
}
