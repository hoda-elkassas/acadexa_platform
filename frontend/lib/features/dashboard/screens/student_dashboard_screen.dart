// file: lib/features/dashboard/student/student_dashboard_screen.dart
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
import '../../../shared/widgets/navigation/ac_navigation.dart';
import '../../transcript/screens/plan_compliance_screen.dart';
import '../../transcript/screens/graduation_tracking_screen.dart';
import '../../expert_system/screens/smart_assistant_screen.dart';
import '../../profile/screens/profile_screen.dart';

// ─── Data contracts ───────────────────────────────────────────────────────
class StudentProfileData {
  const StudentProfileData({
    required this.name,
    required this.studentId,
    required this.program,
    required this.level,
    required this.avatarUrl,
  });
  final String name;
  final String studentId;
  final String program;
  final String level;
  final String? avatarUrl;
}

class AcademicSummaryData {
  const AcademicSummaryData({
    required this.gpa,
    required this.maxGpa,
    required this.completedHours,
    required this.requiredHours,
    required this.registeredCourses,
    required this.semesterNumber,
    required this.academicStanding,
    required this.riskLevel,
  });
  final double gpa;
  final double maxGpa;
  final int completedHours;
  final int requiredHours;
  final int registeredCourses;
  final int semesterNumber;
  final String academicStanding;
  final AcRiskLevel riskLevel;
}

class RecommendedCourseData {
  const RecommendedCourseData({
    required this.courseCode,
    required this.courseName,
    required this.creditHours,
    required this.aiConfidence,
    this.prerequisitesMet = true,
    this.isAvailableThisSemester = true,
  });
  final String courseCode;
  final String courseName;
  final int creditHours;
  final double aiConfidence;
  final bool prerequisitesMet;
  final bool isAvailableThisSemester;
}

class CurrentCourseData {
  const CurrentCourseData({
    required this.courseCode,
    required this.courseName,
    required this.creditHours,
    required this.currentGrade,
    required this.attendancePercent,
    required this.instructor,
  });
  final String courseCode;
  final String courseName;
  final int creditHours;
  final String currentGrade;
  final double attendancePercent;
  final String instructor;
}

class GpaTrendPoint {
  const GpaTrendPoint({required this.semester, required this.gpa});
  final String semester;
  final double gpa;
}

