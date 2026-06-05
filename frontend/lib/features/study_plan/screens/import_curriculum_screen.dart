// file: lib/features/study_plan/screens/import_curriculum_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/study_plan_model.dart';

class ImportCurriculumScreen extends StatefulWidget {
  const ImportCurriculumScreen({super.key, required this.plan});

  final StudyPlanModel plan;

  @override
  State<ImportCurriculumScreen> createState() => _ImportCurriculumScreenState();
}

class _ImportCurriculumScreenState extends State<ImportCurriculumScreen> {
  final _jsonController = TextEditingController();
  final _supabase = Supabase.instance.client;

  int _currentStep = 0;
  List<Map<String, dynamic>> _parsedData = [];
  List<String> _validationErrors = [];
  bool _isImporting = false;

  void _loadSampleJson() {
    final sample = [
      {
        "code": "CS101",
        "name_ar": "مقدمة في علوم الحاسب",
        "name_en": "Introduction to Computer Science",
        "credit_hours": 3,
        "lecture_hours": 2,
        "lab_hours": 2,
        "level": 1,
        "term": "fall",
        "course_type": "compulsory"
      },
      {
        "code": "MATH101",
        "name_ar": "حساب التفاضل والتكامل 1",
        "name_en": "Calculus I",
        "credit_hours": 4,
        "lecture_hours": 4,
        "lab_hours": 0,
        "level": 1,
        "term": "fall",
        "course_type": "compulsory"
      },
      {
        "code": "ENG101",
        "name_ar": "اللغة الإنجليزية الأكاديمية",
        "name_en": "Academic English",
        "credit_hours": 3,
        "lecture_hours": 3,
        "lab_hours": 0,
        "level": 1,
        "term": "fall",
        "course_type": "compulsory"
      }
    ];

    setState(() {
      _jsonController.text = const JsonEncoder.withIndent('  ').convert(sample);
    });
  }

  void _validateJson() {
    final text = _jsonController.text.trim();
    if (text.isEmpty) {
      AcSnackbar.show(
        context,
        message: 'يرجى إدخال نص JSON أولاً',
        type: AcToastType.error,
      );
      return;
    }

    try {
      final decoded = json.decode(text);
      if (decoded is! List) {
        setState(() {
          _validationErrors = ['يجب أن يكون ملف JSON مصفوفة من المقررات (Array).'];
          _parsedData = [];
        });
        return;
      }

      final List<Map<String, dynamic>> items = [];
      final List<String> errors = [];
      final Set<String> codes = {};

      for (int i = 0; i < decoded.length; i++) {
        final item = decoded[i];
        if (item is! Map<String, dynamic>) {
          errors.add('العنصر رقم ${i + 1} ليس كائناً صحيحاً.');
          continue;
        }

        final code = item['code']?.toString() ?? '';
        final nameAr = item['name_ar']?.toString() ?? '';
        final creditHours = int.tryParse(item['credit_hours']?.toString() ?? '') ?? 0;
        final level = int.tryParse(item['level']?.toString() ?? '') ?? 0;

        if (code.isEmpty) {
          errors.add('العنصر رقم ${i + 1}: رمز المقرر (code) مطلوب.');
        } else if (codes.contains(code)) {
          errors.add('تكرار رمز المقرر: $code.');
        } else {
          codes.add(code);
        }

        if (nameAr.isEmpty) {
          errors.add('المقرر $code: الاسم بالعربية (name_ar) مطلوب.');
        }
        if (creditHours <= 0) {
          errors.add('المقرر $code: الساعات المعتمدة يجب أن تكون أكبر من الصفر.');
        }
        if (level <= 0 || level > 12) {
          errors.add('المقرر $code: مستوى الدراسة (level) يجب أن يكون بين 1 و 12.');
        }

        items.add(item);
      }

      setState(() {
        _parsedData = items;
        _validationErrors = errors;
        if (errors.isEmpty) {
          _currentStep = 1;
        }
      });
    } catch (e) {
      setState(() {
        _validationErrors = ['خطأ في بنية JSON: ${e.toString()}'];
        _parsedData = [];
      });
    }
  }

