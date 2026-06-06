// file: lib/features/courses/screens/course_details_drawer.dart
import 'package:flutter/material.dart';
import '../../../core/constants/curriculum_strings.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../data/models/course_model.dart';
import '../../../shared/widgets/widgets.dart';

class CourseDetailsDrawer extends StatelessWidget {
  const CourseDetailsDrawer({super.key, required this.course});

  final CourseModel course;

  @override
  Widget build(BuildContext context) {
    final grading = course.gradingConfig ?? CourseModel.defaultGradingConfig;

    return Drawer(
      width: 400,
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
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
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(course.nameAr, style: AppTypography.h3),
              if (course.nameEn != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  course.nameEn!,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
              const Divider(height: AppSpacing.xl),

              // ── Basic Info Details ──
              _buildInfoRow(CurriculumStrings.creditHours, '${course.creditHours} ساعات'),
              _buildInfoRow('توزيع الساعات (نظري/عملي/معمل)', '${course.theoryHours} ن / ${course.practicalHours} ع / ${course.labHours} م'),
              _buildInfoRow('المستوى الدراسي', 'المستوى ${course.level}'),
              _buildInfoRow('الفصل الموصى به', course.term == 'fall' ? 'الخريف' : (course.term == 'spring' ? 'الربيع' : 'الصيفي')),
              _buildInfoRow('نوع المقرر', course.courseType == 'mandatory' ? 'إجباري' : 'اختياري'),
              
              const Divider(height: AppSpacing.xl),

              // ── Grading Weights ──
              Text('توزيع الدرجات والتقييم', style: AppTypography.h5),
              const SizedBox(height: AppSpacing.sm),
              AcCard(
                child: Column(
                  children: [
                    _buildGradingRow('الامتحان النصفي', '${grading['midterm'] ?? 20}%'),
                    _buildGradingRow('أعمال الفصل الدراسي', '${grading['coursework'] ?? 20}%'),
                    _buildGradingRow('الاختبار النهائي (نظري)', '${grading['final_theory'] ?? 30}%'),
                    _buildGradingRow('الاختبار النهائي (عملي)', '${grading['final_practical'] ?? 30}%'),
                    const Divider(),
                    _buildGradingRow('الحد الأدنى للنجاح بالمقرر', '${grading['min_passing'] ?? 30}%', isBold: true),
                  ],
                ),
              ),

              const Spacer(),
              if (course.notes != null) ...[
                Text('ملاحظات إضافية', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  course.notes!,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
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
}
