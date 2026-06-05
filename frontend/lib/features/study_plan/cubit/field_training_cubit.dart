// file: lib/features/study_plan/cubit/field_training_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/field_training_rules_model.dart';
import '../../../data/services/field_training_service.dart';
import '../../../data/services/base_service.dart';

abstract class FieldTrainingState {}
class FieldTrainingInitial extends FieldTrainingState {}
class FieldTrainingLoading extends FieldTrainingState {}
class FieldTrainingLoaded extends FieldTrainingState {
  FieldTrainingLoaded(this.rules);
  final FieldTrainingRulesModel? rules;
}
class FieldTrainingError extends FieldTrainingState {
  FieldTrainingError(this.message);
  final String message;
}
class FieldTrainingSaving extends FieldTrainingState {}
class FieldTrainingSaved extends FieldTrainingState {}

class FieldTrainingCubit extends Cubit<FieldTrainingState> {
  FieldTrainingCubit({FieldTrainingService? service})
      : _service = service ?? FieldTrainingService(),
        super(FieldTrainingInitial());
  final FieldTrainingService _service;
  String _planId = '';

  Future<void> load(String planId) async {
    _planId = planId;
    emit(FieldTrainingLoading());
    try {
      final data = await _service.getByPlanId(planId);
      emit(FieldTrainingLoaded(data));
    } on ServiceException catch (e) { emit(FieldTrainingError(e.message)); }
  }

  Future<void> save(FieldTrainingRulesModel model) async {
    emit(FieldTrainingSaving());
    try {
      await _service.upsert(model);
      emit(FieldTrainingSaved());
      await load(_planId);
    } on ServiceException catch (e) { emit(FieldTrainingError(e.message)); }
  }
}
