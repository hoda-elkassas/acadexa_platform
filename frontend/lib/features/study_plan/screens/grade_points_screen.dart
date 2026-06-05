// file: lib/features/study_plan/screens/grade_points_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/curriculum_strings.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../data/models/grading_scale_model.dart';
import '../../../data/models/special_grade_symbol_model.dart';
import '../cubit/grading_cubit.dart';

class GradePointsScreen extends StatefulWidget {
  const GradePointsScreen({super.key, required this.plan});

  final dynamic plan; // StudyPlanModel

  @override
  State<GradePointsScreen> createState() => _GradePointsScreenState();
}

class _GradePointsScreenState extends State<GradePointsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final GradingCubit _cubit;
  GradingScaleModel? _selectedScale;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cubit = context.read<GradingCubit>();
    _cubit.load(widget.plan.id!);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Dialogs for Scale CRUD ─────────────────────────────────────────────
  void _showAddEditScaleDialog({GradingScaleModel? scale}) {
    final nameController = TextEditingController(text: scale?.nameAr ?? '');
    final nameEnController = TextEditingController(text: scale?.nameEn ?? '');
    bool isDefault = scale?.isDefault ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AcFormDialog(
          title: scale == null ? 'إضافة مقياس درجات' : 'تعديل مقياس درجات',
          confirmLabel: CurriculumStrings.save,
          onConfirm: () {
            if (nameController.text.trim().isEmpty) return;
            final m = GradingScaleModel(
              id: scale?.id,
              planId: widget.plan.id!,
              nameAr: nameController.text.trim(),
              nameEn: nameEnController.text.trim().isEmpty ? null : nameEnController.text.trim(),
              isDefault: isDefault,
            );
            if (scale == null) {
              _cubit.createScale(m).then((_) => Navigator.pop(context));
            } else {
              _cubit.updateScale(scale.id!, m).then((_) => Navigator.pop(context));
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AcTextField(
                controller: nameController,
                label: 'اسم المقياس بالعربية',
                hint: 'مثال: المقياس المئوي المعتمد',
              ),
              const SizedBox(height: AppSpacing.md),
              AcTextField(
                controller: nameEnController,
                label: 'اسم المقياس بالإنجليزية',
                hint: 'مثال: Standard 4.0 GPA Scale',
              ),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile(
                title: const Text('المقياس الافتراضي للخطة'),
                subtitle: const Text('سيتم تطبيقه تلقائياً على المقررات الجديدة'),
                value: isDefault,
                activeColor: AppColors.primary500,
                onChanged: (val) => setDialogState(() => isDefault = val),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteScale(GradingScaleModel scale) {
    AcDialog.show(
      context,
      title: CurriculumStrings.confirmDelete,
      message: 'هل أنت متأكد من حذف مقياس الدرجات ${scale.nameAr} وكل تقديراته الفرعية؟',
      type: AcDialogType.danger,
    ).then((confirmed) {
      if (confirmed == true) {
        _cubit.deleteScale(scale.id!);
        setState(() {
          if (_selectedScale?.id == scale.id) {
            _selectedScale = null;
          }
        });
      }
    });
  }

  // ─── Dialogs for Scale Items ───────────────────────────────────────────
  void _showAddEditItemDialog(String scaleId, {GradeScaleItemModel? item}) {
    final gradeArController = TextEditingController(text: item?.gradeAr ?? '');
    final gradeLetterController = TextEditingController(text: item?.gradeLetter ?? '');
    final pointsController = TextEditingController(text: item?.points.toString() ?? '4.00');
    final minScoreController = TextEditingController(text: item?.minScore.toString() ?? '90');
    final maxScoreController = TextEditingController(text: item?.maxScore.toString() ?? '94');
    bool isPassing = item?.isPassing ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AcFormDialog(
          title: item == null ? 'إضافة درجة تقدير' : 'تعديل درجة تقدير',
          confirmLabel: CurriculumStrings.save,
          onConfirm: () {
            if (gradeArController.text.trim().isEmpty || gradeLetterController.text.trim().isEmpty) return;
            final m = GradeScaleItemModel(
              id: item?.id,
              gradeScaleId: scaleId,
              gradeAr: gradeArController.text.trim(),
              gradeLetter: gradeLetterController.text.trim(),
              points: double.tryParse(pointsController.text.trim()) ?? 0.0,
              minScore: int.tryParse(minScoreController.text.trim()) ?? 0,
              maxScore: int.tryParse(maxScoreController.text.trim()) ?? 0,
              isPassing: isPassing,
            );
            if (item == null) {
              _cubit.createItem(m).then((_) => Navigator.pop(context));
            } else {
              _cubit.updateItem(item.id!, m).then((_) => Navigator.pop(context));
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AcTextField(
                      controller: gradeArController,
                      label: 'التقدير بالعربية',
                      hint: 'ممتاز',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AcTextField(
                      controller: gradeLetterController,
                      label: 'رمز التقدير (EN)',
                      hint: 'A',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AcTextField(
                      controller: minScoreController,
                      label: 'الدرجة الصغرى %',
                      hint: '90',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AcTextField(
                      controller: maxScoreController,
                      label: 'الدرجة العظمى %',
                      hint: '94',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AcTextField(
                controller: pointsController,
                label: 'نقاط التقدير (GPA Points)',
                hint: '3.75',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile(
                title: const Text('يعتبر تقدير نجاح'),
                value: isPassing,
                activeColor: AppColors.primary500,
                onChanged: (val) => setDialogState(() => isPassing = val),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteItem(GradeScaleItemModel item) {
    AcDialog.show(
      context,
      title: CurriculumStrings.confirmDelete,
      message: 'هل أنت متأكد من حذف تقدير ${item.gradeLetter}؟',
      type: AcDialogType.danger,
    ).then((confirmed) {
      if (confirmed == true) {
        _cubit.deleteItem(item.id!);
      }
    });
  }

  // ─── Dialogs for Special Grade Symbols ─────────────────────────────────
  void _showAddEditSymbolDialog({SpecialGradeSymbolModel? symbol}) {
    final symController = TextEditingController(text: symbol?.symbol ?? '');
    final nameArController = TextEditingController(text: symbol?.nameAr ?? '');
    final descController = TextEditingController(text: symbol?.description ?? '');
    bool affectsGpa = symbol?.affectsGpa ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AcFormDialog(
          title: symbol == null ? 'إضافة رمز تقدير خاص' : 'تعديل رمز تقدير خاص',
          confirmLabel: CurriculumStrings.save,
          onConfirm: () {
            if (symController.text.trim().isEmpty || nameArController.text.trim().isEmpty) return;
            final m = SpecialGradeSymbolModel(
              id: symbol?.id,
              planId: widget.plan.id!,
              symbol: symController.text.trim(),
              nameAr: nameArController.text.trim(),
              description: descController.text.trim().isEmpty ? null : descController.text.trim(),
              affectsGpa: affectsGpa,
            );
            if (symbol == null) {
              _cubit.createSymbol(m).then((_) => Navigator.pop(context));
            } else {
              _cubit.updateSymbol(symbol.id!, m).then((_) => Navigator.pop(context));
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AcTextField(
                      controller: symController,
                      label: 'الرمز',
                      hint: 'مثال: DN, W, I',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AcTextField(
                      controller: nameArController,
                      label: 'الاسم بالعربية',
                      hint: 'منسحب بعذر / حرمان',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AcTextField(
                controller: descController,
                label: 'الوصف التفصيلي',
                hint: 'توضيح لحالة استخدام هذا الرمز الأكاديمي...',
              ),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile(
                title: const Text('يؤثر على المعدل التراكمي (GPA)'),
                subtitle: const Text('تفعيل هذا الخيار يحتسب ساعات الرمز كرسوب أو صفر نقاط'),
                value: affectsGpa,
                activeColor: AppColors.primary500,
                onChanged: (val) => setDialogState(() => affectsGpa = val),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteSymbol(SpecialGradeSymbolModel symbol) {
    AcDialog.show(
      context,
      title: CurriculumStrings.confirmDelete,
      message: 'هل أنت متأكد من حذف الرمز الأكاديمي ${symbol.symbol}؟',
      type: AcDialogType.danger,
    ).then((confirmed) {
      if (confirmed == true) {
        _cubit.deleteSymbol(symbol.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text('إعدادات الدرجات والمعدلات - ${widget.plan.name}'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary500,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary500,
          labelStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'مقاييس وتقديرات الدرجات'),
            Tab(text: 'رموز التقديرات الخاصة'),
          ],
        ),
      ),
      body: BlocListener<GradingCubit, GradingState>(
        listener: (context, state) {
          if (state is GradingSaved) {
            AcSnackbar.show(
              context,
              message: CurriculumStrings.savedSuccessfully,
              type: AcToastType.success,
            );
          } else if (state is GradingError) {
            AcSnackbar.show(
              context,
              message: state.message,
              type: AcToastType.error,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: TabBarView(
            controller: _tabController,
            children: [
              // ─── Tab 1: Scales & Items ─────────────────────────────────────
              BlocBuilder<GradingCubit, GradingState>(
                builder: (context, state) {
                  if (state is GradingLoading) {
                    return const Center(child: AcLoadingState());
                  }

                  if (state is GradingError && state is! GradingLoaded) {
                    return AcErrorState(
                      title: 'حدث خطأ ما',
                      message: state.message,
                      onRetry: () => _cubit.load(widget.plan.id!),
                    );
                  }

                  List<GradingScaleModel> scales = [];
                  if (state is GradingLoaded) {
                    scales = state.scales;
                    // Auto-select first scale if nothing is selected
                    if (_selectedScale == null && scales.isNotEmpty) {
                      _selectedScale = scales.first;
                    } else if (_selectedScale != null) {
                      // Update reference from updated loaded list
                      _selectedScale = scales.firstWhere((s) => s.id == _selectedScale!.id, orElse: () => scales.first);
                    }
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Scale Navigation Side Panel
                      Expanded(
                        flex: 1,
                        child: Card(
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.brCard,
                            side: BorderSide(color: AppColors.border),
                          ),
                          color: AppColors.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('مقاييس الدرجات', style: AppTypography.h5),
                                    const Spacer(),
                                    AcIconButton(
                                      icon: const Icon(Icons.add_rounded),
                                      tooltip: 'إضافة مقياس',
                                      onPressed: () => _showAddEditScaleDialog(),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: scales.length,
                                    itemBuilder: (context, index) {
                                      final sc = scales[index];
                                      final isSelected = _selectedScale?.id == sc.id;
                                      return ListTile(
                                        title: Text(sc.nameAr, style: AppTypography.bodyMedium),
                                        subtitle: sc.isDefault ? const Text('المقياس الافتراضي للنجاح') : null,
                                        trailing: isSelected
                                            ? Icon(Icons.arrow_back_rounded, color: AppColors.primary500)
                                            : null,
                                        selected: isSelected,
                                        selectedTileColor: AppColors.primary50,
                                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brSm),
                                        onTap: () => setState(() => _selectedScale = sc),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),

                      // Scale Items Panel
                      Expanded(
                        flex: 2,
                        child: _selectedScale == null
                            ? AcEmptyState(
                                title: 'لا يوجد مقياس درجات محدد',
                                message: 'يرجى تهيئة أو تحديد مقياس درجات لعرض تفاصيله وتقديراته',
                                icon: const Icon(Icons.grade_rounded),
                                actionLabel: 'إضافة مقياس درجات',
                                onAction: () => _showAddEditScaleDialog(),
                              )
                            : Card(
                                elevation: 0,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadius.brCard,
                                  side: BorderSide(color: AppColors.border),
                                ),
                                color: AppColors.surface,
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(_selectedScale!.nameAr, style: AppTypography.h3),
                                              if (_selectedScale!.nameEn != null)
                                                Text(_selectedScale!.nameEn!, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                                            ],
                                          ),
                                          const Spacer(),
                                          AcIconButton(
                                            icon: const Icon(Icons.edit_rounded),
                                            tooltip: 'تعديل المقياس',
                                            onPressed: () => _showAddEditScaleDialog(scale: _selectedScale),
                                          ),
                                          AcIconButton(
                                            icon: const Icon(Icons.delete_outline_rounded),
                                            tooltip: 'حذف المقياس',
                                            variant: AcButtonVariant.danger,
                                            onPressed: () => _confirmDeleteScale(_selectedScale!),
                                          ),
                                          const SizedBox(width: AppSpacing.md),
                                          AcButton(
                                            label: 'إضافة تقدير',
                                            variant: AcButtonVariant.primary,
                                            leadingIcon: const Icon(Icons.add_rounded),
                                            onPressed: () => _showAddEditItemDialog(_selectedScale!.id!),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: AppSpacing.lg),
                                      Expanded(
                                        child: _selectedScale!.items.isEmpty
                                            ? AcEmptyState(
                                                title: 'لا توجد تقديرات فرعية',
                                                message: 'ابدأ بتعريف مستويات النجاح والحروف المقابلة لها (مثال: A+, A, B...) والدرجات الصغرى والكبرى لها',
                                                icon: const Icon(Icons.list_alt_rounded),
                                                actionLabel: 'إضافة تقدير',
                                                onAction: () => _showAddEditItemDialog(_selectedScale!.id!),
                                              )
                                            : AcDataTable<GradeScaleItemModel>(
                                                columns: [
                                                  AcTableColumn(
                                                    key: 'letter',
                                                    label: 'الرمز (EN)',
                                                    cellBuilder: (it, _) => Text(
                                                      it.gradeLetter,
                                                      style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                                                    ),
                                                    width: 100,
                                                  ),
                                                  AcTableColumn(
                                                    key: 'grade_ar',
                                                    label: 'التقدير بالعربية',
                                                    cellBuilder: (it, _) => Text(it.gradeAr),
                                                  ),
                                                  AcTableColumn(
                                                    key: 'range',
                                                    label: 'نطاق الدرجات %',
                                                    cellBuilder: (it, _) => Text('${it.minScore} - ${it.maxScore}'),
                                                  ),
                                                  AcTableColumn(
                                                    key: 'points',
                                                    label: 'نقاط المعدل (GPA)',
                                                    cellBuilder: (it, _) => Text(
                                                      it.points.toStringAsFixed(2),
                                                      style: AppTypography.labelLarge.copyWith(
                                                        color: AppColors.primary500,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  AcTableColumn(
                                                    key: 'passing',
                                                    label: 'نجاح/رسوب',
                                                    cellBuilder: (it, _) {
                                                      final label = it.isPassing ? 'ناجح' : 'راسب';
                                                      final color = it.isPassing ? AppColors.success500 : AppColors.danger500;
                                                      return Text(
                                                        label,
                                                        style: AppTypography.bodyMedium.copyWith(color: color, fontWeight: FontWeight.bold),
                                                      );
                                                    },
                                                    width: 100,
                                                  ),
                                                  AcTableColumn(
                                                    key: 'actions',
                                                    label: 'الإجراءات',
                                                    cellBuilder: (it, _) => Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        AcIconButton(
                                                          icon: const Icon(Icons.edit_rounded),
                                                          tooltip: CurriculumStrings.edit,
                                                          onPressed: () => _showAddEditItemDialog(_selectedScale!.id!, item: it),
                                                        ),
                                                        AcIconButton(
                                                          icon: const Icon(Icons.delete_outline_rounded),
                                                          tooltip: CurriculumStrings.delete,
                                                          variant: AcButtonVariant.danger,
                                                          onPressed: () => _confirmDeleteItem(it),
                                                        ),
                                                      ],
                                                    ),
                                                    width: 120,
                                                  ),
                                                ],
                                                rows: _selectedScale!.items..sort((a, b) => b.minScore.compareTo(a.minScore)),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),

              // ─── Tab 2: Special Grade Symbols ──────────────────────────────
              BlocBuilder<GradingCubit, GradingState>(
                builder: (context, state) {
                  if (state is GradingLoading) {
                    return const Center(child: AcLoadingState());
                  }

                  if (state is GradingError && state is! GradingLoaded) {
                    return AcErrorState(
                      title: 'حدث خطأ ما',
                      message: state.message,
                      onRetry: () => _cubit.load(widget.plan.id!),
                    );
                  }

                  List<SpecialGradeSymbolModel> symbols = [];
                  if (state is GradingLoaded) {
                    symbols = state.symbols;
                  }

                  return Column(
                    children: [
                      // Header card for adding new symbol
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
                              Text('رموز التقديرات الخاصة بالخطة', style: AppTypography.h5),
                              const Spacer(),
                              AcButton(
                                label: 'إضافة رمز خاص',
                                variant: AcButtonVariant.primary,
                                leadingIcon: const Icon(Icons.add_rounded),
                                onPressed: () => _showAddEditSymbolDialog(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Symbols table
                      Expanded(
                        child: symbols.isEmpty
                            ? AcEmptyState(
                                title: 'لا توجد رموز تقدير خاصة',
                                message: 'ابدأ بتعريف رموز التقديرات الخاصة بالخطة الدراسية (مثال: W لانسحاب بعذر، I لعدم اكتمال...)',
                                icon: const Icon(Icons.bookmark_added_rounded),
                                actionLabel: 'إضافة رمز خاص',
                                onAction: () => _showAddEditSymbolDialog(),
                              )
                            : AcDataTable<SpecialGradeSymbolModel>(
                                columns: [
                                  AcTableColumn(
                                    key: 'symbol',
                                    label: 'الرمز',
                                    cellBuilder: (sym, _) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.aiPurple.withValues(alpha: 0.1),
                                        borderRadius: AppRadius.brSm,
                                      ),
                                      child: Text(
                                        sym.symbol,
                                        style: AppTypography.labelLarge.copyWith(
                                          color: AppColors.aiPurple,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    width: 120,
                                  ),
                                  AcTableColumn(
                                    key: 'name_ar',
                                    label: 'الاسم بالعربية',
                                    cellBuilder: (sym, _) => Text(sym.nameAr),
                                    flex: 2,
                                  ),
                                  AcTableColumn(
                                    key: 'description',
                                    label: 'الوصف التفصيلي والاستخدام',
                                    cellBuilder: (sym, _) => Text(sym.description ?? '-'),
                                    flex: 3,
                                  ),
                                  AcTableColumn(
                                    key: 'affects_gpa',
                                    label: 'تأثير المعدل GPA',
                                    cellBuilder: (sym, _) {
                                      final label = sym.affectsGpa ? 'مؤثر بالمعدل' : 'غير مؤثر بالمعدل';
                                      final color = sym.affectsGpa ? AppColors.danger500 : AppColors.success500;
                                      return Text(
                                        label,
                                        style: AppTypography.bodyMedium.copyWith(color: color, fontWeight: FontWeight.bold),
                                      );
                                    },
                                    width: 150,
                                  ),
                                  AcTableColumn(
                                    key: 'actions',
                                    label: 'الإجراءات',
                                    cellBuilder: (sym, _) => Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AcIconButton(
                                          icon: const Icon(Icons.edit_rounded),
                                          tooltip: CurriculumStrings.edit,
                                          onPressed: () => _showAddEditSymbolDialog(symbol: sym),
                                        ),
                                        AcIconButton(
                                          icon: const Icon(Icons.delete_outline_rounded),
                                          tooltip: CurriculumStrings.delete,
                                          variant: AcButtonVariant.danger,
                                          onPressed: () => _confirmDeleteSymbol(sym),
                                        ),
                                      ],
                                    ),
                                    width: 120,
                                  ),
                                ],
                                rows: symbols,
                              ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
