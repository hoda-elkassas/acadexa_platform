// file: lib/features/courses/screens/add_prerequisite_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/curriculum_strings.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/prerequisite_model.dart';
import '../../../data/services/course_service.dart';
import '../cubit/prerequisites_cubit.dart';

class AddPrerequisiteDialog extends StatefulWidget {
  const AddPrerequisiteDialog({
    super.key,
    required this.planId,
    this.prerequisite,
  });

  final String planId;
  final PrerequisiteModel? prerequisite;

  @override
  State<AddPrerequisiteDialog> createState() => _AddPrerequisiteDialogState();
}

class _AddPrerequisiteDialogState extends State<AddPrerequisiteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _courseService = CourseService();
  final _minGradeController = TextEditingController(text: '50');

  List<CourseModel> _courses = [];
  bool _loadingCourses = true;
  String? _selectedCourseId;
  String? _selectedRequiredCourseId;
  String _selectedLogic = 'ALL';
  bool _mustBePriorTerm = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
    if (widget.prerequisite != null) {
      final pr = widget.prerequisite!;
      _selectedCourseId = pr.courseId;
      _selectedRequiredCourseId = pr.requiredCourseId;
      _selectedLogic = pr.logic;
      _minGradeController.text = pr.minGrade.toString();
      _mustBePriorTerm = pr.mustBePriorTerm;
    }
  }

  @override
  void dispose() {
    _minGradeController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    try {
      final list = await _courseService.getAllForPlan(widget.planId);
      setState(() {
        _courses = list;
        _loadingCourses = false;
      });
    } catch (e) {
      setState(() => _loadingCourses = false);
      if (mounted) {
        AcSnackbar.show(
          context,
          message: 'فشل تحميل المقررات لإعداد المتطلبات السابقة',
          type: AcToastType.error,
        );
      }
    }
  }

  void _onConfirm() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null || _selectedRequiredCourseId == null) {
      AcSnackbar.show(
        context,
        message: 'يرجى تحديد المقرر والمتطلب السابق له',
        type: AcToastType.error,
      );
      return;
    }
    if (_selectedCourseId == _selectedRequiredCourseId) {
      AcSnackbar.show(
        context,
        message: 'لا يمكن للمقرر أن يكون متطلباً سابقاً لنفسه',
        type: AcToastType.error,
      );
      return;
    }

    final newPrereq = PrerequisiteModel(
      id: widget.prerequisite?.id,
      courseId: _selectedCourseId!,
      requiredCourseId: _selectedRequiredCourseId!,
      logic: _selectedLogic,
      minGrade: int.parse(_minGradeController.text.trim()),
      mustBePriorTerm: _mustBePriorTerm,
    );

    final cubit = context.read<PrerequisitesCubit>();
    if (widget.prerequisite == null) {
      cubit.create(newPrereq).then((_) => Navigator.pop(context, true));
    } else {
      cubit.update(widget.prerequisite!.id!, newPrereq).then((_) => Navigator.pop(context, true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.prerequisite == null ? 'إضافة متطلب سابق' : 'تعديل متطلب سابق';

    return AcFormDialog(
      title: title,
      confirmLabel: CurriculumStrings.save,
      onConfirm: _onConfirm,
      child: _loadingCourses
          ? const Center(child: AcLoadingState())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  AcDropdownField<String>(
                    label: 'المقرر الرئيسي',
                    value: _selectedCourseId,
                    hint: 'اختر المقرر الدراسي',
                    onChanged: (val) => setState(() => _selectedCourseId = val),
                    items: _courses.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text('${c.code} - ${c.nameAr}'),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AcDropdownField<String>(
                    label: 'المتطلب السابق المطلوب',
                    value: _selectedRequiredCourseId,
                    hint: 'اختر المقرر المطلوب اجتيازه أولاً',
                    onChanged: (val) => setState(() => _selectedRequiredCourseId = val),
                    items: _courses
                        .where((c) => c.id != _selectedCourseId)
                        .map((c) {
                          return DropdownMenuItem(
                            value: c.id,
                            child: Text('${c.code} - ${c.nameAr}'),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: AcDropdownField<String>(
                          label: 'نوع الشرط الأكاديمي',
                          value: _selectedLogic,
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedLogic = val);
                            }
                          },
                          items: const [
                            DropdownMenuItem(value: 'ALL', child: Text('إلزامي بالكامل (ALL)')),
                            DropdownMenuItem(value: 'ANY', child: Text('أحد الخيارات البديلة (ANY)')),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AcTextField(
                          controller: _minGradeController,
                          label: 'الحد الأدنى لدرجة النجاح',
                          hint: '50',
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || int.tryParse(v) == null ? 'رقم غير صحيح' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SwitchListTile(
                    title: const Text('يجب دراسته في فصل سابق'),
                    subtitle: const Text('يمنع تسجيل المقرر والمتطلب معاً في نفس الفصل الدراسي'),
                    value: _mustBePriorTerm,
                    onChanged: (val) => setState(() => _mustBePriorTerm = val),
                    activeColor: AppColors.primary500,
                  ),
                ],
              ),
            ),
    );
  }
}
