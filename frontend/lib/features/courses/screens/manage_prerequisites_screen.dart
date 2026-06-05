// file: lib/features/courses/screens/manage_prerequisites_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/curriculum_strings.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../data/models/prerequisite_model.dart';
import '../../../data/models/study_plan_model.dart';
import '../cubit/prerequisites_cubit.dart';
import 'add_prerequisite_dialog.dart';

class ManagePrerequisitesScreen extends StatefulWidget {
  const ManagePrerequisitesScreen({super.key, required this.plan});

  final StudyPlanModel plan;

  @override
  State<ManagePrerequisitesScreen> createState() => _ManagePrerequisitesScreenState();
}

class _ManagePrerequisitesScreenState extends State<ManagePrerequisitesScreen> {
  final _searchController = TextEditingController();
  late final PrerequisitesCubit _cubit;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cubit = context.read<PrerequisitesCubit>();
    _cubit.loadByPlan(widget.plan.id!);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEditPrerequisite({PrerequisiteModel? prerequisite}) {
    showDialog(
      context: context,
      builder: (_) => AddPrerequisiteDialog(
        planId: widget.plan.id!,
        prerequisite: prerequisite,
      ),
    ).then((updated) {
      if (updated == true) {
        AcSnackbar.show(
          context,
          message: CurriculumStrings.savedSuccessfully,
          type: AcToastType.success,
        );
      }
    });
  }

  void _confirmDelete(PrerequisiteModel pr) {
    AcDialog.show(
      context,
      title: CurriculumStrings.confirmDelete,
      message: 'هل أنت متأكد من حذف شرط المتطلب للمقررين المحددين؟',
      type: AcDialogType.danger,
      confirmLabel: CurriculumStrings.delete,
      cancelLabel: CurriculumStrings.cancel,
    ).then((confirmed) {
      if (confirmed == true) {
        _cubit.delete(pr.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text('إدارة المتطلبات السابقة - ${widget.plan.name}'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
            child: AcButton(
              label: 'إضافة متطلب سابق',
              variant: AcButtonVariant.primary,
              leadingIcon: const Icon(Icons.add_rounded),
              onPressed: () => _showAddEditPrerequisite(),
            ),
          ),
        ],
      ),
      body: BlocListener<PrerequisitesCubit, PrerequisitesState>(
        listener: (context, state) {
          if (state is PrerequisiteDeleted) {
            AcSnackbar.show(
              context,
              message: CurriculumStrings.deletedSuccessfully,
              type: AcToastType.success,
            );
          } else if (state is PrerequisitesError) {
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
            children: [
              // ─── Header Search ──────────────────────────────────────────
              Card(
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.brCard,
                  side: BorderSide(color: AppColors.border),
                ),
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: AcSearchField(
                    controller: _searchController,
                    hint: 'بحث باسم المقرر أو المتطلب السابق له...',
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    onClear: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ─── Prerequisites List Table ────────────────────────────────
              Expanded(
                child: BlocBuilder<PrerequisitesCubit, PrerequisitesState>(
                  builder: (context, state) {
                    if (state is PrerequisitesLoading) {
                      return const Center(child: AcLoadingState());
                    }

                    if (state is PrerequisitesError) {
                      return AcErrorState(
                        title: CurriculumStrings.errorOccurred,
                        message: state.message,
                        onRetry: () => _cubit.loadByPlan(widget.plan.id!),
                      );
                    }

                    List<PrerequisiteModel> prereqs = [];
                    if (state is PrerequisitesLoaded) {
                      prereqs = state.prerequisites;
                    }

                    // Apply local search filter
                    if (_searchQuery.isNotEmpty) {
                      prereqs = prereqs.where((pr) {
                        final cCode = pr.courseCode?.toLowerCase() ?? '';
                        final cName = pr.courseName?.toLowerCase() ?? '';
                        final rName = pr.requiredCourseName?.toLowerCase() ?? '';
                        final rCode = pr.requiredCourseCode?.toLowerCase() ?? '';
                        final q = _searchQuery.toLowerCase();
                        return cCode.contains(q) || cName.contains(q) || rName.contains(q) || rCode.contains(q);
                      }).toList();
                    }

                    if (prereqs.isEmpty) {
                      return AcEmptyState(
                        title: 'لا توجد شروط متطلبات سابقة',
                        message: 'ابدأ بربط المقررات ببعضها البعض لتنظيم ترتيب دراستها للطلاب',
                        icon: const Icon(Icons.link_rounded),
                        actionLabel: 'إضافة متطلب سابق',
                        onAction: () => _showAddEditPrerequisite(),
                      );
                    }

                    return AcDataTable<PrerequisiteModel>(
                      columns: [
                        AcTableColumn(
                          key: 'course',
                          label: 'المقرر الدراسي',
                          cellBuilder: (pr, _) => Text(
                            '${pr.courseCode ?? ""} - ${pr.courseName ?? ""}',
                            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                          ),
                          flex: 2,
                        ),
                        AcTableColumn(
                          key: 'required_course',
                          label: 'المتطلب السابق المطلوب',
                          cellBuilder: (pr, _) => Text(
                            '${pr.requiredCourseCode ?? pr.requiredCourseId ?? ""} - ${pr.requiredCourseName ?? ""}',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.primary500,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          flex: 2,
                        ),
                        AcTableColumn(
                          key: 'logic',
                          label: 'نوع الشرط',
                          cellBuilder: (pr, _) {
                            final label = pr.logic == 'ALL' ? 'إلزامي بالكامل' : 'بديل (أحدهما)';
                            final color = pr.logic == 'ALL' ? AppColors.primary500 : AppColors.warning500;
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
                          width: 140,
                        ),
                        AcTableColumn(
                          key: 'min_grade',
                          label: 'درجة النجاح الأدنى',
                          cellBuilder: (pr, _) => Text('${pr.minGrade}%'),
                          width: 130,
                        ),
                        AcTableColumn(
                          key: 'prior_term',
                          label: 'تزامن دراسي',
                          cellBuilder: (pr, _) {
                            final label = pr.mustBePriorTerm ? 'في فصل سابق' : 'يسمح بالتزامن';
                            final color = pr.mustBePriorTerm ? AppColors.error500 : AppColors.success500;
                            return Text(
                              label,
                              style: AppTypography.bodyMedium.copyWith(color: color, fontWeight: FontWeight.bold),
                            );
                          },
                          width: 140,
                        ),
                        AcTableColumn(
                          key: 'actions',
                          label: 'الإجراءات',
                          cellBuilder: (pr, _) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AcIconButton(
                                icon: const Icon(Icons.edit_rounded),
                                tooltip: CurriculumStrings.edit,
                                onPressed: () => _showAddEditPrerequisite(prerequisite: pr),
                              ),
                              AcIconButton(
                                icon: const Icon(Icons.delete_outline_rounded),
                                tooltip: CurriculumStrings.delete,
                                variant: AcButtonVariant.danger,
                                onPressed: () => _confirmDelete(pr),
                              ),
                            ],
                          ),
                          width: 120,
                        ),
                      ],
                      rows: prereqs,
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
}
