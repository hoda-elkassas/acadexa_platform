// file: lib/features/courses/cubit/prerequisites_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/prerequisite_model.dart';
import '../../../data/services/prerequisite_service.dart';
import '../../../data/services/base_service.dart';

abstract class PrerequisitesState {}
class PrerequisitesInitial extends PrerequisitesState {}
class PrerequisitesLoading extends PrerequisitesState {}
class PrerequisitesLoaded extends PrerequisitesState {
  PrerequisitesLoaded(this.prerequisites);
  final List<PrerequisiteModel> prerequisites;
}
class PrerequisitesError extends PrerequisitesState {
  PrerequisitesError(this.message);
  final String message;
}
class PrerequisiteSaving extends PrerequisitesState {}
class PrerequisiteSaved extends PrerequisitesState {}
class PrerequisiteDeleted extends PrerequisitesState {}

class PrerequisitesCubit extends Cubit<PrerequisitesState> {
  PrerequisitesCubit({PrerequisiteService? service})
      : _service = service ?? PrerequisiteService(),
        super(PrerequisitesInitial());
  final PrerequisiteService _service;
  String _planId = '';

  Future<void> loadByPlan(String planId) async {
    _planId = planId;
    emit(PrerequisitesLoading());
    try {
      final data = await _service.getByPlanId(planId);
      emit(PrerequisitesLoaded(data));
    } on ServiceException catch (e) {
      emit(PrerequisitesError(e.message));
    }
  }

  Future<void> create(PrerequisiteModel model) async {
    emit(PrerequisiteSaving());
    try {
      await _service.create(model);
      emit(PrerequisiteSaved());
      await loadByPlan(_planId);
    } on ServiceException catch (e) { emit(PrerequisitesError(e.message)); }
  }

  Future<void> update(String id, PrerequisiteModel model) async {
    emit(PrerequisiteSaving());
    try {
      await _service.update(id, model);
      emit(PrerequisiteSaved());
      await loadByPlan(_planId);
    } on ServiceException catch (e) { emit(PrerequisitesError(e.message)); }
  }

  Future<void> delete(String id) async {
    emit(PrerequisiteSaving());
    try {
      await _service.delete(id);
      emit(PrerequisiteDeleted());
      await loadByPlan(_planId);
    } on ServiceException catch (e) { emit(PrerequisitesError(e.message)); }
  }
}
