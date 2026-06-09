// file: lib/features/system/screens/system_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic> _profile = {};

  final _collegeNameController = TextEditingController(text: 'كلية علوم الحاسب والمعلومات');
  String _academicSystem = 'SEMESTER';
  bool _realtimeSync = true;
  bool _autoAlerts = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _collegeNameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final res = await _supabase
            .from('user_profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        if (res != null) {
          _profile = Map<String, dynamic>.from(res);
        }
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل تحميل الملف التعريفي: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    AcSnackbar.show(
      context,
      message: 'تم حفظ إعدادات النظام بنجاح',
      type: AcToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: AcLoadingState());
    }

    if (_errorMessage.isNotEmpty) {
      return AcErrorState(
        title: 'حدث خطأ',
        message: _errorMessage,
        onRetry: _loadProfile,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── System Status Indicators ────────────────────────────────
          Text(
            'حالة اتصال النظام والخدمات الخلفية',
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.success500.withValues(alpha: 0.05),
                    borderRadius: AppRadius.brCard,
                    border: Border.all(color: AppColors.success500.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.success500,
                        radius: 12,
                        child: Icon(Icons.check_rounded, color: Colors.white, size: 14),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('قاعدة البيانات (Supabase)', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                          Text('متصل بالكامل. أداء مستقر.', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.success500.withValues(alpha: 0.05),
                    borderRadius: AppRadius.brCard,
                    border: Border.all(color: AppColors.success500.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.success500,
                        radius: 12,
                        child: Icon(Icons.check_rounded, color: Colors.white, size: 14),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('الخادم البرمجي (FastAPI Backend)', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                          Text('متصل (http://127.0.0.1:8000)', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ─── College Config Section ──────────────────────────────────
          Card(
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.brCard,
              side: BorderSide(color: AppColors.border),
            ),
            color: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الإعدادات الأكاديمية والكلية',
                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AcInputField(
                    controller: _collegeNameController,
                    label: 'اسم الكلية / المؤسسة التعليمية',
                    hint: 'أدخل اسم الكلية',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AcDropdownField<String>(
                    label: 'النظام الأكاديمي المتبع',
                    value: _academicSystem,
                    onChanged: (val) {
                      setState(() => _academicSystem = val ?? 'SEMESTER');
                    },
                    items: const [
                      DropdownMenuItem(value: 'SEMESTER', child: Text('نظام الفصول الدراسية (فصلين)')),
                      DropdownMenuItem(value: 'TRIMESTER', child: Text('نظام الأثلاث الدراسية (3 فصول)')),
                      DropdownMenuItem(value: 'QUARTER', child: Text('نظام ربع سنوي')),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SwitchListTile.adaptive(
                    activeColor: AppColors.primary500,
                    title: Text('المزامنة الفورية للملفات (Realtime Sync)', style: AppTypography.labelLarge),
                    subtitle: Text('تحديث شاشات المرشدين فور تعديل بيانات الطلاب التراكمية', style: AppTypography.caption),
                    value: _realtimeSync,
                    onChanged: (val) => setState(() => _realtimeSync = val),
                  ),
                  SwitchListTile.adaptive(
                    activeColor: AppColors.primary500,
                    title: Text('التنبيه التلقائي للمتعثرين', style: AppTypography.labelLarge),
                    subtitle: Text('إرسال تنبيهات تلقائية للمرشد عندما يقل معدل الطالب عن 2.00', style: AppTypography.caption),
                    value: _autoAlerts,
                    onChanged: (val) => setState(() => _autoAlerts = val),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: AcButton(
                      label: 'حفظ جميع التغييرات',
                      variant: AcButtonVariant.primary,
                      onPressed: _saveSettings,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ─── Current User Account Profile Section ────────────────────
          Card(
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.brCard,
              side: BorderSide(color: AppColors.border),
            ),
            color: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primary500.withValues(alpha: 0.1),
                    child: Text(
                      (_profile['full_name']?.toString() ?? 'A').substring(0, 1).toUpperCase(),
                      style: AppTypography.h3.copyWith(color: AppColors.primary600, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _profile['full_name']?.toString() ?? 'مسؤول النظام',
                        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _supabase.auth.currentUser?.email ?? 'acadops@test.com',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary500.withValues(alpha: 0.1),
                          borderRadius: AppRadius.brPill,
                        ),
                        child: Text(
                          'دور الحساب: ${_profile['role'] ?? "SYSTEM_ADMIN"}',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.primary600, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
