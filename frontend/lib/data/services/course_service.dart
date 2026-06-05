// file: lib/data/services/course_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_model.dart';
import '../models/course_conflict_model.dart';
import '../models/course_equivalent_model.dart';
import 'base_service.dart';

class CourseService extends BaseService {
  static const _table = 'courses';

  /// Fetch paginated courses for a specific plan.
  Future<({List<CourseModel> data, int count})> getAll({
    required String planId,
    int page = 1,
    int pageSize = 20,
    int? level,
    String? term,
    String? courseType,
    String? searchQuery,
  }) async {
    return safeCall(() async {
      final range = pageRange(page, pageSize);
      var query = client.from(_table).select().eq('plan_id', planId);

      if (level != null) {
        query = query.eq('level', level);
      }
      if (term != null && term.isNotEmpty) {
        query = query.eq('term', term);
      }
      if (courseType != null && courseType.isNotEmpty) {
        query = query.eq('course_type', courseType);
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('code.ilike.%$searchQuery%,name_ar.ilike.%$searchQuery%');
      }

      final data = await query
          .order('level')
          .order('term')
          .order('code')
          .range(range.from, range.to);

      // Count
      var countQuery = client.from(_table).select('id').eq('plan_id', planId);
      if (level != null) countQuery = countQuery.eq('level', level);
      if (term != null && term.isNotEmpty) {
        countQuery = countQuery.eq('term', term);
      }
      if (courseType != null && courseType.isNotEmpty) {
        countQuery = countQuery.eq('course_type', courseType);
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        countQuery = countQuery.or(
            'code.ilike.%$searchQuery%,name_ar.ilike.%$searchQuery%');
      }
      final countResult = await countQuery;

      return (
        data: (data as List)
            .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        count: (countResult as List).length,
      );
    }, context: 'CourseService.getAll');
  }

  /// Fetch all courses for a plan (no pagination — for dropdowns/selectors).
  Future<List<CourseModel>> getAllForPlan(String planId) async {
    return safeCall(() async {
      final data = await client
          .from(_table)
          .select()
          .eq('plan_id', planId)
          .order('level')
          .order('code');
      return (data as List)
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }, context: 'CourseService.getAllForPlan');
  }

  /// Fetch a single course by ID.
  Future<CourseModel> getById(String id) async {
    return safeCall(() async {
      final data =
          await client.from(_table).select().eq('id', id).single();
      return CourseModel.fromJson(data);
    }, context: 'CourseService.getById');
  }

  /// Create a new course.
  Future<CourseModel> create(CourseModel model) async {
    return safeCall(() async {
      final data = await client
          .from(_table)
          .insert(model.toInsertJson())
          .select()
          .single();
      return CourseModel.fromJson(data);
    }, context: 'CourseService.create');
  }

  /// Update an existing course.
  Future<CourseModel> update(String id, CourseModel model) async {
    return safeCall(() async {
      final data = await client
          .from(_table)
          .update(model.toUpdateJson())
          .eq('id', id)
          .select()
          .single();
      return CourseModel.fromJson(data);
    }, context: 'CourseService.update');
  }

  /// Delete a course.
  Future<void> delete(String id) async {
    return safeCall(() async {
      await client.from(_table).delete().eq('id', id);
    }, context: 'CourseService.delete');
  }

  // ─── Course Conflicts ────────────────────────────────────────────────

  Future<List<CourseConflictModel>> getConflicts(String courseId) async {
    return safeCall(() async {
      final data = await client
          .from('course_conflicts')
          .select('*, course:courses!course_id(code, name_ar), '
              'conflicting_course:courses!conflicting_course_id(code, name_ar)')
          .eq('course_id', courseId);
      return (data as List)
          .map((e) =>
              CourseConflictModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }, context: 'CourseService.getConflicts');
  }

  Future<CourseConflictModel> addConflict(CourseConflictModel model) async {
    return safeCall(() async {
      final data = await client
          .from('course_conflicts')
          .insert(model.toInsertJson())
          .select()
          .single();
      return CourseConflictModel.fromJson(data);
    }, context: 'CourseService.addConflict');
  }

  Future<void> removeConflict(String id) async {
    return safeCall(() async {
      await client.from('course_conflicts').delete().eq('id', id);
    }, context: 'CourseService.removeConflict');
  }

  // ─── Course Equivalents ──────────────────────────────────────────────

  Future<List<CourseEquivalentModel>> getEquivalents(
      String courseId) async {
    return safeCall(() async {
      final data = await client
          .from('course_equivalents')
          .select('*, courses(code, name_ar)')
          .eq('course_id', courseId);
      return (data as List)
          .map((e) =>
              CourseEquivalentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }, context: 'CourseService.getEquivalents');
  }

  Future<CourseEquivalentModel> addEquivalent(
      CourseEquivalentModel model) async {
    return safeCall(() async {
      final data = await client
          .from('course_equivalents')
          .insert(model.toInsertJson())
          .select()
          .single();
      return CourseEquivalentModel.fromJson(data);
    }, context: 'CourseService.addEquivalent');
  }

  Future<void> removeEquivalent(String id) async {
    return safeCall(() async {
      await client.from('course_equivalents').delete().eq('id', id);
    }, context: 'CourseService.removeEquivalent');
  }

  /// Realtime subscription on courses changes.
  Stream<List<Map<String, dynamic>>> subscribeToChanges(String planId) {
    return client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('plan_id', planId)
        .order('level');
  }
}
