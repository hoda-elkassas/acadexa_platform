// file: lib/features/admin/screens/audit_logs_screen.dart
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final List<Map<String, dynamic>> _mockLogs = [
    {
      'action': 'تسجيل دخول',
      'user': 'م. مصطفى الشريف',
      'role': 'admin',
      'timestamp': '2026-06-10 10:05:22',
      'details': 'تم تسجيل الدخول من IP 192.168.1.15',
      'type': 'info',
    },
    {
      'action': 'تعديل صلاحيات مستخدم',
      'user': 'م. مصطفى الشريف',
      'role': 'admin',
      'timestamp': '2026-06-10 09:45:10',
      'details': 'تغيير صلاحية (خالد السليمان) من user إلى academic_advisor',
      'type': 'warning',
    },
    {
      'action': 'حذف خطة دراسية',
      'user': 'م. مصطفى الشريف',
      'role': 'admin',
      'timestamp': '2026-06-09 16:30:00',
      'details': 'حذف خطة (علوم الحاسب - 2020) من النظام',
      'type': 'danger',
    },
    {
      'action': 'إضافة مقرر',
      'user': 'د. عبد الله المالكي',
      'role': 'department_head',
      'timestamp': '2026-06-09 14:15:33',
      'details': 'إضافة مقرر CS499 - مشروع التخرج',
      'type': 'success',
    },
    {
      'action': 'تحليل أكاديمي',
      'user': 'النظام الخبير',
      'role': 'system',
      'timestamp': '2026-06-09 12:00:00',
      'details': 'تم تحليل 245 طالب - 12 إنذار جديد',
      'type': 'info',
    },
  ];

  IconData _iconForType(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle_outline_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'danger':
        return Icons.error_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'success':
        return AppColors.success500;
      case 'warning':
        return AppColors.warning500;
      case 'danger':
        return AppColors.danger500;
      default:
        return AppColors.primary500;
    }
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
              'سجل العمليات والمراجعة',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'تتبع جميع العمليات التي أجراها المستخدمون والنظام الخبير.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: ListView.separated(
                itemCount: _mockLogs.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final log = _mockLogs[index];
                  final type = log['type'] as String;

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      side: BorderSide(color: _colorForType(type).withValues(alpha: 0.3)),
                    ),
                    color: _colorForType(type).withValues(alpha: 0.03),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: _colorForType(type).withValues(alpha: 0.12),
                            child: Icon(_iconForType(type), color: _colorForType(type), size: 20),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      log['action'],
                                      style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    Text(
                                      log['timestamp'],
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'بواسطة: ${log['user']}',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  log['details'],
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
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
