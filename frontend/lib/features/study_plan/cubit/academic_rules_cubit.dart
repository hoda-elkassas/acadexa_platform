// file: lib/features/study_plan/cubit/academic_rules_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/academic_load_rules_model.dart';
import '../../../data/models/graduation_requirements_model.dart';
import '../../../data/services/academic_rules_service.dart';
import '../../../data/services/base_service.dart';

abstract class AcademicRulesState {}
class AcademicRulesInitial extends AcademicRulesState {}
class AcademicRulesLoading extends AcademicRulesState {}
class AcademicRulesLoaded extends AcademicRulesState {
  AcademicRulesLoaded({this.loadRules, this.gradReqs});
  final AcademicLoadRulesModel? loadRules;
  final GraduationRequirementsModel? gradReqs;
}
class AcademicRulesError extends AcademicRulesState {
  AcademicRulesError(this.message);
  final String message;
}
class AcademicRulesSaving extends AcademicRulesState {}
class AcademicRulesSaved extends AcademicRulesState {}

class AcademicRulesCubit extends Cubit<AcademicRulesState> {
  AcademicRulesCubit({AcademicRulesService? service})
      : _service = service ?? AcademicRulesService(),
        super(AcademicRulesInitial());
  final AcademicRulesService _service;
  String _planId = '';

  Future<void> load(String planId) async {
    _planId = planId;
    emit(AcademicRulesLoading());
    try {
      final lr = await _service.getLoadRules(planId);
      final gr = await _service.getGradReqs(planId);
      emit(AcademicRulesLoaded(loadRules: lr, gradReqs: gr));
    } on ServiceException catch (e) { emit(AcademicRulesError(e.message)); }
  }

  Future<void> saveLoadRules(AcademicLoadRulesModel model) async {
    emit(AcademicRulesSaving());
    try {
      await _service.upsertLoadRules(model);
      emit(AcademicRulesSaved());
      await load(_planId);
    } on ServiceException catch (e) { emit(AcademicRulesError(e.message)); }
  }

  Future<void> saveGradReqs(GraduationRequirementsModel model) async {
    emit(AcademicRulesSaving());
    try {
      await _service.upsertGradReqs(model);
      emit(AcademicRulesSaved());
      await load(_planId);
    } on ServiceException catch (e) { emit(AcademicRulesError(e.message)); }
  }
}
