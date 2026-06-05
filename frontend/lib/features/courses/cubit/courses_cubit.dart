// file: lib/features/courses/cubit/courses_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/course_model.dart';
import '../../../data/services/course_service.dart';
import '../../../data/services/base_service.dart';

// ─── States ───────────────────────────────────────────────────────────
abstract class CoursesState {}
class CoursesInitial extends CoursesState {}
class CoursesLoading extends CoursesState {}

class CoursesLoaded extends CoursesState {
  CoursesLoaded({
    required this.courses,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.planId,
    this.levelFilter,
    this.termFilter,
    this.typeFilter,
    this.searchQuery,
  });
  final List<CourseModel> courses;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final String planId;
  final int? levelFilter;
  final String? termFilter;
  final String? typeFilter;
  final String? searchQuery;

  int get totalPages => (totalCount / pageSize).ceil().clamp(1, 9999);
}

class CoursesError extends CoursesState {
  CoursesError(this.message, {this.code});
  final String message;
  final String? code;
}

class CourseSaving extends CoursesState {}
class CourseSaved extends CoursesState {
  CourseSaved(this.course);
  final CourseModel course;
}
class CourseDeleted extends CoursesState {}

// ─── Cubit ────────────────────────────────────────────────────────────
class CoursesCubit extends Cubit<CoursesState> {
  CoursesCubit({CourseService? service})
      : _service = service ?? CourseService(),
        super(CoursesInitial());

  final CourseService _service;
  StreamSubscription? _realtimeSub;

  String _planId = '';
  int _currentPage = 1;
  int _pageSize = 20;
  int? _levelFilter;
  String? _termFilter;
  String? _typeFilter;
  String? _searchQuery;

  Future<void> loadCourses({
    required String planId,
    int? page,
    int? pageSize,
    int? level,
    String? term,
    String? courseType,
    String? searchQuery,
  }) async {
    _planId = planId;
    if (page != null) _currentPage = page;
    if (pageSize != null) _pageSize = pageSize;
    if (level != null) _levelFilter = level == 0 ? null : level;
    if (term != null) _termFilter = term.isEmpty ? null : term;
    if (courseType != null) _typeFilter = courseType.isEmpty ? null : courseType;
    if (searchQuery != null) _searchQuery = searchQuery.isEmpty ? null : searchQuery;

    emit(CoursesLoading());
    try {
      final result = await _service.getAll(
        planId: _planId,
        page: _currentPage,
        pageSize: _pageSize,
        level: _levelFilter,
        term: _termFilter,
        courseType: _typeFilter,
        searchQuery: _searchQuery,
      );
      emit(CoursesLoaded(
        courses: result.data,
        totalCount: result.count,
        currentPage: _currentPage,
        pageSize: _pageSize,
        planId: _planId,
        levelFilter: _levelFilter,
        termFilter: _termFilter,
        typeFilter: _typeFilter,
        searchQuery: _searchQuery,
      ));
    } on ServiceException catch (e) {
      emit(CoursesError(e.message, code: e.code));
    }
  }

  Future<void> createCourse(CourseModel course) async {
    emit(CourseSaving());
    try {
      final created = await _service.create(course);
      emit(CourseSaved(created));
      await loadCourses(planId: _planId);
    } on ServiceException catch (e) {
      emit(CoursesError(e.message, code: e.code));
    }
  }

  Future<void> updateCourse(String id, CourseModel course) async {
    emit(CourseSaving());
    try {
      final updated = await _service.update(id, course);
      emit(CourseSaved(updated));
      await loadCourses(planId: _planId);
    } on ServiceException catch (e) {
      emit(CoursesError(e.message, code: e.code));
    }
  }

  Future<void> deleteCourse(String id) async {
    emit(CourseSaving());
    try {
      await _service.delete(id);
      emit(CourseDeleted());
      await loadCourses(planId: _planId);
    } on ServiceException catch (e) {
      emit(CoursesError(e.message, code: e.code));
    }
  }

  void subscribeToChanges(String planId) {
    _realtimeSub?.cancel();
    _realtimeSub = _service.subscribeToChanges(planId).listen((_) {
      loadCourses(planId: planId);
    });
  }

  @override
  Future<void> close() {
    _realtimeSub?.cancel();
    return super.close();
  }
}
