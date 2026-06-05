// file: lib/features/study_plan/screens/plan_comparison_report_screen.dart
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../data/models/study_plan_model.dart';
import '../../../data/models/course_model.dart';
import '../../../data/services/study_plan_service.dart';
import '../../../data/services/course_service.dart';

class PlanComparisonReportScreen extends StatefulWidget {
  const PlanComparisonReportScreen({super.key, required this.plan});

  final StudyPlanModel plan;

  @override
  State<PlanComparisonReportScreen> createState() => _PlanComparisonReportScreenState();
}

class _PlanComparisonReportScreenState extends State<PlanComparisonReportScreen> {
  final _planService = StudyPlanService();
  final _courseService = CourseService();

  List<StudyPlanModel> _otherPlans = [];
  bool _loadingPlans = true;
  StudyPlanModel? _selectedPlan;

  // Comparison data
  bool _loadingCourses = false;

  // Analysis result
  List<CourseModel> _addedCourses = [];
  List<CourseModel> _deletedCourses = [];
  List<({CourseModel current, CourseModel compare})> _modifiedCourses = [];

  int _currentTotalHours = 0;
  int _compareTotalHours = 0;

  @override
  void initState() {
    super.initState();
    _loadOtherPlans();
  }

  Future<void> _loadOtherPlans() async {
    try {
      final res = await _planService.getAll(pageSize: 100);
      setState(() {
        _otherPlans = res.data.where((p) => p.id != widget.plan.id).toList();
        _loadingPlans = false;
      });
    } catch (e) {
      setState(() => _loadingPlans = false);
    }
  }

  Future<void> _runComparison(StudyPlanModel target) async {
    setState(() {
      _selectedPlan = target;
      _loadingCourses = true;
    });

    try {
      final currentList = await _courseService.getAllForPlan(widget.plan.id!);
      final compareList = await _courseService.getAllForPlan(target.id!);

      _analyze(currentList, compareList);
    } catch (e) {
      AcSnackbar.show(
        context,
        message: 'حدث خطأ أثناء مقارنة الخطط: ${e.toString()}',
        type: AcToastType.error,
      );
    } finally {
      setState(() {
        _loadingCourses = false;
      });
    }
  }

