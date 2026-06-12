// file: lib/features/courses/screens/manage_courses_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/curriculum_strings.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/study_plan_model.dart';
import '../cubit/courses_cubit.dart';
import '../widgets/add_edit_course_dialog.dart';
import '../widgets/course_details_drawer.dart';

class ManageCoursesScreen extends StatefulWidget {
  const ManageCoursesScreen({super.key, required this.plan});

  final StudyPlanModel plan;

  @override
  State<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  final _searchController = TextEditingController();
  int _selectedLevel = 0;
  String _selectedTerm = '';
  String _selectedType = '';
  late final CoursesCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<CoursesCubit>();
    _cubit.loadCourses(planId: widget.plan.id!, page: 1);
    _cubit.subscribeToChanges(widget.plan.id!);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String val) {
    _cubit.loadCourses(planId: widget.plan.id!, page: 1, searchQuery: val);
  }

  void _onLevelFilterChanged(int? val) {
    setState(() => _selectedLevel = val ?? 0);
    _cubit.loadCourses(planId: widget.plan.id!, page: 1, level: _selectedLevel);
  }

  void _onTermFilterChanged(String? val) {
    setState(() => _selectedTerm = val ?? '');
    _cubit.loadCourses(planId: widget.plan.id!, page: 1, term: _selectedTerm);
  }

  void _onTypeFilterChanged(String? val) {
    setState(() => _selectedType = val ?? '');
    _cubit.loadCourses(planId: widget.plan.id!, page: 1, courseType: _selectedType);
  }

  void _showAddEditCourse({CourseModel? course}) {
    showDialog(
      context: context,
      builder: (_) => AddEditCourseDialog(
        planId: widget.plan.id!,
        course: course,
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

  void _confirmDelete(CourseModel course) {
    AcDialog.show(
      context,
      title: CurriculumStrings.confirmDelete,
      message: 'هل أنت متأكد من حذف المقرر ${course.nameAr} من الخطة الدراسية؟',
      type: AcDialogType.danger,
      confirmLabel: CurriculumStrings.delete,
      cancelLabel: CurriculumStrings.cancel,
    ).then((confirmed) {
      if (confirmed == true) {
        _cubit.deleteCourse(course.id!);
      }
    });
  }

  void _showDetails(CourseModel course) {
    showDrawer(
      context: context,
      child: CourseDetailsDrawer(course: course),
    );
  }

  void showDrawer({required BuildContext context, required Widget child}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.centerLeft,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text('${CurriculumStrings.courses} - ${widget.plan.name}'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
            child: AcButton(
              label: 'إضافة مقرر جديد',
              variant: AcButtonVariant.primary,
              leadingIcon: const Icon(Icons.add_rounded),
              onPressed: () => _showAddEditCourse(),
            ),
          ),
        ],
      ),
      body: BlocListener<CoursesCubit, CoursesState>(
        listener: (context, state) {
          if (state is CourseDeleted) {
            AcSnackbar.show(
              context,
              message: CurriculumStrings.deletedSuccessfully,
              type: AcToastType.success,
            );
          } else if (state is CoursesError) {
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
              // ─── Filters & Plan Stats ──────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Card(
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.brCard,
                        side: BorderSide(color: AppColors.border),
                      ),
                      color: AppColors.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: AcSearchField(
                                    controller: _searchController,
                                    hint: 'بحث باسم المقرر أو الرمز...',
                                    onChanged: _onSearch,
                                    onClear: () {
                                      _searchController.clear();
                                      _onSearch('');
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: AcDropdownField<int>(
                                    label: 'المستوى',
                                    value: _selectedLevel,
                                    onChanged: _onLevelFilterChanged,
                                    items: [
                                      const DropdownMenuItem(value: 0, child: Text('كل المستويات')),
                                      ...List.generate(12, (i) => i + 1).map(
                                        (l) => DropdownMenuItem(value: l, child: Text('المستوى $l')),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: AcDropdownField<String>(
                                    label: 'الفصل الدراسي',
                                    value: _selectedTerm,
                                    onChanged: _onTermFilterChanged,
                                    items: const [
                                      DropdownMenuItem(value: '', child: Text('كل الفصول')),
                                      DropdownMenuItem(value: 'fall', child: Text('الخريف')),
                                      DropdownMenuItem(value: 'spring', child: Text('الربيع')),
                                      DropdownMenuItem(value: 'summer', child: Text('الصيفي')),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: AcDropdownField<String>(
                                    label: 'نوع المقرر',
                                    value: _selectedType,
                                    onChanged: _onTypeFilterChanged,
                                    items: const [
                                      DropdownMenuItem(value: '', child: Text('كل الأنواع')),
                                      DropdownMenuItem(value: 'mandatory', child: Text('إجباري')),
                                      DropdownMenuItem(value: 'elective', child: Text('اختياري')),
                                      DropdownMenuItem(value: 'project', child: Text('مشروع تخرج')),
                                      DropdownMenuItem(value: 'training', child: Text('تدريب عملي')),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    flex: 1,
                    child: BlocBuilder<CoursesCubit, CoursesState>(
                      builder: (context, state) {
                        int totalCredits = 0;
                        int mandatoryCredits = 0;
                        int electiveCredits = 0;

                        if (state is CoursesLoaded) {
                          totalCredits = state.courses.fold(0, (sum, c) => sum + c.creditHours);
                          mandatoryCredits = state.courses
                              .where((c) => c.courseType == CourseType.mandatory)
                              .fold(0, (sum, c) => sum + c.creditHours);
                          electiveCredits = state.courses
                              .where((c) => c.courseType == CourseType.elective)
                              .fold(0, (sum, c) => sum + c.creditHours);
                        }

                        return Container(
                          height: 142,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.primary50,
                            borderRadius: AppRadius.brCard,
                            border: Border.all(color: AppColors.primary100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'إجمالي الساعات المسجلة بالخطة',
                                style: AppTypography.bodySmall.copyWith(color: AppColors.primary700),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Row(
                                textBaseline: TextBaseline.alphabetic,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                children: [
                                  Text(
                                    '$totalCredits',
                                    style: AppTypography.h1.copyWith(color: AppColors.primary600, fontSize: 36),
                                  ),
                                  const SizedBox(width: AppSpacing.xxs),
                                  Text(
                                    '/ ${widget.plan.totalCreditHours} ساعة',
                                    style: AppTypography.bodyMedium.copyWith(color: AppColors.primary700),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Row(
                                children: [
                                  Text('إجباري: $mandatoryCredits س', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                                  const SizedBox(width: AppSpacing.md),
                                  Text('اختياري: $electiveCredits س', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // ─── Courses Table List ─────────────────────────────────────────
              Expanded(
                child: BlocBuilder<CoursesCubit, CoursesState>(
                  builder: (context, state) {
                    if (state is CoursesLoading) {
                      return const Center(child: AcLoadingState());
                    }

                    if (state is CoursesError && state is! CoursesLoaded) {
                      return AcErrorState(
                        title: CurriculumStrings.errorOccurred,
                        message: state.message,
                        onRetry: () => _cubit.loadCourses(planId: widget.plan.id!),
                      );
                    }

                    List<CourseModel> courses = [];
                    int totalCount = 0;
                    int currentPage = 1;
                    int totalPages = 1;

                    if (state is CoursesLoaded) {
                      courses = state.courses;
                      totalCount = state.totalCount;
                      currentPage = state.currentPage;
                      totalPages = state.totalPages;
                    }

                    if (courses.isEmpty) {
                      return AcEmptyState(
                        title: 'لا توجد مقررات مضافة',
                        message: 'ابدأ بإضافة مقررات دراسية لهذه الخطة الأكاديمية',
                        icon: const Icon(Icons.book_rounded),
                        actionLabel: 'إضافة مقرر',
                        onAction: () => _showAddEditCourse(),
                      );
                    }

                    return AcTableWithPagination<CourseModel>(
                      currentPage: currentPage,
                      totalPages: totalPages,
                      totalItems: totalCount,
                      onPageChanged: (page) => _cubit.loadCourses(planId: widget.plan.id!, page: page),
                      columns: [
                        AcTableColumn(
                          key: 'code',
                          label: 'رمز المقرر',
                          cellBuilder: (c, _) => Text(
                            c.code,
                            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                          ),
                          width: 140,
                        ),
                        AcTableColumn(
                          key: 'name_ar',
                          label: 'الاسم بالعربية',
                          cellBuilder: (c, _) => InkWell(
                            onTap: () => _showDetails(c),
                            child: Text(
                              c.nameAr,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.primary500,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary500,
                              ),
                            ),
                          ),
                          flex: 2,
                        ),
                        AcTableColumn(
                          key: 'credit_hours',
                          label: 'الساعات المعتمدة',
                          cellBuilder: (c, _) => Text('${c.creditHours} ساعات'),
                          width: 130,
                        ),
                        AcTableColumn(
                          key: 'level',
                          label: 'المستوى الدراسي',
                          cellBuilder: (c, _) => Text('المستوى ${c.level}'),
                          width: 130,
                        ),
                        AcTableColumn(
                          key: 'term',
                          label: 'الفصل الموصى به',
                          cellBuilder: (c, _) {
                            final label = switch (c.term) {
                              'fall' => 'الخريف',
                              'spring' => 'الربيع',
                              'summer' => 'الصيفي',
                              _ => c.term,
                            };
                            return Text(label);
                          },
                          width: 130,
                        ),
                        AcTableColumn(
                          key: 'type',
                          label: 'نوع المقرر',
                          cellBuilder: (c, _) {
                            final (label, color) = switch (c.courseType.toJson()) {
                              'mandatory' => ('إجباري', AppColors.primary500),
                              'elective' => ('اختياري', AppColors.warning500),
                              'project' => ('مشروع تخرج', AppColors.success500),
                              'training' => ('تدريب ميداني', AppColors.aiPurple),
                              _ => (c.courseType.toJson(), AppColors.textPrimary)
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
                          width: 120,
                        ),
                        AcTableColumn(
                          key: 'actions',
                          label: 'الإجراءات',
                          cellBuilder: (c, _) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AcIconButton(
                                icon: const Icon(Icons.edit_rounded),
                                tooltip: CurriculumStrings.edit,
                                onPressed: () => _showAddEditCourse(course: c),
                              ),
                              AcIconButton(
                                icon: const Icon(Icons.delete_outline_rounded),
                                tooltip: CurriculumStrings.delete,
                                variant: AcButtonVariant.danger,
                                onPressed: () => _confirmDelete(c),
                              ),
                            ],
                          ),
                          width: 120,
                        ),
                      ],
                      rows: courses,
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
