// file: lib/features/study_plan/cubit/plan_structure_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/plan_structure_model.dart';
import '../../../data/services/plan_structure_service.dart';
import '../../../data/services/base_service.dart';

abstract class PlanStructureState {}
class PlanStructureInitial extends PlanStructureState {}
class PlanStructureLoading extends PlanStructureState {}
class PlanStructureLoaded extends PlanStructureState {
  PlanStructureLoaded(this.entries);
  final List<PlanStructureModel> entries;
}
class PlanStructureError extends PlanStructureState {
  PlanStructureError(this.message);
  final String message;
}
class PlanStructureSaving extends PlanStructureState {}
class PlanStructureSaved extends PlanStructureState {}

class PlanStructureCubit extends Cubit<PlanStructureState> {
  PlanStructureCubit({PlanStructureService? service})
      : _service = service ?? PlanStructureService(),
        super(PlanStructureInitial());
  final PlanStructureService _service;
  String _planId = '';

  Future<void> load(String planId) async {
    _planId = planId;
    emit(PlanStructureLoading());
    try {
      final data = await _service.getByPlanId(planId);
      emit(PlanStructureLoaded(data));
    } on ServiceException catch (e) { emit(PlanStructureError(e.message)); }
  }

  Future<void> save(PlanStructureModel model) async {
    emit(PlanStructureSaving());
    try {
      if (model.id != null) {
        await _service.update(model.id!, model);
      } else {
        await _service.create(model);
      }
      emit(PlanStructureSaved());
      await load(_planId);
    } on ServiceException catch (e) { emit(PlanStructureError(e.message)); }
  }

  Future<void> bulkSave(List<PlanStructureModel> models) async {
    emit(PlanStructureSaving());
    try {
      await _service.bulkUpsert(models);
      emit(PlanStructureSaved());
      await load(_planId);
    } on ServiceException catch (e) { emit(PlanStructureError(e.message)); }
  }

  Future<void> delete(String id) async {
    emit(PlanStructureSaving());
    try {
      await _service.delete(id);
      emit(PlanStructureSaved());
      await load(_planId);
    } on ServiceException catch (e) { emit(PlanStructureError(e.message)); }
  }
}