  void _analyze(List<CourseModel> current, List<CourseModel> compare) {
    final Map<String, CourseModel> currentMap = {for (var c in current) c.code: c};
    final Map<String, CourseModel> compareMap = {for (var c in compare) c.code: c};

    final added = <CourseModel>[];
    final deleted = <CourseModel>[];
    final modified = <({CourseModel current, CourseModel compare})>[];

    // Find deleted and modified
    for (final c in current) {
      final comp = compareMap[c.code];
      if (comp == null) {
        deleted.add(c);
      } else {
        if (c.creditHours != comp.creditHours ||
            c.theoryHours != comp.theoryHours ||
            c.labHours != comp.labHours ||
            c.level != comp.level ||
            c.courseType != comp.courseType) {
          modified.add((current: c, compare: comp));
        }
      }
    }

    // Find added
    for (final comp in compare) {
      if (!currentMap.containsKey(comp.code)) {
        added.add(comp);
      }
    }

    // Calculate totals
    final currentSum = current.fold<int>(0, (sum, c) => sum + c.creditHours);
    final compareSum = compare.fold<int>(0, (sum, c) => sum + c.creditHours);

    setState(() {
      _addedCourses = added;
      _deletedCourses = deleted;
      _modifiedCourses = modified;
      _currentTotalHours = currentSum;
      _compareTotalHours = compareSum;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text('تقرير مقارنة الخطط الدراسية - ${widget.plan.name}'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: _loadingPlans
          ? const Center(child: AcLoadingState())
          : Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  // Top Selection Bar
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
                            child: AcDropdownField<StudyPlanModel>(
                              label: 'اختر الخطة المراد مقارنتها',
                              value: _selectedPlan,
                              onChanged: (val) {
                                if (val != null) {
                                  _runComparison(val);
                                }
                              },
                              items: _otherPlans.map((p) {
                                return DropdownMenuItem(
                                  value: p,
                                  child: Text('${p.name} (${p.academicYear})'),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Comparison results
                  Expanded(
                    child: _loadingCourses
                        ? const Center(child: AcLoadingState())
                        : _selectedPlan == null
                            ? AcEmptyState(
                                title: 'حدد خطة للمقارنة',
                                message: 'اختر خطة دراسية أخرى من القائمة العلوية لإجراء تحليل الفروقات وتغير الساعات المعتمدة تلقائياً',
                                icon: const Icon(Icons.compare_rounded),
                              )
                            : _buildReportBody(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildReportBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sidebar Metrics Summary
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildSectionHeader('ملخص الفروقات الأساسية'),
              const SizedBox(height: AppSpacing.md),
              AcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMetricRow('ساعات الخطة الحالية', '$_currentTotalHours ساعة', AppColors.primary500),
                    const Divider(height: AppSpacing.lg),
                    _buildMetricRow('ساعات الخطة المقارنة', '$_compareTotalHours ساعة', AppColors.textSecondary),
                    const Divider(height: AppSpacing.lg),
                    _buildMetricRow('المقررات المضافة', '${_addedCourses.length}', AppColors.success500),
                    const Divider(height: AppSpacing.lg),
                    _buildMetricRow('المقررات المحذوفة', '${_deletedCourses.length}', AppColors.danger500),
                    const Divider(height: AppSpacing.lg),
                    _buildMetricRow('المقررات المعدلة', '${_modifiedCourses.length}', AppColors.aiPurple),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),

        // Differences lists tabs
        Expanded(
          flex: 2,
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Container(
                  color: AppColors.surface,
                  child: TabBar(
                    labelColor: AppColors.primary500,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary500,
                    tabs: [
                      Tab(text: 'المقررات المضافة (${_addedCourses.length})'),
                      Tab(text: 'المقررات المحذوفة (${_deletedCourses.length})'),
                      Tab(text: 'المقررات المعدلة (${_modifiedCourses.length})'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Added
                      _buildAddedTab(),
                      // Deleted
                      _buildDeletedTab(),
                      // Modified
                      _buildModifiedTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
        Text(
          value,
          style: AppTypography.h5.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildAddedTab() {
    if (_addedCourses.isEmpty) {
      return const Center(child: Text('لا توجد مقررات مضافة'));
    }
    return AcDataTable<CourseModel>(
      columns: [
        AcTableColumn(
          key: 'code',
          label: 'رمز المقرر',
          cellBuilder: (c, _) => Text(c.code, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
        ),
        AcTableColumn(
          key: 'name_ar',
          label: 'الاسم بالعربية',
          cellBuilder: (c, _) => Text(c.nameAr),
        ),
        AcTableColumn(
          key: 'credit_hours',
          label: 'ساعات',
          cellBuilder: (c, _) => Text('${c.creditHours}'),
        ),
        AcTableColumn(
          key: 'level',
          label: 'المستوى الدراسي',
          cellBuilder: (c, _) => Text('المستوى ${c.level}'),
        ),
      ],
      rows: _addedCourses,
    );
  }

  Widget _buildDeletedTab() {
    if (_deletedCourses.isEmpty) {
      return const Center(child: Text('لا توجد مقررات محذوفة'));
    }
    return AcDataTable<CourseModel>(
      columns: [
        AcTableColumn(
          key: 'code',
          label: 'رمز المقرر',
          cellBuilder: (c, _) => Text(c.code, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
        ),
        AcTableColumn(
          key: 'name_ar',
          label: 'الاسم بالعربية',
          cellBuilder: (c, _) => Text(c.nameAr),
        ),
        AcTableColumn(
          key: 'credit_hours',
          label: 'ساعات',
          cellBuilder: (c, _) => Text('${c.creditHours}'),
        ),
        AcTableColumn(
          key: 'level',
          label: 'المستوى الدراسي',
          cellBuilder: (c, _) => Text('المستوى ${c.level}'),
        ),
      ],
      rows: _deletedCourses,
    );
  }

  Widget _buildModifiedTab() {
    if (_modifiedCourses.isEmpty) {
      return const Center(child: Text('لا توجد مقررات معدلة'));
    }
    return AcDataTable<({CourseModel current, CourseModel compare})>(
      columns: [
        AcTableColumn(
          key: 'code',
          label: 'رمز المقرر',
          cellBuilder: (pair, _) => Text(pair.current.code, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
        ),
        AcTableColumn(
          key: 'name_ar',
          label: 'الاسم بالعربية',
          cellBuilder: (pair, _) => Text(pair.current.nameAr),
        ),
        AcTableColumn(
          key: 'credit_hours',
          label: 'الساعات (الحالي vs المقارن)',
          cellBuilder: (pair, _) => Text('${pair.current.creditHours} ← ${pair.compare.creditHours}'),
        ),
        AcTableColumn(
          key: 'level',
          label: 'المستوى (الحالي vs المقارن)',
          cellBuilder: (pair, _) => Text('المستوى ${pair.current.level} ← ${pair.compare.level}'),
        ),
      ],
      rows: _modifiedCourses,
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