// ─── StudentDashboardScreen ───────────────────────────────────────────────
class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({
    super.key,
    required this.profileData,
    required this.summaryData,
    required this.recommendedCourses,
    required this.currentCourses,
    required this.gpaTrend,
    this.isLoadingProfile = false,
    this.isLoadingSummary = false,
    this.isLoadingCourses = false,
    this.isLoadingTrend = false,
    this.onRequestAdvisor,
    this.onCourseRegister,
    this.onCourseDetail,
    this.onRefresh,
    this.onNotifications,
    this.notificationCount = 0,
  });

  final StudentProfileData? profileData;
  final AcademicSummaryData? summaryData;
  final List<RecommendedCourseData> recommendedCourses;
  final List<CurrentCourseData> currentCourses;
  final List<GpaTrendPoint> gpaTrend;
  final bool isLoadingProfile;
  final bool isLoadingSummary;
  final bool isLoadingCourses;
  final bool isLoadingTrend;
  final VoidCallback? onRequestAdvisor;
  final void Function(RecommendedCourseData course)? onCourseRegister;
  final void Function(CurrentCourseData course)? onCourseDetail;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onNotifications;
  final int notificationCount;

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _navIndex = 0;

  static const _navItems = [
    AcNavItem(
      label: 'الرئيسية',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    AcNavItem(
      label: 'المقررات',
      icon: Icons.book_outlined,
      selectedIcon: Icons.book_rounded,
    ),
    AcNavItem(
      label: 'الجدول',
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today_rounded,
    ),
    AcNavItem(
      label: 'المشرف',
      icon: Icons.support_agent_outlined,
      selectedIcon: Icons.support_agent_rounded,
    ),
    AcNavItem(
      label: 'الملف',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AcAdaptiveLayout(
      navItems: _navItems,
      selectedIndex: _navIndex,
      onNavItemSelected: (i) => setState(() => _navIndex = i),
      userName: widget.profileData?.name,
      userRole: widget.profileData?.program,
      topBar: AcTopBar(
        title: _titleForIndex(_navIndex),
        actions: [
          AcIconButton(
            icon: const Icon(Icons.notifications_outlined),
            badge: widget.notificationCount > 0
                ? '${widget.notificationCount}'
                : null,
            onPressed: widget.onNotifications,
            tooltip: 'الإشعارات',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: widget.onRefresh ?? () async {},
        color: AppColors.primary500,
        child: _bodyForIndex(_navIndex),
      ),
    );
  }

  String _titleForIndex(int i) => switch (i) {
        0 => 'لوحة الطالب',
        1 => 'مقرراتي',
        2 => 'الجدول الدراسي',
        3 => 'المشرف الأكاديمي',
        4 => 'ملفي الشخصي',
        _ => 'Acadexa',
      };

  Widget _bodyForIndex(int i) => switch (i) {
        0 => _HomeTab(
            profileData: widget.profileData,
            summaryData: widget.summaryData,
            recommendedCourses: widget.recommendedCourses,
            currentCourses: widget.currentCourses,
            gpaTrend: widget.gpaTrend,
            isLoadingProfile: widget.isLoadingProfile,
            isLoadingSummary: widget.isLoadingSummary,
            isLoadingCourses: widget.isLoadingCourses,
            isLoadingTrend: widget.isLoadingTrend,
            onCourseRegister: widget.onCourseRegister,
            onCourseDetail: widget.onCourseDetail,
            onRequestAdvisor: widget.onRequestAdvisor,
          ),
        1 => const PlanComplianceScreen(),
        2 => const GraduationTrackingScreen(),
        3 => const SmartAssistantScreen(),
        4 => const ProfileScreen(),
        _ => const SizedBox.shrink(),
      };
}

// ─── _HomeTab ─────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.profileData,
    required this.summaryData,
    required this.recommendedCourses,
    required this.currentCourses,
    required this.gpaTrend,
    required this.isLoadingProfile,
    required this.isLoadingSummary,
    required this.isLoadingCourses,
    required this.isLoadingTrend,
    this.onCourseRegister,
    this.onCourseDetail,
    this.onRequestAdvisor,
  });

  final StudentProfileData? profileData;
  final AcademicSummaryData? summaryData;
  final List<RecommendedCourseData> recommendedCourses;
  final List<CurrentCourseData> currentCourses;
  final List<GpaTrendPoint> gpaTrend;
  final bool isLoadingProfile;
  final bool isLoadingSummary;
  final bool isLoadingCourses;
  final bool isLoadingTrend;
  final void Function(RecommendedCourseData)? onCourseRegister;
  final void Function(CurrentCourseData)? onCourseDetail;
  final VoidCallback? onRequestAdvisor;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.insetPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting header ─────────────────────────────────────
          _GreetingHeader(
            profileData: profileData,
            isLoading: isLoadingProfile,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── KPI row ─────────────────────────────────────────────
          _KpiRow(summaryData: summaryData, isLoading: isLoadingSummary),
          const SizedBox(height: AppSpacing.lg),

          // ── GPA Trend + Progress ─────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _GpaTrendCard(
                        trend: gpaTrend,
                        isLoading: isLoadingTrend,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: _AcademicProgressCard(
                        summaryData: summaryData,
                        isLoading: isLoadingSummary,
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  _GpaTrendCard(trend: gpaTrend, isLoading: isLoadingTrend),
                  const SizedBox(height: AppSpacing.md),
                  _AcademicProgressCard(
                    summaryData: summaryData,
                    isLoading: isLoadingSummary,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── AI Recommendations ───────────────────────────────────
          _AiRecommendationsSection(
            courses: recommendedCourses,
            isLoading: isLoadingCourses,
            onRegister: onCourseRegister,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Current courses ──────────────────────────────────────
          _CurrentCoursesSection(
            courses: currentCourses,
            isLoading: isLoadingCourses,
            onCourseDetail: onCourseDetail,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Advisor CTA ──────────────────────────────────────────
          if (onRequestAdvisor != null)
            _AdvisorCta(onRequest: onRequestAdvisor!),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

// ─── _GreetingHeader ──────────────────────────────────────────────────────
class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.profileData, required this.isLoading});

  final StudentProfileData? profileData;
  final bool isLoading;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'صباح الخير';
    if (h < 18) return 'مساء الخير';
    return 'مساء النور';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Row(
        children: [
          const AcSkeletonBox(height: 48, isCircle: true),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AcSkeletonBox(
                width: MediaQuery.of(context).size.width * 0.3,
                height: 20,
              ),
              const SizedBox(height: AppSpacing.xxs),
              AcSkeletonBox(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 14,
              ),
            ],
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryDiagonal,
        borderRadius: AppRadius.brCard,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary500.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: profileData?.avatarUrl != null
                ? NetworkImage(profileData!.avatarUrl!)
                : null,
            backgroundColor: AppColors.overlayLight,
            child: profileData?.avatarUrl == null
                ? Text(
                    profileData?.name.characters.first ?? '?',
                    style: AppTypography.h4.copyWith(color: AppColors.neutral0),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_greeting، ${profileData?.name ?? ''}',
                  style: AppTypography.h4.copyWith(color: AppColors.neutral0),
                  textDirection: TextDirection.rtl,
                ),
                Text(
                  '${profileData?.program ?? ''} | المستوى ${profileData?.level ?? ''}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral0.withValues(alpha: 0.85),
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          const AcRiskBadge(level: AcRiskLevel.low, showLabel: false),
        ],
      ),
    );
  }
}

// ─── _KpiRow ─────────────────────────────────────────────────────────────
class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.summaryData, required this.isLoading});

  final AcademicSummaryData? summaryData;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isNarrow = constraints.maxWidth < 500;
        final items = [
          _KpiItem(
            title: 'المعدل التراكمي',
            value: summaryData != null
                ? summaryData!.gpa.toStringAsFixed(2)
                : '--',
            icon: Icons.school_outlined,
            gradient: AppGradients.kpiPrimary,
            trend: null,
          ),
          _KpiItem(
            title: 'الساعات المكتملة',
            value:
                summaryData != null ? '${summaryData!.completedHours}' : '--',
            icon: Icons.check_circle_outline_rounded,
            gradient: AppGradients.kpiSuccess,
            trend: null,
          ),
          _KpiItem(
            title: 'مقررات الفصل',
            value: summaryData != null
                ? '${summaryData!.registeredCourses}'
                : '--',
            icon: Icons.book_outlined,
            gradient: AppGradients.kpiSecondary,
            trend: null,
          ),
          _KpiItem(
            title: 'الساعات المتبقية',
            value: summaryData != null
                ? '${summaryData!.requiredHours - summaryData!.completedHours}'
                : '--',
            icon: Icons.pending_outlined,
            gradient: AppGradients.kpiWarning,
            trend: null,
          ),
        ];

        if (isNarrow) {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.15,
            children: items.map((e) => _buildKpiCard(e, isLoading)).toList(),
          );
        }

        return Row(
          children: items
              .map(
                (e) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: e == items.last ? 0 : AppSpacing.sm,
                    ),
                    child: _buildKpiCard(e, isLoading),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildKpiCard(_KpiItem item, bool loading) {
    return AcKpiCard(
      title: item.title,
      value: item.value,
      icon: Icon(item.icon),
      gradient: item.gradient,
      isLoading: loading,
    );
  }
}

