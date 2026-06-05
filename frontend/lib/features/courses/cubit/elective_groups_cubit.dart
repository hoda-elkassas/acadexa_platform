// file: lib/features/courses/cubit/elective_groups_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/elective_group_model.dart';
import '../../../data/services/elective_group_service.dart';
import '../../../data/services/base_service.dart';

abstract class ElectiveGroupsState {}
class ElectiveGroupsInitial extends ElectiveGroupsState {}
class ElectiveGroupsLoading extends ElectiveGroupsState {}
class ElectiveGroupsLoaded extends ElectiveGroupsState {
  ElectiveGroupsLoaded(this.groups);
  final List<ElectiveGroupModel> groups;
}
class ElectiveGroupsError extends ElectiveGroupsState {
  ElectiveGroupsError(this.message);
  final String message;
}
class ElectiveGroupSaving extends ElectiveGroupsState {}
class ElectiveGroupSaved extends ElectiveGroupsState {}
class ElectiveGroupDeleted extends ElectiveGroupsState {}

class ElectiveGroupsCubit extends Cubit<ElectiveGroupsState> {
  ElectiveGroupsCubit({ElectiveGroupService? service})
      : _service = service ?? ElectiveGroupService(),
        super(ElectiveGroupsInitial());
  final ElectiveGroupService _service;
  String _planId = '';

  Future<void> load(String planId) async {
    _planId = planId;
    emit(ElectiveGroupsLoading());
    try {
      final data = await _service.getByPlanId(planId);
      emit(ElectiveGroupsLoaded(data));
    } on ServiceException catch (e) {
      emit(ElectiveGroupsError(e.message));
    }
  }

  Future<void> create(ElectiveGroupModel model) async {
    emit(ElectiveGroupSaving());
    try {
      final created = await _service.create(model);
      if (model.courseIds.isNotEmpty) {
        await _service.assignCourses(created.id!, model.courseIds);
      }
      emit(ElectiveGroupSaved());
      await load(_planId);
    } on ServiceException catch (e) { emit(ElectiveGroupsError(e.message)); }
  }

  Future<void> update(String id, ElectiveGroupModel model) async {
    emit(ElectiveGroupSaving());
    try {
      await _service.update(id, model);
      await _service.assignCourses(id, model.courseIds);
      emit(ElectiveGroupSaved());
      await load(_planId);
    } on ServiceException catch (e) { emit(ElectiveGroupsError(e.message)); }
  }

  Future<void> delete(String id) async {
    emit(ElectiveGroupSaving());
    try {
      await _service.delete(id);
      emit(ElectiveGroupDeleted());
      await load(_planId);
    } on ServiceException catch (e) { emit(ElectiveGroupsError(e.message)); }
  }
}
