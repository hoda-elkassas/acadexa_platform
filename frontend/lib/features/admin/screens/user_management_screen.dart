// file: lib/features/admin/screens/user_management_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _users = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final res = await _supabase.from('v_users_with_roles').select();
      _users = List<Map<String, dynamic>>.from(res as List);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل تحميل المستخدمين: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'admin':
        return 'مسؤول النظام';
      case 'academic_advisor':
        return 'مرشد أكاديمي';
      case 'department_head':
        return 'رئيس قسم';
      case 'dashboard_viewer':
        return 'عارض لوحة البيانات';
      case 'user':
        return 'طالب';
      default:
        return role ?? 'غير معروف';
    }
  }

  Color _roleColor(String? role) {
    switch (role) {
      case 'admin':
        return AppColors.danger500;
      case 'academic_advisor':
        return AppColors.primary500;
      case 'department_head':
        return AppColors.warning500;
      default:
        return AppColors.neutral400;
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    final q = _searchQuery.toLowerCase();
    return _users.where((u) {
      final name = (u['full_name'] ?? '').toString().toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      return name.contains(q) || email.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: AcLoadingState());
    }

    if (_errorMessage.isNotEmpty) {
      return AcErrorState(
        title: 'خطأ',
        message: _errorMessage,
        onRetry: _loadUsers,
      );
    }

    final users = _filteredUsers;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إدارة المستخدمين والصلاحيات',
                        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'إجمالي المستخدمين: ${_users.length}',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                AcButton(
                  label: 'تحديث',
                  variant: AcButtonVariant.secondary,
                  onPressed: _loadUsers,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Search ──────────────────────────────────────────
            TextField(
              decoration: InputDecoration(
                hintText: 'بحث بالاسم أو البريد الإلكتروني...',
                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Table ───────────────────────────────────────────
            Expanded(
              child: users.isEmpty
                  ? const Center(
                      child: AcEmptyState(
                        title: 'لا توجد نتائج',
                        message: 'لم يتم العثور على مستخدمين مطابقين لبحثك.',
                      ),
                    )
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final u = users[index];
                        final role = u['role']?.toString();

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.brCard,
                            side: BorderSide(color: AppColors.border),
                          ),
                          color: AppColors.surface,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: _roleColor(role).withValues(alpha: 0.1),
                              child: Text(
                                (u['full_name']?.toString() ?? 'U').substring(0, 1).toUpperCase(),
                                style: AppTypography.labelLarge.copyWith(
                                  color: _roleColor(role),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              u['full_name']?.toString() ?? 'مستخدم غير معروف',
                              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              u['email']?.toString() ?? '',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _roleColor(role).withValues(alpha: 0.1),
                                borderRadius: AppRadius.brPill,
                              ),
                              child: Text(
                                _roleLabel(role),
                                style: AppTypography.bodySmall.copyWith(
                                  color: _roleColor(role),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
