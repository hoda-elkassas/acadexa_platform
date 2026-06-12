import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
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
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final res = await _supabase.from('v_users_with_roles').select().order('full_name');
      setState(() {
        _users = List<Map<String, dynamic>>.from(res as List);
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _errorMessage = 'فشل تحميل المستخدمين: ${e.toString()}'; _isLoading = false; });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_searchQuery.isEmpty) return _users;
    final q = _searchQuery.toLowerCase();
    return _users.where((u) {
      final name = u['full_name']?.toString().toLowerCase() ?? '';
      final email = u['email']?.toString().toLowerCase() ?? '';
      return name.contains(q) || email.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: AcLoadingState());
    if (_errorMessage.isNotEmpty) return AcErrorState(title: 'خطأ', message: _errorMessage, onRetry: _loadUsers);

    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('المستخدمين', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.sm),
              Text('عرض وإدارة جميع مستخدمي النظام', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.lg),
              AcSearchField(
                hint: 'بحث باسم المستخدم أو البريد الإلكتروني...',
                onChanged: (v) => setState(() => _searchQuery = v.trim()),
                onClear: () => setState(() => _searchQuery = ''),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(children: [
                Text('إجمالي المستخدمين: ', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                Text('${filtered.length}', style: AppTypography.h4.copyWith(color: AppColors.primary500, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: AppSpacing.md),
            ]),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: AcEmptyState(title: 'لا يوجد مستخدمين', message: 'لا توجد نتائج مطابقة للبحث.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final u = filtered[index];
                      final role = u['role_key']?.toString() ?? u['legacy_role']?.toString() ?? '-';
                      final isActive = u['is_active'] != false;
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.brCard, side: const BorderSide(color: AppColors.border)),
                        color: AppColors.surface,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary100,
                            child: Text((u['full_name']?.toString() ?? '?')[0], style: AppTypography.labelLarge.copyWith(color: AppColors.primary600, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(u['full_name']?.toString() ?? '-', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                          subtitle: Text(u['email']?.toString() ?? '', style: AppTypography.bodySmall),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (isActive ? AppColors.success500 : AppColors.danger500).withValues(alpha: 0.1),
                                  borderRadius: AppRadius.brPill,
                                ),
                                child: Text(isActive ? 'نشط' : 'غير نشط', style: AppTypography.bodySmall.copyWith(color: isActive ? AppColors.success600 : AppColors.danger500, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              AcAcademicChip(label: role),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
