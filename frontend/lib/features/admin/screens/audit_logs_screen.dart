// file: lib/features/admin/screens/audit_logs_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_typography.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final _supabase = Supabase.instance.client;

  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _logs = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final res = await _supabase
          .from('audit_logs')
          .select('*, app_users:changed_by(email, full_name)')
          .order('changed_at', ascending: false)
          .limit(50);
      if (mounted) {
        setState(() {
          _logs = (res as List).map((e) {
            final row = e as Map<String, dynamic>;
            final appUser = row['app_users'] as Map<String, dynamic>?;
            final userEmail = appUser?['email'] ?? '';
            final userFullName = appUser?['full_name'] ?? '';
            final userDisplay = userFullName.isNotEmpty 
                ? '$userFullName ($userEmail)' 
                : (userEmail.isNotEmpty ? userEmail : (row['changed_by'] ?? 'النظام'));

            return {
              'action': row['action'] ?? '',
              'user': userDisplay,
              'role': 'user',
              'timestamp': row['changed_at']?.toString() ?? '',
              'details': 'الجدول: ${row['table_name']} | المعرف: ${row['record_id']}',
              'type': row['action'] == 'DELETE' ? 'danger' : (row['action'] == 'INSERT' ? 'success' : 'info'),
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _errorMessage = 'فشل تحميل سجل التدقيق: ${e.toString()}'; _isLoading = false; });
      }
    }
  }

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
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadLogs, child: const Text('إعادة المحاولة')),
          ],
        ),
      );
    }
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
              child: _logs.isEmpty
                  ? const Center(
                      child: Text('لا توجد سجلات بعد.', style: TextStyle(color: AppColors.textSecondary)),
                    )
                  : ListView.separated(
                      itemCount: _logs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final log = _logs[index];
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
