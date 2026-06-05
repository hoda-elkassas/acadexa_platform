// file: lib/features/departments/cubit/departments_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/department_model.dart';
import '../../../data/models/program_model.dart';
import '../../../data/services/department_service.dart';
import '../../../data/services/base_service.dart';

abstract class DepartmentsState {}
class DepartmentsInitial extends DepartmentsState {}
class DepartmentsLoading extends DepartmentsState {}
class DepartmentsLoaded extends DepartmentsState {
  DepartmentsLoaded({required this.departments, required this.totalCount,
    required this.currentPage, required this.pageSize, this.programs = const []});
  final List<DepartmentModel> departments;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final List<ProgramModel> programs;
  int get totalPages => (totalCount / pageSize).ceil().clamp(1, 9999);
}
class DepartmentsError extends DepartmentsState {
  DepartmentsError(this.message);
  final String message;
}
class DepartmentSaving extends DepartmentsState {}
class DepartmentSaved extends DepartmentsState {}
class DepartmentDeleted extends DepartmentsState {}

class DepartmentsCubit extends Cubit<DepartmentsState> {
  DepartmentsCubit({DepartmentService? service})
      : _service = service ?? DepartmentService(), super(DepartmentsInitial());
  final DepartmentService _service;
  int _page = 1;
  int _pageSize = 20;

  Future<void> load({int? page, int? pageSize, String? search}) async {
    if (page != null) _page = page;
    if (pageSize != null) _pageSize = pageSize;
    emit(DepartmentsLoading());
    try {
      final result = await _service.getAllDepartments(
          page: _page, pageSize: _pageSize, searchQuery: search);
      final programs = await _service.getAllProgramsList();
      emit(DepartmentsLoaded(departments: result.data, totalCount: result.count,
          currentPage: _page, pageSize: _pageSize, programs: programs));
    } on ServiceException catch (e) {
      emit(DepartmentsError(e.message));
    }
  }

  Future<void> createDepartment(DepartmentModel model) async {
    emit(DepartmentSaving());
    try {
      await _service.createDepartment(model);
      emit(DepartmentSaved());
      await load();
    } on ServiceException catch (e) { emit(DepartmentsError(e.message)); }
  }

  Future<void> updateDepartment(String id, DepartmentModel model) async {
    emit(DepartmentSaving());
    try {
      await _service.updateDepartment(id, model);
      emit(DepartmentSaved());
      await load();
    } on ServiceException catch (e) { emit(DepartmentsError(e.message)); }
  }

  Future<void> deleteDepartment(String id) async {
    emit(DepartmentSaving());
    try {
      await _service.deleteDepartment(id);
      emit(DepartmentDeleted());
      await load();
    } on ServiceException catch (e) { emit(DepartmentsError(e.message)); }
  }

  Future<void> createProgram(ProgramModel model) async {
    emit(DepartmentSaving());
    try {
      await _service.createProgram(model);
      emit(DepartmentSaved());
      await load();
    } on ServiceException catch (e) { emit(DepartmentsError(e.message)); }
  }

  Future<void> updateProgram(String id, ProgramModel model) async {
    emit(DepartmentSaving());
    try {
      await _service.updateProgram(id, model);
      emit(DepartmentSaved());
      await load();
    } on ServiceException catch (e) { emit(DepartmentsError(e.message)); }
  }

  Future<void> deleteProgram(String id) async {
    emit(DepartmentSaving());
    try {
      await _service.deleteProgram(id);
      emit(DepartmentDeleted());
      await load();
    } on ServiceException catch (e) { emit(DepartmentsError(e.message)); }
  }
}
