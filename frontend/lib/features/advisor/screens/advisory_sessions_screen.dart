// file: lib/features/advisor/screens/advisory_sessions_screen.dart
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class AdvisorySessionsScreen extends StatefulWidget {
  const AdvisorySessionsScreen({super.key});

  @override
  State<AdvisorySessionsScreen> createState() => _AdvisorySessionsScreenState();
}

class _AdvisorySessionsScreenState extends State<AdvisorySessionsScreen> {
  final List<Map<String, dynamic>> _mockSessions = [
    {
      'student_name': 'عمر عبد العزيز الماجد',
      'student_code': '441002394',
      'date': '10 يونيو 2026',
      'time': '10:00 ص - 10:30 ص',
      'type': 'حضوري - مكتب المرشد',
      'status': 'CONFIRMED',
    },
    {
      'student_name': 'فيصل بن محمد الحربي',
      'student_code': '442008472',
      'date': '11 يونيو 2026',
      'time': '11:15 ص - 11:45 ص',
      'type': 'عن بعد - MS Teams',
      'status': 'PENDING',
    },
  ];

  void _confirmSession(int index) {
    setState(() {
      _mockSessions[index]['status'] = 'CONFIRMED';
    });
    AcSnackbar.show(
      context,
      message: 'تم تأكيد موعد جلسة الإرشاد بنجاح',
      type: AcToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مواعيد وجلسات الإرشاد الأكاديمي',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'متابعة الطلبات وتأكيد الجلسات الاستشارية مع الطلاب.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: _mockSessions.isEmpty
                  ? const Center(
                      child: AcEmptyState(
                        title: 'لا يوجد جلسات مجدولة',
                        message: 'لا توجد جلسات إرشاد أكاديمي مسجلة في الوقت الحالي.',
                        icon: Icon(Icons.calendar_today_rounded),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _mockSessions.length,
                      itemBuilder: (context, index) {
                        final sess = _mockSessions[index];
                        final isPending = sess['status'] == 'PENDING';

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.brCard,
                            side: BorderSide(color: AppColors.border),
                          ),
                          color: AppColors.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.primary500.withValues(alpha: 0.1),
                                  child: const Icon(Icons.event_note_rounded, color: AppColors.primary600),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sess['student_name'],
                                        style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        'الوقت: ${sess['date']} | ${sess['time']}',
                                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                      ),
                                      Text(
                                        'الموقع/النوع: ${sess['type']}',
                                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isPending
                                            ? AppColors.warning500.withValues(alpha: 0.1)
                                            : AppColors.success500.withValues(alpha: 0.1),
                                        borderRadius: AppRadius.brPill,
                                      ),
                                      child: Text(
                                        isPending ? 'في الانتظار' : 'مؤكد',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: isPending ? AppColors.warning600 : AppColors.success600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (isPending) ...[
                                      const SizedBox(height: AppSpacing.sm),
                                      AcButton(
                                        label: 'تأكيد الموعد',
                                        variant: AcButtonVariant.primary,
                                        onPressed: () => _confirmSession(index),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
