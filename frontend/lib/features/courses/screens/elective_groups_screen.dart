// file: lib/features/courses/screens/elective_groups_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/curriculum_strings.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../data/models/elective_group_model.dart';
import '../../../data/models/study_plan_model.dart';
import '../../../data/services/course_service.dart';
import '../../../data/models/course_model.dart';
import '../cubit/elective_groups_cubit.dart';
import 'add_edit_elective_group_dialog.dart';

class ElectiveGroupsScreen extends StatefulWidget {
  const ElectiveGroupsScreen({super.key, required this.plan});

  final StudyPlanModel plan;

  @override
  State<ElectiveGroupsScreen> createState() => _ElectiveGroupsScreenState();
}

class _ElectiveGroupsScreenState extends State<ElectiveGroupsScreen> {
  final _searchController = TextEditingController();
  final _courseService = CourseService();
  late final ElectiveGroupsCubit _cubit;
  
  List<CourseModel> _allCourses = [];
  bool _loadingAllCourses = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ElectiveGroupsCubit>();
    _cubit.load(widget.plan.id!);
    _loadAllCourses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllCourses() async {
    try {
      final list = await _courseService.getAllForPlan(widget.plan.id!);
      setState(() {
        _allCourses = list;
        _loadingAllCourses = false;
      });
    } catch (e) {
      setState(() => _loadingAllCourses = false);
    }
  }

  void _showAddEditGroup({ElectiveGroupModel? group}) {
    showDialog(
      context: context,
      builder: (_) => AddEditElectiveGroupDialog(
        planId: widget.plan.id!,
        group: group,
      ),
    ).then((updated) {
      if (updated == true && mounted) {
        AcSnackbar.show(
          context,
          message: CurriculumStrings.savedSuccessfully,
          type: AcToastType.success,
        );
      }
    });
  }

  void _confirmDelete(ElectiveGroupModel group) {
    AcDialog.show(
      context,
      title: CurriculumStrings.confirmDelete,
      message: 'هل أنت متأكد من حذف المجموعة الاختيارية ${group.name}؟',
      type: AcDialogType.danger,
      confirmLabel: CurriculumStrings.delete,
      cancelLabel: CurriculumStrings.cancel,
    ).then((confirmed) {
      if (confirmed == true) {
        _cubit.delete(group.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text('المجموعات الاختيارية - ${widget.plan.name}'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
            child: AcButton(
              label: 'إضافة مجموعة اختيارية',
              variant: AcButtonVariant.primary,
              leadingIcon: const Icon(Icons.add_rounded),
              onPressed: () => _showAddEditGroup(),
            ),
          ),
        ],
      ),
      body: BlocListener<ElectiveGroupsCubit, ElectiveGroupsState>(
        listener: (context, state) {
          if (state is ElectiveGroupDeleted) {
            AcSnackbar.show(
              context,
              message: CurriculumStrings.deletedSuccessfully,
              type: AcToastType.success,
            );
          } else if (state is ElectiveGroupsError) {
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
                    hint: 'بحث باسم المجموعة الاختيارية أو الرمز...',
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    onClear: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ─── Elective Groups List Table ──────────────────────────────
              Expanded(
                child: _loadingAllCourses
                    ? const Center(child: AcLoadingState())
                    : BlocBuilder<ElectiveGroupsCubit, ElectiveGroupsState>(
                        builder: (context, state) {
                          if (state is ElectiveGroupsLoading) {
                            return const Center(child: AcLoadingState());
                          }

                          if (state is ElectiveGroupsError) {
                            return AcErrorState(
                              title: CurriculumStrings.errorOccurred,
                              message: state.message,
                              onRetry: () => _cubit.load(widget.plan.id!),
                            );
                          }

                          List<ElectiveGroupModel> groups = [];
                          if (state is ElectiveGroupsLoaded) {
                            groups = state.groups;
                          }

                          // Filter locally
                          if (_searchQuery.isNotEmpty) {
                            groups = groups.where((g) {
                              final name = g.name.toLowerCase();
                              final code = g.code.toLowerCase();
                              final q = _searchQuery.toLowerCase();
                              return name.contains(q) || code.contains(q);
                            }).toList();
                          }

                          if (groups.isEmpty) {
                            return AcEmptyState(
                              title: 'لا توجد مجموعات اختيارية مضافة',
                              message: 'ابدأ بتعريف مجموعات اختيارية لتمثيل مسارات الاختيار والمقررات الحرة للطلاب',
                              icon: const Icon(Icons.collections_bookmark_rounded),
                              actionLabel: 'إضافة مجموعة اختيارية',
                              onAction: () => _showAddEditGroup(),
                            );
                          }

                          return AcDataTable<ElectiveGroupModel>(
                            columns: [
                              AcTableColumn(
                                key: 'code',
                                label: 'رمز المجموعة',
                                cellBuilder: (g, _) => Text(
                                  g.code,
                                  style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                                ),
                                width: 140,
                              ),
                              AcTableColumn(
                                key: 'name',
                                label: 'اسم المجموعة الاختيارية',
                                cellBuilder: (g, _) => Text(g.name),
                                flex: 2,
                              ),
                              AcTableColumn(
                                key: 'rules',
                                label: 'شروط المتطلبات',
                                cellBuilder: (g, _) {
                                  if (g.selectByHours) {
                                    return Text('دراسة ما بين ${g.minHours ?? 0} إلى ${g.maxHours ?? 0} ساعة');
                                  } else {
                                    return Text('دراسة ما بين ${g.minCourses ?? 0} إلى ${g.maxCourses ?? 0} مقررات');
                                  }
                                },
                                flex: 2,
                              ),
                              AcTableColumn(
                                key: 'courses',
                                label: 'المقررات المدرجة بالمجموعة',
                                cellBuilder: (g, _) {
                                  final names = _allCourses
                                      .where((c) => g.courseIds.contains(c.id))
                                      .map((c) => c.code)
                                      .toList();
                                  if (names.isEmpty) {
                                    return Text(
                                      'لا توجد مقررات',
                                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textDisabled),
                                    );
                                  }
                                  return Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: names.map((name) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary50,
                                          borderRadius: AppRadius.brSm,
                                          border: Border.all(color: AppColors.primary100),
                                        ),
                                        child: Text(
                                          name,
                                          style: AppTypography.bodySmall.copyWith(
                                            color: AppColors.primary600,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                                flex: 3,
                              ),
                              AcTableColumn(
                                key: 'actions',
                                label: 'الإجراءات',
                                cellBuilder: (g, _) => Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AcIconButton(
                                      icon: const Icon(Icons.edit_rounded),
                                      tooltip: CurriculumStrings.edit,
                                      onPressed: () => _showAddEditGroup(group: g),
                                    ),
                                    AcIconButton(
                                      icon: const Icon(Icons.delete_outline_rounded),
                                      tooltip: CurriculumStrings.delete,
                                      variant: AcButtonVariant.danger,
                                      onPressed: () => _confirmDelete(g),
                                    ),
                                  ],
                                ),
                                width: 120,
                              ),
                            ],
                            rows: groups,
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
