// file: lib/features/departments/screens/add_edit_department_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/curriculum_strings.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../data/models/department_model.dart';
import '../../../data/models/program_model.dart';
import '../cubit/departments_cubit.dart';

class AddEditDepartmentDialog extends StatefulWidget {
  const AddEditDepartmentDialog({
    super.key,
    this.department,
    this.program,
    this.isProgram = false,
  });

  final DepartmentModel? department;
  final ProgramModel? program;
  final bool isProgram;

  @override
  State<AddEditDepartmentDialog> createState() => _AddEditDepartmentDialogState();
}

class _AddEditDepartmentDialogState extends State<AddEditDepartmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _nameArController;
  late final TextEditingController _nameEnController;
  late final TextEditingController _shortNameOrDescController;
  
  String? _selectedDepartmentId;
  String _programType = 'regular';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.isProgram) {
      final p = widget.program;
      _codeController = TextEditingController(text: p?.code ?? '');
      _nameArController = TextEditingController(text: p?.nameAr ?? '');
      _nameEnController = TextEditingController(text: p?.nameEn ?? '');
      _shortNameOrDescController = TextEditingController(text: p?.description ?? '');
      _selectedDepartmentId = p?.departmentId;
      _programType = p?.programType ?? 'regular';
      _isActive = p?.isActive ?? true;
    } else {
      final d = widget.department;
      _codeController = TextEditingController(text: d?.code ?? '');
      _nameArController = TextEditingController(text: d?.nameAr ?? '');
      _nameEnController = TextEditingController(text: d?.nameEn ?? '');
      _shortNameOrDescController = TextEditingController(text: d?.shortName ?? '');
      _isActive = d?.isActive ?? true;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameArController.dispose();
    _nameEnController.dispose();
    _shortNameOrDescController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<DepartmentsCubit>();

    if (widget.isProgram) {
      final p = ProgramModel(
        id: widget.program?.id,
        code: _codeController.text.trim(),
        nameAr: _nameArController.text.trim(),
        nameEn: _nameEnController.text.trim(),
        description: _shortNameOrDescController.text.trim().isEmpty ? null : _shortNameOrDescController.text.trim(),
        departmentId: _selectedDepartmentId,
        programType: _programType,
        isActive: _isActive,
      );

      if (widget.program == null) {
        cubit.createProgram(p).then((_) {
          if (mounted) Navigator.pop(context, true);
        });
      } else {
        cubit.updateProgram(widget.program!.id!, p).then((_) {
          if (mounted) Navigator.pop(context, true);
        });
      }
    } else {
      final d = DepartmentModel(
        id: widget.department?.id,
        code: _codeController.text.trim(),
        nameAr: _nameArController.text.trim(),
        nameEn: _nameEnController.text.trim(),
        shortName: _shortNameOrDescController.text.trim().isEmpty ? null : _shortNameOrDescController.text.trim(),
        isActive: _isActive,
      );

      if (widget.department == null) {
        cubit.createDepartment(d).then((_) {
          if (mounted) Navigator.pop(context, true);
        });
      } else {
        cubit.updateDepartment(widget.department!.id!, d).then((_) {
          if (mounted) Navigator.pop(context, true);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isProgram
        ? (widget.program == null ? 'إضافة برنامج دراسي' : 'تعديل برنامج دراسي')
        : (widget.department == null ? 'إضافة قسم أكاديمي' : 'تعديل قسم أكاديمي');

    return AcFormDialog(
      title: title,
      confirmLabel: CurriculumStrings.save,
      onConfirm: _onConfirm,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AcTextField(
              controller: _codeController,
              label: 'الرمز الكودي',
              hint: widget.isProgram ? 'مثال: CS' : 'مثال: COMP',
              validator: (v) => v == null || v.isEmpty ? 'يرجى إدخال الكود' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            AcTextField(
              controller: _nameArController,
              label: 'الاسم بالعربية',
              hint: widget.isProgram ? 'مثال: علوم الحاسب' : 'مثال: قسم علوم الحاسب',
              validator: (v) => v == null || v.isEmpty ? 'يرجى إدخال الاسم بالعربية' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            AcTextField(
              controller: _nameEnController,
              label: 'الاسم بالإنجليزية',
              hint: widget.isProgram ? 'Computer Science' : 'Department of Computer Science',
              validator: (v) => v == null || v.isEmpty ? 'يرجى إدخال الاسم بالإنجليزية' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            if (widget.isProgram) ...[
              BlocBuilder<DepartmentsCubit, DepartmentsState>(
                builder: (context, state) {
                  List<DepartmentModel> departments = [];
                  if (state is DepartmentsLoaded) {
                    departments = state.departments;
                  }
                  return AcDropdownField<String>(
                    label: CurriculumStrings.department,
                    value: _selectedDepartmentId,
                    hint: 'اختر القسم التابع له البرنامج',
                    onChanged: (val) => setState(() => _selectedDepartmentId = val),
                    items: departments.map((d) {
                      return DropdownMenuItem(
                        value: d.id,
                        child: Text(d.nameAr),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AcDropdownField<String>(
                label: 'نوع البرنامج',
                value: _programType,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _programType = val);
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'regular', child: Text('انتظام')),
                  DropdownMenuItem(value: 'evening', child: Text('مسائي')),
                  DropdownMenuItem(value: 'parallel', child: Text('موازي')),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            AcTextField(
              controller: _shortNameOrDescController,
              label: widget.isProgram ? CurriculumStrings.description : 'الاسم المختصر',
              hint: widget.isProgram ? 'وصف تفصيلي للبرنامج الدراسي...' : 'مثال: CS',
              maxLines: widget.isProgram ? 3 : 1,
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              title: const Text('نشط'),
              subtitle: const Text('إتاحة القسم/البرنامج للاستخدام في النظام الدراسي'),
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
