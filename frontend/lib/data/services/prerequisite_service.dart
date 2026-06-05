// file: lib/data/services/prerequisite_service.dart
import '../models/prerequisite_model.dart';
import 'base_service.dart';

class PrerequisiteService extends BaseService {
  static const _table = 'prerequisites';
  static const _select =
      '*, courses!course_id(code, name_ar), '
      'required_course:courses!required_course_id(code, name_ar)';

  /// Get all prerequisites for a specific course.
  Future<List<PrerequisiteModel>> getByCourseId(String courseId) async {
    return safeCall(() async {
      final data = await client
          .from(_table)
          .select(_select)
          .eq('course_id', courseId);
      return (data as List)
          .map((e) =>
              PrerequisiteModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }, context: 'PrerequisiteService.getByCourseId');
  }

  /// Get all prerequisites for all courses in a plan.
  Future<List<PrerequisiteModel>> getByPlanId(String planId) async {
    return safeCall(() async {
      // Join through courses table to filter by plan_id
      final courseIds = await client
          .from('courses')
          .select('id')
          .eq('plan_id', planId);
      final ids = (courseIds as List)
          .map((e) => (e as Map<String, dynamic>)['id'] as String)
          .toList();
      if (ids.isEmpty) return [];

      final data = await client
          .from(_table)
          .select(_select)
          .inFilter('course_id', ids);
      return (data as List)
          .map((e) =>
              PrerequisiteModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }, context: 'PrerequisiteService.getByPlanId');
  }

  /// Create a prerequisite.
  Future<PrerequisiteModel> create(PrerequisiteModel model) async {
    return safeCall(() async {
      final data = await client
          .from(_table)
          .insert(model.toInsertJson())
          .select(_select)
          .single();
      return PrerequisiteModel.fromJson(data);
    }, context: 'PrerequisiteService.create');
  }

  /// Update a prerequisite.
  Future<PrerequisiteModel> update(
      String id, PrerequisiteModel model) async {
    return safeCall(() async {
      final data = await client
          .from(_table)
          .update(model.toUpdateJson())
          .eq('id', id)
          .select(_select)
          .single();
      return PrerequisiteModel.fromJson(data);
    }, context: 'PrerequisiteService.update');
  }

  /// Delete a prerequisite.
  Future<void> delete(String id) async {
    return safeCall(() async {
      await client.from(_table).delete().eq('id', id);
    }, context: 'PrerequisiteService.delete');
  }
}
