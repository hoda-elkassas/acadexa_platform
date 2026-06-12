import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class RolesPermissionsScreen extends StatefulWidget {
  const RolesPermissionsScreen({super.key});

  @override
  State<RolesPermissionsScreen> createState() => _RolesPermissionsScreenState();
}

class _RolesPermissionsScreenState extends State<RolesPermissionsScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _roles = [];
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final rolesRes = await _supabase.from('system_roles').select().order('role_name');
      final usersRes = await _supabase.from('v_users_with_roles').select().order('full_name');
      setState(() {
        _roles = List<Map<String, dynamic>>.from(rolesRes as List);
        _users = List<Map<String, dynamic>>.from(usersRes as List);
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _errorMessage = 'فشل تحميل البيانات: ${e.toString()}'; _isLoading = false; });
    }
  }

  Future<void> _updateUserRole(String userId, String newRole) async {
    try {
      await _supabase.from('app_users').update({'system_role': newRole}).eq('id', userId);
      if (!mounted) return;
      AcSnackbar.show(context, message: 'تم تحديث الصلاحية بنجاح', type: AcToastType.success);
      _loadData();
    } catch (e) {
      if (!mounted) return;
      AcSnackbar.show(context, message: 'فشل تحديث الصلاحية: ${e.toString()}', type: AcToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: AcLoadingState());
    if (_errorMessage.isNotEmpty) return AcErrorState(title: 'خطأ', message: _errorMessage, onRetry: _loadData);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الصّلاحيات والأدوار', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            Text('إدارة أدوار المستخدمين وصلاحيات النظام', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xl),
            Text('الأدوار (${_roles.length})', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            if (_roles.isEmpty)
              const AcEmptyState(title: 'لا توجد أدوار', size: AcStateSize.small)
            else
              ..._roles.map((r) => Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.brCard, side: const BorderSide(color: AppColors.border)),
                color: AppColors.surface,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary500.withValues(alpha: 0.1),
                    child: Text((r['role_name']?.toString() ?? '?')[0], style: AppTypography.labelLarge.copyWith(color: AppColors.primary600, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(r['role_name']?.toString() ?? '-', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text(r['description']?.toString() ?? '', style: AppTypography.bodySmall),
                  trailing: AcAcademicChip(label: r['role_key']?.toString() ?? ''),
                ),
              )),
            const SizedBox(height: AppSpacing.xl),
            Text('المستخدمين (${_users.length})', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            if (_users.isEmpty)
              const AcEmptyState(title: 'لا توجد مستخدمين', size: AcStateSize.small)
            else
              ..._users.map((u) {
                final role = u['role_key']?.toString() ?? u['legacy_role']?.toString() ?? '-';
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.brCard, side: const BorderSide(color: AppColors.border)),
                  color: AppColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary100,
                        child: Text((u['full_name']?.toString() ?? '?')[0], style: AppTypography.labelLarge.copyWith(color: AppColors.primary600)),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(u['full_name']?.toString() ?? '-', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                        Text(u['email']?.toString() ?? '', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                      ])),
                      DropdownButton<String>(
                        value: role,
                        underline: const SizedBox(),
                        items: _roles.map((r) => DropdownMenuItem(value: r['role_key'] as String, child: Text(r['role_name']?.toString() ?? ''))).toList(),
                        onChanged: (newRole) {
                          if (newRole != null && newRole != role) {
                            _updateUserRole(u['id'] as String, newRole);
                          }
                        },
                      ),
                    ]),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
