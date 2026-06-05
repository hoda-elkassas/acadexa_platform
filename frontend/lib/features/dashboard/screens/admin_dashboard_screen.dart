// file: lib/features/dashboard/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_gradients.dart';
//import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/cards/ac_card.dart';
import '../../../shared/widgets/charts/ac_charts.dart';
import '../../../shared/widgets/chips/ac_chips.dart';
import '../../../shared/widgets/states/ac_states.dart';
import '../../../shared/widgets/navigation/ac_navigation.dart';
import '../../../shared/widgets/buttons/ac_button.dart';

// ─── Data contracts ───────────────────────────────────────────────────────
class AdminKpiData {
  const AdminKpiData({
    required this.totalStudents,
    required this.totalAdvisors,
    required this.activePrograms,
    required this.atRiskStudents,
    required this.avgGpaInstitution,
    required this.registrationRate,
    required this.graduationRate,
    required this.retentionRate,
  });
  final int totalStudents;
  final int totalAdvisors;
  final int activePrograms;
  final int atRiskStudents;
  final double avgGpaInstitution;
  final double registrationRate;
  final double graduationRate;
  final double retentionRate;
}

class DepartmentData {
  const DepartmentData({
    required this.name,
    required this.studentCount,
    required this.avgGpa,
    required this.atRiskPercent,
  });
  final String name;
  final int studentCount;
  final double avgGpa;
  final double atRiskPercent;
}

class EnrollmentTrendPoint {
  const EnrollmentTrendPoint({required this.semester, required this.count});
  final String semester;
  final int count;
}

class SystemActivityItem {
  const SystemActivityItem({
    required this.id,
    required this.message,
    required this.type,
    required this.timestamp,
  });
  final String id;
  final String message;
  final AcStatusType type;
  final DateTime timestamp;
}

