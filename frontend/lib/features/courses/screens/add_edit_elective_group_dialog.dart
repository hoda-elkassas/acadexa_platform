// file: lib/features/courses/screens/add_edit_elective_group_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/curriculum_strings.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/elective_group_model.dart';
import '../../../data/services/course_service.dart';
import '../cubit/elective_groups_cubit.dart';

class AddEditElectiveGroupDialog extends StatefulWidget {
  const AddEditElectiveGroupDialog({
    super.key,
    required this.planId,
    this.group,
  });

  final String planId;
  final ElectiveGroupModel? group;

  @override
  State<AddEditElectiveGroupDialog> createState() => _AddEditElectiveGroupDialogState();
}

class _AddEditElectiveGroupDialogState extends State<AddEditElectiveGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _courseService = CourseService();

  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _minHoursController;
  late final TextEditingController _maxHoursController;
  late final TextEditingController _minCoursesController;
  late final TextEditingController _maxCoursesController;

  bool _selectByHours = true;
  List<CourseModel> _electiveCourses = [];
  final List<String> _selectedCourseIds = [];
  bool _loadingCourses = true;

  @override
  void initState() {
    super.initState();
    final g = widget.group;
    _codeController = TextEditingController(text: g?.code ?? '');
    _nameController = TextEditingController(text: g?.name ?? '');
    _minHoursController = TextEditingController(text: g?.minHours?.toString() ?? '9');
    _maxHoursController = TextEditingController(text: g?.maxHours?.toString() ?? '12');
    _minCoursesController = TextEditingController(text: g?.minCourses?.toString() ?? '3');
    _maxCoursesController = TextEditingController(text: g?.maxCourses?.toString() ?? '4');
    _selectByHours = g?.selectByHours ?? true;

    if (g != null) {
      _selectedCourseIds.addAll(g.courseIds);
    }
    _loadElectiveCourses();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _minHoursController.dispose();
    _maxHoursController.dispose();
    _minCoursesController.dispose();
    _maxCoursesController.dispose();
    super.dispose();
  }

  Future<void> _loadElectiveCourses() async {
    try {
      final list = await _courseService.getAllForPlan(widget.planId);
      setState(() {
        // Only display courses marked as elective
        _electiveCourses = list.where((c) => c.courseType == 'elective').toList();
        _loadingCourses = false;
      });
    } catch (e) {
      setState(() => _loadingCourses = false);
      if (mounted) {
        AcSnackbar.show(
          context,
          message: 'فشل تحميل المقررات الاختيارية',
          type: AcToastType.error,
        );
      }
    }
  }

  void _onConfirm() {
    if (!_formKey.currentState!.validate()) return;

    final newGroup = ElectiveGroupModel(
      id: widget.group?.id,
      planId: widget.planId,
      name: _nameController.text.trim(),
      code: _codeController.text.trim(),
      selectByHours: _selectByHours,
      minHours: _selectByHours ? int.tryParse(_minHoursController.text.trim()) : null,
      maxHours: _selectByHours ? int.tryParse(_maxHoursController.text.trim()) : null,
      minCourses: !_selectByHours ? int.tryParse(_minCoursesController.text.trim()) : null,
      maxCourses: !_selectByHours ? int.tryParse(_maxCoursesController.text.trim()) : null,
      courseIds: _selectedCourseIds,
    );

    final cubit = context.read<ElectiveGroupsCubit>();
    if (widget.group == null) {
      cubit.create(newGroup).then((_) => Navigator.pop(context, true));
    } else {
      cubit.update(widget.group!.id!, newGroup).then((_) => Navigator.pop(context, true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.group == null ? 'إضافة مجموعة اختيارية' : 'تعديل مجموعة اختيارية';

    return AcFormDialog(
      title: title,
      confirmLabel: CurriculumStrings.save,
      onConfirm: _onConfirm,
      maxWidth: 680,
      child: _loadingCourses
          ? const Center(child: AcLoadingState())
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AcTextField(
                          controller: _codeController,
                          label: 'رمز المجموعة',
                          hint: 'مثال: ELEC-CS',
                          validator: (v) => v == null || v.isEmpty ? 'يرجى إدخال الرمز' : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AcTextField(
                          controller: _nameController,
                          label: 'اسم المجموعة',
                          hint: 'مثال: اختياري قسم علوم الحاسب',
                          validator: (v) => v == null || v.isEmpty ? 'يرجى إدخال اسم المجموعة' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Text('طريقة احتساب المتطلبات: ', style: AppTypography.bodyMedium),
                      const Spacer(),
                      ChoiceChip(
                        label: const Text('بالساعات المعتمدة'),
                        selected: _selectByHours,
                        onSelected: (val) => setState(() => _selectByHours = true),
                        selectedColor: AppColors.primary50,
                        checkmarkColor: AppColors.primary500,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ChoiceChip(
                        label: const Text('بعدد المقررات'),
                        selected: !_selectByHours,
                        onSelected: (val) => setState(() => _selectByHours = false),
                        selectedColor: AppColors.primary50,
                        checkmarkColor: AppColors.primary500,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_selectByHours) ...[
                    Row(
                      children: [
                        Expanded(
                          child: AcTextField(
                            controller: _minHoursController,
                            label: 'الحد الأدنى للساعات المطلوبة',
                            hint: '9',
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || int.tryParse(v) == null ? 'رقم غير صحيح' : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AcTextField(
                            controller: _maxHoursController,
                            label: 'الحد الأقصى للساعات المسموحة',
                            hint: '12',
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || int.tryParse(v) == null ? 'رقم غير صحيح' : null,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: AcTextField(
                            controller: _minCoursesController,
                            label: 'الحد الأدنى للمقررات المطلوبة',
                            hint: '3',
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || int.tryParse(v) == null ? 'رقم غير صحيح' : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AcTextField(
                            controller: _maxCoursesController,
                            label: 'الحد الأقصى للمقررات المسموحة',
                            hint: '4',
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || int.tryParse(v) == null ? 'رقم غير صحيح' : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'اختر المقررات الدراسية التابعة للمجموعة:',
                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (_electiveCourses.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Text(
                        'لا توجد مقررات اختيارية مضافة في الخطة الدراسية حالياً.',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    Container(
                      constraints: const BoxConstraints(maxHeight: 180),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: AppRadius.brMd,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _electiveCourses.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final c = _electiveCourses[index];
                          final isSelected = _selectedCourseIds.contains(c.id);
                          return CheckboxListTile(
                            title: Text('${c.code} - ${c.nameAr}'),
                            subtitle: Text('عدد الساعات: ${c.creditHours} ساعة مجهزة'),
                            value: isSelected,
                            activeColor: AppColors.primary500,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedCourseIds.add(c.id!);
                                } else {
                                  _selectedCourseIds.remove(c.id!);
                                }
                              });
                            },
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