  Future<void> _startImport() async {
    setState(() {
      _isImporting = true;
    });

    try {
      final listToInsert = _parsedData.map((e) {
        final model = CourseModel(
          planId: widget.plan.id!,
          code: e['code']?.toString() ?? '',
          nameAr: e['name_ar']?.toString() ?? '',
          nameEn: e['name_en']?.toString(),
          creditHours: int.tryParse(e['credit_hours']?.toString() ?? '3') ?? 3,
          theoryHours: int.tryParse(e['lecture_hours']?.toString() ?? '2') ?? 2,
          labHours: int.tryParse(e['lab_hours']?.toString() ?? '0') ?? 0,
          level: int.tryParse(e['level']?.toString() ?? '1') ?? 1,
          term: e['term']?.toString() ?? 'fall',
          courseType: e['course_type']?.toString() ?? 'compulsory',
        );
        return model.toInsertJson();
      }).toList();

      // Perform bulk insert
      await _supabase.from('courses').insert(listToInsert);

      setState(() {
        _isImporting = false;
        _currentStep = 2;
      });
    } catch (e) {
      setState(() {
        _isImporting = false;
      });
      AcSnackbar.show(
        context,
        message: 'فشل الاستيراد: ${e.toString()}',
        type: AcToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text('استيراد مقررات الخطة - ${widget.plan.name}'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Visual Step Progress Bar
            _buildProgressIndicator(),
            const SizedBox(height: AppSpacing.xl),

            // Step Content
            Expanded(
              child: _buildStepContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepLabel(0, 'إدخال البيانات', _currentStep >= 0),
        _buildStepLine(_currentStep >= 1),
        _buildStepLabel(1, 'المعاينة والتحقق', _currentStep >= 1),
        _buildStepLine(_currentStep >= 2),
        _buildStepLabel(2, 'النتيجة والاستيراد', _currentStep >= 2),
      ],
    );
  }

  Widget _buildStepLabel(int index, String label, bool isActive) {
    final color = isActive ? AppColors.primary500 : AppColors.textDisabled;
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: color,
          child: Text(
            '${index + 1}',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: isActive ? AppColors.textPrimary : AppColors.textDisabled,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      width: 100,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      color: isActive ? AppColors.primary500 : AppColors.border,
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildInputStep();
      case 1:
        return _buildPreviewStep();
      case 2:
        return _buildSuccessStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildInputStep() {
    return Card(
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.brCard,
        side: BorderSide(color: AppColors.border),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'أدخل هيكل المقررات بصيغة JSON',
                  style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                AcButton(
                  label: 'قالب تجريبي',
                  variant: AcButtonVariant.secondary,
                  leadingIcon: const Icon(Icons.code_rounded),
                  onPressed: _loadSampleJson,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: TextField(
                controller: _jsonController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '[\n  {\n    "code": "CS101", ...\n  }\n]',
                  hintStyle: TextStyle(color: AppColors.textDisabled),
                  filled: true,
                  fillColor: AppColors.neutral50,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.brCard,
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ),
            if (_validationErrors.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.danger50,
                  borderRadius: AppRadius.brSm,
                  border: Border.all(color: AppColors.danger200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _validationErrors
                      .map((err) => Text(
                            '• $err',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.danger700),
                          ))
                      .toList(),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AcButton(
                  label: 'تحليل البيانات والمتابعة',
                  variant: AcButtonVariant.primary,
                  leadingIcon: const Icon(Icons.analytics_rounded),
                  onPressed: _validateJson,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewStep() {
    return Column(
      children: [
        // Heading
        Card(
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.brCard,
            side: BorderSide(color: AppColors.border),
          ),
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, color: AppColors.success500),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'تم تحليل البيانات بنجاح: تم التعرف على ${_parsedData.length} مقرر جاهز للاستيراد.',
                  style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Preview table
        Expanded(
          child: AcDataTable<Map<String, dynamic>>(
            columns: [
              AcTableColumn(
                key: 'code',
                label: 'رمز المقرر',
                cellBuilder: (item, _) => Text(
                  item['code']?.toString() ?? '',
                  style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                width: 120,
              ),
              AcTableColumn(
                key: 'name_ar',
                label: 'الاسم بالعربية',
                cellBuilder: (item, _) => Text(item['name_ar']?.toString() ?? ''),
                flex: 3,
              ),
              AcTableColumn(
                key: 'credit_hours',
                label: 'ساعات معتمدة',
                cellBuilder: (item, _) => Text('${item['credit_hours']}'),
                width: 120,
              ),
              AcTableColumn(
                key: 'level',
                label: 'المستوى الدراسيل',
                cellBuilder: (item, _) => Text('المستوى ${item['level']}'),
                width: 120,
              ),
              AcTableColumn(
                key: 'term',
                label: 'الفصل الدراسي',
                cellBuilder: (item, _) {
                  final term = item['term']?.toString() ?? '';
                  final label = term == 'fall'
                      ? 'الخريف'
                      : term == 'spring'
                          ? 'الربيع'
                          : 'الصيف';
                  return Text(label);
                },
                width: 120,
              ),
              AcTableColumn(
                key: 'course_type',
                label: 'نوع المقرر',
                cellBuilder: (item, _) {
                  final type = item['course_type']?.toString() ?? 'compulsory';
                  final label = type == 'compulsory' ? 'إجباري' : 'اختياري';
                  return Text(label);
                },
                width: 120,
              ),
            ],
            rows: _parsedData,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Action Buttons
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AcButton(
                label: 'السابق',
                variant: AcButtonVariant.secondary,
                leadingIcon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() => _currentStep = 0),
              ),
              AcButton(
                label: 'تأكيد وبدء الاستيراد',
                variant: AcButtonVariant.primary,
                leadingIcon: _isImporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload_rounded),
                onPressed: _isImporting ? null : _startImport,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Center(
      child: Card(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.brCard,
          side: BorderSide(color: AppColors.border),
        ),
        color: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.success50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_rounded, color: AppColors.success500, size: 48),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'تم استيراد المقررات بنجاح!',
                style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'تم حفظ ${_parsedData.length} مقرر جديد بالكامل إلى قاعدة بيانات الخطة الدراسية بنجاح.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AcButton(
                label: 'العودة لقائمة المقررات',
                variant: AcButtonVariant.primary,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
