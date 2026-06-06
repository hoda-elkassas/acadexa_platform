// file: lib/features/study_plan/screens/academic_load_rules_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../data/models/academic_load_rules_model.dart';
import '../../../data/models/graduation_requirements_model.dart';
import '../cubit/academic_rules_cubit.dart';

class AcademicLoadRulesScreen extends StatefulWidget {
  const AcademicLoadRulesScreen({super.key, required this.plan});

  final dynamic plan; // StudyPlanModel

  @override
  State<AcademicLoadRulesScreen> createState() => _AcademicLoadRulesScreenState();
}

class _AcademicLoadRulesScreenState extends State<AcademicLoadRulesScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AcademicRulesCubit _cubit;

  // Load Rules fields
  late final TextEditingController _minHoursController;
  late final TextEditingController _maxHoursController;
  late final TextEditingController _maxSummerController;
  late final TextEditingController _overloadMaxController;
  late final TextEditingController _overloadGpaController;
  
  late final TextEditingController _l1To2Controller;
  late final TextEditingController _l2To3Controller;
  late final TextEditingController _l3To4Controller;

  bool _allowOverload = false;

  // Graduation Requirements fields
  late final TextEditingController _gradHoursController;
  late final TextEditingController _gradMinGpaController;
  late final TextEditingController _civicCountController;

  bool _reqTraining = true;
  bool _reqCivic = true;
  bool _reqCommunity = true;

  bool _isInitialized = false;
  AcademicLoadRulesModel? _originalLoadRules;
  GraduationRequirementsModel? _originalGradReqs;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<AcademicRulesCubit>();
    _cubit.load(widget.plan.id!);

    _minHoursController = TextEditingController();
    _maxHoursController = TextEditingController();
    _maxSummerController = TextEditingController();
    _overloadMaxController = TextEditingController();
    _overloadGpaController = TextEditingController();
    
    _l1To2Controller = TextEditingController();
    _l2To3Controller = TextEditingController();
    _l3To4Controller = TextEditingController();

    _gradHoursController = TextEditingController();
    _gradMinGpaController = TextEditingController();
    _civicCountController = TextEditingController();
  }

  @override
  void dispose() {
    _minHoursController.dispose();
    _maxHoursController.dispose();
    _maxSummerController.dispose();
    _overloadMaxController.dispose();
    _overloadGpaController.dispose();
    _l1To2Controller.dispose();
    _l2To3Controller.dispose();
    _l3To4Controller.dispose();
    _gradHoursController.dispose();
    _gradMinGpaController.dispose();
    _civicCountController.dispose();
    super.dispose();
  }

  void _initializeFields(AcademicLoadRulesModel? lr, GraduationRequirementsModel? gr) {
    if (_isInitialized) return;
    _originalLoadRules = lr;
    _originalGradReqs = gr;

    // Load Rules defaults if null
    final loadR = lr ?? AcademicLoadRulesModel(planId: widget.plan.id!);
    _minHoursController.text = loadR.minHoursFallSpring.toString();
    _maxHoursController.text = loadR.maxHoursFallSpring.toString();
    _maxSummerController.text = loadR.maxHoursSummer.toString();
    _allowOverload = loadR.allowOverload;
    _overloadMaxController.text = loadR.overloadMaxHours?.toString() ?? '24';
    _overloadGpaController.text = loadR.overloadMinGpa?.toString() ?? '3.50';

    _l1To2Controller.text = loadR.level1To2MinHours?.toString() ?? '32';
    _l2To3Controller.text = loadR.level2To3MinHours?.toString() ?? '70';
    _l3To4Controller.text = loadR.level3To4MinHours?.toString() ?? '110';

    // Graduation reqs defaults if null
    final gradR = gr ?? GraduationRequirementsModel(planId: widget.plan.id!);
    _gradHoursController.text = gradR.requiredHours.toString();
    _gradMinGpaController.text = gradR.minGpa.toStringAsFixed(2);
    _reqTraining = gradR.requiresFieldTraining ?? true;
    _reqCivic = gradR.requiresCivicLiteracy ?? true;
    _civicCountController.text = gradR.civicLiteracyCount?.toString() ?? '2';
    _reqCommunity = gradR.requiresCommunityCourse ?? true;

    _isInitialized = true;
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final updatedLoadRules = AcademicLoadRulesModel(
      id: _originalLoadRules?.id,
      planId: widget.plan.id!,
      minHoursFallSpring: int.parse(_minHoursController.text),
      maxHoursFallSpring: int.parse(_maxHoursController.text),
      maxHoursSummer: int.parse(_maxSummerController.text),
      allowOverload: _allowOverload,
      overloadMaxHours: _allowOverload ? int.tryParse(_overloadMaxController.text) : null,
      overloadMinGpa: _allowOverload ? double.tryParse(_overloadGpaController.text) : null,
      level1To2MinHours: int.tryParse(_l1To2Controller.text),
      level2To3MinHours: int.tryParse(_l2To3Controller.text),
      level3To4MinHours: int.tryParse(_l3To4Controller.text),
      requiresCivicLiteracy: _reqCivic,
      civicLiteracyCount: _reqCivic ? int.tryParse(_civicCountController.text) : null,
      requiresCommunityCourse: _reqCommunity,
    );

    final updatedGradReqs = GraduationRequirementsModel(
      id: _originalGradReqs?.id,
      planId: widget.plan.id!,
      requiredHours: int.parse(_gradHoursController.text),
      minGpa: double.parse(_gradMinGpaController.text),
      requiresFieldTraining: _reqTraining,
      requiresCivicLiteracy: _reqCivic,
      civicLiteracyCount: _reqCivic ? int.tryParse(_civicCountController.text) : null,
      requiresCommunityCourse: _reqCommunity,
    );

    // Save both
    _cubit.saveLoadRules(updatedLoadRules).then((_) {
      _cubit.saveGradReqs(updatedGradReqs);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text('ضوابط العبء الدراسي والتخرج - ${widget.plan.name}'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
            child: BlocBuilder<AcademicRulesCubit, AcademicRulesState>(
              builder: (context, state) {
                return AcButton(
                  label: 'حفظ كافة الإعدادات',
                  variant: AcButtonVariant.primary,
                  leadingIcon: state is AcademicRulesSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  onPressed: state is AcademicRulesSaving ? null : _onSave,
                );
              },
            ),
          ),
        ],
      ),
      body: BlocConsumer<AcademicRulesCubit, AcademicRulesState>(
        listener: (context, state) {
          if (state is AcademicRulesSaved) {
            AcSnackbar.show(
              context,
              message: 'تم حفظ إعدادات وضوابط العبء الدراسي بنجاح',
              type: AcToastType.success,
            );
          } else if (state is AcademicRulesError) {
            AcSnackbar.show(
              context,
              message: state.message,
              type: AcToastType.error,
            );
          }
        },
        builder: (context, state) {
          if (state is AcademicRulesLoading && !_isInitialized) {
            return const Center(child: AcLoadingState());
          }

          if (state is AcademicRulesLoaded) {
            _initializeFields(state.loadRules, state.gradReqs);
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Column 1: Academic Load Rules
                      Expanded(
                        child: Column(
                          children: [
                            _buildSectionHeader('حدود العبء الدراسي (الساعات المعتمدة)'),
                            const SizedBox(height: AppSpacing.md),
                            AcCard(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AcTextField(
                                          controller: _minHoursController,
                                          label: 'الحد الأدنى للفصل الرئيسي',
                                          keyboardType: TextInputType.number,
                                          validator: (v) => v == null || int.tryParse(v) == null ? 'رقم غير صحيح' : null,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: AcTextField(
                                          controller: _maxHoursController,
                                          label: 'الحد الأقصى للفصل الرئيسي',
                                          keyboardType: TextInputType.number,
                                          validator: (v) => v == null || int.tryParse(v) == null ? 'رقم غير صحيح' : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  AcTextField(
                                    controller: _maxSummerController,
                                    label: 'الحد الأقصى للفصل الصيفي',
                                    keyboardType: TextInputType.number,
                                    validator: (v) => v == null || int.tryParse(v) == null ? 'رقم غير صحيح' : null,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  SwitchListTile(
                                    title: const Text('السماح بالعبء الإضافي (Overload)'),
                                    subtitle: const Text('إتاحة زيادة العبء الدراسي للطلاب المتميزين'),
                                    value: _allowOverload,
                                    activeColor: AppColors.primary500,
                                    onChanged: (val) => setState(() => _allowOverload = val),
                                  ),
                                  if (_allowOverload) ...[
                                    const SizedBox(height: AppSpacing.md),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AcTextField(
                                            controller: _overloadMaxController,
                                            label: 'العبء الأقصى المسموح',
                                            keyboardType: TextInputType.number,
                                            validator: (v) => v == null || int.tryParse(v) == null ? 'رقم غير صحيح' : null,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: AcTextField(
                                            controller: _overloadGpaController,
                                            label: 'الحد الأدنى للمعدل التراكمي',
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                            validator: (v) => v == null || double.tryParse(v) == null ? 'رقم غير صحيح' : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            _buildSectionHeader('ضوابط الانتقال بين المستويات (ساعات مكتسبة)'),
                            const SizedBox(height: AppSpacing.md),
                            AcCard(
                              child: Column(
                                children: [
                                  AcTextField(
                                    controller: _l1To2Controller,
                                    label: 'الحد الأدنى للانتقال للمستوى الثاني (سنة 2)',
                                    keyboardType: TextInputType.number,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  AcTextField(
                                    controller: _l2To3Controller,
                                    label: 'الحد الأدنى للانتقال للمستوى الثالث (سنة 3)',
                                    keyboardType: TextInputType.number,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  AcTextField(
                                    controller: _l3To4Controller,
                                    label: 'الحد الأدنى للانتقال للمستوى الرابع (سنة 4)',
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xl),

                      // Column 2: Graduation Requirements
                      Expanded(
                        child: Column(
                          children: [
                            _buildSectionHeader('شروط ومتطلبات التخرج العامة'),
                            const SizedBox(height: AppSpacing.md),
                            AcCard(
                              child: Column(
                                children: [
                                  AcTextField(
                                    controller: _gradHoursController,
                                    label: 'إجمالي الساعات المطلوبة للتخرج',
                                    keyboardType: TextInputType.number,
                                    validator: (v) => v == null || int.tryParse(v) == null ? 'رقم غير صحيح' : null,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  AcTextField(
                                    controller: _gradMinGpaController,
                                    label: 'الحد الأدنى للمعدل التراكمي للتخرج (GPA)',
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    validator: (v) => v == null || double.tryParse(v) == null ? 'رقم غير صحيح' : null,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  SwitchListTile(
                                    title: const Text('يتطلب تدريب عملي/ميداني'),
                                    subtitle: const Text('إلزامية إنهاء ساعات التدريب الميداني للتخرج'),
                                    value: _reqTraining,
                                    activeColor: AppColors.primary500,
                                    onChanged: (val) => setState(() => _reqTraining = val),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  SwitchListTile(
                                    title: const Text('يتطلب مساقات الخدمة المجتمعية'),
                                    subtitle: const Text('إلزامية مشاركة الطالب في خدمة المجتمع'),
                                    value: _reqCommunity,
                                    activeColor: AppColors.primary500,
                                    onChanged: (val) => setState(() => _reqCommunity = val),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  SwitchListTile(
                                    title: const Text('يتطلب دورات الثقافة المدنية والأكاديمية'),
                                    subtitle: const Text('إتمام الساعات المحددة للتثقيف العام'),
                                    value: _reqCivic,
                                    activeColor: AppColors.primary500,
                                    onChanged: (val) => setState(() => _reqCivic = val),
                                  ),
                                  if (_reqCivic) ...[
                                    const SizedBox(height: AppSpacing.md),
                                    AcTextField(
                                      controller: _civicCountController,
                                      label: 'عدد الدورات/الأنشطة المطلوبة',
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: const BoxDecoration(
            color: AppColors.primary500,
            borderRadius: AppRadius.brPill,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