class _KpiItem {
  const _KpiItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.trend,
  });
  final String title;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  final String? trend;
}

// ─── _GpaTrendCard ────────────────────────────────────────────────────────
class _GpaTrendCard extends StatelessWidget {
  const _GpaTrendCard({required this.trend, required this.isLoading});

  final List<GpaTrendPoint> trend;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final series = [
      AcChartSeries(
        label: 'المعدل الفصلي',
        color: AppColors.primary500,
        points: trend.asMap().entries.map((e) {
          return AcChartPoint(x: e.key.toDouble(), y: e.value.gpa);
        }).toList(),
      ),
    ];

    return AcSectionCard(
      title: 'تطور المعدل',
      subtitle: 'على مدار الفصول الدراسية',
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

// ─── _AcademicProgressCard ────────────────────────────────────────────────
class _AcademicProgressCard extends StatelessWidget {
  const _AcademicProgressCard({
    required this.summaryData,
    required this.isLoading,
  });

  final AcademicSummaryData? summaryData;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AcSectionCard(
      title: 'التقدم الأكاديمي',
      isLoading: isLoading,
      child: Column(
        children: [
          AcProgressChart(
            label: 'الساعات المكتملة',
            value: summaryData != null
                ? summaryData!.completedHours / summaryData!.requiredHours
                : 0,
            displayValue: summaryData != null
                ? '${summaryData!.completedHours}/${summaryData!.requiredHours}'
                : '--',
            color: AppColors.primary500,
          ),
          const SizedBox(height: AppSpacing.sm),
          AcProgressChart(
            label: 'المعدل التراكمي',
            value: summaryData != null
                ? summaryData!.gpa / summaryData!.maxGpa
                : 0,
            displayValue: summaryData != null
                ? '${summaryData!.gpa.toStringAsFixed(2)}/${summaryData!.maxGpa.toStringAsFixed(1)}'
                : '--',
            color: summaryData != null && summaryData!.gpa >= 3.0
                ? AppColors.success500
                : AppColors.warning500,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الوضع الأكاديمي',
                style: AppTypography.labelMedium,
                textDirection: TextDirection.rtl,
              ),
              if (summaryData != null)
                AcStatusChip(
                  label: summaryData!.academicStanding,
                  status: summaryData!.riskLevel == AcRiskLevel.low
                      ? AcStatusType.active
                      : summaryData!.riskLevel == AcRiskLevel.medium
                          ? AcStatusType.warning
                          : AcStatusType.danger,
                )
              else
                const AcSkeletonBox(width: 80, height: 22),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── _AiRecommendationsSection ────────────────────────────────────────────
class _AiRecommendationsSection extends StatelessWidget {
  const _AiRecommendationsSection({
    required this.courses,
    required this.isLoading,
    this.onRegister,
  });

  final List<RecommendedCourseData> courses;
  final bool isLoading;
  final void Function(RecommendedCourseData)? onRegister;

  @override
  Widget build(BuildContext context) {
    return AcSectionCard(
      title: 'توصيات الذكاء الاصطناعي',
      subtitle: 'مقررات مقترحة للفصل القادم',
      isLoading: isLoading,
      trailing: const AcAiRecommendationChip(label: 'AI مدعوم'),
      child: isLoading
          ? const AcLoadingState(size: AcStateSize.small)
          : courses.isEmpty
              ? const AcEmptyState(
                  title: 'لا توجد توصيات حالياً',
                  message: 'سيتم تحليل بياناتك وإعداد التوصيات',
                  icon: Icon(Icons.auto_awesome_outlined),
                  size: AcStateSize.small,
                )
              : Column(
                  children: courses
                      .take(4)
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _RecommendedCourseRow(
                            course: c,
                            onRegister: onRegister,
                          ),
                        ),
                      )
                      .toList(),
                ),
    );
  }
}

class _RecommendedCourseRow extends StatelessWidget {
  const _RecommendedCourseRow({required this.course, this.onRegister});

  final RecommendedCourseData course;
  final void Function(RecommendedCourseData)? onRegister;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: AppRadius.brSm,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              gradient: AppGradients.aiSoft,
              borderRadius: AppRadius.brXs,
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: AppColors.aiPurple,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.courseName,
                  style: AppTypography.labelMedium,
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    Text(course.courseCode, style: AppTypography.caption),
                    const SizedBox(width: AppSpacing.xs),
                    AcAcademicChip(label: '${course.creditHours} ساعات'),
                    const SizedBox(width: AppSpacing.xs),
                    AcAiRecommendationChip(
                      label: 'ملاءمة',
                      confidence: course.aiConfidence,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          AcButton(
            label: 'تسجيل',
            onPressed: course.isAvailableThisSemester && course.prerequisitesMet
                ? () => onRegister?.call(course)
                : null,
            size: AcButtonSize.small,
            variant: AcButtonVariant.primary,
            isDisabled:
                !course.isAvailableThisSemester || !course.prerequisitesMet,
          ),
        ],
      ),
    );
  }
}

// ─── _CurrentCoursesSection ───────────────────────────────────────────────
class _CurrentCoursesSection extends StatelessWidget {
  const _CurrentCoursesSection({
    required this.courses,
    required this.isLoading,
    this.onCourseDetail,
  });

