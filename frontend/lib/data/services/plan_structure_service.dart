// file: lib/data/services/plan_structure_service.dart
import '../models/plan_structure_model.dart';
import 'base_service.dart';

class PlanStructureService extends BaseService {
  static const _table = 'plan_structure';

  Future<List<PlanStructureModel>> getByPlanId(String planId) async {
    return safeCall(() async {
      final data = await client.from(_table).select()
          .eq('plan_id', planId).order('level').order('term');
      return (data as List).map((e) =>
          PlanStructureModel.fromJson(e as Map<String, dynamic>)).toList();
    }, context: 'PlanStructureService.getByPlanId');
  }

  Future<PlanStructureModel> create(PlanStructureModel model) async {
    return safeCall(() async {
      final data = await client.from(_table)
          .insert(model.toInsertJson()).select().single();
      return PlanStructureModel.fromJson(data);
    }, context: 'PlanStructureService.create');
  }

  Future<PlanStructureModel> update(String id, PlanStructureModel model) async {
    return safeCall(() async {
      final data = await client.from(_table)
          .update(model.toUpdateJson()).eq('id', id).select().single();
      return PlanStructureModel.fromJson(data);
    }, context: 'PlanStructureService.update');
  }

  Future<void> delete(String id) async {
    return safeCall(() async {
      await client.from(_table).delete().eq('id', id);
    }, context: 'PlanStructureService.delete');
  }

  Future<List<PlanStructureModel>> bulkUpsert(
      List<PlanStructureModel> models) async {
    return safeCall(() async {
      final data = await client.from(_table)
          .upsert(models.map((m) => m.toInsertJson()).toList()).select();
      return (data as List).map((e) =>
          PlanStructureModel.fromJson(e as Map<String, dynamic>)).toList();
    }, context: 'PlanStructureService.bulkUpsert');
  }
}
