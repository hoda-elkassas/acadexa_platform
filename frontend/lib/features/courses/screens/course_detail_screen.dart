import 'package:flutter/material.dart';
import '../../../core/constants/curriculum_strings.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../data/models/course_model.dart';
import '../../../data/services/course_service.dart';
import '../../../shared/widgets/widgets.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({
    super.key,
    required this.courseId,
    this.courseName,
  });

  final String courseId;
  final String? courseName;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final _service = CourseService();
  bool _isLoading = true;
  String _errorMessage = '';
  CourseModel? _course;

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      CourseModel course;
      try {
        course = await _service.getById(widget.courseId);
      } catch (_) {
        course = await _service.getByCode(widget.courseId);
      }
      if (mounted) {
        setState(() { _course = course; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _errorMessage = 'فشل تحميل بيانات المقرر: ${e.toString()}'; _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _course?.nameAr ?? widget.courseName ?? 'تفاصيل المقرر',
          style: AppTypography.h5,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const AcLoadingState(message: 'جاري تحميل بيانات المقرر...');
    if (_errorMessage.isNotEmpty) {
      return AcErrorState(
        title: 'خطأ في تحميل المقرر',
        message: _errorMessage,
        onRetry: _loadCourse,
      );
    }
    final course = _course;
    if (course == null) {
      return const AcEmptyState(
        title: 'المقرر غير موجود',
        message: 'لم يتم العثور على بيانات هذا المقرر',
      );
    }
    return _buildContent(course);
  }

  Widget _buildContent(CourseModel course) {
    final grading = course.gradingConfig ?? CourseModel.defaultGradingConfig;

    return SingleChildScrollView(
      padding: AppSpacing.insetPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Card ──
          AcCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: AppRadius.brSm,
                      ),
                      child: Text(
                        course.code,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.primary500,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _buildStatusBadge(course.isActive),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(course.nameAr, style: AppTypography.h3),
                if (course.nameEn != null && course.nameEn!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    course.nameEn!,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Basic Info ──
          AcCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('المعلومات الأساسية', style: AppTypography.h5),
                const SizedBox(height: AppSpacing.sm),
                _buildInfoRow(CurriculumStrings.creditHours, '${course.creditHours} ساعات'),
                _buildDivider(),
                _buildInfoRow('توزيع الساعات', 'نظري: ${course.theoryHours} | عملي: ${course.practicalHours} | معمل: ${course.labHours} | ميداني: ${course.fieldHours}'),
                _buildDivider(),
                _buildInfoRow('المستوى الدراسي', 'المستوى ${course.level}'),
                _buildDivider(),
                _buildInfoRow('الفصل الموصى به', course.term == 'fall' ? 'الخريف' : (course.term == 'spring' ? 'الربيع' : 'الصيفي')),
                _buildDivider(),
                _buildInfoRow('نوع المقرر', _courseTypeLabel(course.courseType)),
                if (course.notes != null && course.notes!.isNotEmpty) ...[
                  _buildDivider(),
                  _buildInfoRow('ملاحظات', course.notes!),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Grading Weights ──
          Text('توزيع الدرجات والتقييم', style: AppTypography.h5),
          const SizedBox(height: AppSpacing.sm),
          AcCard(
            child: Column(
              children: [
                _buildGradingRow('الامتحان النصفي', '${grading['midterm'] ?? 20}%'),
                _buildDivider(),
                _buildGradingRow('أعمال الفصل الدراسي', '${grading['coursework'] ?? 20}%'),
                _buildDivider(),
                _buildGradingRow('الاختبار النهائي (نظري)', '${grading['final_theory'] ?? 30}%'),
                _buildDivider(),
                _buildGradingRow('الاختبار النهائي (عملي)', '${grading['final_practical'] ?? 30}%'),
                const Divider(height: AppSpacing.lg),
                _buildGradingRow('الحد الأدنى للنجاح بالمقرر', '${grading['min_passing'] ?? 30}%', isBold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.success50 : AppColors.danger50,
        borderRadius: AppRadius.brPill,
      ),
      child: Text(
        isActive ? 'نشط' : 'غير نشط',
        style: AppTypography.caption.copyWith(
          color: isActive ? AppColors.success600 : AppColors.danger500,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _courseTypeLabel(CourseType type) {
    switch (type) {
      case CourseType.mandatory:
        return 'إجباري';
      case CourseType.elective:
        return 'اختياري';
      case CourseType.fieldTraining:
        return 'تدريب ميداني';
      case CourseType.graduationProject:
        return 'مشروع تخرج';
      case CourseType.universityMandatory:
        return 'متطلب جامعة إجباري';
      case CourseType.universityElective:
        return 'متطلب جامعة اختياري';
      case CourseType.collegeMandatory:
        return 'متطلب كلية إجباري';
      case CourseType.collegeElective:
        return 'متطلب كلية اختياري';
      case CourseType.departmentMandatory:
        return 'متطلب قسم إجباري';
      case CourseType.departmentElective:
        return 'متطلب قسم اختياري';
      case CourseType.freeElective:
        return 'اختياري حر';
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 3,
            child: Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
          ),
        ],
      ),
    );
  }

  Widget _buildGradingRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppColors.success500 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5));
  }
}
