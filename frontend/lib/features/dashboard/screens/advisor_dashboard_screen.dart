// file: lib/features/dashboard/advisor/advisor_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_gradients.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/buttons/ac_button.dart';
import '../../../shared/widgets/cards/ac_card.dart';
import '../../../shared/widgets/charts/ac_charts.dart';
import '../../../shared/widgets/chips/ac_chips.dart';
import '../../../shared/widgets/states/ac_states.dart';
import '../../../shared/widgets/tables/ac_data_table.dart';
import '../../../shared/widgets/navigation/ac_navigation.dart';

// ─── Data contracts ───────────────────────────────────────────────────────
class AdvisorProfileData {
  const AdvisorProfileData({
    required this.name,
    required this.department,
    required this.adviseeCount,
    this.avatarUrl,
  });
  final String name;
  final String department;
  final int adviseeCount;
  final String? avatarUrl;
}

class AdvisorKpiData {
  const AdvisorKpiData({
    required this.totalAdvisees,
    required this.atRiskCount,
    required this.pendingRequests,
    required this.averageGpa,
    required this.thisWeekMeetings,
  });
  final int totalAdvisees;
  final int atRiskCount;
  final int pendingRequests;
  final double averageGpa;
  final int thisWeekMeetings;
}

class AdviseeRowData {
  const AdviseeRowData({
    required this.id,
    required this.name,
    required this.studentId,
    required this.program,
    required this.gpa,
    required this.completedHours,
    required this.riskLevel,
    required this.lastActivity,
    this.avatarUrl,
  });
  final String id;
  final String name;
  final String studentId;
  final String program;
  final double gpa;
  final int completedHours;
  final AcRiskLevel riskLevel;
  final DateTime lastActivity;
  final String? avatarUrl;
}

class RiskDistributionData {
  const RiskDistributionData({
    required this.low,
    required this.medium,
    required this.high,
    required this.critical,
  });
  final int low;
  final int medium;
  final int high;
  final int critical;
}

// ─── AdvisorDashboardScreen ───────────────────────────────────────────────
class AdvisorDashboardScreen extends StatefulWidget {
  const AdvisorDashboardScreen({
    super.key,
    required this.profileData,
    required this.kpiData,
    required this.advisees,
    required this.riskDistribution,
    this.isLoadingProfile = false,
    this.isLoadingKpi = false,
    this.isLoadingAdvisees = false,
    this.totalAdvisees = 0,
    this.currentPage = 1,
    this.totalPages = 1,
    this.onPageChanged,
    this.onAdviseeDetail,
    this.onSendMessage,
    this.onRefresh,
    this.onNotifications,
    this.notificationCount = 0,
    this.onSearchAdvisees,
    this.onFilterByRisk,
    this.searchQuery,
    this.riskFilter,
  });

  final AdvisorProfileData? profileData;
  final AdvisorKpiData? kpiData;
  final List<AdviseeRowData> advisees;
  final RiskDistributionData? riskDistribution;
  final bool isLoadingProfile;
  final bool isLoadingKpi;
  final bool isLoadingAdvisees;
  final int totalAdvisees;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int>? onPageChanged;
  final void Function(AdviseeRowData)? onAdviseeDetail;
  final void Function(AdviseeRowData)? onSendMessage;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onNotifications;
  final int notificationCount;
  final ValueChanged<String>? onSearchAdvisees;
  final ValueChanged<AcRiskLevel?>? onFilterByRisk;
  final String? searchQuery;
  final AcRiskLevel? riskFilter;

  @override
  State<AdvisorDashboardScreen> createState() => _AdvisorDashboardScreenState();
}

class _AdvisorDashboardScreenState extends State<AdvisorDashboardScreen> {
  int _navIndex = 0;

