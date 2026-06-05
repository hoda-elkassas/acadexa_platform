// file: lib/features/departments/screens/departments_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/curriculum_strings.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../data/models/department_model.dart';
import '../../../data/models/program_model.dart';
import '../cubit/departments_cubit.dart';
import 'add_edit_department_dialog.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();
  late final DepartmentsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cubit = context.read<DepartmentsCubit>();
    _cubit.load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String val) {
    _cubit.load(search: val);
  }

  void _showAddEditDepartment({DepartmentModel? department}) {
    showDialog(
      context: context,
      builder: (_) => AddEditDepartmentDialog(department: department),
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

  void _showAddEditProgram({ProgramModel? program}) {
    showDialog(
      context: context,
      builder: (_) => AddEditDepartmentDialog(program: program, isProgram: true),
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

  void _confirmDeleteDepartment(DepartmentModel dept) {
    AcDialog.show(
      context,
      title: CurriculumStrings.confirmDelete,
      message: 'هل أنت متأكد من حذف هذا القسم؟ سيتم حذف جميع البيانات التابعة له.',
      type: AcDialogType.danger,
      confirmLabel: CurriculumStrings.delete,
      cancelLabel: CurriculumStrings.cancel,
    ).then((confirmed) {
      if (confirmed == true) {
        _cubit.deleteDepartment(dept.id!);
      }
    });
  }

  void _confirmDeleteProgram(ProgramModel prog) {
    AcDialog.show(
      context,
      title: CurriculumStrings.confirmDelete,
      message: 'هل أنت متأكد من حذف هذا البرنامج؟',
      type: AcDialogType.danger,
      confirmLabel: CurriculumStrings.delete,
      cancelLabel: CurriculumStrings.cancel,
    ).then((confirmed) {
      if (confirmed == true) {
        _cubit.deleteProgram(prog.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('إدارة الأقسام والبرامج الأكاديمية'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary500,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary500,
          labelStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'الأقسام الأكاديمية'),
            Tab(text: 'البرامج الدراسية'),
          ],
        ),
      ),
      body: BlocListener<DepartmentsCubit, DepartmentsState>(
        listener: (context, state) {
          if (state is DepartmentDeleted) {
            AcSnackbar.show(
              context,
              message: CurriculumStrings.deletedSuccessfully,
              type: AcToastType.success,
            );
          } else if (state is DepartmentsError) {
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
              // ─── Header Search & Add ──────────────────────────────────────
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
                          hint: 'بحث بالاسم أو الكود...',
                          onChanged: _onSearch,
                          onClear: () {
                            _searchController.clear();
                            _onSearch('');
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      AnimatedBuilder(
                        animation: _tabController,
                        builder: (context, _) {
                          final isProgramTab = _tabController.index == 1;
                          return AcButton(
                            label: isProgramTab ? 'إضافة برنامج' : 'إضافة قسم',
                            variant: AcButtonVariant.primary,
                            leadingIcon: const Icon(Icons.add_rounded),
                            onPressed: () {
                              if (isProgramTab) {
                                _showAddEditProgram();
                              } else {
                                _showAddEditDepartment();
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ─── Tab Content ────────────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // ── Tab 1: Departments ──
                    BlocBuilder<DepartmentsCubit, DepartmentsState>(
                      builder: (context, state) {
                        if (state is DepartmentsLoading) {
                          return const Center(child: AcLoadingState());
                        }

                        if (state is DepartmentsError && state is! DepartmentsLoaded) {
                          return AcErrorState(
                            title: CurriculumStrings.errorOccurred,
                            message: state.message,
                            onRetry: () => _cubit.load(),
                          );
                        }

                        List<DepartmentModel> departments = [];
                        int totalCount = 0;
                        int currentPage = 1;
                        int totalPages = 1;

                        if (state is DepartmentsLoaded) {
                          departments = state.departments;
                          totalCount = state.totalCount;
                          currentPage = state.currentPage;
                          totalPages = state.totalPages;
                        }

                        if (departments.isEmpty) {
                          return AcEmptyState(
                            title: 'لا توجد أقسام',
                            message: 'ابدأ بإضافة قسم أكاديمي جديد بالنظام',
                            icon: const Icon(Icons.business_rounded),
                            actionLabel: 'إضافة قسم',
                            onAction: () => _showAddEditDepartment(),
                          );
                        }

                        return AcTableWithPagination<DepartmentModel>(
                          currentPage: currentPage,
                          totalPages: totalPages,
                          totalItems: totalCount,
                          onPageChanged: (page) => _cubit.load(page: page),
                          columns: [
                            AcTableColumn(
                              key: 'code',
                              label: 'الكود',
                              cellBuilder: (d, _) => Text(
                                d.code,
                                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                              ),
                              width: 120,
                            ),
                            AcTableColumn(
                              key: 'name_ar',
                              label: 'الاسم بالعربية',
                              cellBuilder: (d, _) => Text(d.nameAr),
                              flex: 2,
                            ),
                            AcTableColumn(
                              key: 'name_en',
                              label: 'الاسم بالإنجليزية',
                              cellBuilder: (d, _) => Text(d.nameEn),
                              flex: 2,
                            ),
                            AcTableColumn(
                              key: 'status',
                              label: 'الحالة',
                              cellBuilder: (d, _) {
                                final color = d.isActive ? AppColors.success500 : AppColors.textDisabled;
                                final text = d.isActive ? 'نشط' : 'غير نشط';
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: AppRadius.brPill,
                                  ),
                                  child: Text(
                                    text,
                                    style: AppTypography.bodySmall.copyWith(color: color, fontWeight: FontWeight.bold),
                                  ),
                                );
                              },
                              width: 100,
                            ),
                            AcTableColumn(
                              key: 'actions',
                              label: 'الإجراءات',
                              cellBuilder: (d, _) => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AcIconButton(
                                    icon: const Icon(Icons.edit_rounded),
                                    tooltip: CurriculumStrings.edit,
                                    onPressed: () => _showAddEditDepartment(department: d),
                                  ),
                                  AcIconButton(
                                    icon: const Icon(Icons.delete_outline_rounded),
                                    tooltip: CurriculumStrings.delete,
                                    variant: AcButtonVariant.danger,
                                    onPressed: () => _confirmDeleteDepartment(d),
                                  ),
                                ],
                              ),
                              width: 120,
                            ),
                          ],
                          rows: departments,
                        );
                      },
                    ),

                    // ── Tab 2: Programs ──
                    BlocBuilder<DepartmentsCubit, DepartmentsState>(
                      builder: (context, state) {
                        if (state is DepartmentsLoading) {
                          return const Center(child: AcLoadingState());
                        }

                        if (state is DepartmentsError && state is! DepartmentsLoaded) {
                          return AcErrorState(
                            title: CurriculumStrings.errorOccurred,
                            message: state.message,
                            onRetry: () => _cubit.load(),
                          );
                        }

                        List<ProgramModel> programs = [];
                        if (state is DepartmentsLoaded) {
                          programs = state.programs;
                        }

                        if (programs.isEmpty) {
                          return AcEmptyState(
                            title: 'لا توجد برامج دراسية',
                            message: 'ابدأ بإضافة برنامج دراسي جديد تابع لقسم أكاديمي',
                            icon: const Icon(Icons.school_rounded),
                            actionLabel: 'إضافة برنامج',
                            onAction: () => _showAddEditProgram(),
                          );
                        }

                        return AcDataTable<ProgramModel>(
                          columns: [
                            AcTableColumn(
                              key: 'code',
                              label: 'الكود',
                              cellBuilder: (p, _) => Text(
                                p.code,
                                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                              ),
                              width: 120,
                            ),
                            AcTableColumn(
                              key: 'name_ar',
                              label: 'الاسم بالعربية',
                              cellBuilder: (p, _) => Text(p.nameAr),
                              flex: 2,
                            ),
                            AcTableColumn(
                              key: 'name_en',
                              label: 'الاسم بالإنجليزية',
                              cellBuilder: (p, _) => Text(p.nameEn),
                              flex: 2,
                            ),
                            AcTableColumn(
                              key: 'type',
                              label: 'نوع البرنامج',
                              cellBuilder: (p, _) {
                                final text = switch (p.programType) {
                                  'regular' => 'انتظام',
                                  'evening' => 'مسائي',
                                  'parallel' => 'موازي',
                                  _ => p.programType,
                                };
                                return Text(text);
                              },
                            ),
                            AcTableColumn(
                              key: 'status',
                              label: 'الحالة',
                              cellBuilder: (p, _) {
                                final color = p.isActive ? AppColors.success500 : AppColors.textDisabled;
                                final text = p.isActive ? 'نشط' : 'غير نشط';
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: AppRadius.brPill,
                                  ),
                                  child: Text(
                                    text,
                                    style: AppTypography.bodySmall.copyWith(color: color, fontWeight: FontWeight.bold),
                                  ),
                                );
                              },
                              width: 100,
                            ),
                            AcTableColumn(
                              key: 'actions',
                              label: 'الإجراءات',
                              cellBuilder: (p, _) => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AcIconButton(
                                    icon: const Icon(Icons.edit_rounded),
                                    tooltip: CurriculumStrings.edit,
                                    onPressed: () => _showAddEditProgram(program: p),
                                  ),
                                  AcIconButton(
                                    icon: const Icon(Icons.delete_outline_rounded),
                                    tooltip: CurriculumStrings.delete,
                                    variant: AcButtonVariant.danger,
                                    onPressed: () => _confirmDeleteProgram(p),
                                  ),
                                ],
                              ),
                              width: 120,
                            ),
                          ],
                          rows: programs,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