  final List<CurrentCourseData> courses;
  final bool isLoading;
  final void Function(CurrentCourseData)? onCourseDetail;

  @override
  Widget build(BuildContext context) {
    return AcSectionCard(
      title: 'مقررات الفصل الحالي',
      isLoading: isLoading,
      child: isLoading
          ? const AcListSkeleton(itemCount: 3)
          : courses.isEmpty
              ? const AcEmptyState(
                  title: 'لا توجد مقررات مسجلة',
                  size: AcStateSize.small,
                )
              : Column(
                  children: courses
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _CurrentCourseRow(
                            course: c,
                            onTap: onCourseDetail != null ? () => onCourseDetail!(c) : null,
                          ),
                        ),
                      )
                      .toList(),
                ),
    );
  }
}

class _CurrentCourseRow extends StatelessWidget {
  const _CurrentCourseRow({required this.course, this.onTap});

  final CurrentCourseData course;
  final VoidCallback? onTap;

  Color _gradeColor(String grade) {
    if (['A+', 'A', 'A-'].contains(grade)) return AppColors.success600;
    if (['B+', 'B', 'B-'].contains(grade)) return AppColors.primary500;
    if (['C+', 'C', 'C-'].contains(grade)) return AppColors.warning600;
    return AppColors.danger500;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.brSm,
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.courseName,
                    style: AppTypography.labelMedium,
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      Text(course.courseCode, style: AppTypography.caption),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        course.instructor,
                        style: AppTypography.caption,
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  AcProgressChart(
                    label: 'الحضور',
                    value: course.attendancePercent,
                    displayValue: '${(course.attendancePercent * 100).round()}%',
                    height: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              children: [
                Text(
                  course.currentGrade,
                  style: AppTypography.h3.copyWith(
                    color: _gradeColor(course.currentGrade),
                  ),
                ),
                Text('الدرجة', style: AppTypography.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _AdvisorCta ──────────────────────────────────────────────────────────
class _AdvisorCta extends StatelessWidget {
  const _AdvisorCta({required this.onRequest});

  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppGradients.aiSoft,
        borderRadius: AppRadius.brCard,
        border: Border.all(color: AppColors.aiPurple.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              gradient: AppGradients.ai,
              borderRadius: AppRadius.brSm,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: AppColors.neutral0,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تحدث مع مشرفك الأكاديمي',
                  style: AppTypography.h5,
                  textDirection: TextDirection.rtl,
                ),
                Text(
                  'احصل على توجيه مخصص من مشرفك',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AcButton(
            label: 'تواصل',
            onPressed: onRequest,
            variant: AcButtonVariant.ai,
            size: AcButtonSize.small,
            useGradient: true,
          ),
        ],
      ),
    );
  }
}