  static const _navItems = [
    AcNavItem(
      label: 'الرئيسية',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    AcNavItem(
      label: 'المرشدون',
      icon: Icons.people_outline,
      selectedIcon: Icons.people_rounded,
    ),
    AcNavItem(
      label: 'الطلبات',
      icon: Icons.inbox_outlined,
      selectedIcon: Icons.inbox_rounded,
    ),
    AcNavItem(
      label: 'التقارير',
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart_rounded,
    ),
    AcNavItem(
      label: 'الإعدادات',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AcAdaptiveLayout(
      navItems: _navItems,
      selectedIndex: _navIndex,
      onNavItemSelected: (i) => setState(() => _navIndex = i),
      userName: widget.profileData?.name,
      userRole: widget.profileData?.department,
      topBar: AcTopBar(
        title: _titleFor(_navIndex),
        subtitle: 'لوحة تحكم المشرف',
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
    0 => 'لوحة المشرف',
    1 => 'قائمة المرشدين',
    2 => 'الطلبات المعلقة',
    3 => 'التقارير والتحليلات',
    4 => 'الإعدادات',
    _ => 'Acadexa',
  };

  Widget _bodyFor(int i) => switch (i) {
    0 => _HomeTab(
      kpiData: widget.kpiData,
      advisees: widget.advisees,
      riskDistribution: widget.riskDistribution,
      isLoadingKpi: widget.isLoadingKpi,
      isLoadingAdvisees: widget.isLoadingAdvisees,
      totalAdvisees: widget.totalAdvisees,
      currentPage: widget.currentPage,
      totalPages: widget.totalPages,
      onPageChanged: widget.onPageChanged,
      onAdviseeDetail: widget.onAdviseeDetail,
      onSendMessage: widget.onSendMessage,
      onSearchAdvisees: widget.onSearchAdvisees,
      onFilterByRisk: widget.onFilterByRisk,
      searchQuery: widget.searchQuery,
      riskFilter: widget.riskFilter,
    ),
    _ => const Center(child: Text('قريباً', textDirection: TextDirection.rtl)),
  };
}

// ─── _HomeTab ─────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.kpiData,
    required this.advisees,
    required this.riskDistribution,
    required this.isLoadingKpi,
    required this.isLoadingAdvisees,
    required this.totalAdvisees,
    required this.currentPage,
    required this.totalPages,
    this.onPageChanged,
    this.onAdviseeDetail,
    this.onSendMessage,
    this.onSearchAdvisees,
    this.onFilterByRisk,
    this.searchQuery,
    this.riskFilter,
  });

  final AdvisorKpiData? kpiData;
  final List<AdviseeRowData> advisees;
  final RiskDistributionData? riskDistribution;
  final bool isLoadingKpi;
  final bool isLoadingAdvisees;
  final int totalAdvisees;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int>? onPageChanged;
  final void Function(AdviseeRowData)? onAdviseeDetail;
  final void Function(AdviseeRowData)? onSendMessage;
  final ValueChanged<String>? onSearchAdvisees;
  final ValueChanged<AcRiskLevel?>? onFilterByRisk;
  final String? searchQuery;
  final AcRiskLevel? riskFilter;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.insetPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── KPI strip ───────────────────────────────────────────
          _AdvisorKpiRow(kpiData: kpiData, isLoading: isLoadingKpi),
          const SizedBox(height: AppSpacing.lg),

          // ── Risk distribution ────────────────────────────────────
          LayoutBuilder(
            builder: (ctx, constraints) {
              final isWide = constraints.maxWidth > 700;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _RiskDistributionCard(
                        data: riskDistribution,
                        isLoading: isLoadingKpi,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 3,
                      child: _AtRiskAlert(
                        advisees: advisees
                            .where(
                              (a) =>
                                  a.riskLevel == AcRiskLevel.high ||
                                  a.riskLevel == AcRiskLevel.critical,
                            )
                            .take(4)
                            .toList(),
                        isLoading: isLoadingAdvisees,
                        onDetail: onAdviseeDetail,
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  _RiskDistributionCard(
                    data: riskDistribution,
                    isLoading: isLoadingKpi,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _AtRiskAlert(
                    advisees: advisees
                        .where(
                          (a) =>
                              a.riskLevel == AcRiskLevel.high ||
                              a.riskLevel == AcRiskLevel.critical,
                        )
                        .take(4)
                        .toList(),
                    isLoading: isLoadingAdvisees,
                    onDetail: onAdviseeDetail,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Advisees table ───────────────────────────────────────
          _AdviseesTable(
            advisees: advisees,
            isLoading: isLoadingAdvisees,
            totalAdvisees: totalAdvisees,
            currentPage: currentPage,
            totalPages: totalPages,
            onPageChanged: onPageChanged,
            onDetail: onAdviseeDetail,
            onSendMessage: onSendMessage,
            onSearch: onSearchAdvisees,
            onFilterRisk: onFilterByRisk,
            searchQuery: searchQuery,
            riskFilter: riskFilter,
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

// ─── _AdvisorKpiRow ───────────────────────────────────────────────────────
class _AdvisorKpiRow extends StatelessWidget {
  const _AdvisorKpiRow({required this.kpiData, required this.isLoading});

  final AdvisorKpiData? kpiData;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        title: 'إجمالي المرشدين',
        value: '${kpiData?.totalAdvisees ?? '--'}',
        icon: Icons.people_rounded,
        gradient: AppGradients.kpiPrimary,
      ),
      (
        title: 'في خطر',
        value: '${kpiData?.atRiskCount ?? '--'}',
        icon: Icons.warning_amber_rounded,
        gradient: AppGradients.kpiWarning,
      ),
      (
        title: 'طلبات معلقة',
        value: '${kpiData?.pendingRequests ?? '--'}',
        icon: Icons.inbox_rounded,
        gradient: AppGradients.kpiSecondary,
      ),
      (
        title: 'متوسط المعدل',
        value: kpiData?.averageGpa.toStringAsFixed(2) ?? '--',
        icon: Icons.school_rounded,
        gradient: AppGradients.kpiSuccess,
      ),
    ];

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isNarrow = constraints.maxWidth < 500;
        final count = isNarrow ? 2 : 4;
        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: isNarrow ? 1.15 : 1.35,
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

// ─── _RiskDistributionCard ────────────────────────────────────────────────
class _RiskDistributionCard extends StatelessWidget {
  const _RiskDistributionCard({required this.data, required this.isLoading});

  final RiskDistributionData? data;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final slices = data == null
        ? <AcPieSlice>[]
        : [
            AcPieSlice(
              label: 'منخفض',
              value: data!.low.toDouble(),
              color: AppColors.success500,
            ),
            AcPieSlice(
              label: 'متوسط',
              value: data!.medium.toDouble(),
              color: AppColors.warning500,
            ),
            AcPieSlice(
              label: 'عالي',
              value: data!.high.toDouble(),
              color: AppColors.danger500,
            ),
            AcPieSlice(
              label: 'حرج',
              value: data!.critical.toDouble(),
              color: AppColors.danger700,
            ),
          ];

    return AcSectionCard(
      title: 'توزيع مستوى الخطر',
      isLoading: isLoading,
      child: AcDonutChart(
        slices: slices,
        centerLabel: 'الطلاب',
        centerValue: data != null
            ? '${data!.low + data!.medium + data!.high + data!.critical}'
            : '--',
        size: 180,
        thickness: 28,
        isEmpty: data == null,
      ),
    );
  }
}

// ─── _AtRiskAlert ─────────────────────────────────────────────────────────
class _AtRiskAlert extends StatelessWidget {
  const _AtRiskAlert({
    required this.advisees,
    required this.isLoading,
    this.onDetail,
  });

  final List<AdviseeRowData> advisees;
  final bool isLoading;
  final void Function(AdviseeRowData)? onDetail;

  @override
  Widget build(BuildContext context) {
    return AcSectionCard(
      title: 'تنبيهات المخاطر العالية',
      trailing: advisees.isNotEmpty
          ? AcStatusChip(
              label: '${advisees.length} طلاب',
              status: AcStatusType.danger,
            )
          : null,
      isLoading: isLoading,
      child: advisees.isEmpty
          ? const AcEmptyState(
              title: 'لا يوجد طلاب في خطر عالٍ',
              icon: Icon(Icons.check_circle_outline_rounded),
              size: AcStateSize.small,
            )
          : Column(
              children: advisees
                  .map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _AtRiskRow(advisee: a, onDetail: onDetail),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _AtRiskRow extends StatelessWidget {
  const _AtRiskRow({required this.advisee, this.onDetail});

  final AdviseeRowData advisee;
  final void Function(AdviseeRowData)? onDetail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.danger50,
        borderRadius: AppRadius.brSm,
        border: Border.all(color: AppColors.danger500.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.danger100,
            backgroundImage: advisee.avatarUrl != null
                ? NetworkImage(advisee.avatarUrl!)
                : null,
            child: advisee.avatarUrl == null
                ? Text(
                    advisee.name.characters.first,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.danger700,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  advisee.name,
                  style: AppTypography.labelMedium,
                  textDirection: TextDirection.rtl,
                ),
                Row(
                  children: [
                    Text(
                      'GPA: ${advisee.gpa.toStringAsFixed(2)}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.danger500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    AcRiskBadge(level: advisee.riskLevel),
                  ],
                ),
              ],
            ),
          ),
          AcButton(
            label: 'عرض',
            onPressed: () => onDetail?.call(advisee),
            size: AcButtonSize.small,
            variant: AcButtonVariant.danger,
          ),
        ],
      ),
    );
  }
}

// ─── _AdviseesTable ───────────────────────────────────────────────────────
class _AdviseesTable extends StatelessWidget {
  const _AdviseesTable({
    required this.advisees,
    required this.isLoading,
    required this.totalAdvisees,
    required this.currentPage,
    required this.totalPages,
    this.onPageChanged,
    this.onDetail,
    this.onSendMessage,
    this.onSearch,
    this.onFilterRisk,
    this.searchQuery,
    this.riskFilter,
  });

  final List<AdviseeRowData> advisees;
  final bool isLoading;
  final int totalAdvisees;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int>? onPageChanged;
  final void Function(AdviseeRowData)? onDetail;
  final void Function(AdviseeRowData)? onSendMessage;
  final ValueChanged<String>? onSearch;
  final ValueChanged<AcRiskLevel?>? onFilterRisk;
  final String? searchQuery;
  final AcRiskLevel? riskFilter;

  List<AcTableColumn<AdviseeRowData>> get _columns => [
    AcTableColumn<AdviseeRowData>(
      key: 'name',
      label: 'الطالب',
      flex: 3,
      isSortable: true,
      cellBuilder: (row, _) => Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundImage: row.avatarUrl != null
                ? NetworkImage(row.avatarUrl!)
                : null,
            backgroundColor: AppColors.primary100,
            child: row.avatarUrl == null
                ? Text(row.name.characters.first, style: AppTypography.caption)
                : null,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  row.name,
                  style: AppTypography.labelMedium,
                  textDirection: TextDirection.rtl,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(row.studentId, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    ),
    AcTableColumn<AdviseeRowData>(
      key: 'program',
      label: 'البرنامج',
      flex: 2,
      cellBuilder: (row, _) => Text(
        row.program,
        style: AppTypography.bodySmall,
        textDirection: TextDirection.rtl,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    AcTableColumn<AdviseeRowData>(
      key: 'gpa',
      label: 'المعدل',
      flex: 1,
      isSortable: true,
      cellBuilder: (row, _) => AcAcademicChip(
        label: 'GPA',
        value: row.gpa.toStringAsFixed(2),
        colorByValue: true,
        maxValue: 4.0,
      ),
    ),
    AcTableColumn<AdviseeRowData>(
      key: 'risk',
      label: 'المخاطر',
      flex: 1,
      isSortable: true,
      cellBuilder: (row, _) => AcRiskBadge(level: row.riskLevel),
    ),
    AcTableColumn<AdviseeRowData>(
      key: 'actions',
      label: 'إجراءات',
      flex: 2,
      cellBuilder: (row, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AcButton(
            label: 'عرض',
            onPressed: () => onDetail?.call(row),
            size: AcButtonSize.small,
          ),
          const SizedBox(width: AppSpacing.xxs),
          AcIconButton(
            icon: const Icon(Icons.message_outlined),
            onPressed: () => onSendMessage?.call(row),
            size: AcButtonSize.small,
            tooltip: 'إرسال رسالة',
          ),
        ],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AcSectionCard(
      title: 'قائمة المرشدين',
      subtitle: '$totalAdvisees طالب مسجل',
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // ── Search + Filter ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: _SearchBar(value: searchQuery, onChanged: onSearch),
                ),
                const SizedBox(width: AppSpacing.sm),
                _RiskFilter(selected: riskFilter, onChanged: onFilterRisk),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── Table ────────────────────────────────────────────
          AcTableWithPagination<AdviseeRowData>(
            columns: _columns,
            rows: advisees,
            currentPage: currentPage,
            totalPages: totalPages,
            onPageChanged: onPageChanged ?? (_) {},
            totalItems: totalAdvisees,
            isLoading: isLoading,
            onRowTap: (row, _) => onDetail?.call(row),
            emptyTitle: 'لا يوجد طلاب',
            emptyMessage: 'لم يتم تسجيل أي طلاب بعد',
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({this.value, this.onChanged});
  final String? value;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: AppRadius.brInput,
        border: Border.all(color: AppColors.border, width: 1.5),
        color: AppColors.surface,
      ),
      child: TextField(
        onChanged: onChanged,
        textDirection: TextDirection.rtl,
        style: AppTypography.bodySmall,
        decoration: InputDecoration(
          hintText: 'بحث باسم الطالب أو الرقم الجامعي',
          hintStyle: AppTypography.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
          prefixIcon: const Icon(Icons.search_rounded, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
        ),
      ),
    );
  }
}

class _RiskFilter extends StatelessWidget {
  const _RiskFilter({this.selected, this.onChanged});
  final AcRiskLevel? selected;
  final ValueChanged<AcRiskLevel?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<AcRiskLevel?>(
      value: selected,
      hint: Text('كل المستويات', style: AppTypography.labelSmall),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(
            'كل المستويات',
            style: AppTypography.bodySmall,
            textDirection: TextDirection.rtl,
          ),
        ),
        ...AcRiskLevel.values.map(
          (l) => DropdownMenuItem(
            value: l,
            child: AcRiskBadge(level: l),
          ),
        ),
      ],
      onChanged: onChanged,
      underline: const SizedBox(),
      style: AppTypography.bodySmall,
      borderRadius: AppRadius.brSm,
    );
  }
}
