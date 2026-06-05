// file: lib/features/study_plan/cubit/study_plan_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/study_plan_model.dart';
import '../../../data/services/study_plan_service.dart';
import '../../../data/services/base_service.dart';

// ─── States ───────────────────────────────────────────────────────────
abstract class StudyPlanState {}

class StudyPlanInitial extends StudyPlanState {}

class StudyPlanLoading extends StudyPlanState {}

class StudyPlanLoaded extends StudyPlanState {
  StudyPlanLoaded({
    required this.plans,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    this.statusFilter,
    this.searchQuery,
  });
  final List<StudyPlanModel> plans;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final String? statusFilter;
  final String? searchQuery;

  int get totalPages => (totalCount / pageSize).ceil().clamp(1, 9999);
}

class StudyPlanError extends StudyPlanState {
  StudyPlanError(this.message, {this.code});
  final String message;
  final String? code;
}

class StudyPlanSaving extends StudyPlanState {}

class StudyPlanSaved extends StudyPlanState {
  StudyPlanSaved(this.plan);
  final StudyPlanModel plan;
}

class StudyPlanDeleted extends StudyPlanState {}

// ─── Cubit ────────────────────────────────────────────────────────────
class StudyPlanCubit extends Cubit<StudyPlanState> {
  StudyPlanCubit({StudyPlanService? service})
      : _service = service ?? StudyPlanService(),
        super(StudyPlanInitial());

  final StudyPlanService _service;
  StreamSubscription? _realtimeSub;

  int _currentPage = 1;
  int _pageSize = 20;
  String? _statusFilter;
  String? _searchQuery;

  /// Load plans with current filters.
  Future<void> loadPlans({
    int? page,
    int? pageSize,
    String? status,
    String? searchQuery,
  }) async {
    if (page != null) _currentPage = page;
    if (pageSize != null) _pageSize = pageSize;
    if (status != null) _statusFilter = status.isEmpty ? null : status;
    if (searchQuery != null) _searchQuery = searchQuery.isEmpty ? null : searchQuery;

    emit(StudyPlanLoading());
    try {
      final result = await _service.getAll(
        page: _currentPage,
        pageSize: _pageSize,
        status: _statusFilter,
        searchQuery: _searchQuery,
      );
      emit(StudyPlanLoaded(
        plans: result.data,
        totalCount: result.count,
        currentPage: _currentPage,
        pageSize: _pageSize,
        statusFilter: _statusFilter,
        searchQuery: _searchQuery,
      ));
    } on ServiceException catch (e) {
      emit(StudyPlanError(e.message, code: e.code));
    }
  }

  /// Filter by status.
  Future<void> filterByStatus(String? status) async {
    await loadPlans(page: 1, status: status ?? '');
  }

  /// Search by name.
  Future<void> searchByName(String query) async {
    await loadPlans(page: 1, searchQuery: query);
  }

  /// Change page.
  Future<void> changePage(int page) async {
    await loadPlans(page: page);
  }

  /// Create a new study plan.
  Future<void> createPlan(StudyPlanModel plan) async {
    emit(StudyPlanSaving());
    try {
      final created = await _service.create(plan);
      emit(StudyPlanSaved(created));
      await loadPlans(page: 1);
    } on ServiceException catch (e) {
      emit(StudyPlanError(e.message, code: e.code));
    }
  }

  /// Update an existing plan.
  Future<void> updatePlan(String id, StudyPlanModel plan) async {
    emit(StudyPlanSaving());
    try {
      final updated = await _service.update(id, plan);
      emit(StudyPlanSaved(updated));
      await loadPlans();
    } on ServiceException catch (e) {
      emit(StudyPlanError(e.message, code: e.code));
    }
  }

  /// Delete a plan.
  Future<void> deletePlan(String id) async {
    emit(StudyPlanSaving());
    try {
      await _service.delete(id);
      emit(StudyPlanDeleted());
      await loadPlans();
    } on ServiceException catch (e) {
      emit(StudyPlanError(e.message, code: e.code));
    }
  }

  /// Copy a plan.
  Future<void> copyPlan({
    required String sourcePlanId,
    required String newName,
    required int newAcademicYear,
  }) async {
    emit(StudyPlanSaving());
    try {
      final copied = await _service.copyPlan(
        sourcePlanId: sourcePlanId,
        newName: newName,
        newAcademicYear: newAcademicYear,
      );
      emit(StudyPlanSaved(copied));
      await loadPlans();
    } on ServiceException catch (e) {
      emit(StudyPlanError(e.message, code: e.code));
    }
  }

  /// Start realtime subscription.
  void subscribeToChanges() {
    _realtimeSub?.cancel();
    _realtimeSub = _service.subscribeToChanges().listen((_) {
      // Reload current page when changes detected
      loadPlans();
    });
  }

  @override
  Future<void> close() {
    _realtimeSub?.cancel();
    return super.close();
  }
}