// ─── AdminDashboardScreen ─────────────────────────────────────────────────
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({
    super.key,
    required this.kpiData,
    required this.departments,
    required this.enrollmentTrend,
    required this.recentActivity,
    this.isLoadingKpi = false,
    this.isLoadingDepts = false,
    this.isLoadingTrend = false,
    this.isLoadingActivity = false,
    this.adminName,
    this.onRefresh,
    this.onNotifications,
    this.notificationCount = 0,
  });

  final AdminKpiData? kpiData;
  final List<DepartmentData> departments;
  final List<EnrollmentTrendPoint> enrollmentTrend;
  final List<SystemActivityItem> recentActivity;
  final bool isLoadingKpi;
  final bool isLoadingDepts;
  final bool isLoadingTrend;
  final bool isLoadingActivity;
  final String? adminName;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onNotifications;
  final int notificationCount;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _navIndex = 0;

  static const _navItems = [
    AcNavItem(
      label: 'الرئيسية',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    AcNavItem(
      label: 'الطلاب',
      icon: Icons.people_outline,
      selectedIcon: Icons.people_rounded,
    ),
    AcNavItem(
      label: 'الأكاديمي',
      icon: Icons.account_balance_outlined,
      selectedIcon: Icons.account_balance_rounded,
    ),
    AcNavItem(
      label: 'التقارير',
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics_rounded,
    ),
    AcNavItem(
      label: 'النظام',
      icon: Icons.admin_panel_settings_outlined,
      selectedIcon: Icons.admin_panel_settings_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AcAdaptiveLayout(
      navItems: _navItems,
      selectedIndex: _navIndex,
      onNavItemSelected: (i) => setState(() => _navIndex = i),
      userName: widget.adminName,
      userRole: 'مسؤول النظام',
      topBar: AcTopBar(
        title: _titleFor(_navIndex),
        subtitle: 'لوحة الإدارة',
        actions: [
          AcIconButton(
            icon: const Icon(Icons.notifications_outlined),
            badge: widget.notificationCount > 0
                ? '${widget.notificationCount}'
                : null,
            onPressed: widget.onNotifications,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: widget.onRefresh ?? () async {},
        color: AppColors.primary500,
        child: _bodyFor(_navIndex),
      ),
    );
  }

  String _titleFor(int i) => switch (i) {
    0 => 'نظرة عامة',
    1 => 'إدارة الطلاب',
    2 => 'الهيكل الأكاديمي',
    3 => 'التقارير والإحصاءات',
    4 => 'إعدادات النظام',
    _ => 'Acadexa',
  };

  Widget _bodyFor(int i) => switch (i) {
    0 => _OverviewTab(
      kpiData: widget.kpiData,
      departments: widget.departments,
      enrollmentTrend: widget.enrollmentTrend,
      recentActivity: widget.recentActivity,
      isLoadingKpi: widget.isLoadingKpi,
      isLoadingDepts: widget.isLoadingDepts,
      isLoadingTrend: widget.isLoadingTrend,
      isLoadingActivity: widget.isLoadingActivity,
    ),
    _ => const Center(child: Text('قريباً', textDirection: TextDirection.rtl)),
  };
}

// ─── _OverviewTab ─────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.kpiData,
    required this.departments,
    required this.enrollmentTrend,
    required this.recentActivity,
    required this.isLoadingKpi,
    required this.isLoadingDepts,
    required this.isLoadingTrend,
    required this.isLoadingActivity,
  });

  final AdminKpiData? kpiData;
  final List<DepartmentData> departments;
  final List<EnrollmentTrendPoint> enrollmentTrend;
  final List<SystemActivityItem> recentActivity;
  final bool isLoadingKpi;
  final bool isLoadingDepts;
  final bool isLoadingTrend;
  final bool isLoadingActivity;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.insetPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top KPI strip ────────────────────────────────────────
          _AdminKpiGrid(kpiData: kpiData, isLoading: isLoadingKpi),
          const SizedBox(height: AppSpacing.lg),

          // ── Rates row ────────────────────────────────────────────
          _RatesSection(kpiData: kpiData, isLoading: isLoadingKpi),
          const SizedBox(height: AppSpacing.lg),

          // ── Enrollment trend + Departments ───────────────────────
          LayoutBuilder(
            builder: (ctx, constraints) {
              final isWide = constraints.maxWidth > 700;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _EnrollmentTrendCard(
                        trend: enrollmentTrend,
                        isLoading: isLoadingTrend,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: _DepartmentsCard(
                        departments: departments,
                        isLoading: isLoadingDepts,
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  _EnrollmentTrendCard(
                    trend: enrollmentTrend,
                    isLoading: isLoadingTrend,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DepartmentsCard(
                    departments: departments,
                    isLoading: isLoadingDepts,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── System activity ──────────────────────────────────────
          _SystemActivityCard(
            activity: recentActivity,
            isLoading: isLoadingActivity,
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

// ─── _AdminKpiGrid ────────────────────────────────────────────────────────
class _AdminKpiGrid extends StatelessWidget {
  const _AdminKpiGrid({required this.kpiData, required this.isLoading});

  final AdminKpiData? kpiData;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        title: 'إجمالي الطلاب',
        value: '${kpiData?.totalStudents ?? '--'}',
        gradient: AppGradients.kpiPrimary,
        icon: Icons.people_rounded,
      ),
      (
        title: 'المشرفون',
        value: '${kpiData?.totalAdvisors ?? '--'}',
        gradient: AppGradients.kpiSecondary,
        icon: Icons.school_rounded,
      ),
      (
        title: 'البرامج النشطة',
        value: '${kpiData?.activePrograms ?? '--'}',
        gradient: AppGradients.kpiSuccess,
        icon: Icons.book_rounded,
      ),
      (
        title: 'في خطر أكاديمي',
        value: '${kpiData?.atRiskStudents ?? '--'}',
        gradient: AppGradients.kpiWarning,
        icon: Icons.warning_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final count = constraints.maxWidth < 500 ? 2 : 4;
        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: count == 2 ? 1.3 : 1.5,
          children: items
              .map(
                (e) => AcKpiCard(
                  title: e.title,
                  value: e.value,
                  icon: Icon(e.icon),
                  gradient: e.gradient,
                  isLoading: isLoading,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

// ─── _RatesSection ────────────────────────────────────────────────────────
class _RatesSection extends StatelessWidget {
  const _RatesSection({required this.kpiData, required this.isLoading});

  final AdminKpiData? kpiData;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AcSectionCard(
      title: 'المؤشرات الأكاديمية',
      isLoading: isLoading,
      child: Column(
        children: [
          AcProgressChart(
            label: 'معدل التسجيل',
            value: kpiData?.registrationRate ?? 0,
            color: AppColors.primary500,
          ),
          const SizedBox(height: AppSpacing.sm),
          AcProgressChart(
            label: 'معدل التخرج',
            value: kpiData?.graduationRate ?? 0,
            color: AppColors.success500,
          ),
          const SizedBox(height: AppSpacing.sm),
          AcProgressChart(
            label: 'معدل الاستبقاء',
            value: kpiData?.retentionRate ?? 0,
            color: AppColors.secondary700,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'متوسط المعدل المؤسسي',
                style: AppTypography.labelMedium,
                textDirection: TextDirection.rtl,
              ),
              Text(
                kpiData?.avgGpaInstitution.toStringAsFixed(2) ?? '--',
                style: AppTypography.h4.copyWith(color: AppColors.primary500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── _EnrollmentTrendCard ─────────────────────────────────────────────────
class _EnrollmentTrendCard extends StatelessWidget {
  const _EnrollmentTrendCard({required this.trend, required this.isLoading});

  final List<EnrollmentTrendPoint> trend;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final series = [
      AcChartSeries(
        label: 'الطلاب المسجلون',
        color: AppColors.primary500,
        points: trend
            .asMap()
            .entries
            .map(
              (e) => AcChartPoint(
                x: e.key.toDouble(),
                y: e.value.count.toDouble(),
              ),
            )
            .toList(),
      ),
    ];

    return AcSectionCard(
      title: 'اتجاه القبول والتسجيل',
      subtitle: 'عبر الفصول الدراسية',
      isLoading: isLoading,
      child: AcLineChart(
        series: series,
        height: 200,
        isEmpty: trend.isEmpty,
        showLegend: false,
      ),
    );
  }
}

// ─── _DepartmentsCard ─────────────────────────────────────────────────────
class _DepartmentsCard extends StatelessWidget {
  const _DepartmentsCard({required this.departments, required this.isLoading});

  final List<DepartmentData> departments;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AcSectionCard(
      title: 'الأقسام',
      isLoading: isLoading,
      child: isLoading
          ? const AcListSkeleton(itemCount: 4)
          : departments.isEmpty
          ? const AcEmptyState(title: 'لا توجد أقسام', size: AcStateSize.small)
          : Column(
              children: departments
                  .take(6)
                  .map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _DeptRow(dept: d),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _DeptRow extends StatelessWidget {
  const _DeptRow({required this.dept});

  final DepartmentData dept;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                dept.name,
                style: AppTypography.labelMedium,
                textDirection: TextDirection.rtl,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                Text(
                  '${dept.studentCount}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                AcAcademicChip(
                  label: 'GPA',
                  value: dept.avgGpa.toStringAsFixed(2),
                  colorByValue: true,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        AcProgressChart(
          label: '',
          value: 1 - dept.atRiskPercent,
          height: 4,
          showValue: false,
          color: dept.atRiskPercent > 0.3
              ? AppColors.danger500
              : AppColors.primary500,
        ),
      ],
    );
  }
}

// ─── _SystemActivityCard ──────────────────────────────────────────────────
class _SystemActivityCard extends StatelessWidget {
  const _SystemActivityCard({required this.activity, required this.isLoading});

  final List<SystemActivityItem> activity;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AcSectionCard(
      title: 'سجل النشاط',
      subtitle: 'آخر الأحداث في النظام',
      isLoading: isLoading,
      child: isLoading
          ? const AcListSkeleton(itemCount: 5)
          : activity.isEmpty
          ? const AcEmptyState(title: 'لا توجد أنشطة', size: AcStateSize.small)
          : Column(
              children: activity
                  .take(8)
                  .map(
                    (a) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      child: _ActivityRow(item: a),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});

  final SystemActivityItem item;

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AcStatusChip(label: '', status: item.type, showDot: true),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.message,
                style: AppTypography.bodySmall,
                textDirection: TextDirection.rtl,
              ),
              Text(_formatTime(item.timestamp), style: AppTypography.caption),
            ],
          ),
        ),
      ],
    );
  }
}
