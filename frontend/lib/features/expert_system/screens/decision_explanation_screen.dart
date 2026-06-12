import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class DecisionExplanationScreen extends StatefulWidget {
  const DecisionExplanationScreen({super.key});

  @override
  State<DecisionExplanationScreen> createState() => _DecisionExplanationScreenState();
}

class _DecisionExplanationScreenState extends State<DecisionExplanationScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _latestAnalysis;
  List<Map<String, dynamic>> _issues = [];
  List<Map<String, dynamic>> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final userId = _supabase.auth.currentUser?.id ?? '';
      final analysisRes = await _supabase.from('analysis_results').select().eq('student_id', userId).eq('is_latest', true).maybeSingle();
      if (analysisRes != null) {
        final analysisId = analysisRes['id'] as String;
        final issuesRes = await _supabase.from('analysis_issues').select().eq('analysis_id', analysisId);
        final recsRes = await _supabase.from('analysis_recommendations').select().eq('analysis_id', analysisId);
        setState(() {
          _latestAnalysis = analysisRes;
          _issues = List<Map<String, dynamic>>.from(issuesRes as List);
          _recommendations = List<Map<String, dynamic>>.from(recsRes as List);
          _isLoading = false;
        });
      } else {
        setState(() { _isLoading = false; _errorMessage = 'لا يوجد تحليل بعد'; });
      }
    } catch (e) {
      setState(() { _errorMessage = 'فشل تحميل البيانات: ${e.toString()}'; _isLoading = false; });
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
            Text('شرح قرارات النظام الخبير', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            Text('تحليل مفصل لكيفية وسبب كل استنتاج', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xl),
            if (_latestAnalysis != null) ...[
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.brCard, side: const BorderSide(color: AppColors.border)),
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      _statItem('GPA', (_latestAnalysis!['gpa']?.toStringAsFixed(2) ?? (double.tryParse(_latestAnalysis!['gpa']?.toString() ?? '0') ?? 0.0).toStringAsFixed(2)), AppColors.primary600),
                      _statItem('مشاكل', '${_issues.length}', _issues.isEmpty ? AppColors.success500 : AppColors.danger500),
                      _statItem('توصيات', '${_recommendations.length}', AppColors.warning500),
                    ]),
                  ]),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (_issues.isNotEmpty) ...[
              Text('المشاكل المكتشفة (${_issues.length})', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.md),
              ..._issues.map((issue) => Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.brCard,
                  side: BorderSide(color: (issue['severity']?.toString() == 'error' ? AppColors.danger500 : AppColors.warning500).withValues(alpha: 0.3)),
                ),
                color: AppColors.surface,
                child: ListTile(
                  leading: Icon(
                    issue['severity']?.toString() == 'error' ? Icons.error_rounded : Icons.warning_rounded,
                    color: issue['severity']?.toString() == 'error' ? AppColors.danger500 : AppColors.warning500,
                  ),
                  title: Text(issue['title']?.toString() ?? '', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text(issue['description']?.toString() ?? '', style: AppTypography.bodySmall),
                ),
              )),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (_recommendations.isNotEmpty) ...[
              Text('التوصيات (${_recommendations.length})', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.md),
              ..._recommendations.map((rec) => Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.brCard, side: const BorderSide(color: AppColors.primary200)),
                color: AppColors.primary50.withValues(alpha: 0.3),
                child: ListTile(
                  leading: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.warning500),
                  title: Text(rec['recommendation']?.toString() ?? '', style: AppTypography.bodyMedium),
                ),
              )),
            ],
            if (_issues.isEmpty && _recommendations.isEmpty)
              const AcEmptyState(
                title: 'لا توجد نتائج',
                message: 'النظام الخبير لم يجد أي مشاكل أو توصيات. الأداء الأكاديمي جيد.',
                icon: Icon(Icons.check_circle_outline_rounded, size: 64, color: AppColors.success500),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(children: [
      Text(value, style: AppTypography.h4.copyWith(color: color, fontWeight: FontWeight.bold)),
      const SizedBox(height: AppSpacing.xxs),
      Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
    ]);
  }
}
