// file: lib/features/courses/screens/add_edit_course_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/curriculum_strings.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/grading_scale_model.dart';
import '../cubit/courses_cubit.dart';
import '../../study_plan/cubit/grading_cubit.dart';

class AddEditCourseDialog extends StatefulWidget {
  const AddEditCourseDialog({
    super.key,
    required this.planId,
    this.course,
  });

  final String planId;
  final CourseModel? course;

  @override
  State<AddEditCourseDialog> createState() => _AddEditCourseDialogState();
}

class _AddEditCourseDialogState extends State<AddEditCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _nameArController;
  late final TextEditingController _nameEnController;
  late final TextEditingController _creditsController;
  late final TextEditingController _theoryController;
  late final TextEditingController _practicalController;
  late final TextEditingController _labController;
  late final TextEditingController _fieldController;
  late final TextEditingController _notesController;

  int _selectedLevel = 1;
  String _selectedTerm = 'fall';
  String _selectedType = 'mandatory';
  String? _selectedGradingScaleId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final c = widget.course;
    _codeController = TextEditingController(text: c?.code ?? '');
    _nameArController = TextEditingController(text: c?.nameAr ?? '');
    _nameEnController = TextEditingController(text: c?.nameEn ?? '');
    _creditsController = TextEditingController(text: c?.creditHours.toString() ?? '3');
    _theoryController = TextEditingController(text: c?.theoryHours.toString() ?? '2');
    _practicalController = TextEditingController(text: c?.practicalHours.toString() ?? '0');
    _labController = TextEditingController(text: c?.labHours.toString() ?? '2');
    _fieldController = TextEditingController(text: c?.fieldHours.toString() ?? '0');
    _notesController = TextEditingController(text: c?.notes ?? '');

    _selectedLevel = c?.level ?? 1;
    _selectedTerm = c?.term ?? 'fall';
    _selectedType = c?.courseType ?? 'mandatory';
    _selectedGradingScaleId = c?.gradingScaleId;
    _isActive = c?.isActive ?? true;

    context.read<GradingCubit>().load(widget.planId);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameArController.dispose();
    _nameEnController.dispose();
    _creditsController.dispose();
    _theoryController.dispose();
    _practicalController.dispose();
    _labController.dispose();
    _fieldController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (!_formKey.currentState!.validate()) return;

    final newCourse = CourseModel(
      id: widget.course?.id,
      planId: widget.planId,
      code: _codeController.text.trim(),
      nameAr: _nameArController.text.trim(),
      nameEn: _nameEnController.text.trim().isEmpty ? null : _nameEnController.text.trim(),
      creditHours: int.parse(_creditsController.text.trim()),
      theoryHours: int.parse(_theoryController.text.trim()),
      practicalHours: int.parse(_practicalController.text.trim()),
      labHours: int.parse(_labController.text.trim()),
      fieldHours: int.parse(_fieldController.text.trim()),
      level: _selectedLevel,
      term: _selectedTerm,
      courseType: _selectedType,
      gradingScaleId: _selectedGradingScaleId,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      isActive: _isActive,
    );

    final cubit = context.read<CoursesCubit>();
    if (widget.course == null) {
      cubit.createCourse(newCourse).then((_) => Navigator.pop(context, true));
    } else {
      cubit.updateCourse(widget.course!.id!, newCourse).then((_) => Navigator.pop(context, true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.course == null ? 'إضافة مقرر دراسي' : 'تعديل مقرر دراسي';

    return AcFormDialog(
      title: title,
      confirmLabel: CurriculumStrings.save,
      onConfirm: _onConfirm,
      maxWidth: 680,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AcTextField(
                    controller: _codeController,
                    label: CurriculumStrings.courseCode,
                    hint: 'مثال: CPCS-204',
                    validator: (v) => v == null || v.isEmpty ? 'يرجى إدخال رمز المقرر' : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 3,
                  child: AcTextField(
                    controller: _nameArController,
                    label: 'اسم المقرر (بالعربية)',
                    hint: 'مثال: هياكل البيانات',
                    validator: (v) => v == null || v.isEmpty ? 'يرجى إدخال الاسم بالعربية' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AcTextField(
              controller: _nameEnController,
              label: 'اسم المقرر (بالإنجليزية)',
              hint: 'مثال: Data Structures',
              validator: (v) => v == null || v.isEmpty ? 'يرجى إدخال الاسم بالإنجليزية' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AcTextField(
                    controller: _creditsController,
                    label: CurriculumStrings.creditHours,
                    hint: '3',
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null ? 'رقم غير صحيح' : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AcTextField(
                    controller: _theoryController,
                    label: 'ساعات نظري',
                    hint: '2',
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null ? 'رقم غير صحيح' : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AcTextField(
                    controller: _labController,
                    label: 'ساعات معمل',
                    hint: '2',
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null ? 'رقم غير صحيح' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AcTextField(
                    controller: _practicalController,
                    label: 'ساعات عملي',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null ? 'رقم غير صحيح' : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AcTextField(
                    controller: _fieldController,
                    label: 'ساعات تدريب ميداني',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null ? 'رقم غير صحيح' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AcDropdownField<int>(
                    label: 'المستوى (الفصل الدراسي)',
                    value: _selectedLevel,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedLevel = val);
                      }
                    },
                    items: List.generate(12, (i) => i + 1).map((l) {
                      return DropdownMenuItem(
                        value: l,
                        child: Text('المستوى $l'),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AcDropdownField<String>(
                    label: 'الفصل الدراسي الرئيسي',
                    value: _selectedTerm,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedTerm = val);
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 'fall', child: Text('الفصل الأول (خريف)')),
                      DropdownMenuItem(value: 'spring', child: Text('الفصل الثاني (ربيع)')),
                      DropdownMenuItem(value: 'summer', child: Text('الفصل الصيفي')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AcDropdownField<String>(
                    label: 'نوع المقرر',
                    value: _selectedType,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedType = val);
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 'mandatory', child: Text('إجباري خطة')),
                      DropdownMenuItem(value: 'elective', child: Text('اختياري مجموعة')),
                      DropdownMenuItem(value: 'project', child: Text('مشروع تخرج')),
                      DropdownMenuItem(value: 'training', child: Text('تدريب عملي/ميداني')),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: BlocBuilder<GradingCubit, GradingState>(
                    builder: (context, state) {
                      List<GradingScaleModel> scales = [];
                      if (state is GradingLoaded) {
                        scales = state.scales;
                      }
                      return AcDropdownField<String>(
                        label: 'مقياس الدرجات المعتمد',
                        value: _selectedGradingScaleId,
                        hint: 'المقياس الافتراضي للخطة',
                        onChanged: (val) => setState(() => _selectedGradingScaleId = val),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('الافتراضي'),
                          ),
                          ...scales.map((s) => DropdownMenuItem(
                                value: s.id,
                                child: Text(s.nameAr),
                              )),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AcTextField(
              controller: _notesController,
              label: 'ملاحظات إضافية',
              hint: 'أية ملاحظات أو توجيهات حول هذا المقرر...',
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              title: const Text('نشط ومتاح للتسجيل'),
              subtitle: const Text('تعيين المقرر كنشط ومتاح للتسجيل الأكاديمي للطلاب'),
              value: _isActive,
              onChanged: (val) => setState(() => _isActive = val),
              activeColor: AppColors.primary500,
            ),
          ],
        ),
      ),
    );
  }
}
