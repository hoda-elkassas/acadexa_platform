import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class ExpertSystemSettingsScreen extends StatefulWidget {
  const ExpertSystemSettingsScreen({super.key});

  @override
  State<ExpertSystemSettingsScreen> createState() => _ExpertSystemSettingsScreenState();
}

class _ExpertSystemSettingsScreenState extends State<ExpertSystemSettingsScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _rules = [];
  Map<String, dynamic>? _config;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final configRes = await _supabase.from('expert_system_config').select().maybeSingle();
      final rulesRes = await _supabase.from('expert_system_rules').select().order('rule_name');
      setState(() {
        _config = configRes;
        _rules = List<Map<String, dynamic>>.from(rulesRes as List);
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _errorMessage = 'فشل تحميل الإعدادات: ${e.toString()}'; _isLoading = false; });
    }
  }

  Future<void> _toggleRule(String ruleId, bool active) async {
    try {
      await _supabase.from('expert_system_rules').update({'is_active': active}).eq('id', ruleId);
      if (!mounted) return;
      AcSnackbar.show(context, message: 'تم تحديث حالة القاعدة', type: AcToastType.success);
      _loadData();
    } catch (e) {
      if (!mounted) return;
      AcSnackbar.show(context, message: 'فشل التحديث: ${e.toString()}', type: AcToastType.error);
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
            Text('إعدادات النظام الخبير', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            Text('تكوين قواعد الاستدلال والتحليل', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xl),
            if (_config != null) ...[
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.brCard, side: const BorderSide(color: AppColors.border)),
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('إعدادات عامة', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.md),
                    _configRow('الحد الأدنى للـ GPA', _config!['min_gpa']?.toString() ?? '2.0'),
                    _configRow('الحد الأقصى للإنذارات', _config!['max_warnings']?.toString() ?? '3'),
                    _configRow('تفعيل التحليل التلقائي', _config!['auto_analysis'] == true ? 'نعم' : 'لا'),
                  ]),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            Text('قواعد الاستدلال (${_rules.length})', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            if (_rules.isEmpty)
              const AcEmptyState(title: 'لا توجد قواعد', size: AcStateSize.small)
            else
              ..._rules.map((r) {
                final active = r['is_active'] == true;
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.brCard,
                    side: BorderSide(color: active ? AppColors.success200 : AppColors.border),
                  ),
                  color: AppColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(r['rule_name']?.toString() ?? '-', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(r['description']?.toString() ?? '', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: AppSpacing.xxs),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (r['severity']?.toString() == 'error' ? AppColors.danger500 : r['severity']?.toString() == 'warning' ? AppColors.warning500 : AppColors.primary500).withValues(alpha: 0.1),
                            borderRadius: AppRadius.brPill,
                          ),
                          child: Text(r['severity']?.toString() ?? '', style: AppTypography.caption),
                        ),
                      ])),
                      Switch(
                        value: active,
                        onChanged: (v) => _toggleRule(r['id'] as String, v),
                        activeColor: AppColors.primary500,
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

  Widget _configRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: AppTypography.bodyMedium),
        Text(value, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
