// file: lib/data/services/elective_group_service.dart
import '../models/elective_group_model.dart';
import 'base_service.dart';

class ElectiveGroupService extends BaseService {
  static const _table = 'elective_groups';
  static const _select =
      '*, elective_group_courses(course_id), elective_group_rules(*)';

  /// Get all elective groups for a plan.
  Future<List<ElectiveGroupModel>> getByPlanId(String planId) async {
    return safeCall(() async {
      final data = await client
          .from(_table)
          .select(_select)
          .eq('plan_id', planId)
          .order('code');
      return (data as List)
          .map((e) =>
              ElectiveGroupModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }, context: 'ElectiveGroupService.getByPlanId');
  }

  /// Get single elective group.
  Future<ElectiveGroupModel> getById(String id) async {
    return safeCall(() async {
      final data = await client
          .from(_table)
          .select(_select)
          .eq('id', id)
          .single();
      return ElectiveGroupModel.fromJson(data);
    }, context: 'ElectiveGroupService.getById');
  }

  /// Create an elective group.
  Future<ElectiveGroupModel> create(ElectiveGroupModel model) async {
    return safeCall(() async {
      final data = await client
          .from(_table)
          .insert(model.toInsertJson())
          .select(_select)
          .single();
      return ElectiveGroupModel.fromJson(data);
    }, context: 'ElectiveGroupService.create');
  }

  /// Update an elective group.
  Future<ElectiveGroupModel> update(
      String id, ElectiveGroupModel model) async {
    return safeCall(() async {
      final data = await client
          .from(_table)
          .update(model.toUpdateJson())
          .eq('id', id)
          .select(_select)
          .single();
      return ElectiveGroupModel.fromJson(data);
    }, context: 'ElectiveGroupService.update');
  }

  /// Delete an elective group.
  Future<void> delete(String id) async {
    return safeCall(() async {
      // Delete related courses and rules first
      await client.from('elective_group_courses').delete().eq('group_id', id);
      await client.from('elective_group_rules').delete().eq('group_id', id);
      await client.from(_table).delete().eq('id', id);
    }, context: 'ElectiveGroupService.delete');
  }

  // ─── Course assignments ──────────────────────────────────────────────

  /// Assign courses to an elective group.
  Future<void> assignCourses(
      String groupId, List<String> courseIds) async {
    return safeCall(() async {
      // Clear existing
      await client
          .from('elective_group_courses')
          .delete()
          .eq('group_id', groupId);
      // Insert new
      if (courseIds.isNotEmpty) {
        await client.from('elective_group_courses').insert(
          courseIds
              .map((cId) => {'group_id': groupId, 'course_id': cId})
              .toList(),
        );
      }
    }, context: 'ElectiveGroupService.assignCourses');
  }

  // ─── Rules ───────────────────────────────────────────────────────────

  /// Upsert rules for a group.
  Future<void> upsertRules(ElectiveGroupRulesModel rules) async {
    return safeCall(() async {
      await client.from('elective_group_rules').upsert(
        rules.toInsertJson(),
        onConflict: 'group_id',
      );
    }, context: 'ElectiveGroupService.upsertRules');
  }
}
