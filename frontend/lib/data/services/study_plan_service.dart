// file: lib/data/services/study_plan_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/study_plan_model.dart';
import 'base_service.dart';

class StudyPlanService extends BaseService {
  static const _table = 'study_plans';
  static const _select =
      '*, departments(name_ar), programs(name_ar)';

  /// Fetch paginated study plans with optional filters.
  Future<({List<StudyPlanModel> data, int count})> getAll({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? departmentId,
    String? searchQuery,
  }) async {
    return safeCall(() async {
      final range = pageRange(page, pageSize);
      var query = client.from(_table).select(_select);

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }
      if (departmentId != null && departmentId.isNotEmpty) {
        query = query.eq('department_id', departmentId);
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('name', '%$searchQuery%');
      }

      final data = await query
          .order('created_at', ascending: false)
          .range(range.from, range.to);

      // Get count separately
      final countResult = await _buildCountQuery(
        status: status,
        departmentId: departmentId,
        searchQuery: searchQuery,
      );

      return (
        data: (data as List).map((e) =>
            StudyPlanModel.fromJson(e as Map<String, dynamic>)).toList(),
        count: countResult,
      );
    }, context: 'StudyPlanService.getAll');
  }

  Future<int> _buildCountQuery({
    String? status,
    String? departmentId,
    String? searchQuery,
  }) async {
    var query = client.from(_table).select('id');
    if (status != null && status.isNotEmpty) {
      query = query.eq('status', status);
    }
    if (departmentId != null && departmentId.isNotEmpty) {
      query = query.eq('department_id', departmentId);
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.ilike('name', '%$searchQuery%');
    }
    final result = await query;
    return (result as List).length;
  }

  /// Fetch a single study plan by ID.
  Future<StudyPlanModel> getById(String id) async {
    return safeCall(() async {
      final data = await client
          .from(_table)
          .select(_select)
          .eq('id', id)
          .single();
      return StudyPlanModel.fromJson(data);
    }, context: 'StudyPlanService.getById');
  }

  /// Create a new study plan.
  Future<StudyPlanModel> create(StudyPlanModel model) async {
    return safeCall(() async {
      final data = await client
          .from(_table)
          .insert(model.toInsertJson())
          .select(_select)
          .single();
      return StudyPlanModel.fromJson(data);
    }, context: 'StudyPlanService.create');
  }

  /// Update an existing study plan.
  Future<StudyPlanModel> update(String id, StudyPlanModel model) async {
    return safeCall(() async {
      final data = await client
          .from(_table)
          .update(model.toUpdateJson())
          .eq('id', id)
          .select(_select)
          .single();
      return StudyPlanModel.fromJson(data);
    }, context: 'StudyPlanService.update');
  }

  /// Delete a study plan.
  Future<void> delete(String id) async {
    return safeCall(() async {
      await client.from(_table).delete().eq('id', id);
    }, context: 'StudyPlanService.delete');
  }

  /// Copy an existing plan (deep copy with a new name/year).
  Future<StudyPlanModel> copyPlan({
    required String sourcePlanId,
    required String newName,
    required int newAcademicYear,
  }) async {
    return safeCall(() async {
      final source = await getById(sourcePlanId);
      final copy = source.copyWith(
        id: null,
        name: newName,
        academicYear: newAcademicYear,
        version: source.version + 1,
        isCurrent: false,
        status: 'draft',
        createdAt: null,
        updatedAt: null,
      );
      return create(copy);
    }, context: 'StudyPlanService.copyPlan');
  }

  /// Realtime subscription on study_plans changes.
  Stream<List<Map<String, dynamic>>> subscribeToChanges() {
    return client
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }
}
