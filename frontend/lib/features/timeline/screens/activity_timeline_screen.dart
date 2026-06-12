import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class ActivityTimelineScreen extends StatefulWidget {
  const ActivityTimelineScreen({super.key});

  @override
  State<ActivityTimelineScreen> createState() => _ActivityTimelineScreenState();
}

class _ActivityTimelineScreenState extends State<ActivityTimelineScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _activities = [];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final res = await _supabase
          .from('audit_logs')
          .select('*, app_users:changed_by(email)')
          .order('changed_at', ascending: false)
          .limit(50);
      setState(() {
        _activities = (res as List).map((e) {
          final row = e as Map<String, dynamic>;
          final appUser = row['app_users'] as Map<String, dynamic>?;
          return {
            'action': row['action'] ?? '',
            'created_at': row['changed_at'] ?? '',
            'description': 'العملية على جدول: ${row['table_name']} | المعرف: ${row['record_id']}',
            'user_email': appUser?['email'] ?? row['changed_by'] ?? 'النظام',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _errorMessage = 'فشل تحميل النشاطات: ${e.toString()}'; _isLoading = false; });
    }
  }

  IconData _iconForAction(String? action) {
    switch (action) {
      case 'INSERT': return Icons.add_circle_outline_rounded;
      case 'UPDATE': return Icons.edit_rounded;
      case 'DELETE': return Icons.delete_outline_rounded;
      case 'LOGIN': return Icons.login_rounded;
      case 'LOGOUT': return Icons.logout_rounded;
      default: return Icons.info_outline_rounded;
    }
  }

  Color _colorForAction(String? action) {
    switch (action) {
      case 'INSERT': return AppColors.success500;
      case 'UPDATE': return AppColors.primary500;
      case 'DELETE': return AppColors.danger500;
      case 'LOGIN': return AppColors.secondary700;
      case 'LOGOUT': return AppColors.warning500;
      default: return AppColors.neutral400;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: AcLoadingState());
    if (_errorMessage.isNotEmpty) return AcErrorState(title: 'خطأ', message: _errorMessage, onRetry: _loadActivities);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _activities.isEmpty
          ? const Center(child: AcEmptyState(title: 'لا توجد نشاطات', message: 'لم يتم تسجيل أي نشاط بعد.'))
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                final a = _activities[index];
                final action = a['action']?.toString();
                final color = _colorForAction(action);
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(children: [
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.1)),
                          child: Icon(_iconForAction(action), color: color, size: 16),
                        ),
                        if (index < _activities.length - 1)
                          Expanded(child: Container(width: 2, color: AppColors.neutral200)),
                      ]),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.brCard, side: const BorderSide(color: AppColors.border)),
                          color: AppColors.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: AppRadius.brPill),
                                  child: Text(action ?? '-', style: AppTypography.caption.copyWith(color: color, fontWeight: FontWeight.bold)),
                                ),
                                const Spacer(),
                                Text(_formatDate(a['created_at']?.toString()), style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                              ]),
                              const SizedBox(height: AppSpacing.xs),
                              Text(a['description']?.toString() ?? a['message']?.toString() ?? '', style: AppTypography.bodySmall, textDirection: TextDirection.rtl),
                              if (a['user_email'] != null) ...[
                                const SizedBox(height: AppSpacing.xxs),
                                Text(a['user_email'].toString(), style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                              ],
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
