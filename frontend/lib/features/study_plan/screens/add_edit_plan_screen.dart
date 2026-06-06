// file: lib/features/study_plan/screens/add_edit_plan_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/curriculum_strings.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../data/models/study_plan_model.dart';
import '../../../data/models/department_model.dart';
import '../../../data/models/program_model.dart';
import '../../departments/cubit/departments_cubit.dart';
import '../cubit/study_plan_cubit.dart';

class AddEditPlanScreen extends StatefulWidget {
  const AddEditPlanScreen({super.key, this.plan});

  final StudyPlanModel? plan;

  @override
  State<AddEditPlanScreen> createState() => _AddEditPlanScreenState();
}

class _AddEditPlanScreenState extends State<AddEditPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _yearController;
  late final TextEditingController _versionController;
  late final TextEditingController _hoursController;
  late final TextEditingController _gpaController;

  String? _selectedDepartmentId;
  String? _selectedProgramId;
  String _selectedStatus = 'draft';
  bool _isCurrent = false;

  @override
  void initState() {
    super.initState();
    final p = widget.plan;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _yearController = TextEditingController(text: p?.academicYear.toString() ?? DateTime.now().year.toString());
    _versionController = TextEditingController(text: p?.version.toString() ?? '1');
    _hoursController = TextEditingController(text: p?.totalCreditHours.toString() ?? '136');
    _gpaController = TextEditingController(text: p?.minGpaToGraduate.toString() ?? '2.00');

    _selectedDepartmentId = p?.departmentId;
    _selectedProgramId = p?.programId;
    _selectedStatus = p?.status ?? 'draft';
    _isCurrent = p?.isCurrent ?? false;

    context.read<DepartmentsCubit>().load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    _versionController.dispose();
    _hoursController.dispose();
    _gpaController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDepartmentId == null) {
      AcSnackbar.show(context, message: 'يرجى اختيار القسم', type: AcToastType.error);
      return;
    }

    final newPlan = StudyPlanModel(
      id: widget.plan?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      academicYear: int.parse(_yearController.text.trim()),
      version: int.parse(_versionController.text.trim()),
      totalCreditHours: int.parse(_hoursController.text.trim()),
      minGpaToGraduate: double.parse(_gpaController.text.trim()),
      departmentId: _selectedDepartmentId!,
      programId: _selectedProgramId,
      status: _selectedStatus,
      isCurrent: _isCurrent,
    );

    final cubit = context.read<StudyPlanCubit>();
    if (widget.plan == null) {
      cubit.createPlan(newPlan).then((_) {
        if (mounted) Navigator.pop(context);
      });
    } else {
      cubit.updatePlan(widget.plan!.id!, newPlan).then((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.plan != null;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text(isEdit ? CurriculumStrings.editStudyPlan : CurriculumStrings.addStudyPlan),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
            child: AcButton(
              label: CurriculumStrings.save,
              variant: AcButtonVariant.primary,
              onPressed: _onSave,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AcSectionCard(
                title: 'معلومات الخطة الأساسية',
                child: Column(
                  children: [
                    AcTextField(
                      controller: _nameController,
                      label: CurriculumStrings.planName,
                      hint: 'مثال: خطة بكالوريوس علوم الحاسب 2026',
                      validator: (v) => v == null || v.isEmpty ? 'يرجى إدخال اسم الخطة' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AcTextField(
                      controller: _descriptionController,
                      label: CurriculumStrings.description,
                      hint: 'وصف الخطة وأهدافها...',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: BlocBuilder<DepartmentsCubit, DepartmentsState>(
                      builder: (context, state) {
                        List<DepartmentModel> departments = [];
                        if (state is DepartmentsLoaded) {
                          departments = state.departments;
                        }
                        return AcSectionCard(
                          title: 'التبعية الأكاديمية',
                          child: Column(
                            children: [
                              AcDropdownField<String>(
                                label: CurriculumStrings.department,
                                value: _selectedDepartmentId,
                                hint: 'اختر القسم الأكاديمي',
                                onChanged: (val) {
                                  setState(() {
                                    _selectedDepartmentId = val;
                                    _selectedProgramId = null; // reset program when dept changes
                                  });
                                },
                                items: departments.map((d) {
                                  return DropdownMenuItem(
                                    value: d.id,
                                    child: Text(d.nameAr),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AcDropdownField<String>(
                                label: CurriculumStrings.program,
                                value: _selectedProgramId,
                                hint: 'اختر البرنامج الدراسي (اختياري)',
                                onChanged: (val) {
                                  setState(() => _selectedProgramId = val);
                                },
                                items: departments
                                    .where((d) => d.id == _selectedDepartmentId)
                                    .expand((d) => state is DepartmentsLoaded
                                        ? state.programs.where((p) => p.departmentId == d.id)
                                        : <ProgramModel>[])
                                    .map((p) {
                                  return DropdownMenuItem(
                                    value: p.id,
                                    child: Text(p.nameAr),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: AcSectionCard(
                      title: 'المتطلبات والنسخة',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AcTextField(
                                  controller: _yearController,
                                  label: CurriculumStrings.academicYear,
                                  hint: '2026',
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v == null || int.tryParse(v) == null ? 'سنة أكاديمية غير صالحة' : null,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: AcTextField(
                                  controller: _versionController,
                                  label: CurriculumStrings.version,
                                  hint: '1',
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v == null || int.tryParse(v) == null ? 'رقم نسخة غير صالح' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: AcTextField(
                                  controller: _hoursController,
                                  label: CurriculumStrings.creditHours,
                                  hint: '136',
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v == null || int.tryParse(v) == null ? 'عدد ساعات غير صالح' : null,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: AcTextField(
                                  controller: _gpaController,
                                  label: 'المعدل التراكمي للتخرج',
                                  hint: '2.00',
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v == null || double.tryParse(v) == null ? 'معدل تراكمي غير صالح' : null,
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
              const SizedBox(height: AppSpacing.lg),
              AcSectionCard(
                title: 'الحالة وتفعيل الخطة',
                child: Row(
                  children: [
                    Expanded(
                      child: AcDropdownField<String>(
                        label: CurriculumStrings.status,
                        value: _selectedStatus,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedStatus = val);
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 'draft', child: Text(CurriculumStrings.statusDraft)),
                          DropdownMenuItem(value: 'active', child: Text(CurriculumStrings.statusActive)),
                          DropdownMenuItem(value: 'archived', child: Text(CurriculumStrings.statusArchived)),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('الخطة الحالية الافتراضية'),
                        subtitle: const Text('تعيين كخطة نشطة حالياً لهذا البرنامج الأكاديمي'),
                        value: _isCurrent,
                        onChanged: (val) => setState(() => _isCurrent = val),
                        activeColor: AppColors.primary500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
