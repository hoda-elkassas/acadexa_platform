import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class RecommendationsDashboardScreen extends StatefulWidget {
  const RecommendationsDashboardScreen({super.key});

  @override
  State<RecommendationsDashboardScreen> createState() => _RecommendationsDashboardScreenState();
}

class _RecommendationsDashboardScreenState extends State<RecommendationsDashboardScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _recommendations = [];
  String _filter = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final userId = _supabase.auth.currentUser?.id ?? '';
      final res = await _supabase.from('analysis_recommendations').select().eq('student_id', userId).order('created_at', ascending: false);
      setState(() {
        _recommendations = List<Map<String, dynamic>>.from(res as List);
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _errorMessage = 'فشل تحميل التوصيات: ${e.toString()}'; _isLoading = false; });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'الكل') return _recommendations;
    return _recommendations.where((r) {
      final priority = r['priority']?.toString() ?? 'medium';
      return priority == _filter;
    }).toList();
  }

  Color _priorityColor(String? priority) {
    switch (priority) {
      case 'high': return AppColors.danger500;
      case 'medium': return AppColors.warning500;
      case 'low': return AppColors.success500;
      default: return AppColors.primary500;
    }
  }

  String _priorityLabel(String? priority) {
    switch (priority) {
      case 'high': return 'عالية';
      case 'medium': return 'متوسطة';
      case 'low': return 'منخفضة';
      default: return 'عادية';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: AcLoadingState());
    if (_errorMessage.isNotEmpty) return AcErrorState(title: 'خطأ', message: _errorMessage, onRetry: _loadData);

    final filtered = _filtered;
    final highCount = _recommendations.where((r) => r['priority']?.toString() == 'high').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text('توصيات النظام الخبير', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold))),
              if (highCount > 0)
                AcStatusChip(label: '$highCount توصية عالية', status: AcStatusType.danger),
            ]),
            const SizedBox(height: AppSpacing.sm),
            Text('توصيات ذكية مبنية على تحليل البيانات', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xl),
            Row(children: [
              _buildFilterBtn('الكل'),
              const SizedBox(width: AppSpacing.sm),
              _buildFilterBtn('high'),
              const SizedBox(width: AppSpacing.sm),
              _buildFilterBtn('medium'),
              const SizedBox(width: AppSpacing.sm),
              _buildFilterBtn('low'),
            ]),
            const SizedBox(height: AppSpacing.md),
            if (filtered.isEmpty)
              const AcEmptyState(title: 'لا توجد توصيات', message: 'لم يصدر النظام الخبير أي توصيات بعد.', size: AcStateSize.small)
            else
              ...filtered.map((r) {
                final priority = r['priority']?.toString();
                final color = _priorityColor(priority);
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.brCard,
                    side: BorderSide(color: color.withValues(alpha: 0.3)),
                  ),
                  color: AppColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(children: [
                      Container(
                        width: 4, height: 48,
                        decoration: BoxDecoration(color: color, borderRadius: AppRadius.brXs),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(r['recommendation']?.toString() ?? '', style: AppTypography.bodyMedium, textDirection: TextDirection.rtl),
                        const SizedBox(height: AppSpacing.xs),
                        Text(r['category']?.toString() ?? '', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                      ])),
                      const SizedBox(width: AppSpacing.sm),
                      AcAcademicChip(label: _priorityLabel(priority), colorByValue: true, value: priority == 'high' ? '1' : (priority == 'medium' ? '2' : '3'), maxValue: 3),
                    ]),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBtn(String val) {
    final selected = _filter == val;
    final label = val == 'high' ? 'عالية' : (val == 'medium' ? 'متوسطة' : (val == 'low' ? 'منخفضة' : 'الكل'));
    return GestureDetector(
      onTap: () => setState(() => _filter = val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary500 : Colors.transparent,
          borderRadius: AppRadius.brPill,
          border: Border.all(color: selected ? AppColors.primary500 : AppColors.border),
        ),
        child: Text(label, style: AppTypography.labelSmall.copyWith(color: selected ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}
